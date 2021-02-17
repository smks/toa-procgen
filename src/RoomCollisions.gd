extends Node2D

func toggle(on: bool, matcher: String = ''):
	for static_body in get_children():
		var name: String = static_body.get_name()
		if name.begins_with(matcher):
			var collision = static_body.get_child(0)
			collision.disabled = !on

func disable():
	for static_body in get_children():
		static_body.get_children()[0].disabled = true

func enable():
	for static_body in get_children():
		static_body.get_children()[0].disabled = false
