extends CharacterBody2D

@export var max_speed := 300.0
@export var acceleration := 1800.0
@export var deceleration := 1200.0
var run_direction := "side"

func _physics_process(delta: float) -> void:

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var has_input_direction := direction.length() > 0.0

	if has_input_direction:
		var desired_velocity := direction * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move_and_slide()
	
	if velocity.length() > 0.0:
		if abs(velocity.x) < abs(velocity.y):
			if velocity.y < 0.0:
				run_direction = "back"
			else:
				run_direction = "front"
		else:
			run_direction = "side"
			
		$AnimatedSprite2D.play("run_" + run_direction)
		$AnimatedSprite2D.flip_h = velocity.x < 0.0
	else:
		$AnimatedSprite2D.play("idle_" + run_direction)
	
	
