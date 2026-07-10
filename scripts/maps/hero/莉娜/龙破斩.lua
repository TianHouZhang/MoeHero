local mt = ac.skill['龙破斩']

mt{
	level = 0,
	art = [[ReplaceableTextures\CommandButtons\BTNBreathOfFire.blp]],
	title = '龙破斩',
	tip = [[释放一道火焰冲击波，对路径上的敌方单位造成%damage%(+%damage_plus%)伤害。]],
	cool = {9, 7},
	cost = {80, 100},
	show_cd = 1,
	range = 900,
	target_type = ac.skill.TARGET_TYPE_POINT,
	cast_start_time = 0.15,
	cast_shot_time = 0.2,
	damage = {90, 220},
	damage_plus = function(self, hero)
		return hero:get_ad() * 1.6
	end,
	distance = 950,
	speed = 1500,
	hit_area = 120,
}

function mt:on_cast_channel()
	local hero = self.owner
	local mvr = ac.mover.line
	{
		source = hero,
		target = self.target,
		model = [[Abilities\Weapons\RedDragonBreath\RedDragonMissile.mdl]],
		distance = self.distance,
		speed = self.speed,
		hit_area = self.hit_area,
		skill = self,
		hit_type = ac.mover.HIT_TYPE_ENEMY,
		high = 64,
	}

	if not mvr then
		return
	end

	function mvr:on_hit(target)
		target:add_effect('origin', [[Abilities\Spells\Other\BreathOfFire\BreathOfFireDamage.mdl]]):remove()
		target:damage
		{
			source = hero,
			damage = self.skill.damage + self.skill.damage_plus,
			skill = self.skill,
			aoe = true,
			attack = true,
			missile = self.mover,
		}
	end
end
