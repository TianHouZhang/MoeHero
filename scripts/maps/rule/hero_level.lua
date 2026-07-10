local function onLevelCommand(self, p, level)
    local hero = p.hero
    if not hero or hero.removed then
        p:sendMsg('你还没有英雄, 无法使用 -level')
        return
    end

    local current = hero:get_level()
    if level <= current then
        p:sendMsg(('当前等级是 %d, 只能使用 -level 提升到更高等级'):format(current))
        return
    end

    hero:set_level(level)
    p:sendMsg(('角色等级已提升到 %d'):format(level))
end

ac.game:event '玩家-指令-level'(function(self, p, level)
    onLevelCommand(self, p, level)
end)
