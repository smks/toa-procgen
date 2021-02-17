extends Node2D

signal move_to_new_room(pos_to_move_to)

var Room = preload("res://src/Room.tscn")

var player = preload("res://src/Player.tscn").instance()
var room_neighbours = preload('res://src/RoomNeighbours.gd').new()

const ROOM_SIZE = Vector2(1280, 720)

enum {
	UP,
	DOWN,
	RIGHT,
	LEFT
}

var x = 0
var y = 0
var current_direction = Vector2.UP
var options = [UP, DOWN, RIGHT, LEFT]
var steps_history: Array = []
var rng = RandomNumberGenerator.new()
var can_move_room_with_action = true
var current_room = Vector2(0, 0)
var current_room_instance = null
var next_room_to_move_to = Vector2(0, 0)
var next_room_instance = null

func move_camera_to_next_room():
	can_move_room_with_action = false
	
	if not steps_history.has(next_room_to_move_to):
		can_move_room_with_action = true
		next_room_to_move_to = current_room
		return false
	else:
		current_room = next_room_to_move_to
		
	var pos_to_move_to = Vector2(
		next_room_to_move_to.x * ROOM_SIZE.x,
		next_room_to_move_to.y * ROOM_SIZE.y
	)
	
	emit_signal('move_to_new_room', pos_to_move_to)
	return true
	
func make(rooms_total_to_create: int):
	for i in range(rooms_total_to_create):
		var step
		var is_first_room = i == 0
		var is_last_room = i == rooms_total_to_create - 1

		if i == 0:
			step = Vector2.ZERO
		else:
			step = generate_step()

		while steps_history.has(step):
			step = generate_step()

		steps_history.push_front(step)
		
		var room = Room.instance()
		var room_name = 'Room-' + str(step.x) + '-' + str(step.y)
		room.set_name(room_name)
		
		if is_first_room:
			room.set_as_first_room()
			current_room_instance = room
		elif is_last_room:
			room.set_as_last_room()

		room.connect('change_room', self, '_on_change_room');
		room.step = step
		room.position = step_to_position(step)
		add_room(room)
	decorate(rooms_total_to_create)
	add_player()
		
func decorate(rooms_total_to_create: int):
	for i in range(rooms_total_to_create):
		var room = get_child(i)
		var step = room.step
		
		room_neighbours.init(step, steps_history)
		room.set_doors(
			room_neighbours.has_top_neighbour(),
			room_neighbours.has_bottom_neighbour(),
			room_neighbours.has_left_neighbour(),
			room_neighbours.has_right_neighbour()
		)
		
func add_player():
	var first_room = get_child(0)
	player.position = Vector2(
		ROOM_SIZE.x / 2,
		ROOM_SIZE.y / 2
	)
	first_room.add_player(player)
		
func generate_step() -> Vector2:
	rng.randomize()
	var rand_index:int = (rng.randi() % options.size())
	var chose = options[rand_index]

	if (chose == UP):
		current_direction = Vector2.UP
		y = y + 1

	if (chose == DOWN):
		current_direction = Vector2.DOWN
		y = y - 1

	if (chose == RIGHT):
		current_direction = Vector2.RIGHT
		x = x + 1

	if (chose == LEFT):
		current_direction = Vector2.LEFT
		x = x - 1
	
	return Vector2(x, y)
	
func step_to_position(step: Vector2) -> Vector2:
	return Vector2(
		step.x * ROOM_SIZE.x,
		step.y * ROOM_SIZE.y
	)
	
func finished_moving_room():
	can_move_room_with_action = true
	
func add_room(room):
	add_child(room)
	
func _on_change_room(next_step):
	var room_check = current_room + next_step
	if current_room == room_check:
		return
	next_room_to_move_to = room_check
	var next_room = 'Room-' + str(next_room_to_move_to.x) + '-' + str(next_room_to_move_to.y)
	next_room_instance = get_node(next_room)
	if move_camera_to_next_room():
		var player = current_room_instance.get_player_and_remove()
		player.position = set_player_position_in_room(next_step)
		next_room_instance.add_player(player)
		current_room_instance = next_room_instance
		
func set_player_position_in_room(next_step):
	var player_position: Vector2
	if next_step == Vector2.UP:
		player_position = Vector2(640, 660)
	elif next_step == Vector2.DOWN:
		player_position = Vector2(640, 90)
	elif next_step == Vector2.LEFT:
		player_position = Vector2(1126, 360)
	elif next_step == Vector2.RIGHT:
		player_position = Vector2(160, 360)
	return player_position
