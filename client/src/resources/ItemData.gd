extends Resource
class_name ItemData

var id: String
var item_name: String
var category: String

var cost_fund: float
var cost_line: float
var growth_rate: float

var effect_lps: float
var effect_lpc: float

func get_cost_fund(level: int) -> float:
	return cost_fund * pow(1.0 + growth_rate, level)

func get_cost_line(level: int) -> float:
	return cost_line * pow(1.0 + growth_rate, level)
