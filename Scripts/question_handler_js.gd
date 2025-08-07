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

func login():
	print("attempting to login via js")
	var callback = JavaScriptBridge.create_callback(on_login_response)

	var js_code := """
	(function() {
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
		.then(data => %s(data))
		.catch(error => {
			console.error('Login error:', error);
			%s('{"error": "Login failed"}');
		});
	})();
	""" % [
		login_url,
		login_username,
		login_password,
		callback.get_as_string(),
		callback.get_as_string()
	]

	JavaScriptBridge.eval(js_code)

func on_login_response(response_text: String):
	print("Login response received.")

	var json = JSON.new()
	var result = json.parse(response_text)

	if result == OK:
		print("Parsed JSON:", json.data)
		
		var success = json.data.get("success")
		if success:
			print("Login successful.")
			emit_signal("login_successful")
		else:
			print("Login failed:", json.data.get("error", "Unknown error"))
			#emit_signal("login_failed", json.data.get("error", "Unknown error"))
	else:
		print("Login response was not valid JSON.")
		print("Raw response:", response_text)
		#emit_signal("login_failed", "Invalid JSON")

	
