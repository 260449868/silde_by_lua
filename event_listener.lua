local ret = {}

local mtable = {_tcnt = 1}

function mtable:add_listener(lfunc)
	self.list_listener = self.list_listener or {}
	local id = self._tcnt
	self.list_listener[id] = lfunc
	self._tcnt = self._tcnt + 1
	return id
end

function mtable:remove_listener(id)
	self.list_listener = self.list_listener or {}
	self.list_listener[id] = nil
end

function mtable:post_event(...)
	self.list_listener = self.list_listener or {}
	for k,v in pairs(self.list_listener) do
		v(self,...)
	end
end

local register_t = {}

function ret:register(ttable)
	local lmtable = getmetatable(ttable)
	lmtable = lmtable or {}
	if register_t[lmtable] == 1 then
		return
	end
	for k,v in pairs(mtable) do
		if lmtable[k] then
			error("the value '"..k.."'' is already exsit")
		end
		lmtable[k] = v
	end
	lmtable.__index = lmtable.__index or lmtable
	setmetatable(ttable,lmtable)
	register_t[lmtable] = 1
end

--[[
--test
local tab = {}
ret:register(tab)
local function elistener(...)
	print(...)
end
tab:add_listener(elistener)
tab:post_event("etype","etag",{123,234})
]]

return ret