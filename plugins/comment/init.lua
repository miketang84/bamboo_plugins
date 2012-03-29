module(..., package.seeall)

local Comment = require 'plugins.comment.models.comment'
bamboo.registerModel(Comment)
--DEBUG(bamboo.MODEL_LIST)

local urlprefix = 'comment'
local pathprefix = '../plugins/comment/views/'

local TMPLS = {
	['new_basic'] = pathprefix + 'new_basic.html',
	['list_basic'] = pathprefix + 'list_basic.html',
}

function main(args, env)
	DEBUG(args, env)
	local tmpl = args.tmpl or 'new_basic'
	
	if tmpl == 'list_basic' then
		local modelname = args.target_model
		local target_model = bamboo.getModelByName(modelname)
		local target_id = args.target_id
		local target = target_model:getById(target_id)
			
		local comments = target:getForeign('comments')

		
		return View(TMPLS[tmpl]){ comments = comments }
		
	elseif tmpl == 'new_basic' then
		
		return View(TMPLS[tmpl]){ args = args }
	end

end

local postComment = function (web, req)
	local params = req.PARAMS
	local flag, err_msg = Comment:validate(params)
	if not flag then return nil end
	
	local c = {
		content = params.comment_content
	}
	local comment = Comment(c)
	comment:save()
	
	DEBUG(params)
	local modelname = params.target_model
	local target_model = bamboo.getModelByName(modelname)
	local target_id = params.target_id
	local target = target_model:getById(target_id)
	if target then
		comment:addForeign('target', target)
		target:addForeign('comments', comment)
	end
	
	if req.user then
		comment:addForeign('user', req.user)
	end
	
	local target_url = params.target_url
	return web:redirect(target_url)	
end


URLS = {
	-- ['/register/'] = register,  -- put register view customized in handler_entry.lua
	['/' + urlprefix + '/postcomment/'] = postComment,

}

function isRequestForUser(req)
	return req.path:startsWith('/' .. urlprefix)
end
