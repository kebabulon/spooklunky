extends Node

var paused := false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		paused = !paused
		if paused == true:
			get_tree().paused = true
			$CanvasLayer/bomb.visible = true
		else:
			get_tree().paused = false
			$CanvasLayer/bomb.visible = false


func _on_Button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/Menu.tscn")
