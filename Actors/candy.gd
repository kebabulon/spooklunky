extends Actor

var type := 0

func _ready() -> void:
	add_to_group("candy")
	if type == 0:
		$Sprite.texture = preload("res://sprites/candy_1.png")
	if type == 1:
		$Sprite.texture = preload("res://sprites/candy_2.png")
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	velocity.y += gravity * get_physics_process_delta_time()
	if is_on_floor():
		velocity.y = 0
	move_and_slide(velocity, Vector2.UP)

func play() -> void:
	$AnimationPlayer.play("candy")
	$AudioStreamPlayer.play()
