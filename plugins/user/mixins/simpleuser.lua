module(..., package.seeall)

local UserMixin = {
	__fields = {
		['creator'] 		= {foreign = bamboo.MAIN_USER.__name, st="ONE"},
		['owner'] 			= {foreign = bamboo.MAIN_USER.__name, st="ONE"},
		['last_modifier'] 	= {foreign = bamboo.MAIN_USER.__name, st="ONE"},				
	};

}

return UserMixin
