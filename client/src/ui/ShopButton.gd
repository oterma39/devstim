extends Control

var item_id: String

@onready var button = self
@onready var label = $HBoxContainer/VBoxContainer/Name


# =========================
# 초기 설정
# =========================
func setup(id: String):

	item_id = id

	if not is_inside_tree():
		await ready

	_update_ui()


# =========================
# 시작
# =========================
func _ready():

	button.pressed.connect(_on_pressed)

	GameState.item_updated.connect(_on_item_updated)


# =========================
# 버튼 클릭
# =========================
func _on_pressed():

	print("\n===== [SHOP CLICK] =====")
	print("[ITEM]", item_id)

	GameState.buy_item(item_id)


# =========================
# 아이템 갱신
# =========================
func _on_item_updated(updated_id):

	if updated_id == item_id:
		_update_ui()


# =========================
# UI 갱신
# =========================
func _update_ui():

	# 데이터
	var data = GameState.item_datas[item_id]

	# 플레이어 상태
	var player = GameState.player_items[item_id]

	var fund_cost = data.get_cost_fund(player.level)
	var line_cost = data.get_cost_line(player.level)

	var text = "%s Lv.%d" % [
		data.item_name,
		player.level
	]

	# 돈 비용
	if fund_cost > 0:
		text += "\n💰 %d" % int(fund_cost)

	# 라인 비용
	if line_cost > 0:
		text += "\n🧾 %d" % int(line_cost)

	# 효과 표시
	#if data.effect_lps > 0:
	#	text += "\n⚡ LPS +%d" % int(data.effect_lps)

	#if data.effect_lpc > 0:
	#	text += "\n🖱 LPC +%d" % int(data.effect_lpc)

	label.text = text
