local mt = ac.skill['神灭斩']

mt {
    level = 0,
    max_level = 3,
    requirement = {6, 11, 16},
    art = [[ReplaceableTextures\CommandButtons\BTNOrbOfFire.blp]],
    title = '神灭斩',
    tip = [[发射一道高能火焰斩击，对目标敌方单位造成%damage%(+%damage_plus%)伤害。该次伤害额外提高%damage_pene_rate%%穿透。
	]],
    cool = {70, 55, 40},
    cost = {120, 180, 240},
    range = 700,
    target_type = ac.skill.TARGET_TYPE_UNIT,
    cast_start_time = 0.25,
    cast_shot_time = 0.15,
    damage = {260, 420, 580},
    damage_plus = function(self, hero)
        return hero:get_ad() * 2.5
    end,
    damage_pene_rate = {20, 30, 40}
}

function mt:on_cast_channel()
    local hero = self.owner
    local target = self.target
    if not target or target.removed or not target:is_alive() then
        return
    end

    ac.lightning('CLPB', hero, target, 175, 0):fade(-8)
    target:add_effect('origin', [[Abilities\Spells\Other\Incinerate\IncinerateBuff.mdl]]):remove()
    target:damage{
        source = hero,
        damage = self.damage + self.damage_plus,
        skill = self,
        attack = true,
        ['穿透'] = hero:get '穿透' + self.damage_pene_rate
    }
end
