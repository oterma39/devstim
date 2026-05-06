extends Node2D

# =========================
# UI 노드 참조
# =========================
@onready var staff_container = %StaffContainer
@onready var upgrade_container = %UpgradeContainer
@onready var project_container = %ProjectContainer

@onready var funds_label = %FundsLabel
@onready var lines_label = %LinesLabel


# =========================
# 시작
# =========================
func _ready():
	print("\n===== [MAIN READY START] =====")

	print("[CHECK] GameState:", GameState)
	print("[CHECK] EconomyManager:", EconomyManager)

	_setup_game()
	_connect_signals()
	_setup_shop()
	_update_funds(GameState.funds)
	_update_lines(GameState.uncommitted_lines)
	print("===== [MAIN READY END] =====\n")


# =========================
# 초기화 (데이터 로드 + 인스턴스 생성)
# =========================
func _setup_game():
	print("\n--- [SETUP GAME START] ---")

	var em = EconomyManager

	em.load_csv()
	print("[DATA] items_data 개수:", em.items_data.size())

	if em.items_data.size() == 0:
		push_error("❌ CSV 데이터 없음")
		return

	GameState.items.clear()  # 🔥 중요: 중복 방지

	for data in em.items_data:
		var item = em.create_item_instance(data)

		print("[ITEM]",
			"id:", item.id,
			"category:", item.category,
			"cost_fund:", item.cost_fund,
			"cost_line:", item.cost_line,
			"lps:", item.effect_lps,
			"lpc:", item.effect_lpc
		)

		GameState.items[item.id] = item

	print("[RESULT] GameState.items:", GameState.items.size())
	print("--- [SETUP GAME END] ---\n")

# =========================
# 시그널 연결
# =========================
func _connect_signals():
	print("\n--- [SIGNAL CONNECT] ---")

	GameState.funds_changed.connect(_update_funds)
	GameState.lines_changed.connect(_update_lines)

	print("✔ funds_changed 연결 완료")
	print("✔ lines_changed 연결 완료")

	print("--- [SIGNAL CONNECT END] ---\n")


# =========================
# UI 업데이트
# =========================
func _update_funds(value):
	#print("[UI UPDATE] Funds →", value)
	funds_label.text = "Funds: $%d" % int(value)

func _update_lines(value):
	print("UPDATE LINES:", value, " / label:", lines_label)
	lines_label.text = "Lines: %d" % int(value)

# =========================
# 상점 생성
# =========================
func _setup_shop():
	print("\n--- [SHOP SETUP START] ---")

	if GameState.items.size() == 0:
		push_error("❌ GameState.items 비어있음 → 버튼 생성 불가")
		return

	for item in GameState.items.values():
		print("[CREATE BUTTON] id:", item.id, "category:", item.category)

		var btn = preload("res://src/ui/ShopButton.tscn").instantiate()
		btn.setup(item.id)

		match item.category:
			"staff":
				staff_container.add_child(btn)
				print(" → staff_container 추가 완료")

			"upgrade":
				upgrade_container.add_child(btn)
				print(" → upgrade_container 추가 완료")

			"project":
				project_container.add_child(btn)
				print(" → project_container 추가 완료")

	print("--- [SHOP SETUP END] ---\n")


# =========================
# 버튼 (수동 작업)
# =========================
func _on_work_button_pressed():
	print("\n===== [CLICK WORK BUTTON] =====")

	print("[BEFORE] lines:", GameState.uncommitted_lines,
		"/ power:", GameState.manual_coding_power)

	GameState.do_manual_work()

	print("[AFTER] lines:", GameState.uncommitted_lines)

	print("===== [CLICK END] =====\n")
