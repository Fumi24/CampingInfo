# CampingInfo

A small World of Warcraft: Forever addon that adds a clear **Camping Benefit** summary when you mouse over Camping feature items.

## Install

1. Copy (or clone) this repository into your WoW: Forever `Interface/AddOns/` directory as `CampingInfo`, so the path reads `Interface/AddOns/CampingInfo/CampingInfo.toc`.
2. Restart WoW or `/reload`.
3. Enable **CampingInfo** in the AddOns list if it isn't already.

## Intended tooltip

```text
Camping Benefit
+2% Critical Strike
Skinning • Tier 1
```

Higher tiers can show both inherited buffs and their additional utility.

## `/ci` commands

```text
/ci on | off        - toggle the Camping Benefit tooltip section
/ci detailed on|off - toggle exclusivity/conflict notes (e.g. "Does not stack with Moonkin Aura")
```

## Project layout

```text
CampingInfo.toc
Data.lua
Core.lua
README.md
```

## Compatibility

Built against the WoW: Forever client. Not tested on retail or other private servers.

Primary research reference / credits: https://www.wowhead.com/forever/guide/camping-overview-unlock-rewards 
