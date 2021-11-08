extends Actor


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


func _physics_process(delta: float) -> void:
	velocity.y += gravity * get_physics_process_delta_time()
	if is_on_floor():
		velocity.y = 0
	move_and_slide(velocity, Vector2.UP)


