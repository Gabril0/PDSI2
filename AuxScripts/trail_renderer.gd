extends Node2D

@export var target: Node2D
@export var max_points: int = 20
@export var min_distance: float = 5.0
@export var trail_fade_time: float = 0.5
@export var start_width: float = 8.0
@export var end_width: float = 0.0
@export var start_color: Color = Color.WHITE
@export var end_color: Color = Color(1, 1, 1, 0)

var _points: Array[Vector2] = []
var _times: Array[float] = []
var _mesh_instance: MeshInstance2D
var _mesh: ArrayMesh

func _ready() -> void:
	_mesh_instance = MeshInstance2D.new()
	add_child(_mesh_instance)
	_mesh = ArrayMesh.new()
	_mesh_instance.mesh = _mesh

func _process(delta: float) -> void:
	if target == null:
		return

	var pos: Vector2 = target.global_position
	if _points.size() == 0 or _points[-1].distance_to(pos) >= min_distance:
		_points.append(pos)
		_times.append(0.0)

	for i in range(_times.size()):
		_times[i] += delta

	while _points.size() > max_points or (_times.size() > 0 and _times[0] >= trail_fade_time):
		_points.pop_front()
		_times.pop_front()

	_update_mesh()

func _update_mesh() -> void:
	if _points.size() < 2:
		_mesh = ArrayMesh.new()
		_mesh_instance.mesh = _mesh
		return

	var vertices = PackedVector2Array()
	var colors = PackedColorArray()
	var indices = PackedInt32Array()

	var total = _points.size()

	for i in range(total):
		var t = float(i) / max(1, total - 1)
		var width = lerp(start_width, end_width, t) * 0.5
		var alpha = 1.0 - (_times[i] / trail_fade_time)
		var color = start_color.lerp(end_color, t)
		color.a *= clamp(alpha, 0.0, 1.0)
		
		var point = _points[i]
		var dir: Vector2
		if i == 0:
			dir = (_points[i + 1] - point).normalized()
		elif i == total - 1:
			dir = (point - _points[i - 1]).normalized()
		else:
			dir = (_points[i + 1] - _points[i - 1]).normalized()

		var normal = Vector2(-dir.y, dir.x) * width

		vertices.append(to_local(point + normal))
		colors.append(color)

		vertices.append(to_local(point - normal))
		colors.append(color)

	for i in range(total - 1):
		var idx = i * 2
		indices.append(idx)
		indices.append(idx + 1)
		indices.append(idx + 2)

		indices.append(idx + 1)
		indices.append(idx + 3)
		indices.append(idx + 2)

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices

	_mesh = ArrayMesh.new()
	_mesh_instance.mesh = _mesh
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
