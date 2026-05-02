# res://src/resources/projects/ProjectData.gd
extends BaseItem
class_name ProjectData

@export var reward_funds: float
@export var required_lines: int

func can_afford() -> bool:
	return GameState.uncommitted_lines >= required_lines

func apply_effect() -> bool:
	if can_afford():
		var before_lines = GameState.uncommitted_lines
		var before_funds = GameState.funds
		
		# 1. 코드 줄 소모
		GameState.uncommitted_lines -= required_lines
		GameState.lines_changed.emit(GameState.uncommitted_lines)
		
		# 2. 자금 지급
		GameState.funds += reward_funds
		GameState.funds_changed.emit(GameState.funds)
		
		print("--- [프로젝트 완료 - 코드/자금] ---")
		print("구입 전 코드: %d | 사용한 코드: %d | 남은 코드: %d" % [before_lines, required_lines, GameState.uncommitted_lines])
		print("구입 전 자금: %d | 획득한 자금: +%d | 최종 자금: %d" % [before_funds, reward_funds, GameState.funds])
		
		return true
	return false
