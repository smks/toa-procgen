extends Node2D

onready var tween = $Tween
onready var camera = $Camera2D
onready var rooms = $Rooms

const MIN_ROOMS_TO_CREATE = 15
const MAX_ROOMS_TO_CREATE = 45

var current_direction = Vector2.UP
var steps_history: Array = []
var rng = RandomNumberGenerator.new()
var rooms_total_to_create: int = MIN_ROOMS_TO_CREATE
var current_zoom = Vector2.ZERO

func _ready():
	generate()

# toggle camera zoom to see further out (Press key 1) OR further in (Press key 2)
func _input(event):
	if event.is_action_released("zoom_out"):
		camera.zoom += Vector2(1, 1)
	elif event.is_action_released("zoom_in"):
		if camera.zoom == Vector2(1, 1):
			return
		camera.zoom -= Vector2(1, 1)

func generate():
	rng.randomize()
	rooms_total_to_create = rng.randi_range(MIN_ROOMS_TO_CREATE, MAX_ROOMS_TO_CREATE)
	print('creating ' + str(rooms_total_to_create) + ' rooms')
	rooms.make(rooms_total_to_create)

func _on_Rooms_move_to_new_room(pos_to_move_to: Vector2):
	tween.interpolate_property(camera, "offset", camera.offset, pos_to_move_to, 0.3, Tween.TRANS_CIRC , Tween.EASE_OUT)
	tween.start()

func _on_Tween_tween_completed(object, key):
	rooms.finished_moving_room()
