extends Button

var data: BaseItem

@onready var name_label = $HBoxContainer/VBoxContainer/Name
@onready var cost_label = $HBoxContainer/VBoxContainer/Price


func setup(incoming_data: BaseItem):
	data = incoming_data
	_update_ui()


func _update_ui():
	if not data:
		return

	name_label.text = data.item_name

	if data.cost_type == "money":
		cost_label.text = "$%d" % data.base_cost
	elif data.cost_type == "lines":
		cost_label.text = "%d Lines" % data.base_cost

	self.tooltip_text = "%s\nCost: %s" % [
		data.item_name,
		cost_label.text
	]


func _pressed():
	if not data:
		return

	if not data.can_afford():
		print("구매 불가:", data.item_name)
		return

	data.consume_cost()
	data.apply_effect()

	print("구매 완료:", data.item_name)
