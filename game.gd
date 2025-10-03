extends Node2D
class_name Game

@onready var game_instance: GameInstance = %GameInstance
@onready var lobby_client: LobbyClient = %LobbyClient
@onready var online_multiplayer_screen = %OnlineMultiplayerScreen

const TYPES := {
	"PLAYER": "PLAYER",
	"SERVER": "room"
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
		print("client is " + TYPES.PLAYER)
		online_multiplayer_screen.on_lobby_joined.connect(func(port): 
			print(get_game_instance_url(port))
			game_instance.create_client(get_game_instance_url(port))
		)
		lobby_client.join(get_lobby_manager_url())
	elif type == TYPES.SERVER:
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
		
		
	else: 
		print(type + " type is not supported.")
