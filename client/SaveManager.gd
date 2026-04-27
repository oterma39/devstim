extends Node

const SECRET_KEY = "Oterma39"

#save
func save_game(data:Dictionary,slot:int=1):
	var save_path = "user://save_slot_%d.dat"%slot
	#save with key
	var file = FileAccess.open_encrypted_with_pass(save_path,FileAccess.WRITE,SECRET_KEY)
	
	if file:
		file.store_var(data)
		file.close()
		print("save done - ",slot," slot")
	else:
		print("save error")


#Load
func load_game(slot:int=1)->Dictionary:
	var load_path = "user://save_slot_%d.dat"%slot
	var password = SECRET_KEY
	
	if not FileAccess.file_exists(load_path):
		return {}
		
	var file = FileAccess.open_encrypted_with_pass(load_path,FileAccess.READ,SECRET_KEY)
	if file:
		var data = file.get_var()
		file.close()
		return data
	return {}
