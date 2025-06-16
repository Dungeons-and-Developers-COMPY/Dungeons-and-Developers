extends Node
class_name MazeLogic

static func find_starting_sqaure(grid: Array, size: int):
	var center: int = size / 2
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


static func find_furthest_edge_square(grid: Array, start_row: int, start_col: int) -> Variant:
	var rows = grid.size()
	var cols = grid[0].size()
	
	var visited = []
	for _i in range(rows):
		visited.append([])
		for _j in range(cols):
			visited[_i].append(false)
	
	var queue = []
	queue.append({"row": start_row, "col": start_col, "dist": 0})
	visited[start_row][start_col] = true
	
	var directions = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
	
	var furthest = null  # Will store a Dictionary: {row, col, dist}
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var r = current["row"]
		var c = current["col"]
		var dist = current["dist"]
		
		# Check if current is on the edge
		if r == 0 or r == rows - 1 or c == 0 or c == cols - 1:
			if furthest == null or dist > furthest["dist"]:
				furthest = {"row": r, "col": c, "dist": dist}
		
		for dir in directions:
			var nr = r + int(dir.x)
			var nc = c + int(dir.y)
			if nr >= 0 and nr < rows and nc >= 0 and nc < cols:
				if not visited[nr][nc] and grid[nr][nc] == 0:
					visited[nr][nc] = true
					queue.append({"row": nr, "col": nc, "dist": dist + 1})
	
	return furthest  # Return a Dictionary or null if no edge reachable
