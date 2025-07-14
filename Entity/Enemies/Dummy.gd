class_name Dummy
extends Enemy

func _ready():
    add_to_group("enemy")
    add_to_group("attackable")

func _physics_process(_delta):
    check_collision()

func check_collision():
    for i in get_slide_collision_count():
        print("entered")
        var collision = get_slide_collision(i)
        var collider = collision.get_collider()
        
        if collider.is_in_group("player"):
            print("Colidindo com player!")
        elif collider.is_in_group("projectile"):
            take_damage(100)
            print("damage")


