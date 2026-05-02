# res://src/resources/BaseItem.gd
extends Resource
class_name BaseItem

@export var id: String
@export var item_name: String
@export var description: String
@export var base_cost: float # 업그레이드/스태프는 달러, 프로젝트는 라인 수

func can_afford() -> bool:
	return GameState.funds >= base_cost

func consume_cost():
	GameState.funds -= base_cost
	GameState.funds_changed.emit(GameState.funds)

func apply_effect():
	pass
