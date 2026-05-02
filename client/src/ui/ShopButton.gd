# res://src/ui/ShopButton.gd
extends Button
class_name ShopButton

var data: BaseItem 

@onready var economy_manager = get_node("/root/EconomyManager")

func setup(p_data: BaseItem):
	data = p_data
	pivot_offset = size / 2 
	
	if not mouse_entered.is_connected(_on_mouse_entered_tooltip):
		mouse_entered.connect(_on_mouse_entered_tooltip)
	if not mouse_exited.is_connected(_on_mouse_exited_tooltip):
		mouse_exited.connect(_on_mouse_exited_tooltip)		
	_update_ui()

# res://src/ui/ShopButton.gd
# res://src/ui/ShopButton.gd
func _update_ui():
	if data:
		var translated_name = tr(data.item_name)
		var identifier = data.id if "id" in data else (data.item_id if "item_id" in data else data.item_name)
		
		var cost = 0.0
		if economy_manager:
			var current_level = data.level if "level" in data else 1
			
			# 현재 레벨(1)에 해당하는 정확한 구매 비용 계산
			var raw_cost = economy_manager.get_next_cost(identifier, current_level)
			cost = int(round(raw_cost))
			
			print("--- [UI 업데이트] ---")
			print("이름: ", data.item_name)
			print("결정된 ID: ", identifier)
			print("현재 비용: ", cost)
		
		# 현재 구매해야 하는 가격만 표시
		if get_parent().name == "Projects":
			text = "%s\n(%d 코드)" % [translated_name, cost]
		else:
			text = "%s\n($%d)" % [translated_name, cost]

func _on_mouse_entered_tooltip() -> void:
	if data:
		Events.show_tooltip.emit(data)

func _on_mouse_exited_tooltip() -> void:
	Events.hide_tooltip.emit()

# res://src/ui/ShopButton.gd
func _pressed() -> void:
	var tw = create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(0.9, 0.9), 0.05)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	if not data:
		return
		
	# 1. 프로젝트(ProjectData)인 경우
	if data is ProjectData:
		if data.can_afford():
			data.apply_effect()
			_update_ui()
		else:
			print("구입 실패: 코드 줄이 부족합니다.")
		return
		
	# 2. 일반 업그레이드 또는 스태프 등 일반 아이템인 경우
	if data.can_afford():
		data.consume_cost()
		data.apply_effect()
		_update_ui()
	else:
		print("구입 실패: 재화가 부족합니다.")
