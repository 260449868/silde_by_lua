local silde_data = require "silde_main"
local ret = {}
local lccp = ccp
local texture_cache = CCTextureCache:sharedTextureCache()
local shader_mng = ShaderManage:GetInstance()
local shader_float = shader_mng:GetProgram("float")
local shader_default = shader_mng:GetProgram("default")

--local pngsize = 65
ret.pngsize = 65
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
	local lpngsize = ret.pngsize
	sdata:init()

	self.cleanblock = lcleanblock
	self.setblock = lsetblock

	self.ssprite = {}
	for i=1,sdata.size_w do
		for j=1,sdata.size_h do
			local point = sdata.data[i][j]
			local sprdata = self.ssprite[i+j*sdata.size_w]
			local texture = texture_cache:addImage("icon/ficon"..point.ttype.."_"..point.color..".png")
			if not sprdata then
				sprdata = CCSprite:createWithTexture(texture)
				self:addChild(sprdata)
				self.ssprite[i+j*sdata.size_w] = sprdata
			else
				sprdata:setTexture(texture)
			end
			--sprdata:setAnchorPoint(ccp(0,0))
			sprdata.pos = {x=i,y=j}
			sprdata:setPosition(lccp(i*lpngsize-lpngsize/2,j*lpngsize-lpngsize/2))
		end
	end

	local pPoint = nil
	local mway = {}
	local sway = {}
	local function resetway(self)
		local tsize = #(sway)
		for i=tsize,1,-1 do
			local tpoint = sway[i]
			local spr = mway[tpoint]
			mway[tpoint] = nil
			spr:setShaderProgram(shader_default)
			table.remove(sway)
			pPoint = nil
			print("remove:",tpoint.x,tpoint.y)
		end
	end
	self.resetway = resetway
	local function addway(point,sprdata)
		pPoint = point
		table.insert(sway,point)
		mway[point] = sprdata
		sprdata:setShaderProgram(shader_float)
		print("add:",point.x,point.y)
	end
	local function touchSelect(px,py)
		local point = sdata.data[px][py]
		if pPoint == point then
			return true
		end
		local sprdata = self.ssprite[px+py*sdata.size_w]
		if not pPoint then
			addway(point,sprdata)
			return true
		end

		if not mway[point] then
			if math.abs(px-pPoint.x)+math.abs(py-pPoint.y) == 1 then
				if pPoint.color == point.color or pPoint.ttype == point.ttype then
					addway(point,sprdata)
					return true
				else
					--not rule in

					return true
				end
			else
				--not rule in

				return true
			end
		else
			local tsize = #(sway)
			for i=tsize,1,-1 do
				local tpoint = sway[i]
				if tpoint ~= point then
					local spr = mway[tpoint]
					mway[tpoint] = nil
					spr:setShaderProgram(shader_default)
					table.remove(sway)
					print("remove:",tpoint.x,tpoint.y)
				else
					pPoint = tpoint
					return true
				end
			end
		end
		return true
	end

	local function onTouch(eventType, x, y)
		if	self.isbusy == true then
			return false
		end

        if eventType == "began" or  eventType == "moved" then
        	local p =self:convertToNodeSpaceAR(ccp(x,y))
			local px = math.ceil(p.x/lpngsize)
			local py = math.ceil(p.y/lpngsize)
			if px<1 or px> sdata.size_w or py<1 or py>sdata.size_h then
				return false
			end
            return touchSelect(px, py)
        else
        	
			local tsize = #(sway)
			if tsize == 1 then
				resetway()
			elseif tsize>1 then
				self.sdata:run(sway)
			end
			return true
            --return onTouchEnded(x, y)
        end
        return true
    end

    self:registerScriptTouchHandler(onTouch)
    self:setTouchEnabled(true)
end

function ret.create_sildedata(self,width,height,ntype,ncolor)
	local data = silde_data:new()
	data.size_w = width
	data.size_h = height
	data.color_cnt = ncolor
	data.type_cnt = ntype
	return data
end

local CCOrbitCamera = CCOrbitCamera
local schedule = CCDirector:sharedDirector():getScheduler()
function ret.create_sildelayer(self,width,height,ntype,ncolor)
	local layer = CCLayer:create()
	layer.sdata = self:create_sildedata(width,height,ntype,ncolor)

	local function event_listener(etype,etag)
		if etype == "init" then

		elseif etype == "run_way" then
			layer.isbusy = true
			local way = etag.way
			for i=1,#(way) do
				local point = way[i]
				local sprdata = layer.ssprite[point.x+point.y*layer.sdata.size_w]
				sprdata:runAction(CCOrbitCamera:create(0.5,1,0,0,90,0,0) )
			end
			local tdelay = nil
			local function onActionEnd()
				schedule:unscheduleScriptEntry(tdelay)
				layer.sdata:fill()
			end
			tdelay = schedule:scheduleScriptFunc(onActionEnd,0.5,false)

		elseif etype == "fill_data" then
			local sprdata = layer.ssprite[etag.x+etag.y*layer.sdata.size_w]
			local texture = texture_cache:addImage("icon/ficon"..etag.data.ttype.."_"..etag.data.color..".png")
			sprdata:setTexture(texture)
			sprdata:stopAllActions()
			sprdata:runAction(CCOrbitCamera:create(0.5,1,0,90,-90,0,0) )

		elseif etype == "fill_end" then
			layer.resetway()
			layer.isbusy = false
		end
		if layer.listener then layer.listener(etype,etag) end
		print(etype)
	end
	layer.sdata.listener = event_listener
	initl(layer)

	return layer
end
--ret:create_sildelayer(5,5,3,3)

return ret