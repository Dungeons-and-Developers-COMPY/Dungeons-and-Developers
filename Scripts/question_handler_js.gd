extends Node

var session_cookie = ""
var username = "Admin_Username"
var password = "Admin_Password!"
var login_username = "Mahir"
var login_password = "MrMoodles123!"
var login_key = "4fIEjhIwkfIIPcU2m4vYDdLe0ZFkDgzh"
var login_url = "https://dungeonsanddevelopers.cs.uct.ac.za/admin/login"
var random_q_url = "https://dungeonsanddevelopers.cs.uct.ac.za/questions/random/"
var submission_url = "https://dungeonsanddevelopers.cs.uct.ac.za/admin/submit/"
var test_code_url = "https://dungeonsanddevelopers.cs.uct.ac.za/admin/run-code"
var register_server_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/register"
var deregister_server_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/deregister"
var find_server_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/find-available?type="
var update_player_count_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/update-players"
var difficulties = ["Easy", "Medium", "Hard"]
var is_server := OS.has_feature("dedicated_server")

var request_queue = []
var current_server_request = "REGISTER"


signal all_received
signal shutdown

signal login_successful(next_step: String)
signal server(found: bool, message: String, ip: String, port: int)
signal submission_result(output: String, passed: bool)
signal test_result(output: String, passed: bool)
signal question(q, question_num: int)

var login_callback_ref
var server_callback_ref
var submit_callback_ref
var test_callback_ref
var get_question_callback_ref
var next_step: String = "FIND"
var question_to_replace = 0

#region login

func login(next: String = "FIND"):
	next_step = next
	
	print("attempting to login via js")
	login_callback_ref = JavaScriptBridge.create_callback(on_login_response)
	var window = JavaScriptBridge.get_interface("window")
	
	# store callback for login
	window.godotLoginCallback = login_callback_ref
	print("Callback stored in window")
	
	var js_code := """
	console.log('Starting login fetch...');
	console.log('Callback available:', typeof window.godotLoginCallback);
	
	fetch('%s', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify({
			login_key: '%s'
		}),
		credentials: 'include'
	})
	.then(response => {
		console.log('Fetch response received, status:', response.status);
		return response.text();
	})
	.then(data => {
		console.log('Response data:', data);
		console.log('About to call Godot callback...');
		if (window.godotLoginCallback) {
			try {
				var dataToSend = typeof data === 'string' ? data : JSON.stringify(data);
				console.log('Sending to Godot:', dataToSend);
				window.godotLoginCallback(dataToSend);
				console.log('Godot callback called successfully');
			} catch(e) {
				console.error('Error calling Godot callback:', e);
			}
		} else {
			console.error('Godot callback not found!');
		}
		delete window.godotLoginCallback;
	})
	.catch(error => {
		console.error('Login error:', error);
		if (window.godotLoginCallback) {
			try {
				window.godotLoginCallback('{"error": "' + error.message + '"}');
			} catch(e) {
				console.error('Error in error callback:', e);
			}
		}
		delete window.godotLoginCallback;
	});
	""" % [
		login_url,
		login_key
	]
	
	print("About to execute JavaScript...")
	JavaScriptBridge.eval(js_code)
	print("JavaScript executed")

func on_login_response(args: Array):
	print("=== LOGIN RESPONSE RECEIVED ===")
	print("Args: ", args)
	var response_text = args[0]
	if response_text is JavaScriptObject:
		response_text = response_text.to_string()
	print("Response text: ", response_text)
	
	var json = JSON.new()
	var result = json.parse(response_text)
	if result == OK:
		print("Parsed JSON:", json.data)
		
		var message = json.data.get("message")
		var success = json.data.get("success")
		if message == "Logged in successfully":
			print("Login successful.")
			emit_signal("login_successful", next_step)
		else:
			print("Login failed:", json.data.get("error", "Unknown error"))
			#emit_signal("login_failed", json.data.get("error", "Unknown error"))
	else:
		print("Login response was not valid JSON.")
		print("Raw response:", response_text)
		#emit_signal("login_failed", "Invalid JSON")

#endregion

#region find server

func find_server(type: String):
	print("attempting to find server via js")
	current_server_request = "FIND"
	
	# Create callback for server response
	server_callback_ref = JavaScriptBridge.create_callback(on_find_server_response)
	var window = JavaScriptBridge.get_interface("window")
	window.godotFindServerCallback = server_callback_ref
	
	var url = find_server_url + type
	var js_code := """
	console.log('Starting find server request...');
	console.log('URL:', '%s');
	console.log('Session cookie:', '%s');
	
	fetch('%s', {
		method: 'GET',
		headers: {
			'Content-Type': 'application/json',
		},
		credentials: 'include'
	})
	.then(response => {
		console.log('Find server response received, status:', response.status);
		return response.text();
	})
	.then(data => {
		console.log('Find server response data:', data);
		if (window.godotFindServerCallback) {
			try {
				window.godotFindServerCallback(data);
				console.log('Find server callback called successfully');
			} catch(e) {
				console.error('Error calling find server callback:', e);
			}
		} else {
			console.error('Find server callback not found!');
		}
		delete window.godotFindServerCallback;
	})
	.catch(error => {
		console.error('Find server error:', error);
		if (window.godotFindServerCallback) {
			try {
				window.godotFindServerCallback('{"error": "' + error.message + '"}');
			} catch(e) {
				console.error('Error in find server error callback:', e);
			}
		}
		delete window.godotFindServerCallback;
	});
	""" % [url, session_cookie, url]
	
	var err = JavaScriptBridge.eval(js_code)
	if err != null:
		print("JavaScript execution failed: ", err)
	else:
		print("Find server request sent.")

func on_find_server_response(args: Array):
	print("=== FIND SERVER RESPONSE RECEIVED ===")
	print("Args: ", args)
	var response_text = args[0]
	if response_text is JavaScriptObject:
		response_text = response_text.to_string()
	print("Response text: ", response_text)
	
	var json = JSON.new()
	var result = json.parse(response_text)
	if result == OK:
		print("Parsed JSON:", json.data)
		#if response_code == 200:
		var response = json.data.get("message")
		var server_data = json.data.get("server")
		print(response)
		emit_signal("server", true, response, server_data["ip"], server_data["port"])
		#else:
			#var response = json.data.get("error")
			#print(response)
			#emit_signal("server", false, response, "", 0)
	else:
		print("Find server response was not valid JSON.")
		print("Raw response:", response_text)

#endregion

func get_question(difficulty: String, question_num: int):
	print("attempting to find server via js")
	
	question_to_replace = question_num 
	# Create callback for server response godotFindServerCallback
	get_question_callback_ref = JavaScriptBridge.create_callback(on_get_question_response)
	var window = JavaScriptBridge.get_interface("window")
	window.godotGetQuestionCallback = get_question_callback_ref
	
	var url = random_q_url + difficulty
	var js_code := """
	console.log('Starting get question request...');
	console.log('URL: ', '%s');
	
	fetch('%s', {
		method: 'GET',
		headers: {
			'Content-Type': 'application/json',
		},
		credentials: 'include'
	})
	.then(response => {
		console.log('Get question response received, status:', response.status);
		return response.text();
	})
	.then(data => {
		console.log('Get question response data:', data);
		if (window.godotGetQuestionCallback) {
			try {
				window.godotGetQuestionCallback(data);
				console.log('Get question callback called successfully');
			} catch(e) {
				console.error('Error calling find server callback:', e);
			}
		} else {
			console.error('Get question callback not found!');
		}
		delete window.godotGetQuestionCallback;
	})
	.catch(error => {
		console.error('Find server error:', error);
		if (window.godotGetQuestionCallback) {
			try {
				window.godotGetQuestionCallback('{"error": "' + error.message + '"}');
			} catch(e) {
				console.error('Error in get question error callback:', e);
			}
		}
		delete window.godotGetQuestionCallback;
	});
	""" % [url, url]
	
	var err = JavaScriptBridge.eval(js_code)
	if err != null:
		print("JavaScript execution failed: ", err)
	else:
		print("Find server request sent.")

func on_get_question_response(args: Array):
	print("=== GET QUESTION RESPONSE RECEIVED ===")
	print("Args: ", args)
	var response_text = args[0]
	if response_text is JavaScriptObject:
		response_text = response_text.to_string()
	print("Response text: ", response_text)
	var json = JSON.new()
	var parse_result = json.parse(response_text)

	if parse_result == OK:
		print("JSON response:")
		print(json.data)
		var prompt = json.data.get("prompt_md")
		var title = json.data.get("title")
		var question_num = json.data.get("question_number")
		var res = [title, prompt, question_num]
		emit_signal("question", res, question_to_replace)
		
	else:
		print("Non-JSON response received:")
		print("Raw response:", response_text)

#region submit code

func submit_code(question_num: int, code: String):
	var payload = {
		"code": Marshalls.raw_to_base64(code.to_utf8_buffer())

	}
	var url = submission_url + str(question_num)
	
	print("attempting to submit code via js")
	submit_callback_ref = JavaScriptBridge.create_callback(on_submit_response)
	var window = JavaScriptBridge.get_interface("window")
	
	# store callback for submission
	window.godotSubmissionCallback = submit_callback_ref
	print("Callback stored in window")
	
	var js_code := """
	console.log('Starting login fetch...');
	console.log('Callback available:', typeof window.godotSubmissionCallback);
	
	var payload = %s;
	fetch('%s', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(payload),
		credentials: 'include'
	})
	.then(response => {
		console.log('Fetch response received, status:', response.status);
		return response.text();
	})
	.then(data => {
		console.log('Response data:', data);
		console.log('About to call Godot callback...');
		if (window.godotSubmissionCallback) {
			try {
				var dataToSend = typeof data === 'string' ? data : JSON.stringify(data);
				console.log('Sending to Godot:', dataToSend);
				window.godotSubmissionCallback(dataToSend);
				console.log('Godot callback called successfully');
			} catch(e) {
				console.error('Error calling Godot callback:', e);
			}
		} else {
			console.error('Godot callback not found!');
		}
		delete window.godotSubmissionCallback;
	})
	.catch(error => {
		console.error('Login error:', error);
		if (window.godotSubmissionCallback) {
			try {
				window.godotSubmissionCallback('{"error": "' + error.message + '"}');
			} catch(e) {
				console.error('Error in error callback:', e);
			}
		}
		delete window.godotSubmissionCallback;
	});
	""" % [
		JSON.stringify(payload),
		url
	]
	
	print("About to execute JavaScript...")
	JavaScriptBridge.eval(js_code)
	print("JavaScript executed")

func on_submit_response(args: Array):
	print("=== SUBMISSION RESPONSE RECEIVED ===")
	print("Args: ", args)
	var response_text = args[0]
	if response_text is JavaScriptObject:
		response_text = response_text.to_string()
	print("Response text: ", response_text)
	var json = JSON.new()
	var parse_result = json.parse(response_text)
	
	if parse_result == OK:
		print("JSON response:")
		print(json.data)
		var passed = json.data.get("success")
		var response = ""
		if passed:
			response = json.data.get("message")
		else:
			response = json.data.get("error")
		
		emit_signal("submission_result", response, passed)
	else:
		print("Non-JSON response received:")
		print("Raw response:", response_text)

#endregion

#region test code

func test_code(code: String, input):
	var payload = {
		"code": code,
		"input": input
	}
	var url = test_code_url
	
	print("attempting to submit code via js")
	test_callback_ref = JavaScriptBridge.create_callback(on_test_response)
	var window = JavaScriptBridge.get_interface("window")
	
	# store callback for submission godotSubmissionCallback
	window.godotTestCallback = test_callback_ref
	print("Callback stored in window")
	
	var js_code := """
	console.log('Starting login fetch...');
	console.log('Callback available:', typeof window.godotTestCallback);
	
	var payload = %s;
	fetch('%s', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(payload),
		credentials: 'include'
	})
	.then(response => {
		console.log('Fetch response received, status:', response.status);
		return response.text();
	})
	.then(data => {
		console.log('Response data:', data);
		console.log('About to call Godot callback...');
		if (window.godotTestCallback) {
			try {
				var dataToSend = typeof data === 'string' ? data : JSON.stringify(data);
				console.log('Sending to Godot:', dataToSend);
				window.godotTestCallback(dataToSend);
				console.log('Godot callback called successfully');
			} catch(e) {
				console.error('Error calling Godot callback:', e);
			}
		} else {
			console.error('Godot callback not found!');
		}
		delete window.godotTestCallback;
	})
	.catch(error => {
		console.error('Login error:', error);
		if (window.godotTestCallback) {
			try {
				window.godotTestCallback('{"error": "' + error.message + '"}');
			} catch(e) {
				console.error('Error in error callback:', e);
			}
		}
		delete window.godotTestCallback;
	});
	""" % [
		JSON.stringify(payload),
		url
	]
	
	print("About to execute JavaScript...")
	JavaScriptBridge.eval(js_code)
	print("JavaScript executed")

func on_test_response(args: Array):
	print("=== TEST RESPONSE RECEIVED ===")
	print("Args: ", args)
	var response_text = args[0]
	if response_text is JavaScriptObject:
		response_text = response_text.to_string()
	print("Response text: ", response_text)
	var json = JSON.new()
	var parse_result = json.parse(response_text)
	
	if parse_result == OK:
		print("JSON response:")
		print(json.data)
		var response
		var passed = json.data.get("success")
		if passed != null:
			response = json.data.get("result")
		else:
			passed = false
			response = json.data.get("error")
		emit_signal("test_result", str(response), passed)
	else:
		print("Non-JSON response received:")
		print("Raw response:", response_text)

#endregion
