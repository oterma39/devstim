extends BaseItem
class_name UpgradeData

# 업그레이드만의 고유 변수 (예: 클릭 한 번에 추가되는 코드 줄 수)
@export var click_power_increase: float = 1.0

func apply_effect() -> bool:
	if can_afford():
		consume_cost()
		# GameState에 정의된 클릭 파워 변수를 증가시킴
		GameState.manual_coding_power += click_power_increase
		print(item_name + " 업그레이드 완료!")
		return true
	
	print("업그레이드 비용 부족!")
	return false
