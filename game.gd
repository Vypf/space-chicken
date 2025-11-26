extends Node2D
class_name Game

@onready var game_instance: GameInstance = %GameInstance
@onready var lobby_client: LobbyClient = %LobbyClient
@onready var online_multiplayer_screen: OnlineMultiplayerScreen = %OnlineMultiplayerScreen
@onready var lobby_manager: LobbyManager = %LobbyManager
@onready var waiting_room: WaitingRoom = %WaitingRoom
@onready var player_spawner:PlayerSpawner = %PlayerSpawner
@onready var lobby_server:LobbyServer = %LobbyServer
@onready var level = %Level
@onready var npc_spawner: MultiplayerSpawner = %NPCSpawner

const TYPES := {
	"PLAYER": "PLAYER",
	"SERVER": "room",
	"LOBBY": "lobby"
}
var type:String:
	get:
		return Config.arguments.get("server_type", TYPES.PLAYER)

const DEFAULT_SERVER_URL: String = "games.yvonnickfrin.dev"
const LOBBY_PORT = 17018

var server_url: String:
	get:
		return Config.arguments.get("server_url", DEFAULT_SERVER_URL)

func get_game_instance_url(lobby_info: LobbyInfo) -> String:
	if Config.is_production:
		return "wss://" + server_url + "/" + lobby_info.code
	return "ws://localhost:" + str(lobby_info.port)

func get_lobby_manager_url() -> String:
	# lobby_url is for game servers in Docker to reach the lobby via internal DNS
	if Config.arguments.has("lobby_url"):
		return Config.arguments["lobby_url"]

	# For clients, derive lobby URL from server_url
	if Config.is_production:
		return "wss://" + server_url + "/lobby"
	return "ws://localhost:" + str(LOBBY_PORT)

func _ready():
	if type == TYPES.PLAYER:
		_set_window_title(TYPES.PLAYER)
		print("client is " + TYPES.PLAYER)
		level.clear_npcs()
		waiting_room.on_ready.connect(func(peer_id):
			lobby_manager.ready_peer(peer_id)
		)
		waiting_room.on_start_clicked.connect(func():
			lobby_manager.start()
		)
		lobby_manager.on_slots_update.connect(func(slots):
			waiting_room.peer_id = multiplayer.get_unique_id()
			waiting_room.slots = slots
		)
		level.on_started.connect(func():
			hide_screen(waiting_room)
		)
		game_instance.code_received.connect(func(code):
			hide_screen(online_multiplayer_screen)
			waiting_room.show()
		)
		online_multiplayer_screen.on_lobby_joined.connect(func(lobby_info: LobbyInfo):
			game_instance.create_client(get_game_instance_url(lobby_info))
		)
		lobby_client.join(get_lobby_manager_url())
	elif type == TYPES.SERVER:
		_set_window_title(TYPES.SERVER)
		lobby_manager.on_game_start_requested.connect(func(slots):
			player_spawner.spawn_players(slots)
			level.spawn_npcs(npc_spawner)
			level.start()
		)
		# TODO: Plutôt avoir la logique inverse, l'écran est caché par défaut et s'affiche quand on est joueur
		hide_screen(online_multiplayer_screen)
		print("client is " + TYPES.SERVER)
		var port = Config.arguments.get("port", null)
		var code = Config.arguments.get("code", null)
		
		if (port == null or code == null):
			print("Can't start game instance because port or code is missing.")
			return
		
		game_instance.create_server(port, code)
		var info = LobbyInfo.new()
		info.port = int(port)
		info.code = code
		info.pId = OS.get_process_id()
		lobby_client.lobby_info = info
		lobby_client.join(get_lobby_manager_url())
	# For dev purpose only
	elif type == TYPES.LOBBY:
		_set_window_title(TYPES.LOBBY)
		var instance_manager = LocalInstanceManager.new(
			Config.arguments.get("paths", {}),
			Config.arguments.get("executable_paths", {}),
			Config.arguments.get("log_folder", ""),
			Config.arguments.get("environment", "development"),
			Config.arguments.get("lobby_url", "")
		)
		lobby_server._instance_manager = instance_manager
		lobby_server.start(Config.arguments.get("port", LOBBY_PORT))
	else: 
		print(type + " type is not supported.")
		

func hide_screen(screen: Control):
	screen.hide()
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.set_process(false)
	screen.set_process_input(false)

func _set_window_title(title: String):
	var window = get_window()
	if window:
		window.title = title
