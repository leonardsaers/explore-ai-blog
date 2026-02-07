
-- Animationsvariabler för startskärmen
start_screen_anim = {
    timer = 0,
    slimes = {}
}

-- Hjälpfunktion för att skapa en slumpmässig bakgrundsslime
function create_bg_slime(random_x)
    local type = rnd(1) < 0.5 and "neutral" or (rnd(1) < 0.5 and "opponent" or "player")
    local template_name = "neutral_slime"
    if type == "opponent" then template_name = "opponent_leader"
    elseif type == "player" then template_name = "player_leader" end
    
    local dir = rnd(1) < 0.5 and 1 or -1
    local x
    if random_x then
        x = rnd(128)
    else
        -- Spawna strax utanför skärmen beroende på riktning
        if dir == 1 then x = -16 else x = 144 end
    end
    
    local y = 10 + rnd(20)
    local creature = Creature.new(x, y, template_name)
    
    -- Anpassa egenskaper
    creature.dir_val = dir
    creature.speed = 0.2 + rnd(0.5)
    creature.state = "walk"
    creature.facing = "side"
    creature.flip_x = (creature.dir_val == -1)
    creature.has_hat = rnd(1) < 0.1
    
    if creature.has_hat then
        creature.hat_type = flr(rnd(7)) + 1
    end
    
    return creature
end

-- Initiera animering för Game Over
function init_game_over_anim()
    local p_template = "player_leader"
    -- Placera spelaren centralt på skärmen
    local player = Creature.new(64, 50, p_template)
    player.state = "sad" -- Använd den ledsna animationen
    player.facing = "side"
    player.dir_val = 1
    
    start_screen_anim.player_demo = player
end

function init_level_complete_anim()
    local p_template = "player_leader"
    -- Placera spelaren centralt på skärmen
    local player = Creature.new(64, 80, p_template)
    player.state = "victory" -- Använd segeranimationen
    player.facing = "down"
    
    start_screen_anim.player_demo = player
end

function draw_level_complete_anim()
    local p = start_screen_anim.player_demo
    if p then
        p:update_animation()
        p:draw()
    end
end

-- Initiera animering för Victory
function init_victory_anim()
    start_screen_anim.slimes = {}
    
    -- Spelaren i mitten
    local p_template = "player_leader"
    local player = Creature.new(64, 64, p_template)
    player.state = "victory"
    player.facing = "down"
    player.has_hat = true
    player.hat_type = 8 -- Krona/Festlig hatt
    
    start_screen_anim.player_demo = player
    
    -- Fans runtomkring
    for i=1, 8 do
        local angle = (i / 8) * 3.14159 * 2
        local dist = 30
        local x = 64 + cos(angle) * dist
        local y = 64 + sin(angle) * dist
        
        -- Variera typen av fan
        local fan_type = "neutral_slime"
        if rnd(1) < 0.15 then fan_type = "opponent_leader"
        elseif rnd(1) < 0.2 then fan_type = "opponent_leader" end
        
        local fan = Creature.new(x, y, fan_type)
        fan.state = "idle"
        fan.facing = "down"
        
        -- Ingen hatt för fans
        fan.has_hat = false
        
        -- Ge dem lite offset i animationen så de inte hoppar synkront
        fan.animators.body.timer = rnd(10)
        
        add(start_screen_anim.slimes, fan)
    end
end

function update_victory_anim()
    local p = start_screen_anim.player_demo
    if p then 
        p:update_animation()
        update_hat_visuals(p)
    end
    
    for s in all(start_screen_anim.slimes) do
        s:update_animation()
        update_hat_visuals(s)
    end
end

function draw_victory_anim()
    -- Vi kan återanvända draw_start_screen_anim då den ritar slimes + player_demo sorterat
    draw_start_screen_anim() 
end

-- Initiera slimes för startskärmen
function init_start_screen_slimes()
    start_screen_anim.slimes = {}
    -- Lägg till några bakgrundsslimes som går fram och tillbaka
    for i=1, 8 do -- Ökade antalet lite för bättre myller
        add(start_screen_anim.slimes, create_bg_slime(true))
    end
    
    -- Spelarslime som står i mitten och tittar sig omkring
    local p_template = "player_leader"
    local player = Creature.new(64, 25, p_template)
    player.state = "idle" -- Börja med idle
    player.facing = "down"
    player.look_timer = 0
    player.dir_val = 1
    
    start_screen_anim.player_demo = player
end

function update_start_screen_anim()
    local anim = start_screen_anim
    
    -- Uppdatera bakgrundsslimes
    -- Använd index-loop för att kunna ersätta element
    for i=1, #anim.slimes do
        local s = anim.slimes[i]
        s.x += s.speed * s.dir_val
        
        -- Kolla om utanför skärmen och ersätt isåfall
        local reset = false
        if s.dir_val == 1 and s.x > 144 then reset = true end
        if s.dir_val == -1 and s.x < -16 then reset = true end
        
        if reset then
            -- Ersätt med en ny slime som kommer in från kanten
            anim.slimes[i] = create_bg_slime(false)
        else
            -- Uppdatera animationen som vanligt
            s:update_animation()
            update_hat_visuals(s)
        end
    end
    
    -- Uppdatera spelardemo
    local p = anim.player_demo
    
    -- Hantera riktningsbyte
    p.look_timer += 1
    if p.look_timer > 90 then
        p.dir_val = -p.dir_val
        p.look_timer = 0
        p.facing = "side"
        p.flip_x = (p.dir_val == -1)
        p.state = "idle" 
        p.state = "walk" 
    end
    
    p.facing = "side"
    p.flip_x = (p.dir_val == -1)
    
    p:update_animation()
end

-- Hjälpfunktion för att uppdatera hatt-sprites
function update_hat_visuals(s)
    if s.has_hat and s.hat_type then
         -- Hämta hatt-definition
         local hat_def = gamedata.anim_defs.headgear[s.hat_type]
         if hat_def then
             -- Försök hitta en matchande animation, annars fallback
             local anim_key = s.state
             if anim_key == "walk" then anim_key = "walk_"..s.facing end
             
             if not hat_def[anim_key] then 
                 -- Fallback logik
                 if s.state == "victory" then anim_key = "idle" -- Hattar kanske inte har victory-anim
                 elseif s.facing == "side" then anim_key = "walk_side"
                 else anim_key = "idle" end
             end
             
             if hat_def[anim_key] then
                 local hat_frames = hat_def[anim_key].frames
                 local body_anim = s.animators.body
                 local idx = body_anim.current_frame_idx or 1
                 local hat_frame = hat_frames[(idx - 1) % #hat_frames + 1]
                 s.hat_sprite = hat_frame
             end
         end
    end
end

function draw_start_screen_anim()
    local anim = start_screen_anim
    
    -- Samla alla objekt som ska ritas
    local all_render_objects = {}
    for s in all(anim.slimes) do
        add(all_render_objects, s)
    end
    add(all_render_objects, anim.player_demo)
    
    -- Sortera
    for i=1, #all_render_objects do
        for j=1, #all_render_objects-i do
            if all_render_objects[j].y > all_render_objects[j+1].y then
                all_render_objects[j], all_render_objects[j+1] = all_render_objects[j+1], all_render_objects[j]
            end
        end
    end

    -- Rita med Creature:draw()
    for s in all(all_render_objects) do
        s:draw()
    end
end
