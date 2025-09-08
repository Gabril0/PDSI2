extends Control

# Referências aos elementos da UI baseados na estrutura:
# CenterContainer -> VBoxContainer -> Email, Senha, Button
@onready var email_input = $CenterContainer/VBoxContainer/Email
@onready var senha_input = $CenterContainer/VBoxContainer/Senha  
@onready var login_button = $CenterContainer/VBoxContainer/Button
@onready var signup_button = $CenterContainer/VBoxContainer/Button2 

func _ready():
	
	_setup_ui()
	
	if login_button:
		login_button.pressed.connect(_on_login_button_pressed)
		
	if signup_button:
		signup_button.pressed.connect(_on_signup_button_pressed)
		
	
	# Conecta ao sistema de API para receber resposta do login
	if not API.is_connected("login_completed", _on_login_completed):
		API.connect("login_completed", _on_login_completed)
	

#Configura a interface
func _setup_ui():

	# Configura o campo de email
	if email_input and email_input is LineEdit:
		email_input.text = ""
	
	# Configura o campo de senha
	if senha_input and senha_input is LineEdit:
		senha_input.text = ""
		senha_input.secret = true  # Oculta a senha


func _on_login_button_pressed():
	var email = email_input.text.strip_edges()
	var senha = senha_input.text
	
	# Validações básicas
	if email == "" or senha == "":
		_show_message("Preencha todos os campos!", Color.RED)
		return
	
	if not _is_valid_email(email):
		_show_message("Email inválido!", Color.RED)
		return
	
	# Desabilita o botão durante a requisição
	login_button.disabled = true
	
	# Faz login via API
	print("Tentando fazer login com:", email)
	API.login(email, senha)

func _on_signup_button_pressed():
	
	if API.is_connected("login_completed", _on_login_completed):
		API.disconnect("login_completed", _on_login_completed)
	
	get_tree().change_scene_to_file("res://Cadastro.tscn")

func _on_login_completed(success: bool, player_data):
	login_button.disabled = false
	
	if success:
		_show_message("Login realizado com sucesso!", Color.GREEN)
		
		await get_tree().create_timer(1.5).timeout
		_go_to_main_menu()

	else:
		_show_message("Email ou senha incorretos!", Color.RED)

#Leva o user para o menu principal quando for bem sucedido
func _go_to_main_menu():
	if API.is_connected("login_completed", _on_login_completed):
		API.disconnect("login_completed", _on_login_completed)
	
	get_tree().change_scene_to_file("res://MainMenu.tscn")


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
