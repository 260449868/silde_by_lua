local ret = {}

local mtable = {_tcnt = 1,event_queue={}}

--the higher priority will call later,the default priority is 5
function mtable:add_listener(lfunc,lpriority)
	self.list_listener = self.list_listener or {}
	local _id = self._tcnt
	local _priority = lpriority or 5
	table.insert(self.list_listener, {id = _id,priority = _priority ,func=lfunc} )
	table.sort(self.list_listener,function(a,b) return a.priority<b.priority end)
	self._tcnt = self._tcnt + 1
	return id
end

function mtable:remove_listener(id)
	self.list_listener = self.list_listener or {}
	local lltable = self.list_listener
	for i=1,#(lltable) do
		if lltable[i].id == id then
			table.remove(lltable,i)
			return true
		end
	end
	return false
end

--[[the event will be call after the function post_event call by insert_event]]
local coroutine = coroutine
function mtable:insert_event(...)
	table.insert(self.event_queue,coroutine.create(function() 
		self:post_event( unpack (arg,1) ) 
		end) )
end

--[[the event will be call soon by post_event]]
function mtable:post_event(...)
	self.list_listener = self.list_listener or {}
	local lltable = self.list_listener
	for i=1,#(lltable) do
		lltable[i].func(self,...)
	end
	local ins_evnet = table.remove(self.event_queue,1)
	while ins_evnet do
		coroutine.resume(ins_evnet)
		ins_evnet = table.remove(self.event_queue,1)
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


--test
--[[
local tab = {}
ret:register(tab)
local function elistener(self,etype,...)
	if etype == "etype" then
		tab:insert_event("event1","vala","valb")
		tab:post_event("event2","valc")
	end
	if etype == "event1" then
		print(...)
	end
	print(...)
	
end
local function elistener1(...)
	print(2)
end
local function elistener2(...)
	print(3)
	print(...)
end
tab:add_listener(elistener,1)
--tab:add_listener(elistener1,10)
--tab:add_listener(elistener2)
tab:post_event("etype","etag",{123,234})
]]

return ret