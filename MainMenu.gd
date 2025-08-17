extends Control

@onready var vbox_container = $VBoxContainer
@onready var btn_jogar = $VBoxContainer/BtnJogar
@onready var btn_ranking = $VBoxContainer/BtnRanking
@onready var btn_sair = $VBoxContainer/BtnSair

func _ready():
	# Configura o layout para centralizar
	setup_layout()
	
	# Conecta os botões
	btn_jogar.pressed.connect(_on_btn_jogar_pressed)
	btn_ranking.pressed.connect(_on_btn_ranking_pressed)
	btn_sair.pressed.connect(_on_btn_sair_pressed)

func setup_layout():
	# Configura o fundo com a cor marrom escura da imagem
	var background = ColorRect.new()
	background.color = Color(0.4, 0.3, 0.3, 1.0)  # Cor marrom escura
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	move_child(background, 0)  # Move para trás dos outros elementos
	
	# Configura o container principal para ocupar toda a tela
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Configura o VBoxContainer para ficar posicionado à esquerda como na imagem
	if vbox_container:
		vbox_container.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
		vbox_container.position = Vector2(50, 250)  # Posição similar à imagem
		vbox_container.custom_minimum_size = Vector2(300, 300)
		vbox_container.add_theme_constant_override("separation", 15)  # Espaço entre botões
	
	# Configura os botões seguindo o estilo da imagem
	setup_button_style(btn_jogar, "Jogar", Color(0.85, 0.85, 0.85, 1.0))      # Cinza claro
	setup_button_style(btn_ranking, "Ranking", Color(0.85, 0.85, 0.85, 1.0))  # Cinza claro
	setup_button_style(btn_sair, "Sair", Color(0.6, 0.2, 0.2, 1.0))          # Vermelho escuro

func setup_button_style(button: Button, new_text: String, bg_color: Color):
	if button:
		button.text = new_text
		button.custom_minimum_size = Vector2(300, 80)  # Tamanho similar aos da imagem
		
		# Configura a fonte
		button.add_theme_font_size_override("font_size", 28)
		
		# Cria um StyleBoxFlat para customizar a aparência
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = bg_color
		style_normal.corner_radius_top_left = 15
		style_normal.corner_radius_top_right = 15
		style_normal.corner_radius_bottom_left = 15
		style_normal.corner_radius_bottom_right = 15
		
		# Estilo quando pressionado
		var style_pressed = StyleBoxFlat.new()
		style_pressed.bg_color = Color(bg_color.r * 0.8, bg_color.g * 0.8, bg_color.b * 0.8, 1.0)
		style_pressed.corner_radius_top_left = 15
		style_pressed.corner_radius_top_right = 15
		style_pressed.corner_radius_bottom_left = 15
		style_pressed.corner_radius_bottom_right = 15
		
		# Estilo quando hover
		var style_hover = StyleBoxFlat.new()
		style_hover.bg_color = Color(bg_color.r * 1.1, bg_color.g * 1.1, bg_color.b * 1.1, 1.0)
		style_hover.corner_radius_top_left = 15
		style_hover.corner_radius_top_right = 15
		style_hover.corner_radius_bottom_left = 15
		style_hover.corner_radius_bottom_right = 15
		
		# Aplica os estilos
		button.add_theme_stylebox_override("normal", style_normal)
		button.add_theme_stylebox_override("pressed", style_pressed)
		button.add_theme_stylebox_override("hover", style_hover)
		
		# Cor do texto
		if bg_color.r > 0.5:  # Se for cor clara, texto escuro
			button.add_theme_color_override("font_color", Color(0.3, 0.2, 0.3, 1.0))
		else:  # Se for cor escura, texto claro
			button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))

func _on_btn_jogar_pressed():
	# Muda para a cena do jogo principal
	get_tree().change_scene_to_file("res://main.tscn")

func _on_btn_ranking_pressed():
	# Muda para a cena do ranking
	get_tree().change_scene_to_file("res://Ranking.tscn")

func _on_btn_sair_pressed():
	# Sai do jogo
	get_tree().quit()
