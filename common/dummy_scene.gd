extends Node2D

signal on_started()

func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED

func clear_npcs():
	for npc in get_tree().get_nodes_in_group("sync_npc"):
		npc.queue_free()

func spawn_npcs(spawner: MultiplayerSpawner):
	if is_multiplayer_authority():
		var npcs = get_tree().get_nodes_in_group("sync_npc")
		for npc in npcs:
			var new_npc :Node= spawner.spawn(npc.scene_file_path)
			new_npc.global_position = npc.global_position
			npc.queue_free() 

func start():
	if not multiplayer.is_server():
		return
	_start.rpc()

@rpc("any_peer", "call_local")
func _start():
	process_mode = Node.PROCESS_MODE_ALWAYS
	on_started.emit()
