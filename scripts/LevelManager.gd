extends Node

## --- PARÂMETROS CONFIGURÁVEIS  ---
@export var level_number: int = 1
@export var min_rooms: int = 8
@export var max_rooms: int = 12

# Definindo o tamanho de cada célula da "matriz". Deve ser grande o suficiente
# para que nenhuma sala se encoste na outra. Ex: tamanho da maior sala + margem.
const ROOM_SIZE = Vector2(800, 600)

# Templates de salas
@export var rooms_path: String = "res://scenes/salas/"
var start_room_template: PackedScene
var normal_room_templates: Array[PackedScene] = []
var boss_room_template: PackedScene
var shop_room_template: PackedScene
var item_room_template: PackedScene
var all_boss_room_templates: Array[PackedScene] = []
var all_shop_room_templates: Array[PackedScene] = []
var all_item_room_templates: Array[PackedScene] = []

func _ready():
	_load_room_templates_from_path()

# Referência ao nó que conterá as salas
var dungeon_container: Node2D
var player: CharacterBody2D

## --- DADOS DA GERAÇÃO ---
var grid = {} # Dicionário para armazenar a matriz de salas. Chave: Vector2i, Valor: dados da sala
var spawned_room_nodes = {} # Dicionário para armazenar os nós instanciados. Chave: Vector2i, Valor: Node2D

func generate_level(container: Node2D, player_ref: CharacterBody2D):
	self.dungeon_container = container
	self.player = player_ref
	
	# Limpa o level anterior
	for child in dungeon_container.get_children():
		child.queue_free()
	grid.clear()
	spawned_room_nodes.clear()

	# 3. Usa o timestamp como seed
	seed(Time.get_unix_time_from_system())
	var target_room_count = randi_range(min_rooms, max_rooms)

	# 4/5. ALGORITMO DE GERAÇÃO (Random Walk em Grid)
	_randomize_special_room_templates()
	_generate_grid_layout(target_room_count)
	
	# 6/7/8. Designa as salas especiais
	_assign_special_rooms()

	# Instancia as cenas com base no layout gerado
	_instantiate_rooms_from_grid()
	
	# 9. Posiciona o personagem
	player.global_position = spawned_room_nodes[Vector2i.ZERO].global_position

	# 10. Gera o mapa (a ser implementado na UI)
	print("Level gerado com %d salas." % grid.size())
	update_minimap()

func _generate_grid_layout(target_count: int):
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var frontier = [Vector2i.ZERO] # Fila de posições a partir das quais podemos expandir

	# 1. Instanciar (logicamente) a sala inicial
	grid[Vector2i.ZERO] = { "type": "start", "connections": [] }

	while not frontier.is_empty() and grid.size() < target_count:
		# Pega uma posição aleatória da fronteira para expandir
		var current_pos = frontier.pick_random()
		
		directions.shuffle()
		var moved = false
		for dir in directions:
			var next_pos = current_pos + dir
			if not grid.has(next_pos): # Se a célula do grid estiver vazia
				# Conecta as salas
				grid[next_pos] = { "type": "normal", "connections": [-dir] }
				grid[current_pos]["connections"].append(dir)
				
				frontier.append(next_pos) # Adiciona a nova sala à fronteira
				moved = true
				break # Vai para a próxima iteração do while

		if not moved:
			# Se não conseguiu expandir a partir desta sala, remove ela da fronteira
			# para evitar loops infinitos.
			frontier.erase(current_pos)

func _assign_special_rooms():
	# Encontra todos os "becos sem saída" (dead ends)
	var dead_ends = []
	for pos in grid:
		if grid[pos]["connections"].size() == 1 and grid[pos].type != "start":
			dead_ends.append(pos)
	
	if dead_ends.size() < 3:
		print("ERRO: Geração resultou em menos de 3 becos sem saída. Tente novamente.")
		# TO-DO
		# Idealmente, reiniciar a geração.
		return
	dead_ends.shuffle()
	# 7. A sala do BOSS deve ser a mais distante
	var farthest_pos = null
	var max_dist = -1
	for pos in dead_ends:
		var dist = pos.length() # Distância de Manhattan a partir de (0,0)
		if dist > max_dist:
			max_dist = dist
			farthest_pos = pos
	
	grid[farthest_pos].type = "boss"
	dead_ends.erase(farthest_pos) # Remove para não ser escolhida de novo
	# 6. Atribui as outras salas especiais
	grid[dead_ends.pop_front()].type = "shop"
	grid[dead_ends.pop_front()].type = "item"
	
	# 8. O shop pode estar perto a lógica acima permite isso, pois `dead_ends` foi embaralhada.

func _instantiate_rooms_from_grid():
	for pos in grid:
		var room_data = grid[pos]
		var template = _get_template_for_type(room_data.type)
		
		if not template:
			print("ERRO: Nenhum template encontrado para o tipo: ", room_data.type)
			continue
			
		var room_node = template.instantiate()
		var calculated_position = Vector2(pos) * ROOM_SIZE
		room_node.global_position = calculated_position
		# PRINT DE DEPURAÇÃO MAIS IMPORTANTE
		print("Instanciando sala tipo '%s' na coordenada do grid %s. Posição final calculada: %s" % [room_data.type, str(pos), str(calculated_position)])
		
		dungeon_container.add_child(room_node)
		spawned_room_nodes[pos] = room_node
		
		# Passa as informações para o script da sala
		var room_info = room_node.get_node("RoomInfo") as RoomInfo
		room_info.room_level = self.level_number


		var type_string = room_data.type.to_upper()
		# Trata o caso especial da sala "start"
		if type_string == "START":
			type_string = "NORMAL" # A sala inicial é do tipo normal para a enum
		# Trata o caso especial da sala "item"
		elif type_string == "ITEM":
			type_string = "ITEM"

		if RoomInfo.RoomType.has(type_string):
			room_info.room_type = RoomInfo.RoomType[type_string]
		else:
			print("AVISO: Tipo de sala desconhecido no grid: ", room_data.type)
			room_info.room_type = RoomInfo.RoomType.NORMAL
		
		# Ativa/desativa as portas visuais (opcional, mas bom para debug)
		_configure_room_doors(room_node, room_data.connections)


func _get_template_for_type(type: String) -> PackedScene:
	match type:
		"start":
			return start_room_template
		"boss":
			return boss_room_template
		"shop":
			return shop_room_template
		"item": # Esta string vem do seu Dicionário 'grid'
			return item_room_template
		_: # "normal"
			if normal_room_templates.is_empty():
				print("ERRO: Nenhum template de sala normal foi carregado!")
				return null
			return normal_room_templates.pick_random()


func _configure_room_doors(room_node: Node2D, connections: Array):
	var doors_node = room_node.get_node("ConnectionPoints")
	for door_marker in doors_node.get_children():
		var is_active = false
		if door_marker.name == "Porta_Cima" and connections.has(Vector2i.UP):
			is_active = true
		elif door_marker.name == "Porta_Baixo" and connections.has(Vector2i.DOWN):
			is_active = true
		elif door_marker.name == "Porta_Direita" and connections.has(Vector2i.RIGHT):
			is_active = true
		elif door_marker.name == "Porta_Esquerda" and connections.has(Vector2i.LEFT):
			is_active = true
		
		door_marker.visible = is_active # Esconde ou mostra o ícone do Marker2D

# 10. Lógica do Minimapa (exemplo)
func update_minimap():
	# Esta função seria chamada sempre que o jogador muda de sala
	print("Atualizando minimapa...")
	# for pos in spawned_room_nodes:
	#    var room_node = spawned_room_nodes[pos]
	#    var room_info = room_node.get_node("RoomInfo")
	#    var is_adjacent = ... (cálculo de adjacência)
	#    minimap_ui.update_room_icon(pos, room_info.is_visited, is_adjacent)

func _load_room_templates_from_path():
	all_boss_room_templates.clear()
	all_shop_room_templates.clear()
	all_item_room_templates.clear()
	normal_room_templates.clear()
	var dir = DirAccess.open(rooms_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Verifica se o arquivo é uma cena e não um diretório
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				# Monta o caminho completo do arquivo
				var full_path = rooms_path.path_join(file_name)
				var parts = file_name.split("_")
				# parts ex: "sala_normal_01.tscn" -> ["sala", "normal", "01.tscn"]
				if parts.size() < 2:
					print("AVISO: Arquivo de sala com nome inválido, pulando: ", file_name)
					file_name = dir.get_next()
					continue
				var room_type = parts[1]
				var loaded_scene = load(full_path) as PackedScene
				# Adiciona a cena carregada à variável correta
				match room_type:
					"start":
						start_room_template = loaded_scene
					"normal":
						normal_room_templates.append(loaded_scene)
					"boss":
						all_boss_room_templates.append(loaded_scene)
					"shop":
						all_shop_room_templates.append(loaded_scene)
					"item":
						all_item_room_templates.append(loaded_scene)
			file_name = dir.get_next()
		if not all_boss_room_templates.is_empty():
			boss_room_template = all_boss_room_templates.pick_random()
			print("Template de Boss sorteado: ", boss_room_template.resource_path)
		
		if not all_shop_room_templates.is_empty():
			shop_room_template = all_shop_room_templates.pick_random()
			print("Template de Shop sorteado: ", shop_room_template.resource_path)
		
		if not all_item_room_templates.is_empty():
			item_room_template = all_item_room_templates.pick_random()
			print("Template de Item sorteado: ", item_room_template.resource_path)
		print("Carregados %d templates de salas normais." % normal_room_templates.size())
	else:
		print("ERRO: Não foi possível encontrar o diretório de salas: ", rooms_path)

func _randomize_special_room_templates():
	# Sorteia um template de cada lista mestra e o define para o andar atual
	if not all_boss_room_templates.is_empty():
		boss_room_template = all_boss_room_templates.pick_random()
	
	if not all_shop_room_templates.is_empty():
		shop_room_template = all_shop_room_templates.pick_random()
	
	if not all_item_room_templates.is_empty():
		item_room_template = all_item_room_templates.pick_random()
