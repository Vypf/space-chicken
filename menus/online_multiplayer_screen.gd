extends Control
class_name OnlineMultiplayerScreen

@export var address: String

@onready var lobby_panel: LobbyPanel = %LobbyPanel
@onready var lobby_client: LobbyClient = %LobbyClient

signal on_lobby_joined(port: int)

var _requested_lobby_code: String

func _ready():
	lobby_client.join(address)
	lobby_client.lobby_connected.connect(_on_lobby_connected)
	lobby_client.lobby_created.connect(_on_lobby_created)
	lobby_panel.on_host_click.connect(_on_host_click)
	lobby_panel.on_join_click.connect(_on_join_click)

func _on_lobby_connected(peer_id: int, lobby_info: Dictionary):
	if lobby_info.code == _requested_lobby_code:
		on_lobby_joined.emit(lobby_info.port)

func _on_lobby_created(code):
	_requested_lobby_code = code
	
func _on_host_click():
	lobby_client.create()
	
func _on_join_click(code: String):
	var peer_id: String = _find_key(lobby_client.lobbies, func(key, value):
		return value.code == code
	)
	if peer_id:
		var lobby_info: Dictionary = lobby_client.lobbies[peer_id]
		on_lobby_joined.emit(lobby_info.port)

## Retourne la première clé du dictionnaire pour laquelle le callable renvoie true.
## - dict: Dictionary à parcourir
## - predicate: un Callable qui reçoit (key, value)
## - default: valeur retournée si aucune clé ne correspond
func _find_key(dict: Dictionary, predicate: Callable, default : Variant = null):
	for key in dict.keys():
		var value = dict[key]
		if predicate.call(key, value):
			return key
	return default
