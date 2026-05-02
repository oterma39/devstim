# res://src/resources/BaseItem.gd
extends Resource
class_name BaseItem

enum PurchaseType {
	FUNDS,       # 자금 ($) 소모
	LINES,       # 코드 줄 소모
	BOTH         # 둘 다 소모
}

@export var id: String = ""
@export var description: String
@export var item_name: String
@export var base_cost: float
@export var purchase_type: PurchaseType = PurchaseType.FUNDS
@export var level: int = 1

func can_afford() -> bool:
	match purchase_type:
		PurchaseType.FUNDS:
			return GameState.funds >= base_cost
		PurchaseType.LINES:
			return GameState.uncommitted_lines >= int(base_cost)
	return false

# 상점에서 호출하여 재화를 차감하는 공통 함수
func consume_cost():
	match purchase_type:
		PurchaseType.FUNDS:
			var before_funds = GameState.funds
			GameState.funds -= base_cost
			GameState.funds_changed.emit(GameState.funds)
			print("--- [구입 완료 - 자금] ---")
			print("구입 전 자금: %d | 지불할 자금: %d | 차감 후 자금: %d" % [before_funds, base_cost, GameState.funds])
			
		PurchaseType.LINES:
			var before_lines = GameState.uncommitted_lines
			GameState.uncommitted_lines -= int(base_cost)
			GameState.lines_changed.emit(GameState.uncommitted_lines)
			print("--- [구입 완료 - 코드] ---")
			print("구입 전 코드: %d | 지불할 코드: %d | 차감 후 코드: %d" % [before_lines, base_cost, GameState.uncommitted_lines])

func apply_effect() -> bool:
	return false
