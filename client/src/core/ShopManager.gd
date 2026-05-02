# res://src/managers/ShopManager.gd
extends Node

# 미리 로드해 둔 템플릿 리소스
const ProjectTemplate = preload("res://resources/template_project.tres")

# 상점 목록을 반환하는 함수
func get_shop_items() -> Array:
	var items = []
	
	# 💡 팩토리를 사용하여 템플릿으로부터 동적 인스턴스 생성
	var instagram_project = ProjectFactory.create_project(
		ProjectTemplate,
		55,    # required_lines (필요한 코드 줄)
		100.0  # reward_funds (획득할 자금)
	)
	
	items.append(instagram_project)
	# 다른 일반 아이템들도 이곳에서 추가할 수 있습니다.
	
	return items
