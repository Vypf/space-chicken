extends CharacterBody2D

@onready var animation_tree := %AnimationTree
@export var max_speed := 300.0
@export var acceleration := 1800.0
@export var deceleration := 1200.0
@onready var input: PlayerInput = %Input

var last_facing_direction := Vector2(0, -1)

func _ready():
	# Avatar's input object is owned by player
	var input = find_child("Input")
	if input != null:
		input.set_multiplayer_authority(int(name))
		print("Set input(%s) ownership to %s" % [name, multiplayer.get_unique_id()])


func _physics_process(delta) -> void:
	if not is_multiplayer_authority():
		return
	
	var direction := input.direction
	var has_input_direction := direction.length() > 0.0

	if has_input_direction:
		var desired_velocity := direction * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	move_and_slide()


func _process(delta):
	var idle = !velocity
	
	if !idle:
		last_facing_direction = velocity.normalized()

	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
	animation_tree.set("parameters/Run/blend_position", last_facing_direction)
