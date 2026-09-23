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
    }

No item IDs have been verified in-game yet, so every known Camping feature
from the Wowhead Forever Camping guide lives in ns.CampingItemsPending below,
keyed by a stable slug instead of an item ID. Nothing in CampingItemsPending
is shown in tooltips.

To promote an entry once you've captured its real item ID in-game:
1. Hover the item and run `/ci id` (see Core.lua) to print its item ID.
2. Copy the matching block out of CampingItemsPending into CampingItems,
   keyed by that numeric item ID.
3. Resolve `inheritedFrom` (currently a slug) to the tier-1 item's own
   numeric item ID, once that tier-1 item has also been promoted.
4. Set `verified = true`.
5. Delete the entry from CampingItemsPending.
--]]

ns.CampingItems = {
    -- [itemID] = { ... },
}

ns.CampingItemsPending = {
    -- Alchemy
    mana_well = {
        name = "Mana Well", profession = "Alchemy", tier = 1,
        buff = "Mana regeneration", exclusiveWith = "Blessing of Wisdom",
    },
    fermenter = {
        name = "Fermenter", profession = "Alchemy", tier = 2,
        utility = "Create certain reagents", inheritedFrom = "mana_well",
    },
    alchemy_laboratory = {
        name = "Alchemy Laboratory", profession = "Alchemy", tier = 3,
        utility = "Enables recipes requiring an Alchemy Lab", inheritedFrom = "mana_well",
    },

    -- Blacksmithing
    sharpening_wheel = {
        name = "Sharpening Wheel", profession = "Blacksmithing", tier = 1,
        buff = "Increased Strength", exclusiveWith = "Strength of Earth Totem",
    },
    anvil = {
        name = "Anvil", profession = "Blacksmithing", tier = 2,
        utility = "Usable anvil", inheritedFrom = "sharpening_wheel",
    },
    master_forge = {
        name = "Master Forge", profession = "Blacksmithing", tier = 3,
        utility = "Enables recipes requiring a Forge", inheritedFrom = "sharpening_wheel",
    },

    -- Enchanting
    enchanted_lute = {
        name = "Enchanted Lute", profession = "Enchanting", tier = 1,
        buff = "Increased Armor, All Stats, and Resistances", exclusiveWith = "Mark of the Wild",
        notes = "Exact live wording unverified; source text is ambiguous.",
    },
    arcane_salvager = {
        name = "Arcane Salvager", profession = "Enchanting", tier = 2,
        utility = "More efficient disenchanting", inheritedFrom = "enchanted_lute",
    },
    arcane_forge = {
        name = "Arcane Forge", profession = "Enchanting", tier = 3,
        utility = "Enables recipes requiring an Arcane Forge", inheritedFrom = "enchanted_lute",
    },

    -- Engineering (utility only, no camp buff)
    reagent_bot = {
        name = "Reagent Bot", profession = "Engineering", tier = 1,
        utility = "Purchase reagents",
    },
    repair_bot = {
        name = "Repair Bot", profession = "Engineering", tier = 2,
        utility = "Purchase reagents and repair gear",
    },
    anarchists_workbench = {
        name = "Anarchist's Workbench", profession = "Engineering", tier = 3,
        utility = "Enables recipes requiring the workbench",
    },

    -- Herbalism
    incense_candle = {
        name = "Incense Candle", profession = "Herbalism", tier = 1,
        buff = "Increased Intellect", exclusiveWith = "Arcane Intellect",
    },
    greenhouse = {
        name = "Greenhouse", profession = "Herbalism", tier = 2,
        utility = "Grow herbs from planted seeds", inheritedFrom = "incense_candle",
    },
    seed_hybridizer = {
        name = "Seed Hybridizer", profession = "Herbalism", tier = 3,
        utility = "Multiply/combine seeds", inheritedFrom = "incense_candle",
    },

    -- Leatherworking
    camp_tent = {
        name = "Camp Tent", profession = "Leatherworking", tier = 1,
        buff = "Rested XP up to 5% of a level",
        notes = "Tooltip text confirmed via screenshot; item ID still unverified.",
    },
    tanning_rack = {
        name = "Tanning Rack", profession = "Leatherworking", tier = 2,
        utility = "Create certain reagents", inheritedFrom = "camp_tent",
    },
    sewing_machine = {
        name = "Sewing Machine", profession = "Leatherworking", tier = 3,
        utility = "Enables recipes requiring it", inheritedFrom = "camp_tent",
    },

    -- Mining
    lodestone = {
        name = "Lodestone", profession = "Mining", tier = 1,
        buff = "Increased melee Attack Power", exclusiveWith = "Blessing of Might",
    },
    rock_garden = {
        name = "Rock Garden", profession = "Mining", tier = 2,
        utility = "Spawns a common mining node over time", inheritedFrom = "lodestone",
    },
    molten_foundry = {
        name = "Molten Foundry", profession = "Mining", tier = 3,
        utility = "Enables recipes requiring it", inheritedFrom = "lodestone",
    },

    -- Skinning
    camp_chair = {
        name = "Camp Chair", profession = "Skinning", tier = 1,
        buff = "+2% Critical Strike", exclusiveWith = "Moonkin Aura",
    },
    field_guide = {
        name = "Field Guide", profession = "Skinning", tier = 2,
        utility = "Grants Track Beasts", inheritedFrom = "camp_chair",
    },
    trappers_workbench = {
        name = "Trapper's Workbench", profession = "Skinning", tier = 3,
        utility = "Contains 1 trap", inheritedFrom = "camp_chair",
    },

    -- Tailoring
    faction_banner = {
        name = "Faction Banner", profession = "Tailoring", tier = 1,
        buff = "Increased Spirit", exclusiveWith = "Divine Spirit",
    },
    spinning_wheel = {
        name = "Spinning Wheel", profession = "Tailoring", tier = 2,
        utility = "Create certain reagents", inheritedFrom = "faction_banner",
    },
    loom = {
        name = "Loom", profession = "Tailoring", tier = 3,
        utility = "Enables recipes requiring it", inheritedFrom = "faction_banner",
    },

    -- Cooking (utility only, no camp buff)
    basic_campfire = {
        name = "Basic Campfire", profession = "Cooking", tier = 1,
        utility = "Cooking + up to 3 additional camp features",
    },
    journeyman_campfire = {
        name = "Journeyman Campfire", profession = "Cooking", tier = 2,
        utility = "Cooking + up to 5 additional camp features",
    },
    cookies_feast = {
        name = "Cookie's Feast", profession = "Cooking", tier = 2,
        buff = "Stamina-boosting food",
    },
    expert_campfire = {
        name = "Expert Campfire", profession = "Cooking", tier = 3,
        utility = "Cooking + up to 10 additional camp features",
    },
    iron_oven = {
        name = "Iron Oven", profession = "Cooking", tier = 4,
        utility = "Required for advanced cooking recipes",
    },

    -- First Aid
    first_aid_kit = {
        name = "First Aid Kit", profession = "First Aid", tier = 1,
        buff = "Stamina buff",
    },
    toxin_study = {
        name = "Toxin Study", profession = "First Aid", tier = 2,
        utility = "Healing potions and antivenom",
        notes = "Exact effect TBD; verify against live client.",
    },
    plague_doctors_laboratory = {
        name = "Plague Doctor's Laboratory", profession = "First Aid", tier = 3,
        utility = "Healing potions and poultices",
        notes = "Exact effect TBD; verify against live client.",
    },

    -- Fishing
    fish_bowl = {
        name = "Fish Bowl", profession = "Fishing", tier = 1,
        buff = "+8% increased stats", exclusiveWith = "Blessing of Kings",
    },
    fishing_rack = {
        name = "Fishing Rack", profession = "Fishing", tier = 2,
        utility = "Catch uncommon fish for 1 hour + fishing-skill lures", inheritedFrom = "fish_bowl",
    },
    fishing_hut = {
        name = "Fishing Hut", profession = "Fishing", tier = 3,
        utility = "Catch rare fish for 1 hour + fishing-skill lures", inheritedFrom = "fish_bowl",
    },
}
