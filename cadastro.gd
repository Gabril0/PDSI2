extends Control

@onready var email_input = $CenterContainer/VBoxContainer/Email
@onready var senha_input = $CenterContainer/VBoxContainer/Senha
@onready var nickname_input = $CenterContainer/VBoxContainer/Nickname
@onready var cadastro_button = $CenterContainer/VBoxContainer/Button

func _ready():
	_setup_ui()
	
	if cadastro_button:
		cadastro_button.pressed.connect(_on_cadastro_button_pressed)
	
	# Conecta ao sistema de API
	if not API.is_connected("register_completed", _on_register_completed):
		API.connect("register_completed", _on_register_completed)
	
	print("Tela de cadastro carregada!")

func _setup_ui():
	# Configura o campo de email
	if email_input:
		email_input.text = ""
	
	# Configura o campo de senha
	if senha_input:
		senha_input.text = ""
		senha_input.secret = true  # Oculta a senha
	
	# Configura o campo de nickname
	if nickname_input:
		nickname_input.text = ""
	


func _on_cadastro_button_pressed():
	var email = email_input.text.strip_edges()
	var senha = senha_input.text
	var nickname = nickname_input.text.strip_edges()
	
	# Validações básicas
	if email == "" or senha == "" or nickname == "":
		_show_message("Preencha todos os campos!", Color.RED)
		return
	
	if not _is_valid_email(email):
		_show_message("Email inválido!", Color.RED)
		return
	
	if nickname.length() < 3:
		_show_message("Nickname deve ter pelo menos 3 caracteres!", Color.RED)
		return
	
	if senha.length() < 6:
		_show_message("Senha deve ter pelo menos 6 caracteres!", Color.RED)
		return
	
	# Desabilita o botão durante a requisição
	cadastro_button.disabled = true
	
	# Faz cadastro via API
	print("Tentando cadastrar usuário:", email, "com nickname:", nickname)
	API.cadastrar(email, senha, nickname)

func _on_register_completed(success: bool, response_data):
	cadastro_button.disabled = false
	
	if success:
		_show_message("Cadastro realizado com sucesso!", Color.GREEN)
		
		await get_tree().create_timer(2.0).timeout
		_go_to_login()

	else:
		var error_msg = "Erro ao cadastrar"
		if response_data and response_data.has("detail"):
			error_msg = response_data["detail"]
		_show_message(error_msg, Color.RED)

# Volta para a tela de login
func _go_to_login():
	if API.is_connected("register_completed", _on_register_completed):
		API.disconnect("register_completed", _on_register_completed)
	
	get_tree().change_scene_to_file("res://Login.tscn")

func _show_message(message: String, color: Color):

	var message_label = get_node_or_null("MessageLabel")
	if not message_label:
		message_label = Label.new()
		message_label.name = "MessageLabel"
		message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		message_label.add_theme_font_size_override("font_size", 16)
		add_child(message_label)
		message_label.move_to_front()
	
	message_label.text = message
	message_label.add_theme_color_override("font_color", color)
	message_label.position = Vector2(0, 50)
	message_label.size = Vector2(get_viewport().size.x, 30)
	
	await get_tree().create_timer(3.0).timeout
	if message_label:
		message_label.text = ""

func _is_valid_email(email: String) -> bool:
	return email.contains("@") and email.contains(".")
