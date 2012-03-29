module(..., package.seeall)

local User = require 'plugins.user.models.simpleuser'
bamboo.registerMainUser(User)
--DEBUG(bamboo.MODEL_LIST)

local urlprefix = 'user'

local TMPLS = {
	['login'] = '../plugins/simpleuser/views/login.html',
	['register'] = '../plugins/simpleuser/views/register.html',
	['register_successfully'] =  '../plugins/simpleuser/views/register_successfully.html',
	['register_failed'] =  '../plugins/simpleuser/views/register_failed.html',
	['login_successfully'] =  '../plugins/simpleuser/views/login_successfully.html',
	['login_failed'] =  '../plugins/simpleuser/views/login_failed.html',
	['logout'] =  '../plugins/simpleuser/views/logout.html',
}

function main(args)
	DEBUG(args)
	local tmpl = (args.tmpl == 'login') and 'login' or 'register'

	return View(TMPLS[tmpl]){ args = args }
end

local postRegister = function (web, req)
	local params = req.PARAMS
	local user, error_code, error_desc = User:register(params)
	if not user then 
		DEBUG(error_code, error_desc)
		return web:page(View(TMPLS['register_failed']){})
	end
	
	DEBUG('user register successfully')
	return web:page(View(TMPLS['register_successfully']){})
	
end

local postLogin = function (web, req)
	local params = req.PARAMS
	
	local user = User:login (params)
	if not user then 
		DEBUG('user login failed.')
		return web:page(View(TMPLS['login_failed']){})
	end
	
	DEBUG('user login successfully')
	return web:page(View(TMPLS['login_successfully']){})

end

local logout = function (web, req)
	User:logout()
	return web:page(View(TMPLS['logout']){})

end

local update = function (web, req)


end

local forgotpwd = function (web, req)


end

URLS = {
	-- ['/register/'] = register,  -- put register view customized in handler_entry.lua
	['/' + urlprefix + '/postregister/'] = postRegister,
	-- ['/login/'] = login,  -- put login view customized in handler_entry.lua	
	['/' + urlprefix + '/postlogin/'] = postLogin,	
	-- ['/edit/'] = edit,  -- put edit view customized in handler_entry.lua		
	['/' + urlprefix + '/update/'] = update,
	['/' + urlprefix + '/forgotpwd/'] = forgotpwd,
	['/logout/'] = logout,

}
