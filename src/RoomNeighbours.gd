extends Resource

var top_neighbour
var down_neighbour
var right_neighbour
var left_neighbour
var steps
var room_step

func init(_room_step: Vector2, _steps = []):
	steps = _steps
	room_step = _room_step
	top_neighbour = room_step + Vector2(0, -1)
	down_neighbour = room_step + Vector2(0, 1)
	right_neighbour = room_step + Vector2(1, 0)
	left_neighbour = room_step + Vector2(-1, 0)
	
func has_top_neighbour() -> bool:
	return steps.has(top_neighbour)
	
func has_bottom_neighbour() -> bool:
	return steps.has(down_neighbour)
	
func has_left_neighbour() -> bool:
	return steps.has(left_neighbour)
	
func has_right_neighbour() -> bool:
	return steps.has(right_neighbour)
