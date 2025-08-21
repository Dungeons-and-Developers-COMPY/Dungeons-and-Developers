extends Node

var js_callback_ref

signal signaling_message(msg: String)

# Called when the game starts
func _ready():
	_inject_js()
	# Bind JS → Godot callback
	js_callback_ref = JavaScriptBridge.create_callback(on_response)
	# Init WebRTC in browser
	JavaScriptBridge.eval("initVoice(function(msg){ godotSignaling(msg); })")

# Inject the WebRTC JavaScript
func _inject_js():
	var js_code = """
		var pc = null;
		var localStream = null;
		var sendToGodot = null;

		function initVoice(sendCallback) {
			sendToGodot = sendCallback;
			pc = new RTCPeerConnection();

			navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
				localStream = stream;
				localStream.getTracks().forEach(track => pc.addTrack(track, localStream));
			});

			pc.ontrack = event => {
				let audio = document.createElement("audio");
				audio.srcObject = event.streams[0];
				audio.autoplay = true;
				document.body.appendChild(audio);
			};

			pc.onicecandidate = event => {
				if (event.candidate) {
					sendToGodot(JSON.stringify({ type: "ice", candidate: event.candidate }));
				}
			};
		}

		async function makeOffer() {
			let offer = await pc.createOffer();
			await pc.setLocalDescription(offer);
			return JSON.stringify({ type: "offer", sdp: offer.sdp });
		}

		async function handleOffer(offerJson) {
			let offer = JSON.parse(offerJson);
			await pc.setRemoteDescription({ type: "offer", sdp: offer.sdp });
			let answer = await pc.createAnswer();
			await pc.setLocalDescription(answer);
			return JSON.stringify({ type: "answer", sdp: answer.sdp });
		}

		async function handleAnswer(answerJson) {
			let answer = JSON.parse(answerJson);
			await pc.setRemoteDescription({ type: "answer", sdp: answer.sdp });
		}

		function handleIce(iceJson) {
			let ice = JSON.parse(iceJson);
			pc.addIceCandidate(new RTCIceCandidate(ice.candidate));
		}
	"""
	JavaScriptBridge.eval(js_code)

# --- Public API ---

func start_call() -> String:
	# Returns an "offer" JSON to send to the other peer
	return JavaScriptBridge.eval("makeOffer()")

func receive_signal(msg: String) -> String:
	var data = JSON.parse_string(msg)
	match data.type:
		"offer":
			return JavaScriptBridge.eval("handleOffer('" + msg + "')")
		"answer":
			JavaScriptBridge.eval("handleAnswer('" + msg + "')")
			return ""
		"ice":
			JavaScriptBridge.eval("handleIce('" + msg + "')")
			return ""
		_:
			return ""

func on_response(args: Array):
	return
