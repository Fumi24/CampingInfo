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

-- Checks the tooltip's actual current lines for our marker, rather than
-- trusting a cached "already added" flag. The game appears to rebuild the
-- tooltip's content on each fresh hover of a placed object — including a
-- repeat hover of the very same object — without a Hide/Show transition we
-- can reliably observe, which silently wiped our lines while cached dedup
-- state still believed they were present. Reading the tooltip itself can't
-- go stale that way.
local function TooltipHasCampingBenefit(tooltip)
    local tooltipName = tooltip:GetName()
    if not tooltipName then
        return false
    end

    for i = 1, tooltip:NumLines() do
        local fontString = _G[tooltipName .. "TextLeft" .. i]
        if fontString and fontString:GetText() == "Camping Benefit" then
            return true
        end
    end

    return false
end

local function AddCampingLines(tooltip, itemID)
    local entry = ns.CampingItems[itemID]
    if not entry then
        return
    end

    if TooltipHasCampingBenefit(tooltip) then
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

--[[
Name-based fallback for placed Camping structures.

A Camping item hovered in bags/bank/vendor fires an item tooltip and is
matched by item ID above. Once placed at a campsite, the same feature is a
world object rather than an item link, so no item ID is available — it may
render as a unit tooltip (a common way custom servers implement clickable
world props) or something else entirely. Instead of guessing the object
type, this reads whatever text the tooltip actually rendered and matches
it against known Camping item names.
--]]

local function GetTooltipFirstLineText(tooltip)
    if not tooltip or not tooltip.GetName then
        return nil
    end

    local tooltipName = tooltip:GetName()
    if not tooltipName then
        return nil
    end

    local fontString = _G[tooltipName .. "TextLeft1"]
    if not fontString or not fontString.GetText then
        return nil
    end

    return fontString:GetText()
end

local function OnTooltipNameFallback(tooltip)
    if not CampingInfoSettings.enabled then
        return
    end

    local text = GetTooltipFirstLineText(tooltip)
    if not text then
        return
    end

    -- Substring match rather than exact equality: a placed object's tooltip
    -- may add coloring, an owner tag, or other text around the item name.
    local lowerText = text:lower()
    for id, entry in pairs(ns.CampingItems) do
        if lowerText:find(entry.name:lower(), 1, true) then
            AddCampingLines(tooltip, id)
            return
        end

        if entry.aliases then
            for _, alias in ipairs(entry.aliases) do
                if lowerText:find(alias:lower(), 1, true) then
                    AddCampingLines(tooltip, id)
                    return
                end
            end
        end
    end
end

-- Tracks the tooltip text last processed by the OnUpdate poll below, purely
-- as a fast-path skip so the name-matching loop doesn't run every single
-- frame. It is NOT relied on for correctness — the tooltip can be silently
-- rebuilt (wiping our lines) while the name text stays the same, so this
-- also re-checks TooltipHasCampingBenefit even when the text is unchanged.
local lastPolledText = nil

local function PollTooltipForNameFallback(tooltip)
    local text = GetTooltipFirstLineText(tooltip)
    if not text then
        return
    end

    if text == lastPolledText and TooltipHasCampingBenefit(tooltip) then
        return
    end

    lastPolledText = text
    OnTooltipNameFallback(tooltip)
end

local function RegisterTooltipHook()
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
            OnTooltipItem(tooltip, data)
        end)

        if Enum.TooltipDataType.Unit then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
                OnTooltipNameFallback(tooltip)
            end)
        end
    else
        -- Classic-style fallback for clients without TooltipDataProcessor.
        GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
            OnTooltipItem(tooltip, nil)
        end)

        if ItemRefTooltip then
            ItemRefTooltip:HookScript("OnTooltipSetItem", function(tooltip)
                OnTooltipItem(tooltip, nil)
            end)
        end

        GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
            OnTooltipNameFallback(tooltip)
        end)
    end

    -- Catch-all: whatever type of tooltip a placed world object turns out
    -- to use, this still catches it once the tooltip actually renders.
    GameTooltip:HookScript("OnShow", function(tooltip)
        OnTooltipNameFallback(tooltip)
    end)

    -- Plain-text world-object tooltips fire neither OnTooltipSetItem nor
    -- OnTooltipSetUnit, and moving the mouse directly from one such object
    -- to another updates the text in place without an OnShow transition.
    -- Polling on OnUpdate is what actually catches those reliably.
    GameTooltip:HookScript("OnUpdate", function(tooltip)
        PollTooltipForNameFallback(tooltip)
    end)

    GameTooltip:HookScript("OnHide", function()
        lastPolledText = nil
    end)
end

local function HandleSlashCommand(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")

    if msg == "on" then
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
