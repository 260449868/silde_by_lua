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
		datav.color = datav.ttype = 0
	end
	if self.listener then self.listener("run_way",{way = _way}) end
end

--填充
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

function ret.findway(self)
	for i=1,self.size_w do
		for j=1,self.size_h do
			local startdata = data[i][j]
			if startdata.color ~= 0 then
				local startpoint = {x=i,y=j}
				local bptable = {startpoint}

				local function  findnext(point)
					if point.color == 0 then
						--end
					else
						local nextpoint = nil
						
					end


				end
				
			end
		end
	end
end

return ret
