local UPDATE_MS = 20
local MIN_DURATION_MS = 12000
local BLOOD_EFFECT_MODEL = [[Objects\Spawnmodels\Human\HumanBlood\BloodElfSpellThiefBlood.mdl]]
local BLOOD_EFFECT_INTERVAL_MS = 180

local runtime = rawget(_G, '__circle_motion_runtime')
if not runtime then
	runtime = {
		active_runs = setmetatable({}, { __mode = 'k' }),
		handler_registered = false,
		handler = nil,
	}
	rawset(_G, '__circle_motion_runtime', runtime)
end

local active_runs = runtime.active_runs

local function stopCircleMotion(hero)
	local run = active_runs[hero]
	if not run then
		return
	end
	if run.timer then
		run.timer:remove()
	end
	if run.lock_move and not hero.removed then
		hero:remove_restriction '定身'
	end
	active_runs[hero] = nil
end

local function startCircleMotion(hero, radius)
	if not hero or hero.removed or not hero:is_alive() then
		return false, '英雄不存在或已死亡, 无法执行 -circle'
	end

	stopCircleMotion(hero)

	local center = hero:get_point()
	local cx, cy = center:get()
	local start_angle = hero:get_facing()
	local start_life = hero:get '生命'
	if start_life <= 0 then
		return false, '当前生命值异常, 无法执行 -circle'
	end

	local move_speed = hero:get '移动速度'
	if move_speed <= 0 then
		move_speed = 300
	end

	local circumference = 2 * math.pi * radius
	local duration_ms = math.max(MIN_DURATION_MS, circumference / move_speed * 1000)
	local half_life = start_life * 0.5
	local elapsed_ms = 0

	hero:add_restriction '定身'

	local run = {
		center_x = cx,
		center_y = cy,
		radius = radius,
		start_angle = start_angle,
		start_life = start_life,
		half_life = half_life,
		duration_ms = duration_ms,
		elapsed_ms = elapsed_ms,
		lock_move = true,
		blood_elapsed_ms = 0,
	}
	active_runs[hero] = run

	run.timer = ac.loop(UPDATE_MS, function(t)
		if hero.removed or not hero:is_alive() then
			stopCircleMotion(hero)
			return
		end

		local cur = active_runs[hero]
		if not cur then
			t:remove()
			return
		end

		cur.elapsed_ms = cur.elapsed_ms + UPDATE_MS
		cur.blood_elapsed_ms = cur.blood_elapsed_ms + UPDATE_MS
		local progress = cur.elapsed_ms / cur.duration_ms
		if progress > 1 then
			progress = 1
		end
		if cur.blood_elapsed_ms >= BLOOD_EFFECT_INTERVAL_MS then
			cur.blood_elapsed_ms = 0
			hero:add_effect('origin', BLOOD_EFFECT_MODEL):remove()
			hero:add_effect('chest', BLOOD_EFFECT_MODEL):remove()
		end

		local angle = cur.start_angle + 360 * progress
		local x = cur.center_x + cur.radius * math.cos(angle)
		local y = cur.center_y + cur.radius * math.sin(angle)
		local target = ac.point(x, y)
		if not hero:set_position(target, true, true) then
			hero:setPoint(target)
		end

		local expected_life = cur.start_life - (cur.start_life - cur.half_life) * progress
		if hero:get '生命' > expected_life then
			hero:set('生命', expected_life)
		end

		if progress >= 1 then
			local center_point = ac.point(cur.center_x, cur.center_y)
			if not hero:set_position(center_point, true, true) then
				hero:setPoint(center_point)
			end
			hero:set('生命', cur.half_life)
			hero:issue_order 'stop'
			stopCircleMotion(hero)
		end
	end)

	return true
end

local function stopAllCircleMotion()
	for hero in pairs(active_runs) do
		stopCircleMotion(hero)
	end
end

local function onCircleCommand(self, p, radius)
	local hero = p.hero
	local ok, err = startCircleMotion(hero, radius)
	if not ok then
		if err then
			p:sendMsg(err)
		end
		return
	end
	p:sendMsg(('开始绕圈: 半径 %.2f, 完成后血量为初始的一半'):format(radius))
end

runtime.handler = onCircleCommand

if not runtime.handler_registered then
	runtime.handler_registered = true
	ac.game:event '玩家-指令-circle' (function(self, p, radius)
		if runtime.handler then
			runtime.handler(self, p, radius)
		end
	end)
end

local M = {}

function M.hot_reload()
	stopAllCircleMotion()
	return true
end

return M
