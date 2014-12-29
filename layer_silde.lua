local silde_data = require "silde_main"
local ret = {}

local function lcleanblock(self,x,y)
	local sdata = self.sdata
	local sprdata = self.ssprite[x*sdata.size_w+y]

end

local function lsetblock(self,x,y)
	local sdata = self.sdata
	local sprdata = self.ssprite[x*sdata.size_w+y]
end
local function initl(self)
	local sdata = self.sdata
	sdata:init()

	self.cleanblock = lcleanblock
	self.setblock = lsetblock

	self.ssprite = {}
	for i=1,sdata.size_w do
		for j=1,sdata.size_h do
			local point = sdata.data[i][j]
			local sprdata = self.ssprite[i*sdata.size_w+j]
			if not sprdata then
				sprdata = {}--CCSprite:create()
			end
			sprdata.pos = {x=i,y=j}
			--sprdata:setPosition(ccp())
		end
	end
end

function ret.create_sildedata(self,width,height,ntype,ncolor)
	local data = silde_data:new()
	data.size_w = width
	data.size_h = height
	data.color_cnt = ncolor
	data.type_cnt = ntype
	return data
end

function ret.create_sildelayer(self,width,height,ntype,ncolor)
	local layer = {}--CCLayer:create()
	layer.sdata = self:create_sildedata(width,height,ntype,ncolor)

	local function event_listener(etype,etag)
		if etype == "init" then

		elseif etype == "run_way" then

		elseif etype == "fill_data" then

		elseif etype == "fill_end" then

		end
		if layer.listener then layer.listener(etype,etag) end
		print(etype)
	end
	layer.sdata.listener = event_listener
	initl(layer)

	return layer
end
ret:create_sildelayer(5,5,3,3)

return ret