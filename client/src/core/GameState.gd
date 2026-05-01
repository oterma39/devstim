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
