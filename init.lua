--[[
death_messages - A Minetest mod which sends a chat message when a player dies.
Copyright (C) 2016  EvergreenTree

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

--------------------------------------------------------------------------------
local title = "Death Messages"
local version = "0.1.4"
local mname = "death_messages"
--------------------------------------------------------------------------------
dofile(minetest.get_modpath("death_messages").."/settings.txt")
--------------------------------------------------------------------------------

-- A table of quips for death messages.  The first item in each sub table is the
-- default message used when RANDOM_MESSAGES is disabled.
local messages = {}

-- create a table of players and their death count
local death_count = {}

-- set the PCRS_deaths.json file path to be in the death_messages mod folder
local file_path = minetest.get_modpath("death_messages").."/scoreboard/PCRS_deaths.sqlite"

-- read death_count from json if PCRS_deaths.json exists
local file = io.open(file_path, "r")
if file ~= nil then
	death_count = minetest.parse_json(file:read("*all"))
	file:close()
end

-- Lava death messages
messages.lava = {
    " melted into a ball of fire.",
    " thought lava was cool.",
    " melted into a ball of fire.",
    " couldn't resist that warm glow of lava.",
    " dug straight down.",
    " didn't know lava was hot."
}

-- Drowning death messages
messages.water = {
    " drowned.",
    " ran out of air.",
    " failed at swimming lessons.",
    " tried to impersonate an anchor.",
    " forgot he wasn't a fish.",
    " blew one too many bubbles."
}

-- Burning death messages
messages.fire = {
    " burned to a crisp.",
    " got a little too warm.",
    " got too close to the camp fire.",
    " just got roasted, hotdog style.",
    " got burned up. More light that way."
}

-- Other death messages
messages.other = {
    " died.",
    " did something fatal.",
    " gave up on life.",
    " is somewhat dead now.",
    " passed out -permanently."
}

function get_message(mtype)
    if RANDOM_MESSAGES then
        return messages[mtype][math.random(1, #messages[mtype])]
    else
        return messages[1] -- 1 is the index for the non-random message
    end
end

-- periodically run to save death_count to json
local function save_deaths()
	-- check if PCRS_deaths.json exists and if not create it
	local file = io.open(file_path, "r")
	if file == nil then
		file = io.open(file_path, "w")
		file:write(minetest.write_json(death_count))
		file:close()
	end

	-- update the json file PCRS_deaths.json with the death_count table and the last death message
	file = io.open(file_path, "w")
	file:write(minetest.write_json(death_count))
	file:close()
end

-- save death_count to json every 5 minutes
minetest.register_globalstep(function(dtime)
	local timer = 0
	timer = timer + dtime
	if timer >= 300 then
		save_deaths()
		timer = 0
	end
end)

minetest.register_on_dieplayer(function(player)
    local player_name = player:get_player_name()
    local node = minetest.registered_nodes[
        minetest.get_node(player:getpos()).name
    ]

	-- check if player is in deathcount table and add if not add them
	if death_count[player_name] == nil then
		death_count[player_name] = 1
	else
		death_count[player_name] = death_count[player_name] + 1
	end

    if minetest.is_singleplayer() then
        player_name = "You"
    end
    -- Death by lava
    if node.groups.lava ~= nil then
        minetest.chat_send_all(player_name .. get_message("lava"))
    -- Death by drowning
    elseif player:get_breath() == 0 then
        minetest.chat_send_all(player_name .. get_message("water"))
    -- Death by fire
    elseif node.name == "fire:basic_flame" then
        minetest.chat_send_all(player_name .. get_message("fire"))
	-- Death by falling
	elseif node.name == "air" then
		minetest.chat_send_all(player_name .. " fell to their death.")
	-- Death by node with animal in name
	elseif string.find(node.name, "animal") then
		minetest.chat_send_all(player_name .. " was killed by an animal.")
    -- Death by something else
    else
        minetest.chat_send_all(player_name .. get_message("other"))
    end

end)

--------------------------------------------------------------------------------
print("[Mod] "..title.." ["..version.."] ["..mname.."] Loaded...")
--------------------------------------------------------------------------------
