# CampingInfo

A small World of Warcraft: Forever addon that adds a clear **Camping Benefit** summary when you mouse over Camping feature items.

## Status

Repository bootstrap / implementation plan. See [`PLAN.md`](PLAN.md) for the Claude Code build specification.

## Intended tooltip

```text
Camping Benefit
+2% Critical Strike
Skinning • Tier 1
```

Higher tiers can show both inherited buffs and their additional utility.

## Project layout

```text
CampingInfo/
  CampingInfo.toc
  Data.lua
  Core.lua
PLAN.md
README.md
```

## Development

The current skeleton intentionally does **not** invent WoW: Forever item IDs or an Interface version. Verify those against the live client before release.

Primary research reference: https://www.wowhead.com/forever/guide/camping-overview-unlock-rewards
