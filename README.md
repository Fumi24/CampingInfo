# CampingInfo

A small World of Warcraft: Forever addon that adds a clear **Camping Benefit** summary when you mouse over Camping feature items.

## Status

Milestone 1 skeleton implemented. The tooltip hook, data model, and debug workflow are functional, but **no item IDs or the client Interface version have been verified in-game yet** — see [Data accuracy](#data-accuracy) below. See [`PLAN.md`](PLAN.md) for the full build specification.

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

All Camping feature items documented in the [Wowhead Forever Camping guide](https://www.wowhead.com/forever/guide/camping-overview-unlock-rewards) are present in `CampingInfo/Data.lua` (Alchemy, Blacksmithing, Enchanting, Engineering, Herbalism, Leatherworking, Mining, Skinning, Tailoring, Cooking, First Aid, Fishing — tiers 1 through 3/4). Tooltips only appear for entries that have been moved into the verified `ns.CampingItems` table; everything else currently sits in `ns.CampingItemsPending` awaiting a real item ID (see below).

## `/ci` commands

```text
/ci id            - print the item ID of the currently shown tooltip
/ci on | off       - toggle the Camping Benefit tooltip section
/ci detailed on|off - toggle exclusivity/conflict notes (e.g. "Does not stack with Moonkin Aura")
```

## Data accuracy

`CampingInfo/Data.lua` intentionally does **not** invent WoW: Forever item IDs, and `CampingInfo.toc`'s `## Interface:` line is a placeholder (`TODO_VERIFY_CURRENT_FOREVER_INTERFACE`) pending a real Interface number from a known-working addon or client metadata.

To verify an item:

1. Hover it in-game and run `/ci id` to get its numeric item ID.
2. Move its block from `ns.CampingItemsPending` to `ns.CampingItems` in `Data.lua`, keyed by that item ID.
3. Confirm the buff/utility text and profession/tier against the live tooltip.
4. Resolve any `inheritedFrom` slug to the tier-1 item's own item ID once that item is also verified.
5. Set `verified = true`.

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
