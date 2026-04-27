extends Button

signal bought(data)#money,production)

var item_data
var amount = 0

var item_name = ""
var money = 0
var production = 0

func setup(data):#nm,prc,prd):
	item_data = data
	_update_ui()
	#text = str(nm) + " - cost :" +str(prc) +" / " + str(prd) 

func _update_ui():
	text = (str(item_data.name)
		+"["+str(amount)
		+"man] cost:"
		+str(item_data.money)
		+"/Production:"+str(item_data.production))

func update_amount(new_amount:int):
	amount = new_amount
	_update_ui()


func _on_pressed() -> void:
	bought.emit(item_data)
	pass # Replace with function body.
