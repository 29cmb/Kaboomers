-- Atlases
SMODS.Atlas {
    key = "kaboomers_jokers",
    px = 69,
    py = 93,
    path = {
        ['default'] = "j_kaboomers_atlas.png"
    }
}

SMODS.Enhancement {
    key = "flaming",
    loc_txt = {
        name = "Flaming",
        text = {
            "{C:mult}+#1#{} mult",
            "Increases by {C:gold}#2#{} every time this card is played",
            "{C:red}Has a 1/8 chance to destroy this card{}"
        },
    },
    config = {mult = 5, increase = 1},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.mult, card.ability.increase}}
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then 
            card.ability.mult = card.ability.mult + card.ability.increase
        end
        
        if context.destroying_card then 
            if pseudorandom("kaboomers_fire_destroy", 1, 8) == 1 then 
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Extinct!"})

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
            else
                card_eval_status_text(card, "extra", nil, nil, nil, {message = "Safe!"})
            end
        end
    end
}

SMODS.Joker {
    key = "kaboomer",
    loc_txt = {
        name = "Red Kaboomer",
        text = {
            "Gains {X:mult,C:white}X#1#{} mult",
            "for every {C:red}Flaming{} card destroyed!",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive}){}"
        },
    },
    pos = { x = 0, y = 0 },
    atlas = "kaboomers_jokers",
    soul_pos = { x = 0, y = 1 },
    rarity = 4,
    cost = 36,
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
            "for every {C:red}Flaming{} card destroyed!",
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
            "{C:red}Flaming{} card destroyed!",
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