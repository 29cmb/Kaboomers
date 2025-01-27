-- Atlases
SMODS.Atlas {
    key = "kaboomers_jokers",
    px = 69,
    py = 93,
    path = {
        ['default'] = "j_kaboomers_atlas.png"
    }
}

SMODS.Atlas {
    key = "kaboomers_tarots",
    px = 63,
    py = 93,
    path = {
        ['default'] = "t_kaboomers_atlas.png"
    }
}

SMODS.Atlas {
    key = "kaboomers_enhancements",
    px = 69,
    py = 93,
    path = {
        ['default'] = "e_kaboomers_atlas.png"
    }
}

SMODS.Enhancement {
    key = "flaming",
    loc_txt = {
        name = "Flaming",
        text = {
            "{C:mult}+#1#{} mult",
            "Increases by {C:mult}+#2#{} mult every",
            "time this card is played",
            "{C:red}Has a 1 in 8 chance{}",
            "{C:red}to destroy this card{}"
        },
    },
    atlas = "kaboomers_enhancements",
    config = {mult = 5, increase = 1},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.mult, card.ability.increase}}
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then 
            card.ability.mult = card.ability.mult + card.ability.increase
        end
        
        if context.destroying_card then 
            if pseudorandom("kaboomers_fire_destroy", 1, 8) <= G.GAME.probabilities.normal then 
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Burnt!"})

                for _,v in pairs(G.jokers.cards) do 
                    if v.label == "j_kb_kaboomer" then 
                        v.ability.x_mult = v.ability.x_mult + v.ability.increase
                        card_eval_status_text(v, 'extra', nil, nil, nil, {message = "X" .. v.ability.x_mult})
                    elseif v.label == "j_kb_blue_kaboomer" then
                        v.ability.chip_mod = v.ability.chip_mod + v.ability.increase
                        card_eval_status_text(v, 'extra', nil, nil, nil, {message = "+" .. v.ability.chip_mod})
                    elseif v.label == "j_kb_yellow_kaboomer" then
                        v.ability.money = v.ability.money + v.ability.increase
                        card_eval_status_text(v, 'extra', nil, nil, nil, {message = "$" .. v.ability.money})
                    end
                end

                return {
                    remove = true
                }
            end
        end
    end
}

SMODS.Consumable {
    key = "explosive",
    set = "Tarot",
    loc_txt = {
        name = "Explosive",
        text = {
            "Enhances {C:gold}2{}",
            "selected cards to",
            "{C:red}Flaming Cards{}"
        },
    },
    atlas = "kaboomers_tarots",
    config = {count = 2},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.count}}
    end,
    can_use = function(self, card)
        return #G.hand.highlighted <= 2 and #G.hand.highlighted > 0
    end,
    use = function(self, card, area, copier)
        for i = 1, #G.hand.highlighted do --flips cards
            local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() 
                G.hand.highlighted[i]:flip();
                play_sound('card1', percent);
                G.hand.highlighted[i]:juice_up(0.3, 0.3);
                return true 
            end}))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do --enhances cards
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() G.hand.highlighted[i]:set_ability(G.P_CENTERS["m_kb_flaming"]);return true end }))
        end 
        for i = 1, #G.hand.highlighted do --unflips cards
            local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() 
                G.hand.highlighted[i]:flip()
                play_sound('tarot2', percent, 0.6)
                G.hand.highlighted[i]:juice_up(0.3, 0.3)
                return true
            end}))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
        delay(0.5)
    end
}

SMODS.Joker {
    key = "kaboomer",
    loc_txt = {
        name = "Red Kaboomer",
        text = {
            "Gains {X:mult,C:white}X#1#{} mult",
            "for every {C:red}Flaming{} card destroyed",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive}){}"
        },
    },
    pos = { x = 0, y = 0 },
    atlas = "kaboomers_jokers",
    soul_pos = { x = 0, y = 1 },
    rarity = 4,
    cost = 30,
    config = {x_mult = 1, increase = 1},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.increase, card.ability.x_mult}}
    end
}

SMODS.Joker {
    key = "blue_kaboomer",
    loc_txt = {
        name = "Blue Kaboomer",
        text = {
            "Gains {C:chips}+#1#{} chips",
            "for every {C:red}Flaming{} card destroyed",
            "{C:inactive}(Currently {C:chips}+#2#{C:inactive}){}"
        },
    },
    pos = { x = 0, y = 0 },
    atlas = "kaboomers_jokers",
    soul_pos = { x = 1, y = 1 },
    rarity = 3,
    cost = 9,
    config = {increase = 50, chip_mod = 0},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.increase, card.ability.chip_mod}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.chip_mod
            }
        end
    end
}

SMODS.Joker {
    key = "yellow_kaboomer",
    loc_txt = {
        name = "Yellow Kaboomer",
        text = {
            "Gains {C:money}$#1#{} at the",
            "end of each round for every",
            "{C:red}Flaming{} card destroyed",
            "{C:inactive}(Currently {C:money}$#2#{C:inactive}){}"
        },
    },
    pos = { x = 0, y = 0 },
    atlas = "kaboomers_jokers",
    soul_pos = { x = 2, y = 1 },
    rarity = 2,
    cost = 6,
    config = {increase = 1, money = 0},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.increase, card.ability.money}}
    end,
    calc_dollar_bonus = function(self, card)
        if card.ability.money > 0 then return card.ability.money end
    end
}

SMODS.Joker {
    key = "green_kaboomer",
    loc_txt = {
        name = "Green Kaboomer",
        text = {
            "{C:green}#2# in #3#{} chance to",
            "retrigger all {C:red}Flaming{}",
            "cards {C:gold}#1#{} additional times"
        },
    },
    pos = { x = 0, y = 0 },
    atlas = "kaboomers_jokers",
    soul_pos = { x = 3, y = 1 },
    rarity = 2,
    cost = 6,
    config = {repetitions = 2, chance = 1, maxchance = 4},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.repetitions, G.GAME.probabilities.normal/card.ability.chance, card.ability.maxchance}}
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and not context.repetition_only and context.other_card.config.center_key == "m_kb_flaming" then
            if pseudorandom("kaboomers_green_retrigger", 1, 4) <= G.GAME.probabilities.normal then
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Again!"})
                return {
                    repetitions = card.ability.repetitions,
                    card = context.other_card
                }
            else
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Nope!"})
            end
        end
    end
}