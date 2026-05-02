# res://src/ui/ShopButton.gd
extends Button

# 이 버튼이 들고 있을 데이터 (CSV에서 생성된 ProjectData 또는 BaseItem)
var data: BaseItem = null

@onready var name_label = $NameLabel   # 아이템 이름 표시용
@onready var cost_label = $CostLabel   # 비용 표시용 (Lines 또는 $)
@onready var icon_rect = $Icon         # 아이콘이 있다면 사용

func _ready() -> void:
	# 데이터가 주입된 후 UI를 업데이트하기 위해 호출
	if data:
		_update_ui()

# 1. 외부(ShopMenu 등)에서 데이터를 주입할 때 호출하는 함수
func set_button_data(incoming_data: BaseItem) -> void:
	data = incoming_data
	_update_ui()

# 2. UI 업데이트 로직 (프로젝트 vs 일반 아이템 구분)
func _update_ui() -> void:
	if not data:
		return
	
	# 이름 설정
	name_label.text = data.item_name
	
	# 비용 및 툴팁 설정
	if data is ProjectData:
		# [프로젝트] 라인 소모, 달러 보상
		cost_label.text = str(data.base_cost) + " Lines" # 여기서 base_cost는 CSV의 55
		tooltip_text = "[PROJECT]\n%s\n소모: %d Lines\n보상: +$%d" % [
			data.description, data.base_cost, data.reward_funds
		]
	else:
		# [업그레이드/스태프] 달러 소모
		cost_label.text = "$" + str(data.base_cost)
		tooltip_text = "[UPGRADE/STAFF]\n%s\n비용: $%d" % [
			data.description, data.base_cost
		]

# 3. 버튼 클릭 시 구매 로직
func _pressed() -> void:
	if not data:
		return

	# 클릭 피드백 (트윈 애니메이션)
	var tw = create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

	# 구매 가능 여부 체크
	if data.can_afford():
		print("--- [구매 프로세스 시작] ---")
		print("아이템: ", data.item_name, " (ID: ", data.id, ")")
		
		# 결제 진행 (ProjectData는 라인을, BaseItem은 달러를 깎음)
		data.consume_cost()
		
		# 효과 적용 (클릭 파워 증가, 자동 라인 증가 등)
		data.apply_effect()
		
		# UI 갱신
		_update_ui()
		print("--- [구매 프로세스 종료] ---")
	else:
		_show_insufficient_funds_warning()

# 4. 재화 부족 시 시각적 피드백 (선택 사항)
func _show_insufficient_funds_warning():
	print("로그: 재화가 부족하여 구매 불가 - ", data.item_name)
	# 여기에 버튼을 붉은색으로 깜빡이는 등의 연출 추가 가능
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color.RED, 0.1)
	tw.tween_property(self, "modulate", Color.WHITE, 0.1)
