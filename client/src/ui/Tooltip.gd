# res://src/ui/Tooltip.gd
extends Control

@onready var panel_container = $Panel
@onready var title_label = $Panel/VBox/Title
@onready var desc_label = $Panel/VBox/Desc
@onready var cost_label = $Panel/VBox/Cost

var current_tween: Tween
var hide_timer: SceneTreeTimer # 지연 시간을 위한 타이머 변수

func _ready() -> void:
	visible = false
	modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if has_node("/root/Events"):
		if not Events.show_tooltip.is_connected(_on_show_tooltip):
			Events.show_tooltip.connect(_on_show_tooltip)
		if not Events.hide_tooltip.is_connected(_on_hide_tooltip):
			Events.hide_tooltip.connect(_on_hide_tooltip)

func _process(_delta: float) -> void:
	if visible:
		global_position = lerp(global_position, get_global_mouse_position() + Vector2(16, 16), 0.3)

func _on_show_tooltip(item_data) -> void:
	if not item_data:
		return
		
	# 1. 끄기 위해 대기하던 타이머가 있다면 취소 (이벤트가 덮어씌워짐)
	if hide_timer and hide_timer.time_left > 0:
		hide_timer = null # 타이머 참조 해제
		
	if current_tween and current_tween.is_running():
		current_tween.kill()
		
	# 2. 텍스트 즉시 갱신
	title_label.text = tr(item_data.item_name)
	desc_label.text = tr(item_data.description)
	
	if item_data.purchase_type == 0: 
		cost_label.text = "Cost: %s Lines" % str(item_data.base_cost)
	else:
		cost_label.text = "Cost: $%s" % str(item_data.base_cost)
	# 툴팁이 켜지기 전에 마우스 위치로 위치를 즉시 초기화하여 좌상단 잔상 방지	
	global_position = get_global_mouse_position() + Vector2(16, 16)

	visible = true
	modulate.a = 1.0
	scale = Vector2.ONE
	
	current_tween = create_tween()
	current_tween.tween_property(self, "modulate:a", 1.0, 0.05)

func _on_hide_tooltip() -> void:
	# 3. 즉시 끄지 않고 0.05초의 여유(유예 시간)를 둡니다.
	hide_timer = get_tree().create_timer(0.05)
	await hide_timer.timeout
	
	# 유예 시간(0.05초)이 지난 후에도 여전히 다른 버튼이 안 눌렸을 때만 툴팁을 끕니다.
	if hide_timer == null: 
		return # 다른 버튼으로 넘어가서 타이머가 무효화된 경우
		
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.05)
	await tween.finished
	
	visible = false
	hide_timer = null
