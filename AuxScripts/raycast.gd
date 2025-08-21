class_name Raycast
extends Node2D

@export var visualize: bool = true

var _debug_draw: Array[Callable] = []

func _ready():
	set_process(true)

func circle_cast(position: Vector2, radius: float, max_results: int = 32) -> Array[Dictionary]:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	query.shape = shape
	query.transform = Transform2D(0, position)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = space_state.intersect_shape(query, max_results)

	if visualize:
		_debug_draw.append(func(): draw_circle(to_local(position), radius, Color(0,1,0,0.3)))

	return results

func square_cast(position: Vector2, extents: Vector2, rotation: float = 0.0, max_results: int = 32) -> Array[Dictionary]:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := RectangleShape2D.new()
	shape.extents = extents
	query.shape = shape
	query.transform = Transform2D(rotation, position)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = space_state.intersect_shape(query, max_results)

	if visualize:
		_debug_draw.append(func():
			var local_pos = to_local(position)
			draw_rect(Rect2(local_pos - extents, extents * 2), Color(0,0,1,0.3), false, 2.0)
		)

	return results

func ray_cast(from: Vector2, to: Vector2, collide_with_areas := true, collide_with_bodies := true) -> Dictionary:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.collide_with_areas = collide_with_areas
	query.collide_with_bodies = collide_with_bodies

	var result: Dictionary = space_state.intersect_ray(query)

	if visualize:
		_debug_draw.append(func(): draw_line(to_local(from), to_local(to), Color(1,0,0,0.6), 2.0))

	return result

func _draw():
	for f in _debug_draw:
		f.call()
	_debug_draw.clear()

func _process(delta: float) -> void:
	if visualize:
		queue_redraw()
