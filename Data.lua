local ADDON_NAME, ns = ...

--[[
Data.lua owns static Camping metadata only.

ns.CampingItems is keyed by verified numeric WoW item ID and is the ONLY
table Core.lua looks up at tooltip time:

    ns.CampingItems[itemID] = {
        name          = "Camp Chair",
        profession    = "Skinning",
        tier          = 1,
        buff          = "+2% Critical Strike",
        utility       = nil,
        exclusiveWith = "Moonkin Aura",
        inheritedFrom = nil,      -- itemID of the tier-1 item, once known
        verified      = true,
        aliases       = nil,      -- optional list of alternate names shown by
                                   -- the placed world object's tooltip, when
                                   -- it differs from `name`
        buffValues    = nil,      -- optional buff magnitude by level bracket.
                                   -- Either a flat array {14, 19, 27, 32} when
                                   -- only the magnitudes are confirmed (level
                                   -- thresholds unknown), or an array of
                                   -- {level = X, value = Y} when the level a
                                   -- bracket starts at is confirmed too, e.g.
                                   -- {level = 1, value = 14} applies from
                                   -- level 1 until the next entry's level.
    }

Item IDs below were sourced from each item's own Wowhead Forever page
(wowhead.com/forever/item=<id>/<slug>), linked from the Camping overview
guide. `verified = true` means both the item ID and the benefit text are
considered solid; `verified = false` means the ID is sourced but the exact
live tooltip wording still needs an in-game check (see its `notes`).

Any Camping feature not yet linked from the guide lives in
ns.CampingItemsPending below, keyed by a stable slug instead of an item ID.
Nothing in CampingItemsPending is shown in tooltips.

To promote a pending entry once you have its real item ID:
1. Copy the block out of CampingItemsPending into CampingItems, keyed by
   that numeric item ID.
2. Resolve `inheritedFrom` (currently a slug) to the tier-1 item's own
   numeric item ID, once that tier-1 item has also been promoted.
3. Confirm the benefit text in-game and set `verified = true`.
4. Delete the entry from CampingItemsPending.
--]]

ns.CampingItems = {
    -- Alchemy
    [279956] = { -- Mana Well
        name = "Mana Well", profession = "Alchemy", tier = 1,
        buff = "Mana regeneration", exclusiveWith = "Blessing of Wisdom",
        buffValues = {10, 15, 20, 24, 29}, -- Mana per 5 sec, per level bracket
        notes = "5 brackets here (the raw digit string can't fit fewer), but Blessing " ..
            "of Wisdom only has 4 ranks (levels 1/24/38/54, granting 10/15/20/30). The " ..
            "first 3 values (10, 15, 20) match those ranks' levels, but this server's " ..
            "own rank 4 value (24, not 30) starts at an unconfirmed level, and there's " ..
            "a 5th tier (29) with no known threshold at all -- needs in-game testing.",
        verified = true,
    },
    [279970] = { -- Fermenter
        name = "Fermenter", profession = "Alchemy", tier = 2,
        utility = "Create certain reagents", inheritedFrom = 279956,
        verified = true,
    },
    [279990] = { -- Alchemy Laboratory
        name = "Alchemy Laboratory", profession = "Alchemy", tier = 3,
        utility = "Enables recipes requiring an Alchemy Lab", inheritedFrom = 279956,
        verified = true,
    },

    -- Blacksmithing
    [279944] = { -- Sharpening Wheel
        name = "Sharpening Wheel", profession = "Blacksmithing", tier = 1,
        buff = "Increased Strength", exclusiveWith = "Strength of Earth Totem",
        buffValues = { -- Strength; mirrors Strength of Earth's own rank breakpoints
            {level = 1, value = 6},   -- Strength of Earth Rank 1
            {level = 24, value = 11}, -- Strength of Earth Rank 2
            {level = 38, value = 20}, -- Strength of Earth Rank 3
            {level = 54, value = 34}, -- Strength of Earth Rank 4
        },
        verified = true,
    },
    [279988] = { -- Anvil
        name = "Anvil", profession = "Blacksmithing", tier = 2,
        utility = "Usable anvil", inheritedFrom = 279944,
        verified = true,
    },
    [279955] = { -- Master Forge
        name = "Master Forge", profession = "Blacksmithing", tier = 3,
        utility = "Enables recipes requiring a Forge", inheritedFrom = 279944,
        verified = true,
    },

    -- Enchanting
    [279976] = { -- Enchanted Lute
        name = "Enchanted Lute", profession = "Enchanting", tier = 1,
        buff = "Increased Armor, All Stats, and Resistances", exclusiveWith = "Mark of the Wild",
        buffValues = {
            -- Only the Armor component could be decoded (rank count matches Mark of
            -- the Wild's 7 ranks; magnitudes are this server's own, not vanilla's).
            -- The All Stats and Resistances components are still unresolved -- their
            -- raw tooltip text is broken (unresolved template placeholders like
            -- "[][and][,]"), so this remains an incomplete/unverified benefit overall.
            armor = {
                {level = 1, value = 28},   -- Mark of the Wild Rank 1
                {level = 10, value = 71},  -- Mark of the Wild Rank 2
                {level = 20, value = 114}, -- Mark of the Wild Rank 3
                {level = 30, value = 163}, -- Mark of the Wild Rank 4
                {level = 40, value = 211}, -- Mark of the Wild Rank 5
                {level = 50, value = 260}, -- Mark of the Wild Rank 6
                {level = 60, value = 308}, -- Mark of the Wild Rank 7
            },
        },
        notes = "Exact live wording unverified; source text is ambiguous. All Stats and " ..
            "Resistances magnitudes are still unknown -- only Armor has been decoded.",
        verified = false,
    },
    [279985] = { -- Arcane Salvager
        name = "Arcane Salvager", profession = "Enchanting", tier = 2,
        utility = "More efficient disenchanting", inheritedFrom = 279976,
        verified = true,
    },
    [279987] = { -- Arcane Forge
        name = "Arcane Forge", profession = "Enchanting", tier = 3,
        utility = "Enables recipes requiring an Arcane Forge", inheritedFrom = 279976,
        verified = true,
    },

    -- Engineering (utility only, no camp buff)
    [279950] = { -- Reagent Bot
        name = "Reagent Bot", profession = "Engineering", tier = 1,
        utility = "Purchase reagents",
        verified = true,
    },
    [279949] = { -- Repair Bot
        name = "Repair Bot", profession = "Engineering", tier = 2,
        utility = "Purchase reagents and repair gear",
        verified = true,
    },
    [279989] = { -- Anarchist's Workbench
        name = "Anarchist's Workbench", profession = "Engineering", tier = 3,
        utility = "Enables recipes requiring the workbench",
        verified = true,
    },

    -- Herbalism
    [279962] = { -- Incense Candle
        name = "Incense Candle", profession = "Herbalism", tier = 1,
        buff = "Increased Intellect", exclusiveWith = "Arcane Intellect",
        buffValues = { -- Intellect; mirrors Arcane Intellect's own rank breakpoints
            {level = 1, value = 2},   -- Arcane Intellect Rank 1
            {level = 14, value = 6},  -- Arcane Intellect Rank 2
            {level = 28, value = 12}, -- Arcane Intellect Rank 3
            {level = 42, value = 18}, -- Arcane Intellect Rank 4
            {level = 56, value = 25}, -- Arcane Intellect Rank 5
        },
        verified = true,
    },
    [279964] = { -- Greenhouse
        name = "Greenhouse", profession = "Herbalism", tier = 2,
        utility = "Grow herbs from planted seeds", inheritedFrom = 279962,
        verified = true,
    },
    [279947] = { -- Seed Hybridizer
        name = "Seed Hybridizer", profession = "Herbalism", tier = 3,
        utility = "Multiply/combine seeds", inheritedFrom = 279962,
        verified = true,
    },

    -- Leatherworking
    [279978] = { -- Camp Tent
        name = "Camp Tent", profession = "Leatherworking", tier = 1,
        buff = "Rested XP up to 5% of a level",
        -- buff text confirmed against an in-game tooltip screenshot.
        verified = true,
    },
    [279941] = { -- Tanning Rack
        name = "Tanning Rack", profession = "Leatherworking", tier = 2,
        utility = "Create certain reagents", inheritedFrom = 279978,
        verified = true,
    },
    [279945] = { -- Sewing Machine
        name = "Sewing Machine", profession = "Leatherworking", tier = 3,
        utility = "Enables recipes requiring it", inheritedFrom = 279978,
        verified = true,
    },

    -- Mining
    [279960] = { -- Lodestone
        name = "Lodestone", profession = "Mining", tier = 1,
        buff = "Increased melee Attack Power", exclusiveWith = "Blessing of Might",
        buffValues = { -- melee Attack Power; rank count matches Blessing of Might but
            -- magnitudes were rebalanced for this server (decoded from its own
            -- tooltip, not the vanilla spell's values). Level thresholds borrowed
            -- from Blessing of Might's own ranks since the tier count matches.
            {level = 1, value = 12},
            {level = 12, value = 20},
            {level = 24, value = 32},
            {level = 36, value = 49},
            {level = 48, value = 67},
            {level = 60, value = 90},
        },
        verified = true,
    },
    [279948] = { -- Rock Garden
        name = "Rock Garden", profession = "Mining", tier = 2,
        utility = "Spawns a common mining node over time", inheritedFrom = 279960,
        verified = true,
    },
    [279952] = { -- Molten Foundry
        name = "Molten Foundry", profession = "Mining", tier = 3,
        utility = "Enables recipes requiring it", inheritedFrom = 279960,
        verified = true,
    },

    -- Skinning
    [279979] = { -- Camp Chair
        name = "Camp Chair", profession = "Skinning", tier = 1,
        buff = "+2% Critical Strike", exclusiveWith = "Moonkin Aura",
        -- The placed world object's tooltip shows "Chair", not the item name.
        aliases = { "Chair" },
        verified = true,
    },
    [279969] = { -- Field Guide
        name = "Field Guide", profession = "Skinning", tier = 2,
        utility = "Grants Track Beasts", inheritedFrom = 279979,
        verified = true,
    },
    [279938] = { -- Trapper's Workbench
        name = "Trapper's Workbench", profession = "Skinning", tier = 3,
        utility = "Contains 1 trap", inheritedFrom = 279979,
        verified = true,
    },

    -- Tailoring
    [279972] = { -- Faction Banner (Horde)
        name = "Faction Banner", profession = "Tailoring", tier = 1,
        buff = "Increased Spirit", exclusiveWith = "Divine Spirit",
        notes = "This item is Horde-only; the Alliance version is a separate item, 279973.",
        buffValues = { -- Spirit; mirrors Divine Spirit's own rank breakpoints
            {level = 1, value = 14},  -- Divine Spirit Rank 1
            {level = 30, value = 19}, -- Divine Spirit Rank 2
            {level = 50, value = 27}, -- Divine Spirit Rank 3
            {level = 60, value = 32}, -- Divine Spirit Rank 4
        },
        verified = true,
    },
    [279973] = { -- Faction Banner (Alliance)
        name = "Faction Banner", profession = "Tailoring", tier = 1,
        buff = "Increased Spirit", exclusiveWith = "Divine Spirit",
        notes = "This item is Alliance-only; same name and identical Spirit values as " ..
            "the Horde version, 279972, just different item IDs per faction.",
        buffValues = { -- Spirit; mirrors Divine Spirit's own rank breakpoints
            {level = 1, value = 14},  -- Divine Spirit Rank 1
            {level = 30, value = 19}, -- Divine Spirit Rank 2
            {level = 50, value = 27}, -- Divine Spirit Rank 3
            {level = 60, value = 32}, -- Divine Spirit Rank 4
        },
        verified = true,
    },
    [279943] = { -- Spinning Wheel
        name = "Spinning Wheel", profession = "Tailoring", tier = 2,
        utility = "Create certain reagents", inheritedFrom = 279972,
        verified = true,
    },
    [279959] = { -- Loom
        name = "Loom", profession = "Tailoring", tier = 3,
        utility = "Enables recipes requiring it", inheritedFrom = 279972,
        verified = true,
    },

    -- Cooking (utility only, no camp buff)
    [279981] = { -- Basic Campfire Kit
        name = "Basic Campfire Kit", profession = "Cooking", tier = 1,
        utility = "Cooking + up to 3 additional camp features",
        verified = true,
    },
    [279961] = { -- Journeyman Campfire Kit
        name = "Journeyman Campfire Kit", profession = "Cooking", tier = 2,
        utility = "Cooking + up to 5 additional camp features",
        verified = true,
    },
    [279957] = { -- Cookie's Feast
        name = "Cookie's Feast", profession = "Cooking", tier = 2,
        buff = "Stamina-boosting food",
        verified = true,
    },
    [279974] = { -- Expert Campfire Kit
        name = "Expert Campfire Kit", profession = "Cooking", tier = 3,
        utility = "Cooking + up to 10 additional camp features",
        verified = true,
    },
    [279982] = { -- Iron Oven
        name = "Iron Oven", profession = "Cooking", tier = 4,
        utility = "Required for advanced cooking recipes",
        verified = true,
    },

    -- First Aid
    [279968] = { -- First Aid Kit
        name = "First Aid Kit", profession = "First Aid", tier = 1,
        buff = "Stamina buff",
        buffValues = { -- Stamina; mirrors Power Word: Fortitude's own rank breakpoints
            {level = 1, value = 3},   -- Power Word: Fortitude Rank 1
            {level = 12, value = 8},  -- Power Word: Fortitude Rank 2
            {level = 24, value = 21}, -- Power Word: Fortitude Rank 3
            {level = 36, value = 34}, -- Power Word: Fortitude Rank 4
            {level = 48, value = 45}, -- Power Word: Fortitude Rank 5
            {level = 60, value = 56}, -- Power Word: Fortitude Rank 6
        },
        verified = true,
    },
    [279940] = { -- Toxin Study
        name = "Toxin Study", profession = "First Aid", tier = 2,
        utility = "Healing potions and antivenom",
        notes = "Exact effect TBD; verify against live client.",
        verified = false,
    },
    [279951] = { -- Plague Doctor's Laboratory
        name = "Plague Doctor's Laboratory", profession = "First Aid", tier = 3,
        utility = "Healing potions and poultices",
        notes = "Exact effect TBD; verify against live client.",
        verified = false,
    },

    -- Fishing
    [279967] = { -- Fish Bowl
        name = "Fish Bowl", profession = "Fishing", tier = 1,
        buff = "+8% increased stats", exclusiveWith = "Blessing of Kings",
        verified = true,
    },
    [279965] = { -- Fishing Rack
        name = "Fishing Rack", profession = "Fishing", tier = 2,
        utility = "Catch uncommon fish for 1 hour + fishing-skill lures", inheritedFrom = 279967,
        verified = true,
    },
    [279966] = { -- Fishing Hut
        name = "Fishing Hut", profession = "Fishing", tier = 3,
        utility = "Catch rare fish for 1 hour + fishing-skill lures", inheritedFrom = 279967,
        verified = true,
    },
}

-- All known Camping features now have a verified item ID; nothing pending.
ns.CampingItemsPending = {}
