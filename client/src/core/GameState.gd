# res://src/core/GameState.gd
extends Node

signal funds_changed(new_funds)
signal lines_changed(new_lines)
signal lps_changed(new_lps)

var funds: float = 0.0 :
	set(val):
		funds = val
		funds_changed.emit(funds) # UI 갱신을 위해 반드시 필요합니다.

var uncommitted_lines: int = 0 :
	set(val):
		uncommitted_lines = val
		lines_changed.emit(uncommitted_lines) # 이 부분도 반드시 필요합니다.

var total_lines_per_second: float = 0.0 :
	set(val):
		total_lines_per_second = val
		lps_changed.emit(total_lines_per_second)

var manual_coding_power: int = 1

# [추가] 시간을 누적할 내부 변수
var _timer_accumulator: float = 0.0

# [추가] 프로세스 함수를 통해 초당 자동 생산 처리
func _process(delta: float) -> void:
	if total_lines_per_second > 0:
		_timer_accumulator += delta
		if _timer_accumulator >= 1.0:
			_timer_accumulator -= 1.0
			# 세터를 호출하여 lines_changed 시그널이 자동 방출되도록 대입
			uncommitted_lines += int(total_lines_per_second)
