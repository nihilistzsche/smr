local function generator(name, upgrade, capacity, flow, order, create, recharge, eingredients)

	--local eei = table.deepcopy(data.raw['electric-energy-interface']['electric-energy-interface'])
	local eei = table.deepcopy(data.raw['accumulator']['accumulator'])

	eei.name = name
	eei.energy_source.buffer_capacity = capacity
	eei.energy_source.input_flow_limit = '0kW'
	eei.energy_source.output_flow_limit = flow
	eei.minable.result = name
	eei.energy_production = '0kW'
	eei.next_upgrade = upgrade
	eei.fast_replaceable_group = 'smr-generators'
	eei.dying_explosion = 'massive-explosion'

	eei.picture = {
		filename = '__smr__/graphics/'..name..'-frames-lr.png',
		width = 96,
		height = 96,
		hr_version = {
			filename = '__smr__/graphics/'..name..'-frames-hr.png',
			width = 192,
			height = 192,
			scale = 0.5,
		}
	}
	eei.charge_animation = nil
	eei.charge_light = nil
	eei.discharge_animation = {
		frame_count = 30,
		filename = '__smr__/graphics/'..name..'-frames-lr.png',
		line_length = 5,
		width = 96,
		height = 96,
		hr_version = {
			frame_count = 30,
			filename = '__smr__/graphics/'..name..'-frames-hr.png',
			line_length = 5,
			width = 192,
			height = 192,
			scale = 0.5,
		}
	}
	--eei.discharge_light = nil

	eei.icon = '__smr__/graphics/'..name..'.png'
	eei.icon_size = 32

	data:extend({eei})

	local order = 'f[nuclear-energy]-z['..order..'-'..name..']'

	local ingredients = {
		{ type = 'item', name = 'uranium-fuel-cell', amount = create },
	}
	for _, item in ipairs(eingredients) do
		ingredients[#ingredients+1] = item
	end

	local ringredients = {
		{ type = 'item', name = 'uranium-fuel-cell', amount = recharge },
		{ type = 'item', name = name..'-depleted', amount = 1 },
	}

	data:extend({
		{
			type = 'item-with-tags',
			name = name,
			icon = '__smr__/graphics/'..name..'.png',
			icon_size = 32,
			stack_size = 10,
			subgroup = 'energy',
			place_result = name,
			order = order,
		},
		{
			type = 'item',
			name = name..'-depleted',
			icon = '__smr__/graphics/'..name..'-depleted.png',
			icon_size = 32,
			stack_size = 10,
			subgroup = 'energy',
			order = order,
		},
		{
			type = 'recipe',
			name = name,
			category = 'crafting',
			subgroup = 'energy',
			enabled = false,
			icon = '__smr__/graphics/'..name..'.png',
			icon_size = 32,
			hidden = false,
			energy_required = 60.0,
			ingredients = ingredients,
			results = {
				{ type = 'item', name = name, amount = 1 },
			},
			order = order,
		},
		{
			type = 'recipe',
			name = name..'-recharge',
			category = 'crafting',
			subgroup = 'energy',
			enabled = false,
			icon = '__smr__/graphics/'..name..'-recharge.png',
			icon_size = 32,
			hidden = false,
			energy_required = 30.0,
			ingredients = ringredients,
			results = {
				{ type = 'item', name = name, amount = 1 },
			},
			order = order,
		},
	})
end

generator('smr-generator-1', 'smr-generator-2', '10GJ', '5MW', 'a', 2, 2, { -- 0.625
	{ type = 'item', name = 'nuclear-reactor', amount = 1 },
	{ type = 'item', name = 'battery-equipment', amount = 5 },
})

generator('smr-generator-2', 'smr-generator-3', '100GJ', '25MW', 'b', 16, 15, { -- 0.78, 0.83
	{ type = 'item', name = 'smr-generator-1', amount = 1 },
	{ type = 'item', name = 'battery-mk2-equipment', amount = 5 },
})

generator('smr-generator-3', nil, '500GJ', '50MW', 'c', 70, 65, { -- 0.89, 0.96
	{ type = 'item', name = 'smr-generator-2', amount = 1 },
	{ type = 'item', name = 'fusion-reactor-equipment', amount = 5 },
})

data:extend({
	{
		type = 'technology',
		name = 'smr-tech1',
		icon = '__smr__/graphics/tech1.png',
		icon_size = 128,
		effects = {
			{ type = 'unlock-recipe', recipe = 'smr-generator-1' },
			{ type = 'unlock-recipe', recipe = 'smr-generator-1-recharge' },
		},
		prerequisites = {
			'nuclear-power',
			'battery-equipment',
		},
		unit = {
			count = 300,
			ingredients = {
				{'automation-science-pack', 1},
				{'logistic-science-pack', 1},
				{'chemical-science-pack', 1},
			},
			time = 30
		},
		order = 'a',
	},
	{
		type = 'technology',
		name = 'smr-tech2',
		icon = '__smr__/graphics/tech2.png',
		icon_size = 128,
		effects = {
			{ type = 'unlock-recipe', recipe = 'smr-generator-2' },
			{ type = 'unlock-recipe', recipe = 'smr-generator-2-recharge' },
		},
		prerequisites = {
			'smr-tech1',
			'battery-mk2-equipment',
		},
		unit = {
			count = 400,
			ingredients = {
				{'automation-science-pack', 1},
				{'logistic-science-pack', 1},
				{'chemical-science-pack', 1},
				{'production-science-pack', 1},
			},
			time = 30
		},
		order = 'b',
	},
	{
		type = 'technology',
		name = 'smr-tech3',
		icon = '__smr__/graphics/tech3.png',
		icon_size = 128,
		effects = {
			{ type = 'unlock-recipe', recipe = 'smr-generator-3' },
			{ type = 'unlock-recipe', recipe = 'smr-generator-3-recharge' },
		},
		prerequisites = {
			'smr-tech2',
			'fusion-reactor-equipment',
		},
		unit = {
			count = 500,
			ingredients = {
				{'automation-science-pack', 1},
				{'logistic-science-pack', 1},
				{'chemical-science-pack', 1},
				{'production-science-pack', 1},
				{'utility-science-pack', 1},
			},
			time = 30
		},
		order = 'c',
	},
})