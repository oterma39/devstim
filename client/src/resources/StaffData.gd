# res://src/resources/staff/StaffData.gd
extends BaseItem
class_name StaffData

@export var lines_per_second: int = 1

func apply_effect() -> bool:
	GameState.total_lines_per_second += lines_per_second
	print("직원 고용 완료! 초당 생산량: ", GameState.total_lines_per_second)
	return true
