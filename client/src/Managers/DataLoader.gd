# res://src/managers/DataLoader.gd
extends Node

func load_shop_items(csv_path: String) -> Array:
	var items = []
	var file = FileAccess.open(csv_path, FileAccess.READ)
	
	# 첫 줄(헤더) 건너뛰기
	file.get_csv_line()
	
	while !file.at_end_of_file():
		var line = file.get_csv_line()
		if line.size() < 5: continue
		
		var item_type = line[0] # "PROJECT", "UPGRADE", "STAFF"
		var new_item
		
		if item_type == "PROJECT":
			new_item = ProjectData.new()
			new_item.reward_funds = float(line[4]) # CSV의 보상 컬럼
		else:
			new_item = BaseItem.new() # 업그레이드 등
			
		new_item.id = line[1]
		new_item.item_name = line[2]
		new_item.base_cost = float(line[3]) # 여기서 55가 주입됨!
		
		items.append(new_item)
	return items
