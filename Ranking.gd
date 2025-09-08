extends Control

@onready var title_label = $VBoxContainer/TitleLabel
@onready var ranking_list = $VBoxContainer/RankingList
@onready var btn_voltar = $VBoxContainer/BtnVoltar

func _ready():
	# Configura o layout da tela de ranking
	_setup_ranking_layout()
	
	# Conecta o botão de voltar (sintaxe correta para Godot 4)
	btn_voltar.pressed.connect(_on_btn_voltar_pressed)
	
	# Configura o título principal
	title_label.text = "=== RANKING SEMANAL ==="
	
	# Limpa a lista antes de carregar
	_clear_ranking_list()
	
	# Conecta ao sistema de API centralizado
	if not API.is_connected("ranking_received", _on_ranking_received):
		API.connect("ranking_received", _on_ranking_received)
	
	# Busca o ranking usando a API centralizada
	API.buscar_ranking_atual()

func _setup_ranking_layout():
	# Configura o container principal para ocupar toda a tela
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Configura o VBoxContainer principal
	if $VBoxContainer:
		$VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		$VBoxContainer.add_theme_constant_override("separation", 20)
		# Adiciona padding nas bordas
		$VBoxContainer.add_theme_constant_override("margin_left", 40)
		$VBoxContainer.add_theme_constant_override("margin_right", 40)
		$VBoxContainer.add_theme_constant_override("margin_top", 30)
		$VBoxContainer.add_theme_constant_override("margin_bottom", 30)
	
	# Configura o ranking_list como ScrollContainer se necessário
	if ranking_list:
		# Força como VBoxContainer se não for
		if not ranking_list is VBoxContainer:
			print("AVISO: ranking_list não é VBoxContainer")
		
		# Configura espaçamento entre itens
		ranking_list.add_theme_constant_override("separation", 5)
		
		# Se for um ScrollContainer, configura scroll
		if ranking_list.get_parent() is ScrollContainer:
			var scroll_container = ranking_list.get_parent()
			scroll_container.scroll_horizontal_enabled = false
			scroll_container.scroll_vertical_enabled = true
	
	# Configura estilos do título principal
	if title_label:
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.add_theme_font_size_override("font_size", 28)
		title_label.add_theme_color_override("font_color", Color.GOLD)
		title_label.custom_minimum_size.y = 50
	
	# Configura o botão voltar
	if btn_voltar:
		btn_voltar.text = "⬅️ VOLTAR"
		btn_voltar.custom_minimum_size = Vector2(150, 45)
		btn_voltar.add_theme_font_size_override("font_size", 16)

func _clear_ranking_list():
	for child in ranking_list.get_children():
		child.queue_free()

func _on_ranking_received(ranking_data):
	_clear_ranking_list()
	
	if ranking_data == null or not ranking_data.has("ranking"):
		_show_error_message()
		return
	
	# Cria as seções do ranking organizadamente
	_create_week_info_section(ranking_data)
	_create_separator()
	_create_table_with_entries(ranking_data["ranking"])

func _show_error_message():
	"""Exibe mensagem de erro quando não consegue carregar o ranking"""
	var error_container = VBoxContainer.new()
	error_container.add_theme_constant_override("separation", 10)
	
	var error_icon = Label.new()
	error_icon.text = "❌"
	error_icon.add_theme_font_size_override("font_size", 32)
	error_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var error_label = Label.new()
	error_label.text = "Erro ao carregar ranking"
	error_label.add_theme_color_override("font_color", Color.ORANGE_RED)
	error_label.add_theme_font_size_override("font_size", 18)
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var error_desc = Label.new()
	error_desc.text = "Verifique sua conexão e tente novamente"
	error_desc.add_theme_color_override("font_color", Color.GRAY)
	error_desc.add_theme_font_size_override("font_size", 14)
	error_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	error_container.add_child(error_icon)
	error_container.add_child(error_label)
	error_container.add_child(error_desc)
	
	ranking_list.add_child(error_container)

func _create_week_info_section(ranking_data):
	"""Cria a seção com informações da semana"""
	var info_container = VBoxContainer.new()
	info_container.add_theme_constant_override("separation", 8)
	
	# Informação da semana
	var week_label = Label.new()
	week_label.text = "Semana: " + str(ranking_data.get("week", "N/A"))
	week_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)
	week_label.add_theme_font_size_override("font_size", 16)
	week_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Informação da seed
	var seed_label = Label.new()
	seed_label.text = "Seed: " + str(int(str(ranking_data.get("seed", "N/A"))))
	seed_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)
	seed_label.add_theme_font_size_override("font_size", 16)
	seed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	info_container.add_child(week_label)
	info_container.add_child(seed_label)
	
	ranking_list.add_child(info_container)

func _create_separator():
	"""Cria um separador visual"""
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 25
	ranking_list.add_child(spacer)

func _create_table_with_entries(ranking_entries):
	"""Cria a tabela completa com cabeçalho e dados"""
	var main_table_container = VBoxContainer.new()
	main_table_container.add_theme_constant_override("separation", 0)
	
	# CABEÇALHO DA TABELA
	var table_header_section = VBoxContainer.new()
	table_header_section.add_theme_constant_override("separation", 8)
	
	# Título "Posições:"
	var positions_title = Label.new()
	positions_title.text = "Posições:"
	positions_title.add_theme_color_override("font_color", Color.WHITE)
	positions_title.add_theme_font_size_override("font_size", 18)
	positions_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	positions_title.custom_minimum_size.y = 30
	
	# Cabeçalho das colunas
	var table_header = HBoxContainer.new()
	table_header.add_theme_constant_override("separation", 15)
	table_header.custom_minimum_size.y = 35
	
	# Fundo do cabeçalho
	var header_bg = ColorRect.new()
	header_bg.color = Color(0.2, 0.2, 0.3, 0.8)
	header_bg.z_index = -1
	table_header.add_child(header_bg)
	header_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Colunas do cabeçalho
	var pos_header = Label.new()
	pos_header.text = "POS."
	pos_header.add_theme_color_override("font_color", Color.GOLD)
	pos_header.add_theme_font_size_override("font_size", 14)
	pos_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pos_header.custom_minimum_size.x = 80
	
	var player_header = Label.new()
	player_header.text = "JOGADOR"
	player_header.add_theme_color_override("font_color", Color.GOLD)
	player_header.add_theme_font_size_override("font_size", 14)
	player_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	player_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var time_header = Label.new()
	time_header.text = "TEMPO"
	time_header.add_theme_color_override("font_color", Color.GOLD)
	time_header.add_theme_font_size_override("font_size", 14)
	time_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_header.custom_minimum_size.x = 100
	
	table_header.add_child(pos_header)
	table_header.add_child(player_header)
	table_header.add_child(time_header)
	
	# Linha separadora
	var separator = HSeparator.new()
	separator.add_theme_color_override("separator", Color.GOLD)
	separator.custom_minimum_size.y = 2
	
	# Monta o cabeçalho
	table_header_section.add_child(positions_title)
	table_header_section.add_child(table_header)
	table_header_section.add_child(separator)
	
	# DADOS DA TABELA (logo abaixo do cabeçalho)
	var table_data = VBoxContainer.new()
	table_data.add_theme_constant_override("separation", 2)
	
	for i in range(ranking_entries.size()):
		var entry = ranking_entries[i]
		var rank_item = _create_ranking_item(entry, i % 2 == 0)
		table_data.add_child(rank_item)
	
	# Junta tudo
	main_table_container.add_child(table_header_section)
	main_table_container.add_child(table_data)
	
	ranking_list.add_child(main_table_container)

func _create_ranking_item(entry, is_even_row = true):
	"""Cria um item visual em formato de tabela para cada posição do ranking"""
	var row_container = HBoxContainer.new()
	row_container.add_theme_constant_override("separation", 15)
	row_container.custom_minimum_size.y = 35
	
	var position = int(entry.get("position", 0))
	var player_name = str(entry.get("nickname", "N/A"))
	var time_seconds = float(entry.get("time_seconds", 0.0))
	var is_current_player = (API.jogador_nickname == player_name)
	
	# Fundo da linha (alternando cores)
	var row_bg = ColorRect.new()
	if is_current_player:
		row_bg.color = Color(0, 0.4, 0.6, 0.4)  # Azul para jogador atual
	elif is_even_row:
		row_bg.color = Color(0.1, 0.1, 0.1, 0.3)  # Cinza escuro para linhas pares
	else:
		row_bg.color = Color(0.05, 0.05, 0.05, 0.2)  # Mais escuro para linhas ímpares
	
	row_bg.z_index = -1
	row_container.add_child(row_bg)
	row_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# COLUNA 1: Posição (80px)
	var position_label = Label.new()
	position_label.custom_minimum_size.x = 80
	position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	position_label.add_theme_font_size_override("font_size", 16)
	
	# Formatação especial para top 3
	match position:
		1:
			position_label.text = "🥇 " + str(position) + "º"
			position_label.add_theme_color_override("font_color", Color.GOLD)
		2:
			position_label.text = "🥈 " + str(position) + "º"
			position_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
		3:
			position_label.text = "🥉 " + str(position) + "º"
			position_label.add_theme_color_override("font_color", Color("#CD7F32")) # Bronze
		_:
			position_label.text = str(position) + "º"
			position_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)
	
	# COLUNA 2: Nome do jogador (expansível)
	var player_label = Label.new()
	player_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	player_label.add_theme_font_size_override("font_size", 16)
	
	if is_current_player:
		player_label.text = player_name + " (VOCÊ)"
		player_label.add_theme_color_override("font_color", Color.CYAN)
	else:
		player_label.text = player_name
		player_label.add_theme_color_override("font_color", Color.WHITE)
	
	# COLUNA 3: Tempo (100px)
	var time_label = Label.new()
	time_label.text = str(time_seconds) + "s"
	time_label.custom_minimum_size.x = 100
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_font_size_override("font_size", 16)
	
	if is_current_player:
		time_label.add_theme_color_override("font_color", Color.CYAN)
	else:
		# Cor baseada na performance (verde para tempos melhores)
		if time_seconds <= 80.0:
			time_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
		elif time_seconds <= 90.0:
			time_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			time_label.add_theme_color_override("font_color", Color.LIGHT_CORAL)
	
	# Adiciona bordas sutis
	var border_top = ColorRect.new()
	border_top.color = Color(0.3, 0.3, 0.3, 0.5)
	border_top.custom_minimum_size.y = 1
	border_top.z_index = 1
	
	# Monta a linha
	row_container.add_child(position_label)
	row_container.add_child(player_label)
	row_container.add_child(time_label)
	
	return row_container

func _on_btn_voltar_pressed():
	# Desconecta do signal para evitar vazamentos
	if API.is_connected("ranking_received", _on_ranking_received):
		API.disconnect("ranking_received", _on_ranking_received)
	
	# Volta para o menu principal
	get_tree().change_scene_to_file("res://MainMenu.tscn")
