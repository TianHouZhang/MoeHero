local CIRCLE_MIN_RADIUS = 50
local CIRCLE_MAX_RADIUS = 1200
local HERO_LEVEL_MIN = 1
local HERO_LEVEL_MAX = 25

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

local function parseLevelCommand(str)
    local normalized = normalizeChatCommand(str)
    local lower = normalized:lower()
    if not lower:find('^%-level') and not lower:find('^%-lv') then
        return nil
    end

    local payload = lower:gsub('^%-level', '', 1)
    payload = payload:gsub('^%-lv', '', 1)
    payload = payload:gsub('^[%s:=,]+', '')
    if payload == '' then
        return false, nil, '格式错误: 请输入 -level 等级, 例如 -level 10'
    end

    local num_txt = payload:match('%d+')
    if not num_txt then
        return false, nil, '格式错误: 等级必须是整数, 例如 -level 10'
    end

    local level = tonumber(num_txt)
    if not level then
        return false, nil, '格式错误: 等级必须是整数, 例如 -level 10'
    end

    if level < HERO_LEVEL_MIN or level > HERO_LEVEL_MAX then
        return false, nil, ('参数错误: 等级范围是 %d 到 %d'):format(HERO_LEVEL_MIN, HERO_LEVEL_MAX)
    end

    return true, level
end

local CHAT_COMMANDS = {{
    parse = parseCircleCommand,
    event = '玩家-指令-circle',
    hero_msg = '你还没有英雄, 无法使用 -circle'
}, {
    parse = parseLevelCommand,
    event = '玩家-指令-level',
    hero_msg = '你还没有英雄, 无法使用 -level'
}}

ac.game:event '玩家-聊天'(function(self, p, str)
    for _, command in ipairs(CHAT_COMMANDS) do
        local ok, value, err = command.parse(str)
        if ok ~= nil then
            if not ok then
                p:sendMsg(err)
                return
            end

            if not p.hero then
                p:sendMsg(command.hero_msg)
                return
            end

            p:event_notify(command.event, p, value)
        end
    end
end)
