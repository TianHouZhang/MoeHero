local CIRCLE_MIN_RADIUS = 50
local CIRCLE_MAX_RADIUS = 1200

local function normalizeChatCommand(str)
	if type(str) ~= 'string' then
		return ''
	end
	-- 统一全角空格和常见中文分隔符，减少输入格式差异导致的解析失败。
	str = str:gsub('　', ' ')
	str = str:gsub('：', ':')
	str = str:gsub('＝', '=')
	str = str:gsub('，', ',')
	str = str:gsub('%s+', ' ')
	str = str:match('^%s*(.-)%s*$') or ''
	return str
end

local function parseCircleCommand(str)
	local normalized = normalizeChatCommand(str)
	local lower = normalized:lower()
	if not lower:find('^%-circle') then
		return nil
	end

	local payload = lower:sub(8)
	payload = payload:gsub('^[%s:=,]+', '')
	if payload == '' then
		return false, nil, '格式错误: 请输入 -circle 半径, 例如 -circle 300'
	end

	local num_txt = payload:match('[%+%-]?%d+%.?%d*')
	if not num_txt then
		return false, nil, '格式错误: 半径必须是数字, 例如 -circle 300'
	end

	local radius = tonumber(num_txt)
	if not radius then
		return false, nil, '格式错误: 半径必须是数字(可带小数), 例如 -circle 300.5'
	end

	if radius <= 0 then
		return false, nil, '参数错误: 半径必须大于 0'
	end

	if radius < CIRCLE_MIN_RADIUS or radius > CIRCLE_MAX_RADIUS then
		return false, nil, ('参数错误: 半径范围是 %d 到 %d'):format(CIRCLE_MIN_RADIUS, CIRCLE_MAX_RADIUS)
	end

	return true, radius
end

ac.game:event '玩家-聊天' (function(self, p, str)
	local ok, r, err = parseCircleCommand(str)
	if ok == nil then
		return
	end

	if not p.hero then
		p:sendMsg('你还没有英雄, 无法使用 -circle')
		return
	end

	if not ok then
		p:sendMsg(err)
		return
	end

	p:event_notify('玩家-指令-circle', p, r)
end)
