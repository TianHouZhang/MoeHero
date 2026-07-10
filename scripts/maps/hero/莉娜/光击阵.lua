local mt = ac.skill['光击阵']

mt {
    level = 0,
    art = [[ReplaceableTextures\CommandButtons\BTNImmolationOn.blp]],
    title = '光击阵',
    tip = [[在目标点延迟%delay%秒引爆火焰，对%area%范围敌方单位造成%damage%(+%damage_plus%)伤害并晕眩%stun_time%秒。]],
    cool = {12, 10},
    cost = {90, 120},
    range = 900,
    target_type = ac.skill.TARGET_TYPE_POINT,
    cast_start_time = 0.2,
    delay = 0.5,
    area = 260,
    stun_time = {1.2, 1.6},
    damage = {100, 240},
    damage_plus = function(self, hero)
        return hero:get_ad() * 1.8
    end
}

function mt:on_cast_channel()
    local hero = self.owner
    local point = self.target
    local delay_ms = self.delay * 1000

    point:add_effect([[Abilities\Spells\Human\FlameStrike\FlameStrikeTarget.mdl]]):remove()

    hero:wait(delay_ms, function()
        if hero.removed then
            return
        end
        point:add_effect([[Abilities\Spells\Human\FlameStrike\FlameStrike1.mdl]]):remove()
        for _, u in ac.selector():in_range(point, self.area):is_enemy(hero):ipairs() do
            u:add_buff '晕眩' {
                source = hero,
                time = self.stun_time
            }
            u:damage{
                source = hero,
                damage = self.damage + self.damage_plus,
                skill = self,
                aoe = true,
                attack = true
            }
        end
    end)
end
