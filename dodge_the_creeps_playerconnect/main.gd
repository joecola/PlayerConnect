extends Node

# Declare member variables
var player_name = ""
var score = 0

# Add HTTPRequest Node reference
@onready var http_request = $HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load the player name if it exists
	var file = FileAccess.open("user://player_name.save", FileAccess.READ)
	if file:
		player_name = file.get_as_text().strip_edges()
		file.close()
	
	# Set the player name in the PlayerNameLabel
	$PlayerNameLabel.text = "Player: " + player_name
	
	# Connect the HTTPRequest completed signal
	http_request.request_completed.connect(_on_HTTPRequest_request_completed)

@export var mob_scene: PackedScene

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

	# Send HTTP request with player name and score
	send_score_update(player_name, score)

func new_game():
	get_tree().call_group("mobs", "queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()

func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress = randi()

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


# Function to send HTTP request with player name and score
func send_score_update(pname, current_score):
	# Construct JSON data
	var json_data = {
		"passkey": "123",
		"playerconnect_name": pname,
		"playerconnect_current_score": current_score,
		"playerconnect_info": "Dodge the Creeps"
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
