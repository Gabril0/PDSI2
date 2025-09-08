extends Resource #Avisar a rapaziada que trocou de item para resource pq ai todos os novos objetos item vão usar o mesmo modelo de script
class_name Item

@export var i_name : String
@export var description: String
@export var price: int
@export var icon : Texture2D

@export_group("Efeitos do Item")
@export var heal_amount: int = 0      # Quantidade de vida a curar
@export var speed_buff: float = 0.0   # Aumento na velocidade (em pixels/seg)
@export var damage_buff: int = 0      # Aumento no dano

@export var health_regen: float = 0.0  # Vida por segundo


func activate(target: Entity):
	# Lógica de Cura
	if heal_amount > 0:
		target.heal(heal_amount)
		print(target.name, " curou ", heal_amount, " de vida.")

	# Lógica de Buff de Velocidade
	if speed_buff > 0.0:
		target.speed += speed_buff
		print(target.name, " aumentou a velocidade em ", speed_buff, ". Nova velocidade: ", target.speed)

	# Lógica de Buff de Dano
	if damage_buff > 0:
		target.damage += damage_buff
		print(target.name, " aumentou o dano em ", damage_buff, ". Novo dano: ", target.damage)

func on_process(target: Entity, delta: float):
	# Lógica de Regeneração de Vida
	if health_regen > 0.0:
		# Usamos 'delta' para que a cura seja por segundo, e não por frame.
		target.heal(health_regen * delta)
