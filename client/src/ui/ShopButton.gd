# res://src/ui/ShopButton.gd
extends Button
class_name ShopButton

var data: BaseItem 

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
		# tr() 함수를 사용하여 다국어 키를 번역된 텍스트로 가져옵니다.
		var translated_name = tr(data.item_name)
		
		if get_parent().name == "Projects":
			text = "%s\n(%d 코드)" % [translated_name, data.base_cost]
		else:
			text = "%s\n($%.0f)" % [translated_name, data.base_cost]

# --- 2. 애니메이션 로직 ---
func _on_mouse_entered_tooltip() -> void:
	if data:
		# 끄는 과정 없이 바로 새로운 데이터를 전달
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
				_update_ui()
			else:
				print("구입 실패: 코드가 부족합니다.")
				
		BaseItem.PurchaseType.FUNDS:
			if GameState.funds >= data.base_cost:
				data.apply_effect()
				print("구입 성공 (자금 소모)")
				_update_ui()
			else:
				print("구입 실패: 자금이 부족합니다.")
				
		BaseItem.PurchaseType.BOTH:
			pass
