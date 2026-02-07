
-- Slime-tåget - Huvudfil

-- Listor med Creature-objekt
player_slime_train = {}
opponent_slime_train = {}
neutral_slimes = {}
hats = {}

-- Nya datastrukturer för spår-baserad rörelse
player_train = {}
opponent_train = {}

-- Spelstatus
game_state = ""
current_level = 1
level_timer = 0
slimes_to_collect = 0
game_over = false
winner = nil
player_powerups = 0
opponent_powerups = 0
hat_pool = {}
MAX_HATS = 7
BASE_MOVE_DURATION = 8
HAT_SPEED_BONUS = 1 -- Hur mycket varje hatt minskar move_duration

-- Screen Shake-variabler
camera_shake_timer = 0
camera_shake_intensity = 0

-- Funktion för att skapa och initiera ett tåg-objekt
function create_train(template_name, start_x, start_y, start_dir)
    local train = {
        creatures = {},
        path = {},
        is_moving = false,
        move_timer = 0,
        direction = start_dir,
        buffered_direction = nil
    }
    
    -- Sätt initial hastighet
    update_train_speed(train)
    
    local leader = Creature.new(start_x, start_y, template_name)
    add(train.creatures, leader)
    add(train.path, {x = leader.tile_x, y = leader.tile_y})
    
    return train
end

function _init()
    game_state = "start_screen"
    init_start_screen_slimes()
end

function _update()
    if game_state == "start_screen" then
        update_start_screen_anim()
        if btnp(5) then -- Knapp O
            game_state = "level_intro"
        end
    elseif game_state == "level_intro" then
        if btnp(5) then -- Knapp O
            game_state = "gameplay"
            setup_gameplay()
        end
    elseif game_state == "level_complete" then
        if btnp(5) then -- Knapp O
            if current_level == 5 then
                game_state = "game_victory_screen"
                init_victory_anim()
            else
                current_level += 1
                game_state = "level_intro"
            end
        end
    elseif game_state == "game_over_screen" then
        if btnp(4) or btnp(5) then
            -- run() -- Starta om spelet (gammalt)
            
            -- Starta om den aktuella nivån istället
            game_state = "level_intro"
            -- Vi behöver inte anropa run() eller _init() eftersom setup_gameplay() 
            -- rensar och sätter upp allt korrekt när vi går in i gameplay.
            -- Men vi måste återställa vissa saker som inte setup_gameplay rör.
            camera_shake_timer = 0
            game_over = false
            winner = nil
            
            -- Om det var nivå 2, se till att vi inte nollställer current_level
            -- (vilket vi inte gör här, så det är lugnt)
        end
    elseif game_state == "game_victory_screen" then
        update_victory_anim()
        if btnp(4) or btnp(5) then
            run() -- Starta om hela spelet
        end
    elseif game_state == "gameplay" then
        update_gameplay()
    end
end

function _draw()
    if game_state == "start_screen" then
        cls(0) -- Svart bakgrund
        
        -- Rita animationerna i övre delen
        draw_start_screen_anim()
        
        print("THE TRIAL OF MASTERS AWAITS.", 15, 60, 7) -- Flyttade ner texten lite
        print("DO YOU HAVE WHAT IT TAKES", 25, 70, 7)
        print("TO CLAIM THE TITLE:", 35, 80, 7)
        print("SLIME MASTER?", 45, 90, 7)
        print("PRESS O TO START", 35, 110, 5)
    elseif game_state == "level_intro" then
        cls(0)
        if current_level == 1 then
            print("TRIAL 1: THE TRIAL OF GATHERING", 8, 50, 7)
            print("GATHER 20 FOLLOWERS.", 28, 60, 7)
        elseif current_level == 2 then
            print("TRIAL 2: THE TRIAL OF THE RIVAL", 8, 50, 7)
            print("DEFEAT YOUR RIVAL IN A DUEL.", 12, 60, 7)
        elseif current_level == 3 then
            print("TRIAL 3: THE TRIAL OF THE MAZE", 10, 50, 7)
            print("GATHER 20 FOLLOWERS.", 25, 60, 7)
        elseif current_level == 4 then
            print("TRIAL 4: THE TRIAL OF RANDOMNESS", 8, 50, 7)
            print("GATHER 25 FOLLOWERS.", 15, 60, 7)
        elseif current_level == 5 then
            print("THE GRANDMASTER DUEL", 6, 50, 7)
            print("FIRST TO 10 FOLLOWERS WINS.", 15, 60, 7)
        end
        print("PRESS O TO BEGIN", 35, 100, 5)
    elseif game_state == "level_complete" then
        if not start_screen_anim.player_demo or start_screen_anim.player_demo.state ~= "victory" then
             init_level_complete_anim()
        end
        
        cls(0)
        print("LEVEL COMPLETE!", 38, 60, 7)
        
        -- Rita segrande slime
        draw_level_complete_anim()
        
        print("PRESS O TO CONTINUE", 30, 100, 5)
    elseif game_state == "game_over_screen" then
        -- Rita den vanliga gameplay-skärmen i bakgrunden
        draw_gameplay() 
        -- Rita game over-texten över
        local msg = "GAME OVER"
        print(msg, 64 - #msg * 2, 60, 8)
        
        print("PRESS Z TO RESTART", 32, 80, 7)
    elseif game_state == "game_victory_screen" then
        cls(0)
        draw_victory_anim()
        
        print("CONGRATULATIONS!", 32, 20, 7)
        print("YOU ARE THE GRANDMASTER!", 20, 30, 7)
        print("THE SLIMES REJOICE!", 30, 100, 6)
        print("PRESS Z TO RESTART", 32, 115, 5)
    elseif game_state == "gameplay" then
        draw_gameplay()
    end
end

--============================================
-- GAMEPLAY SPECIFIC FUNCTIONS
--============================================

function setup_gameplay()
    -- Välj värld och karta beroende på nivå
    local map_x = 0
    if current_level == 2 then
        map_x = 16 -- Nivå 2 ritar från tile-kolumn 16
    elseif current_level == 3 then
        map_x = 32 -- Nivå 3 och 5 använder labyrinten
    elseif current_level == 4 then
        map_x = 0 -- Nivå 4 använder samma öppna arena som Nivå 2
    elseif current_level == 5 then
        map_x = 48 -- Nivå 5 använder labyrinten
    end
    
    -- Skapa en värld som ritar 16x16 tiles från kartans start
    world = World.new(map_x, 0, 0, 0, 16, 16)

    -- Sätt kollisionsflagga för hinder-sprites
    fset(49, 0, true) -- Flagga 0 betyder "solid"
    fset(50, 0, true)

    -- STÄDNING: Rensa dynamiska hinder från kartan om vi är på nivå 2 eller 4
    if current_level == 2 or current_level == 4 then
        -- Rensa insidan av arenan (1-14), spara väggarna/ramen (0 och 15)
        for x=0, 15 do
            for y=0, 15 do
                -- Undantag för tidsräknarens bakgrund (x=1-3, y=5-8)
                -- (Dessa koordinater verkar vara där timern ritas in i kartan)
                local is_protected = (y >= 1 and y <= 3 and x >= 5 and x <= 9)
                
                if not is_protected then
                    local tile = mget(map_x + x, y)
                    if tile == 49 then -- Om det är ett block
                        mset(map_x + x, y, 0) -- Ta bort det
                    end
                end
            end
        end
    end

    -- Placera ut 8 enstaka hinder manuellt på kartan ENDAST för Nivå 1
    if current_level == 1 then
        mset(7, 3, 49)
        mset(8, 3, 49)
    end
    hat_pool = {}
    hats = {}
    neutral_slimes = {}
    player_powerups = 0
    opponent_powerups = 0

    -- Bestäm startpositioner baserat på nivå
    local p_start_x, p_start_y, p_start_dir = 32, 64, "right"
    if current_level == 3 or current_level == 5 then
        p_start_x, p_start_y, p_start_dir = 16, 16, "right" -- Uppe till vänster för labyrint
    elseif current_level == 4 then
        p_start_x, p_start_y, p_start_dir = 64, 64, "right" -- Mitten för finalen
    end

    -- Skapa tågen med den nya strukturen
    player_train = create_train("player_leader", p_start_x, p_start_y, p_start_dir)
    player_slime_train = player_train.creatures

    if current_level == 1 then
        level_timer = 60 -- Ändrad från 100
        slimes_to_collect = 20
        -- Nollställ motståndaren för nivå 1
        opponent_train = nil
        opponent_slime_train = {}
        opponent_ai = nil
    elseif current_level == 2 then
        -- Skapa motståndaren för nivå 2
        opponent_train = create_train("opponent_leader", 96, 64, "left")
        opponent_slime_train = opponent_train.creatures
        opponent_ai = AIController.new(opponent_train)
    elseif current_level == 3 then
        -- Konfiguration för Nivå 3: Labyrint, tidsbegränsning, ingen motståndare
        level_timer = 65
        slimes_to_collect = 20
        opponent_train = nil
        opponent_slime_train = {}
        opponent_ai = nil
    elseif current_level == 4 then
        -- Konfiguration för Nivå 4: Finalen
        level_timer = 90         -- Mer tid
        slimes_to_collect = 25   -- Fler slimes, kräver långt tåg
        opponent_train = nil
        opponent_slime_train = {}
        opponent_ai = nil
    elseif current_level == 5 then
        -- Konfiguration för Nivå 5: Grandmaster Duel (AI + Labyrint
        level_timer = 0 -- Ingen tidsgräns, kör tills någon kraschar
        slimes_to_collect = 0 -- Inget samlarkrav, bara vinn duellen
        
        -- Starta motståndaren i motsatt hörn av labyrinten (112, 112)
        opponent_train = create_train("opponent_leader", 112, 112, "left")
        opponent_slime_train = opponent_train.creatures
        opponent_ai = AIController.new(opponent_train)
        
        -- GE MOTSTÅNDAREN EN FÖRDEL: En slumpmässig hatt från start!
        local hat_type = 8
        opponent_train.creatures[1]:equip_hat(hat_type)
        update_train_speed(opponent_train)
    end

    
    -- Fyll på hatt-poolen med hatt-typer i ordning
    for i=1, MAX_HATS do
        add(hat_pool, i) -- Lägg till 1, 2, 3, ... 7
    end

    -- Blanda hattarna för slumpmässig ordning
    for i = #hat_pool, 2, -1 do
        local j = flr(rnd(i)) + 1
        hat_pool[i], hat_pool[j] = hat_pool[j], hat_pool[i]
    end

    spawn_neutral_slime()
    spawn_hat()
end

function update_gameplay()
    -- Hantera screen shake-timer (måste vara FÖRE game_over-check)
    if camera_shake_timer > 0 then
        camera_shake_timer -= 1
    end

    if (current_level == 1 or current_level == 3 or current_level == 4 or current_level == 5) and level_timer > 0 then
        level_timer -= 1/30 -- Pico-8 körs i 30 FPS
    end

    if current_level == 1 or current_level == 3 or current_level == 4 or current_level == 5 then
        if rnd(1) < 0.02 then
            spawn_hat()
        end
    end

    check_level_conditions()

    if game_over then
        game_state = "game_over_screen"
    end

    if game_state != "gameplay" then return end
    
    if (current_level == 2 or current_level == 5) and #neutral_slimes == 0 then
        spawn_neutral_slime()
    end
    
    if (current_level == 3 or current_level == 4) and #neutral_slimes == 0 then
        spawn_neutral_slime()
    end

    -- Hantera logiken för varje tåg separat
    handle_train_logic(player_train, true)
    if opponent_train then
        handle_train_logic(opponent_train, false)
    end

    -- Buffra input för spelaren under animationsfasen
    if player_train.is_moving then
        local buffered_input = nil
        if (btnp(0) and player_train.direction != "right") buffered_input = "left"
        if (btnp(1) and player_train.direction != "left") buffered_input = "right"
        if (btnp(2) and player_train.direction != "down") buffered_input = "up"
        if (btnp(3) and player_train.direction != "up") buffered_input = "down"
        if buffered_input then
            player_train.buffered_direction = buffered_input
        end
    end

    -- Uppdatera alltid den visuella representationen och animationerna
    update_train(player_train, true)
    if opponent_train then
        update_train(opponent_train, false)
    end
    for slime in all(neutral_slimes) do slime:update() end
    for hat in all(hats) do hat:update() end
end

-- Ny funktion för att hantera ett enskilt tågs input och rörelsestart
function handle_train_logic(train, is_player)
    -- Starta bara en ny rörelse om tåget står stilla
    if not train.is_moving then
        -- 1% chans att tappa en hatt varje frame man står still
        if rnd(1) < 0.01 then
            drop_hat(train)
        end

        local dx, dy = 0, 0
        
        if is_player then
            local next_dir = train.buffered_direction
            train.buffered_direction = nil -- Rensa bufferten

            if not next_dir then
                if (btn(0) and train.direction != "right") next_dir = "left"
                if (btn(1) and train.direction != "left") next_dir = "right"
                if (btn(2) and train.direction != "down") next_dir = "up"
                if (btn(3) and train.direction != "up") next_dir = "down"
            end

            if next_dir then
                train.direction = next_dir
            end
        else -- AI
            local next_ai_dir = opponent_ai:decide_next_move(neutral_slimes, hats, player_train)
            if next_ai_dir then
                train.direction = next_ai_dir
            end
        end

        local dir_vec = get_dir_vector(train.direction) -- Använd global funktion
        dx, dy = dir_vec.x, dir_vec.y

        if dx != 0 or dy != 0 then
            local head = train.path[1]
            local next_pos = {x = head.x + dx, y = head.y + dy}

            -- Kollisionsdetektion
            if is_pos_colliding(next_pos, train, is_player and opponent_train or player_train) then
                -- Sätt krasch-status för detta tåg
                if is_player then
                    winner = "opponent"
                    game_over = true
                else
                    winner = "player"
                    game_state = "level_complete"
                end
                
                camera_shake_timer = 15
                camera_shake_intensity = 2
                sfx(2)
                train.creatures[1].state = "game_over"
                -- Uppdatera vinnarens animation
                if opponent_train then
                    local winner_train = is_player and opponent_train or player_train
                    for c in all(winner_train.creatures) do c.state = "victory" end
                end

            else
                -- Initiera rörelsen
                add(train.path, next_pos, 1)
                train.is_moving = true
            end
        end
    end
end


-- Uppdaterar ett tågs visuella tillstånd och animation
function update_train(train, is_player)
    -- Om tåget animerar sin rörelse
    if train.is_moving then
        train.move_timer += 1
        local progress = train.move_timer / train.move_duration
        
        for i = 1, #train.creatures do
            local creature = train.creatures[i]
            local start_pos = train.path[i+1]
            local end_pos = train.path[i]
            
            local new_x = start_pos.x * 8 + (end_pos.x - start_pos.x) * 8 * progress
            local new_y = start_pos.y * 8 + (end_pos.y - start_pos.y) * 8 * progress
            
            local dx = end_pos.x - start_pos.x
            local dy = end_pos.y - start_pos.y
            local facing = "down"
            local flip_x = false
            if dy > 0 then facing = "down"
            elseif dy < 0 then facing = "up"
            elseif dx != 0 then
                facing = "side"
                flip_x = (dx < 0)
            end

            creature:set_visuals(new_x, new_y, "walk", facing, flip_x)
            creature:update()
        end

        if train.move_timer >= train.move_duration then
            train.is_moving = false
            train.move_timer = 0
            del(train.path, train.path[#train.path])

            for i=1, #train.creatures do
                train.creatures[i].tile_x = train.path[i].x
                train.creatures[i].tile_y = train.path[i].y
            end
            
            -- Hantera upplockning när tåget har landat på en ny ruta
            handle_slime_pickup(train)
            handle_hat_pickup(train, is_player and "player" or "opponent")
        end
    -- Om tåget står stilla
    else
        -- Sätt state till idle (eller victory/game_over om spelet är slut)
        for creature in all(train.creatures) do
            if not game_over then
                creature.state = "idle"
            end
            creature:update()
        end
    end
end



function draw_gameplay()
    -- Återställ kameran, cls, och rita världen
    camera(0,0)

    if current_level == 5 then
        cls(0) 
    else
        cls(12)
    end
    world:draw()

    -- Samla alla objekt som ska ritas i en lista för sortering
    local render_list = {}
    
    for hat in all(hats) do add(render_list, hat) end
    for slime in all(neutral_slimes) do add(render_list, slime) end
    for segment in all(player_slime_train) do add(render_list, segment) end
    if opponent_train then
        for segment in all(opponent_slime_train) do add(render_list, segment) end
    end
    
    -- Sortera listan baserat på Y-position (Depth sorting)
    -- Objekt högre upp (mindre Y) ritas först (bakom)
    for i=1, #render_list do
        for j=1, #render_list-i do
            if render_list[j].y > render_list[j+1].y then
                render_list[j], render_list[j+1] = render_list[j+1], render_list[j]
            end
        end
    end
    
    -- Rita alla objekt i rätt ordning
    for obj in all(render_list) do
        obj:draw()
    end
    
    -- UI - ritas bara under gameplay
    print("Slimes: " .. (#player_slime_train - 1), 2, 2, 7)
    if opponent_train then
        print("Opponent: " .. (#opponent_slime_train - 1), 64, 2, 8)
    end

    -- Rita ut timer för nivå 1, 3 och 4 (Ingen timer för nivå 5)
    if current_level == 1 or current_level == 3 or current_level == 4 then
        local time_str = tostr(ceil(level_timer))
        print(time_str, 64 - #time_str * 2, 18, 7)
    end
end

function check_level_conditions()
    -- Denna funktion kan i framtiden flyttas till en level manager
    if game_state != "gameplay" then return end

    if current_level == 1 or current_level == 3 or current_level == 4 then
        if level_timer <= 0 then
            if #player_slime_train - 1 >= slimes_to_collect then
                winner = "player"
                game_state = "level_complete"
            else
                winner = "opponent" -- Förlorade mot klockan (använder samma vinnar-variabel för enkelhet)
                game_over = true
            end
        end
    elseif current_level == 5 then
        -- Ingen tidsgräns på nivå 5
        -- Race condition: Först till 10 följare
        if (#opponent_slime_train - 1) >= 10 then
            winner = "opponent"
            game_over = true
        elseif (#player_slime_train - 1) >= 10 then
            winner = "player"
            game_state = "level_complete"
        end
    end
end

-- Hjälpfunktion för att se om en position är upptagen
function is_pos_colliding(pos, own_train, other_train)
    -- 1. Världens gränser och hinder
    if not world:is_passable(pos.x * 8, pos.y * 8) then return true end

    -- 2. Eget tåg (ignorera svansens sista del under rörelse)
    local own_path = own_train.path
    if own_train.is_moving then
        -- När tåget rör sig, kommer svansen att lämna sin ruta.
        -- Vi behöver inte kolla den sista positionen.
        for i=1, #own_path - 1 do
            if pos.x == own_path[i].x and pos.y == own_path[i].y then return true end
        end
    else
        for segment in all(own_path) do
            if pos.x == segment.x and pos.y == segment.y then return true end
        end
    end

    -- 3. Motståndartåg (hantera "head-on"-krock)
    if other_train then
        local other_path = other_train.path
        for segment in all(other_path) do
            if pos.x == segment.x and pos.y == segment.y then return true end
        end
        
        -- Specialfall: Om motståndaren också rör sig och vi är på väg
        -- att byta plats med dess huvud.
        if other_train.is_moving then
            local own_head = own_train.path[1]
            local other_head = other_train.path[1]
            if pos.x == other_head.x and pos.y == other_head.y and
               other_path[2].x == own_head.x and other_path[2].y == own_head.y then
               return true
            end
        end
    end

    return false
end

function get_dir_vector(dir)
    if dir == "left" then return {x=-1, y=0}
    elseif dir == "right" then return {x=1, y=0}
    elseif dir == "up" then return {x=0, y=-1}
    elseif dir == "down" then return {x=0, y=1}
    end
    return {x=0, y=0}
end

function spawn_neutral_slime()
    local tile_x, tile_y
    repeat
        tile_x = flr(rnd(world.w_tiles - 2)) + 1
        tile_y = flr(rnd(world.h_tiles - 2)) + 1
    until world:is_passable(tile_x * 8, tile_y * 8)

    local slime = Creature.new(tile_x * 8, tile_y * 8, "neutral_slime")
    slime.state = "idle"
    add(neutral_slimes, slime)
end

function spawn_hat()
    -- Om det finns hattar kvar i poolen och inga på kartan, spawna en ny
    if #hat_pool > 0 and #hats == 0 then
        local hat_type = del(hat_pool, hat_pool[#hat_pool]) -- Ta sista från poolen

        local tile_x, tile_y
        repeat
            tile_x = flr(rnd(world.w_tiles - 2)) + 1
            tile_y = flr(rnd(world.h_tiles - 2)) + 1
        until world:is_passable(tile_x * 8, tile_y * 8)

        local hat = Creature.new(tile_x * 8, tile_y * 8, "hat")
        hat.hat_type = hat_type -- Spara vilken typ av hatt det är
        -- Sätt rätt animation för hatten som ligger på marken
        hat.anim_defs = gamedata.anim_defs.hat[hat_type]
        hat.state = "idle"
        add(hats, hat)
    end
end

-- Hanterar kollisionen mellan ett tåg och neutrala slimes
function handle_slime_pickup(train)
    local head_pos = train.path[1]

    for slime in all(neutral_slimes) do
        if head_pos.x == slime.tile_x and head_pos.y == slime.tile_y then
            sfx(0) -- Spela "plocka upp slime"-ljud
            local tail_pos = train.path[#train.path]
            slime.tile_x = tail_pos.x
            slime.tile_y = tail_pos.y
            slime.x, slime.y = slime.tile_x * 8, slime.tile_y * 8
            
            add(train.creatures, slime)
            add(train.path, tail_pos) -- KORRIGERING: Använd tail_pos
            
            del(neutral_slimes, slime)
            -- På nivå 1 spawnar en ny direkt. På nivå 2 hanteras det i update.
            if current_level ~= 2 then
                spawn_neutral_slime()
            end
            
            -- Nivå 4: Spawna hinder när man plockar upp en slime!
            if current_level == 4 then
                spawn_dynamic_obstacle()
                -- Öka svårighetsgraden: Ibland spawna två hinder
                if rnd(1) < 0.3 then spawn_dynamic_obstacle() end
            end
            
            break
        end
    end
end

-- Funktion för att spawna dynamiska hinder (block) på kartan
function spawn_dynamic_obstacle()
    local tile_x, tile_y
    local attempts = 0
    repeat
        attempts += 1
        tile_x = flr(rnd(world.w_tiles - 2)) + 1
        tile_y = flr(rnd(world.h_tiles - 2)) + 1
        
        -- Måste vara en fri plats (ej vägg)
        local passable = world:is_passable(tile_x * 8, tile_y * 8)
        
        -- Får ej vara för nära spelaren (ge lite andrum)
        local player_head = player_train.path[1]
        local dist_x = abs(tile_x - player_head.x)
        local dist_y = abs(tile_y - player_head.y)
        local safe_dist = (dist_x > 3 or dist_y > 3)
        
        -- Får ej krocka med tåget
        local on_train = false
        for seg in all(player_train.path) do
            if seg.x == tile_x and seg.y == tile_y then on_train = true break end
        end
        
        -- Får ej krocka med stillastående slimes eller hattar
        local on_entity = false
        for s in all(neutral_slimes) do
            if s.tile_x == tile_x and s.tile_y == tile_y then on_entity = true break end
        end
        for h in all(hats) do
            if h.tile_x == tile_x and h.tile_y == tile_y then on_entity = true break end
        end
        
    until (passable and safe_dist and not on_train and not on_entity) or attempts > 50
    
    if attempts <= 50 then
        -- Placera blocket på kartan (Sprite 49)
        mset(world.map_x + tile_x, world.map_y + tile_y, 49)
        
        -- Visuell effekt (rökpuff) kan läggas till här om vi vill
    end
end

-- Hanterar kollisionen mellan ett tåg och en hatt
function handle_hat_pickup(train, train_id)
    local head_pos = train.path[1]

    for hat in all(hats) do
        if head_pos.x == hat.tile_x and head_pos.y == hat.tile_y then
            sfx(1) -- Spela "plocka upp hatt"-ljud
            local creatures = train.creatures
            -- Kolla om alla i tåget redan har en hatt
            local all_have_hats = true
            for segment in all(creatures) do
                if not segment.has_hat then
                    all_have_hats = false
                    break
                end
            end
            if all_have_hats then return end

            -- Hitta en slumpmässig medlem som *inte* har en hatt
            local target_slime
            repeat
                target_slime = creatures[flr(rnd(#creatures)) + 1]
            until not target_slime.has_hat
            
            target_slime:equip_hat(hat.hat_type)
            update_train_speed(train)
            
            -- Öka rätt räknare
            if train_id == "player" then
                player_powerups += 1
            elseif train_id == "opponent" then
                opponent_powerups += 1
            end
            
            del(hats, hat)
            spawn_hat()
            break
        end
    end
end

-- Funktion för att tappa en hatt
function drop_hat(train)
    -- Hitta alla som bär en hatt
    local hat_wearers = {}
    for creature in all(train.creatures) do
        if creature.has_hat then
            add(hat_wearers, creature)
        end
    end
    
    if #hat_wearers == 0 then return end

    -- Välj en slumpmässig att tappa hatten
    local unlucky_slime = hat_wearers[flr(rnd(#hat_wearers)) + 1]
    
    -- Skapa en ny hatt på kartan
    local tile_x, tile_y = unlucky_slime.tile_x, unlucky_slime.tile_y
    local hat = Creature.new(tile_x * 8, tile_y * 8, "hat")
    hat.hat_type = unlucky_slime.hat_type -- Ta typen från den som tappade
    hat.anim_defs = gamedata.anim_defs.hat[hat.hat_type]
    hat.state = "idle"
    add(hats, hat)
    
    -- Nollställ den som tappade
    unlucky_slime:remove_hat()
    update_train_speed(train)
end

-- Uppdaterar tågets hastighet baserat på antalet hattar
function update_train_speed(train)
    local hat_count = 0
    for c in all(train.creatures) do
        if c.has_hat then
            hat_count += 1
        end
    end
    train.move_duration = max(2, BASE_MOVE_DURATION - (hat_count * HAT_SPEED_BONUS))
end