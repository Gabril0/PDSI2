extends Panel
class_name MinimapIcon

enum State { HIDDEN, VISITED, CURRENT, SPECIAL }

@export var color_hidden: Color = Color("2d2d2d")
@export var color_visited: Color = Color("6d6d6d")
@export var color_current: Color = Color("ffffff")
@export var color_special_shop: Color = Color("AF5C00") 
@export var color_special_boss: Color = Color("ff0000") 

var stylebox: StyleBoxFlat #para mudar a cor do painel via código.

func _ready():
	stylebox = get_theme_stylebox("panel").duplicate()
	set("theme_override_styles/panel", stylebox)
	
	set_state(State.HIDDEN)

func set_state(new_state: State, room_type: String = ""):
	match new_state:
		State.HIDDEN:
			stylebox.bg_color = color_hidden
		State.VISITED:
			stylebox.bg_color = color_visited
		State.CURRENT:
			stylebox.bg_color = color_current
		State.SPECIAL:

			match room_type:
				"shop":
					stylebox.bg_color = color_special_shop
				"boss":
					stylebox.bg_color = color_special_boss
				_:
					stylebox.bg_color = color_visited
