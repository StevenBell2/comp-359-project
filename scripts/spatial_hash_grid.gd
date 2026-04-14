class_name SpatialHashGrid

var cell_size: float
var world_min: Vector3
var world_max: Vector3
var min_cell: Vector3i
var max_cell: Vector3i
var _cells: Dictionary = {}

func _init(
    _cell_size: float,
    _world_min: Vector3 = Vector3.ZERO,
    _world_max: Vector3 = Vector3.ZERO
):
    cell_size = _cell_size
    world_min = _world_min
    world_max = _world_max

    min_cell = Vector3i(
        floori(world_min.x / cell_size),
        floori(world_min.y / cell_size),
        floori(world_min.z / cell_size)
    )

    max_cell = Vector3i(
        int(ceil(world_max.x / cell_size)) - 1,
        int(ceil(world_max.y / cell_size)) - 1,
        int(ceil(world_max.z / cell_size)) - 1
    )

func _cell_key(x: int, y: int, z: int) -> Vector3i:
    return Vector3i(x, y, z)

func _clamp_cell_coords(coords: Vector3i) -> Vector3i:
    return Vector3i(
        clampi(coords.x, min_cell.x, max_cell.x),
        clampi(coords.y, min_cell.y, max_cell.y),
        clampi(coords.z, min_cell.z, max_cell.z)
    )

func _get_cell_coords(pos: Vector3) -> Vector3i:
    return _clamp_cell_coords(
        Vector3i(
            floori(pos.x / cell_size),
            floori(pos.y / cell_size),
            floori(pos.z / cell_size)
        )
    )

func insert(client: SpatialClient):
    var cell_coords := _get_cell_coords(client.position)

    if not _cells.has(cell_coords):
        _cells[cell_coords] = []
    _cells[cell_coords].append(client)

func remove(client: SpatialClient, pos: Vector3 = Vector3.INF):
    if pos == Vector3.INF:
        pos = client.position

    var cell_coords := _get_cell_coords(pos)

    if _cells.has(cell_coords):
        _cells[cell_coords].erase(client)
        if _cells[cell_coords].is_empty():
            _cells.erase(cell_coords)

func update(client: SpatialClient, old_position: Vector3):
    var old_cell_coords := _get_cell_coords(old_position)
    var new_cell_coords := _get_cell_coords(client.position)

    if old_cell_coords != new_cell_coords:
        remove(client, old_position)
        insert(client)

func clear() -> void:
    _cells.clear()

func find_nearby(pos: Vector3, radius: float, out: Array) -> void:
    out.clear()

    var min_coords := _get_cell_coords(pos - Vector3(radius, radius, radius))
    var max_coords := _get_cell_coords(pos + Vector3(radius, radius, radius))

    for x in range(min_coords.x, max_coords.x + 1):
        for y in range(min_coords.y, max_coords.y + 1):
            for z in range(min_coords.z, max_coords.z + 1):
                var cell_key := _cell_key(x, y, z)
                if _cells.has(cell_key):
                    out.append_array(_cells[cell_key])