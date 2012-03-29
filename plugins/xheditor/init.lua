module(..., package.seeall)

local urlprefix = 'xheditor'
local pathprefix = '../plugins/xheditor/views/'

local TMPLS = {
	['basic'] = pathprefix + 'textarea.html',
}


--[[
class="xheditor {skin:'default'}"
{^ xheditor config="{tools: 'mini', skin: 'default',  }"    ^}


--]]

function main(args, env)
	local class_config = "xheditor "
	if args.class and type(args.class) == 'string' then
		class_config = args.class .. ' ' .. class_config 
	end
	if args.config and type(args.config) == 'string' then
		class_config = class_config .. args.config
	end
	local default_value = args.value or ''
	
	local tmpl = 'basic'
	return View(TMPLS[tmpl]){ class_config=class_config, name=args.name, default_value = default_value }

end


URLS = {
	-- ['/register/'] = register,  -- put register view customized in handler_entry.lua
	--['/' + urlprefix + '/postcomment/'] = postComment,

}

