extends Resource
class_name BaseItem # 다른 스크립트에서 부모로 인식하게 함
enum PurchaseType {
	FUNDS,       # 자금 ($) 소모
	LINES,       # 코드 줄 소모
	BOTH         # 둘 다 소모
}
@export var id: String = ""
@export var description: String # 이 부분이 빠져 있으면 에러가 발생합니다.
@export var item_name: String
@export var base_cost: float # 기본 가격 (또는 기본 수치)
@export var purchase_type: PurchaseType = PurchaseType.FUNDS # 구입 타입 기본값 지정
@export var level: int = 1

# 아이템의 구매 가능 여부를 체크하는 공통 함수
func can_afford() -> bool:
	match purchase_type:
		PurchaseType.FUNDS:
			return GameState.funds >= base_cost
		PurchaseType.LINES:
			return GameState.uncommitted_lines >= base_cost
		PurchaseType.BOTH:
			# 예: base_cost는 funds, 추가 변수(예: required_lines)는 코드 줄로 검사 가능
			return false # 필요에 따라 로직 확장 가능
	return false
	
# 공통 로직: 돈 깎기
func consume_cost():
	print("consume_cost")
	GameState.funds -= base_cost

# 가상 함수: 자식들이 오버라이드할 함수
func apply_effect():
	pass
