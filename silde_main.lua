require "print_r"
local table = table
local ret = {}

ret.size_w = 5
ret.size_h = 5
ret.color_cnt = 3
ret.type_cnt = 3

ret.data = {}
ret.listener = nil

function ret.init(self)
	for i=1,self.size_w do
		for j=1,self.size_h do
			local tt = { color = math.random(1,self.color_cnt),ttpye = math.random(1,self.type_cnt) }
			if not self.data[i] then self.data[i] = {} end
			self.data[i][j] = tt
		end
	end
	if self.listener then self.listener("init") end
end

function ret.run(self,_way)
--[[	if type(way) ~= "table" then
		error("the type of way is error")
		return
	end]]
	if #(_way) <2 then
		return
	end
	for i=1,#(_way)-1 do
		local point1 = _way[i]
		local point2 = _way[i+1]
		local data1 = data[point1.x][point1.y]
		local data2 = data[point2.x][point2.y]
		if data1.color ~= data2.color and data1.ttpye ~= data2.ttpye then
			error("the way is error")
			return
		end
	end
	for i=1,#(_way) do
		local point = _way[i]
		local datav = data[point.x][point.y]
		datav.color = 0
		datav.ttype = 0
	end
	if self.listener then self.listener("run_way",{way = _way}) end
end

--[[fill the blank]]
function ret.fill(self)
	for i=1,self.size_w do
		for j=1,self.size_h-1 do
			local data1 = data[i][j]
			local data2 = data[i][j+1]
			if data1.color == 0 then
				local temp = data1
				data[i][j] = data2
				data[i][j+1] = temp
			end
		end
	end
	for i=1,self.size_w do
		for j=1,self.size_h do
			local datav = data[i][j]
			if datav.color == 0 then
				datav.color = math.random(1,self.color_cnt)
				datav.ttpye = math.random(1,self.type_cnt)
				if self.listener then self.listener("fill_data",{ x=i,y=j,data=datav }) end
			end
		end
	end
	if self.listener then self.listener("fill_end") end
end

--[[find the way at least min_step steps,if not found,it will return the max-step way]]
function ret.findway(self,min_step)
	local data = self.data
	local acess = {}
	local ntable = nil
	local nval = 1
	for i=1,self.size_w do
		for j=1,self.size_h do
			local startdata = data[i][j]
			if startdata.color ~= 0 then
				local wtable = {}
				local startpoint = {x=i,y=j}
				local cptable = {}
				local function  findnext(point)
					table.insert(wtable,point)
					local px = point.x
					local py = point.y
					local sdata = data[px][px]
					local bnext = false
					local npos = px+py*self.size_h
					cptable[ npos ] = 1
					if px<self.size_w and not cptable[ npos+1 ] then
						if data[px][py].color == data[px+1][py].color or data[px][py].ttpye == data[px+1][py].ttpye then
							local retv = findnext({x=px+1,y=py})
							if retv then return retv end
							bnext = true
						end
					end
					if px>1 and not cptable[ npos-1 ] then
						if data[px][py].color == data[px-1][py].color or data[px][py].ttpye == data[px-1][py].ttpye then
							local retv = findnext({x=px-1,y=py})
							if retv then return retv end
							bnext = true
						end
					end
					if py<self.size_h and not cptable[ npos+self.size_h ] then
						if data[px][py].color == data[px][py+1].color or data[px][py].ttpye == data[px][py+1].ttpye then
							local retv = findnext({x=px,y=py+1})
							if retv then return retv end
							bnext = true
						end
					end
					if py>1 and not cptable[ npos-self.size_h ] then
						if data[px][py].color == data[px][py-1].color or data[px][py].ttpye == data[px][py-1].ttpye then
							local retv = findnext({x=px,y=py-1})
							if retv then return retv end
							bnext = true
						end
					end
					if bnext == false then
						local tsize = #(wtable)
						if min_step and tsize >= min_step then
							return wtable
						end
						if nval<tsize then
							ntable = {}
							local tinsert = table.insert
							table.foreachi(wtable, function(i, v) tinsert(ntable,v) end)
							nval = tsize
						end
					end
					table.remove(wtable)
					cptable[ npos ] = nil
				end
				local retv = findnext(startpoint)
				if retv then return retv end
			end
		end
	end
	return ntable
end

local mtable = {}
function mtable.__tostring(self)
	return getstr_r(self.data)
end
setmetatable(ret, mtable)

ret:init()
local result = ret:findway(10)
print_r(result)

return ret
