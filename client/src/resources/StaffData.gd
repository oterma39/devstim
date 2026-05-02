extends BaseItem
class_name StaffData

# 부모(BaseItem)에 item_name과 base_cost가 이미 있으므로 
# staff_name과 hire_cost는 삭제하거나 아래 변수로 대체합니다.

@export var lines_per_second: int = 1  # 직원만의 고유 변수

# 부모의 기능을 가져와서 직원에게 맞게 완성
func apply_effect():
	# 자금 차감은 버튼에서 진행하지 않으므로 여기서 직접 처리할 수 있습니다.
	# 단, 2중 차감을 막기 위해 상점 버튼이 아닌 데이터에서만 차감
	if GameState.funds >= base_cost:
		GameState.funds -= base_cost
		GameState.total_lines_per_second += lines_per_second
		
		# 상태 갱신 신호 발송
		GameState.funds_changed.emit(GameState.funds)
		print("직원 고용 완료! 초당 생산량: ", GameState.total_lines_per_second)
		return true
	return false
