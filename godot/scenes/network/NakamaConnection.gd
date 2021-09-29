extends Node

# Nakama web console
# http://127.0.0.1:7351/
# admin:password

const SERVER_IP = "43.249.195.171"  # "127.0.0.1"
const PORT = 7350
const SERVER_KEY := "wT2kpPbvY83Pr8u9"

var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket
var _exception_handler := ExceptionHandler.new()
var storage_worker : StorageWorker
var account : NakamaAPI.ApiAccount
var auth_check_timer : Timer

var user_data : Dictionary
var room_users = {}
var default_user_data = {
	"coin": 0,
	"progress": {},
	"discovery": {},
}

var online_users = 0


# Some signals
signal account_retrived
signal user_data_retrived


func _ready():
	# Create a client
	client = Nakama.create_client(SERVER_KEY, SERVER_IP, PORT, "http")
	
	# Get the user ID from URL
	var custom_id = get_user_id()
	
	# Authenticate
	authenticate(custom_id)
	
	auth_check_timer = Timer.new()
	auth_check_timer.wait_time = 1800
	auth_check_timer.autostart = true
	auth_check_timer.one_shot = false
	auth_check_timer.connect("timeout", self, "auth_check_timer_timeout")


func get_user_id():
	# Fallback user ID
	var user_id = OS.get_unique_id()
	
	if user_id == "":
		user_id = "test-user"
	
#	if not OS.has_feature('JavaScript'):
#		print("[Web] No JavaScript feature.")
#		print("[Web] Invalid user ID fetched from URL! Log in as the test user.")
#		return user_id
#
#	var parsed_id = JavaScript.eval("""
#		var parameter = 'id';
#		var url_string = window.location.href;
#		var url = new URL(url_string);
#		url.searchParams.get(parameter);
#	""")
#
#	if parsed_id != null:
#		user_id = parsed_id
	
	return user_id


# Authenticating with the server
func authenticate(custom_id):
	############### Server Connection ###############
	# Obtain a session token using a custom ID
	session = yield(client.authenticate_custom_async(custom_id), "completed")
	if session.is_exception():
		print('[Network] Authentication failed!')
		return FAILED
	
	# Create a socket with the server
	socket = Nakama.create_socket_from(client)
	
	# Connect networking events
	socket.connect("connected", self, "_socket_connected")
	socket.connect("closed", self, "_socket_closed")
	socket.connect("received_error", self, "_socket_error")
	
	# Connect socket to the server
	yield(socket.connect_async(session), "completed")
	if session.is_exception():
		print('[Network] Creating socket failed!')
		return FAILED
	
	############### Server Storage ###############
	# Create a new storage worker
	storage_worker = StorageWorker.new(session, client, _exception_handler)
	
	# User info
	if not retrieve_account():
		print("[Network] Retrieving account failed!")
		return FAILED
	
	# Retrieve user storage
	user_data = yield(storage_worker.get_data_async("user_data", "basic", session.user_id), "completed")
	
	# Create new user data if there are none
	if user_data.size() == 0:
		user_data = default_user_data
		var result = yield(storage_worker.create_data_async("user_data", "basic", user_data), "completed")
		if result != OK:
			print("[Network] Failed to create new user data!")
			return FAILED
	
	# Retrieve public data
	var broadcast = yield(storage_worker.get_data_async("system", "broadcast", null), "completed")
	#if broadcast.has("theme"):
	#	Global.theme = broadcast["theme"]
	
	emit_signal("user_data_retrived")
	
	return OK


func _socket_connected():
	print("[Network] Socket connected.")


func _socket_closed():
	print("[Network] Socket closed.")


func _socket_error():
	print("[Network] Socket error.")


func retrieve_account():
	# No valid session
	if not session: return
	
	# Retrieve account
	account = yield(client.get_account_async(session), "completed")
	if account.is_exception():
		print("[Network] An error occured: %s" % account)
		return FAILED
	
	# Retrieve wallet
	var wallet_dict = JSON.parse(account.wallet).result
	
	if wallet_dict.has("金币"):
		Global.coin_count = wallet_dict["金币"]
	else:
		Global.coin_count = 0
	
	print("[Network] Retrieved account")
	print("[Network] User ID '%s' | Username '%s' | Display name '%s'" % [account.user.id, account.user.username, account.user.display_name])
	print("[Network] User's wallet: %s" % account.wallet)
	
	emit_signal("account_retrived")
	
	return OK


func update_display_name(display_name : String):
	var update : NakamaAsyncResult = yield(client.update_account_async(session, null, display_name), "completed")
	if update.is_exception():
		print("[Network] An error occured: %s" % update)
		return FAILED
	print("[Network] Updated display name")
	return OK


func fetch_users_by_ids(ids : Array):
	var result : NakamaAPI.ApiUsers = yield(client.get_users_async(session, ids), "completed")
	if result.is_exception():
		print("[Network] An error occured: %s" % result)
		return {}
	for u in result.users:
		print("[Network] User id '%s' username '%s' user display name '%s'" % [u.id, u.username, u.display_name])
	
	return result.users


func update_data(collection, key, dict):
	if storage_worker:
		storage_worker.update_data_async(collection, key, dict)
	else:
		print("[Network] No storage worker!")


func update_leaderboard(leaderboard_id, value) -> int:
	var record : NakamaAPI.ApiLeaderboardRecord = yield(
			client.write_leaderboard_record_async(
				session, leaderboard_id, value),
				"completed")
	
	if record.is_exception():
		print("[Network] An error occured: %s" % record)
		return FAILED
	
	print("[Network] New coin record %s by %s" % [record.score, record.username])
	
	return OK


func fetch_leaderboard():
	var leaderboard_id = "金币"
	var result : NakamaAPI.ApiLeaderboardRecordList = yield(
			client.list_leaderboard_records_async(
				session, leaderboard_id),
				"completed")
	
	if result.is_exception():
		print("[Network] An error occured: %s" % result)
		return []
	
	for r in result.records:
		var record : NakamaAPI.ApiLeaderboardRecord = r
		print("[Network] Record username %s and score %s" % [record.username, record.score])
	#print(result.records)
	return result.records


func auth_check_timer_timeout():
	# Get the user ID from URL
	var custom_id = get_user_id()
	
	# Re-authenticate
	authenticate(custom_id)
	
	print("[Network] Re-authenticated user")
