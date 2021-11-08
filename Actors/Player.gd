extends Actor

var can_dj := false
var has_dj := true

var has_jetpack := false

var was_on_floor := 0.0
var pressed_jump := 0.0

var candy := 0
var candyMult := 1
onready var bucketProgress := $CanvasLayer/bucket/VBoxContainer/TextureProgress
onready var full := $CanvasLayer/bucket/VBoxContainer/FULL

var points := 0
onready var pointText := $CanvasLayer/points

signal drop_bomb
var can_bomb := 0.0
onready var bomb_font = $CanvasLayer/bomb/bombTimer.get("custom_fonts/font")

var has_pumpkin := false

func _ready() -> void:
	$newLevel.play("newLevel")

func _physics_process(delta: float) -> void:
	was_on_floor -= delta
	if is_on_floor():
		was_on_floor = delta*10
	pressed_jump -= delta
	if Input.is_action_just_pressed("jump"):
		pressed_jump = delta*5
	var is_jump_interrupted := Input.is_action_just_released("jump") and velocity.y < 0.0
	var direction := get_direction()
	if direction.y < 0.0:
		pressed_jump = 0.0
	velocity = calc_move_vel(velocity, direction, is_jump_interrupted)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	# flip player sprite
	if round(velocity.x) > 0.0: $Sprite.flip_h = false
	if round(velocity.x) < 0.0: $Sprite.flip_h = true
	
	

func _process(delta: float) -> void:
	# other stuff
	handleBoombs()
	$pumpkinSprite.visible = has_pumpkin

func handleBoombs() -> void:
	if can_bomb < 0.0:
		bomb_font.size = 25
		$CanvasLayer/bomb/bombTimer.text = "READY!"
		if can_bomb > -10.0:
			# play sound
			pass
		can_bomb = -10.0
	else:
		bomb_font.size = 50
		$CanvasLayer/bomb/bombTimer.text = str(round(can_bomb))
		can_bomb-= get_process_delta_time()*3
	if Input.is_action_just_pressed("bomb") and can_bomb < 0.0:
		emit_signal("drop_bomb", global_position)
		can_bomb = 10.0
	
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1.0 if pressed_jump > 0.0 and (was_on_floor > 0.0 or (can_dj and has_dj) or has_jetpack) else 1.0
	)
	
func calc_move_vel(
		vel: Vector2,
		direction: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var out := vel
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()
	if direction.y == -1:
		out.y  = speed.y * direction.y
	if is_jump_interrupted:
		out.y = out.y*0.5
	return out


func _on_Level_changePlayersPosition(pos: Node2D) -> void:
	global_position = pos.global_position


func _on_trigger_body_entered(body: Node) -> void:
	if body.get_groups().has("candy"):
		if candy < 60:
			body.play()
			if body.type == 0:
				candy += 7
			if body.type == 1:
				candy += 15
		else:
			if $full_bag.playing == false:
				$full_bag.playing = true
				full.visible = true
		bucketProgress.value = candy
	if body.get_groups().has("pumpkin"):
		if has_pumpkin == false:
			has_pumpkin = true
			$pumpkinEffect.play()
			body.queue_free()

func _on_trigger_area_entered(altar: Area2D) -> void:
	print('a')
	if candy > 0 or has_pumpkin == true:
		$sacrifice.playing = true
		altar.get_node("smoke").emitting = true
		points += candy * candyMult
		if has_pumpkin == true:
			points += 30 * candyMult
			has_pumpkin = false
		candy = 0
		bucketProgress.value = 0
		$full_bag.playing = false
		full.visible = false
		pointText.text = str(points)


func _on_Level_resetPlayer() -> void:
	if candyMult == 3:
		$CanvasLayer/end.visible = true
		$CanvasLayer/end/score.text = "SCORE: \n" + str(points)
		$game_end.play()
	candy = 0
	can_bomb = 0
	has_pumpkin = false
	$full_bag.playing = false
	full.visible = false
	bucketProgress.value = 0
	candyMult += 1
	$CanvasLayer/newLevel.text = "LEVEL " + str(candyMult)
	$newLevel.play("newLevel")


func _on_Button_pressed() -> void:
	get_tree().change_scene("res://Scenes/Menu.tscn")

