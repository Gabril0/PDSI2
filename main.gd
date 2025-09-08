extends Node

func _unhandled_input(event):
	
	# ESC para voltar ao menu
	if event.is_action_pressed("ui_cancel"):  # ESC
		if has_method("get_tree"):
			get_tree().change_scene_to_file("res://MainMenu.tscn")
		else:
			# Fallback para quando get_tree() não está disponível
			var scene_tree = Engine.get_main_loop()
			scene_tree.change_scene_to_file("res://MainMenu.tscn")
	
