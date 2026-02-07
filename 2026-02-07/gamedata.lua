-- gamedata.lua
-- Central databas för animationer och speldata

gamedata = {}

-- Animationsdefinitioner
gamedata.anim_defs = {
    -- Slime-animationer
    player_slime = {
        body = {
            idle = { frames = {84}, speed = 30 },
            walk_down = { frames = {84, 85}, speed = 15 },
            walk_up = { frames = {84, 85}, speed = 15 },
            walk_side = { frames = {68, 69, 70, 71}, speed = 15 },
            game_over = { frames = {76, 77, 78, 79}, speed = 4, loop = false },
            victory = { frames = {84, 85}, speed = 8 },
            sad = { frames = {84}, speed = 8 }
        },
        drip = {
            idle = { frames = {76, 77, 78, 79}, speed = 10 },
            walk_down = { frames = {76, 77, 78, 79}, speed = 10 },
            walk_up = { frames = {76, 77, 78, 79}, speed = 10 },
            walk_side = { frames = {76, 77, 78, 79}, speed = 10 },
            victory = { frames = {76, 77, 78, 79}, speed = 10 },
            sad = { frames = {76, 77, 78, 79}, speed = 10 }
        },
        headgear = {
            idle = { frames = {0}, speed = 999 },
            walk_down = { frames = {0}, speed = 999 },
            walk_up = { frames = {0}, speed = 999 },
            walk_side = { frames = {0}, speed = 999 }   
        },
        face = {
            idle = { frames = {121}, speed = 999 },
            walk_down = { frames = {121}, speed = 999 },
            walk_up = { frames = {0}, speed = 999 },
            walk_side = { frames = {105}, speed = 999 },
            game_over = { frames = {86,87}, speed = 10 },
            victory = { frames = {89}, speed = 8 },
            sad = { frames = {73,74,73,75}, speed = 10 }
        }
    },
    opponent_slime = {
        body = {
            idle = { frames = {116, 117}, speed = 30 },
            walk_down = { frames = {116, 117}, speed = 15 },
            walk_up = { frames = {116, 117}, speed = 15 },
            walk_side = { frames = {100, 101,102,103}, speed = 15 },
            game_over = { frames = {118,119}, speed = 10, loop = false },
            victory = { frames = {116, 117}, speed = 8 }
        },
        drip = {
            idle = { frames = {76, 77, 78, 79}, speed = 10 },
            walk_down = { frames = {76, 77, 78, 79}, speed = 10 },
            walk_up = { frames = {76, 77, 78, 79}, speed = 10 },
            walk_side = { frames = {76, 77, 78, 79}, speed = 10 }
        },
        headgear = {
            idle = { frames = {0}, speed = 999 },
            walk_down = { frames = {0}, speed = 999 },
            walk_up = { frames = {0}, speed = 999 },
            walk_side = { frames = {0}, speed = 999 }   
        },
        face = {
            idle = { frames = {120}, speed = 999 },
            walk_down = { frames = {120}, speed = 999 },
            walk_up = { frames = {0}, speed = 999 },
            walk_side = { frames = {104}, speed = 999 },
            game_over = { frames = {0}, speed = 4, loop = false },
            victory = { frames = {88}, speed = 8 } 
        }
    },
    neutral_slime = {
        body = {
            idle = { frames = {80, 81}, speed = 30 },
            walk_down = { frames = {80, 81}, speed = 15 },
            walk_up = { frames = {80, 81}, speed = 15 },
            walk_side = { frames = {64, 65, 66, 67}, speed = 15 }
        },
        drip = {
            idle = { frames = {76, 77, 78, 79}, speed = 10 },
            walk_down = { frames = {76, 77, 78, 79}, speed = 10 },
            walk_up = { frames = {76, 77, 78, 79}, speed = 10 },
            walk_side = { frames = {76, 77, 78, 79}, speed = 10 }
        },
        headgear = {
            idle = { frames = {0}, speed = 999 },
            walk_down = { frames = {0}, speed = 999 },
            walk_up = { frames = {0}, speed = 999 },
            walk_side = { frames = {0}, speed = 999 }   
        },
        face = {
            idle = { frames = {120}, speed = 999 },
            walk_down = { frames = {120}, speed = 999 },
            walk_up = { frames = {0}, speed = 999 },
            walk_side = { frames = {104}, speed = 999 }   
        }
    },
    headgear = {
        [1] = { idle = { frames = {9}, speed = 999 }, walk_down = { frames = {9}, speed = 999 }, walk_up = { frames = {9}, speed = 999 }, walk_side = { frames = {9}, speed = 999 } },
        [2] = { idle = { frames = {25}, speed = 999 }, walk_down = { frames = {25}, speed = 999 }, walk_up = { frames = {25}, speed = 999 }, walk_side = { frames = {25}, speed = 999 } },
        [3] = { idle = { frames = {41}, speed = 999 }, walk_down = { frames = {41}, speed = 999 }, walk_up = { frames = {41}, speed = 999 }, walk_side = { frames = {41}, speed = 999 } },
        [4] = { idle = { frames = {57,58}, speed = 999 }, walk_down = { frames = {57}, speed = 999 }, walk_up = { frames = {57}, speed = 999 }, walk_side = { frames = {57}, speed = 999 } },
        [5] = { idle = { frames = {12,13,14,13}, speed = 5 }, walk_down = { frames = {12,13,14}, speed = 5 }, walk_up = { frames = {12,13,14}, speed = 5 }, walk_side = { frames = {12,13,14}, speed = 5 } },
        [6] = { idle = { frames = {28}, speed = 999 }, walk_down = { frames = {28}, speed = 999 }, walk_up = { frames = {28}, speed = 999 }, walk_side = { frames = {28}, speed = 999 } },
        [7] = { idle = { frames = {44}, speed = 999 }, walk_down = { frames = {44}, speed = 999 }, walk_up = { frames = {44}, speed = 999 }, walk_side = { frames = {44}, speed = 999 } },
        [8] = { idle = { frames = {60,61,62,63}, speed = 3 }, walk_down = { frames = {60,61,62,63}, speed = 3 }, walk_up = { frames = {60,61,62,63}, speed = 3 }, walk_side = { frames = {60,61,62,63}, speed = 3 } }
    },
    -- Power-up animationer (objekt på marken)
    hat = {
        [1] = { body = { idle = { frames = {9}, speed = 20 } } },
        [2] = { body = { idle = { frames = {25}, speed = 20 } } },
        [3] = { body = { idle = { frames = {41}, speed = 20 } } },
        [4] = { body = { idle = { frames = {57}, speed = 20 } } },
        [5] = { body = { idle = { frames = {12}, speed = 20 } } },
        [6] = { body = { idle = { frames = {28}, speed = 20 } } },
        [7] = { body = { idle = { frames = {44}, speed = 20 } } }
    }
}

-- Definiera mallar för våra slimes och power-ups
gamedata.creature_templates = {
    player_leader = {
        anim_ref = "player_slime",
        speed = 1.0,
        move_duration = 8,
        layers = {"body", "face", "drip", "headgear"},
        draw_config = {
            {layer = "body", ox = 0, oy = 0},
            {layer = "face", ox = 0, oy = 0},
            {layer = "drip", ox = 0, oy = 0},
            {layer = "headgear", ox = 0, oy = -4}
        }
    },
    opponent_leader = {
        anim_ref = "opponent_slime",
        speed = 1.0,
        move_duration = 8,
        layers = {"body", "face", "drip", "headgear"},
        draw_config = {
            {layer = "body", ox = 0, oy = 0},
            {layer = "face", ox = 0, oy = 0},
            {layer = "drip", ox = 0, oy = 0},
            {layer = "headgear", ox = 0, oy = -4}
        }
    },
    neutral_slime = {
        anim_ref = "neutral_slime",
        speed = 1.0,
        move_duration = 8,
        layers = {"body", "face", "drip", "headgear"},
        draw_config = {
            {layer = "body", ox = 0, oy = 0},
            {layer = "face", ox = 0, oy = 0},
            {layer = "drip", ox = 0, oy = 0},
            {layer = "headgear", ox = 0, oy = -4}
        }
    },
    hat = {
        anim_ref = "hat",
        speed = 1.0,
        move_duration = 999,
        layers = {"body"},
        draw_config = {{layer = "body", ox = 0, oy = 0}}
    }
}
