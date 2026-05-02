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
	
	var identifier = data.id if "id" in data else (data.item_id if "item_id" in data else data.item_name)
	
	match data.purchase_type:
		BaseItem.PurchaseType.LINES:
			var required_cost = int(round(economy_manager.get_next_cost(identifier, 1)))
			var current_lines = GameState.uncommitted_lines
			
			if current_lines >= required_cost:
				var before_lines = current_lines
				data.apply_effect()
				GameState.uncommitted_lines = before_lines - required_cost
				var after_lines = GameState.uncommitted_lines
				
				print("--- [구입 완료 - 코드] ---")
				print("구입 전 코드: %d | 지불할 코드: %d | 차감 후 코드: %d" % [before_lines, required_cost, after_lines])
				
				_update_ui()
			else:
				print("구입 실패: 코드가 부족합니다.")
				
		# res://src/ui/ShopButton.gd
		# res://src/ui/ShopButton.gd

		BaseItem.PurchaseType.FUNDS:
			var required_cost = int(round(economy_manager.get_next_cost(identifier, 1)))
			var current_funds = int(round(GameState.funds))
			
			if current_funds >= required_cost:
				var before_funds = current_funds
				
				GameState.funds = before_funds - required_cost
				data.apply_effect()
				
				# 🔥 [수정 포인트] 구매 후 레벨을 1 증가시켜 다음 레벨 비용이 오르도록 처리
				data.level = (data.level if "level" in data else 1) + 1
				
				var after_funds = int(round(GameState.funds))
				
				print("--- [구입 완료 - 자금] ---")
				print("구입 전 자금: %d | 지불할 자금: %d | 차감 후 자금: %d" % [before_funds, required_cost, after_funds])
				
				_update_ui()
