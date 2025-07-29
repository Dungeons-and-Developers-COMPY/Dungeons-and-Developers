extends Node

var username = "Admin_Username"
var password = "Admin_Password!"
var random_q_url = "https://dungeonsanddevelopers.cs.uct.ac.za/questions/random/"
var difficulties = ["Easy", "Medium", "Hard"]
var is_server := OS.has_feature("dedicated_server")

var request_queue = []

signal question(q)
signal all_received


@onready var question_request = $HTTPRequestQuestion

func add_to_queue(url):
	request_queue.append(url)

func get_all_questions():
	var url = random_q_url + difficulties[0]
	add_to_queue(url)
	url = random_q_url + difficulties[1]
	add_to_queue(url)
	url = random_q_url + difficulties[2]
	add_to_queue(url)
	
	get_question()
	

# gets a random question of a specified difficulty from the database
func get_question():
	if not is_server:
		return
	if request_queue.is_empty():
		print("All questions received")
		emit_signal("all_received")
		return
		
	var login_details = "%s:%s" % [username, password]
	var encoded_details = Marshalls.utf8_to_base64(login_details)
	var headers = ["Authorization: Basic %s" % encoded_details]
	
	var url = request_queue.pop_front()
	var err = question_request.request(url, headers)
	print(err)
	if err != OK:
		print("Failed to send request:", err)

# called when request for a question is completed
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if not is_server:
		return
		
	print("Status code:", response_code)

	var response_text := body.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(response_text)

	if parse_result == OK:
		print("JSON response:")
		#print(json.data)
		var prompt = json.data.get("prompt_md")
		var title = json.data.get("title")
		var res = [title, prompt]
		emit_signal("question", res)
		get_question()
		
	else:
		print("Non-JSON response received:")
		print("Raw response:", response_text)


# called when a post of testing code locally is completed
func _on_test_code_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if not is_server:
		return

# called when a post of submitted code is completed
func _on_sumbit_code_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if not is_server:
		return
