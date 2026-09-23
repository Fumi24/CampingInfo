# CampingInfo

A small World of Warcraft: Forever addon that adds a clear **Camping Benefit** summary when you mouse over Camping feature items.

## Status

Milestone 2 complete: all 37 known Camping items have a confirmed item ID, and `## Interface: 16001` is set. Camping features are placed as physical objects at a campsite rather than just hovered as bag items, so item-ID matching alone isn't enough — see [How placed objects are matched](#how-placed-objects-are-matched) below for the current approach and its status. See [`PLAN.md`](PLAN.md) for the full build specification.

## Install

1. Copy (or clone) the `CampingInfo/` folder into your WoW: Forever `Interface/AddOns/` directory, so the path reads `Interface/AddOns/CampingInfo/CampingInfo.toc`.
2. Restart WoW or `/reload`.
3. Enable **CampingInfo** in the AddOns list if it isn't already.

## Intended tooltip

```text
Camping Benefit
+2% Critical Strike
Skinning • Tier 1
```

Higher tiers can show both inherited buffs and their additional utility.

## Supported Camping features

All 37 Camping feature items documented in the [Wowhead Forever Camping guide](https://www.wowhead.com/forever/guide/camping-overview-unlock-rewards) are present in `CampingInfo/Data.lua` (Alchemy, Blacksmithing, Enchanting, Engineering, Herbalism, Leatherworking, Mining, Skinning, Tailoring, Cooking, First Aid, Fishing — tiers 1 through 4), each keyed by its real item ID in `ns.CampingItems`. `ns.CampingItemsPending` is currently empty.

## `/ci` commands

```text
/ci id              - print the item ID of the currently shown tooltip
/ci debug           - print every line of the last tooltip shown, for
                       diagnosing a placed object that isn't matching
/ci scan            - scan bags/bank/open vendor for known Camping items
                       and print a paste-ready Data.lua block for each match
/ci on | off        - toggle the Camping Benefit tooltip section
/ci detailed on|off - toggle exclusivity/conflict notes (e.g. "Does not stack with Moonkin Aura")
```

## How placed objects are matched

Camping items aren't just hovered in bags — after being used, they're placed as a physical object at the campsite, and hovering that placed object doesn't fire the item-tooltip event `Core.lua` originally relied on (no item link, so no item ID). To handle this:

- The item-ID path (bags, bank, vendor, chat links) is unchanged and reliable.
- For anything else, `Core.lua` hooks `OnTooltipSetUnit` (placed objects are commonly implemented as units on custom servers) and a catch-all `OnShow` on `GameTooltip`, then reads whatever text line 1 of the tooltip actually rendered and matches it against known Camping item names (substring match, so an owner tag or extra text around the name is fine).

This is a best-effort fallback written without being able to test in-game what tooltip event a placed Camping object actually fires. If a placed item still doesn't show the Camping Benefit section, hover it once and run `/ci debug` — it prints the tooltip frame name, whether it resolved as a unit/item, and every rendered line, using a snapshot from the last tooltip shown (so it still works even after the tooltip's gone by the time you finish typing).

## Data accuracy

`CampingInfo/Data.lua` intentionally does **not** invent WoW: Forever item IDs.

All 37 item IDs came from each item's own Wowhead Forever page (`wowhead.com/forever/item=<id>/<slug>`), linked from the Camping overview guide. `verified = true` on an entry means both the ID and the benefit text are considered solid; `verified = false` (currently `Enchanted Lute`, `Toxin Study`, `Plague Doctor's Laboratory`) means the ID is sourced but the exact live tooltip wording still needs an in-game check — see each entry's `notes`.

If a future guide update adds a new Camping feature, add it to `ns.CampingItemsPending` in `Data.lua` (keyed by a slug, not an item ID) until its real item ID is known. To resolve one:

- **Wowhead**: find the item's page and hand over the numeric ID directly.
- **`/ci scan`**: with the item in your bags, an open bank, or an open vendor window, run `/ci scan` to bulk-resolve every match at once and get a paste-ready `Data.lua` block in a copyable window.
- **`/ci id`**: hover the item's tooltip in-game and run `/ci id` to print just that item's ID.

Whichever source is used:

1. Move the item's block from `ns.CampingItemsPending` to `ns.CampingItems` in `Data.lua`, keyed by its numeric item ID.
2. Confirm the buff/utility text and profession/tier against the live tooltip where possible.
3. Resolve any `inheritedFrom` slug to the tier-1 item's own item ID once that item is also verified.
4. Set `verified = true`.

## Project layout

```text
CampingInfo/
  CampingInfo.toc
  Data.lua
  Core.lua
PLAN.md
README.md
```

## Compatibility

Built against the WoW: Forever client. Not tested on retail or other private servers.

Primary research reference / credits: https://www.wowhead.com/forever/guide/camping-overview-unlock-rewards
