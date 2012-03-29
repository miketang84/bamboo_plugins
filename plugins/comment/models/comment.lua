module(..., package.seeall)
local Model = require 'bamboo.model'

local MODEL_NAME = 'Comment'

_M['this_model'] = Model:extend {
	__tag = 'Bamboo.Model.' .. MODEL_NAME;
	__name = MODEL_NAME;
	__desc = 'Generitic '.. MODEL_NAME ..' definition';
	__fields = {
		['target'] = {foreign="UNFIXED", st="ONE"},
		['content'] = {},
		['user'] = {foreign="User", st="ONE"},
		['touser'] = {foreign="User", st="ONE"},
		-- timestamp was inheritated from Model

	};

	init = function (self, t)
		if not t then return self end

		self.content = t.content
		return self
	end;

}

return _M['this_model']
