# patient_shoes.gd
extends Item

@export var speed_increase = 300

# A assinatura agora CORRESPONDE à do pai (Item.gd)
func activate(target: Entity) -> void:
	# Usamos 'target' (que será o jogador) em vez de 'player_ref'
	target.speed += speed_increase
	print(target.name, " teve sua velocidade aumentada em ", speed_increase)
