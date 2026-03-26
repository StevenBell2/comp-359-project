extends Node3D

@export var ball_scene: PackedScene
@export var detect_radius: float = 8.0
@export var neighbour_radius: float = 16.0

var balls: Array = []
var clients: Array = []
var grid: SpatialHashGridFast3D
var naive = preload("res://scripts/naive.gd").new()

#benchmark variables:
var use_spatial := true
var query_time_ms := 0.0
var broadphase_candidate_count := 0
var collision_pair_count := 0
var print_timer := 0.0 
var print_interval := 5.0

func _ready():
	grid = SpatialHashGridFast3D.new(5.0)  # no world size needed anymore
	add_child(grid)
	for i in range(100):
		var b = ball_scene.instantiate()
		# add randf_range(-50, 50) insted of 0 for y, if you want to see the 3d
		b.position = Vector3(randf_range(-50, 50), 0, randf_range(-50, 50))
		add_child(b)
		balls.append(b)
		var client = SpatialClientFast3D.new()
		client.position = b.position
		client.data = b
		grid.insert(client)
		clients.append(client)

func _process(delta):

	#toggle between naive and spatial
	if Input.is_action_just_pressed("ui_accept"):
	use_spatial = !use_spatial
	print("Using Spatial Hash:", use_spatial)

	for i in clients.size():
		var old_pos = clients[i].position
		clients[i].position = balls[i].position
		grid.update(clients[i], old_pos)
	var detector = $Detector

	broadphase_candidate_count = 0
	collision_pair_count = 0
	var start = Time.get_ticks_usec()

	var nearby
	if use_spatial:
		nearby = grid._find_nearby(detector.position, neighbour_radius)
	else:
		nearby = naive.find_nearby_naive(balls, detector.position, neighbour_radius)

	var end = Time.get_ticks_usec()
	query_time_ms = (end - start) / 1000.0

	for b in balls:
		b.set_color(Color.WHITE)
	for client in nearby:
		broadphase_candidate_count += 1
		var dist = client.position.distance_to(detector.position)
		if dist < detect_radius:
			collision_pair_count += 1
			client.data.set_color(Color.RED)
		elif dist < neighbour_radius:
			client.data.set_color(Color.YELLOW)

# print benchmark
print_timer += delta 
if print_timer >= print_interval: 
	print_timer = 0.0
	print( 
		"Objects: ", balls.size(), 
		" | Query(ms): ", query_time_ms, 
		" | Candidates: ", broadphase_candidate_count, 
		" | Collisions: ", collision_pair_count 
		)
