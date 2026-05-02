# res://src/resources/upgrades/UpgradeData.gd
extends BaseItem
class_name UpgradeData

@export var click_power_increase: float = 1.0

func apply_effect() -> bool:
	GameState.manual_coding_power += click_power_increase
	print(item_name + " 업그레이드 완료!")
	return true
