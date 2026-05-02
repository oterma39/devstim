extends Node

var items_db: Dictionary = {}
var staff_names: Array = []
var used_names: Dictionary = {}

# 데이터 로드 완료 시그널 추가
signal items_loaded

# 1. 성장 함수 (비용 계산)
static func calculate_cost(base_cost: float, growth_rate: float, current_level: int) -> float:
	return base_cost * pow(1 + growth_rate, current_level)

# 2. 아이템 데이터 로드
func load_items(path: String):
	items_db.clear()
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("❌ 파일을 열 수 없습니다: ", path)
		return
		
	# 1. 헤더 읽기 및 제거
	var header = file.get_csv_line()
	print("CSV 헤더 확인: ", header)
	
	var count = 0
	while not file.eof_reached():
		var line = file.get_csv_line()
		
		# 줄에 데이터가 부족하거나 빈 줄인 경우 건너뛰기
		if line.size() < 11 or line[0].strip_edges() == "":
			continue
			
		var category = line[0].strip_edges()
		var item_id = line[1].strip_edges()
		var name_key = line[2].strip_edges()
		var desc_key = line[3].strip_edges()
		var base_cost = float(line[7]) if line.size() > 7 and line[7].is_valid_float() else 0.0
		
		var item_data = {
			"Category": category,
			"Item_id": item_id,
			"Name_key": name_key,
			"Desc_key": desc_key,
			"Base_cost": base_cost,
			"Growth_rate": float(line[8]) if line.size() > 8 else 0.1,
			"Effect_value": line[9] if line.size() > 9 else "",
			"Icon_path": line[10] if line.size() > 10 else ""
		}
		
		# 2. Key(item_id)를 명확하게 지정하여 저장
		items_db[item_id] = item_data
		count += 1
		
	print("  [성공] CSV 아이템 데이터 로드 완료, 최종 개수: ", count)
	print("  [데이터] 저장된 items_db 키 목록: ", items_db.keys())
	
	emit_signal("items_loaded")

# 3. 스태프 이름 데이터 로드
func load_staff_names(csv_file_path: String) -> void:
	staff_names.clear()
	used_names.clear()
	
	var file = FileAccess.open(csv_file_path, FileAccess.READ)
	if file == null:
		printerr("이름 파일을 불러올 수 없습니다: ", csv_file_path)
		return
		
	var is_header = true
	while not file.eof_reached():
		var csv_line = file.get_csv_line()
		
		if csv_line.is_empty() or csv_line[0] == "":
			continue
			
		if is_header:
			is_header = false
			continue
		
		staff_names.append({
			"id": csv_line[0],
			"name_kr": csv_line[1],
			"name_en": csv_line[2],
			"name_ja": csv_line[3]
		})

# 4. 고용 시 미사용 고유 이름 할당
func get_unique_staff_name() -> Dictionary:
	for name_data in staff_names:
		var name_id = name_data["id"]
		if not used_names.has(name_id):
			used_names[name_id] = true
			return name_data
			
	return {
		"id": "DEFAULT",
		"name_kr": "신규 인력",
		"name_en": "New Staff",
		"name_ja": "新規人材"
	}

# 5. 비용 계산 위임
func get_next_cost(item_id: String, current_level: int) -> float:
	if not items_db.has(item_id):
		push_warning("아이템 ID를 찾을 수 없습니다: " + item_id)
		return 0.0
		
	var item = items_db[item_id]
	
	# [수정 포인트] 딕셔너리 형태의 데이터에 맞게 키("Base_cost", "Growth_rate")를 가져오도록 수정
	var base_cost = float(item.get("Base_cost", 0.0))
	var growth_rate = float(item.get("Growth_rate", 0.1))
	
	return calculate_cost(base_cost, growth_rate, current_level)
