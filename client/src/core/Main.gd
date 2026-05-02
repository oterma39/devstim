# res://src/core/Main.gd
extends Node

const SHOP_BUTTON_SCENE = preload("res://src/ui/ShopButton.tscn")
const TooltipScript = preload("res://src/ui/Tooltip.gd")

@onready var staff_container = $UI/Root/ShopArea/Staffs
@onready var upgrade_container = $UI/Root/ShopArea/Upgrade
@onready var project_container = $UI/Root/ShopArea/Projects

@onready var funds_label = $UI/Root/HUD/TopBar/FundsLabel
@onready var lines_label = $UI/Root/HUD/TopBar/LinesLabel
@onready var work_button = $UI/Root/WorkArea/CodingButton

func _ready():
	print("--- Main.gd의 _ready()가 실행되었습니다! ---") # 👈 이 로그가 찍히는지 확인
	
	if not GameState.funds_changed.is_connected(_on_funds_changed):
		GameState.funds_changed.connect(_on_funds_changed)
	
	if not GameState.lines_changed.is_connected(_on_lines_changed):
		GameState.lines_changed.connect(_on_lines_changed)
	
	_on_funds_changed(GameState.funds)
	_on_lines_changed(GameState.uncommitted_lines)
	
	var economy_manager = get_tree().root.get_node_or_null("EconomyManager")
	if economy_manager:
		if not economy_manager.is_connected("items_loaded", _setup_shop):
			economy_manager.items_loaded.connect(_setup_shop)
		
		economy_manager.load_items("res://data/GameData - Items.csv")
		economy_manager.load_staff_names("res://data/GameData - StaffNames.csv")
		
		if economy_manager.items_db.size() > 0:
			call_deferred("_setup_shop")
	else:
		print("❌ [에러] EconomyManager를 찾지 못했습니다.")

	if work_button and not work_button.pressed.is_connected(_on_work_button_pressed):
		work_button.pressed.connect(_on_work_button_pressed)
	
func _on_funds_changed(new_funds: float):
	if funds_label:
		funds_label.text = "Funds: $%d" % new_funds

func _on_lines_changed(new_lines: int):
	if lines_label:
		lines_label.text = "Lines: %d" % new_lines

func _setup_shop():
	print("--- 1. 상점 초기화 시작 ---")
	
	var economy_manager = get_tree().root.get_node_or_null("EconomyManager")
	if not economy_manager:
		print("❌ [에러] EconomyManager 노드를 찾을 수 없습니다.")
		return
	print("   [성공] EconomyManager 로드 완료")
	
	var staff_template = load("res://resources/template_staff.tres")
	var upgrade_template = load("res://resources/template_upgrade.tres")
	var project_template = load("res://resources/template_project.tres")
	
	_clear_container(staff_container)
	_clear_container(upgrade_container)
	_clear_container(project_container)
	
	var item_keys = economy_manager.items_db.keys()
	print("   [데이터] 읽어올 아이템 개수: ", item_keys.size())
	
	for item_id in item_keys:
		var item_data = economy_manager.items_db[item_id]
		
		# [수정 포인트] 딕셔너리 키("Category")를 명시적으로 조회하도록 수정
		var category = str(item_data.get("Category", "")).strip_edges().to_lower()
		
		var data_instance = null
		var container = null
		
		if category == "staff":
			if staff_template:
				data_instance = staff_template.duplicate()
				container = staff_container
		elif category == "upgrade":
			if upgrade_template:
				data_instance = upgrade_template.duplicate()
				container = upgrade_container
		elif category == "project":
			if project_template:
				data_instance = project_template.duplicate()
				container = project_container
		else:
			print("      -> ❌ 카테고리 불일치: ", category)
			
		if data_instance and container:
			data_instance.id = item_id
			data_instance.item_name = item_data.get("Name_key", "")
			data_instance.base_cost = item_data.get("Base_cost", 0.0)
			
			print("      -> [생성 시도] 아이템 ID: ", item_id)
			var btn = SHOP_BUTTON_SCENE.instantiate()
			container.add_child(btn)
			btn.setup(data_instance)
			print("      -> [성공] 버튼 생성 완료")
		else:
			print("      -> ❌ 인스턴스 또는 컨테이너 누락으로 생성 실패")

func _clear_container(container: Control):
	if container:
		for child in container.get_children():
			child.queue_free()

func _on_work_button_pressed() -> void:
	print("clicked")
	GameState.uncommitted_lines += GameState.manual_coding_power
	print("현재 코드 줄: ", GameState.uncommitted_lines)
