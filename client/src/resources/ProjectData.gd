# res://src/resources/projects/ProjectData.gd (또는 해당 경로)
extends BaseItem
class_name ProjectData

@export var reward_funds: float
@export var required_lines: int

func can_afford() -> bool:
	return GameState.uncommitted_lines >= required_lines

func consume_cost():
	# 1. 코드 줄을 감소시키고 시그널 발송
	GameState.uncommitted_lines -= required_lines

func apply_effect():
	if can_afford():
		# 2. 코드 줄 차감
		consume_cost()
		
		# 3. 자금 증가 및 갱신
		GameState.funds += reward_funds
		print("자금 증가 확인: +", reward_funds, " / 현재 자금: ", GameState.funds)
		
		return true
	return false
