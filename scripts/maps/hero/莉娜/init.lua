require 'maps.hero.莉娜.龙破斩'
require 'maps.hero.莉娜.光击阵'
require 'maps.hero.莉娜.炽魂'
require 'maps.hero.莉娜.神灭斩'

return ac.hero.create '莉娜'
{
	--物编中的id
	id = 'H014',

	production = 'Dota 1',

	model_source = 'Warcraft III - Blood Mage',

	hero_designer = 'GitHub Copilot',

	hero_scripter = 'GitHub Copilot',

	show_animation = { 'spell', 'spell slam' },

	--技能数量
	skill_count = 4,

	skill_names = '龙破斩 光击阵 炽魂 神灭斩',

	attribute = {
		['生命上限'] = 900,
		['魔法上限'] = 760,
		['生命恢复'] = 3.0,
		['魔法恢复'] = 1.3,
		['魔法脱战恢复'] = 0,
		['攻击']    = 32,
		['护甲']    = 10,
		['移动速度'] = 305,
		['攻击间隔'] = 1.2,
		['攻击范围'] = 600,
	},

	upgrade = {
		['生命上限'] = 112,
		['魔法上限'] = 50,
		['生命恢复'] = 0.2,
		['魔法恢复'] = 0.12,
		['攻击']    = 3.2,
		['护甲']    = 1.0,
	},

	weapon = {
		['弹道模型'] = [[Abilities\Weapons\RedDragonBreath\RedDragonMissile.mdl]],
		['弹道速度'] = 2000,
		['弹道弧度'] = 0.15,
		['弹道出手'] = {15, 0, 66},
	},

	difficulty = 3,

	--选取半径
	selected_radius = 32,

	yuri = true,
	pad = true,
}
