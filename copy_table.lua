require "print_r"
local ret = {}

function ret.copytable(target)
	if not target or type(target) ~= "table" then
		return
	end
	local ttable = {}
	local function tcopy(target)
		local tab = {}
	    for k, v in pairs(target or {}) do
	        if type(v) ~= "table" then
	            tab[k] = v
	        else
	        	local ref = ttable[ v ]
	        	if not ref then
	            	tab[k] = tcopy(v)
	            	ttable[ v ] = tab[k]
	            else
	            	tab[k] = ref
	            end
	        end
	    end
    	return tab
	end
	local tret = tcopy(target)
	setmetatable(tret, getmetatable(target))
	return tret
end

return ret