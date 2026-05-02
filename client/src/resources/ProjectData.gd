# res://src/resources/projects/ProjectData.gd
extends BaseItem
class_name ProjectData

@export var reward_funds: float

# 프로젝트는 '라인'을 사용하는 특수 로직으로 오버라이드
func can_afford() -> bool:
	return GameState.uncommitted_lines >= int(base_cost)

func consume_cost():
	var before = GameState.uncommitted_lines
	GameState.uncommitted_lines -= int(base_cost)
	GameState.lines_changed.emit(GameState.uncommitted_lines)
	
	# 프로젝트 완료 보상 지급
	GameState.funds += reward_funds
	GameState.funds_changed.emit(GameState.funds)
	
	print("--- [프로젝트 결제 완료] ---")
	print("ID: %s | 지불(라인): %d | 보상: +$%f" % [id, base_cost, reward_funds])

func apply_effect():
	# 프로젝트 완료 시의 추가 효과가 있다면 여기에 작성
	pass
