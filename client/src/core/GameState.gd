extends Node

signal funds_changed(new_funds)
signal lines_changed(new_lines)
signal lps_changed(new_lps)

var funds: float = 0.0:
	set(val):
		funds = val
		funds_changed.emit(funds)

var uncommitted_lines: int = 0:
	set(val):
		uncommitted_lines = val
		lines_changed.emit(uncommitted_lines)

# 👉 스태프 효과는 이걸 사용
var total_lines_per_second: float = 0.0:
	set(val):
		total_lines_per_second = val
		lps_changed.emit(total_lines_per_second)

var manual_coding_power: int = 1

# 내부 타이머
var _timer_accumulator: float = 0.0


func _process(delta: float) -> void:
	if total_lines_per_second > 0:
		_timer_accumulator += delta
		if _timer_accumulator >= 1.0:
			_timer_accumulator -= 1.0
			uncommitted_lines += int(total_lines_per_second)
