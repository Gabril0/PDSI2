extends Node2D

@export var trail : Line2D
@export var tracking_object : Node2D
@export var trail_length : int = 20
@export var point_spacing : float = 5.0

var last_point := Vector2.ZERO

func _ready():
	if tracking_object == null:
		push_warning("Tracking object not set!")
		return

	last_point = tracking_object.global_position
	trail.clear_points()
	trail.add_point(tracking_object.global_position)

func _process(delta):
	if tracking_object == null:
		return

	var current_pos = tracking_object.global_position
	var distance = current_pos.distance_to(last_point)

	if distance >= point_spacing:
		trail.add_point(current_pos)
		last_point = current_pos

	while trail.get_point_count() > trail_length:
		trail.remove_point(0)
