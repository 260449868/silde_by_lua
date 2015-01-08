local listener = require "event_listener"
local skill = require "skill"
local ret = {}

--[[event_type -- order by time
	collect_phase
	prepare_phase
	damage_phase--defent_phase
	attack_phase--hurt_phase
	end_phase
]]

--[[
	listener priority:
	1.during the phase
	2.the skill almost in this priority
	5.default priority
	9.client effect
]]

local meta_fighter = {}
meta_fighter.__index = meta_fighter

function meta_fighter:set_target(target)
	self.target = target
end

local meta_param_data={
	hp = 0,
	strength = 0,
	atk_per = 0,
	def_per = 0,
}
meta_param_data.__index = meta_param_data
function meta_fighter:init()
	self.collect_data = {0,0,0,0,0}
	self.phase_data = {{0,0,0,0,0},{0,0,0,0,0}}
	self.param_data = {}
	setmetatable(self.param_data,meta_param_data)
	
end

function meta_fighter:run_way(_way)
	self:post_event("run_way",_way)
end

local event_switch = {
	run_way = function (this,etag)
		this.phase_data = {{0,0,0,0,0},{0,0,0,0,0}}
		this:post_event("collect_phase",etag)
		this:post_event("prepare_phase",etag)
		this:post_event("damage_phase",etag)
		this:post_event("attack_phase",etag)
		this:post_event("end_phase",etag)
	end,
	collect_phase = function ( this,etag )
		local phase_data = this.phase_data
		for i=1,#(etag) do
			local data = etag[i]
			phase_data[1][data.ttype] = phase_data[1][data.ttype]+1
			phase_data[2][data.color] = phase_data[2][data.color]+1
		end
	end,
	prepare_phase = function ( this,etag )
		local cphase_data = this.phase_data[2]
		for i=1,#(cphase_data) do
			this.collect_data[i] = this.collect_data[i]+cphase_data[i]
		end
	end,
	damage_phase = function ( this,etag )
		local tphase_data = this.phase_data[1]
		local param_data = this.param_data
		local damage = tphase_data[1]
		local aper = param_data.strength*0.1
		--local aper2 = aper*(1+param_data.atk_per)
		damage = damage*(1+aper)*(1+param_data.atk_per)
		etag.damage = damage
		this.target:insert_event("defent_phase",etag)
	end,
	defent_phase = function ( this,etag )
		local damage = etag.damage or 0
		local ttphase_data = this.phase_data[1]
		local param_data = this.param_data
		local armor = ttphase_data[2]
		local dper = param_data.strength*0.05
		--dper = dper*(1+param_data.def_per)
		armor = armor*(1+dper)*(1+param_data.def_per)
		damage = damage-armor
		if damage<=0 then damage = 1 end
		etag.damage = damage
	end,
	attack_phase = function ( this,etag )
		this.target:insert_event("hurt_phase",etag)
	end,
	hurt_phase = function ( this,etag )
		local damage = etag.damage or 0
		local tparam_data = this.param_data
		tparam_data.hp = tparam_data.hp-damage
	end,
	end_phase = function ( this,etag )

	end

}

function meta_fighter:on_event(etype,...)
	if event_switch[etype] then
		event_switch[etype](self,...)
	end
end

skill:init(meta_fighter)

function ret:create_fighter()
	local fighter = {}
	setmetatable(fighter,meta_fighter)
	listener:register(fighter)
	fighter:add_listener(fighter.on_event,1)
	fighter:init()
	return fighter
end

--test
local p1 = ret:create_fighter()
local p2 = ret:create_fighter()
p1:set_target(p2)
p2:set_target(p1)
p1.param_data = {hp = 100,strength = 0,atk_per = 0,def_per = 0}
p1:add_skill(1001)
p1:add_skill(1002)
p2.param_data = {hp = 100,strength = 0,atk_per = 0,def_per = 0}
for i=1,999 do
	local way = {}
	for j=1,10 do
		way[j] = {ttype = math.random(1,3),color = math.random(1,5)}
	end
	if i%2 == 1 then
		p1:ativate_skill(1001)
		p1:ativate_skill(1002)
		p1:post_event("run_way",way)
	else
		p2:post_event("run_way",way)
	end
	print("turn"..i.." p1.hp "..p1.param_data.hp.." p2.hp "..p2.param_data.hp.." damage "..way.damage)
end


return ret