extends Control

var item_id: String

@onready var button = $"."
@onready var label = $HBoxContainer/VBoxContainer/Name

func setup(id: String):
	item_id = id

	# 노드 준비 안됐으면 대기
	if not is_inside_tree():
		await ready

	_update_ui()

func _ready():
	GameState.item_updated.connect(_on_item_updated)
	button.pressed.connect(_on_pressed)
	
func _on_pressed():
	GameState.buy_item(item_id)

func _on_item_updated(updated_id):
	if updated_id == item_id:
		_update_ui()

func _update_ui():
	var item = GameState.items[item_id]

	var fund_cost = item.get_cost_fund()
	var line_cost = item.get_cost_line()

	var text = "%s Lv.%d" % [
		item.item_name,
		item.level
	]

	if fund_cost > 0:
		text += " 💰%d" % int(fund_cost)

	if line_cost > 0:
		text += " 🧾%d" % int(line_cost)

	label.text = text
