# res://src/ui/ShopButton.gd
extends Button
class_name ShopButton

var data: BaseItem 

# EconomyManager 오토로드 참조
@onready var economy_manager = get_node("/root/EconomyManager")

func setup(p_data: BaseItem):
	data = p_data
	pivot_offset = size / 2 
	
	# 마우스 진입 시 툴팁 표시 시그널 전송
	if not mouse_entered.is_connected(_on_mouse_entered_tooltip):
		mouse_entered.connect(_on_mouse_entered_tooltip)
	if not mouse_exited.is_connected(_on_mouse_exited_tooltip):
		mouse_exited.connect(_on_mouse_exited_tooltip)		
	_update_ui()

# --- 1. UI 업데이트 함수 (다국어 tr() 적용) ---
func _update_ui():
	if data:
		var translated_name = tr(data.item_name)
		
		var identifier = ""
		if "id" in data:
			identifier = data.id
		elif "item_id" in data:
			identifier = data.item_id
		else:
			identifier = data.item_name
			
		# [추가] 어떤 아이템이 넘어오는지 출력하여 확인합니다.
		print("--- UI 업데이트 중 ---")
		print("item_name: ", data.item_name)
		print("결정된 identifier: ", identifier)
		
		var cost = 0.0
		if economy_manager:
			cost = economy_manager.get_next_cost(identifier, 1)
			print("계산된 비용: ", cost) # 비용 계산 결과 확인
		
		if get_parent().name == "Projects":
			text = "%s\n(%.0f 코드)" % [translated_name, cost]
		else:
			text = "%s\n($%.0f)" % [translated_name, cost]



func _on_mouse_entered_tooltip() -> void:
	if data:
		Events.show_tooltip.emit(data)

func _on_mouse_exited_tooltip() -> void:
	Events.hide_tooltip.emit()

# --- 3. 통합 _pressed 로직 (로그 및 구입 처리) ---
func _pressed() -> void:
	# 클릭 애니메이션
	var tw = create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(0.9, 0.9), 0.05)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	if not data:
		print("에러: 데이터가 없습니다.")
		return
	
	# 구입 타입에 따른 유연한 분기
	match data.purchase_type:
		BaseItem.PurchaseType.LINES:
			if data.can_afford(): 
				data.apply_effect()
				print("구입 성공 (코드 소모)")
				
				# [수정 포인트] Category가 Staff(직원)인 경우에만 직원 이름 로직을 실행하도록 변경
				var identifier = data.id if "id" in data else data.item_name
				var item_data = economy_manager.items_db.get(identifier)
				
				# 카테고리가 'Staff'일 때만 아래 코드가 실행됩니다.
				if item_data and item_data["category"] == "Staff":
					var staff_name = economy_manager.get_unique_staff_name()
					print("고용한 스태프 이름: ", staff_name["name_kr"])
					
				_update_ui()
			else:
				print("구입 실패: 코드가 부족합니다.")
				
		BaseItem.PurchaseType.FUNDS:
			if GameState.funds >= data.base_cost: # 추후 필요시 get_next_cost로 변경 가능
				data.apply_effect()
				print("구입 성공 (자금 소모)")
				_update_ui()
			else:
				print("구입 실패: 자금이 부족합니다.")
				
		BaseItem.PurchaseType.BOTH:
			pass
