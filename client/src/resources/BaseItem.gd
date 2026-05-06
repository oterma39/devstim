extends Resource
class_name BaseItem

var id: String
var item_name: String
var category: String

# 🔥 비용 분리
var cost_fund: float
var cost_line: float
var growth_rate: float

# 🔥 효과 분리
var effect_lps: float   # 자동 증가
var effect_lpc: float   # 클릭 증가

var level: int = 0

func get_cost_fund() -> float:
	return cost_fund * pow(1.0 + growth_rate, level)

func get_cost_line() -> float:
	return cost_line * pow(1.0 + growth_rate, level)
