extends Pickable

@onready var animated_sprite = %AnimatedSprite2D

func _ready():
	super()
	animated_sprite.play("idle")

func interact(player: CharacterBody2D):
	if (is_multiplayer_authority()):
		queue_free()
