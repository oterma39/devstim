extends Node

signal items_loaded

var items_db: Dictionary = {}
var staff_names: Array = []

# -------------------------
# CSV 로드 (아이템)
# -------------------------
func load_items(path: String):
	items_db.clear()

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		print("❌ 파일 열기 실패:", path)
		return

	var header = file.get_csv_line()
	print("CSV 헤더:", header)

	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() < header.size():
			continue

		var data = {}
		for i in range(header.size()):
			data[header[i]] = row[i]

		var item = _parse_item(data)
		if item:
			items_db[item["id"]] = item

	file.close()

	print("아이템 로드 완료:", items_db.size())
	print("키 목록:", items_db.keys())

	emit_signal("items_loaded")


# -------------------------
# CSV 로드 (이름)
# -------------------------
func load_staff_names(path: String):
	staff_names.clear()

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		print("❌ 이름 파일 열기 실패:", path)
		return

	file.get_csv_line() # header skip

	while not file.eof_reached():
		var row = file.get_csv_line()
		if row.size() == 0:
			continue

		staff_names.append(row[0])

	file.close()

	print("스태프 이름 로드:", staff_names.size())


# -------------------------
# 아이템 파싱 (핵심)
# -------------------------
func _parse_item(data: Dictionary) -> Dictionary:
	var category = str(data.get("Category", "")).strip_edges().to_lower()

	var item = {
		"id": data.get("Item_ID", ""),
		"name_key": data.get("Name_Key", ""),
		"category": category,
		"base_cost": float(data.get("Base_Cost", "0")),
		"effect_value": float(data.get("Effect_Value", "0")),
		"cost_type": _get_cost_type(category),
		"reward_funds": 0.0
	}

	# 프로젝트만 보상 있음
	if category == "project":
		item["reward_funds"] = float(data.get("Effect_Value", "0"))

	return item


# -------------------------
# 비용 타입 결정
# -------------------------
func _get_cost_type(category: String) -> String:
	match category:
		"project":
			return "lines"
		"staff", "upgrade":
			return "money"
	return "money"
