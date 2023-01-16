require("mod-gui")

local mod = nil

local function queue()
	return {first = 0, last = -1}
end

local function qlen(list)
	return math.max(0, list.last - list.first + 1)
end

local function first(list)
	return list[list.first]
end

local function last(list)
	return list[list.last]
end

local function shove (list, value)
	local first = list.first - 1
	list.first = first
	list[first] = value
end

local function push (list, value)
	local last = list.last + 1
	list.last = last
	list[last] = value
end

local function shift (list)
	local first = list.first
	if first > list.last then return nil end
	local value = list[first]
	list[first] = nil
	list.first = first + 1
	return value
end

local function pop (list)
	local last = list.last
	if list.first > last then return nil end
	local value = list[last]
	list[last] = nil
	list.last = last - 1
	return value
end

local function check_state()
	mod = global
	if not mod.entities then
		mod.entities = queue()
		for _, surface in pairs(game.surfaces) do
			for _, en in ipairs(surface.find_entities_filtered({name = {'smr-generator-1', 'smr-generator-2', 'smr-generator-3'}})) do
				push(mod.entities, en)
			end
		end
	end
end

local debug = true

local function note(msg)
	if debug then
		game.print(msg)
	end
end

local function serialize(t)
	if type(t) == "table" then
		local s = {}
		for k,v in pairs(t) do
			if type(v) == "table" then
				v = serialize(v)
			end
			s[#s+1] = tostring(k).." = "..tostring(v)
		end
		return "{ "..table.concat(s, ", ").." }"
	else
		return tostring(t)
	end
end

local function prefixed(str, start)
	return str:sub(1, #start) == start
end

local function suffixed(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

local function on_create_entity(event)
	local entity = event.created_entity
	if entity and entity.valid and prefixed(entity.name, 'smr-generator-') then
		push(mod.entities, entity)
		local stack = event.stack
		local energy = stack.get_tag('buffer_energy')
		local health = stack.get_tag('real_health')
		if energy then
			entity.energy = tonumber(energy)
			entity.health = tonumber(health)
		else
			entity.energy = entity.prototype.electric_energy_source_prototype.buffer_capacity
		end
	end
end

local function on_remove_entity(event)
	local entity = event.entity
	if entity and entity.valid and event.buffer then
		for i = 1,#event.buffer do
			local stack = event.buffer[i]
			if stack and stack.valid and stack.valid_for_read then
				local name = stack.name
				if prefixed(name, 'smr-generator-') and not suffixed(name, '-depleted')
					and entity.energy < entity.prototype.electric_energy_source_prototype.buffer_capacity
				then
					if entity.energy < 1000 then
						event.buffer.remove({ type = 'item', name = name, amount = 1 })
						event.buffer.insert({ type = 'item', name = name..'-depleted', amount = 1 })
					else
						stack.set_tag('buffer_energy', entity.energy)
						stack.set_tag('real_health', entity.health)
						stack.health = math.max(0.001, entity.energy / entity.prototype.electric_energy_source_prototype.buffer_capacity)
					end
					break
				end
			end
		end
	end
end

local function on_nth_tick()
	check_state()

	local entity = shift(mod.entities)

	if entity and entity.valid then
		if entity.energy < 1 and entity.order_deconstruction(entity.force) then
			entity.surface.create_entity({
				name = 'entity-ghost',
				inner_name = entity.name,
				position = entity.position,
				force = entity.force,
			})
		end
		push(mod.entities, entity)
	end
end

local function attach_events()
	if settings.startup['smr-autodeconstruct'].value then
		script.on_nth_tick(60, on_nth_tick)
	end
	script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, on_create_entity)
	script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity, defines.events.on_entity_died}, on_remove_entity)
end

script.on_init(function()
	check_state()
	attach_events()
end)

script.on_load(function()
	attach_events()
end)
