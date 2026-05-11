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
	_update_lines(GameState.lines)
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

	# 초기화
	GameState.item_datas.clear()
	GameState.player_items.clear()

	for data in em.items_data:

		# =========================
		# ItemData 생성
		# =========================
		var item_data = ItemData.new()

		item_data.id = data.get("Item_ID", "")
		item_data.item_name = data.get("Name_Key", "")
		item_data.category = data.get("Category", "").to_lower()

		item_data.cost_fund = float(data.get("Cost_Fund", "0"))
		item_data.cost_line = float(data.get("Cost_Line", "0"))

		item_data.growth_rate = float(
			data.get("Growth_Rate (r)", "0.15")
		)

		item_data.effect_lps = float(
			data.get("Effect_LPS", "0")
		)

		item_data.effect_lpc = float(
			data.get("Effect_LPC", "0")
		)

		GameState.item_datas[item_data.id] = item_data

		# =========================
		# PlayerItem 생성
		# =========================
		var player_item = PlayerItem.new()
		player_item.item_id = item_data.id

		GameState.player_items[item_data.id] = player_item

		print("[ITEM LOADED]",
			item_data.id,
			"/ category:", item_data.category
		)

	print("[RESULT]")
	print("item_datas:", GameState.item_datas.size())
	print("player_items:", GameState.player_items.size())

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
	#print("UPDATE LINES:", value, " / label:", lines_label)
	lines_label.text = "Lines: %d" % int(value)

# =========================
# 상점 생성
# =========================
func _setup_shop():
	print("\n--- [SHOP SETUP START] ---")

	if GameState.item_datas.size() == 0:
		push_error("❌ GameState.items 비어있음 → 버튼 생성 불가")
		return
	for item in GameState.item_datas.values():
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
	print("[BEFORE] lines:", GameState.lines,
		"/ power:", GameState.manual_coding_power)

	GameState.do_manual_work()


	print("[AFTER] lines:", GameState.lines)

	print("===== [CLICK END] =====\n")
