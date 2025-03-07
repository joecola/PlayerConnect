extends Control

# Declare member variables
var player_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load the player name if it exists
	var file = FileAccess.open("user://player_name.save", FileAccess.READ)
	if file:
		player_name = file.get_as_text().strip_edges()
		file.close()
	
	# Set the player name in the LineEdit
	$LineEdit.text = player_name

# Called when the OK button is pressed
func _on_ok_button_pressed():
	# Save the player name
	player_name = $LineEdit.text
	var file = FileAccess.open("user://player_name.save", FileAccess.WRITE)
	file.store_string(player_name)
	file.close()
	
	# Change to the main game scene
	get_tree().change_scene_to_file("res://main.tscn")
