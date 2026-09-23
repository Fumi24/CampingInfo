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
        notes = "Exact live wording unverified; source text is ambiguous.",
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
    [279972] = { -- Faction Banner
        name = "Faction Banner", profession = "Tailoring", tier = 1,
        buff = "Increased Spirit", exclusiveWith = "Divine Spirit",
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
