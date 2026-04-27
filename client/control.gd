extends Control
##debug
@onready var debug_pannel_1 = $CanvasLayer/PanelContainer/VBoxContainer/DebugLabel1
@onready var debug_pannel_2 = $CanvasLayer/PanelContainer/VBoxContainer/DebugLabel2
##-----------------debug
var money = 0
var clickPower = 1 #click
var auto_production = 0

var inventory = {} # {"개발자 이름": 보유수}
var spawned_items = {} # {"개발자 이름": 버튼 객체}

var item_scene = preload("res://ShopItem.tscn")
var shop_items:Array[ItemData]
func _ready() -> void:
    _load_items_from_folder("res://items/")
    var saved_data = SaveManager.load_game(1)
    inventory = saved_data.get("inventory",{})
    if not saved_data.is_empty():
        money = saved_data.get("money",0)
        clickPower = saved_data.get("clickPower",1)
        auto_production = saved_data.get("auto_production",0)
    $Label.text = str(money) + "lines"	

    _display_items()
    $CanvasLayer/OnOffDebug.text = "RESET"
    _update_debug_display()
    
func _load_items_from_folder(path:String):
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var fileName = dir.get_next()
        while fileName != "":
            if !dir.current_is_dir() and fileName.ends_with(".tres"):
                var item = load(path + fileName)
                if item is ItemData:
                    shop_items.append(item)
            fileName = dir.get_next()
        dir.list_dir_end()
        shop_items.sort_custom(func(a, b): return a.order < b.order)
        
func _display_items():
    for data in shop_items:
        var new_item = item_scene.instantiate()
        $VBoxContainer.add_child(new_item)
        # 1. 버튼 객체를 이름으로 저장해둡니다 (나중에 찾아서 숫자 바꾸려고)
        spawned_items[data.name] = new_item
        # 2. 초기 셋업 (인벤토리에 이미 데이터가 있다면 그 숫자를 가져옴)
        var current_count = inventory.get(data.name,0)
        new_item.setup(data)
        new_item.update_amount(current_count)
        new_item.bought.connect(_on_item_bought)
    


func _on_item_bought(data):
    if money>=data.money:
        money -= data.money
        auto_production += data.production
        
        # 3. 인벤토리 숫자 올리기
        inventory[data.name] = inventory.get(data.name,0)+1
        # 4. 시각적으로 버튼 텍스트 업데이트!
        spawned_items[data.name].update_amount(inventory[data.name])
        _save_current_game()
        
    else:             
        $Label.text = "not enough Cost"	

func _on_button_pressed():
    money += clickPower
    # 유니티의 GetComponent<Label>().text 대신 '$'를 씁니다.
    $Label.text = str(money) + "Lines"

func _on_timer_timeout() -> void:
    money += auto_production
    $Label.text = str(money) + "Lines"
    pass # Replace with function body.

# Control.gd 하단에 추가
func _save_current_game():
    var data = {
        "money": money,
        "clickPower": clickPower,
        "auto_production": auto_production,
        "inventory":inventory
        # "inventory": ... 나중에 아이템 개별 수량도 추가
    }
    SaveManager.save_game(data, 1)

# Control.gd 에 추가
func _process(_delta):
    # 디버그 패널이 켜져 있을 때만 업데이트 (성능 절약)
    if debug_pannel_1.visible:
        _update_debug_display()
        
func _update_debug_display():
        var info = """--- DEBUG INFO ---
        Money: %d
        Auto: %d
        Click: %d
        Items: %s
        """ % [money, auto_production, clickPower, str(inventory)]
        debug_pannel_1.text = info
# 2. 데이터 초기화 버튼
func _on_reset_save_pressed():
    var dir = DirAccess.open("user://")
    if dir:
        dir.remove("save_slot_1.dat") # 파일명 확인!
        print("세이브 삭제됨")
        get_tree().reload_current_scene() # 씬 재시작


func _on_on_off_debug_pressed() -> void:
    pass # Replace with function body.
