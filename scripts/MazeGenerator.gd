extends TileMap

var maze = []
const width = 22
const height = 13
var current_offset_y = 0.0

var boxes = []
var animatedTile = preload("res://Box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	build_maze()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#var RandVector2 = Vector2i(randi_range(-9,9),randi_range(-6,6))
	#set_cell(2, RandVector2, 0, Vector2(5,10))

func _unhandled_input(event):
	if(event.is_action_pressed("ui_text_backspace")):
		build_maze()

func build_maze():
	create_maze()
	
	for x in boxes:
		remove_child(x)
	
	for x in range(width):
		var to_wait = 0
		for y in range(height-1, -1, -1):
			if(maze[y][x] == 1):
				spawn_box((x-12)*16, (y-5)*16, x+y)
				#await get_tree().create_timer(0.01).timeout
				#to_wait += 0.01
				#set_cell(4, Vector2i(x-12, y-5), 0, Vector2(5,10))


func spawn_box(x,y, id):
	await get_tree().create_timer(id/20.0).timeout
	var instance = animatedTile.instantiate()
	boxes.append(instance)
	instance.position = Vector2(x, y - 16)
	instance.position = instance.position.snapped(Vector2.ONE * 16) + Vector2.ONE * 16 / 2
	add_child(instance)
	instance.start_fall(1.5)


func create_maze():
	while true:
		maze = []
		for y in range(height):
			maze.append([])
			for x in range(width):
				maze[y].append(1)
		
		carve_passage_from(4, height - 2)
		maze[0][4] = 0
		maze[height - 1][width - 2] = 0
		var steps = is_reachable(maze,Vector2i(1,1), Vector2i(width - 2, height - 2))
		if steps and steps > 70:
			return maze
	

func is_reachable(maze, start, end):
	var stack = [start]
	var visited = []
	var steps = 0
	while stack.size() > 0:
		var node = stack.pop_back()
		if node == end:
			return steps
		if not visited.has(node):
			visited.append(node)
			var x = node[0]
			var y = node[1]
			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					if dx == 0 or dy == 0:
						var nx = x + dx
						var ny = y + dy
						if 0 <= nx and nx < maze[0].size() and 0 <= ny and ny < maze.size() and maze[ny][nx] == 0:
							stack.append(Vector2i(nx, ny))
							steps += 1
	return false

func in_bounds(x,y):
	return 0 <= x and x < width and 0 <= y and y < height

func carve_passage_from(cx,cy):
	var directions = [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]
	directions.shuffle()
	
	for d in directions:
		var nx = cx + d.x * 2
		var ny = cy + d.y * 2
		if in_bounds(nx, ny) and maze[ny][nx] == 1:
			maze[cy+d.y][cx+d.x] = 0
			maze[ny][nx] = 0
			carve_passage_from(nx, ny)
