extends Node

var best_time = INF;

func save_game():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json = JSON.stringify({"best_time": best_time})
	save_game.store_line(json)

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	var json_string = save_game.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	var node_data = json.get_data()
	best_time = node_data["best_time"]
