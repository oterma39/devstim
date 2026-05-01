extends BaseItem
class_name StaffData

# 부모(BaseItem)에 item_name과 base_cost가 이미 있으므로 
# staff_name과 hire_cost는 삭제하거나 아래 변수로 대체합니다.

@export var lines_per_second: int = 1  # 직원만의 고유 변수

# 부모의 기능을 가져와서 직원에게 맞게 완성
func apply_effect() -> bool:
	if can_afford():
		consume_cost()
		GameState.total_lines_per_second += lines_per_second
		print(item_name + " 고용 성공!")
		return true
	
	print("자금 부족!")
	return false
