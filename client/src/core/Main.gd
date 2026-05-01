extends Node

# 1. 아까 만든 대문자 ShopButton 씬을 미리 불러옵니다.
const SHOP_BUTTON_SCENE = preload("res://src/ui/ShopButton.tscn")

# 2. 버튼들이 들어갈 컨테이너 연결 (스크린샷의 트리 구조 기준)
@onready var staff_container = $UI/Root/ShopArea/Staffs
@onready var upgrade_container = $UI/Root/ShopArea/Upgrade
@onready var project_container = $UI/Root/ShopArea/Projects
#현재 상태 UI
@onready var funds_label = $UI/Root/HUD/TopBar/FundsLabel
@onready var lines_label = $UI/Root/HUD/TopBar/LinesLabel
@onready var work_button = $UI/Root/WorkArea/CodingButton # 본인의 클릭 버튼 노드 경로로 수정하세요

func _ready():
	# 게임 시작 시 상점 아이템들을 배치합니다.
	# 시그널 연결 (값이 바뀔 때마다 함수 실행)
# 시그널 연결 (안 되어 있다면 추가)
	if not GameState.funds_changed.is_connected(_on_funds_changed):
		GameState.funds_changed.connect(_on_funds_changed)
	
	if not GameState.lines_changed.is_connected(_on_lines_changed):
		GameState.lines_changed.connect(_on_lines_changed)
	# 초기값 한 번 출력
	_on_funds_changed(GameState.funds)
	_on_lines_changed(GameState.uncommitted_lines)
	_setup_shop()
	# 자금(Funds) 변경 시그널 연결 확인
	if not GameState.funds_changed.is_connected(_on_funds_changed):
		GameState.funds_changed.connect(_on_funds_changed)
	
	_on_funds_changed(GameState.funds) # 초기값 설정
# [추가] 클릭 버튼 시그널 연결
	if work_button and not work_button.pressed.is_connected(_on_work_button_pressed):
		work_button.pressed.connect(_on_work_button_pressed)

func _on_funds_changed(new_funds: float):
	if funds_label:
		funds_label.text = "Funds: $%d" % new_funds

func _on_lines_changed(new_lines: int):
	if lines_label:
		lines_label.text = "Lines: %d" % new_lines
func _setup_shop():
	print("--- 상점 초기화 시작 ---")
# 1. 직원 생성
	var staffs = _load_resources("res://resources/staffs/")
	print("1. 직원 폴더에서 읽어온 개수: ", staffs.size())
	_generate_buttons(staffs, staff_container)
	
	# 2. 업그레이드 생성 (확실하게 upgrade_container로 지정)
	var upgrades = _load_resources("res://resources/upgrades/")
	print("2. 업그레이드 폴더에서 읽어온 개수: ", upgrades.size())
	_generate_buttons(upgrades, upgrade_container)
	
	# 3. 프로젝트 생성
	var projects = _load_resources("res://resources/projects/")
	print("3. 프로젝트 폴더에서 읽어온 개수: ", projects.size())
	_generate_buttons(projects, project_container)

	# 데이터 리스트를 돌면서 버튼 생성
## [공용 함수] 폴더 내의 .tres 파일을 모두 읽어오는 함수
func _load_resources(path: String) -> Array:
	var list = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# 폴더명이 아니면서 .tres 확장자로 끝나는 파일만 로드
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var item = load(path + "/" + file_name)
				if item is BaseItem:
					list.append(item)
			file_name = dir.get_next()
	else:
		print("경로를 찾을 수 없습니다: ", path)
	return list

## 핵심: 어떤 데이터든 버튼으로 만들어주는 범용 함수
func _generate_buttons(data_list: Array, container: Control):
	if container == null:
		return
# 자식 삭제 전 상태 출력
	print("컨테이너 [", container.name, "] 의 기존 자식 수: ", container.get_children().size())	
	for child in container.get_children():
		child.queue_free()
		
	for data in data_list:
		if data is BaseItem:
			var btn = SHOP_BUTTON_SCENE.instantiate()
			container.add_child(btn)
			btn.setup(data)

# 버튼을 클릭했을 때 실행될 로직
func _on_work_button_pressed() -> void:
	print("clicked")
	# GameState의 manual_coding_power 또는 uncommitted_lines 값을 증가시킵니다.
	# (예: 클릭할 때마다 +1씩 코드 줄이 증가하도록 설정)
	GameState.uncommitted_lines += GameState.manual_coding_power
	print("현재 코드 줄: ", GameState.uncommitted_lines) # 콘솔 확인용


func _on_coding_button_pressed() -> void:
	pass # Replace with function body.
