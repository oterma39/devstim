# res://src/Main.gd
extends Node

# 1. 상점 버튼 씬 미리 불러오기
const SHOP_BUTTON_SCENE = preload("res://src/ui/ShopButton.tscn")
const TooltipScript = preload("res://src/ui/Tooltip.gd")
# 2. 버튼들이 들어갈 컨테이너 연결
@onready var staff_container = $UI/Root/ShopArea/Staffs
@onready var upgrade_container = $UI/Root/ShopArea/Upgrade
@onready var project_container = $UI/Root/ShopArea/Projects

# 현재 상태 UI
@onready var funds_label = $UI/Root/HUD/TopBar/FundsLabel
@onready var lines_label = $UI/Root/HUD/TopBar/LinesLabel
@onready var work_button = $UI/Root/WorkArea/CodingButton # 본인의 클릭 버튼 노드

func _ready():
	# 게임 시작 시 상점 아이템 배치 및 시그널 연결
	if not GameState.funds_changed.is_connected(_on_funds_changed):
		GameState.funds_changed.connect(_on_funds_changed)
	
	if not GameState.lines_changed.is_connected(_on_lines_changed):
		GameState.lines_changed.connect(_on_lines_changed)
	
	# 초기값 한 번 출력
	_on_funds_changed(GameState.funds)
	_on_lines_changed(GameState.uncommitted_lines)
	
	_setup_shop()
	
	# 클릭 버튼 시그널 연결
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
	
	# 2. 업그레이드 생성
	var upgrades = _load_resources("res://resources/upgrades/")
	print("2. 업그레이드 폴더에서 읽어온 개수: ", upgrades.size())
	_generate_buttons(upgrades, upgrade_container)
	
	# 3. 프로젝트 생성 (수정된 부분: 경로 확인 및 디버깅 로그 추가)
	var projects = _load_resources("res://resources/projects/")
	print("3. 프로젝트 폴더에서 읽어온 개수: ", projects.size())
	
	# 프로젝트 컨테이너가 null이 아니고 데이터가 있다면 버튼 생성
	if projects.size() > 0:
		_generate_buttons(projects, project_container)
	else:
		print("경고: res://resources/projects/ 경로에서 프로젝트 데이터를 찾을 수 없습니다.")

## 폴더 내의 .tres 파일을 모두 읽어오는 함수
func _load_resources(path: String) -> Array:
	var list = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
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
		
	print("컨테이너 [", container.name, "] 의 기존 자식 수: ", container.get_children().size())	
	for child in container.get_children():
		child.queue_free()
		
	for data in data_list:
		if data is BaseItem:
			var btn = SHOP_BUTTON_SCENE.instantiate()
			container.add_child(btn)
			btn.setup(data)

# 버튼을 클릭했을 때 실행될 로직 (지연 없이 즉시 반영)
func _on_work_button_pressed() -> void:
	print("clicked")
	GameState.uncommitted_lines += GameState.manual_coding_power
	print("현재 코드 줄: ", GameState.uncommitted_lines)
