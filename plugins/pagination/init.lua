module (..., package.seeall)

local _args_collector = {}
local path='../plugins/pagination/views/'
local TMPLS = {
	['pagin_a_ajax'] = path .. 'pagin_a_ajax.html',
	['pagin_select_ajax'] = path .. 'pagin_select_ajax.html',	
	['pagin_a'] = path .. 'pagin_a.html',
	['pagin_select'] = path .. 'pagin_select.html',		
}

function helper(_tag)
	local params = req.PARAMS
	local _args = _args_collector[_tag]
	
	local thepage = tonumber(params.thepage) or 1
	if thepage < 1 then thepage = 1 end
	local totalpages = tonumber(params.totalpages) or 1
	if totalpages and thepage > totalpages then thepage = totalpages end
	local npp = tonumber(params.npp) or tonumber(_args.npp) or 5
	local starti = (thepage-1) * npp + 1
	local endi = thepage * npp
	local paginurl = params.paginurl or _args.paginurl
	local callback = _args.callback
	
	local totalnum, htmlcontent
	local datasource
	if not _args.callback then
		assert(_args.content_tmpl)
		-- if supply datasource
		if isList(_args.orig_datasource) then
			datasource = _args.orig_datasource or List()
			totalnum = #datasource
			if totalnum then
				totalpages = math.ceil(totalnum/npp)
				if thepage > totalpages	then thepage = totalpages end
			end

			datasource = datasource:slice(starti, endi)
			_args.datasource = datasource
			local content_tmpl = _args.content_tmpl 
			htmlcontent = View(content_tmpl)(_args)
--			print(totalnum, htmlcontent)
		else
			-- if supply model name, query_args, is_rev
			assert(type(_args.model) == 'string')
			
			local model = bamboo.getModelByName(_args.model)
			assert(model)
			-- if query_args is 'all'
			if not _args.query_args or _args.query_args == 'all' then
				totalnum = model:numbers()
				if _args.is_rev == 'rev' then
					datasource = model:slice(-endi, -starti, 'rev')
				else
					datasource = model:slice(starti, endi)					
				end
			else
				-- if query_args is table or function
				assert(type(_args.query_args) == 'table' or type(_args.query_args) == 'function') 
				if _args.is_rev == 'rev' then
					datasource = model:filter(_args.query_args, -endi, -starti, 'rev')
				else
					datasource = model:filter(_args.query_args, starti, endi)					
				end
				totalnum = model:count(_args.query_args)
			end
			_args.datasource = datasource
			htmlcontent = View(_args.content_tmpl)(_args)			
			
		end
	else
		-- if supply callback
		if type(callback) == 'string' then
			local callback_func = bamboo.getPluginCallbackByName(callback)
			assert(type(callback_func) == 'function')
			-- the callback should return 2 values: html fragment and totalnum
			htmlcontent, totalnum = callback_func(starti, endi)
		elseif type(callback) == 'function' then
			htmlcontent, totalnum = callback(starti, endi)
		end
	end
	local prevpage = thepage - 1
	if prevpage < 1 then prevpage = 1 end
	local nextpage = thepage + 1
	if nextpage > totalpages then nextpage = totalpages end
	
	return {
		['_tag'] = _tag,
		['totalnum'] = totalnum,
		['htmlcontent'] = htmlcontent, 
		['totalpages'] = totalpages, 
		['npp'] = npp, 
		['paginurl'] = paginurl, 
		['thepage'] = thepage, 
		['prevpage'] = prevpage, 
		['nextpage'] = nextpage
	}
end


--[[

{^ pagination datasource=all_persons, content_tmpl="item.html", npp=20,  ^}

--]]
function main(args, env)
	assert(args._tag, '[Error] @plugin pagination - missing _tag.')
	_args_collector[args._tag] = args
	assert(args.paginurl, '[Error] @plugin pagination - missing paginurl.')

--	assert(type(args.callback) == 'string' and type(bamboo.getPluginCallbackByName(args.callback)) == 'function', '[Error] callback missing in plugin paginator.')
	if args.datasource then
		_args_collector[args._tag].orig_datasource = args.datasource
	end
	
	-- default choose pagin_a style
	args.tmpl = args.tmpl or 'pagin_select_ajax'
	return View(TMPLS[args.tmpl]) (helper(args._tag))
end

function page(web, req)
	local params = req.PARAMS
	assert(params._tag, '[Error] @plugin pagination function page - missing _tag.')
	_args = _args_collector[params._tag]
	
	return web:page(View(TMPLS[_args.tmpl])(helper(params._tag)))
end

function json(web, req)
	local params = req.PARAMS
	assert(params._tag, '[Error] @plugin pagination function json - missing _tag.')
	_args = _args_collector[params._tag]
	
	return web:jsonSuccess(helper(params._tag))
end
