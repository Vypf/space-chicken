@tool
extends Control
class_name WaitingRoom

@onready var h_box_container = %HBoxContainer
@onready var start_button: Button = %StartButton

const PLAYER_SLOT = preload("uid://dety1mr3r2ho0")

signal on_ready(peer_id:int)
signal on_start_clicked()

var slots :Array[LobbySlot]= []:
	set(value):
		slots = value
		_set_player_slots()
var peer_id: int

var _is_host: bool:
	get:
		if slots.is_empty():
			return false
		return peer_id == slots[0].peer_id

var _are_all_taken_slots_readied: bool:
	get:
		return slots.all(func(slot):
			if slot.peer_id == -1:
				return true
			return slot.is_ready
		)

func _ready():
	_set_player_slots()
	start_button.pressed.connect(func():
		on_start_clicked.emit()
	)
	
func _set_player_slots():
	if not h_box_container:
		return
	
	if _is_host and _are_all_taken_slots_readied:
		start_button.disabled = false
	else:
		start_button.disabled = true
	
	var children = h_box_container.get_children()
	for child in children:
		h_box_container.call_deferred("remove_child", child)
	
	for slot in slots:
		var player_slot :PlayerSlot= PLAYER_SLOT.instantiate()
		
		h_box_container.add_child(player_slot)
		player_slot.owner = h_box_container
		player_slot.is_ready = slot.is_ready
		player_slot.can_click = peer_id == slot.peer_id
		player_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		player_slot.on_ready_clicked.connect(func():
			on_ready.emit(slot.peer_id)
		)
