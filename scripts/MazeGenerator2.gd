extends TileMap

const width = 23
const height = 13

const continuation_probability = 0.4
const min_path_length = 60
const max_path_length = 100

const start = Vector2i(4,0)
const end = Vector2i(width-3, height-1)

var boxes = []
var animatedTile = preload("res://scenes/Box.tscn")

func build_maze():
	#cleanup all boxes
	for x in range(boxes.size()):
		var box = boxes.pop_back()
		box.queue_free()
		
	#create a maze
	var maze = create_maze()
	
	#create new boxes
	for x in range(width):
		for y in range(height-1, -1, -1):
			if(maze[y][x] == 1):
				spawn_box((x-12)*16, (y-5)*16, x+y)
				
	#wait for animation to end
	await get_tree().create_timer(4).timeout
	return true


func spawn_box(x,y, id):
	await get_tree().create_timer(id/20.0).timeout
	var instance = animatedTile.instantiate()
	boxes.append(instance)
	instance.position = Vector2(x, y - 16)
	instance.position = instance.position.snapped(Vector2.ONE * 16) + Vector2.ONE * 16 / 2
	add_child(instance)
	instance.start_fall(1.5) # 1.5 seconds


func create_maze():
	var template_row = []
	template_row.resize(width)
	template_row.fill(1)
	
	while true:
		# create a block of wall
		var maze = []
		for y in range(height):
			maze.append(template_row.duplicate())
		
		# generate passage
		carve_passage(maze, start)
		maze[start.y][start.x] = 0
		maze[end.y][end.x] = 0
		
		# check if possible and within parameters
		var reachable = is_reachable(maze, start, end)
		if min_path_length <= reachable and reachable <= max_path_length:
			return maze
	
# Breadth-first search (BFS) algorithm
func is_reachable(maze, start, end):
	var queue = [start]
	var visited = {start: 0}
	
	while queue.size() > 0:
		var node = queue.pop_front()
		var steps = visited[node]
		if node == end:
			return steps
			
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.UP]:
			var neighbour = node + offset
			
			#if in bounds, not a wall and hasn't been checked already
			if(in_bounds(neighbour) and maze[neighbour.y][neighbour.x] == 0 and neighbour not in visited):
				queue.append(neighbour)
				visited[neighbour] = steps + 1
	return -1

# Depth-first search (DFS) algorithm
func carve_passage(maze, current, last_direction=null):
	var directions = [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]
	
	# make last direction less likely to appear again
	if last_direction != null and randf() >= continuation_probability:
		directions.remove_at(last_direction)
	directions.shuffle()
	
	for i in range(directions.size()):
		var neighbour = current + (directions[i] * 2)
		if in_bounds(neighbour) and maze[neighbour.y][neighbour.x] == 1:
			var sum = current + directions[i]
			maze[sum.y][sum.x] = 0
			maze[neighbour.y][neighbour.x] = 0
			carve_passage(maze, neighbour, i)

func in_bounds(pos):
	return 0 <= pos.x and pos.x < width and 0 <= pos.y and pos.y < height
