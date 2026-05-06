extends Node

signal funds_changed(value)
signal lines_changed(value)
signal item_updated(item_id)

var funds: float = 0
var lines: float = 0
var uncommitted_lines: float = 0

var manual_coding_power: float = 1.0
var auto_lines_per_sec: float = 0.0

var items := {} # id → BaseItem

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
	lines += manual_coding_power
	lines_changed.emit(lines)

# =========================
# 구매
# =========================
func buy_item(item_id: String) -> bool:
	if not items.has(item_id):
		return false

	var item = items[item_id]

	var fund_cost = item.get_cost_fund()
	var line_cost = item.get_cost_line()

	# 🔥 비용 체크 (둘 다)
	if funds < fund_cost:
		return false
	if lines < line_cost:
		return false

	# 🔥 차감
	funds -= fund_cost
	lines -= line_cost

	item.level += 1

	# 🔥 효과 적용
	auto_lines_per_sec += item.effect_lps
	manual_coding_power += item.effect_lpc

	# 🔥 UI 갱신
	funds_changed.emit(funds)
	lines_changed.emit(lines)

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
