@abstract
class_name Pickable extends Area2D

func _ready():
	add_to_group("sync_npc")
	# Layer 3 : Pickable (0010...)
	collision_layer = 4
	# Layer 1 : Player (1000...)
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	

@abstract
func interact(player: CharacterBody2D)

func _on_body_entered(player: Node2D):
	if not is_multiplayer_authority():
		return
	if player is CharacterBody2D:
		interact(player)
