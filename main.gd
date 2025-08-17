extends Node

func _ready():
	# Faz login automático (você pode mudar depois para um sistema de login manual)
	API.login("teste@teste.com", "123456")

func _unhandled_input(event):
	# Pressione ESC para voltar ao menu
	if event.is_action_pressed("ui_cancel"):  # ESC
		if has_method("get_tree"):
			get_tree().change_scene_to_file("res://MainMenu.tscn")
		else:
			# Fallback para quando get_tree() não está disponível
			var scene_tree = Engine.get_main_loop()
			scene_tree.change_scene_to_file("res://MainMenu.tscn")
	
	# Pressione F1 para ver o ranking durante o jogo
	if event is InputEventKey and event.keycode == KEY_F1 and event.pressed:
		if has_method("get_tree"):
			get_tree().change_scene_to_file("res://Ranking.tscn")
		else:
			# Fallback para quando get_tree() não está disponível
			var scene_tree = Engine.get_main_loop()
			scene_tree.change_scene_to_file("res://Ranking.tscn")
