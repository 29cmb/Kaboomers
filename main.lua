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

}

SMODS.Joker {
    key = "kaboomer",
    loc_txt = {
        name = "Kaboomer",
        text = {
            "TODO"
        },
    },
    pos = { x = 0, y = 0 },
    atlas = "kaboomers_jokers",
    soul_pos = { x = 0, y = 1 },
    rarity = 4,
    cost = 20,
    config = {extra = { x_mult = 3 }},
    calculate = function(self, card, context)

    end
}