@tool
class_name PlayerSlot extends Control

@onready var ready_button = %ReadyButton
@onready var ready_label = %ReadyLabel

signal on_ready_clicked

@export var can_click:= false:
	set(value):
		can_click = value
		ready_button.disabled = not can_click
@export var is_ready := false:
	set(value):
		is_ready = value
		if is_ready:
			ready_button.visible = false
			ready_label.text = "Readied!"
		else:
			ready_button.visible = true
			ready_label.text = ""

func _ready():
	ready_button.pressed.connect(func():
		on_ready_clicked.emit()	
	)
