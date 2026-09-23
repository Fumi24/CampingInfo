local ADDON_NAME, ns = ...

CampingInfoSettings = CampingInfoSettings or {}

local function InitSettings()
    if CampingInfoSettings.enabled == nil then
        CampingInfoSettings.enabled = true
    end
    if CampingInfoSettings.detailed == nil then
        CampingInfoSettings.detailed = false
    end
end

-- Tracks the last itemID rendered per tooltip so repeated post-call
-- invocations for the same item (e.g. tooltip refreshes) don't duplicate
-- the Camping Benefit block. Weak-keyed so tooltip frames can still be GC'd.
local appliedTooltips = setmetatable({}, { __mode = "k" })

local function GetItemIDFromTooltip(tooltip, tooltipData)
    if tooltipData and tooltipData.id then
        return tooltipData.id
    end

    if not tooltip or not tooltip.GetItem then
        return nil
    end

    local _, itemLink = tooltip:GetItem()
    if not itemLink then
        return nil
    end

    local idString = itemLink:match("item:(%d+)")
    if not idString then
        return nil
    end

    return tonumber(idString)
end

local function AddCampingLines(tooltip, itemID)
    local entry = ns.CampingItems[itemID]
    if not entry then
        return
    end

    if appliedTooltips[tooltip] == itemID then
        return
    end

    tooltip:AddLine(" ")
    tooltip:AddLine("Camping Benefit", 1.0, 0.82, 0.0)

    if entry.buff then
        tooltip:AddLine(entry.buff, 0.3, 1.0, 0.3, true)
    end

    if entry.utility then
        tooltip:AddLine("Utility: " .. entry.utility, 0.8, 0.8, 0.8, true)
    end

    if CampingInfoSettings.detailed and entry.exclusiveWith then
        tooltip:AddLine("Does not stack with " .. entry.exclusiveWith, 0.7, 0.3, 0.3, true)
    end

    if entry.profession and entry.tier then
        tooltip:AddLine(string.format("%s \194\183 Tier %d", entry.profession, entry.tier), 0.6, 0.6, 0.6)
    end

    tooltip:Show()
    appliedTooltips[tooltip] = itemID
end

local function OnTooltipItem(tooltip, tooltipData)
    if not CampingInfoSettings.enabled then
        return
    end

    local itemID = GetItemIDFromTooltip(tooltip, tooltipData)
    if not itemID then
        return
    end

    AddCampingLines(tooltip, itemID)
end

local function RegisterTooltipHook()
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
            OnTooltipItem(tooltip, data)
        end)
        return
    end

    -- Classic-style fallback for clients without TooltipDataProcessor.
    GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        OnTooltipItem(tooltip, nil)
    end)

    if ItemRefTooltip then
        ItemRefTooltip:HookScript("OnTooltipSetItem", function(tooltip)
            OnTooltipItem(tooltip, nil)
        end)
    end
end

local function PrintCurrentTooltipItemID()
    local _, itemLink = GameTooltip:GetItem()
    if not itemLink then
        print("|cffffcc00CampingInfo|r: no item tooltip is currently visible.")
        return
    end

    local idString = itemLink:match("item:(%d+)")
    local name = itemLink:match("%[(.-)%]")

    if idString then
        print(string.format("|cffffcc00CampingInfo|r: %s -> item ID %s", name or itemLink, idString))
    else
        print("|cffffcc00CampingInfo|r: could not parse an item ID from the current tooltip.")
    end
end

--[[
Bulk ID discovery.

Hovering all ~38 Camping items one at a time isn't realistic, so `/ci scan`
instead checks your bags, an open bank, and an open vendor window for any
item whose name matches a known Camping item, and prints a ready-to-paste
Data.lua block for everything it finds in one pass.
--]]

local nameToSlug = {}
for slug, entry in pairs(ns.CampingItemsPending) do
    nameToSlug[entry.name:lower()] = slug
end

local function TryMatchLink(itemLink, results)
    if not itemLink then
        return
    end

    local idString = itemLink:match("item:(%d+)")
    local name = itemLink:match("%[(.-)%]")
    if not idString or not name then
        return
    end

    local slug = nameToSlug[name:lower()]
    if not slug or results[slug] then
        return
    end

    results[slug] = tonumber(idString)
end

local function ScanContainerSlots(bagID, results)
    local getLink = (C_Container and C_Container.GetContainerItemLink) or GetContainerItemLink
    local getNumSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
    if not getLink or not getNumSlots then
        return
    end

    local numSlots = getNumSlots(bagID) or 0
    for slot = 1, numSlots do
        TryMatchLink(getLink(bagID, slot), results)
    end
end

local function ScanBags(results)
    for bagID = 0, (NUM_BAG_SLOTS or 4) do
        ScanContainerSlots(bagID, results)
    end
end

local function ScanBank(results)
    if not (BankFrame and BankFrame:IsShown()) then
        return
    end

    ScanContainerSlots(BANK_CONTAINER or -1, results)

    local firstBankBag = (NUM_BAG_SLOTS or 4) + 1
    local lastBankBag = firstBankBag + (NUM_BANKBAGSLOTS or 7) - 1
    for bagID = firstBankBag, lastBankBag do
        ScanContainerSlots(bagID, results)
    end
end

local function ScanMerchant(results)
    if not (MerchantFrame and MerchantFrame:IsShown() and GetMerchantNumItems and GetMerchantItemLink) then
        return
    end

    for i = 1, GetMerchantNumItems() do
        TryMatchLink(GetMerchantItemLink(i), results)
    end
end

local function FormatResults(results)
    local slugs, count = {}, 0
    for slug in pairs(results) do
        count = count + 1
        slugs[count] = slug
    end

    if count == 0 then
        return nil, 0
    end

    table.sort(slugs)

    local lines = {
        "-- Paste each block into ns.CampingItems in Data.lua, then delete the",
        "-- matching entry from ns.CampingItemsPending.",
        "",
    }

    for _, slug in ipairs(slugs) do
        local entry = ns.CampingItemsPending[slug]
        local itemID = results[slug]

        table.insert(lines, string.format("[%d] = { -- %s", itemID, entry.name))
        table.insert(lines, string.format("    name = %q, profession = %q, tier = %d,", entry.name, entry.profession, entry.tier))

        if entry.buff then
            table.insert(lines, string.format("    buff = %q,", entry.buff))
        end
        if entry.utility then
            table.insert(lines, string.format("    utility = %q,", entry.utility))
        end
        if entry.exclusiveWith then
            table.insert(lines, string.format("    exclusiveWith = %q,", entry.exclusiveWith))
        end
        if type(entry.inheritedFrom) == "number" then
            table.insert(lines, string.format("    inheritedFrom = %d,", entry.inheritedFrom))
        elseif entry.inheritedFrom then
            local inheritedID = results[entry.inheritedFrom]
            if inheritedID then
                table.insert(lines, string.format("    inheritedFrom = %d,", inheritedID))
            else
                table.insert(lines, string.format("    -- TODO inheritedFrom: %s (not found this scan)", entry.inheritedFrom))
            end
        end
        if entry.notes then
            table.insert(lines, string.format("    -- %s", entry.notes))
        end

        table.insert(lines, "    verified = true,")
        table.insert(lines, "},")
        table.insert(lines, "")
    end

    return table.concat(lines, "\n"), count
end

local copyFrame

local function ShowCopyBox(text)
    if not copyFrame then
        local f = CreateFrame("Frame", "CampingInfoCopyFrame", UIParent, "BackdropTemplate")
        f:SetSize(560, 420)
        f:SetPoint("CENTER")
        f:SetFrameStrata("DIALOG")
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        f:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        f:SetBackdropColor(0, 0, 0, 1)

        local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOP", 0, -12)
        title:SetText("CampingInfo scan results - Ctrl+A, Ctrl+C to copy")

        local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT")
        close:SetScript("OnClick", function() f:Hide() end)

        local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 12, -32)
        scroll:SetPoint("BOTTOMRIGHT", -32, 12)

        local edit = CreateFrame("EditBox", nil, scroll)
        edit:SetMultiLine(true)
        edit:SetFontObject(ChatFontNormal)
        edit:SetWidth(500)
        edit:SetAutoFocus(false)
        edit:SetScript("OnEscapePressed", function() f:Hide() end)
        scroll:SetScrollChild(edit)

        f.editBox = edit
        copyFrame = f
    end

    copyFrame.editBox:SetText(text)
    copyFrame.editBox:HighlightText()
    copyFrame:Show()
    copyFrame.editBox:SetFocus()
end

local function ScanForCampingItems()
    local results = {}
    ScanBags(results)
    ScanBank(results)
    ScanMerchant(results)

    local text, count = FormatResults(results)
    if count == 0 then
        print("|cffffcc00CampingInfo|r: no known Camping items found in your bags" ..
            ((BankFrame and BankFrame:IsShown()) and ", bank" or "") ..
            ((MerchantFrame and MerchantFrame:IsShown()) and ", or open vendor" or "") .. ".")
        return
    end

    print(string.format("|cffffcc00CampingInfo|r: found %d known Camping item(s). Opening copy box.", count))
    ShowCopyBox(text)
end

local function HandleSlashCommand(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")

    if msg == "id" then
        PrintCurrentTooltipItemID()
    elseif msg == "scan" then
        ScanForCampingItems()
    elseif msg == "on" then
        CampingInfoSettings.enabled = true
        print("|cffffcc00CampingInfo|r: enabled.")
    elseif msg == "off" then
        CampingInfoSettings.enabled = false
        print("|cffffcc00CampingInfo|r: disabled.")
    elseif msg == "detailed on" then
        CampingInfoSettings.detailed = true
        print("|cffffcc00CampingInfo|r: detailed mode enabled.")
    elseif msg == "detailed off" then
        CampingInfoSettings.detailed = false
        print("|cffffcc00CampingInfo|r: detailed mode disabled.")
    else
        print("|cffffcc00CampingInfo|r commands:")
        print("  /ci id - print the item ID of the currently shown tooltip")
        print("  /ci scan - scan bags/bank/open vendor for known Camping items")
        print("  /ci on | off - toggle the Camping Benefit tooltip section")
        print("  /ci detailed on | off - toggle exclusivity/conflict notes")
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, loadedAddonName)
    if loadedAddonName ~= ADDON_NAME then
        return
    end

    InitSettings()
    RegisterTooltipHook()

    SLASH_CAMPINGINFO1 = "/ci"
    SlashCmdList.CAMPINGINFO = HandleSlashCommand

    self:UnregisterEvent("ADDON_LOADED")
end)
