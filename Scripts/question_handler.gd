extends Node

var session_cookie = ""
var username = "Admin_Username"
var password = "Admin_Password!"
var login_username = "Mahir"
var login_password = "MrMoodles123!"
var login_url = "https://dungeonsanddevelopers.cs.uct.ac.za/admin/login"
var random_q_url = "https://dungeonsanddevelopers.cs.uct.ac.za/questions/random/"
var submission_url = "https://dungeonsanddevelopers.cs.uct.ac.za/admin/submit/"
var test_code_url = "https://dungeonsanddevelopers.cs.uct.ac.za/admin/run-code"
var difficulties = ["Easy", "Medium", "Hard"]
var is_server := OS.has_feature("dedicated_server")

var request_queue = []

signal question(q)
signal all_received
signal submission_result(output: String, passed: bool)
signal test_result

@onready var question_request = $HTTPRequestQuestion
@onready var submit_answer_http = $HTTPSumbitCode
@onready var test_answer_http = $HTTPTestCode
@onready var login_http = $HTTPLogin

func get_auth(questions: bool):
	var login_details = ""
	if question:
		login_details = "%s:%s" % [username, password]
	else:
		login_details = "%s:%s" % [username, password]
	var encoded_details = Marshalls.utf8_to_base64(login_details)
	var header = "Authorization: Basic %s" % encoded_details
	
	return header

func login():
	var payload = {
		"username": login_username,
		"password": login_password
	}
	var body = JSON.stringify(payload)
	var headers = ["Content-Type: application/json"]
	
	var err = login_http.request(login_url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		print("Login request failed! ", err)

func add_to_queue(url):
	request_queue.append(url)

func get_all_questions():
	var url = random_q_url + difficulties[0]
	add_to_queue(url)
	url = random_q_url + difficulties[0]
	add_to_queue(url)
	url = random_q_url + difficulties[2]
	add_to_queue(url)
	
	get_question()
	
func submit_answer(question_num: int, code: String):
	var payload = {
		"code": code
	}
	var json_payload = JSON.stringify(payload) 
	
	var url = submission_url + str(question_num)
	var headers = ["Content-Type: application/json", "Cookie: %s" % session_cookie]
	
	var err = submit_answer_http.request(url, headers, HTTPClient.METHOD_POST, json_payload)
	if err != OK:
		print("Failed to send request:", err)
	else:
		print("Request sent.")

func test_code(code: String, input):
	var payload = {
		"code": code,
		"input": input
	}
	var json_payload = JSON.stringify(payload) 
	
	var url = test_code_url
	var headers = ["Content-Type: application/json", "Cookie: %s" % session_cookie]
	
	var err = test_answer_http.request(url, headers, HTTPClient.METHOD_POST, json_payload)
	if err != OK:
		print("Failed to send request:", err)
	else:
		print("Request sent.")

# gets a random question of a specified difficulty from the database
func get_question():
	if not is_server:
		return
	if request_queue.is_empty():
		print("All questions received")
		emit_signal("all_received")
		return
		
	var headers = [get_auth(true)]
	
	var url = request_queue.pop_front()
	var err = question_request.request(url, headers)
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
		var question_num = json.data.get("question_number")
		var res = [title, prompt, question_num]
		emit_signal("question", res)
		get_question()
		
	else:
		print("Non-JSON response received:")
		print("Raw response:", response_text)

# called when a post of testing code locally is completed
func _on_test_code_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Status Code: ", response_code)
	var response_text := body.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(response_text)
	
	if parse_result == OK:
		print("JSON response:")
		print(json.data)
		var response = json.data.get("message")
		var passed = json.data.get("success")
		emit_signal("submission_result", response, passed)
	else:
		print("Non-JSON response received:")
		print("Raw response:", response_text)

# called when a post of submitted code is completed
func _on_sumbit_code_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Status code:", response_code)
	var response_text := body.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(response_text)
	
	if parse_result == OK:
		print("JSON response:")
		print(json.data)
		#var response = json.data.get("message")
		#var passed = json.data.get("success")
		#emit_signal("submission_result", response, passed)
	else:
		print("Non-JSON response received:")
		print("Raw response:", response_text)

func _on_login_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("Login Status:", response_code)
	var response_text = body.get_string_from_utf8()
	var json = JSON.new()
	if json.parse(response_text) == OK:
		print("Login Response: ", json.data)
	else:
		print("Login Response (raw): ", response_text)
		
	# get cookie from headers
	for header in headers:
		if header.begins_with("Set-Cookie:"):
			var cookie_line = header.replace("Set-Cookie: ", "")
			session_cookie = cookie_line.split(";")[0]
			break
			
	if session_cookie != "":
		print("Session Cookie: ", session_cookie)
		#submit_code()
	else:
		print("No session cookie found... Login failed.")
