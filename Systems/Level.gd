extends Node2D

export(Array, PackedScene) var corridors := []
export(Array, PackedScene) var stairs := []
export(Array, PackedScene) var multis := []
export(Array, PackedScene) var randoms := []

export(PackedScene) var playerRoom: PackedScene
export(PackedScene) var altarRoom: PackedScene

onready var tileMap := $TileMap

var rng = RandomNumberGenerator.new()

var floodfillMatrix = []
var floodfillResult: bool

signal changePlayersPosition
var bomb_node := preload("res://Actors/bomb.tscn")

signal resetPlayer
var timeReset := 90
var timer := timeReset
onready var timerFont = $CanvasLayer/timer.get("custom_fonts/font")

var pumpkin_node = preload("res://Actors/Pumpkin.tscn")
var pumkinsPerLevel := 10

func _ready() -> void:
	randomize()
	$CanvasLayer/timer.text = str(timer/60) + ":" + str(timer%60)
	gen() # looks easier than it actually is...
	# update: ahhh pain

func gen() -> void:
	rng.randomize()
	var matrix := []
	delete_children($objects)
	for x in 4:
		matrix.append([])
		for y in 4:
			matrix[x].append(0)
	var pPos := [
			rng.randi_range(0, 3),
			rng.randi_range(0, 3)
		]
	var sPos := pPos
	while sPos == pPos:
		sPos = [
			rng.randi_range(0, 3),
			rng.randi_range(0, 3)
		]
	matrix[pPos[0]][pPos[1]] = 1
	matrix[sPos[0]][sPos[1]] = 2
	var mainPath := []
	var posRn = pPos
	var _temp = 0
	while posRn != sPos:
		_temp+=1
		if _temp > 20:
			# TODO: probably regen the map if this fails or somethin
			break
		# print(posRn, sPos)
		renderMatrix(matrix)
		var choiced := choicePath(matrix, posRn)
		for i in choiced:
			if getCoords(matrix, i) == 2:
				mainPath.append(i)
				matrix[i[0]][i[1]] = 1
				posRn = i
				break
			floodfillMatrix = []
			floodfillMatrix.clear()
			floodfillMatrix = matrix.duplicate(true)
			floodfillResult = false
			floodfill(i)
			if floodfillResult == true:
				mainPath.append(i)
				matrix[i[0]][i[1]] = 1
				posRn = i
				break
	print("done ", mainPath)
	addRoom(playerRoom, pPos)
	addRoom(altarRoom, sPos)
	randomize()
	for i in range(0, mainPath.size()-1):
		# up
		if mainPath[i][1]+1 == mainPath[i+1][1] and mainPath[i][1]-1 == mainPath[i-1][1]:
			addRoom(stairs[randi() % stairs.size()], mainPath[i])
		# down
		elif mainPath[i][1]-1 == mainPath[i+1][1] and mainPath[i][1]+1 == mainPath[i-1][1]:
			addRoom(stairs[randi() % stairs.size()], mainPath[i])
		# right
		elif mainPath[i][0]+1 == mainPath[i+1][0] and mainPath[i][0]-1 == mainPath[i-1][0]:
			addRoom(corridors[randi() % corridors.size()], mainPath[i])
		# left
		elif mainPath[i][0]-1 == mainPath[i+1][0] and mainPath[i][0]+1 == mainPath[i-1][0]:
			addRoom(corridors[randi() % corridors.size()], mainPath[i])
		# corner
		else:
			addRoom(multis[randi() % multis.size()], mainPath[i])
	for x in 4:
		for y in 4:
			if matrix[x][y] == 0:
				var room: PackedScene
				var r := randf()
				if r > 0.6:
					room = randoms[randi() % randoms.size()]
				else:
					room = multis[randi() % multis.size()]
				addRoom(room, [x, y])
	emit_signal("changePlayersPosition", $objects.get_node("playerSpawn"))
	# spawn pumkkins
	# amongus
	var pumpkins := $objects.get_children()
	for i in pumkinsPerLevel:
		var num := randi() % pumpkins.size()
		if pumpkins[num].get_groups().has("item"):
			var pump: Node2D = pumpkin_node.instance()
			$objects.add_child(pump)
			pump.global_position = pumpkins[num].global_position
			pumpkins[num].queue_free()
			pumpkins.remove(num)

func addRoom(pRoom: PackedScene, pos: Array) -> void:
	var room: Node2D = pRoom.instance()
	add_child(room)
	room.global_position = Vector2(pos[0]*320, pos[1]*320)
	if room.get_node("objects").get_child_count() > 0:
		for i in room.get_node("objects").get_children():
			var globalPos: Vector2 = i.global_position
			room.get_node("objects").remove_child(i)
			i.global_position = globalPos
			$objects.add_child(i)
	for x in 10:
		for y in 10:
			var roomMap := room.get_node("TileMap")
			tileMap.set_cell(x+10*pos[0],y+10*pos[1],roomMap.get_cell(x,y))
	room.free()

func floodfill(pos: Array) -> void:
	var choices := [[pos[0]-1, pos[1]], [pos[0]+1, pos[1]],
					[pos[0], pos[1]-1], [pos[0], pos[1]+1]]
	choices.shuffle()
	if floodfillResult == false:
		for i in 4:
			if getCoords(floodfillMatrix, choices[i]) == 2:
				print(choices[i])
				floodfillResult = true
				break
			elif getCoords(floodfillMatrix, choices[i]) == 0:
				floodfillMatrix[choices[i][0]][choices[i][1]] = -1
				floodfill(choices[i])
	
func getCoords(matrix: Array, pos: Array) -> int:
	if pos[0] > 3 or pos[1] > 3 or pos[0] < 0 or pos[1] < 0:
		return -1 
	else:
		return matrix[pos[0]][pos[1]]
	
func choicePath(m: Array, pos: Array) -> Array:
	# matrix[pos[0]][pos[1]]
	var choices := [[pos[0]-1, pos[1]], [pos[0]+1, pos[1]],
					[pos[0], pos[1]-1], [pos[0], pos[1]+1]]
	choices.shuffle()
	var correct := []
	for i in 4:
		if getCoords(m, choices[i]) == 0 or getCoords(m, choices[i]) == 2:
			correct.append(choices[i])
	return correct
		
		
func renderMatrix(matrix: Array) -> void:
	var s := ""
	for y in 4:
		for x in 4:
			s += str(matrix[x][y]) + " "
		s += "\n"
	print(s)


func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()


func _on_Player_drop_bomb(pos: Vector2) -> void:
	var bomb: KinematicBody2D = bomb_node.instance()
	bomb.global_position = pos
	bomb.tileMap = tileMap
	$objects.add_child(bomb)
	


func _on_timer_timeout() -> void:
	$timer.start()
	if timer == 0:
		timeReset -= 30
		timer = timeReset
		emit_signal("resetPlayer")
		gen()
	if timer <= 10:
		timerFont.size = 100
		$CanvasLayer/timer.modulate = Color(50,0,0)
	else:
		timerFont.size = 50
		$CanvasLayer/timer.modulate = Color(255,255,255)
	timer -= 1
	$CanvasLayer/timer.text = str(timer/60) + ":" + str(timer%60)
