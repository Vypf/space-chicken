extends Node2D
class_name Game

@onready var online_multiplayer_screen = %OnlineMultiplayerScreen

func _ready():
	online_multiplayer_screen.on_lobby_joined.connect(func(port): 
		print('LOBBY JOINED ' + str(port))
	)
