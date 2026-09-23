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

local function HandleSlashCommand(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")

    if msg == "id" then
        PrintCurrentTooltipItemID()
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
