# Minimap.gd (VERSÃO FINAL E COMPLETA)
extends PanelContainer

const MinimapIconScene = preload("res://scenes/ui/MinimapIcon.tscn")

@onready var grid_container: GridContainer = $GridContainer
var spawned_icons: Dictionary = {}
var current_player_pos: Vector2i

func _ready():
	LevelManager.level_generated.connect(generate_map)
	get_tree().get_first_node_in_group("player").room_changed.connect(update_player_position)

func generate_map(grid_data: Dictionary):
	_clear_map()
	if grid_data.is_empty(): return

	var min_pos = grid_data.keys()[0]
	var max_pos = grid_data.keys()[0]
	for pos in grid_data.keys():
		min_pos = min_pos.min(pos)
		max_pos = max_pos.max(pos)
	
	grid_container.columns = (max_pos.x - min_pos.x) + 1

	for y in range(min_pos.y, max_pos.y + 1):
		for x in range(min_pos.x, max_pos.x + 1):
			var current_pos = Vector2i(x, y)
			
			if grid_data.has(current_pos):
				var icon_instance = MinimapIconScene.instantiate()
				grid_container.add_child(icon_instance)
				icon_instance.set_state(MinimapIcon.State.HIDDEN)
				spawned_icons[current_pos] = icon_instance
			else:
				var placeholder = Control.new()
				placeholder.custom_minimum_size = Vector2(16, 16)
				grid_container.add_child(placeholder)
	
	# Revela a sala inicial
	update_player_position(Vector2i.ZERO)

func update_player_position(new_pos: Vector2i):
	# Se já estávamos em uma sala, marca ela como 'visitada'
	if spawned_icons.has(current_player_pos):
		spawned_icons[current_player_pos].set_state(MinimapIcon.State.VISITED)
	
	current_player_pos = new_pos
	
	# Marca a nova sala como 'atual' e revela as vizinhas
	if spawned_icons.has(current_player_pos):
		spawned_icons[current_player_pos].set_state(MinimapIcon.State.CURRENT)
		_reveal_neighbors(current_player_pos)

func _reveal_neighbors(pos: Vector2i):
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for dir in directions:
		var neighbor_pos = pos + dir
		if spawned_icons.has(neighbor_pos):
			# Apenas revela, não marca como visitada ainda
			var icon = spawned_icons[neighbor_pos]

			var room_type = LevelManager.grid[neighbor_pos].type 
			if room_type == "shop" or room_type == "boss" or room_type == "item":
				icon.set_state(MinimapIcon.State.SPECIAL, room_type)
			else:
				icon.set_state(MinimapIcon.State.VISITED)

func _clear_map():
	for child in grid_container.get_children():
		child.queue_free()
	spawned_icons.clear()
