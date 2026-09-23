# CampingInfo — Claude Code Implementation Plan

## 1. Goal

Build a lightweight World of Warcraft: Forever addon that augments **item tooltips** for Camping feature items.

When the player mouses over a Camping item (bags, bank, merchant, profession/crafting UI, chat link, etc.), append a compact section explaining **what benefit that item provides when placed near a campfire**.

Example desired tooltip addition:

```text
Camping Benefit
+2% Critical Strike
Higher tiers also provide this benefit.
```

For utility-only items:

```text
Camping Benefit
Repair gear + purchase reagents
```

The addon must not replace Blizzard's tooltip text. It should add a clearer, normalized summary beneath the normal tooltip.

## 2. Product Scope

### MVP

- Detect hovered item tooltips.
- Resolve item ID from the tooltip/item link.
- Look up the item in a local Camping item database.
- Append:
  - `Camping Benefit` header.
  - Primary buff/benefit in plain language.
  - Optional secondary utility.
  - Optional exclusivity/conflict note if known.
  - Tier and profession in muted text.
- Support all known primary- and secondary-profession Camping feature items from the Wowhead Forever Camping guide.
- Avoid duplicated tooltip lines when Blizzard refreshes a tooltip.
- Work without external libraries.
- Fail silently for non-Camping items.

### Nice-to-have after MVP

- Optional `/cbt` commands.
- Enable/disable addon tooltip section.
- Compact vs detailed tooltip mode.
- Show required profession skill.
- Show whether a higher tier inherits the same buff.
- Localization-ready string table.
- Debug command that prints an item's item ID from the current tooltip/link.

### Explicitly out of scope for v1

- Detecting whether the player is physically near a campfire.
- Tracking active Camping buffs on the player.
- Automatically choosing the "best" camp feature.
- Scraping Wowhead at runtime.
- Ace3 or other addon frameworks.

## 3. Source of Truth / Research Notes

Primary source:

- Wowhead: `https://www.wowhead.com/forever/guide/camping-overview-unlock-rewards`
- Guide revision observed: 2026-09-22, Patch 1.60.1.

Important implementation caveat:

Some numeric spell values in the web-rendered guide are malformed/concatenated. Do **not** copy those raw numbers into the addon unless verified from the live game tooltip/spell data. Prefer normalized descriptions such as `Increased Strength`, `Mana regeneration`, or `8% increased stats` where the guide text is unambiguous.

The first development pass should verify item IDs and exact visible values from the client. The database schema below is designed so those can be corrected without touching tooltip logic.

## 4. Known Camping Feature Matrix

Use this matrix to seed `Data.lua`. Higher tiers should include inherited Tier 1 benefits where the guide says they provide all benefits of the lower-tier object.

| Profession | Tier | Item | Normalized camping benefit |
|---|---:|---|---|
| Alchemy | 1 | Mana Well | Mana regeneration |
| Alchemy | 2 | Fermenter | Create certain reagents; inherits Mana Well mana regeneration |
| Alchemy | 3 | Alchemy Laboratory | Enables recipes requiring an Alchemy Lab; inherits Mana Well mana regeneration |
| Blacksmithing | 1 | Sharpening Wheel | Increased Strength |
| Blacksmithing | 2 | Anvil | Usable anvil; inherits Increased Strength |
| Blacksmithing | 3 | Master Forge | Enables recipes requiring a Forge; inherits Increased Strength |
| Enchanting | 1 | Enchanted Lute | Increased Armor, All Stats, and Resistances (verify exact live behavior/text) |
| Enchanting | 2 | Arcane Salvager | More efficient disenchanting; inherits Enchanted Lute benefit |
| Enchanting | 3 | Arcane Forge | Enables recipes requiring an Arcane Forge; inherits Enchanted Lute benefit |
| Engineering | 1 | Reagent Bot | Purchase reagents |
| Engineering | 2 | Repair Bot | Purchase reagents and repair gear |
| Engineering | 3 | Anarchist's Workbench | Enables recipes requiring the workbench |
| Herbalism | 1 | Incense Candle | Increased Intellect |
| Herbalism | 2 | Greenhouse | Grow herbs from planted seeds; inherits Increased Intellect |
| Herbalism | 3 | Seed Hybridizer | Multiply/combine seeds; inherits Increased Intellect |
| Leatherworking | 1 | Camp Tent | Rested XP up to 5% of a level |
| Leatherworking | 2 | Tanning Rack | Create certain reagents; inherits Camp Tent rested-XP benefit |
| Leatherworking | 3 | Sewing Machine | Enables recipes requiring it; inherits Camp Tent rested-XP benefit |
| Mining | 1 | Lodestone | Increased melee Attack Power |
| Mining | 2 | Rock Garden | Spawns a common mining node over time; inherits melee Attack Power |
| Mining | 3 | Molten Foundry | Enables recipes requiring it; inherits melee Attack Power |
| Skinning | 1 | Camp Chair | +2% Critical Strike |
| Skinning | 2 | Field Guide | Grants Track Beasts; inherits +2% Critical Strike |
| Skinning | 3 | Trapper's Workbench | Contains 1 trap; inherits +2% Critical Strike |
| Tailoring | 1 | Faction Banner | Increased Spirit |
| Tailoring | 2 | Spinning Wheel | Create certain reagents; inherits Increased Spirit |
| Tailoring | 3 | Loom | Enables recipes requiring it; inherits Increased Spirit |
| Cooking | 1 | Basic Campfire | Cooking + up to 3 additional camp features |
| Cooking | 2 | Journeyman Campfire | Cooking + up to 5 additional camp features |
| Cooking | 2 | Cookie's Feast | Stamina-boosting food |
| Cooking | 3 | Expert Campfire | Cooking + up to 10 additional camp features |
| Cooking | 4 | Iron Oven | Required for advanced cooking recipes |
| First Aid | 1 | First Aid Kit | Stamina buff |
| First Aid | 2 | Toxin Study | Healing potions and antivenom / exact effect TBD in source |
| First Aid | 3 | Plague Doctor's Laboratory | Healing potions and poultices / exact effect TBD in source |
| Fishing | 1 | Fish Bowl | +8% increased stats |
| Fishing | 2 | Fishing Rack | Catch uncommon fish for 1 hour + fishing-skill lures; inherits +8% stats |
| Fishing | 3 | Fishing Hut | Catch rare fish for 1 hour + fishing-skill lures; inherits +8% stats |

Known exclusivity notes worth surfacing in detailed mode after live verification:

- Mana Well: exclusive with Blessing of Wisdom.
- Sharpening Wheel: exclusive with Strength of Earth Totem.
- Enchanted Lute: source says exclusive with Mark of the Wild.
- Incense Candle: exclusive with Arcane Intellect.
- Lodestone: exclusive with Blessing of Might.
- Camp Chair: exclusive with Moonkin Aura.
- Faction Banner: exclusive with Divine Spirit.
- Fish Bowl: exclusive with Blessing of Kings.

## 5. Addon Architecture

Keep the addon intentionally small.

```text
CampingInfo/
├── CampingInfo.toc
├── Core.lua
├── Data.lua
├── Config.lua          # optional for MVP, useful once slash settings exist
└── Locales/
    └── enUS.lua        # optional after MVP
```

For the initial repository, `Data.lua` and `Core.lua` are sufficient.

### Responsibilities

#### `Data.lua`

Owns static Camping metadata only.

Preferred structure:

```lua
CampingInfoDB = {
    [ITEM_ID] = {
        name = "Camp Chair",
        profession = "Skinning",
        tier = 1,
        buff = "+2% Critical Strike",
        utility = nil,
        exclusiveWith = "Moonkin Aura",
        inheritedFrom = nil,
        verified = true,
    },
}
```

Rules:

- Key by numeric item ID, not localized item name.
- `name` is informational/debug metadata only.
- Use one canonical entry per item.
- Separate `buff` from `utility` so tooltip formatting stays consistent.
- Add `verified = false` for values inferred from the guide but not checked in-game.
- For higher-tier items, set `inheritedFrom` to the Tier 1 item ID when possible.

#### `Core.lua`

Owns tooltip integration and rendering.

Responsibilities:

1. Register item-tooltip callbacks using the API available in the Forever client.
2. Get the item link / item ID safely.
3. Query `CampingInfoDB[itemID]`.
4. Add lines once per rendered tooltip.
5. Trigger tooltip resize/show refresh if required by the client API.
6. Never throw on nil/incomplete item data.

## 6. Tooltip Hook Strategy

Claude Code must inspect the API available in the target WoW Forever client and choose the least invasive supported hook.

Preferred order:

1. **Modern TooltipDataProcessor path** if available:

```lua
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    -- resolve item ID and append camping info
end)
```

2. If Forever uses an older/Classic-style API, use a compatible `OnTooltipSetItem` hook on relevant tooltip frames.

Do not globally replace `GameTooltip:SetHyperlink`, `SetBagItem`, etc. unless absolutely necessary. Prefer post-processing because it covers more tooltip sources with less taint risk.

### Item ID resolution

Use the strongest available source in this order:

- Tooltip callback data's `id` / item ID field.
- `tooltip:GetItem()` item link, then parse `item:(%d+)`.
- A helper based on `C_Item.GetItemInfoInstant(itemLink)` if supported.

Provide a single helper:

```lua
local function GetItemIDFromTooltip(tooltip, tooltipData)
    -- returns number or nil
end
```

## 7. Rendering Specification

Default output should be short enough not to make tooltips noisy.

Recommended style:

```text
[blank line]
Camping Benefit
+2% Critical Strike
Skinning • Tier 1
```

Higher-tier example:

```text
Camping Benefit
+2% Critical Strike
Utility: Grants Track Beasts
Skinning • Tier 2
```

Detailed-mode optional line:

```text
Does not stack with Moonkin Aura
```

### Formatting

- Header: warm/gold WoW-like color.
- Buff: green-ish semantic color using standard escape color codes.
- Utility/meta: neutral gray.
- Do not modify the existing Blizzard lines.
- Do not duplicate a line on repeated callback invocation.

Deduplication can be implemented using a weak-key table keyed by tooltip and current item ID, or by ensuring each tooltip refresh begins cleanly enough that the post-call occurs once. Avoid writing state directly onto secure frames unless known safe.

## 8. Data Verification Workflow

Because this system is new, item IDs and some exact values must be treated as mutable research data.

Implement `/cbt debug` or a temporary debug helper during development:

```text
/cbt id
```

Expected behavior:

- If an item tooltip is currently visible, print the item name + item ID.
- Or allow `/cbt id <itemLink>` if slash parsing is simple.

Verification checklist for every item:

1. Hover the item in-game.
2. Capture its numeric item ID.
3. Confirm exact Camping benefit text.
4. Confirm profession and tier.
5. Confirm whether higher tiers inherit Tier 1 benefits.
6. Confirm exclusivity wording.
7. Set `verified = true` only after live verification.

Do not block MVP on every exact coefficient if the human-readable benefit is clear.

## 9. Suggested Slash Commands

Keep optional commands small:

```text
/cbt help
/cbt on
/cbt off
/cbt detailed on
/cbt detailed off
/cbt id
```

SavedVariables can wait until settings are implemented.

Suggested saved variable name:

```text
CampingInfoSettings
```

Defaults:

```lua
{
    enabled = true,
    detailed = false,
}
```

## 10. Compatibility / TOC

Do not guess the `## Interface:` number permanently.

During implementation:

- Read the current Forever client interface version from a known working addon or client metadata.
- Set the TOC accordingly.
- If this is a PTR/beta environment and interface numbers change frequently, document it in README.

Suggested TOC fields:

```toc
## Title: CampingInfo
## Notes: Shows normalized Camping benefits on Camping item tooltips.
## Author: <author>
## Version: 0.1.0
## Interface: <VERIFY_CURRENT_FOREVER_INTERFACE>

Data.lua
Core.lua
```

## 11. Implementation Milestones

### Milestone 1 — Minimal working addon

Acceptance criteria:

- Addon loads with zero Lua errors.
- Hovering a seeded Camping item appends one `Camping Benefit` section.
- Hovering a normal item changes nothing.
- Tooltip callback can fire repeatedly without duplicate lines.

Tasks:

- Create `.toc`.
- Create `Data.lua` with at least 3 test items after identifying their item IDs in-game.
- Create tooltip post-hook in `Core.lua`.
- Add item-ID resolver.
- Add renderer.

### Milestone 2 — Full Camping database

Acceptance criteria:

- Every currently documented camp feature item is represented.
- Higher-tier inherited benefits are shown clearly.
- Unknown/TBD effects use conservative wording rather than invented values.

Tasks:

- Fill item IDs.
- Fill professions and tiers.
- Add `buff`, `utility`, `exclusiveWith`, `inheritedFrom`, `verified`.
- Cross-check with in-game tooltips.

### Milestone 3 — UX polish

Acceptance criteria:

- Tooltip is compact by default.
- Detailed mode can surface conflicts and verification/debug metadata.
- Settings persist across reloads if configuration is added.

Tasks:

- Slash commands.
- SavedVariables.
- Localized labels via a strings table.

### Milestone 4 — Packaging

Acceptance criteria:

- Repository can be cloned directly into the AddOns directory.
- README has install/test instructions.
- Release zip has exactly one top-level addon folder named `CampingInfo`.

Tasks:

- Add release script or GitHub Action later if desired.
- Add changelog.
- Tag `v0.1.0` once live tested.

## 12. Testing Matrix

Test at minimum:

- Bag item tooltip.
- Bank item tooltip.
- Merchant tooltip.
- Profession/crafting result tooltip.
- Chat-linked item tooltip.
- Item with cached info.
- Item whose info is not cached at first hover.
- Re-hover same item 10+ times: no duplicate custom lines.
- Hover Camping item A then B then normal item: no stale custom text.
- `/reload` preserves settings once SavedVariables exist.

Edge cases:

- `tooltip:GetItem()` returns nil briefly.
- item link exists but item ID not in database.
- database entry has only `utility`, no `buff`.
- database entry is `verified = false`.
- tooltips are scanned by another addon.

## 13. Coding Conventions

- Lua only; no build step.
- `local ADDON_NAME, ns = ...` namespace pattern preferred.
- Avoid globals except the SavedVariables name required by WoW.
- If `Data.lua` must expose data, put it on `ns`, e.g. `ns.CampingItems`.
- Keep functions short and named by behavior.
- No polling / `OnUpdate` loops.
- No combat-sensitive actions; tooltip display only.
- Avoid taint-prone overrides.
- Add comments only where API compatibility or non-obvious behavior requires them.

Preferred namespace version:

```lua
-- Data.lua
local ADDON_NAME, ns = ...
ns.CampingItems = {
    -- [itemID] = {...}
}
```

## 14. Recommended First-Pass Code Shape

`Core.lua` should roughly contain:

```lua
local ADDON_NAME, ns = ...

local function AddCampingLines(tooltip, itemID)
    local entry = ns.CampingItems[itemID]
    if not entry then return end

    tooltip:AddLine(" ")
    tooltip:AddLine("Camping Benefit", 1.0, 0.82, 0.0)

    if entry.buff then
        tooltip:AddLine(entry.buff, 0.3, 1.0, 0.3, true)
    end

    if entry.utility then
        tooltip:AddLine("Utility: " .. entry.utility, 0.8, 0.8, 0.8, true)
    end

    tooltip:AddLine(string.format("%s • Tier %d", entry.profession, entry.tier), 0.6, 0.6, 0.6)
end

-- Register the best supported item-tooltip post-hook here.
```

This is illustrative, not final. Claude Code should adapt it to the actual Forever API and add deduplication.

## 15. README Requirements

README should contain:

- One-sentence explanation.
- Screenshot/GIF placeholder.
- Install instructions:
  - clone/copy `CampingInfo` into the client `Interface/AddOns/` directory.
  - restart/reload WoW.
- Example tooltip output.
- Supported Camping features.
- `/cbt` commands if implemented.
- Compatibility note for WoW: Forever.
- Data accuracy note saying exact values are verified against live client where possible.
- Credits/source link to the Wowhead Camping guide.

## 16. Git Workflow

Repository name:

```text
CampingInfo
```

Suggested branches:

- `main` — working/releasable.
- short-lived feature branches only if useful.

Suggested initial commits:

1. `chore: bootstrap addon repository`
2. `feat: add camping item tooltip annotations`
3. `data: add verified camping feature items`
4. `docs: add installation and testing guide`

Use conventional-ish commits, but do not over-engineer the workflow for a small addon.

## 17. Definition of Done for v0.1.0

v0.1.0 is done when:

- The addon loads on the current WoW: Forever client with no errors.
- Known Camping items show a clear benefit on mouseover.
- Normal items are unaffected.
- No duplicate custom lines appear.
- The complete known Camping matrix is present in the local data table.
- All item IDs used by the addon have been verified in-game or clearly marked unverified.
- README installation steps work from a fresh clone.
- Source contains no web scraping, external dependency, or background polling.

## 18. Instructions to Claude Code

Work through the milestones in order. Do not invent missing WoW item IDs or spell values.

When an identifier/value cannot be confidently derived from the checked-out project or the live client/API data available to you:

1. Leave a clearly named placeholder/TODO.
2. Keep the architecture functional with verified entries.
3. Add a debug path that makes collecting the missing value easy in-game.
4. Document exactly what the maintainer must capture.

Prioritize a reliable tooltip hook and clean data model over extra settings/UI.
