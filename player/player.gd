extends CharacterBody2D

@onready var animation_tree := %AnimationTree
@export var max_speed := 300.0
@export var acceleration := 1800.0
@export var deceleration := 1200.0

var last_facing_direction := Vector2(0, -1)

func _physics_process(delta: float) -> void:

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var has_input_direction := direction.length() > 0.0

	if has_input_direction:
		var desired_velocity := direction * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move_and_slide()
	
	var idle = !velocity
	
	if !idle:
		last_facing_direction = velocity.normalized()

	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
	animation_tree.set("parameters/Run/blend_position", last_facing_direction)
	

	
