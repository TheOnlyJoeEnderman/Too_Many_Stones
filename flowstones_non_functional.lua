-- mods/too_many_stones/flowstones.lua

-- support for MT game translation.
local S = minetest.get_translator("too_many_stones")

local growth_interval = 1 -- Adjust this value to set the growth interval in seconds

function too_many_stones.register_flowstone(stone_name, description, texture1, texture2, texture3, texture4, groups)
    -- Attempt to deserialize the provided groups string
    local node_groups = groups

    -- Check if deserialization failed and use a default group table if so
    if not node_groups then
        node_groups = {cracky = 3, attached_node = 1, grey_stone = 1, stone = 1, flowstone = 1}
    end

    -- Register 8 flowstone nodes
    for i = 1, 8 do
        local node_name = "too_many_stones:" .. stone_name .. "_flowstone_" .. i
        local node_description = S(description .. " Pointed Flowstone")
        local node_texture

        -- Assign textures for each variant
        if i <= 4 then
            -- First four use the provided textures
            node_texture = "tms_" .. stone_name .. "_flowstone_" .. i .. ".png"
        else
            -- Last four use mirrored textures of the first four
            local mirrored_index = i - 4
            node_texture = "tms_" .. stone_name .. "_flowstone_" .. mirrored_index .. ".png^[transformFY"
        end

        minetest.register_node(node_name, {
            description = node_description,
            drawtype = "plantlike",
            tiles = {node_texture},
            use_texture_alpha = "clip",
            sunlight_propagates = true,
            paramtype = "light",
            groups = node_groups,
            drop = "too_many_stones:" .. stone_name .. "_flowstone_8",
            sounds = too_many_stones.node_sound_stone_defaults(),
            is_ground_content = false,
        })
    end
end

-- Function to handle flowstone growth
local function grow_flowstones()
    for _, player in ipairs(minetest.get_connected_players()) do
        local pos = player:get_pos()
        local radius = 50 -- Adjust the radius as needed

        for x = -radius, radius do
            for y = -radius, radius do
                for z = -radius, radius do
                    local node_pos = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                    local node = minetest.get_node(node_pos)

                    if node.name:find("too_many_stones:.+_flowstone_[1-4]") then
                        local new_index = tonumber(node.name:match("_flowstone_(%d)")) + 1
                        local new_node_name = node.name:gsub("_flowstone_%d", "_flowstone_" .. new_index)

                        if new_index <= 4 then
                            minetest.set_node(node_pos, {name = new_node_name})
                        else
                            minetest.set_node(node_pos, {name = "air"})
                            minetest.set_node({x = node_pos.x, y = node_pos.y - 1, z = node_pos.z}, {name = "too_many_stones:" .. node.name:match("too_many_stones:(.+)_flowstone_%d")})
                        end
                    elseif node.name:find("too_many_stones:.+_flowstone_[5-8]") then
                        local new_index = tonumber(node.name:match("_flowstone_(%d)")) - 1
                        local new_node_name = node.name:gsub("_flowstone_%d", "_flowstone_" .. new_index)

                        if new_index >= 5 then
                            minetest.set_node(node_pos, {name = new_node_name})
                        else
                            minetest.set_node(node_pos, {name = "air"})
                            minetest.set_node({x = node_pos.x, y = node_pos.y + 1, z = node_pos.z}, {name = "too_many_stones:" .. node.name:match("too_many_stones:(.+)_flowstone_%d")})
                        end
                    end
                end
            end
        end
    end

    minetest.after(growth_interval, grow_flowstones)
end

-- Start the flowstone growth timer
minetest.after(growth_interval, grow_flowstones)

-- Register Flowstones:
too_many_stones.register_flowstone(
    "limestone_blue",
    "Blue Limestone",
    "tms_limestone_blue_flowstone_1.png",
    "tms_limestone_blue_flowstone_2.png",
    "tms_limestone_blue_flowstone_3.png",
    "tms_limestone_blue_flowstone_4.png",
    {limestone = 1, cracky = 3, grey_stone = 1, stone = 1, flowstone = 1}
)

too_many_stones.register_flowstone(
    "limestone_white",
    "White Limestone",
    "tms_limestone_white_flowstone_1.png",
    "tms_limestone_white_flowstone_2.png",
    "tms_limestone_white_flowstone_3.png",
    "tms_limestone_white_flowstone_4.png",
    {limestone = 1, cracky = 3, attached_node = 1, white_stone = 1, stone = 1, flowstone = 1}
)

too_many_stones.register_flowstone(
    "travertine",
    "Travertine",
    "tms_travertine_flowstone_1.png",
    "tms_travertine_flowstone_2.png",
    "tms_travertine_flowstone_3.png",
    "tms_travertine_flowstone_4.png",
    {limestone = 1, cracky = 3, attached_node = 1, yellow_stone = 1, stone = 1, flowstone = 1}
)


too_many_stones.register_flowstone(
    "travertine_yellow",
    "Yellow Travertine",
    "tms_travertine_yellow_flowstone_1.png",
    "tms_travertine_yellow_flowstone_2.png",
    "tms_travertine_yellow_flowstone_3.png",
    "tms_travertine_yellow_flowstone_4.png",
    {limestone = 1, cracky = 3, attached_node = 1, yellow_stone = 1, stone = 1, flowstone = 1}
)

too_many_stones.register_flowstone(
    "geyserite",
    "Geyserite",
    "tms_geyserite_flowstone_1.png",
    "tms_geyserite_flowstone_2.png",
    "tms_geyserite_flowstone_3.png",
    "tms_geyserite_flowstone_4.png",
    {limestone = 1, cracky = 3, grey_stone = 1, stone = 1, flowstone = 1}
)
