extends Node

# Definindo o tamanho de cada célula da "matriz". Deve ser grande o suficiente
# para que nenhuma sala se encoste na outra. Ex: tamanho da maior sala + margem.
const ROOM_SIZE = Vector2(3500, 2500)
 # Distância em pixels que o jogador surgirá da porta ao entrar em uma sala
const PLAYER_SPAWN_OFFSET = -200.0

## --- PARÂMETROS CONFIGURÁVEIS  ---
@export var level_number: int = 1
@export var min_rooms: int = 8
@export var max_rooms: int = 12

# Templates de salas
@export var rooms_path: String = "res://scenes/salas/"
# --- DICIONÁRIOS para ARMAZENAR TODOS os templates por nível ---
var start_room_templates: Dictionary = {}    # Nível -> Template
var normal_room_templates: Dictionary = {}   # Nível -> Array de Templates
var boss_room_templates: Dictionary = {}     # Nível -> Array de Templates
var item_room_templates: Dictionary = {}     # Nível -> Array de Templates
# --- VARIÁVEIS para guardar o template ESCOLHIDO para o andar ATUAL ---
var start_room_template: PackedScene
var boss_room_template: PackedScene
var item_room_template: PackedScene
var shop_room_template: PackedScene

# Templates de portas
@export var doors_path: String = "res://scenes/portas/"
# Estrutura: { "tipo": { nível: [templates] } }
# Ex: { "normal": { 1: [porta_n_1], 2: [porta_n_2] }, "boss": { 0: [porta_b] } }
var door_templates: Dictionary = {}

func _ready():
	_load_room_templates_from_path()
	_load_door_templates_from_path()

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
		_configure_room_doors(room_node, pos, room_data.connections)
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
		#_configure_room_doors(room_node, room_data.connections)


func _get_template_for_type(type: String) -> PackedScene:
	match type:
		"start":
			return start_room_template
		"boss":
			return boss_room_template
		"shop":
			return shop_room_template # Loja continua simples
		"item":
			return item_room_template
		_: # "normal"
			var template = _find_best_template(normal_room_templates)
			if not template:
				print("ERRO: Nenhum template de sala normal encontrado para o nível ", level_number, " ou inferior.")
			return template


func _configure_room_doors(room_node: Node2D, room_pos: Vector2i, connections: Array):
	# ... (a primeira parte da função continua igual) ...
	var placeholders_node = room_node.get_node("ConnectionPoints")
	var direction_map = {
		Vector2i.UP: "DoorPlaceholder_Up", Vector2i.DOWN: "DoorPlaceholder_Down",
		Vector2i.LEFT: "DoorPlaceholder_Left", Vector2i.RIGHT: "DoorPlaceholder_Right"
	}

	for direction in connections:
		var placeholder_name = direction_map.get(direction)
		var placeholder = placeholders_node.get_node_or_null(placeholder_name)
		if not placeholder:
			continue
			
		var current_room_type = grid[room_pos].type
		var neighbor_type = grid[room_pos + direction].type
		
		if current_room_type == "start": current_room_type = "normal"
		if neighbor_type == "start": neighbor_type = "normal"

		var door_type_to_load = "normal"
		if current_room_type != "normal":
			door_type_to_load = current_room_type
		elif neighbor_type != "normal":
			door_type_to_load = neighbor_type
		
		# --- LÓGICA DE SELEÇÃO DE PORTA ATUALIZADA ---
		var door_template: PackedScene = null
		if door_templates.has(door_type_to_load):
			var templates_by_level = door_templates[door_type_to_load]
			# Prioridade 1: Tenta pegar uma porta do nível atual
			if templates_by_level.has(level_number) and not templates_by_level[level_number].is_empty():
				door_template = templates_by_level[level_number].pick_random()
			# Prioridade 2: Tenta pegar uma porta "qualquer nível" (chave 0)
			elif templates_by_level.has(0) and not templates_by_level[0].is_empty():
				door_template = templates_by_level[0].pick_random()

		# Se ainda assim não encontrou, usa um fallback para porta normal
		if not door_template:
			print("AVISO: Nenhum template de porta encontrado para '", door_type_to_load, "'. Usando 'normal'.")
			door_type_to_load = "normal"
			if door_templates["normal"].has(level_number):
				door_template = door_templates["normal"][level_number].pick_random()
			elif door_templates["normal"].has(0):
				door_template = door_templates["normal"][0].pick_random()
		
		if not door_template:
			print("ERRO CRÍTICO: Não foi possível encontrar NENHUM template de porta.")
			continue # Pula a criação desta porta

		# ... (o resto da função, instanciando e conectando, continua igual) ...
		var door_instance = door_template.instantiate()
		door_instance.transform = placeholder.transform
		door_instance.direction = direction
		door_instance.player_entered.connect(Callable(self, "_on_player_changed_room").bind(room_pos))
		placeholders_node.add_child(door_instance)
		placeholder.queue_free()

func _on_player_changed_room(direction_of_exit: Vector2i, current_pos: Vector2i):
	# 1. Calcula a posição da próxima sala
	var next_room_pos = current_pos + direction_of_exit
	
	if not spawned_room_nodes.has(next_room_pos):
		print("ERRO: Tentou se mover para uma sala que não existe em ", next_room_pos)
		return
		
	var current_room_node = spawned_room_nodes[current_pos]
	var next_room_node = spawned_room_nodes[next_room_pos]
	
	# 2. Encontra a porta de entrada na nova sala
	var entry_direction = -direction_of_exit
	var entry_door = _get_door_in_direction(next_room_node, entry_direction)
	
	if not entry_door:
		print("ERRO: Não foi possível encontrar a porta de entrada na sala ", next_room_pos)
		player.global_position = next_room_node.global_position # Teleporta para o centro como fallback
		return

	# 3. Calcula a posição final do jogador (A GRANDE MUDANÇA)
	# Pega a posição global da porta de entrada...
	# ...e adiciona um vetor na direção de entrada, multiplicado pela nossa distância.
	var spawn_position = entry_door.global_position + (Vector2(entry_direction) * PLAYER_SPAWN_OFFSET)
	
	# 4. Teleporta o jogador para a posição calculada
	player.global_position = spawn_position

	# 5. [BÔNUS] Adiciona uma transição suave de câmera
	# Esta parte assume que você tem um nó Camera2D na sua cena principal.
	# Se a câmera for filha do player, você pode pular esta parte.
	var camera = get_tree().get_root().get_node_or_null("Mundo/Camera2D") # Ajuste o caminho para sua câmera
	if camera:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUINT) # Efeito de aceleração/desaceleração suave
		tween.set_ease(Tween.EASE_OUT)
		# Anima a câmera da posição da sala antiga para a nova em 0.4 segundos
		tween.tween_property(camera, "global_position", next_room_node.global_position, 0.4)

	# 6. Lógica de abrir/fechar portas da nova sala (a ser implementada)
	# Ex: _update_doors_for_room(next_room_node)


# Função auxiliar para encontrar uma porta específica em uma sala
func _get_door_in_direction(room_node: Node2D, direction: Vector2i) -> Node2D:
	var doors_container = room_node.get_node_or_null("ConnectionPoints")
	if not doors_container: return null
	
	for door in doors_container.get_children():
		# Garante que o nó é uma porta e tem a propriedade 'direction'
		if "direction" in door and door.direction == direction:
			return door
	return null

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
	start_room_templates.clear()
	normal_room_templates.clear()
	boss_room_templates.clear()
	item_room_templates.clear()
	
	var dir = DirAccess.open(rooms_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				var full_path = rooms_path.path_join(file_name)
				var base_name = file_name.get_basename()
				var parts = base_name.split("_")
				
				if parts.size() < 3:
					file_name = dir.get_next()
					continue
				
				var room_type = parts[1]
				
				if room_type == "shop":
					shop_room_template = load(full_path) as PackedScene
					file_name = dir.get_next()
					continue

				if parts.size() < 4 or not parts[parts.size() - 1].is_valid_int():
					print("AVISO: Sala '", base_name, "' pulada. Falta sufixo de nível. (Exceto para a loja)")
					file_name = dir.get_next()
					continue

				var level_suffix = parts[parts.size() - 1].to_int()
				var loaded_scene = load(full_path) as PackedScene

				# --- LÓGICA DE ARMAZENAMENTO PADRONIZADA ---
				match room_type:
					"start":
						# AGORA a sala inicial também é guardada em um Array
						if not start_room_templates.has(level_suffix):
							start_room_templates[level_suffix] = []
						start_room_templates[level_suffix].append(loaded_scene)
					"normal":
						if not normal_room_templates.has(level_suffix):
							normal_room_templates[level_suffix] = []
						normal_room_templates[level_suffix].append(loaded_scene)
					"boss":
						if not boss_room_templates.has(level_suffix):
							boss_room_templates[level_suffix] = []
						boss_room_templates[level_suffix].append(loaded_scene)
					"item":
						if not item_room_templates.has(level_suffix):
							item_room_templates[level_suffix] = []
						item_room_templates[level_suffix].append(loaded_scene)
			
			file_name = dir.get_next()
		
		print("Templates de salas carregados.")
	else:
		print("ERRO: Não foi possível encontrar o diretório de salas: ", rooms_path)

func _load_door_templates_from_path():
	door_templates.clear()
	var dir = DirAccess.open(doors_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tscn"):
				var base_name = file_name.get_basename()
				var parts = base_name.split("_")
				
				if parts.size() < 3:
					file_name = dir.get_next()
					continue
				
				var door_type = parts[1]
				var full_path = doors_path.path_join(file_name)
				var loaded_scene = load(full_path) as PackedScene
				
				# --- LÓGICA CORRIGIDA ---
				var level_suffix = 0 # 0 = serve para qualquer nível (padrão para portas especiais)
				# Apenas portas normais têm sufixo de nível
				if door_type == "normal" and parts.size() >= 4 and parts[parts.size() - 1].is_valid_int():
					level_suffix = parts[parts.size() - 1].to_int()

				if not door_templates.has(door_type):
					door_templates[door_type] = {}
				if not door_templates[door_type].has(level_suffix):
					door_templates[door_type][level_suffix] = []
				
				door_templates[door_type][level_suffix].append(loaded_scene)
				
			file_name = dir.get_next()
		print("Templates de portas carregados: ", door_templates.keys())
	else:
		print("ERRO: Não foi possível encontrar o diretório de portas: ", doors_path)


func _randomize_special_room_templates():
	# Sorteia um template de cada lista mestra usando a nova função auxiliar
	# e salva na variável SINGULAR correta.
	start_room_template = _find_best_template(start_room_templates)
	boss_room_template = _find_best_template(boss_room_templates)
	item_room_template = _find_best_template(item_room_templates)
	# A sala da loja não muda e já foi carregada no _load
	
func _find_best_template(template_dict: Dictionary) -> PackedScene:
	"""
	Encontra o melhor template em um dicionário de templates baseado no level_number.
	Procura pelo nível atual, depois por níveis inferiores até o nível 0.
	"""
	var level = level_number
	# Loop para procurar do nível atual para baixo até 0
	while level >= 0:
		if template_dict.has(level):
			return template_dict[level].pick_random()
		level -= 1
	
	# Se não encontrou absolutamente nada, retorna nulo
	return null
