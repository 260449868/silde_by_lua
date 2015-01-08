local ret = {}
--[[
	skill status:
	inativity,	--the skill is cooldown but not used
	ativity,	--the skill is ready to use,or it's an unative skill not in cooldown
	cooldown,	--the skill in cooldown
	using,		--the skill is using
]]
local skill_status = {
	inativity = 1,
	ativity = 2,
	cooldown = 3,
	using = 4,
}
local config = {
	[1001] = {name="skill1",cd_time=5,use_phase = "collect_phase",
			collect_phase = function(fighter,skill_data,etag)
					if skill_data.status ~= skill_status.ativity then return false end
					table.foreachi(fighter.phase_data[1],function(i,v) fighter.phase_data[1][i] = v*2 end)
					return true
				end
		},
	[1002] = {name="skill2",cd_time=3,use_phase = "collect_phase",
			collect_phase = function(fighter,skill_data,etag)
					if skill_data.status ~= skill_status.ativity then return false end
					fighter.target:post_event("hurt_phase",{damage=10})
					return true
				end
		}
}
local function create_skill_event(skill_data)
	return function (self,etype,...)
				local base = skill_data.base
				local result = false
				if base[etype] ~= nil then result = base[etype](self,skill_data,...) end
				if result and base.use_phase == etype then
					skill_data.cooldown = skill_data.cooldown + base.cd_time
					skill_data.status = skill_status.cooldown
				end
				if etype == "end_phase" and skill_data.status == skill_status.cooldown then
					if skill_data.cooldown>0 then
						skill_data.cooldown = skill_data.cooldown - 1
					end
					if skill_data.cooldown <=0 then
						skill_data.cooldown = 0
						skill_data.status = skill_status.inativity
					end
				end
			end
end
function ret:init(meta_fighter)
	assert(meta_fighter)
	function meta_fighter:add_skill(_skill_id)
		self.skill_list = self.skill_list or {}
		for i=1,#(self.skill_list) do
			local skill_data = self.skill_list[i]
			if _skill_id == skill_data.skill_id then return false end
		end
		local base = config[_skill_id]
		assert(base,"then skill ".._skill_id.." can not be found")
		local skill_data = {skill_id = _skill_id,base = base,status = skill_status.inativity,cooldown = 0}
		table.insert(self.skill_list,skill_data)
		skill_data.lid = self:add_listener( create_skill_event(skill_data) ,2)
		return true
	end
	function meta_fighter:remove_skill(_skill_id)
		self.skill_list = self.skill_list or {}
		for i=1,#(self.skill_list) do
			local skill_data = self.skill_list[i]
			if _skill_id == skill_data.skill_id then 
				self:remove_listener(skill_data.lid)
				table.remove(self.skill_list,i)
				return true 
			end
		end
		return false
	end
	function meta_fighter:ativate_skill(_skill_id)
		self.skill_list = self.skill_list or {}
		for i=1,#(self.skill_list) do
			local skill_data = self.skill_list[i]
			if _skill_id == skill_data.skill_id then 
				if skill_data.status ~= skill_status.inativity then
					return false
				else
					skill_data.status = skill_status.ativity
					return true
				end
			end
		end
		return false
	end
end

return ret