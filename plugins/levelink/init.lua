module(..., package.seeall)

local urlprefix = 'levelink'
local pathprefix = '../plugins/levelink/views/'

local TMPLS = {
	['radio'] = pathprefix + 'radio.html',
}



--[[

{^ levelink _tag="xxxxx",
	datasource=cats,
	cols = {'value', 'caption'},
	direction = 'horizontal',
	nlevel = 3,
	instance = ...
^}



--]]

local _args_collector = {}

function main(args, env)
	local tmpl = 'radio'
	if not args.tmpl or not TMPLS[args.tmpl] then
		args.tmpl = tmpl
	end

	local _tag = args._tag
	assert(_tag, '[Error] @plugin levelink - missing _tag.')
	_args_collector[_tag] = args
	
	assert(args.nlevel, '[Error] @plugin levelink - missing nlevel.')
	assert(args.datasource, '[Error] @plugin levelink - missing datasource.')
	args._datasource = args.datasource
	args.levels = {}
	args.current_level = 1
	
	return View(pathprefix .. 'container.html')(args)

end

function selectLevel(web, req)
	local params = req.PARAMS
	assert(params._tag, '[Error] @plugin levelink function selectLevel - missing _tag.')
	local _args = _args_collector[params._tag]
	
	-- chosen is a number presenting which item was chosed
	local chosen = tonumber(params.chosen)
	local cl = tonumber(params.current_level)
	if type(_args.current_level) == 'number' then
		_args.current_level = (cl or _args.current_level) + 1
	end
	
	-- if level is valid
	if _args.current_level > _args.nlevel then return web:jsonError() end

	_args.levels[cl] = chosen
	local lenlevel = #_args.levels	
	if cl < lenlevel then
		for i=cl + 1, lenlevel do
			table.remove(_args.levels)
		end
	end

	_args.datasource = table.copy(_args._datasource)
	for j=1, #_args.levels - 1 do
		_args.datasource = _args.datasource[_args.levels[j]].sublevel
	end
	if not _args.datasource[chosen] or not _args.datasource[chosen].sublevel then return web:jsonError() end

	_args.datasource = _args.datasource[chosen].sublevel

	return web:jsonSuccess {
		['htmls'] = View(TMPLS[_args.tmpl])(_args)
	}

end

URLS = {
	['/levelink/select/'] = selectLevel
}

