module(..., package.seeall)

local urlprefix = 'managetable'
local pathprefix = '../plugins/managetable/views/'

local TMPLS = {
	['basic'] = pathprefix + 'basic.html',
}


local pagination = require 'plugins.pagination'
bamboo.registerPlugin('pagination', pagination)


--[[
{% 	local goodworks = function (instance)
		local htmls = {}
		local images = instance:getForeign('images'); 
		if images then 
			for i, v in ipairs(images) do
				table.insert(htmls, '<a href="/${href}">${imagename}</a><br/>' % {href = v.path, imagename = v.imagename})
			end 
		end

		return table.concat(htmls)
	end
%}


{^ managetable datasource = artists,
	thead = { '艺术家', '代表作品', '流派', '国家', '圈子', '简介'  },
	tbody = { 'artistname', goodworks, 'style', 'country', 'sphere', 'brief'  },	
--	colstyle = {  }	     
     
^}


--]]

local _args_collector = {}

function main(args, env)
	local tmpl = 'basic'

	local _tag = args._tag
	assert(_tag, '[Error] @plugin managetable - missing _tag.')
	_args_collector[_tag] = args
	
	local edit_url = args.edit_url
	assert(edit_url, '[Error] @plugin managetable - missing edit_url.')
	local del_url = args.del_url
	assert(del_url, '[Error] @plugin managetable - missing del_url.')

	local thead = args.thead or {}
	local tbody = args.tbody or {}	
	local datasource = args.datasource or {}

	return View(TMPLS[tmpl]){ _tag=_tag, thead=thead, tbody=tbody, datasource=datasource, edit_url=edit_url, del_url=del_url }

end

--[[
function action_edit(web, req)
	local params = req.PARAMS
	local modelname = params.model
	if isFalse(modelname) then print('[Warning] @plugin managetable - must specify model name.'); return web:notFound() end
	local item_id = params.item_id
	if isFalse(item_id) then print('[Warning] @plugin managetable - must specify item id.'); return web:notFound() end
	
	local model = bamboo.getModelByName(modelname)
	local instance = model:getById(item_id)
	if not instance then return web:notFound() end
	if _args.edit_callback and type(_args.edit_callback) == 'function' then
		return web:page(_args.edit_callback(instance))
	else	
		assert(_args.edit_tmpl)
		return web:page(View(edit_tmpl){ instance = instance })
	end
	
end

function action_del(web, req)
	local params = req.PARAMS
	local modelname = params.model
	if isFalse(modelname) then print('[Warning] @plugin managetable - must specify model name.'); return web:notFound() end
	local item_id = params.item_id
	if isFalse(item_id) then print('[Warning] @plugin managetable - must specify item id.'); return web:notFound() end

	local model = bamboo.getModelByName(modelname)
	local instance = model:getById(item_id)
	if not instance then return web:notFound() end
	
	print('ready to del this instance.')
	-- at least remand user to login in 
	if req.user then
		instance:del()
	end
--	fptable(req)
	return web:redirect(req.headers['referer'])
	
end
--]]

URLS = {
--	['/managetable/edit/'] = action_edit,  -- put register view customized in handler_entry.lua
--	['/managetable/del/'] = action_del,  -- put register view customized in handler_entry.lua
	['/managetable/paginjson/'] = pagination.json,  -- put register view customized in handler_entry.lua	
	['/managetable/paginpage/'] = pagination.page,  -- put register view customized in handler_entry.lua	
	--['/' + urlprefix + '/postcomment/'] = postComment,

}

