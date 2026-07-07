local const = require("scripts/constants") ---@module "belt-visualizer/scripts/constants"
local color = const.color
local width = const.width
local dash_length = const.dash_length
local gap_length = const.gap_length
local curved = const.curved
local arc_radius = const.arc_radius
local radius = const.radius

local draw = {}

---@param data BeltVisualizer.Data
---@param entity LuaEntity
---@param from_offset Vector
---@param to_offset Vector
function draw.line(data, entity, from_offset, to_offset)
    local drawn = data.drawn_offsets[entity.unit_number]
    if not drawn then
        drawn = {}
        data.drawn_offsets[entity.unit_number] = drawn
    end
    if drawn[from_offset] and drawn[to_offset] then return end
    drawn[from_offset] = true
    drawn[to_offset] = true
    local render = rendering.draw_line{
        color = color,
        width = width,
        from = {entity = entity, offset = from_offset},
        to = {entity = entity, offset = to_offset},
        surface = entity.surface,
        players = {data.index},
    }
    data.render[render.id] = render
end

---@param data BeltVisualizer.Data
---@param from LuaEntity
---@param to LuaEntity
---@param from_offset Vector
---@param to_offset Vector
function draw.dash(data, from, to, from_offset, to_offset)
    local render = rendering.draw_line{
        color = color,
        width = width,
        from = {entity = from, offset = from_offset},
        to = {entity = to, offset = to_offset},
        dash_length = dash_length,
        gap_length = gap_length,
        surface = from.surface,
        players = {data.index},
    }
    data.render[render.id] = render
end

---@param data BeltVisualizer.Data
---@param entity LuaEntity
---@param lane 1|2
---@param clockwise boolean
function draw.arc(data, entity, lane, clockwise)
    local drawn = data.drawn_arcs[entity.unit_number]
    if not drawn then
        drawn = {}
        data.drawn_arcs[entity.unit_number] = drawn
    end
    if drawn[lane] then return end
    drawn[lane] = true
    local offset = ((clockwise and 4 or 0) + entity.direction) % 16
    lane = clockwise and lane % 2 + 1 or lane
    local radii = arc_radius[lane]
    local render = rendering.draw_arc{
        color = color,
        min_radius = radii.min,
        max_radius = radii.max,
        start_angle = math.rad(offset * 45 / 2) --[[@as float]],
        angle = math.rad(90) --[[@as float]],
        target = {entity = entity, offset = curved[offset]},
        surface = entity.surface,
        players = {data.index},
    }
    data.render[render.id] = render
end

---@param data BeltVisualizer.Data
---@param entity LuaEntity
---@param offset Vector
function draw.circle(data, entity, offset)
    local render = rendering.draw_circle{
        color = color,
        radius = radius,
        filled = true,
        target = {entity = entity, offset = offset},
        surface = entity.surface,
        players = {data.index},
    }
    data.render[render.id] = render
end

---@param data BeltVisualizer.Data
---@param entity LuaEntity
---@param offsets BoundingBox
function draw.rectangle(data, entity, offsets)
    local render = rendering.draw_rectangle{
        color = color,
        filled = true,
        left_top = {entity = entity, offset = offsets.left_top},
        right_bottom = {entity = entity, offset = offsets.right_bottom},
        surface = entity.surface,
        players = {data.index},
    }
    data.render[render.id] = render
end

return draw