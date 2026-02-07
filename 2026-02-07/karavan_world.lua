-- karavan_world.lua
-- Hanterar spelvärlden, kamera och kollisioner

World = {}
World.__index = World

function World.new(map_x, map_y, screen_x, screen_y, w_tiles, h_tiles)
    local self = setmetatable({}, World)
    
    -- Var på kartan vi ritar ifrån
    self.map_x = map_x or 0
    self.map_y = map_y or 0
    
    -- Var på skärmen vi ritar till
    self.screen_x = screen_x or 0
    self.screen_y = screen_y or 0
    
    -- Hur många tiles (bredd/höjd) som ska ritas
    self.w_tiles = w_tiles or 16
    self.h_tiles = h_tiles or 16
    
    -- Spara även storleken i pixlar
    self.w_pixels = self.w_tiles * 8
    self.h_pixels = self.h_tiles * 8
    
    self.camera_x = 0
    self.camera_y = 0
    return self
end


function World:update(target)
    -- Om scroll_margin är 0, rör inte kameran.
    if self.scroll_margin_tiles == 0 then
        return
    end

    -- Definiera scroll-zonen på skärmen
    local margin = self.scroll_margin_pixels
    local screen_w = 128
    local screen_h = 128
    
    local left_bound = self.camera_x + margin
    local right_bound = self.camera_x + screen_w - margin
    local top_bound = self.camera_y + margin
    local bottom_bound = self.camera_y + screen_h - margin

    -- Justera kameran om spelaren är utanför zonen
    if target.x < left_bound then
        self.camera_x = target.x - margin
    end
    if target.x > right_bound then
        self.camera_x = target.x - screen_w + margin
    end
    if target.y < top_bound then
        self.camera_y = target.y - margin
    end
    if target.y > bottom_bound then
        self.camera_y = target.y - screen_h + margin
    end
    
    -- Se till att kameran inte scrollar utanför världens gränser
    local max_cam_x = self.w_pixels - screen_w
    local max_cam_y = self.h_pixels - screen_h
    
    self.camera_x = mid(0, self.camera_x, max_cam_x)
    self.camera_y = mid(0, self.camera_y, max_cam_y)
end

function World:draw()
    -- Använd kamera-inställningarna från update, rita sedan kartan
    camera(self.camera_x, self.camera_y)
    map(self.map_x, self.map_y, self.screen_x, self.screen_y, self.w_tiles, self.h_tiles)
    camera() -- Återställ kameran för UI etc.
end

function World:is_passable(x, y)
    -- 1. Kolla världens gränser
    if x < 0 or x >= self.w_pixels or y < 0 or y >= self.h_pixels then
        return false
    end
    
    -- 2. Kolla sprite-flaggor på kartan
    -- VIKTIGT: Lägg till self.map_x och self.map_y för att kolla rätt del av kartan!
    local tile_x = flr(x / 8) + self.map_x
    local tile_y = flr(y / 8) + self.map_y
    local sprite_id = mget(tile_x, tile_y)
    
    if fget(sprite_id, 0) then
        return false -- Flagga 0 betyder "solid"
    end
    
    return true
end