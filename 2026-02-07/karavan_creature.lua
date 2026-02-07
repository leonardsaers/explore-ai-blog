-- TEST
-- karavan_creature.lua
-- Hanterar varelser, rörelse och animation

Creature = {}
Creature.__index = Creature


function Creature.new(x, y, template_name)
    local self = setmetatable({}, Creature)
    local template = gamedata.creature_templates[template_name]
    
    self.move_duration = template.move_duration or 8
    

    self.tile_x = x / 8
    self.tile_y = y / 8
    

    self.x = x
    self.y = y
    

    self.is_moving = false
    self.move_timer = 0
    self.start_x = x
    self.start_y = y
    self.target_x = x
    self.target_y = y


    self.prev_tile_x = self.tile_x
    self.prev_tile_y = self.tile_y

    self.direction = "down"
    self.facing = "down"
    self.flip_x = false
    self.state = "idle"
    self.anim_ref = template.anim_ref
    self.hat_sprite = nil
    

    self.animators = {}
    self.active_layers = template.layers or {"body"}
    
    for _, layer_name in pairs(self.active_layers) do
        self.animators[layer_name] = {
            timer = 0,
            current_frame_idx = 1,
            current_anim_key = nil
        }
    end

    self.draw_config = {}
    if template.draw_config then
        for _, conf in pairs(template.draw_config) do
            add(self.draw_config, {layer=conf.layer, ox=conf.ox, oy=conf.oy})
        end
    else
        for _, layer_name in pairs(self.active_layers) do
            add(self.draw_config, {layer = layer_name, ox = 0, oy = 0})
        end
    end

    return self
end


function Creature:update(parent_segment)
    if self.is_moving then
        self:update_tile_movement()
    end


    if parent_segment and not self.is_moving then

        local target_tx = parent_segment.prev_tile_x
        local target_ty = parent_segment.prev_tile_y

        if target_tx ~= self.tile_x or target_ty ~= self.tile_y then
            self:move_to_tile(target_tx, target_ty)
        end
    end

    self:update_animation()
end

function Creature:set_visuals(x, y, state, facing, flip_x)
    self.x = x
    self.y = y
    self.state = state
    self.facing = facing
    self.flip_x = flip_x
end

function Creature:equip_hat(hat_type)
    self.has_hat = true
    self.hat_type = hat_type

    local hat_lib = gamedata.anim_defs.headgear[hat_type]
    if hat_lib and hat_lib.walk_down then
        self.hat_sprite = hat_lib.walk_down.frames[1]
    end
end

function Creature:remove_hat()
    self.has_hat = false
    self.hat_type = nil
    self.hat_sprite = nil
end

function Creature:update_tile_movement()
    self.move_timer = self.move_timer + 1
    
    local progress = self.move_timer / self.move_duration
    

    self.x = self.start_x + (self.target_x - self.start_x) * progress
    self.y = self.start_y + (self.target_y - self.start_y) * progress
    

    if self.move_timer >= self.move_duration then
        self.is_moving = false
        self.x = self.target_x
        self.y = self.target_y

        self.tile_x = self.target_x / 8
        self.tile_y = self.target_y / 8
    end
end

function Creature:handle_player_input()

    if self.is_moving then return end

    -- Byt riktning baserat på input, men vänd inte 180 grader
    if (btn(0) and self.direction != "right") self.direction = "left"
    if (btn(1) and self.direction != "left") self.direction = "right"
    if (btn(2) and self.direction != "down") self.direction = "up"
    if (btn(3) and self.direction != "up") self.direction = "down"
    

    local dx, dy = 0, 0
    if self.direction == "left" then dx = -1
    elseif self.direction == "right" then dx = 1
    elseif self.direction == "up" then dy = -1
    elseif self.direction == "down" then dy = 1
    end

    if dx != 0 or dy != 0 then
        self:move_to_tile(self.tile_x + dx, self.tile_y + dy)
    else

        self.state = "idle"
    end
end




function Creature:handle_ai_input(all_dancers)
    if self.is_moving or #all_dancers == 0 then return end

    local closest_dancer = nil
    local min_dist = 9999



    for dancer in all(all_dancers) do

        local dist = abs(self.tile_x - dancer.tile_x) + abs(self.tile_y - dancer.tile_y)
        if dist < min_dist then
            min_dist = dist

            closest_dancer = dancer
        end
    end


    if not closest_dancer then return end


    local dx = closest_dancer.tile_x - self.tile_x
    local dy = closest_dancer.tile_y - self.tile_y

    local move_options = {}


    if abs(dx) > abs(dy) then
        if dx > 0 then add(move_options, "right") else add(move_options, "left") end
        if dy > 0 then add(move_options, "down") else add(move_options, "up") end
    else
        if dy > 0 then add(move_options, "down") else add(move_options, "up") end
        if dx > 0 then add(move_options, "right") else add(move_options, "left") end
    end


    add(move_options, self.direction)

    for new_dir in all(move_options) do
        local is_valid = true

        if (new_dir == "left" and self.direction == "right") or
           (new_dir == "right" and self.direction == "left") or
           (new_dir == "up" and self.direction == "down") or
           (new_dir == "down" and self.direction == "up") then
            is_valid = false
        end


        if is_valid then
            self.direction = new_dir
            break
        end
    end


    local move_dx, move_dy = 0, 0
    if self.direction == "left" then move_dx = -1
    elseif self.direction == "right" then move_dx = 1
    elseif self.direction == "up" then move_dy = -1
    elseif self.direction == "down" then move_dy = 1
    end

   
    self:move_to_tile(self.tile_x + move_dx, self.tile_y + move_dy)
end



function Creature:move_to_tile(target_tile_x, target_tile_y)

    self.prev_tile_x = self.tile_x
    self.prev_tile_y = self.tile_y

    self.is_moving = true
    self.state = "walk"
    self.move_timer = 0
    
    self.start_x = self.x
    self.start_y = self.y
    self.target_x = target_tile_x * 8
    self.target_y = target_tile_y * 8
    

    local dx = self.target_x - self.start_x
    local dy = self.target_y - self.start_y
    
    if dy > 0 then self.facing = "down"
    elseif dy < 0 then self.facing = "up"
    elseif dx != 0 then 
        self.facing = "side" 
        self.flip_x = (dx < 0)
    end
end

function Creature:update_animation()

    local anim_set = self.anim_defs or gamedata.anim_defs[self.anim_ref]
    if not anim_set then return end
    

    local anim_key = self.state
    if self.state == "walk" then
        anim_key = "walk_" .. self.facing
    end
    
    for _, layer in pairs(self.active_layers) do
        local layer_defs = anim_set[layer]
        if layer_defs then
            local animator = self.animators[layer]
            

            local current_anim = layer_defs[anim_key] or layer_defs[self.state] or layer_defs["idle"]
            
            if current_anim then

                if anim_key ~= animator.current_anim_key then
                    animator.current_anim_key = anim_key
                    animator.timer = 0
                    animator.current_frame_idx = 1
                end


                animator.timer = animator.timer + 1
                if animator.timer >= current_anim.speed then
                    animator.timer = 0
                    animator.current_frame_idx = animator.current_frame_idx + 1

                    if animator.current_frame_idx > #current_anim.frames then
                        animator.current_frame_idx = 1
                    end
                end
                

                if animator.current_frame_idx > #current_anim.frames then
                    animator.current_frame_idx = 1
                end
                
                animator.sprite_id = current_anim.frames[animator.current_frame_idx]
                

                if layer == "body" and self.has_hat and self.hat_type then
                    local hat_def = gamedata.anim_defs.headgear[self.hat_type]
                    if hat_def then

                        local hat_anim_key = anim_key

                        
                        local hat_anim = hat_def[hat_anim_key] or hat_def["idle"]
                        if hat_anim then

                            local frame_idx = (animator.current_frame_idx - 1) % #hat_anim.frames + 1
                            self.hat_sprite = hat_anim.frames[frame_idx]
                        end
                    end
                end
            else
                animator.sprite_id = nil
            end
        end
    end
end

function Creature:draw()
    for _, config in pairs(self.draw_config) do
        local layer_name = config.layer
        local animator = self.animators[layer_name]
        
        local ox = config.ox or 0
        if self.flip_x then
            ox = -ox
        end
        local draw_x = self.x + ox
        local draw_y = self.y + (config.oy or 0)

        if layer_name == "headgear" and self.hat_sprite then
            spr(self.hat_sprite, draw_x, draw_y, 1, 1, self.flip_x)
        elseif animator and animator.sprite_id then
            spr(animator.sprite_id, draw_x, draw_y, 1, 1, self.flip_x)
        end
    end
end
