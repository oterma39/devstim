# res://src/managers/DataLoader.gd
extends Node

func load_shop_data(path: String) -> Array[BaseItem]:
	var items: Array[BaseItem] = []
	var file = FileAccess.open(path, FileAccess.READ)
	
	if not file:
		push_error("CSV 파일을 열 수 없습니다: " + path)
		return items

	file.get_csv_line() # 헤더 스킵

	while !file.at_end_of_file():
		var line = file.get_csv_line()
		if line.size() < 4: continue # 최소 데이터 확인

		var type = line[0] # PROJECT, UPGRADE, STAFF
		var item: BaseItem
		
		# 💡 타입에 따라 다른 클래스 생성 (팩토리 로직)
		if type == "PROJECT":
			item = ProjectData.new()
			if line.size() > 4:
				item.reward_funds = float(line[4]) # 프로젝트 전용 보상금
		else:
			item = BaseItem.new() # 일반 업그레이드/스태프

		# 공통 데이터 주입 (템플릿 값 무시하고 CSV 값이 덮어씀)
		item.id = line[1]
		item.item_name = line[2]
		item.base_cost = float(line[3]) # 여기서 55가 정확히 들어감
		
		items.append(item)
	
	return items
