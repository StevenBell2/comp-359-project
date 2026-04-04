class_name SpatialHashGridOptimized

# we made this version after finding that the previous "fast" version was not able to get the performance increase we wanted
# based off of the 10MinutePhysics collision detection implementation using Godot PackedInt32Array 

var cell_size: float
var _inv_cell_size: float
var _table_size: int = 0
var _table_mask: int = 0

var _cell_head: PackedInt32Array
var _next: PackedInt32Array

var _clients: Array = []
var _requires_rebuild: bool = true

var query_ids: PackedInt32Array
var query_size: int = 0

var hash_constants = [92837111, 689287499, 283923481]

func _init(_cell_size: float, _world_min: Vector3 = Vector3.ZERO, _world_max: Vector3 = Vector3.ZERO):
    cell_size = _cell_size
    # inverted cell size
    # we use this instead of get_cell_coords to get the benefits of using multiplication instead of division
    _inv_cell_size = 1.0 / _cell_size

    if _world_min != _world_max:
        var ics := 1.0 / _cell_size
        var nx := int(ceil((_world_max.x - _world_min.x) * ics)) + 1
        var ny := int(ceil((_world_max.y - _world_min.y) * ics)) + 1
        var nz := int(ceil((_world_max.z - _world_min.z) * ics)) + 1
        _resize_table(_next_pow2(nx * ny * nz))

func _next_pow2(n: int) -> int:
    var p := 1
    while p < n:
        p <<= 1
    return p

# resizes the hash table to the new size and rehashes all the clients
func _resize_table(new_size: int) -> void:
    if new_size == _table_size:
        return
    _table_size = new_size
    _table_mask = new_size - 1
    _cell_head = PackedInt32Array()
    _cell_head.resize(new_size)
    _cell_head.fill(-1)

func insert(client: SpatialClient) -> void:
    _clients.append(client)
    _requires_rebuild = true

func remove(client: SpatialClient, _pos: Vector3 = Vector3.INF) -> void:
    _clients.erase(client)
    _requires_rebuild = true

func update(_client: SpatialClient, _old_position: Vector3) -> void:
    _requires_rebuild = true

func _build() -> void:
    var num := _clients.size()
    if num == 0:
        _requires_rebuild = false
        return

    if _next.size() != num:
        _next = PackedInt32Array()
        _next.resize(num)
        query_ids = PackedInt32Array()
        query_ids.resize(num)

    if _table_size == 0:
        _resize_table(_next_pow2(num * 8))

    _cell_head.fill(-1)

    var ics := _inv_cell_size
    var mask := _table_mask

    for i in range(num):
        var pos: Vector3 = _clients[i].position
        var h: int = (
            (floori(pos.x * ics) * hash_constants[0]) ^
            (floori(pos.y * ics) * hash_constants[1]) ^
            (floori(pos.z * ics) * hash_constants[2])
        ) & mask
        _next[i] = _cell_head[h]
        _cell_head[h] = i

    _requires_rebuild = false

func find_nearby(pos: Vector3, radius: float) -> void:
    query_size = 0

    if _requires_rebuild:
        _build()

    var ics := _inv_cell_size
    var mask := _table_mask

    var x0 := floori((pos.x - radius) * ics)
    var y0 := floori((pos.y - radius) * ics)
    var z0 := floori((pos.z - radius) * ics)
    var x1 := floori((pos.x + radius) * ics)
    var y1 := floori((pos.y + radius) * ics)
    var z1 := floori((pos.z + radius) * ics)

    for xi in range(x0, x1 + 1):
        for yi in range(y0, y1 + 1):
            for zi in range(z0, z1 + 1):
                var h: int = (
                    (xi * hash_constants[0]) ^ (yi * hash_constants[1]) ^ (zi * hash_constants[2])
                ) & mask
                var idx := _cell_head[h]
                
                while idx != -1:
                    query_ids[query_size] = idx
                    query_size += 1
                    idx = _next[idx]

func clear() -> void:
    _clients.clear()
    _cell_head.fill(-1)
    _next = PackedInt32Array()
    query_ids = PackedInt32Array()
    query_size = 0
    _requires_rebuild = true