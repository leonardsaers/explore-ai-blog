-- pico-8 cartridge
-- title: Chromatic Serpent
-- author: Gemini & User
-- version: 2.8 (Final Polish)

--============================================--
--      INITIALISERING (_init)                --
--============================================--
function _init()
    grid_size = 8
    grid_width = 128 / grid_size
    grid_height = 128 / grid_size
    
    -- Ormen startar nu som bara ett huvud
    snake = {{x=8, y=8}}
    -- Ormens kroppsfärger är tom från start
    snake_sprites = {}
    
    dir = 0
    speed = 12 -- Något långsammare start
    move_timer = speed
    
    -- Hantera flera frukter
    fruits = {}
    for i=1,3 do
        spawn_fruit()
    end
    
    -- Variabler för statistik
    fruits_eaten = 0
    speed_fruits_eaten = 0
    
    can_turn = true
    
    -- Effekt-variabler
    controls_inverted = false
    invert_timer = 0
    
    game_state = "title"

    -- Dekorativ orm för startskärmen
    title_snake = {}
    title_snake_sprites = {}
    local start_x, start_y = 2, 3
    -- Skapa 8 positionssegment
    for i=1, 8 do
        add(title_snake, {x = start_x - (i-1), y = start_y})
    end
    -- Skapa 7 färgsegment för kroppen
    for i=1, 7 do
        add(title_snake_sprites, (i-1)%3 + 1)
    end

    title_snake_dir = 0 -- startar med att röra sig höger
    title_snake_speed = 6 -- snabbare än spelet
    title_snake_timer = title_snake_speed
    
    -- Timers för effekter
    blink_timer = 0
    shake_timer = 0

    -- Partikelsystem
    particles = {}
end

--============================================--
--      UPPDATERING (_update)                 --
--============================================--
function _update()
    if game_state == "title" then
        update_title()
    elseif game_state == "playing" then
        update_playing()
    elseif game_state == "game_over" then
        update_game_over()
    end
end

function update_title()
    -- Starta spelet vid knapptryck
    if btnp(4) or btnp(5) then
        game_state = "playing"
    end
    
    -- Uppdatera blink-timer
    blink_timer = (blink_timer + 1) % 40

    -- Animera ormen på startskärmen
    title_snake_timer -= 1
    if title_snake_timer <= 0 then
        title_snake_timer = title_snake_speed

        local head = title_snake[1]
        local new_head = {x=head.x, y=head.y}

        -- Rektangelns hörn
        local left_wall, right_wall = 2, 13
        local top_wall, bottom_wall = 3, 12

        -- Byt riktning i hörnen
        if head.x == right_wall and head.y == top_wall and title_snake_dir == 0 then title_snake_dir = 1 end
        if head.x == right_wall and head.y == bottom_wall and title_snake_dir == 1 then title_snake_dir = 2 end
        if head.x == left_wall and head.y == bottom_wall and title_snake_dir == 2 then title_snake_dir = 3 end
        if head.x == left_wall and head.y == top_wall and title_snake_dir == 3 then title_snake_dir = 0 end

        -- Flytta huvudet
        if title_snake_dir == 0 then new_head.x += 1 end -- höger
        if title_snake_dir == 1 then new_head.y += 1 end -- ner
        if title_snake_dir == 2 then new_head.x -= 1 end -- vänster
        if title_snake_dir == 3 then new_head.y -= 1 end -- upp

        add(title_snake, new_head, 1)
        deli(title_snake)
    end
end

function update_game_over()
    if btnp(4) or btnp(5) then
        _init()
    end
    -- Uppdatera blink-timer för texten
    blink_timer = (blink_timer + 1) % 40
end

function update_playing()
    -- Uppdatera partiklar
    for i=#particles,1,-1 do
        local p = particles[i]
        p.x += p.dx
        p.y += p.dy
        p.life -= 1
        if p.life <= 0 then
            deli(particles, i)
        end
    end

    -- Hantera timer för inverterade kontroller
    if invert_timer > 0 then
        invert_timer -= 1
        if invert_timer == 0 then
            controls_inverted = false
        end
    end
    
    -- Läs av input och hantera riktning
    if can_turn then
        local left  = btnp(0)
        local right = btnp(1)
        local up    = btnp(2)
        local down  = btnp(3)

        -- Byt knapptryck om kontroller är inverterade
        if controls_inverted then
            left, right = right, left
            up, down = down, up
        end

        local new_dir = dir
        if left and dir != 0 then new_dir = 2 end
        if right and dir != 2 then new_dir = 0 end
        if up and dir != 1 then new_dir = 3 end
        if down and dir != 3 then new_dir = 1 end

        if new_dir != dir then
            dir = new_dir
            can_turn = false
        end
    end

    move_timer -= 1
    
    if move_timer <= 0 then
        move_timer = speed
        can_turn = true
        
        local head = snake[1]
        local new_head = {x=head.x, y=head.y}
        
        if dir == 0 then new_head.x += 1 end
        if dir == 1 then new_head.y += 1 end
        if dir == 2 then new_head.x -= 1 end
        if dir == 3 then new_head.y -= 1 end
        
        -- Vid kollision, spela ljud och byt state
        if new_head.x < 0 or new_head.x >= grid_width or 
           new_head.y < 0 or new_head.y >= grid_height then
            sfx(1) -- Spela Game Over-ljud
            shake_timer = 15 -- Starta skärmskakning
            game_state = "game_over"
            return
        end
        
        -- Kollision med sig själv (bara om ormen har en kropp)
        if #snake > 1 then
            for i=2, #snake do
                local segment = snake[i]
                if new_head.x == segment.x and new_head.y == segment.y then
                    sfx(1) -- Spela Game Over-ljud
                    shake_timer = 15 -- Starta skärmskakning
                    game_state = "game_over"
                    return
                end
            end
        end
        
        add(snake, new_head, 1)
        
        -- Ät frukt
        local ate_fruit = false
        local eaten_fruit_index
        for i=1, #fruits do
            local fruit = fruits[i]
            if new_head.x == fruit.x and new_head.y == fruit.y then
                fruits_eaten += 1
                apply_fruit_effect(fruit)
                ate_fruit = true
                eaten_fruit_index = i
                sfx(0) -- Spela ät-ljud
                create_particles(fruit) -- Skapa partiklar
                break
            end
        end

        if ate_fruit then
            deli(fruits, eaten_fruit_index)
            spawn_fruit()
        else
            deli(snake)
        end
    end
end

--============================================--
--      GRAFIK (_draw)                        --
--============================================--
function _draw()
    -- Hantera skärmskakning
    if shake_timer > 0 then
        shake_timer -= 1
        camera(rnd(3)-2, rnd(3)-2)
    else
        camera(0,0)
    end

    cls(1)
    
    if game_state == "title" then
        draw_title()
    elseif game_state == "playing" then
        draw_playing()
    elseif game_state == "game_over" then
        draw_game_over()
    end
end

function draw_title()
    -- Svart bakgrund för texten
    rectfill(18, 32, 110, 92, 0)
    
    -- Rita den dekorativa ormens huvud
    spr(4, title_snake[1].x * grid_size, title_snake[1].y * grid_size)
    -- Rita den dekorativa ormens kropp
    for i=2, #title_snake do
        local segment = title_snake[i]
        local sprite = title_snake_sprites[i-1]
        spr(sprite, segment.x * grid_size, segment.y * grid_size)
    end

    print("CHROMATIC SERPENT", 26, 40, 7)
    print("EAT THE FRUITS!", 34, 60, 13)
    
    -- Rita blinkande text
    if blink_timer < 20 then
        print("PRESS X TO START", 30, 80, 7)
    end
end

function draw_game_over()
    draw_playing()
    local final_score = fruits_eaten * speed_fruits_eaten
    
    -- Svart bakgrund för texten
    rectfill(14, 32, 114, 92, 0)
    
    print("GAME OVER", 45, 40, 8)
    print("TOTAL SCORE: "..final_score, 28, 52, 7)
    print("("..fruits_eaten.." X "..speed_fruits_eaten.." SPEED FRUITS)", 18, 62, 13)
    
    -- Rita blinkande text
    if blink_timer < 20 then
        print("PRESS X TO RESTART", 24, 80, 7)
    end
end

function draw_playing()
    -- Ändra bakgrundsfärg om kontroller är inverterade
    if controls_inverted then
        cls(9) -- Orange bakgrund
    else
        cls(1) -- Mörkblå bakgrund
    end
    
    -- Rita alla frukter
    for fruit in all(fruits) do
        spr(fruit.sprite, fruit.x * grid_size, fruit.y * grid_size)
    end
    
    -- Rita ormens huvud
    spr(4, snake[1].x * grid_size, snake[1].y * grid_size)
    -- Rita ormens kropp
    for i=2, #snake do
        local segment = snake[i]
        local sprite = snake_sprites[i-1] or 1 -- Standardfärg om något går fel
        spr(sprite, segment.x * grid_size, segment.y * grid_size)
    end
    
    print("FRUITS: "..fruits_eaten, 3, 3, 7)
    print("SPEED FRUITS: "..speed_fruits_eaten, 58, 3, 7)

    -- Rita partiklar
    for p in all(particles) do
        pset(p.x, p.y, p.color)
    end
end

--============================================--
--      HJÄLPFUNKTIONER                       --
--============================================--
function create_particles(fruit)
    local px = fruit.x * grid_size + 4 -- Mitten av rutan
    local py = fruit.y * grid_size + 4
    local p_color = 7 -- Vit standardfärg

    if fruit.sprite == 1 then p_color = 8 end -- Röd
    if fruit.sprite == 2 then p_color = 13 end -- Lila
    if fruit.sprite == 3 then p_color = 9 end -- Orange
    
    -- Skapa 5 partiklar
    for i=1, 5 do
        add(particles, {
            x = px,
            y = py,
            dx = rnd(3) - 1.5,
            dy = rnd(3) - 1.5,
            life = 10 + rnd(5),
            color = p_color
        })
    end
end

function spawn_fruit()
    local fruit = {}
    local on_something
    repeat
        on_something = false
        fruit.x = flr(rnd(grid_width))
        fruit.y = flr(rnd(grid_height))
        
        for segment in all(snake) do
            if fruit.x == segment.x and fruit.y == segment.y then
                on_something = true
                break
            end
        end

        for other_fruit in all(fruits) do
            if fruit.x == other_fruit.x and fruit.y == other_fruit.y then
                on_something = true
                break
            end
        end

    until not on_something

    local rand = rnd(1)
    local max_speed_reached = (speed <= 4)

    if max_speed_reached then
        -- Om maxhastighet är nådd, fördela om sannolikheten
        -- mellan "grow" och "invert"
        if rand < 0.75 then -- 75% chans för växt-frukt
            fruit.type = "grow"
            fruit.sprite = 1
        else -- 25% chans för kaos-frukt
            fruit.type = "invert"
            fruit.sprite = 3
        end
    else
        -- Normal sannolikhet om maxhastighet inte är nådd
        if rand < 0.6 then -- 60% chans för växt-frukt
            fruit.type = "grow"
            fruit.sprite = 1
        elseif rand < 0.85 then -- 25% chans för fart-frukt
            fruit.type = "speed"
            fruit.sprite = 2
        else -- 15% chans för kaos-frukt
            fruit.type = "invert"
            fruit.sprite = 3
        end
    end

    add(fruits, fruit)
end

function apply_fruit_effect(fruit)
    -- Lägg till den nya färgen i slutet av färg-listan,
    -- så att den dyker upp på det nya svans-segmentet.
    add(snake_sprites, fruit.sprite)

    if fruit.type == "speed" then
        speed_fruits_eaten += 1
        -- Snabbare ökning i början, långsammare mot slutet
        if speed > 8 then
            speed -= 2
        elseif speed > 4 then
            speed -= 1
        end
    elseif fruit.type == "invert" then
        controls_inverted = true
        invert_timer = 60 * 5 -- 5 sekunder
    elseif fruit.type == "grow" then
        -- Väx-effekten hanteras genom att inte ta bort sista segmentet.
        -- Denna funktion behöver inte göra något extra.
    end
end


