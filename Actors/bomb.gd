extends Actor


var tileMap: TileMap

var radius := 2.5
var stop := false

var candy_node := preload("res://Actors/candy.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	velocity.y += gravity * get_physics_process_delta_time()
	if is_on_floor():
		velocity.y = 0
	if not stop:
		move_and_slide(velocity, Vector2.UP)
	

func circleMatrix(radius: float) -> Array:
	var out := []
	for x1 in ceil(10):
		out.append([])
		for y1 in ceil(10):
			var x2 = 5
			var y2 = 5
			if sqrt(pow(x2 - x1, 2) + pow(y2-y1, 2)) < radius:
				out[x1].append(1)
			else:
				out[x1].append(0)
	return out
	
func spawnCandy(pos: Vector2, type: int) -> void:
	var candy: KinematicBody2D = candy_node.instance()
	candy.type = type
	get_parent().add_child(candy)
	candy.global_position = pos+Vector2(16,16)
	

func boom() -> void:
	var m := circleMatrix(radius)
	for x in m.size():
		for y in m[0].size():
			# print(m[x][y])
			if m[x][y] == 1:
				print(m[x][y])
				var pos := tileMap.world_to_map(global_position)-Vector2(5,5)+Vector2(x,y)
				var cell := tileMap.get_cellv(pos)
				if cell == 0 or cell == 1 or cell == 4:
					if cell == 0 or cell == 1:
						spawnCandy(tileMap.map_to_world(pos), cell)
					tileMap.set_cellv(pos, -1)
	stop = true
	$Sprite.visible = false
	$CPUParticles2D.emitting = true
