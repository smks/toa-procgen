extends Node2D

signal started
#signal finished
signal change_room(direction)

enum Cell { PERIMETER, BORDER, WALKABLE, SLOWABLE, OBSTACLE, FALLABLE, BREAKABLE }
enum RoomType { FIRST_ROOM, LAST_ROOM }

export var walkable_probability := 0.1

var inner_size := Vector2(35, 20)
var start_point := Vector2(5, 3)

# x and y index of this room as part of a collection of rooms
var step: Vector2
var room_type = null

var has_door_top: bool = true
var has_door_bottom: bool = true
var has_door_right: bool = true
var has_door_left: bool = true
var is_leaving_room = false

#onready var tile_map: TileMap = $TileMap
onready var blocked_passage_collisions = $BlockedPassageCollisions
onready var open_passage_collisions = $OpenPassageCollisions
onready var move_to_top_room = $MoveToTopRoom
onready var move_to_bottom_room = $MoveToBottomRoom
onready var move_to_left_room = $MoveToLeftRoom
onready var move_to_right_room = $MoveToRightRoom

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	set_physics_process(false)
	set_process(false)
	disable_collisions()
	setup()
	
func disable_collisions():
	blocked_passage_collisions.disable()
	open_passage_collisions.disable()

func set_doors(top: bool, bottom: bool, left: bool, right: bool):
	has_door_top = top
	has_door_bottom = bottom
	has_door_left = left
	has_door_right = right
	
	# block all passages and only open available doors
	blocked_passage_collisions.enable()
	
	if has_door_top:
		open_passage_collisions.toggle(true, 'Top')
		blocked_passage_collisions.toggle(false, 'Top')
	
	if has_door_bottom:
		open_passage_collisions.toggle(true, 'Bottom')
		blocked_passage_collisions.toggle(false, 'Bottom')
		
	if has_door_left:
		open_passage_collisions.toggle(true, 'Left')
		blocked_passage_collisions.toggle(false, 'Left')

	if has_door_right:
		open_passage_collisions.toggle(true, 'Right')
		blocked_passage_collisions.toggle(false, 'Right')	

func _unhandled_input(event):
	if event.is_action_released("ui_select"):
		generate()

func setup() -> void:
	generate()

func generate() -> void:
	emit_signal("started")
	generate_walkable_tiles()

func generate_walkable_tiles() -> void:
	pass
#	for x in range(start_point.x, inner_size.x):
#		for y in range(start_point.y, inner_size.y):
#            tile_map.set_cell(x, y, get_random_tile(0.9))
			
func get_random_tile(probability: float) -> int:
	return Cell.WALKABLE if rng.randf() < probability else rand_range(3, 5)
	
func set_as_first_room():
	room_type = RoomType.FIRST_ROOM
	print('FIRST ROOM')
	
func set_as_last_room():
	room_type = RoomType.LAST_ROOM
	print('LAST ROOM')
	
func add_player(player):
	return get_node('YSort').add_child(player)
	
func get_player_and_remove():
	var y_sort = get_node('YSort')
	var player = y_sort.get_node('Player')
	y_sort.remove_child(player)
	return player
	
func _on_MoveToTopRoom_body_entered(body: Node):
	if is_leaving_room:
		return
	if body.name == 'Player':
		leave_room(Vector2.UP)

func _on_MoveToBottomRoom_body_entered(body: Node):
	if is_leaving_room:
		return
	if body.name == 'Player':
		leave_room(Vector2.DOWN)

func _on_MoveToLeftRoom_body_entered(body: Node):
	if is_leaving_room:
		return
	if body.name == 'Player':
		leave_room(Vector2.LEFT)
	
func _on_MoveToRightRoom_body_entered(body: Node):
	if is_leaving_room:
		return
	if body.name == 'Player':
		leave_room(Vector2.RIGHT)
		
func leave_room(direction: Vector2):
	is_leaving_room = true
	emit_signal("change_room", direction)
	yield(get_tree().create_timer(1.0), "timeout")
	is_leaving_room = false

# debug code below

func _draw():
	add_room_type()
	if has_door_top:
		add_door_up()
	if has_door_bottom:
		add_door_down()
	if has_door_left:
		add_door_left()
	if has_door_right:
		add_door_right()

func add_room_type():
	if room_type == null:
		return
	draw_rect(
		Rect2(
			Vector2(590, 310),
			Vector2(100, 100)
		), 
		Color(
			0.7,
			0.4,
			0.2,
			1
		),
		true
	)

func add_door_up():
	draw_rect(
		Rect2(
			Vector2(544, 0),
			Vector2(192, 96)
		), 
		Color(
			0.2,
			0.4,
			1,
			1
		),
		true
	)

func add_door_down():
	draw_rect(
		Rect2(
			Vector2(544, 640),
			Vector2(192, 96)
		), 
		Color(
			0.2,
			0.4,
			1,
			1
		),
		true
	)
	
func add_door_left():
	draw_rect(
		Rect2(
			Vector2(64, 256),
			Vector2(96, 192)
		), 
		Color(
			0.2,
			0.4,
			1,
			1
		),
		true
	)	
func add_door_right():
	draw_rect(
		Rect2(
			Vector2(1120, 256),
			Vector2(96, 192)
		), 
		Color(
			0.2,
			0.4,
			1,
			1
		),
		true
	)
