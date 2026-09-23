# CampingInfo

A small World of Warcraft: Forever addon that adds a clear **Camping Benefit** summary when you mouse over Camping feature items.

## Status

Milestone 2 in progress. 36 of 37 known Camping items have a confirmed item ID and appear in tooltips; only `Iron Oven` (Cooking Tier 4) and the client's `## Interface:` version are still pending — see [Data accuracy](#data-accuracy) below. See [`PLAN.md`](PLAN.md) for the full build specification.

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

All Camping feature items documented in the [Wowhead Forever Camping guide](https://www.wowhead.com/forever/guide/camping-overview-unlock-rewards) are present in `CampingInfo/Data.lua` (Alchemy, Blacksmithing, Enchanting, Engineering, Herbalism, Leatherworking, Mining, Skinning, Tailoring, Cooking, First Aid, Fishing — tiers 1 through 3/4). Tooltips appear for the 36 entries in `ns.CampingItems` keyed by their real item ID; `Iron Oven` (Cooking Tier 4) is the one item not yet linked from the guide and sits in `ns.CampingItemsPending` awaiting an ID (see below).

## `/ci` commands

```text
/ci id              - print the item ID of the currently shown tooltip
/ci scan            - scan bags/bank/open vendor for known Camping items
                       and print a paste-ready Data.lua block for each match
/ci on | off        - toggle the Camping Benefit tooltip section
/ci detailed on|off - toggle exclusivity/conflict notes (e.g. "Does not stack with Moonkin Aura")
```

## Data accuracy

`CampingInfo/Data.lua` intentionally does **not** invent WoW: Forever item IDs, and `CampingInfo.toc`'s `## Interface:` line is a placeholder (`TODO_VERIFY_CURRENT_FOREVER_INTERFACE`) pending a real Interface number from a known-working addon or client metadata.

36 of 37 item IDs came from each item's own Wowhead Forever page (`wowhead.com/forever/item=<id>/<slug>`), linked from the Camping overview guide. `verified = true` on an entry means both the ID and the benefit text are considered solid; `verified = false` (currently `Enchanted Lute`, `Toxin Study`, `Plague Doctor's Laboratory`) means the ID is sourced but the exact live tooltip wording still needs an in-game check — see each entry's `notes`.

To fill in a still-pending item's real ID (currently just `Iron Oven`), any of these work:

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
