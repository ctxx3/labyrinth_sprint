extends TileMap

var maze = []
const width = 22
const height = 13
var current_offset_y = 0.0

var boxes = []
var animatedTile = preload("res://Box.tscn")

func build_maze():
	for x in range(boxes.size()):
		var box = boxes.pop_back()
		box.queue_free()
	create_maze()
	
	for x in range(width):
		var to_wait = 0
		for y in range(height-1, -1, -1):
			if(maze[y][x] == 1):
				spawn_box((x-12)*16, (y-5)*16, x+y)


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
		var steps = is_reachable(maze,Vector2i(4,2), Vector2i(width - 2, height - 2))
		if steps > 70:
			return maze
	

func is_reachable(maze, start, end):
	var queue = []
	queue.append({"position": start, "steps": 0})
	var visited = {}
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var node = current["position"]
		var steps = current["steps"]
		
		if node == end:
			return steps
		
		if not visited.has(node):
			visited[node] = true
			
			var x = node.x
			var y = node.y
			
			for offset in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
				var nx = x + offset.x
				var ny = y + offset.y
				
				if in_bounds(x,y) and maze[ny][nx] == 0:
					queue.append({"position": Vector2i(nx, ny), "steps": steps + 1})
	return -1


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
