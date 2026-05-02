# res://src/managers/ProjectFactory.gd
class_name ProjectFactory

# 템플릿을 받아 복제(Duplicate)하고, 필요한 값을 덮어써서 반환하는 함수
static func create_project(template: ProjectData, custom_lines: int, custom_funds: float) -> ProjectData:
	var new_project = template.duplicate(true) as ProjectData
	
	# 초기값 덮어쓰기
	new_project.required_lines = custom_lines
	new_project.reward_funds = custom_funds
	
	return new_project
