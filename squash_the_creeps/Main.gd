extends Node

# PlayerConnect - Declare member variables
var player_name = ""
var score = 0

# PlayerConnect - Add HTTPRequest Node reference
@onready var http_request = $HTTPRequest

@export var mob_scene: PackedScene


func _ready():
	$UserInterface/Retry.hide()
	# PlayerConnect - Load the player name if it exists
	var file = FileAccess.open("user://player_name.save", FileAccess.READ)
	if file:
		player_name = file.get_as_text().strip_edges()
		file.close()
	
	# Set the player name in the PlayerNameLabel
	$PlayerNameLabel.text = "Player: " + player_name
	
	# Connect the HTTPRequest completed signal
	http_request.request_completed.connect(_on_HTTPRequest_request_completed)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()


func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on the SpawnPath.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	# Communicate the spawn location and the player's location to the mob.
	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	# We connect the mob to the score label to update the score upon squashing a mob.
	mob.squashed.connect($UserInterface/ScoreLabel._on_Mob_squashed)


func _on_player_hit():
	$MobTimer.stop()
	$UserInterface/Retry.show()
# PlayerConnect - Send HTTP request with player name and score
	send_score_update(player_name, score)


# Function to send HTTP request with player name and score
func send_score_update(pname, current_score):
	# Construct JSON data
	var json_data = {
		"passkey": "123",
		"playerconnect_name": pname,
		"playerconnect_current_score": current_score,
		"playerconnect_info": "Squash the Creeps"
	}
	var json_text = JSON.stringify(json_data)
	
	# Create a properly formatted POST request
	var headers = PackedStringArray(["Content-Type: application/json"])
	var body = json_text.to_utf8_buffer()
	
	# Log the request details
	print("Sending HTTP request with the following data:")
	print("URL: https://final2.ddev.site/playerconnect/create-player")
	print("Headers: Content-Type: application/json")
	print("JSON Data: ", json_text)
	
	# Send POST request using the correct signature for Godot 4.4
	var error = http_request.request_raw(
		"https://final2.ddev.site/playerconnect/create-player",  # URL
		headers,                                                 # Headers
		HTTPClient.METHOD_POST,                                  # HTTP Method as enum
		body                                                     # Request body as PackedByteArray
	)
	
	# Log any errors in making the request
	if error != OK:
		print("Error making request: ", error)

# Called when HTTPRequest completes
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("HTTP request completed with result: ", result)
	print("Response code: ", response_code)
	print("Headers: ", headers)
	print("Body: ", body.get_string_from_utf8())

	var json = JSON.new()
	var parse_error = json.parse(body.get_string_from_utf8())
	if parse_error == OK:
		print("Response: ", json.data)
	else:
		print("Error parsing response: ", json.get_error_message())
		print("Error line: ", json.get_error_line())
