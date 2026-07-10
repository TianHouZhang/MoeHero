local mt = ac.skill['炽魂']

mt {
    level = 0,
    art = [[ReplaceableTextures\CommandButtons\BTNInnerFire.blp]],
    title = '炽魂',
    tip = [[|cff11ccff被动|r：每次释放英雄技能时，获得1层炽魂，持续%time%秒。每层提高%attack_speed%攻击速度和%move_speed_rate%%移动速度，最多%max_stack%层。]],
    time = 8,
    max_stack = {3, 4},
    attack_speed = {18, 30},
    move_speed_rate = {4, 7}
}

mt.passive = true

function mt:on_add()
    local hero = self.owner
    self.trg = hero:event '技能-施法出手'(function(_, _, skill)
        if not skill then
            return
        end
        if skill == self then
            return
        end
        if skill:get_type() ~= '英雄' then
            return
        end
        self:update_data()
        hero:add_buff '炽魂' {
            source = hero,
            skill = self,
            time = self.time,
            max_stack = self.max_stack,
            attack_speed = self.attack_speed,
            move_speed_rate = self.move_speed_rate
        }
    end)
end

function mt:on_remove()
    if self.trg then
        self.trg:remove()
    end
end

local mt = ac.buff['炽魂']

function mt:on_add()
    local hero = self.target
    hero:add('攻击速度', self.attack_speed)
    hero:add('移动速度%', self.move_speed_rate)
    self:set_stack(1)
end

function mt:on_remove()
    local hero = self.target
    local stack = self:get_stack(1)
    hero:add('攻击速度', -self.attack_speed * stack)
    hero:add('移动速度%', -self.move_speed_rate * stack)
end

function mt:on_cover(new)
    local hero = self.target
    local stack = self:get_stack(1)
    if stack < new.max_stack then
        self:add_stack(1)
        hero:add('攻击速度', new.attack_speed)
        hero:add('移动速度%', new.move_speed_rate)
    end
    self:set_remaining(new.time)
    return false
end
