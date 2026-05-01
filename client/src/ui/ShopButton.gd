extends Button
class_name ShopButton

var data: BaseItem 

func setup(p_data: BaseItem):
	data = p_data
	pivot_offset = size / 2 
	
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
		
	_update_ui()

# --- 1. UI 업데이트 함수 ---
func _update_ui():
	if data:
		if get_parent().name == "Projects":
			text = "%s\n(%d 코드)" % [data.item_name, data.base_cost]
		else:
			text = "%s\n($%.0f)" % [data.item_name, data.base_cost]

# --- 2. 애니메이션 로직 ---
func _on_mouse_entered() -> void:
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

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
	
	# 카테고리(컨테이너 이름)에 따른 분기 처리
	if get_parent().name == "Projects":
		# [어플리케이션(프로젝트) 구입 로직]
		if data.can_afford():
			var success = data.apply_effect()
			if success:
				print("어플 구입 성공! 남은 코드: ", GameState.uncommitted_lines)
				_update_ui()
			else:
				print("어플 구입 실패: 효과 적용 실패")
		else:
			print("어플 구입 실패: 코드가 부족합니다. (현재: ", GameState.uncommitted_lines, " / 필요: ", data.base_cost, ")")
			
	else:
		# [스태프 및 아이템(업그레이드) 구입 로직]
		if GameState.funds >= data.base_cost:
			GameState.funds -= data.base_cost
			data.apply_effect()
			print("스태프/아이템 구입 성공! 남은 자금: ", GameState.funds)
			_update_ui()
		else:
			print("스태프/아이템 구입 실패: 자금이 부족합니다. (현재: ", GameState.funds, " / 필요: ", data.base_cost, ")")
