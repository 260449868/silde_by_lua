local ret = {}

local map_manage_metatable = {}
map_manage_metatable.__index = map_manage_metatable


local map_metatable = {}
function map_metatable:setsize(wsize,hsize)
	self.wsize = wsize
	self.hsize = hsize
	self:resetmap()
end

--[[
	type--event,enemy,item,npc
]]
local default_
function map_metatable:resetmap(data)
	self:remove_quest()

end

function map_metatable:remove_quest()
	if self.quest then
		--remove listener
		self.quest = nil
	end
end

function map_metatable:reset_quest(cnt)
	self:remove_quest()
	local tquest = {}
	for i=1,cnt do
		--random quest
	end
	for i=1,#tquest do
		--add listener
	end
end

function map_manage_metatable:create_map(data)
	local nmap = {}
	setmetatable(nmap,map_metatable)
	nmap:setsize(data.wsize or 10,data.hsize or 10)
	nmap:resetmap(data)
	nmap:reset_quest(data.qcnt or 3)
	return nmap
end





return ret