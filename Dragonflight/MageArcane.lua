-- MageArcane.lua
-- September 2022

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID

local GetItemCooldown = GetItemCooldown
local strformat = string.format

local spec = Hekili:NewSpecialization( 62 )

spec:RegisterResource( Enum.PowerType.ArcaneCharges, {
    arcane_orb = {
        aura = "arcane_orb",

        last = function ()
            local app = state.buff.arcane_orb.applied
            local t = state.query_time

            return app + floor( ( t - app ) * 2 ) * 0.5
        end,

        interval = 0.5,
        value = function () return state.active_enemies end,
    },
} )

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Mage
    accumulative_shielding     = { 62093, 382800, 2 }, -- Your barrier's cooldown recharges 20% faster while the shield persists.
    alter_time                 = { 62115, 342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after 10 seconds. Effect negated by long distance or death.
    arcane_warding             = { 62114, 383092, 2 }, -- Reduces magic damage taken by 3%.
    blast_wave                 = { 62103, 157981, 1 }, -- Causes an explosion around yourself, dealing 916 Fire damage to all enemies within 8 yards, knocking them back, and reducing movement speed by 70% for 6 sec.
    cryofreeze                 = { 62107, 382292, 2 }, -- While inside Ice Block, you heal for 40% of your maximum health over the duration.
    displacement               = { 62092, 389713, 1 }, -- Teleports you back to where you last Blinked. Only usable within 8 sec of Blinking.
    diverted_energy            = { 62101, 382270, 2 }, -- Your Barriers heal you for 10% of the damage absorbed.
    dragons_breath             = { 62091, 31661 , 1 }, -- Enemies in a cone in front of you take 1,130 Fire damage and are disoriented for 4 sec. Damage will cancel the effect.
    energized_barriers         = { 62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a 10% chance to be granted Clearcasting. Casting your barrier removes all snare effects.
    flow_of_time               = { 62096, 382268, 2 }, -- The cooldown of Blink is reduced by 2.0 sec.
    freezing_cold              = { 62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for 5 sec instead of snared. When your roots expire or are dispelled, your target is snared by 90%, decaying over 3 sec.
    frigid_winds               = { 62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional 10%.
    greater_invisibility       = { 62095, 110959, 1 }, -- Makes you invisible and untargetable for 20 sec, removing all threat. Any action taken cancels this effect. You take 60% reduced damage while invisible and for 3 sec after reappearing. Increases your movement speed by 16% for 6 sec.
    ice_block                  = { 62122, 45438 , 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_floes                  = { 62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than 10 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                   = { 62126, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing 2,328 Frost damage to the target and reduced damage to all other enemies within 8 yards, and freezing them in place for 2 sec.
    ice_ward                   = { 62086, 205036, 1 }, -- Frost Nova now has 2 charges.
    improved_frost_nova        = { 62108, 343183, 1 }, -- Frost Nova duration is increased by 2 sec.
    incantation_of_swiftness   = { 62112, 382293, 2 }, -- Invisibility increases your movement speed by 16% for 6 sec.
    incanters_flow             = { 62113, 1463  , 1 }, -- Magical energy flows through you while in combat, building up to 20% increased damage and then diminishing down to 4% increased damage, cycling every 10 sec.
    invisibility               = { 62118, 66    , 1 }, -- Turns you invisible over 3 sec, reducing threat each second. While invisible, you are untargetable by enemies. Lasts 20 sec. Taking any action cancels the effect. Increases your movement speed by 40% for 6 sec.
    mass_polymorph             = { 62106, 383121, 1 }, -- Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 1 min. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    mass_slow                  = { 62109, 391102, 1 }, -- Slow applies to all enemies within 5 yds of your target.
    master_of_time             = { 62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by 10 sec. Alter Time resets the cooldown of Blink when you return to your original location.
    meteor                     = { 62090, 153561, 1 }, -- Calls down a meteor which lands at the target location after 3 sec, dealing 5,044 Fire damage, split evenly between all targets within 8 yards, and burns the ground, dealing 1,280 Fire damage over 8.5 sec to all enemies in the area.
    mirror_image               = { 62124, 55342 , 1 }, -- Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    overflowing_energy         = { 62120, 390218, 1 }, -- Your spell critical strike damage is increased by 10%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by 2%, up to 10% for 8 sec. When your spells critically strike Overflowing Energy is reset.
    quick_witted               = { 62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by 4 sec.
    reabsorption               = { 62125, 382820, 1 }, -- You are healed for 5% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reduplication              = { 62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by 10 sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse               = { 62116, 475   , 1 }, -- Removes all Curses from a friendly target.
    rigid_ice                  = { 62110, 382481, 1 }, -- Frost Nova can withstand 80% more damage before breaking.
    ring_of_frost              = { 62088, 113724, 1 }, -- Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 65% for 4 sec.
    rune_of_power              = { 62113, 116011, 1 }, -- Places a Rune of Power on the ground for 12 sec which increases your spell damage by 40% while you stand within 8 yds. Casting Arcane Power will also create a Rune of Power at your location.
    shifting_power             = { 62085, 382440, 1 }, -- Draw power from the Night Fae, dealing 4,113 Nature damage over 3.5 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.5 sec.
    shimmer                    = { 62105, 212653, 1 }, -- Teleports you 20 yards forward, unless something is in the way. Unaffected by the global cooldown and castable while casting. Gain a shield that absorbs 3% of your maximum health for 15 sec after you Shimmer.
    slow                       = { 62097, 31589 , 1 }, -- Reduces the target's movement speed by 60% for 15 sec.
    spellsteal                 = { 62084, 30449 , 1 }, -- Steals a beneficial magic effect from the target. This effect lasts a maximum of 2 min.
    tempest_barrier            = { 62111, 382289, 2 }, -- Gain a shield that absorbs 3% of your maximum health for 15 sec after you Blink.
    temporal_velocity          = { 62099, 382826, 2 }, -- Increases your movement speed by 5% for 2 sec after casting Blink and 20% for 5 sec after returning from Alter Time.
    temporal_warp              = { 62094, 386539, 1 }, -- While you have Temporal Displacement or other similar effects, you may use Time Warp to grant yourself 30% Haste for 40 sec.
    time_anomaly               = { 62094, 383243, 1 }, -- At any moment, you have a chance to gain Arcane Surge for 6 sec, Clearcasting, or Time Warp for 6 sec.
    time_manipulation          = { 62129, 387807, 2 }, -- Casting Clearcasting Arcane Missiles reduces the cooldown of your loss of control abilities by 1 sec.
    tome_of_antonidas          = { 62098, 382490, 1 }, -- Increases Haste by 2%.
    tome_of_rhonin             = { 62127, 382493, 1 }, -- Increases Critical Strike chance by 2%.
    volatile_detonation        = { 62089, 389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by 5 seconds.
    winters_protection         = { 62123, 382424, 2 }, -- The cooldown of Ice Block is reduced by 20 sec.

    -- Arcane
    amplification              = { 62225, 236628, 1 }, -- When Clearcast, Arcane Missiles fires 3 additional missiles.
    arcane_barrage             = { 62237, 44425 , 1 }, -- Launches bolts of arcane energy at the enemy target, causing 1,525 Arcane damage. For each Arcane Charge, deals 36% additional damage. Consumes all Arcane Charges.
    arcane_bombardment         = { 62234, 384581, 1 }, -- Arcane Barrage deals an additional 100% damage against targets below 35% health.
    arcane_echo                = { 62131, 342231, 1 }, -- Direct damage you deal to enemies affected by Touch of the Magi, causes an explosion that deals 194 Arcane damage to all nearby enemies. Deals reduced damage beyond 8 targets.
    arcane_familiar            = { 62145, 205022, 1 }, -- Summon a Familiar that attacks your enemies and increases your maximum mana by 10% for 1 |4hour:hrs;.
    arcane_harmony             = { 62135, 384452, 1 }, -- Each time Arcane Missiles hits an enemy, the damage of your next Arcane Barrage is increased by 5%. This effect stacks up to 20 times.
    arcane_missiles            = { 62238, 5143  , 1 }, -- Launches five waves of Arcane Missiles at the enemy over 2.2 sec, causing a total of 4,460 Arcane damage.
    arcane_orb                 = { 62239, 153626, 1 }, -- Launches an Arcane Orb forward from your position, traveling up to 40 yards, dealing 2,828 Arcane damage to enemies it passes through. Grants 1 Arcane Charge when cast and every time it deals damage.
    arcane_power               = { 62130, 321739, 1 }, -- Arcane Surge lasts an additional 3 sec and grants 25% increased Spell Damage.
    arcane_surge               = { 62230, 365350, 1 }, -- Expend all of your current mana to annihilate your enemy target and nearby enemies for up to 7,279 Arcane damage based on Mana spent. Deals reduced damage beyond 5 targets. For the next 15 sec, your Mana Regeneration is increased by 425% and Spell Damage is increased by 35%.
    arcane_tempo               = { 62144, 383980, 1 }, -- Consuming Arcane Charges increases your Haste by 2% for 12 seconds, stacks up to 5 times.
    arcing_cleave              = { 62140, 231564, 1 }, -- For each Arcane Charge, Arcane Barrage hits 1 additional nearby target for 40% damage.
    cascading_power            = { 62133, 384276, 1 }, -- Consuming a Mana Gem grants up to 2 Clearcasting stacks.
    charged_orb                = { 62241, 384651, 1 }, -- Arcane Orb gains 1 additional charge.
    chrono_shift               = { 62141, 235711, 1 }, -- Arcane Barrage slows enemies by 50% and increases your movement speed by 50% for 5 sec.
    clearcasting               = { 62229, 79684 , 1 }, -- For each 250 mana you spend, you have a 1% chance to gain Clearcasting, making your next Arcane Missiles or Arcane Explosion free and channel 20% faster.
    concentration              = { 62134, 384374, 1 }, -- Arcane Blast has a chance to grant Concentration, which causes your next Clearcasting to not be consumed.
    conjure_mana_gem           = { 62132, 759   , 1 }, -- Conjures a Mana Gem that can be used to instantly restore 25% mana and grant 5% spell damage for 12 sec. Holds up to 3 charges. Conjured Items Conjured items disappear if logged out for more than 15 minutes.
    crackling_energy           = { 62228, 321752, 2 }, -- Increases Arcane Explosion and Arcane Blast damage by 10%.
    enlightened                = { 62143, 321387, 1 }, -- Arcane damage dealt while above 70% mana is increased by 6%, Mana Regen while below 70% is increased by 20%.
    evocation                  = { 62147, 12051 , 1 }, -- Increases your mana regeneration by 750% for 5.3 sec.
    foresight                  = { 62142, 384861, 1 }, -- Standing still for 10 sec grants you Foresight, allowing you to cast while moving for 4 sec. This duration begins when you start moving.
    harmonic_echo              = { 62236, 384683, 1 }, -- Damage dealt to enemies affected by Radiant Spark's vulnerability echo to your current enemy target and 4 nearby enemies for 20% of the damage dealt.
    illuminated_thoughts       = { 62223, 384060, 2 }, -- Clearcasting has a 5% increased chance to proc.
    impetus                    = { 62222, 383676, 1 }, -- Arcane Blast has a 10% chance to generate an additional Arcane Charge. If you were to gain an Arcane Charge while at maximum charges instead gain 10% Arcane damage for 10 sec.
    improved_arcane_missiles   = { 62240, 383661, 2 }, -- Increases Arcane Missiles damage by 10%.
    improved_clearcasting      = { 62224, 321420, 1 }, -- Clearcasting can stack up to 2 additional times.
    improved_prismatic_barrier = { 62232, 321745, 1 }, -- Prismatic Barrier further reduces magical damage taken by an additional 5% and duration of harmful Magic effects by 10%.
    mana_adept                 = { 62231, 321526, 1 }, -- Arcane Barrage grants you 2% of your maximum mana per Arcane Charge spent.
    nether_precision           = { 62226, 383782, 1 }, -- Consuming Clearcasting increases the damage of your next 2 Arcane Blasts by 20%.
    nether_tempest             = { 62138, 114923, 1 }, -- Places a Nether Tempest on the target which deals 433 Arcane damage over 12 sec to the target and nearby enemies within 10 yards. Limit 1 target. Deals reduced damage to secondary targets. Damage increased by 72% per Arcane Charge.
    orb_barrage                = { 62136, 384858, 1 }, -- Consuming Clearcasting reduces the cooldown of Arcane Orb by 2 sec. Additionally, casting Arcane Missiles 15 times fires an Arcane Orb toward your target. Clearcast Arcane Missiles count as 2.
    presence_of_mind           = { 62146, 205025, 1 }, -- Causes your next 2 Arcane Blasts to be instant cast.
    prismatic_barrier          = { 62121, 235450, 1 }, -- Shields you with an arcane force, absorbing 8,622 damage and reducing magic damage taken by 15% for 1 min. The duration of harmful Magic effects against you is reduced by 25%.
    prodigious_savant          = { 62137, 384612, 2 }, -- Arcane Charges further increase Mastery effectiveness of Arcane Blast and Arcane Barrage by 20%.
    radiant_spark              = { 62235, 376103, 1 }, -- Conjure a radiant spark that causes 2,147 Arcane damage instantly, and an additional 1,093 damage over 10 sec. The target takes 10% increased damage from your direct damage spells, stacking each time they are struck. This effect ends after 4 spells.
    resonance                  = { 62139, 205028, 1 }, -- Arcane Barrage deals 15% increased damage per target it hits.
    reverberate                = { 62138, 281482, 1 }, -- If Arcane Explosion hits at least 3 targets, it has a 50% chance to generate an extra Arcane Charge.
    rule_of_threes             = { 62145, 264354, 1 }, -- When you gain your third Arcane Charge, the cost of your next Arcane Blast or Arcane Missiles is reduced by 100%.
    siphon_storm               = { 62148, 384187, 1 }, -- Evocation grants 1 Arcane Charge, and while channeling Evocation, your Intellect is increased by 2% every 0.9 sec. Lasts 30 sec.
    slipstream                 = { 62227, 236457, 1 }, -- Clearcasting allows Arcane Missiles to be channeled while moving. Evocation can be channeled while moving.
    supernova                  = { 62221, 157980, 1 }, -- Pulses arcane energy around the target enemy or ally, dealing 706 Arcane damage to all enemies within 8 yards, and knocking them upward. A primary enemy target will take 100% increased damage.
    touch_of_the_magi          = { 62233, 321507, 1 }, -- Applies Touch of the Magi to your current target, accumulating 20% of the damage you deal to the target for 10 sec, and then exploding for that amount of Arcane damage to the target and reduced damage to all nearby enemies. Generates 4 Arcane Charges.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    arcane_empowerment = 61  , -- (276741) Clearcasting can now stack 2 additional times, and increases the damage of Arcane Missiles by 5% per stack. Clearcasting no longer reduces the mana cost of Arcane Explosion.
    arcanosphere       = 5397, -- (353128) Builds a sphere of Arcane energy, gaining power over 4 sec. Upon release, the sphere passes through any barriers, knocking enemies back and dealing up to 11,978 Arcane damage.
    ice_wall           = 5488, -- (352278) Conjures an Ice Wall 30 yards long that obstructs line of sight. The wall has 40% of your maximum health and lasts up to 15 sec.
    kleptomania        = 3529, -- (198100) Spellsteal steals all spells from the target, now has a 30 sec cooldown and costs 300% more mana.
    mass_invisibility  = 637 , -- (198158) You and your allies within 40 yards instantly become invisible for 5 sec. Dealing damage will cancel the effect.
    master_of_escape   = 635 , -- (210476) Reduces the cooldown of Greater Invisibility by 45 sec.
    netherwind_armor   = 3442, -- (198062) Reduces the chance you will suffer a critical strike by 10%.
    precognition       = 5492, -- (377360) If an interrupt is used on you while you are not casting, gain 15% haste and become immune to control and interrupt effects for 4 sec.
    prismatic_cloak    = 3531, -- (198064) After you Shimmer, you take 50% less magical damage for 2 sec.
    ring_of_fire       = 5491, -- (353082) Summons a Ring of Fire for 8 sec at the target location. Enemies entering the ring burn for 24% of their total health over 6 sec.
    temporal_shield    = 3517, -- (198111) Envelops you in a temporal shield for 4 sec. 100% of all damage taken while shielded will be instantly restored when the shield ends.
} )


-- Auras
spec:RegisterAuras( {
    -- Talent: Altering Time. Returning to past location and health when duration expires.
    -- https://wowhead.com/beta/spell=342246
    alter_time = {
        id = 342246,
        duration = 10,
        max_stack = 1
    },
    arcane_blast_overcapped = {
        duration = 3,
        max_stack = 1,
    },
    -- Increases the damage of Arcane Blast, Arcane Missiles, Arcane Explosion, and Arcane Barrage by $36032w1%.    Increases the mana cost of Arcane Blast by $36032w2%$?{$w5<0}[, and reduces the cast time of Arcane Blast by $w5%.][.]    Increases the number of targets hit by Arcane Barrage for 50% damage by $36032w3.
    -- https://wowhead.com/beta/spell=36032
    arcane_charge = {
        duration = 3600,
        max_stack = 4,
        generate = function ()
            local ac = buff.arcane_charge

            if arcane_charges.current > 0 then
                ac.count = arcane_charges.current
                ac.applied = query_time
                ac.expires = query_time + 3600
                ac.caster = "player"
                return
            end

            ac.count = 0
            ac.applied = 0
            ac.expires = 0
            ac.caster = "nobody"
        end,
    },
    -- Talent: Maximum mana increased by $s1%.
    -- https://wowhead.com/beta/spell=210126
    arcane_familiar = {
        id = 210126,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Increases the damage of your next Arcane Barrage by $s1%.
    -- https://wowhead.com/beta/spell=384455
    arcane_harmony = {
        id = 384455,
        duration = 3600,
        max_stack = 1,
        copy = 332777
    },
    -- Intellect increased by $w1%.
    -- https://wowhead.com/beta/spell=1459
    arcane_intellect = {
        id = 1459,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        shared = "player"
    },
    arcane_orb = {
        duration = 2.5,
        max_stack = 1,
        --[[ generate = function ()
            local last = action.arcane_orb.lastCast
            local ao = buff.arcane_orb

            if query_time - last < 2.5 then
                ao.count = 1
                ao.applied = last
                ao.expires = last + 2.5
                ao.caster = "player"
                return
            end

            ao.count = 0
            ao.applied = 0
            ao.expires = 0
            ao.caster = "nobody"
        end, ]]
    },
    arcane_power = {
        id = 12042,
        duration = 15,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: Spell damage increased by $w1% and Mana Regeneration increase $w3%.
    -- https://wowhead.com/beta/spell=365362
    arcane_surge = {
        id = 365362,
        duration = function() return ( talent.arcane_power.enabled and 15 or 12 ) + ( set_bonus.tier30_2pc > 0 and 3 or 0 ) end,
        type = "Magic",
        max_stack = 1
    },
    arcane_tempo = {
        id = 383997,
        duration = 12,
        max_stack = 5
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=157981
    blast_wave = {
        id = 157981,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Absorbs $w1 damage.  Melee attackers take $235314s1 Fire damage.
    -- https://wowhead.com/beta/spell=235313
    blazing_barrier = {
        id = 235313,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Blinking.
    -- https://wowhead.com/beta/spell=1953
    blink = {
        id = 1953,
        duration = 0.3,
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=12486
    blizzard = {
        id = 12486,
        duration = 3,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed increased by $s1%.
    -- https://wowhead.com/beta/spell=236298
    chrono_shift = {
        id = 236298,
        duration = 5,
        max_stack = 1,
        copy = "chrono_shift_buff"
    },
    -- Talent: Movement speed slowed by $s1%.
    -- https://wowhead.com/beta/spell=236299
    chrono_shift_snare = {
        id = 236299,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Your next Arcane Missiles or Arcane Explosion costs no mana$?s321758[ and Arcane Missiles fires an additional missile][].
    -- https://wowhead.com/beta/spell=263725
    clearcasting = {
        id = function () return pvptalent.arcane_empowerment.enabled and 276743 or 263725 end,
        duration = 15,
        type = "Magic",
        max_stack = function ()
            return ( talent.improved_clearcasting.enabled and 3 or 1 ) + ( pvptalent.arcane_empowerment.enabled and 2 or 0 )
        end,
        copy = { 263725, 276743 }
    },
    clearcasting_channel = {
        duration = function () return 2.5 * haste end,
        tick_time = function () return ( 2.5 / 6 ) * haste end,
        max_stack = 1,
    },
    -- Talent: Your next Clearcasting will not be consumed.
    -- https://wowhead.com/beta/spell=384379
    concentration = {
        id = 384379,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Mana regeneration increased by $s1%.
    -- https://wowhead.com/beta/spell=12051
    evocation = {
        id = 12051,
        duration = function () return 6 * haste end,
        tick_time = function () return haste end,
        max_stack = 1,
    },
    freezing_cold = {
        id = 386770,
        duration = 5,
        max_stack = 1,
    },
    -- Frozen in place.
    -- https://wowhead.com/beta/spell=122
    frost_nova = {
        id = 122,
        duration = function() return talent.improved_frost_nova.enabled and 8 or 6 end,
        type = "Magic",
        max_stack = 1,
        copy = 235235
    },
    hypothermia = {
        id = 41425,
        duration = 30,
        max_stack = 1,
    },
    -- Talent: Immune to all attacks and damage.  Cannot attack, move, or use spells.
    -- https://wowhead.com/beta/spell=45438
    ice_block = {
        id = 45438,
        duration = 10,
        mechanic = "invulneraility",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Able to move while casting spells.
    -- https://wowhead.com/beta/spell=108839
    ice_floes = {
        id = 108839,
        duration = 15,
        type = "Magic",
        max_stack = 3
    },
    impetus = {
        id = 393939,
        duration = 10,
        max_stack = 1,
    },
    incantation_of_swiftness = {
        id = 382294,
        duration = 6,
        max_stack = 1,
        copy = 337278
    },
    incanters_flow = {
        id = 116267,
        duration = 3600,
        max_stack = 5,
        meta = {
            stack = function() return state.incanters_flow_stacks end,
            stacks = function() return state.incanters_flow_stacks end,
        }
    },
    mirror_image = {
        id = 55342,
        duration = 40,
        max_stack = 3,
        generate = function ()
            local mi = buff.mirror_image

            if action.mirror_image.lastCast > 0 and query_time < action.mirror_image.lastCast + 40 then
                mi.count = 1
                mi.applied = action.mirror_image.lastCast
                mi.expires = mi.applied + 40
                mi.caster = "player"
                return
            end

            mi.count = 0
            mi.applied = 0
            mi.expires = 0
            mi.caster = "nobody"
        end,
    },
    mirrors_of_torment = {
        id = 314793,
        duration = 20,
        type = "Magic",
        max_stack = 3,
    },
    nether_precision = {
        id = 383783,
        duration = 10,
        max_stack = 2,
        copy = 336889
    },
    -- Talent: Deals $w1 Arcane damage and an additional $w1 Arcane damage to all enemies within $114954A1 yards every $t sec.
    -- https://wowhead.com/beta/spell=114923
    nether_tempest = {
        id = 114923,
        duration = 12,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    orb_barrage = {
        id = 384859,
        duration = 30,
        max_stack = 15
    },
    orb_barrage_ready = {
        id = 384860,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Spell critical strike chance increased by $w1%.
    -- https://wowhead.com/beta/spell=394195
    overflowing_energy = {
        id = 394195,
        duration = 8,
        max_stack = 5
    },
    -- Talent: Arcane Blast is instant cast.
    -- https://wowhead.com/beta/spell=205025
    presence_of_mind = {
        id = 205025,
        duration = 3600,
        max_stack = 2,
        onRemove = function( t )
            setCooldown( "presence_of_mind", action.presence_of_mind.cooldown )
        end,
    },
    -- Talent: Absorbs $w1 damage.  Magic damage taken reduced by $s3%.  Duration of all harmful Magic effects reduced by $w4%.
    -- https://wowhead.com/beta/spell=235450
    prismatic_barrier = {
        id = 235450,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $w2 Arcane damage every $t2 sec.
    -- https://wowhead.com/beta/spell=376103
    radiant_spark = {
        id = 376103,
        duration = 12,
        type = "Magic",
        max_stack = 1,
        copy = 307443
    },
    -- Damage taken from $@auracaster  increased by $w1%.
    -- https://wowhead.com/beta/spell=376104
    radiant_spark_vulnerability = {
        id = 376104,
        duration = 12,
        max_stack = 4,
        copy = 307454
    },
    radiant_spark_consumed = {
        id = 376105,
        duration = 10,
        max_stack = 1,
        copy = 307747
    },
    rule_of_threes = {
        id = 264774,
        duration = 15,
        max_stack = 1,
    },
    -- Talent: Every $t1 sec, deal $382445s1 Nature damage to enemies within $382445A1 yds and reduce the remaining cooldown of your abilities by ${-$s2/1000} sec.
    -- https://wowhead.com/beta/spell=382440
    shifting_power = {
        id = 382440,
        duration = function() return 4 * haste end,
        tick_time = function() return haste end,
        type = "Magic",
        max_stack = 1,
        copy = 314791
    },
    -- Talent: Shimmering.
    -- https://wowhead.com/beta/spell=212653
    shimmer = {
        id = 212653,
        duration = 0.65,
        type = "Magic",
        max_stack = 1
    },
    siphon_storm = {
        id = 384267,
        duration = 30,
        max_stack = 7,
        copy = 332934
    },
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=31589
    slow = {
        id = 31589,
        duration = 15,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=382290
    tempest_barrier = {
        id = 382290,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Rooted and Silenced.
    -- https://wowhead.com/beta/spell=317589
    tormenting_backlash = {
        id = 317589,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Will explode for $w1 Arcane damage upon expiration.
    -- https://wowhead.com/beta/spell=210824
    touch_of_the_magi = {
        id = 210824,
        duration = 12,
        max_stack = 1
    },
    -- Suffering $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=277703
    trailing_embers = {
        id = 277703,
        duration = 6,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },

    -- Azerite Powers
    brain_storm = {
        id = 273330,
        duration = 30,
        max_stack = 1,
    },
    equipoise = {
        id = 264352,
        duration = 3600,
        max_stack = 1,
    },

    -- Legendaries
    heart_of_the_fae = {
        id = 356881,
        duration = 15,
        max_stack = 1,
    },
    grisly_icicle = {
        id = 348007,
        duration = 8,
        max_stack = 1
    }
} )


-- Variables from APL (2022-11-30)
-- actions.precombat+=/variable,name=aoe_target_count,default=-1,op=set,if=variable.aoe_target_count=-1,value=3
spec:RegisterVariable( "aoe_target_count", function ()
    return 3
end )

-- Goal is to conserve mana through the first TotM in a fight, then burn otherwise.
local totm_casts = 0
local clearcasting_consumed = 0

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_CAST_SUCCESS" and spellID == 321507 then
            totm_casts = ( totm_casts + 1 ) % 2

        elseif subtype == "SPELL_AURA_REMOVED" and ( spellID == 276743 or spellID == 263725 ) then
            -- Clearcasting was consumed.
            clearcasting_consumed = GetTime()
        end
    end
end, false )

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    totm_casts = 0
end )

-- actions.precombat+=/variable,name=conserve_mana,op=set,value=0
-- actions.touch_phase+=/variable,name=conserve_mana,op=set,if=debuff.touch_of_the_magi.remains>9,value=1-variable.conserve_mana
spec:RegisterVariable( "conserve_mana", function ()
    return totm_casts % 2 > 0
end )


do
    -- Builds Disciplinary Command; written so that it can be ported to the other two Mage specs.
    function Hekili:EmbedDisciplinaryCommand( x )
        local file_id = x.id

        x:RegisterAuras( {
            disciplinary_command = {
                id = 327371,
                duration = 20,
            },

            disciplinary_command_arcane = {
                duration = 10,
                max_stack = 1,
            },

            disciplinary_command_frost = {
                duration = 10,
                max_stack = 1,
            },

            disciplinary_command_fire = {
                duration = 10,
                max_stack = 1,
            }
        } )

        local __last_arcane, __last_fire, __last_frost, __last_disciplinary_command = 0, 0, 0, 0
        local __last_arcSpell, __last_firSpell, __last_froSpell

        x:RegisterHook( "reset_precast", function ()
            if not legendary.disciplinary_command.enabled then return end

            if now - __last_arcane < 10 then applyBuff( "disciplinary_command_arcane", 10 - ( now - __last_arcane ) ) end
            if now - __last_fire   < 10 then applyBuff( "disciplinary_command_fire",   10 - ( now - __last_fire ) ) end
            if now - __last_frost  < 10 then applyBuff( "disciplinary_command_frost",  10 - ( now - __last_frost ) ) end

            if now - __last_disciplinary_command < 30 then
                setCooldown( "buff_disciplinary_command", 30 - ( now - __last_disciplinary_command ) )
            end

            Hekili:Debug( "Disciplinary Command:\n - Arcane: %.2f, %s\n - Fire  : %.2f, %s\n - Frost : %.2f, %s\n - ICD   : %.2f", buff.disciplinary_command_arcane.remains, __last_arcSpell or "None", buff.disciplinary_command_fire.remains, __last_firSpell or "None", buff.disciplinary_command_frost.remains, __last_froSpell or "None", cooldown.buff_disciplinary_command.remains )
        end )

        x:RegisterStateFunction( "update_disciplinary_command", function( action )
            local ability = class.abilities[ action ]

            if not ability then return end
            if ability.item or ability.from == 0 then return end

            if     ability.school == "arcane" then applyBuff( "disciplinary_command_arcane" )
            elseif ability.school == "fire"   then applyBuff( "disciplinary_command_fire"   )
            elseif ability.school == "frost"  then applyBuff( "disciplinary_command_frost"  )
            else
                local sAction = x.abilities[ action ]
                local sDiscipline = sAction and sAction.school

                if sDiscipline then
                    if     sDiscipline == "arcane" then applyBuff( "disciplinary_command_arcane" )
                    elseif sDiscipline == "fire"   then applyBuff( "disciplinary_command_fire"   )
                    elseif sDiscipline == "frost"  then applyBuff( "disciplinary_command_frost"  ) end
                else applyBuff( "disciplinary_command_" .. state.spec.key ) end
            end

            if buff.disciplinary_command_arcane.up and buff.disciplinary_command_fire.up and buff.disciplinary_command_frost.up then
                applyBuff( "disciplinary_command" )
                setCooldown( "buff_disciplinary_command", 30 )
                removeBuff( "disciplinary_command_arcane" )
                removeBuff( "disciplinary_command_fire" )
                removeBuff( "disciplinary_command_frost" )
            end
        end )

        x:RegisterHook( "runHandler", function( action )
            if not legendary.disciplinary_command.enabled or cooldown.buff_disciplinary_command.remains > 0 then return end
            update_disciplinary_command( action )
        end )

        local triggerEvents = {
            SPELL_CAST_SUCCESS = true,
            SPELL_HEAL = true,
            SPELL_SUMMON= true
        }

        local spellChanges = {
            [108853] = 319836,
            [212653] = 1953,
            [342130] = 116011,
            [337137] = 1,
        }

        local spellSchools = {
            [4] = "fire",
            [16] = "frost",
            [64] = "arcane"
        }

        x:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, _, _, _, _, _, _, _, spellID, spellName, spellSchool )
            if sourceGUID == GUID then
                if triggerEvents[ subtype ] then
                    spellID = spellChanges[ spellID ] or spellID
                    if not IsSpellKnown( spellID, false ) then return end

                    local school = spellSchools[ spellSchool ]
                    if not school then return end

                    if     school == "arcane" then __last_arcane = GetTime(); __last_arcSpell = spellName
                    elseif school == "fire"   then __last_fire   = GetTime(); __last_firSpell = spellName
                    elseif school == "frost"  then __last_frost  = GetTime(); __last_froSpell = spellName end
                    return
                elseif subtype == "SPELL_AURA_APPLIED" and spellID == class.auras.disciplinary_command.id then
                    __last_disciplinary_command = GetTime()
                    __last_arcane = 0
                    __last_fire = 0
                    __last_frost = 0
                end
            end
        end, false )

        x:RegisterAbility( "buff_disciplinary_command", {
            cooldown_special = function ()
                local remains = ( now + offset ) - __last_disciplinary_command

                if remains < 30 then
                    return __last_disciplinary_command, 30
                end

                return 0, 0
            end,
            unlisted = true,

            cast = 0,
            cooldown = 30,
            gcd = "off",

            handler = function()
                applyBuff( "disciplinary_command" )
            end,
        } )
    end
end


-- Tier 30
spec:RegisterGear( "tier30", 202554, 202552, 202551, 202550, 202549 )
spec:RegisterAura( "arcane_overload", {
    id = 409022,
    duration = 18,
    max_stack = 25
} )

local TriggerArcaneOverloadT30 = setfenv( function()
    applyBuff( "arcane_overload" )
end, state )

spec:RegisterGear( "tier29", 200318, 200320, 200315, 200317, 200319 )
spec:RegisterAura( "bursting_energy", {
    id = 395006,
    duration = 12,
    max_stack = 4
} )


spec:RegisterHook( "spend", function( amt, resource )
    if resource == "arcane_charges" then
        if arcane_charges.current == 0 then
            removeBuff( "arcane_charge" )
        else
            applyBuff( "arcane_charge", nil, arcane_charges.current )
        end
        if amt > 0 and talent.arcane_tempo.enabled then
            addStack( "arcane_tempo", nil, 1 )
        end

    elseif resource == "mana" then
        if azerite.equipoise.enabled and mana.percent < 70 then
            removeBuff( "equipoise" )
        end
    end
end )

spec:RegisterHook( "gain", function( amt, resource )
    if resource == "arcane_charges" then
        if arcane_charges.current == 0 then
            removeBuff( "arcane_charge" )
        else
            if talent.rule_of_threes.enabled and arcane_charges.current >= 3 and arcane_charges.current - amt < 3 then
                applyBuff( "rule_of_threes" )
            end
            applyBuff( "arcane_charge", nil, arcane_charges.current )
        end
    end
end )

spec:RegisterHook( "runHandler", function( action )
    if buff.ice_floes.up then
        local ability = class.abilities[ action ]
        if ability and ability.cast > 0 and ability.cast < 10 then removeStack( "ice_floes" ) end
    end
end )


--[[ spec:RegisterStateTable( "burn_info", setmetatable( {
    __start = 0,
    start = 0,
    __average = 20,
    average = 20,
    n = 1,
    __n = 1,
}, {
    __index = function( t, k )
        if k == "active" then
            return t.start > 0
        end
    end,
} ) ) ]]


spec:RegisterTotem( "rune_of_power", 609815 )


spec:RegisterStateTable( "incanters_flow", {
    changed = 0,
    count = 0,
    direction = 0,

    startCount = 0,
    startTime = 0,
    startIndex = 0,

    values = {
        [0] = { 0, 1 },
        { 1, 1 },
        { 2, 1 },
        { 3, 1 },
        { 4, 1 },
        { 5, 0 },
        { 5, -1 },
        { 4, -1 },
        { 3, -1 },
        { 2, -1 },
        { 1, 0 }
    },

    f = CreateFrame( "Frame" ),
    fRegistered = false,

    reset = setfenv( function ()
        if talent.incanters_flow.enabled then
            if not incanters_flow.fRegistered then
                Hekili:ProfileFrame( "Incanters_Flow_Arcane", incanters_flow.f )
                -- One-time setup.
                incanters_flow.f:RegisterUnitEvent( "UNIT_AURA", "player" )
                incanters_flow.f:SetScript( "OnEvent", function ()
                    -- Check to see if IF changed.
                    if state.talent.incanters_flow.enabled then
                        local flow = state.incanters_flow
                        local name, _, count = FindUnitBuffByID( "player", 116267, "PLAYER" )
                        local now = GetTime()

                        if name then
                            if count ~= flow.count then
                                if count == 1 then flow.direction = 0
                                elseif count == 5 then flow.direction = 0
                                else flow.direction = ( count > flow.count ) and 1 or -1 end

                                flow.changed = GetTime()
                                flow.count = count
                            end
                        else
                            flow.count = 0
                            flow.changed = GetTime()
                            flow.direction = 0
                        end
                    end
                end )

                incanters_flow.fRegistered = true
            end

            if now - incanters_flow.changed >= 1 then
                if incanters_flow.count == 1 and incanters_flow.direction == 0 then
                    incanters_flow.direction = 1
                    incanters_flow.changed = incanters_flow.changed + 1
                elseif incanters_flow.count == 5 and incanters_flow.direction == 0 then
                    incanters_flow.direction = -1
                    incanters_flow.changed = incanters_flow.changed + 1
                end
            end

            if incanters_flow.count == 0 then
                incanters_flow.startCount = 0
                incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                incanters_flow.startIndex = 0
            else
                incanters_flow.startCount = incanters_flow.count
                incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                incanters_flow.startIndex = 0

                for i, val in ipairs( incanters_flow.values ) do
                    if val[1] == incanters_flow.count and val[2] == incanters_flow.direction then incanters_flow.startIndex = i; break end
                end
            end
        else
            incanters_flow.count = 0
            incanters_flow.changed = 0
            incanters_flow.direction = 0
        end
    end, state ),
} )

spec:RegisterStateExpr( "incanters_flow_stacks", function ()
    if not talent.incanters_flow.enabled then return 0 end

    local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
    if index > 10 then index = index % 10 end

    return incanters_flow.values[ index ][ 1 ]
end )

spec:RegisterStateExpr( "incanters_flow_dir", function()
    if not talent.incanters_flow.enabled then return 0 end

    local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
    if index > 10 then index = index % 10 end

    return incanters_flow.values[ index ][ 2 ]
end )

-- Seemingly, a very silly way to track Incanter's Flow...
local incanters_flow_time_obj = setmetatable( { __stack = 0 }, {
    __index = function( t, k )
        if not state.talent.incanters_flow.enabled then return 0 end

        local stack = t.__stack
        local ticks = #state.incanters_flow.values

        local start = state.incanters_flow.startIndex + floor( state.offset + state.delay )

        local low_pos, high_pos

        if k == "up" then low_pos = 5
        elseif k == "down" then high_pos = 6 end

        local time_since = ( state.query_time - state.incanters_flow.changed ) % 1

        for i = 0, 10 do
            local index = ( start + i )
            if index > 10 then index = index % 10 end

            local values = state.incanters_flow.values[ index ]

            if values[ 1 ] == stack and ( not low_pos or index <= low_pos ) and ( not high_pos or index >= high_pos ) then
                return max( 0, i - time_since )
            end
        end

        return 0
    end
} )

spec:RegisterStateTable( "incanters_flow_time_to", setmetatable( {}, {
    __index = function( t, k )
        incanters_flow_time_obj.__stack = tonumber( k ) or 0
        return incanters_flow_time_obj
    end
} ) )


spec:RegisterStateExpr( "mana_gem_charges", function ()
    return 0
end )


--[[ spec:RegisterStateFunction( "start_burn_phase", function ()
    burn_info.start = query_time
end )


spec:RegisterStateFunction( "stop_burn_phase", function ()
    if burn_info.start > 0 then
        burn_info.average = burn_info.average * burn_info.n
        burn_info.average = burn_info.average + ( query_time - burn_info.start )
        burn_info.n = burn_info.n + 1

        burn_info.average = burn_info.average / burn_info.n
        burn_info.start = 0
    end
end )


spec:RegisterStateExpr( "burn_phase", function ()
    return burn_info.start > 0
end )

spec:RegisterStateExpr( "average_burn_length", function ()
    return burn_info.average or 15
end ) ]]


spec:RegisterStateExpr( "tick_reduction", function ()
    return action.shifting_power.cdr / 4
end )

spec:RegisterStateExpr( "full_reduction", function ()
    return action.shifting_power.cdr
end )


-- Dragonflight APL 20221213
-- aoe_spark_phase starts:
--     active_enemies>=variable.aoe_target_count&(action.arcane_orb.charges>0|buff.arcane_charge.stack>=3)&(!talent.rune_of_power|cooldown.rune_of_power.ready)&cooldown.radiant_spark.ready&cooldown.touch_of_the_magi.remains<=(gcd.max*2)
-- aoe_spark_phase ends:
--     variable.aoe_spark_phase&debuff.radiant_spark_vulnerability.down&dot.radiant_spark.remains<7&cooldown.radiant_spark.remains

local realAoeSparkPhase = {}
local virtualAoeSparkPhase = false

local SetAoeSparkPhase = setfenv( function()
    if realAoeSparkPhase[ display ] == nil then realAoeSparkPhase[ display ] = false end

    if not realAoeSparkPhase[ display ] and active_enemies >= variable.aoe_target_count and ( cooldown.arcane_orb.charges > 0 or buff.arcane_charge.stack >= 3 ) and ( not talent.rune_of_power.enabled or cooldown.rune_of_power.remains < gcd.max ) and cooldown.radiant_spark.remains < gcd.max and cooldown.touch_of_the_magi.remains <= gcd.max * 2 then
        realAoeSparkPhase[ display ] = true
    end

    if realAoeSparkPhase[ display ] and not debuff.radiant_spark_vulnerability.up and debuff.radiant_spark.remains < 7 and cooldown.radiant_spark.remains > gcd.max then
        realAoeSparkPhase[ display ] = false
    end

    virtualAoeSparkPhase = realAoeSparkPhase[ display ]
end, state )

local UpdateAoeSparkPhase = setfenv( function()
    if not virtualAoeSparkPhase and active_enemies >= variable.aoe_target_count and ( action.arcane_orb.charges > 0 or buff.arcane_charge.stack >= 3 ) and ( not talent.rune_of_power.enabled or cooldown.rune_of_power.remains < gcd.max ) and cooldown.radiant_spark.remains < gcd.max and cooldown.touch_of_the_magi.remains <= 2 * gcd.max then
        virtualAoeSparkPhase = true
    end

    if virtualAoeSparkPhase and debuff.radiant_spark_vulnerability.down and dot.radiant_spark.remains < 5 and cooldown.radiant_spark.remains > gcd.max then
        virtualAoeSparkPhase = false
    end
end, state )

spec:RegisterVariable( "aoe_spark_phase", function ()
    return virtualAoeSparkPhase
end )


-- spark_phase starts:
--     buff.arcane_charge.stack>=3&active_enemies<variable.aoe_target_count&(!talent.rune_of_power|cooldown.rune_of_power.ready)&cooldown.radiant_spark.ready&cooldown.touch_of_the_magi.remains<=(gcd.max*7)&!set_bonus.tier30_4pc
-- spark_phase ends:
--     variable.spark_phase&debuff.radiant_spark_vulnerability.down&dot.radiant_spark.remains<5&cooldown.radiant_spark.remains

local realSparkPhase = {}
local virtualSparkPhase = false

local SetSparkPhase = setfenv( function()
    if realSparkPhase[ display ] == nil then realSparkPhase[ display ] = false end

    if not realSparkPhase[ display ] and buff.arcane_charge.stack >= 3 and active_enemies < variable.aoe_target_count and ( not talent.rune_of_power.enabled or cooldown.rune_of_power.remains < gcd.max ) and cooldown.radiant_spark.remains < gcd.max and cooldown.touch_of_the_magi.remains <= gcd.max * 7 and set_bonus.tier30_4pc == 0 then
        realSparkPhase[ display ] = true
    end

    if realSparkPhase[ display ] and not prev[1].radiant_spark and not prev[2].radiant_spark and not debuff.radiant_spark_vulnerability.up and debuff.radiant_spark.remains < 7 and cooldown.radiant_spark.remains > gcd.max and cooldown.touch_of_the_magi.remains > gcd.max * 7 then
        realSparkPhase[ display ] = false
    end

    virtualSparkPhase = realSparkPhase[ display ]
end, state )

local UpdateSparkPhase = setfenv( function()
    if not virtualSparkPhase and buff.arcane_charge.stack >= 3 and active_enemies < variable.aoe_target_count and ( not talent.rune_of_power.enabled or cooldown.rune_of_power.remains < gcd.max ) and cooldown.radiant_spark.remains < gcd.max and cooldown.touch_of_the_magi.remains <= gcd.max * 7 then
        virtualSparkPhase = true
    end

    if virtualSparkPhase and debuff.radiant_spark_vulnerability.down and dot.radiant_spark.remains < 5 and cooldown.radiant_spark.remains > gcd.max and cooldown.touch_of_the_magi.remains > gcd.max * 7 then
        virtualSparkPhase = false
    end
end, state )

spec:RegisterVariable( "spark_phase", function ()
    return virtualSparkPhase
end )


-- rop_phase starts:
--     talent.rune_of_power&!talent.radiant_spark&buff.arcane_charge.stack>=3&cooldown.rune_of_power.ready&active_enemies<variable.aoe_target_count
-- rop_phase ends:
--     debuff.touch_of_the_magi.up|!talent.rune_of_power

local realRopPhase = {}
local virtualRopPhase = false

local SetRopPhase = setfenv( function()
    if realRopPhase[ display ] == nil then realRopPhase[ display ] = false end

    if not realRopPhase[ display ] and talent.rune_of_power.enabled and not talent.radiant_spark.enabled and buff.arcane_charge.stack >= 3 and cooldown.rune_of_power.remains < gcd.max and active_enemies < variable.aoe_target_count then
        realRopPhase[ display ] = true
    end

    if realRopPhase[ display ] and ( debuff.touch_of_the_magi.up or not talent.rune_of_power.enabled ) then
        realRopPhase[ display ] = false
    end

    virtualRopPhase = realRopPhase[ display ]
end, state )

local UpdateRopPhase = setfenv( function()
    if not virtualRopPhase and talent.rune_of_power.enabled and not talent.radiant_spark.enabled and buff.arcane_charge.stack >= 3 and cooldown.rune_of_power.remains < gcd.max and active_enemies < variable.aoe_target_count then
        virtualRopPhase = true
    end

    if virtualRopPhase and debuff.touch_of_the_magi.up or not talent.rune_of_power.enabled then
        virtualRopPhase = false
    end
end, state )

spec:RegisterVariable( "rop_phase", function ()
    return virtualRopPhase
end )

spec:RegisterPhasedVariable( "opener",
    -- Default value.
    function() return true end,
    -- Value update function; include all conditions here.
    function( current, default )
        if current and debuff.touch_of_the_magi.up then return false end
        return current
    end,
"reset_precast", "advance_end", "runHandler" )


local abs = math.abs


spec:RegisterHook( "reset_precast", function ()
    if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
    else removeBuff( "rune_of_power" ) end

    if buff.casting.up and buff.casting.v1 == 5143 and abs( action.arcane_missiles.lastCast - clearcasting_consumed ) < 0.15 then
        applyBuff( "clearcasting_channel", buff.casting.remains )
    end

    if arcane_charges.current > 0 then applyBuff( "arcane_charge", nil, arcane_charges.current ) end

    mana_gem_charges = GetItemCount( 36799, nil, true )

    if prev[1].conjure_mana_gem and now - action.conjure_mana_gem.lastCast < 1 and mana_gem_charges == 0 then
        mana_gem_charges = 3
    end

    if buff.arcane_surge.up and set_bonus.tier30_4pc > 0 then
        state:QueueAuraEvent( "arcane_overload", TriggerArcaneOverloadT30, buff.arcane_surge.expires, "AURA_EXPIRATION" )
    end

    incanters_flow.reset()

    SetAoeSparkPhase( display )
    SetSparkPhase( display )
    SetRopPhase( display )

    if Hekili.ActiveDebug then Hekili:Debug( "Arcane Phases (reset): aoe_spark_phase[%s], spark_phase[%s], rop_phase[%s]", tostring( virtualAoeSparkPhase ), tostring( virtualSparkPhase ), tostring( virtualRopPhase ) ) end
end )

spec:RegisterHook( "runHandler", function()
    UpdateAoeSparkPhase()
    UpdateSparkPhase()
    UpdateRopPhase()

    if Hekili.ActiveDebug then Hekili:Debug( "Arcane Phases (handler): aoe_spark_phase[%s], spark_phase[%s], rop_phase[%s]", tostring( virtualAoeSparkPhase ), tostring( virtualSparkPhase ), tostring( virtualRopPhase ) ) end
end )

spec:RegisterHook( "advance", function()
    UpdateAoeSparkPhase()
    UpdateSparkPhase()
    UpdateRopPhase()

    if Hekili.ActiveDebug then Hekili:Debug( "Arcane Phases (advance): aoe_spark_phase[%s], spark_phase[%s], rop_phase[%s]", tostring( virtualAoeSparkPhase ), tostring( virtualSparkPhase ), tostring( virtualRopPhase ) ) end
end )


spec:RegisterStateFunction( "handle_radiant_spark", function()
    if debuff.radiant_spark_vulnerability.down then
        applyDebuff( "target", "radiant_spark_vulnerability" )
    else
        debuff.radiant_spark_vulnerability.count = debuff.radiant_spark_vulnerability.count + 1

        -- Implemented with max of 5 stacks (application of 5th stack makes the debuff expire in 0.1 seconds, to give us time to Arcane Barrage).
        if debuff.radiant_spark_vulnerability.stack == debuff.radiant_spark_vulnerability.max_stack then
            debuff.radiant_spark_vulnerability.expires = query_time + 0.1
            applyBuff( "radiant_spark_consumed", debuff.radiant_spark.remains )
        end
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after 10 seconds. Effect negated by long distance or death.
    alter_time = {
        id = function () return buff.alter_time.down and 342247 or 342245 end,
        cast = 0,
        cooldown = function () return talent.master_of_time.enabled and 50 or 60 end,
        gcd = "spell",
        school = "arcane",

        spend = 0.01,
        spendType = "mana",

        toggle = "defensives",
        startsCombat = false,

        handler = function ()
            if buff.alter_time.down then
                applyBuff( "alter_time" )
            else
                removeBuff( "alter_time" )
                if talent.master_of_time.enabled then setCooldown( "blink", 0 ) end
            end
        end,

        copy = { 342247, 342245 },
    },

    -- Talent: Launches bolts of arcane energy at the enemy target, causing 1,617 Arcane damage. For each Arcane Charge, deals 36% additional damage and hits 1 additional nearby target for 40% of its damage. Consumes all Arcane Charges.
    arcane_barrage = {
        id = 44425,
        cast = 0,
        cooldown = 3,
        gcd = "spell",
        school = "arcane",

        talent = "arcane_barrage",
        startsCombat = true,

        handler = function ()
            if talent.mana_adept.enabled then gain( 0.02 * mana.modmax * arcane_charges.current, "mana" ) end

            spend( arcane_charges.current, "arcane_charges" )
            removeBuff( "arcane_harmony" )
            removeBuff( "bursting_energy" )

            if talent.chrono_shift.enabled then
                applyBuff( "chrono_shift_buff" )
                applyDebuff( "target", "chrono_shift_snare" )
            end

            if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
        end,
    },

    -- Blasts the target with energy, dealing 1,340 Arcane damage. Each Arcane Charge increases damage by 72% and mana cost by 100%, and reduces cast time by 8%. Generates 1 Arcane Charge.
    arcane_blast = {
        id = 30451,
        cast = function ()
            if buff.presence_of_mind.up then return 0 end
            return 2.25 * ( 1 - ( 0.08 * arcane_charges.current ) ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function ()
            if buff.rule_of_threes.up then return 0 end
            local mult = 0.0275 * ( 1 + arcane_charges.current ) * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 )
            -- if azerite.equipoise.enabled and mana.pct < 70 then return ( mana.modmax * mult ) - 190 end
            return mana.modmax * mult, "mana"
        end,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            if buff.presence_of_mind.up then
                removeStack( "presence_of_mind" )
                if buff.presence_of_mind.down then setCooldown( "presence_of_mind", 60 ) end
            end
            removeBuff( "rule_of_threes" )
            removeStack( "nether_precision" )

            if arcane_charges.current == arcane_charges.max then
                applyBuff( "arcane_blast_overcapped" )
                if talent.arcane_echo.enabled then echo_opened = true end
            end -- Use this to catch "5th" cast of Arcane Blast.
            gain( 1, "arcane_charges" )

            if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
        end,
    },

    -- Causes an explosion of magic around the caster, dealing 1,684 Arcane damage to all enemies within 10 yards. Generates 1 Arcane Charge if any targets are hit.
    arcane_explosion = {
        id = 1449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function ()
            if not pvptalent.arcane_empowerment.enabled and buff.clearcasting.up then return 0 end
            return 0.1 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 )
        end,
        spendType = "mana",

        startsCombat = true,

        usable = function () return not settings.check_explosion_range or target.distance < 10, "target out of range" end,
        handler = function ()
            if buff.expanded_potential.up then removeBuff( "expanded_potential" )
            else
                if buff.concentration.up then removeBuff( "concentration" )
                else
                    removeStack( "clearcasting" )
                    if conduit.nether_precision.enabled or talent.nether_precision.enabled then addStack( "nether_precision", nil, 2 ) end
                    if talent.orb_barrage.enabled then reduceCooldown( "arcane_orb", 2 ) end
                end
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
            end
            gain( 1, "arcane_charges" )
        end,
    },

    -- Talent: Summon a Familiar that attacks your enemies and increases your maximum mana by 10% for 1 |4hour:hrs;.
    arcane_familiar = {
        id = 205022,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "arcane",

        talent = "arcane_familiar",
        startsCombat = false,
        nobuff = "arcane_familiar",
        essential = true,

        handler = function ()
            if buff.arcane_familiar.down then mana.max = mana.max * 1.10 end
            applyBuff( "arcane_familiar" )
        end,

        copy = "summon_arcane_familiar"
    },

    -- Infuses the target with brilliance, increasing their Intellect by 5% for 1 |4hour:hrs;. If the target is in your party or raid, all party and raid members will be affected.
    arcane_intellect = {
        id = 1459,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.04 * ( buff.arcane_surge.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        nobuff = "arcane_intellect",
        essential = true,

        handler = function ()
            applyBuff( "arcane_intellect" )
        end,
    },

    -- Talent: Launches five waves of Arcane Missiles at the enemy over 2.2 sec, causing a total of 5,158 Arcane damage.
    arcane_missiles = {
        id = 5143,
        cast = function () return ( buff.clearcasting.up and 0.8 or 1 ) * 2.5 * haste end,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function ()
            if buff.rule_of_threes.up or buff.clearcasting.up then return 0 end
            return 0.15 * ( buff.arcane_surge.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 )
        end,
        spendType = "mana",

        talent = "arcane_missiles",
        startsCombat = true,
        aura = function () return buff.clearcasting_channel.up and "clearcasting_channel" or "casting" end,
        breakchannel = function ()
            removeBuff( "clearcasting_channel" )
        end,

        tick_time = function ()
            if buff.clearcasting_channel.up then return buff.clearcasting_channel.tick_time end
            return 0.5 * haste
        end,

        start = function ()
            removeBuff( "orb_barrage_ready" )
            removeBuff( "arcane_blast_overcapped" )

            if buff.clearcasting.up then
                if buff.concentration.up then removeBuff( "concentration" )
                else
                    removeStack( "clearcasting" )
                    if conduit.nether_precision.enabled or talent.nether_precision.enabled then addStack( "nether_precision", nil, 2 ) end
                    if talent.orb_barrage.enabled then
                        reduceCooldown( "arcane_orb", 2 )
                        addStack( "orb_barrage", nil, 2 )
                    end
                end
                if talent.amplification.enabled then applyBuff( "clearcasting_channel" ) end
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
            else
                if buff.rule_of_threes.up then removeBuff( "rule_of_threes" ) end
                if talent.orb_barrage.enabled then addStack( "orb_barrage", nil, 1 ) end
            end

            if buff.orb_barrage.stack >= 15 then
                applyBuff( "orb_barrage_ready" )
                removeBuff( "orb_barrage" )
            end

            if buff.expanded_potential.up then removeBuff( "expanded_potential" ) end

            if conduit.arcane_prodigy.enabled and cooldown.arcane_surge.remains > 0 then
                reduceCooldown( "arcane_surge", conduit.arcane_prodigy.mod * 0.1 )
            end
        end,

        tick = function ()
            if talent.arcane_harmony.enabled or legendary.arcane_harmony.enabled then addStack( "arcane_harmony", nil, 1 ) end
            if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
        end,
    },

    -- Talent: Launches an Arcane Orb forward from your position, traveling up to 40 yards, dealing 2,997 Arcane damage to enemies it passes through. Grants 1 Arcane Charge when cast and every time it deals damage.
    arcane_orb = {
        id = 153626,
        cast = 0,
        charges = function() return talent.charged_orb.enabled and 2 or nil end,
        cooldown = 20,
        recharge = function() return talent.charged_orb.enabled and 20 or nil end,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.01 * ( buff.arcane_surge.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "arcane_orb",
        startsCombat = true,

        handler = function ()
            gain( 1, "arcane_charges" )
            applyBuff( "arcane_orb" )
        end,
    },

    -- Talent: Expend all of your current mana to annihilate your enemy target and nearby enemies for up to 7,716 Arcane damage based on Mana spent. Deals reduced damage beyond 5 targets. For the next 15 sec, your Mana Regeneration is increased by 425% and Spell Damage is increased by 35%.
    arcane_surge = {
        id = 365350,
        cast = 2.5,
        cooldown = 90,
        gcd = "spell",
        school = "arcane",

        spend = function() return mana.current end,
        spendType = "mana",

        talent = "arcane_surge",
        startsCombat = true,
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "arcane_surge" )
            mana.regen = mana.regen * 5.25
            forecastResources( "mana" )
            if talent.rune_of_power.enabled then applyBuff( "rune_of_power" ) end
            -- start_burn_phase()
        end,

        copy = "arcane_power"
    },


    arcanosphere = {
        id = 353128,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "arcanosphere",
        startsCombat = false,
        texture = 4226155,

        handler = function ()
        end,
    },


    blink = {
        id = function () return talent.shimmer.enabled and 212653 or 1953 end,
        cast = 0,
        charges = function () return talent.shimmer.enabled and 2 or nil end,
        cooldown = function () return ( talent.shimmer.enabled and 20 or 15 ) - conduit.flow_of_time.mod * 0.001 - talent.flow_of_time.rank end,
        recharge = function () return ( talent.shimmer.enabled and ( 20 - conduit.flow_of_time.mod * 0.001 - talent.flow_of_time.rank ) or nil ) end,
        gcd = "off",
        icd = 6,

        spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = function () return talent.shimmer.enabled and 135739 or 135736 end,

        handler = function ()
            if talent.displacement.enabled then applyBuff( "displacement_beacon" ) end
            if talent.tempest_barrier.enabled then applyBuff( "tempest_barrier" ) end
        end,

        copy = { 212653, 1953, "shimmer", "blink_any" }
    },

    -- Talent: Conjures a Mana Gem that can be used to instantly restore 25% mana and grant 5% spell damage for 12 sec. Holds up to 3 charges. Conjured Items Conjured items disappear if logged out for more than 15 minutes.
    conjure_mana_gem = {
        id = 759,
        cast = 3,
        cooldown = 0,
        icd = 10, -- Probably don't want to recast within 10 seconds.
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        talent = "conjure_mana_gem",
        startsCombat = false,

        usable = function ()
            if mana_gem_charges > 0 then return false, "already has a mana_gem" end
            return true
        end,

        handler = function ()
            mana_gem_charges = 3
        end,
    },

    mana_gem = {
        name = "|cff00ccff[Mana Gem]|r",
        known = function ()
            return state.mana_gem_charges > 0
        end,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 134132,

        item = 36799,
        bagItem = true,

        usable = function ()
            return mana_gem_charges > 0, "requires mana_gem in bags"
        end,

        readyTime = function ()
            local start, duration = GetItemCooldown( 36799 )
            return max( 0, start + duration - query_time )
        end,

        handler = function ()
            gain( 0.25 * mana.max, "mana" )
            if talent.cascading_power.enabled then gain( 2, "arcane_charges" ) end
            mana_gem_charges = mana_gem_charges - 1
        end,

        copy = "use_mana_gem"
    },

    -- Targets in a cone in front of you take 383 Frost damage and have movement slowed by 70% for 5 sec.
    cone_of_cold = {
        id = 120,
        cast = 0,
        cooldown = 12,
        gcd = "spell",
        school = "frost",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,

        usable = function () return target.distance <= 12, "target must be nearby" end,
        handler = function ()
            applyDebuff( "target", talent.freezing_cold.enabled and "freezing_cold" or "cone_of_cold" )
            active_dot.cone_of_cold = max( active_enemies, active_dot.cone_of_cold )

            removeBuff( "snowstorm" )
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
        end,
    },

    -- Counters the enemy's spellcast, preventing any spell from that school of magic from being cast for 6 sec.
    counterspell = {
        id = 2139,
        cast = 0,
        cooldown = function () return 24 - ( conduit.grounding_surge.mod * 0.1 ) end,
        gcd = "off",
        school = "arcane",

        spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        toggle = "interrupts",
        debuff = function () return not runeforge.disciplinary_command.enabled and "casting" or nil end,
        readyTime = function () if debuff.casting.up then return state.timeToInterrupt() end end,

        handler = function ()
            interrupt()
            if talent.quick_witted.enabled then reduceCooldown( "counterspell", 4 ) end
        end,
    },

    -- Talent: Increases your mana regeneration by 750% for 5.3 sec.
    evocation = {
        id = 12051,
        cast = function () return 6 * haste end,
        charges = 1,
        cooldown = 90,
        recharge = 90,
        gcd = "spell",
        school = "arcane",

        channeled = true,
        fixedCast = true,

        talent = "evocation",
        startsCombat = false,
        aura = "evocation",
        tick_time = function () return haste end,

        start = function ()
            -- stop_burn_phase()

            applyBuff( "evocation" )

            if talent.siphon_storm.enabled then
                gain( 1, "arcane_charges" )
                applyBuff( "siphon_storm" )
            end

            if azerite.brain_storm.enabled then
                gain( 2, "arcane_charges" )
                applyBuff( "brain_storm" )
            end

            if legendary.siphon_storm.enabled then
                applyBuff( "siphon_storm" )
            end

            mana.regen = mana.regen * ( 8.5 / haste )
        end,

        tick = function ()
            if talent.siphon_storm.enabled or legendary.siphon_storm.enabled then
                addStack( "siphon_storm", nil, 1 )
            end
        end,

        finish = function ()
            mana.regen = mana.regen / ( 8.5 * haste )
        end,

        breakchannel = function ()
            removeBuff( "evocation" )
            mana.regen = mana.regen / ( 8.5 * haste )
        end,
    },


    focus_magic = {
        id = 321358,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135754,

        talent = "focus_magic",

        usable = function () return active_dot.focus_magic == 0 and group, "can apply one in a group" end,
        handler = function ()
            applyBuff( "focus_magic" )
        end,
    },

    -- Blasts enemies within 12 yds of you for 45 Frost damage and freezes them in place for 6 sec. Damage may interrupt the freeze effect.
    frost_nova = {
        id = 122,
        cast = 0,
        charges = function () return talent.ice_ward.enabled and 2 or nil end,
        cooldown = 30,
        recharge = function () return talent.ice_ward.enabled and 30 or nil end,
        gcd = "spell",
        school = "frost",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        usable = function () return not state.spec.frost or target.distance < 12, "target out of range" end,
        handler = function ()
            applyDebuff( "target", "frost_nova" )
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
            if legendary.grisly_icicle.enabled then applyDebuff( "target", "grisly_icicle" ) end
        end,
    },

    greater_invisibility = {
        id = 110959,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        toggle = "defensives",
        defensive = true,

        startsCombat = false,
        texture = 575584,

        handler = function ()
            applyBuff( "greater_invisibility" )
            if conduit.incantation_of_swiftness.enabled then applyBuff( "incantation_of_swiftness" ) end
        end,
    },

    -- Talent: Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for 40% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_block = {
        id = 45438,
        cast = 0,
        cooldown = function () return 240 + ( conduit.winters_protection.mod * 0.001 ) - 20 * talent.winters_protection.rank end,
        gcd = "spell",
        school = "frost",

        talent = "ice_block",
        startsCombat = false,
        nodebuff = "hypothermia",
        toggle = "defensives",

        handler = function ()
            applyBuff( "ice_block" )
            applyDebuff( "player", "hypothermia" )
        end,
    },

    -- Talent: Makes your next Mage spell with a cast time shorter than 10 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_floes = {
        id = 108839,
        cast = 0,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "off",
        dual_cast = true,
        school = "frost",

        talent = "ice_floes",
        startsCombat = false,

        handler = function ()
            addStack( "ice_floes" )
        end,
    },

    -- Talent: Causes a whirl of icy wind around the enemy, dealing 2,328 Frost damage to the target and reduced damage to all other enemies within 8 yards, and freezing them in place for 2 sec.
    ice_nova = {
        id = 157997,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "frost",

        talent = "ice_nova",
        startsCombat = false,

        handler = function ()
            applyBuff( "ice_nova" )
        end,
    },


    ice_wall = {
        id = 352278,
        cast = 1.5,
        cooldown = 90,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        pvptalent = "ice_wall",
        startsCombat = false,
        texture = 4226156,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    mass_invisibility = {
        id = 198158,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "mass_invisibility",
        startsCombat = false,
        texture = 1387356,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    -- Talent: Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 1 min. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    mass_polymorph = {
        id = 383121,
        cast = 1.7,
        cooldown = 60,
        gcd = "spell",
        school = "arcane",

        spend = 0.04,
        spendType = "mana",

        talent = "mass_polymorph",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mass_polymorph" )
        end,
    },

    -- Talent: Calls down a meteor which lands at the target location after 3 sec, dealing 2,657 Fire damage, split evenly between all targets within 8 yards, and burns the ground, dealing 675 Fire damage over 8.5 sec to all enemies in the area.
    meteor = {
        id = 153561,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "fire",

        spend = 0.01,
        spendType = "mana",

        talent = "meteor",
        startsCombat = false,

        flightTime = 1,

        impact = function ()
            applyDebuff( "target", "meteor_burn" )
        end,
    },

    -- Talent: Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    mirror_image = {
        id = 55342,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "mirror_image",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "mirror_image", nil, 3 )
        end,
    },

    -- Talent: Places a Nether Tempest on the target which deals 459 Arcane damage over 12 sec to the target and nearby enemies within 10 yards. Limit 1 target. Deals reduced damage to secondary targets. Damage increased by 72% per Arcane Charge.
    nether_tempest = {
        id = 114923,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.015 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "nether_tempest",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "nether_tempest" )
        end,
    },


    polymorph = {
        id = 118,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 136071,

        handler = function ()
        end,
    },

    -- Talent: Causes your next 2 Arcane Blasts to be instant cast.
    presence_of_mind = {
        id = 205025,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "arcane",

        talent = "presence_of_mind",
        startsCombat = false,
        nobuff = "presence_of_mind",

        handler = function ()
            applyBuff( "presence_of_mind", nil, 2 )
        end,
    },

    -- Talent: Shields you with an arcane force, absorbing 8,622 damage and reducing magic damage taken by 15% for 1 min. The duration of harmful Magic effects against you is reduced by 25%.
    prismatic_barrier = {
        id = 235450,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "arcane",

        spend = function() return 0.03 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "prismatic_barrier",
        startsCombat = false,

        handler = function ()
            applyBuff( "prismatic_barrier" )
            if legendary.triune_ward.enabled then
                applyBuff( "blazing_barrier" )
                applyBuff( "ice_barrier" )
            end
        end,
    },

    -- Talent: Conjure a radiant spark that causes 2,275 Arcane damage instantly, and an additional 1,158 damage over 10 sec. The target takes 10% increased damage from your direct damage spells, stacking each time they are struck. This effect ends after 4 spells.
    radiant_spark = {
        id = function() return talent.radiant_spark.enabled and 376103 or 307443 end,
        cast = 1.5,
        cooldown = 30,
        gcd = "spell",
        school = "arcane",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "radiant_spark" )
        end,

        copy = { 376103, 307443 }
    },

    -- Talent: Removes all Curses from a friendly target.
    remove_curse = {
        id = 475,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.013 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "remove_curse",
        startsCombat = false,
        debuff = "dispellable_curse",

        handler = function ()
            removeDebuff( "player", "dispellable_curse" )
        end,
    },


    ring_of_fire = {
        id = 353082,
        cast = 2,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        pvptalent = "ring_of_fire",
        startsCombat = false,
        texture = 4067368,

        handler = function ()
        end,
    },

    -- Talent: Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 65% for 4 sec.
    ring_of_frost = {
        id = 113724,
        cast = 2,
        cooldown = 45,
        gcd = "spell",
        school = "frost",

        spend = function () return 0.08 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "ring_of_frost",
        startsCombat = true,

        handler = function ()
        end,
    },

    -- Talent: Places a Rune of Power on the ground for 12 sec which increases your spell damage by 40% while you stand within 8 yds. Casting Arcane Power will also create a Rune of Power at your location.
    rune_of_power = {
        id = 116011,
        cast = 1.5,
        charges = 2,
        cooldown = 40,
        recharge = 40,
        gcd = "spell",

        talent = "rune_of_power",
        startsCombat = false,
        nobuff = "rune_of_power",

        handler = function ()
            applyBuff( "rune_of_power" )
        end,
    },

    -- Talent: Draw power from the Night Fae, dealing 4,113 Nature damage over 3.5 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.5 sec.
    shifting_power = {
        id = function() return talent.shifting_power.enabled and 382440 or 314791 end,
        cast = function () return 4 * haste end,
        channeled = true,
        cooldown = 60,
        gcd = "spell",
        school = "nature",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,

        cdr = function ()
            return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
        end,

        full_reduction = function ()
            return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
        end,

        start = function ()
            applyBuff( "shifting_power" )
        end,

        tick  = function ()
            -- TODO: Identify which abilities have their CDs reduced.
        end,

        finish = function ()
            removeBuff( "shifting_power" )
        end,

        copy = { 382440, 314794 }
    },

    -- Talent: Teleports you 20 yards forward, unless something is in the way. Unaffected by the global cooldown and castable while casting. Gain a shield that absorbs 3% of your maximum health for 15 sec after you Shimmer.
    shimmer = {
        id = 212653,
        cast = 0,
        charges = 2,
        cooldown = 25,
        recharge = 25,
        gcd = "off",
        school = "arcane",

        spend = 0.02,
        spendType = "mana",

        talent = "shimmer",
        startsCombat = false,

        handler = function ()
            applyBuff( "shimmer" )
        end,
    },

    -- Talent: Reduces the target's movement speed by 50% for 15 sec.
    slow = {
        id = 31589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "slow",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "slow" )
            if active_enemies > 1 and talent.mass_slow.enabled then active_dot.slow = active_enemies end
        end,
    },

    -- Talent: Steals a beneficial magic effect from the target. This effect lasts a maximum of 2 min.
    spellsteal = {
        id = 30449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.21 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "spellsteal",
        startsCombat = true,
        debuff = "stealable_magic",

        handler = function ()
            applyBuff( "time_warp" )
            applyDebuff( "player", "temporal_displacement" )
        end,
    },

    -- Talent: Pulses arcane energy around the target enemy or ally, dealing 748 Arcane damage to all enemies within 8 yards, and knocking them upward. A primary enemy target will take 100% increased damage.
    supernova = {
        id = 157980,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "arcane",

        talent = "supernova",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "supernova" )
        end,
    },


    temporal_shield = {
        id = 198111,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "temporal_shield",
        startsCombat = false,

        handler = function ()
            applyBuff( "temporal_shield" )
        end,
    },

    -- Warp the flow of time, increasing haste by 30% for all party and raid members for 40 sec. Allies will be unable to benefit from Bloodlust, Heroism, or Time Warp again for 10 min.
    time_warp = {
        id = 80353,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "time_warp" )
            applyDebuff( "player", "temporal_displacement" )
        end,
    },

    -- Talent: Applies Touch of the Magi to your current target, accumulating 20% of the damage you deal to the target for 10 sec, and then exploding for that amount of Arcane damage to the target and reduced damage to all nearby enemies. Generates 4 Arcane Charges.
    touch_of_the_magi = {
        id = 321507,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "arcane",

        spend = 0.05,
        spendType = "mana",

        talent = "touch_of_the_magi",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "touch_of_the_magi" )
            gain( 4, "arcane_charges" )
        end,
    },
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "spectral_intellect",

    package = "Arcane",
} )


spec:RegisterSetting( "check_explosion_range", true, {
    name = strformat( "%s: Range Check", Hekili:GetSpellLinkWithTexture( spec.abilities.arcane_explosion.id ) ),
    desc = strformat( "If checked, %s will not be recommended when you are more than 10 yards from your target.", Hekili:GetSpellLinkWithTexture( spec.abilities.arcane_explosion.id ) ),
    type = "toggle",
    width = "full"
} )


spec:RegisterPack( "Arcane", 20230624, [[Hekili:T3ZAtUnUr(BXvQIR0gBzQxZ4DJ0uv292pex3T5Qm791rIJe1igtrQqsn2Ukv63(HgGpWRgaKsA8SjBQuRTjbB0Or)UBa9WWh(ThUFDqr4d)6i)rJ9Vz0KbdNoCYKp8W9fFDF4d3Vpy1NcEI8xsc2r(V)1Svbj0h)140G1WNNNEiBf5rBlk2N)JV)9pfvS9WJdwLU795r7oehueLMSklytb8Vx9(hU)XdrXf)TKhEu)CFdbM7dx9WVEZicuJwVoKn0W8vpCpm035FZ7gn5hpT80YFkmyvAY7lYIs(uyXPLXPpfT60Yd7baV(VCA560KVJ88F550vue50Y9zHVB)H44tlJ2CAjBbDA59hYEI8hr50HNfgS(RNw2ln70YI0NEkoC9PLPB20FWPpE6JmCy67gDdfh(Tphg8jyCnq7NIdYlYpTmGaRTrpTL8Fjpiu8Rhs)6)r47ctcEmouajtpuat4PLpMMtGZgcmkYf)CF6N)lphsg(U0mY3hS(FEiVyxycm1a6ueTdq89zrPzrfKfe5vzrHIaA40s8io4lNwMNUJaP4iyvSknnED6NtkH22W49aiYpatwrwqsEedBJs4x8usP4umMof)prjabLT5ioGr0b8xj71e893g7ZJ0BYs3rGA0UFw4B8zFZ)hfAKrbGEO)GHdE4(4ic1h4ndsdxKLwqjQK)9Vs53zK71p8tpC)kYmeMffa8KB2miGUcwSABaScYli8(Nwo70YrNw61qoguKEy12fPBwuSnCXUGNIgKfUlicOt3rWbIStWk6mEFjatZE8HccBo6S370Y3qiPbXKnObHvSbdkh7PLhpYn9nVxyAjizFkEkaSsmiNUNOhEcdXbqQU81dxlKPAGZt6zib85neX8TrBkIsEAX(0phMbeYXoTnQdwrRcxKK(CaaLjM2oYc3KfMVLjyclly9hT6te8qhElYYmx7l3f8LfLdWHvDsiHSLTOiC3(W8caFNAEvVkoeaxoqQiuAcCOZJiFabt2LM81MDSMrKDa4u3WOYcdOEhvCi17MZOmipTAnSepT87Pcm9vKc2fLNhfhMdRLBCAhSLuvyBAxqsWG9WAFgOoqbjEmildSNrWHBPAieFD4x2hNMtFsd2bu)7lg7FjuLmUsEIoQhJttxhtuAt38LxbePKB91rjTQprpZL4MjQy)KP0bMhwS4X0Kd5dkIcZiR(j7xzvOS61cCkI0sdYDoq5kGNwmyByqCX26n6Xt1WR)y6oYU96DuDQLtxncs8cipmzffj3fLS2bbm5pzWH9xauYIQeasQmXG7foigHOsq9DssycVRwaZOa9TFtvM2R6)thjOZmnliEXNdY2t3L0OzObry7qIm0n7oMSrrFlaMW)1HO97dxpijKWdeqCDjjFXQG44ffPagNMxbiQNClAe3MdwcnP1)dDqAXfsMa5yQp9zg9brdYtu0Bud7p8sG73YW9NjuDyIibEKKhM9m4YrsqZMxJQ2sXwh9tzANw5elpDxYKeUe4OoJ(xITDMGzuQDyxSI5YoeDaLmZe9MRIYzRfCvzdDZAw7rfbMLBSYSi4QlIprcU5I4ueJ1PFBy1g6loA9o6pXVBCKYonJXw0gwvLDyMpSK4bdZYoSVyr0MhUhCmSepN77HXz41RAJ6UX(EMPUKrC8y9WV1VpDborJ)Cm2lr)pgov3alPuYU9brqMVpi7tl2tcHp0SNFK1ZZlGL7Wb8ZVJ(DD70gSImKvHXlaIfBBybl)l6CBbxWXYCckpN6iYn2hZ5ofx)cwhfKuWOAwC9R6BGev8iWBTfSate(O0aNxhZ1gacN4CT8of0lw)iXqqJRiASp0VkHx6Wm7UkQvzfyRN5elhFIe1cnCe7o7PDo16(ie(W9qkEwSI4rmrCWO)BIEWgUABQQ30sUTid8pOrGJUhkXEG7VGnoGAo51HuIHazDXZhItcZcEmkoQ4RC2oM0rt49A58mYrHSBNw7rzBNIHUmfLKj1ak5x2Ts9wLwZAbzzdCpCprsJ8GnWhc6oRn1JgjMK2A8K90kc0igDTvFJHiVgAm7rTAwMGeHbvpu34ggBoOfd7)LM8y7JIM8Q(MDHfHPYb1JBeYTiGngeD5A3G3tGjGs9)MyUDlXHT3htygjorgMeUlkSmSUABou6jD5Tyv6He9Udq0jlUAc)s4QdfKVmAxOPLeMjvv362saorJSRo41to5f8Q(1pcLSlc8ULdHSaRqBHGR7RZC6zUiQm4wPwSefio7)ppKX81FXtH70NKtqFv9ikle0lm5OJw6hP1sVrJ7DMT3elPoZ9gsS6LtvtVwQQGTJW0RIKAB(b33Grl7kxWsF4fClOY4KrBt8GSIdTkhzkSWTxDD)kpVB1oHj2Px3khCqETv5brwwfD1AkiB(qPXrbNTdyFR8ordwYjxvH3VrLh32gIQdDXW)d6ghsi8FBQAtlkf64UvKN)OOXcirDfUuZm2qUmR01Qj)nOEuwku2RW6r1TsuJQJ(mQhfUk5)OEuNv9OUc(ssrKxI6r9IulTxL1JYsL4ETuoklvnRltyd62k3WUAvg7pkhflnJY(1G7vV7SQDOCuU4PS3B0gx)d1zN0bhw1xDkepwjCljRj2Lxu3bMD1312knYYkVg3ormiym7W5SEQvXRdXAiuxRGPU7mwtcsTXodrOjNob7UwDEtJk3oUFrUilAQ(wxGTELY5H770RaSTzpe3tKluHkkGsmSj4qCHoXpOF0ZI2Za3VWc(LOmo85WSVEAjlkycWPjhg6n5icTj45GOyQM(gmHMt4WS89HXXMd4dl4lbMV9P0)uJOu1iQ1JlTg(TTaksrtYMbHOdm(7cdy97DeX7sIAxYF7RPhi67jlKt02ch6NEgijV7ZrfBHE1E)wOVWju5SDdEqTya50bq2AH3Z7rhJSnt14J0sUPGwtnloxf(PGl4kH6e(LTbexX4CWPh(CtZimyZvYMhW4pXNlNI60IO5B(Gy4)ajGIMoeqLWmuham9vI(bu)o0u5WmvwHeX0dCWI)5H1pbbhAwRW1fvEm4j6BZibOzVvdnzf6nMcjtVF595lbh6Mk6kPSvcQxkeX8WmimtZrJGSi4aeGKl2Ci7RMDU3kG2eLfsbMf3VTciOFvYlakkeMPfpOzXgBzRsx)hZVBu)5Ju)CJBiEgGDd4Hf25vspb9fEcRxrVOe4raRqe60UCJEjxMTAIhIBJIJFko9XqEcSq2iVzkxKe1lHCYqtJwVO8OtTOkLb1ea7P6BKVIrDv9ZGICADTkBOgDyEHH2t7r6j8cYBbSj(y4xtHweOzP(nBnvTG0IGfA6qGQveXZ(pTlfAdPWvFArgT(UVIwpAqVIQMMZ6QznOh4v8YHHFW6r2CM(1tuYMWSK0xXROkmewty1oI4M3(WmIdAKr)C6NiwHiQTwh(LxxllmKewzY2kRwzrRyMVi0IGIT5jbzVU4(0HFW6b3KTSdI6kRpxKLJSKYmeFVm4YMr3YQSK0tt(RRFJtrjcvLXSTyxRleqIMA1RHgl7Tad9VCyOVlyONezvIz47fAzXM44a(alzhQl(GBJtXEWzs4pJauv)8YG8ZvMMusi0WPlxkqa5k0tx2w77msmRRcwRPqkvtQUcpnRQNn15YpxUi4XemhyQhKOEjhqpuNUftz2iJT7HTnP5kPQbp(v53uVrvgQKNu(Q1hMVd1LEYuo45U8k)czsRKqlvU33G8UNAmbZmesaKfxsiRGYEowyOeCS)Xc4qQZoQ6L92pCctF8qg5FZAgkyR1HehIATACTo5MIdW39O8PYyDAHYllHe912B(ubwaxi5AYt4469mZru)TExAxuseD7bpNivvSrGMYlClGs8NWKwJrYaaqmRTZVdi2zHuYieEYoSfRERceV9iQC3odilU3zTfznX7zYHG2VoKwdJX9lSgHYs331T3MpfMlCFp4QDjkdNRL4SvmcuFWB7QstD3GLhUpgTcLAp(iC9LaycE1XUqmr8xYbWeILddlmh1qOGM6WvqBg1ueLkGuA5ckpBCC4k5sMosZy3eSJyUjqULGfQcRIFIIJvEjLUNs9GsdxbHQTq6FRCrLUNSlNbQ(PawJk1suuQRVbyeFGWJedYzJ8H)x5Zi)ZrtH)zHAI(lXk94e9BR7XNNIbrlIpw5Kadx)uOulafLfTo8q(InKqgHC5l96qOW4G)NKOVjlwKrLVpnkoheml7OOd5sJOiDhvW9qcrkIGNmjy5bPEA6KgX20SeamKfj043n0FSW3bINSz4wq80IrEgiF84ub3PjeWdHBuKDrzzPzlI2PuHFLm)lXKx2)aIfyCDeT8Iqf3cEMqioT8ZSyweU3OEmS4ZHWncv(Ua4kUcUORYnDtxfsV)OOEcoGEzwrlcyqCompRO6TYlVCLyxew5d0RF3bF9r9uLDkbXT6Ayk0hoCHOdigBEc(E)J39hMaFtuG8fgQzwrp5JtMQOdZ0LIcUMDDiKTsnOPswLPwqYgLKwTMpgVnIecYcH3vJAwPXzUR9DAtajeEh6RuGeiDMmrc(zwvd3rHL((lsJ27wTyTCOHKYcr17BYuXWPCrk7iLRpxW8iup3in9nYp2m0X(1kQRfhmCqXXYK9f)GIp(K1Z6nEOlLU)bbplxrpYmXNs06u5mrKC6e1BU8HROC3RgOtLbAFufug1Zk4jU4hQpXukRgzmtUuNkIgSmAvyS4Z9AfoDdco16fNjQAtxizOm3Gmv5o2D8PzZtE)CMtzyHpnQ90CCn02m)WkxZbcGExeWNKTwqxuiWWCCUK2QGHlbcJ(QAKx2kJHBnghOOn9EM5BcaCJZODAwfDLbvPxoGyUDtSANa5pOm9RC9Ok3B4BsihAFTR0nIstO)YXZzY)g89josOeaW20B12r9fWcx)I448GNxDNMNXUop6O(Lz6xGgINTrNWNjUIpwtEy5hOCcOTyp0KrjHd(N2J9RZh5V21htDTZqLZwFBVyG6Y0Aqk6nozcrUvM1wpajhovo)xAEjEdLxEkgXfzVSiEpl4(OAFb68suRlBcxFdcg77Fs39THDvmMCn)6qZ0gDdxCckVxBP3mFVV256zPuNYhqIJWv9KQUH3zocmMEC9OUVyr1zkNPb8Ou61bFFh1wh71TXx7BVCehognNPgeT315E9Y2jqRZTrH9KGnAeMNuMJYWER5kAX5c618yft2M9wUNt6TQsstve0U)jZ4l7pug6MaWMjg)L7WCodM4QWnCtqz)EtqRK(EnNfCL(VuIXu(BU8huZMfmwRtkRVxghrmW4HMhQZ)O7rXxDx03AcdQGR4(kH2yixvwlpOT8dHBvssLR4zc3sAEUq3BA(6KXTKC3ANB1QLIbMAHudMuKipkgLeipJ1yYQVCVsHlf9QosEJ3Mb)owRQyIOB1b024PaQvkE5WGlWTaLLA79V53FpAdsxxgN8DnAEQE5NdZO3Dy1)sb9W9FoilHSqZHZTiuot48CvuwPYVJVXj(oO8M)Rdrza6Y(5Tj4qr6UaA9ujiFYt0FrC(VP)M3a)OY8ZPjKjK(6VRq6(N47yLGv55vueY77n8l9TbpEp1KaPGdITdQkBWsGwLbab(tnI1LLGspElv)khHSGGNeG12sqnW90h1WaW3ilTJbyIXLoxo21V81KeEhjbxWz4w9ZGO7dsqx)9nJmK)Wfw8yicN8LMFqQhjBhlbc5SC)aYcQ(Dk(8J6a(X1bFTd)mRJ5sWqzwOOTuaxG55OJbbYCx5MsGvZLXPJcTY9AMeGXUubDe6Nf99fxhEhPV61F3vzHVzQVVqCci6AKDatc6y(NzHk3nlK)Hlsa8hF1z0U(SY3C18taHnUZ8idh(Y4NGAhGFrKn6OICTOy5vst7WleUv(oQuEFwtZw6ihQWLRHS8LUlIffzxeYO0HLtwfR(JsNcWrOfxgGJqsotc9iejvHmTiZ(luUpmaJiOE2aEmMa7vdWxynb1T5s7e0EbIvOkj1TdXqIC764yHuZrCrWuXKdlHN6RPPnL9DnGWRNR1)WvyTxAb1)3LGgrA)c6ee2uCfX(RiOzfxrcKIDtPfPI9vNxR2jtC9cNhrFWzAsfrsRZq90h)BuYiaSHJRkxe8tPEo9xU9hUNq82cD1291)Q4)ZWVk(qzes3efxxX(8b1Bb)55VVKgvFi5o9rdJQ64XPFqYXGE6J)P)ufIkoYQ(Q4TqZsmx(Gm(209Zb7cfVT0x05JDfucxWTaCaOqptwZ91J0IFV05vPecrBElbWRP)A0pxlVv5CWoVDVT5e5nNDG8CzQXoaAIRc0tL3XJOhPmUxHCA84gHMtIh3B1Fk84hGAFVW9wHtFNleLcU(UbHqOzg9WpCIANt(JshHt70YxrNgoJYJ0sF92OnZFJgDihpASPGUB4u9WUoyzaWAGlOlcOrT9kjTE2MZFLKw)uYmZUBrHP10bqdM8R1Djkp2yJo4bl4zd5(XevhzE2uEywF5BYbtHqwzLJv4(c1RNbQXXJc3boZMpX)4r((UP62vXtACFWVppIjDHCcONkuaCWdPp18m3JACtLWfU5vDIQVomHzPNAhyqNmV30JbVqXRSt28Z3EF97F8ypT0wdxBdcu5M7vtaJqqi(pO((Z0XXlEnzA8JadQ)AkrPu(H9vow84xReGxVon5VasrjjWyiM)kYsJz62cipAl0Fq7Jd(k8NpLfqvC9)YABO)wYMd0MiqWQnb7yx8Alc)cr4pjG9ZpltppD7fUR5OFiVgnHG29CGeuFbxs30X311DJgaBWCTdKWhyyp2tlSaGbOvZf4WDZrV8gqvIqKX9qBHP(mk8V93)V(7)ipHUIguAefCOiBbyKSylNLDl6APkkqLcreADw4uef1CRDcOwDFQCZuVEVX6vThHGB2K3iFn4DLkXH(97JJH6UgoP8PxFSchPuVlnFLHs07dZxz4u5nA53ESc5cP8BoIP5sL8fdNenyOgNixo1eJhyiGIURUThBsQWe481uEDbENKdu8D18DZh3NOiQY0eVwroVTL7YpIk8(EMoMmE2VpZMnVxzhc(9JohYKpqMeilCd1ZHgSKPLh76CB2T4luwRaAe1nV7AyxXtCNFMHn(VX7E32xVRhDKWiUF(AAVSUahA2j1Tf4P3JptB6M2ZCMJOtRckz3GhHhpQLnZ8CXs(u1ezEc8KUioAsYL4mScmaxDvAvPImL)EXes0kXHqsusnTf88FyQNUukCwqVxn4fcf97NqKi6j8O7Sgu9qbZxLdPSfGa8qmy3rOH1Fj9U1Rx9keYkqVEoOxy4u9XoWPpc)JhnfjkgiYdNMD)Zz29XM9A(OzsB08BdYjl20UHzYoYELzgibmZ7nY3zWcav4(cw2TjE8VuIrQw(myPEpbnBKgu)WE0jO8KMmFkF4XYZLXW9lJt8Fe(CuEee5p96770YnXbpDAjKfmcLfsBgbYzr8jFKkRlEL8vgBPyLyFldKmT8MDgC28AhA0NXkXNYDxaZ5cgs(ovU1FVBY0(UjrwHutCskG4rBFTYqTW8JlKyOE8c0wZ(zp2NlPHACz54ruR(Kxz3Xb6EGDQdNBpJ7xdyTzj7AteLDkMNwQ1VdmFKTpvDBAA1ui1o3ctJjNgePNgIpYokC(tVbN0r8q2go14Sgpgvpn1V2oKu7tpbqQ3vvSqlCMQ33oIXFYJeqjNNe7Zb)HBryo66UcduqDJkh7a(LrJdCKOWnfNhXGPDDo3n8dOtJyVLsnrvTLvBXWOvKHJ4S9WR51AT24)qfC3jlnai07Qd66nAv4IK0NdKjQo8PI5zMsQ4(vTgcVHDNw2hnanDBJ1N(72Uskhz1PBSEbPEMe90wFEpTrCIg)iZ6LqgxmJyCHE0j6XXJCHoyBYc)Y(40CnsuC2qMxgAgmPLLyrQv7aCvZHsgQOSzFNV72POtlbjfOLwDvz2TtTmBJ9noB8AGnnq5sIO00a2rv(uWXxoc(MuGizq3NfQBOj8sEp1wIU2JDy(Tph2uVoUoeJHg3Hv1nikZb9AQJGsngf8X(5GOI3MhUAU)a)Pw3TiCPAcgIXExPiwrKGhPBjYGe415asRcoo4Pot1Zy3wYw3N4uZD5qUjTBI75mGhzvpgKOeNb3qlPuGaotRefl7VL7EyG5FLg(1Y7icdWvEh1fQzvBd58AFKtHfwYS5cg0L9ZjAZxsR2dhJ44rFAtnjjEYfIZF2Pgn0u4pvmD)qvEWFxT9dXFv()iokuEZMyyeQKxrvZC9RSNY126SXtXt1MCwBAhw0jNICpCvfjtU7lVzZfU5jSJ2U4KzpvlEYpR0ZZJhlFm3HuTF)3sVulMp8SrhMFbdR8VvoRQneg(ujYsc0l5IWMRhJCagNl7KdtHwpRRtBWCPA5OmanAy5Dx7S(A(x5X1JsxdOoUfqT01TlY8oXL51fVpR0COEZyX3g48qvw1QU1HSTy(XCEw35HzBtkYyVEsrCaY7nbuE3T(oLFHXCTeYG)9pPjEsvCCQ2fVUGMnStO1KkQfyt761cn0ztgnGKP2U5cnnnZgBcnCXwiIrjnJxJQ4xWuo1RN(g9vi3lnfUxKVhJnQp3PBOPTkZPTFl0SGeSinVVeZ28HJmU3FMg6AQ)6uFpfzvjCzK)ldQCRVNEhEv7ZAxYY70wTmCNnoLiLLuKX0Gv1e4TDv7UGDBHmdF0CBT9YSjEd6MyRBRQYTX(USzZ3oiAkTR)1Hxq71j6B5Vw9OXcvoRoER659gToyBLJXH9xE3iSLWUkDPYTrKQWyDcIMmfd8ioTzo1dYtmMRaqGkQAias9DYWO(y7X(a9CC1133cIYZMyLiPXgOrBJ3XNBk9nF3utmHkbEzDjOVQi8s9B5)HFcAmPE9SUU7x2JgAw52wE9TKnTX(2wLiP)(kM2)XIDER0u1Mt3cww8Tquerfxf2nemKh3bKzs7qf(SQq4dQbJ0V9oO4jpufIQqeh9WWp(5u5Q9fzozr5rNnlt2nktMv8RLl8AnH133T3b2t84PRZCiXMLBikHyX58pK(gPGfUB(yOJOAhvOX5yxPb1M7QIVgx8rP8hIFABX1USJPTyi2YFTdBrk15qeMNtUdKpidpIDVrpJqxhD8iNhl0N4exQTXOX)dL(NrJeFNCg1YCiP9tONjrkrNNA(JSmjnQr4X0Qcsy2Jw6jy2fYeIx7xQzbVm9U0oFJ6yq4otyFnGnNJCjVWGupYE2qMxhQkSDOovLvGYegwoNLjF8noOKJNLutlNINak32HqrXM7aHlas2dflhjD2VDEjyQ2u3vvnnUtEk(k1LixVCebTrEu6VVY7QKjRwoMwnctPdUFxlL7ajQKFf196oTdAAEv922TvJ2WQrxwnojB1NMrU7LSXDjNcCcZIA3AoknSkYgPy82T9eIyUmdJgztLANA2hRBQCg4rGNjG0yQ0bjEMPWXUGuvAtDUNkUZ35w9zgCOk6vhVdOTW5VD(eJCk6kuth6Lb70fki1vpMZ0de316RvXmwgOo38v6acwgIGQqeCOvCZHeh2SArJZWn3i5iIBeTmDjywweuZkv6iTZBhKF91cijTjyr8WMp(73ezZbE9WmIWT4K(vqs2VLsC6C8V9cgrRgQuT6TxH636J5DLSyy5AsNoVE2KJQv6voz6B9956DKtKy6I)OwXN74Z3vtcMKxB1nB0LvHMgUdheYKdU7Q00g9rNd1oYGFE4AXbZ(9mr)zpgDArkZJ0O0XuAGm0UUyWgz3Uv62nFo11e6rfxeouFoNhd26CcPP9)q7Ece(GlwfVBzhuCTrNxWUO4CzRVWDsHlc8Tf6oAK4AUH(7VoQ4m5lADxvGThXDFIm23Yr5JmchTTYZxzDqnEdie6Z32JnG5JmG4BFH9GuBxDB1KDNKWSnRCN)eEWSTSjia7A9WDlqNxe973LdpHwS7Q1Y)QTuHd7jM1p2E8)1FGbO0eBJHXvr)nf9H))d]] )

