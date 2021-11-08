extends KinematicBody2D
class_name Actor

var velocity := Vector2.ZERO

const FLOOR_NORMAL :=  Vector2.UP
const CEILING_NORMAL :=  Vector2.DOWN

export var speed := Vector2(0.0, 0.0)
export var gravity := 1000.0
