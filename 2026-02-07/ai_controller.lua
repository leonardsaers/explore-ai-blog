-- ai_controller.lua
-- Hanterar AI-logiken för motståndartåget

AIController = {}
AIController.__index = AIController

function AIController.new(train)
    local self = setmetatable({}, AIController)
    self.train = train
    return self
end

function AIController:decide_next_move(neutral_slimes, hats, opponent_train)
    local best_target = self:evaluate_targets(neutral_slimes, hats)
    

    if not best_target then
        local head_pos = self.train.path[1]
        local next_pos = {x = head_pos.x, y = head_pos.y}
        local vec = get_dir_vector(self.train.direction)
        next_pos.x += vec.x
        next_pos.y += vec.y
        if not is_pos_colliding(next_pos, self.train, opponent_train) then
            return self.train.direction
        end
        return nil
    end

    local next_direction = self:plan_route(best_target, opponent_train)
    
    return next_direction
end

function AIController:evaluate_targets(neutral_slimes, hats)
    local targets = {}
    local head_pos = self.train.path[1]

    for slime in all(neutral_slimes) do
        add(targets, {obj = slime, type = "slime"})
    end

    local can_pickup_hat = false
    for creature in all(self.train.creatures) do
        if not creature.has_hat then
            can_pickup_hat = true
            break
        end
    end

    if can_pickup_hat then
        for hat in all(hats) do
            add(targets, {obj = hat, type = "hat"})
        end
    end

    local best_score = -1
    local best_target = nil

    for target in all(targets) do
        local dist = abs(head_pos.x - target.obj.tile_x) + abs(head_pos.y - target.obj.tile_y)
        if dist > 0 then
            local base_value = (target.type == "hat") and 120 or 100
            local score = base_value / dist
            
            if score > best_score then
                best_score = score
                best_target = target.obj
            end
        end
    end
    
    return best_target
end

function AIController:plan_route(target, opponent_train)
    local head_pos = self.train.path[1]
    
    local dx = target.tile_x - head_pos.x
    local dy = target.tile_y - head_pos.y

    local primary_dir, secondary_dir
    if abs(dx) > abs(dy) then
        primary_dir = (dx > 0) and "right" or "left"
        secondary_dir = (dy > 0) and "down" or "up"
    else
        primary_dir = (dy > 0) and "down" or "up"
        secondary_dir = (dx > 0) and "right" or "left"
    end
    
    local move_options = {}

    local current_dist = abs(dx) + abs(dy)
    local momentum_pos = {x = head_pos.x, y = head_pos.y}
    local dir_vec = get_dir_vector(self.train.direction)
    momentum_pos.x += dir_vec.x
    momentum_pos.y += dir_vec.y
    local new_dist = abs(target.tile_x - momentum_pos.x) + abs(target.tile_y - momentum_pos.y)

    if new_dist < current_dist then
        add(move_options, self.train.direction)
    end

    if primary_dir and not self:is_in_table(move_options, primary_dir) then add(move_options, primary_dir) end
    if secondary_dir and not self:is_in_table(move_options, secondary_dir) then add(move_options, secondary_dir) end

    for dir in all(move_options) do
        if self:is_safe_move(dir, head_pos, opponent_train) then
            return dir
        end
    end
    
    local fallback_dirs = {"up", "down", "left", "right"}
    for dir in all(fallback_dirs) do
        if not self:is_in_table(move_options, dir) then
             if self:is_safe_move(dir, head_pos, opponent_train) then
                return dir
            end
        end
    end

    return self.train.direction
end

function AIController:is_safe_move(dir, head_pos, opponent_train)
    local is_reverse = (dir == "left" and self.train.direction == "right") or
                       (dir == "right" and self.train.direction == "left") or
                       (dir == "up" and self.train.direction == "down") or
                       (dir == "down" and self.train.direction == "up")
    if is_reverse then return false end

    local next_pos = {x = head_pos.x, y = head_pos.y}
    local vec = get_dir_vector(dir)
    next_pos.x += vec.x
    next_pos.y += vec.y

    if is_pos_colliding(next_pos, self.train, opponent_train) then
        return false
    end

    return true
end

function AIController:is_in_table(tbl, value)
    for item in all(tbl) do
        if item == value then return true end
    end
    return false
end
