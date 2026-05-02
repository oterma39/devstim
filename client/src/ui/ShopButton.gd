# res://src/ui/ShopButton.gd
extends Button

var data: BaseItem

func _pressed():
	if data and data.can_afford():
		# 데이터 타입에 따라 라인이 깎일지 달러가 깎일지 스스로 결정함
		data.consume_cost() 
		data.apply_effect()
		_update_ui()
	else:
		print("재화가 부족합니다!")

func _update_ui():
	if not data: return
	# 툴팁 및 텍스트 설정
	tooltip_text = "%s\n%s" % [data.item_name, data.description]
	var unit = "줄" if data is ProjectData else "$"
	$CostLabel.text = "비용: %d %s" % [data.base_cost, unit]
