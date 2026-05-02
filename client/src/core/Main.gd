# res://src/ui/ShopButton.gd
extends Button

var data: BaseItem = null

# 에러 해결: 매니저나 메뉴에서 호출하는 'setup' 함수를 정의합니다.
func setup(incoming_data: BaseItem) -> void:
	data = incoming_data
	_update_ui() # 데이터가 들어왔으니 UI를 즉시 갱신합니다.

# UI 업데이트 로직
func _update_ui() -> void:
	if not data:
		return
	
	# 이름과 비용 표시 (프로젝트와 일반 아이템 구분)
	$NameLabel.text = data.item_name
	
	if data is ProjectData:
		$CostLabel.text = str(data.base_cost) + " Lines"
	else:
		$CostLabel.text = "$" + str(data.base_cost)

# 클릭 시 구매 로직
func _pressed() -> void:
	if data and data.can_afford():
		data.consume_cost()
		data.apply_effect()
		_update_ui()
	else:
		print("재화가 부족합니다!")
