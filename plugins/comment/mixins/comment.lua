module(..., package.seeall)
local Model = require 'bamboo.model'

local CommentMixin = {
	__fields = {
		['comments'] = {foreign="Comment", st="MANY"},
	};

	init = function (self, t)
		if not t then return self end

		return self
	end;

}

return CommentMixin
