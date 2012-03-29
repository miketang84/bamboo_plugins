module(..., package.seeall)
local User = require 'bamboo.models.user'

local MODEL_NAME = 'User'

_M['this_model'] = User:extend {
	__tag = 'Bamboo.Model.User.' .. MODEL_NAME;
	__name = MODEL_NAME;
	__desc = 'Generitic '.. MODEL_NAME ..' definition';
	__indexfd = "username";
	__fields = {
		['username'] = { required=true, unique=true },
		['password'] = { required=true },
		['salt'] = {},
		['email'] = { required=true },
		['nickname'] = {},
	};

	init = function (self, t)
		if not t then return self end

		return self
	end;

}

return _M['this_model']
