module(..., package.seeall)

local Levelink = {
	__fields = {
		['namelevel1'] = {},
		['namelevel2'] = {},
		['namelevel3'] = {},
		['namelevel4'] = {},
		['namelevel5'] = {},
		['namelevel6'] = {},
		['namelevel7'] = {},
		['namelevel8'] = {},														
	};

	init = function (self, t)
		if not t then return self end
		
		for i=1, 8 do
			self['namelevel' .. i] = t['namelevel' .. i]
		end

		return self
	end;

}

return Levelink
