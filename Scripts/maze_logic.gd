extends Node
class_name MazeLogic

static var path_to_end = []

# find the starting sqaure where players will spawn
static func find_starting_sqaure(grid: Array, size: int):
	var center: int = size / 2 # start in center
	var start = null
	if grid[center][center] == 0:
			start = {"row": center, "col": center}
			return start
	var look: int = center
	for i in range(center):
		# check above
		var above = look - (i+1)
		if grid[above][center] == 0:
			start = {"row": above, "col": center}
			return start
		# check below
		var below = look + (i+1)
		if grid[below][center] == 0:
			start = {"row": below + 1, "col": center}
			return start
			
	return start

# find the exit, which is the furthest reachable edge square from the start
static func find_furthest_edge_square(grid: Array, start_row: int, start_col: int):
	var rows = grid.size()
	var cols = grid[0].size()
	
	var visited = []
	for i in range(rows):
		visited.append([])
		for j in range(cols):
			visited[i].append(false)
	
	var queue = []
	var parents = {}
	queue.append({"row": start_row, "col": start_col, "dist": 0})
	visited[start_row][start_col] = true
	
	var directions = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	
	var furthest = null  # will store a dictionary: {row, col, dist}
	var furthest_pos = null # Vector2i rep
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var r = current["row"]
		var c = current["col"]
		var dist = current["dist"]
		
		# check if current is on the edge
		if r == 0 or r == rows - 1 or c == 0 or c == cols - 1:
			if furthest == null or dist > furthest["dist"]:
				furthest = {"row": r, "col": c, "dist": dist}
				furthest_pos = Vector2i(r, c)
		
		for dir in directions:
			var nr = r + int(dir.x)
			var nc = c + int(dir.y)
			if nr >= 0 and nr < rows and nc >= 0 and nc < cols:
				if not visited[nr][nc] and grid[nr][nc] == 0:
					visited[nr][nc] = true
					queue.append({"row": nr, "col": nc, "dist": dist + 1})
					parents[Vector2i(nr, nc)] = Vector2i(r, c)
	
	# reconstruct path from furthest to start
	var path = []
	var current_pos = furthest_pos
	while current_pos != Vector2i(start_row, start_col):
		path.append(current_pos)
		current_pos = parents.get(current_pos)
	path.append(Vector2i(start_row, start_col))
	path.reverse()
	path_to_end = path
	
	return furthest  # return a dictionary or null if no edge reachable

# function to get the positions of where the monsters will be
static func get_monster_positions(num_monsters: int):
	var skip = randi_range(4,6)
	var trimmed_path = path_to_end.slice(skip, path_to_end.size() - skip)
		
	var monster_positions = []
	#var step = float(usable_length - 1) / float(num_monsters - 1)
	
	for i in range(num_monsters):
		#var index = int(round(1 + i * step))
		var index = int(i * float(trimmed_path.size() - 1) / float(num_monsters - 1))
		monster_positions.append(trimmed_path[index])

	return monster_positions
