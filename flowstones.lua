-- mods/too_many_stones/flowstones.lua

-- support for MT game translation.
local S = minetest.get_translator("too_many_stones")

local growth_interval = 1 -- Adjust this value to set the growth interval in seconds
local growth_chance = 0.5 -- Adjust this value to set the chance of growth (0.0 to 1.0)

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

                    if math.random() < growth_chance then
                        if node.name:find("too_many_stones:.+_flowstone_1") then
                            -- flowstone 1 is the widest variant pointed down and will be attached to ceilings and has little effects
                            -- No changes needed
                        elseif node.name:find("too_many_stones:.+_flowstone_2") then
                            -- flowstone 2 can be repeated infinitely if need be and will never replace the one above it unless it is not 1 or 2
                            local node_above = minetest.get_node({x = node_pos.x, y = node_pos.y + 1, z = node_pos.z})
                            if not node_above.name:find("too_many_stones:.+_flowstone_[1-2]") then
                                minetest.set_node(node_pos, {name = "too_many_stones:" .. node.name:match("too_many_stones:(.+)_flowstone_2")})
                            end
                        elseif node.name:find("too_many_stones:.+_flowstone_3") then
                            -- flowstone 3 will replace the one above with 2 if it is 3 and the one below with 4 if it is air
                            local node_above = minetest.get_node({x = node_pos.x, y = node_pos.y + 1, z = node_pos.z})
                            local node_below = minetest.get_node({x = node_pos.x, y = node_pos.y - 1, z = node_pos.z})
                            if node_above.name:find("too_many_stones:.+_flowstone_3") then
                                minetest.set_node({x = node_pos.x, y = node_pos.y + 1, z = node_pos.z}, {name = "too_many_stones:" .. node.name:match("too_many_stones:(.+)_flowstone_2")})
                            end
                            if node_below.name == "air" then
                                minetest.set_node({x = node_pos.x, y = node_pos.y - 1, z = node_pos.z}, {name = "too_many_stones:" .. node.name:match("too_many_stones:(.+)_flowstone_4")})
                            end
                        elseif node.name:find("too_many_stones:.+_flowstone_4") then
                            -- flowstone 4 will replace the one below with air and the one above with 3
                            minetest.set_node({x = node_pos.x, y = node_pos.y - 1, z = node_pos.z}, {name = "air"})
                            minetest.set_node({x = node_pos.x, y = node_pos.y + 1, z = node_pos.z}, {name = "too_many_stones:" .. node.name:match("too_many_stones:(.+)_flowstone_3")})
                        elseif node.name:find("too_many_stones:.+_flowstone_5") then
                            -- flowstone 5 should be the widest and attach to the ground instead of the ceiling
                            -- No changes needed
                        elseif node.name:find("too_many_stones:.+_flowstone_6") then
                            -- flowstone 6 should be repeatable according to the rules of 2 but flipped top to bottom
                            local node_below = minetest.get_node({x = node_pos.x, y = node_pos.y - 1, z = node_pos.z})
                            if not node_below.name:find("too_many_stones:.+_flowstone_[5-6]") then
                                minetest.set_node(node_pos, {name = "too_many_stones:" .. node.name:match("too_many_stones:(.+)_flowstone_6")})
                            end
                        elseif node.name:find("too_many_stones:.+_flowstone_7") then
                            -- flowstone 7 should be the same as 3 but flipped top to bottom by replacing the one above with 8 and the one below with 6 unless the one above already is 8 obviously
                            local node_above = minetest.get_node({x = node_pos.x, y = node_pos.y + 1, z = node_pos.z})
                            local node_below = minetest.get_node({x = node_pos.x, y = node_pos.y - 1, z = node_pos.z})
                            if node_below.name:find("too_many_stones:.+_flowstone_7") then
                                minetest.set_node({x = node_pos.x, y = node_pos.y - 1, z = node_pos.z}, {name = "too_many_stones:" .. node.name:match("too_many_stones:(.+)_flowstone_6")})
                            end
                            if node_above.name == "air" and not node_above.name:find("too_many_stones:.+_flowstone_8") then
                                minetest.set_node({x = node_pos.x, y = node_pos.y + 1, z = node_pos.z}, {name = "too_many_stones:" .. node.name:match("too_many_stones:(.+)_flowstone_8")})
                            end
                        elseif node.name:find("too_many_stones:.+_flowstone_8") then
                            -- flowstone 8 should replace air above with 8 and flowstone below with 7
                            minetest.set_node({x = node_pos.x, y = node_pos.y + 1, z = node_pos.z}, {name = "too_many_stones:" .. node.name:match("too_many_stones:(.+)_flowstone_8")})
                            minetest.set_node({x = node_pos.x, y = node_pos.y - 1, z = node_pos.z}, {name = "too_many_stones:" .. node.name:match("too_many_stones:(.+)_flowstone_7")})
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
