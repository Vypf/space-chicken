extends Pickable


func _ready():
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.play("idle")


func _on_body_entered(player: Node2D):
	if not player is CharacterBody2D:
		return
	
	queue_free()
