extends Node2D
class_name Game

@onready var game_instance: GameInstance = %GameInstance
@onready var lobby_client: LobbyClient = %LobbyClient
@onready var online_multiplayer_screen = %OnlineMultiplayerScreen
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

# TODO: move to root after lobby refactoring
const SERVER_URL: String = "games.yvonnickfrin.dev/survivors"
const PORT = 17018
func get_game_instance_url(port: int) -> String:
	if Config.is_production:
		return "wss://" + SERVER_URL + "?port=" + str(port)
	return "ws://localhost:" + str(port)

func get_lobby_manager_url() -> String:
	if Config.is_production:
		return "wss://" + SERVER_URL
	return "ws://localhost:" + str(PORT)

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
		level.on_started.connect(func():
			hide_screen(waiting_room)
		)
		lobby_manager.on_slots_update.connect(func(slots):
			waiting_room.peer_id = multiplayer.get_unique_id()
			waiting_room.slots = slots
		)
		game_instance.code_received.connect(func(code):
			hide_screen(online_multiplayer_screen)
			waiting_room.show()
		)
		online_multiplayer_screen.on_lobby_joined.connect(func(port): 
			print(get_game_instance_url(port))
			game_instance.create_client(get_game_instance_url(port))
		)
		lobby_client.join(get_lobby_manager_url())
	elif type == TYPES.SERVER:
		_set_window_title(TYPES.SERVER)
		lobby_manager.on_game_start_requested.connect(func(slots):
			player_spawner.spawn_players(slots)
			level.spawn_npcs(npc_spawner)
			level.start()
		)
		hide_screen(online_multiplayer_screen)
		print("client is " + TYPES.SERVER)
		var port = Config.arguments.get("port", null)
		var code = Config.arguments.get("code", null)
		game_instance.create_server(port, code)
		lobby_client.lobby_info = {
			"port": port, "code": code, "pId": OS.get_process_id()
		}
		lobby_client.join(get_lobby_manager_url())
		
		if (port == null or code == null):
			print("Can't start game instance because port or code is missing.")
			return
	elif type == TYPES.LOBBY:
		_set_window_title(TYPES.LOBBY)
		DisplayServer.window_set_title('Lobby')
		lobby_server._paths = Config.arguments.get("paths", {})
		lobby_server._executable_paths = Config.arguments.get("executable_paths", {})
		lobby_server._log_folder = Config.arguments.get("log_folder", "")
		lobby_server._environment = Config.arguments.get("environment", "development")
		lobby_server.start(Config.arguments.get("port", PORT))
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
