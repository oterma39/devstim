extends Node

signal funds_changed(value)
signal lines_changed(value)
signal item_updated(item_id)

var funds: float = 0
var lines: float = 0
#var uncommitted_lines: float = 0

var manual_coding_power: float = 1.0
var auto_lines_per_sec: float = 0.0

var item_datas = {}
var player_items = {}

# =========================
# 기본 루프
# =========================
func _process(delta):
	lines += auto_lines_per_sec * delta
	lines_changed.emit(lines)
# =========================
# 수동 작업
# =========================
func do_manual_work():
	print("A",lines,manual_coding_power)
	lines += manual_coding_power
	lines_changed.emit(lines)
	print("B",lines,manual_coding_power)

# =========================
# 구매
# =========================
func buy_item(item_id: String) -> bool:

	# 데이터 체크
	if not item_datas.has(item_id):
		print("❌ item data 없음:", item_id)
		return false

	if not player_items.has(item_id):
		print("❌ player item 없음:", item_id)
		return false

	var data = item_datas[item_id]
	var player = player_items[item_id]

	var fund_cost = data.get_cost_fund(player.level)
	var line_cost = data.get_cost_line(player.level)

	print("\n===== [BUY ITEM] =====")
	print("[ITEM]", item_id)
	print("[LEVEL]", player.level)

	print("[COST]")
	print("fund:", fund_cost)
	print("line:", line_cost)

	print("[BEFORE]")
	print("funds:", funds)
	print("lines:", lines)

	# 비용 체크
	if funds < fund_cost:
		print("❌ 돈 부족")
		return false

	if lines < line_cost:
		print("❌ 라인 부족")
		return false

	# 차감
	funds -= fund_cost
	lines -= line_cost

	# 레벨 증가
	player.level += 1

	# 효과 적용
	auto_lines_per_sec += data.effect_lps
	manual_coding_power += data.effect_lpc

	print("[AFTER]")
	print("funds:", funds)
	print("lines:", lines)

	print("[POWER]")
	print("LPS:", auto_lines_per_sec)
	print("LPC:", manual_coding_power)

	# UI 갱신
	funds_changed.emit(funds)
	lines_changed.emit(lines)

	item_updated.emit(item_id)

	print("===== [BUY END] =====\n")

	return true

# =========================
# 효과 처리 (핵심)
# =========================
func _apply_effect(item):
	match item.category:
		"staff":
			auto_lines_per_sec += item.effect_value

		"upgrade":
			manual_coding_power += item.effect_value

		"project":
			funds += item.reward_funds

			# 프로젝트는 소모형이면 리셋
			item.level = 0
