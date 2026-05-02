extends Node

# 씬
const SHOP_BUTTON_SCENE = preload("res://src/ui/ShopButton.tscn")

# 컨테이너
@onready var staff_container = $UI/Root/ShopArea/Staffs
@onready var upgrade_container = $UI/Root/ShopArea/Upgrade
@onready var project_container = $UI/Root/ShopArea/Projects

# UI
@onready var funds_label = $UI/Root/HUD/TopBar/FundsLabel
@onready var lines_label = $UI/Root/HUD/TopBar/LinesLabel
@onready var work_button = $UI/Root/WorkArea/CodingButton

func _ready():
	var economy_manager = get_tree().root.get_node_or_null("EconomyManager")

	if not economy_manager:
		print("❌ EconomyManager 없음")
		return

	# -------------------------
	# UI 업데이트 연결
	# -------------------------
	if not GameState.funds_changed.is_connected(_on_funds_changed):
		GameState.funds_changed.connect(_on_funds_changed)

	if not GameState.lines_changed.is_connected(_on_lines_changed):
		GameState.lines_changed.connect(_on_lines_changed)

	_on_funds_changed(GameState.funds)
	_on_lines_changed(GameState.uncommitted_lines)

	# -------------------------
	# 버튼 클릭 연결
	# -------------------------
	if work_button and not work_button.pressed.is_connected(_on_work_button_pressed):
		work_button.pressed.connect(_on_work_button_pressed)

	# -------------------------
	# 데이터 로드 & 시그널 연결
	# -------------------------
	if not economy_manager.items_loaded.is_connected(_setup_shop):
		economy_manager.items_loaded.connect(_setup_shop)

	economy_manager.load_items("res://data/GameData - Items.csv")
	economy_manager.load_staff_names("res://data/GameData - StaffNames.csv")

	# 🔥 이미 로드된 경우 대비 (핵심)
	if economy_manager.items_db.size() > 0:
		print("이미 데이터 있음 → 바로 상점 생성")
		_setup_shop()

# -------------------------
# UI 업데이트
# -------------------------
func _on_funds_changed(new_funds: float):
	if funds_label:
		funds_label.text = "Funds: $%d" % new_funds

func _on_lines_changed(new_lines: int):
	if lines_label:
		lines_label.text = "Lines: %d" % new_lines

# -------------------------
# 상점 생성
# -------------------------
func _setup_shop():
	print("--- 상점 생성 시작 ---")

	var economy_manager = get_tree().root.get_node_or_null("EconomyManager")
	if not economy_manager:
		print("❌ EconomyManager 없음")
		return

	# 중복 생성 방지
	if staff_container.get_child_count() > 0:
		print("이미 생성됨 → 스킵")
		return

	var items = economy_manager.items_db.values()
	print("아이템 개수:", items.size())

	for item_data in items:
		var category = str(item_data.get("category", "")).strip_edges().to_lower()

		var container = _get_container(category)
		if not container:
			print("❌ 잘못된 카테고리:", category)
			continue

		# 🔥 tres 제거 → 코드로 생성
		var data_instance = BaseItem.new()

		data_instance.id = item_data.get("id", "")
		data_instance.item_name = item_data.get("name_key", "")
		data_instance.base_cost = item_data.get("base_cost", 0.0)
		data_instance.cost_type = item_data.get("cost_type", "money")
		data_instance.effect_value = item_data.get("effect_value", 0.0)
		data_instance.reward_funds = item_data.get("reward_funds", 0.0)
		data_instance.category = category

		print("생성:", data_instance.id, category)

		var btn = SHOP_BUTTON_SCENE.instantiate()
		container.add_child(btn)

		# 🔥 반드시 add_child 이후
		btn.setup(data_instance)

	print("상점 생성 완료")

# -------------------------
# 컨테이너 선택
# -------------------------
func _get_container(category: String):
	match category:
		"staff":
			return staff_container
		"upgrade":
			return upgrade_container
		"project":
			return project_container
	return null

# -------------------------
# 컨테이너 초기화 (필요 시)
# -------------------------
func _clear_container(container: Control):
	if container:
		for child in container.get_children():
			child.queue_free()

# -------------------------
# 클릭 처리
# -------------------------
func _on_work_button_pressed() -> void:
	GameState.uncommitted_lines += GameState.manual_coding_power
	GameState.lines_changed.emit(GameState.uncommitted_lines)
