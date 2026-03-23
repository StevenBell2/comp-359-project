class_name SpatialHashGridFast extends Node

var cell_size: float
var _cells: Array = []
var view_size: Vector2
var grid_size: Vector2i
func _init(_cell_size: float):
	cell_size = _cell_size
	view_size = get_viewport().size
	grid_size = Vector2i(
		ceil(view_size.x / cell_size),
		ceil(view_size.y / cell_size)
	)
	for y in range(grid_size.y):
		var row = []
		row.resize(grid_size.x)
		row.fill(null)
		_cells.append(row)


func _get_cell_coords(pos: Vector2) -> Vector2i:
	return Vector2i(
		clampi(floor(pos.x / cell_size), 0, grid_size.x - 1),
		clampi(floor(pos.y / cell_size), 0, grid_size.y - 1)
	)

func insert(client: SpatialClientFast):
	# Fetch the coordinates of the cell then insert the node there.
	# Note: The node list at the cell level is maintained as a Doubly linked list.
	if client._cellLinkedListNode != null:
		remove(client)
	var cell_coords = _get_cell_coords(client.position)

	var headNode = {
		"next": null,
		"prev": null,
		"client": client
	}

	headNode.next = _cells[cell_coords.y][cell_coords.x]

	if _cells[cell_coords.y][cell_coords.x] != null:
		_cells[cell_coords.y][cell_coords.x].prev = headNode

	_cells[cell_coords.y][cell_coords.x] = headNode
	client._cellLinkedListNode = headNode

func remove(client: SpatialClientFast, pos: Vector2 = Vector2.INF):
	# Remove the node from the linked list at the cell level.
	if pos == Vector2.INF:
		pos = client.position
	var node = client._cellLinkedListNode
	if node == null:
		return

	if node.next != null:
		node.next.prev = node.prev

	if node.prev != null:
		node.prev.next = node.next

	if node.prev == null:
		var cell_coords = _get_cell_coords(pos)
		_cells[cell_coords.y][cell_coords.x] = node.next
	
	client._cellLinkedListNode = null

func _find_nearby(pos: Vector2, radius: float) -> Array:
	# Fetch the coordinates of the cells that are within the radius and then traverse the linked list at each cell to fetch the clients.
	var results: Array[SpatialClientFast] = []

	var i1 = _get_cell_coords(pos - Vector2(radius, radius))
	var i2 = _get_cell_coords(pos + Vector2(radius, radius))

	for y in range(i1.y, i2.y + 1):
		for x in range(i1.x, i2.x + 1):
			var node = _cells[y][x]
			while node != null:
				results.append(node.client)
				node = node.next

	return results

func update(client: SpatialClientFast, old_position: Vector2) -> void:
	# Check if the client has moved to a different cell, if yes then remove it from the old cell and insert it into the new cell.
	var old_cell_coords = _get_cell_coords(old_position)
	var new_cell_coords = _get_cell_coords(client.position)

	if old_cell_coords != new_cell_coords:
		remove(client, old_position)
		insert(client)
