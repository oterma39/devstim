extends Node

var items_data = []

func load_csv():
	print("\n===== [CSV LOAD START] =====")

	items_data.clear()

	var path = "res://data/GameData - Items.csv"
	print("[PATH]", path)

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("❌ 파일 열기 실패: " + path)
		return

	var header = file.get_csv_line()
	print("[HEADER]", header)

	while not file.eof_reached():
		var row = file.get_csv_line()

		# 빈 줄 스킵
		if row.size() == 0:
			continue

		# ⭐ 핵심: 길이 안 맞으면 스킵
		if row.size() < header.size():
			print("⚠️ 잘못된 row 스킵:", row)
			continue

		var data = {}

		for i in range(header.size()):
			data[header[i]] = row[i]

		items_data.append(data)

	print("[RESULT] 아이템 개수:", items_data.size())
	print("===== [CSV LOAD END] =====\n")

func create_item_instance(data: Dictionary) -> BaseItem:
	var item = BaseItem.new()

	item.id = data.get("Item_ID", "")
	item.item_name = data.get("Name_Key", "")
	item.category = data.get("Category", "").to_lower()

	item.cost_fund = float(data.get("Cost_Fund", "0"))
	item.cost_line = float(data.get("Cost_Line", "0"))
	item.growth_rate = float(data.get("Growth_Rate (r)", "0.15"))

	item.effect_lps = float(data.get("Effect_LPS", "0"))
	item.effect_lpc = float(data.get("Effect_LPC", "0"))

	return item
