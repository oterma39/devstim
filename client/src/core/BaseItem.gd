extends Resource
class_name BaseItem # 다른 스크립트에서 부모로 인식하게 함

@export var item_name: String
@export var base_cost: float

# 공통 로직: 살 수 있는지 체크
func can_afford() -> bool:
	return GameState.funds >= base_cost

# 공통 로직: 돈 깎기
func consume_cost():
	GameState.funds -= base_cost

# 가상 함수: 자식들이 오버라이드할 함수
func apply_effect():
	pass
