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
var register_server_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/register"
var deregister_server_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/deregister"
var find_server_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/find-available?type="
var update_player_count_url = "https://dungeonsanddevelopers.cs.uct.ac.za/server/update-players"
var difficulties = ["Easy", "Medium", "Hard"]
var is_server := OS.has_feature("dedicated_server")

var request_queue = []
var current_server_request = "REGISTER"

signal question(q)
signal all_received
signal submission_result(output: String, passed: bool)
signal test_result(output: String, passed: bool)
signal server(found: bool, message: String, ip: String, port: int)
signal shutdown

signal login_successful

var login_callback_ref

#region login

# Polling-based approach as fallback
func login_polling_fallback():
	print("Using polling fallback approach")
	
	var window = JavaScriptBridge.get_interface("window")
	window.godotLoginResult = null
	
	var js_code := """
	console.log('Starting login with polling approach...');
	window.godotLoginResult = null;
	
	fetch('%s', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify({
			username: '%s',
			password: '%s'
		}),
		credentials: 'include'
	})
	.then(response => response.text())
	.then(data => {
		console.log('Login response:', data);
		window.godotLoginResult = data;
	})
	.catch(error => {
		console.error('Login error:', error);
		window.godotLoginResult = '{"error": "' + error.message + '"}';
	});
	""" % [login_url, login_username, login_password]
	
	JavaScriptBridge.eval(js_code)
	
	# Poll for result
	poll_for_login_result()

func poll_for_login_result():
	var window = JavaScriptBridge.get_interface("window")
	var result = window.godotLoginResult
	
	if result != null:
		print("Polling got result: ", result)
		window.godotLoginResult = null  # Clean up
		on_login_response(result)
	else:
		# Keep polling
		await get_tree().create_timer(0.1).timeout
		poll_for_login_result()

func login():
	print("attempting to login via js")
	
	#var callback := JavaScriptBridge.create_callback(on_login_response)
	#var window = JavaScriptBridge.get_interface("window")
	login_callback_ref = JavaScriptBridge.create_callback(on_login_response)
	var window = JavaScriptBridge.get_interface("window")
	window.godotLoginCallback = login_callback_ref
	
	# Store callback for login
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
			username: '%s',
			password: '%s'
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
				window.godotLoginCallback([data]);
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
		login_username,
		login_password
	]
	
	print("About to execute JavaScript...")
	JavaScriptBridge.eval(js_code)
	print("JavaScript executed")

func on_login_response(args: Array):
	print("=== LOGIN RESPONSE RECEIVED ===")
	var response_text = args[0]
	print("Response text: ", response_text)
	
	var json = JSON.new()
	var result = json.parse(response_text)
	if result == OK:
		print("Parsed JSON:", json.data)
		
		var message = json.data.get("message")
		var success = json.data.get("success")
		if message == "Logged in successfully":
			print("Login successful.")
			emit_signal("login_successful")
		else:
			print("Login failed:", json.data.get("error", "Unknown error"))
			#emit_signal("login_failed", json.data.get("error", "Unknown error"))
		emit_signal("login_successful")
	else:
		print("Login response was not valid JSON.")
		print("Raw response:", response_text)
		#emit_signal("login_failed", "Invalid JSON")

#endregion

func find_server(type: String):
	print("attempting to find server via js")
	current_server_request = "FIND"
	
	# Create callback for server response
	var callback := JavaScriptBridge.create_callback(on_find_server_response)
	var window = JavaScriptBridge.get_interface("window")
	window.godotFindServerCallback = callback
	
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

# Polling fallback version
func find_server_polling_fallback(type: String):
	print("Using polling fallback for find server")
	current_server_request = "FIND"
	
	var window = JavaScriptBridge.get_interface("window")
	window.godotFindServerResult = null
	
	var url = find_server_url + type
	var js_code := """
	console.log('Starting find server with polling approach...');
	window.godotFindServerResult = null;
	
	fetch('%s', {
		method: 'GET',
		headers: {
			'Content-Type': 'application/json',
			'Cookie': '%s'
		},
		credentials: 'include'
	})
	.then(response => response.text())
	.then(data => {
		console.log('Find server response:', data);
		window.godotFindServerResult = data;
	})
	.catch(error => {
		console.error('Find server error:', error);
		window.godotFindServerResult = '{"error": "' + error.message + '"}';
	});
	""" % [url, session_cookie]
	
	JavaScriptBridge.eval(js_code)
	poll_for_find_server_result()

func poll_for_find_server_result():
	var window = JavaScriptBridge.get_interface("window")
	var result = window.godotFindServerResult
	
	if result != null:
		print("Find server polling got result: ", result)
		window.godotFindServerResult = null  # Clean up
		on_find_server_response(str(result))
	else:
		# Keep polling
		await get_tree().create_timer(0.1).timeout
		poll_for_find_server_result()

func on_find_server_response(response_text: String):
	print("=== FIND SERVER RESPONSE RECEIVED ===")
	print("Response text: ", response_text)
	
	var json = JSON.new()
	var result = json.parse(response_text)
	if result == OK:
		print("Parsed JSON:", json.data)
		# Handle your server response here
		# Example: emit_signal("server_found", json.data)
	else:
		print("Find server response was not valid JSON.")
		print("Raw response:", response_text)
