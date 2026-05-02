extends Resource
class_name BaseItem

var id: String
var item_name: String
var description: String

var base_cost: float
var cost_type: String
var category: String

var effect_value: float
var reward_funds: float


func can_afford() -> bool:
	if cost_type == "money":
		return GameState.funds >= base_cost
	elif cost_type == "lines":
		return GameState.uncommitted_lines >= base_cost
	return false


func consume_cost():
	if cost_type == "money":
		GameState.funds -= base_cost
		GameState.funds_changed.emit(GameState.funds)

	elif cost_type == "lines":
		GameState.uncommitted_lines -= base_cost
		GameState.lines_changed.emit(GameState.uncommitted_lines)


func apply_effect():
	match category:

		"project":
			GameState.funds += reward_funds
			GameState.funds_changed.emit(GameState.funds)

		"upgrade":
			GameState.manual_coding_power += effect_value

		"staff":
			GameState.total_lines_per_second += effect_value
