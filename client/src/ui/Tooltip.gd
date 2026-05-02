# res://src/ui/Tooltip.gd
extends Control

@onready var panel_container = $Panel
@onready var title_label = $Panel/VBox/Title
@onready var desc_label = $Panel/VBox/Desc
@onready var cost_label = $Panel/VBox/Cost

@onready var economy_manager = get_node_or_null("/root/EconomyManager")

var current_tween: Tween
var hide_timer: SceneTreeTimer

func _ready() -> void:
	visible = false
	modulate.a = 0.0
	
	# 툴팁이 마우스 이벤트를 방해하지 않으면서 렌더링되도록 설정
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if has_node("/root/Events"):
		if not Events.show_tooltip.is_connected(_on_show_tooltip):
			Events.show_tooltip.connect(_on_show_tooltip)
		if not Events.hide_tooltip.is_connected(_on_hide_tooltip):
			Events.hide_tooltip.connect(_on_hide_tooltip)

func _process(_delta: float) -> void:
	if visible:
		# 부드럽게 마우스를 따라오도록 위치 설정
		global_position = lerp(global_position, get_global_mouse_position() + Vector2(16, 16), 0.3)

func _on_show_tooltip(item_data) -> void:
	if not item_data:
		return
		
	if hide_timer and hide_timer.time_left > 0:
		hide_timer = null
		
	if current_tween and current_tween.is_running():
		current_tween.kill()
		
	title_label.text = tr(item_data.item_name)
	desc_label.text = tr(item_data.description)
	
	var identifier = item_data.id if "id" in item_data else (item_data.item_id if "item_id" in item_data else item_data.item_name)
	var current_level = item_data.level if "level" in item_data else 1
	
	var cost = 0.0
	if economy_manager:
		var raw_cost = economy_manager.get_next_cost(identifier, current_level)
		cost = int(round(raw_cost)) # 동일한 사사오입 적용
	
	if item_data.purchase_type == 0: 
		cost_label.text = "Cost: $%d" % cost
	else:
		cost_label.text = "Cost: %d Lines" % cost
		
	# 위치 초기화
	global_position = get_global_mouse_position() + Vector2(16, 16)

	visible = true
	modulate.a = 1.0
	scale = Vector2.ONE
	
	current_tween = create_tween()
	current_tween.tween_property(self, "modulate:a", 1.0, 0.05)

func _on_hide_tooltip() -> void:
	hide_timer = get_tree().create_timer(0.05)
	await hide_timer.timeout
	
	if hide_timer == null: 
		return
		
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.05)
	await tween.finished
	
	visible = false
	hide_timer = null
