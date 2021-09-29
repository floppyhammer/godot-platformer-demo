# Class that ServerConnection delegates work to
# Stores and fetches data in and out of server storage
extends Reference
class_name StorageWorker

# Nakama read permissions
enum ReadPermissions { NO_READ, OWNER_READ, PUBLIC_READ }

# Nakama write permissions
enum WritePermissions { NO_WRITE, OWNER_WRITE }

var _session: NakamaSession
var _client: NakamaClient
var _exception_handler: ExceptionHandler


func _init(session: NakamaSession, client: NakamaClient, exception_handler: ExceptionHandler) -> void:
	_session = session
	_client = client
	_exception_handler = exception_handler


# Create new data into server storage (will overwrite exsiting one)
func create_data_async(collection, key, data) -> int:
	print("Created new user data!")
	
	var result: int = yield(_write_data_async(collection, key, data), "completed")
	
	return result


# Get data from server storage
func get_data_async(collection, key, owner_id) -> Dictionary:
	var result : NakamaAPI.ApiStorageObjects
	if owner_id == null:
		result = yield(
			_client.read_storage_objects_async(
				_session,
				[NakamaStorageObjectId.new(collection, key)]
			), "completed")
	else:
		result = yield(
			_client.read_storage_objects_async(
				_session,
				[NakamaStorageObjectId.new(collection, key, owner_id)]
			), "completed")
		
	if result.is_exception():
		print("[StorageWorker] An error occured: %s" % result)
		return {}
	
	if result.objects.size() == 0:
		print("[StorageWorker] Storage object's size is zero")
		return {}
	
	var decoded_dict = JSON.parse(result.objects[0].value).result
	
	return decoded_dict


# Write data into server storage
func _write_data_async(collection, key, data) -> int:
	var result: NakamaAPI.ApiStorageObjectAcks = yield(
		_client.write_storage_objects_async(
			_session, [
				NakamaWriteStorageObject.new(
					collection,
					key,
					ReadPermissions.PUBLIC_READ,
					WritePermissions.OWNER_WRITE,
					JSON.print(data),
					""
				)
			]
		),
		"completed"
	)
	
	var parsed_result := _exception_handler.parse_exception(result)
	
	return parsed_result


# Update data
func update_data_async(collection, key, value) -> int:
	var decoded_dict: Dictionary = yield(get_data_async(collection, key, _session.user_id), "completed")
	
	if decoded_dict == null:
		print("[Network] Data that need to be updated do not exist!")
		return FAILED
	
	var result: int = yield(_write_data_async(collection, key, value), "completed")
	
	return result


## Asynchronous coroutine. Delete the character at the specified index in the array from
## player storage. Returns OK, a nakama error code, or ERR_PARAMETER_RANGE_ERROR
## if the index is too large or is invalid.
#func delete_user_basic_async(idx: int) -> int:
#	var characters: Array = yield(get_user_basic_async(), "completed")
#
#	if idx >= 0 and idx < characters.size():
#		var character: Dictionary = characters[idx]
#		yield(_client.rpc_async(_session, "remove_character_name", character.name), "completed")
#		characters.remove(idx)
#
#		var result: int = yield(_write_user_basic_async(characters), "completed")
#		return result
#	else:
#		return ERR_PARAMETER_RANGE_ERROR


## Asynchronous coroutine. Get the last logged in character from the server, if any.
## Returns a {name: String, color: Color} dictionary, or an empty dictionary if no
## character is found, or something goes wrong.
#func get_last_user_basic_async() -> Dictionary:
#	var storage_objects: NakamaAPI.ApiStorageObjects = yield(
#		_client.read_storage_objects_async(
#			_session, [NakamaStorageObjectId.new(COLLECTION, KEY_BASIC, _session.user_id)]
#		),
#		"completed"
#	)
#
#	var parsed_result := _exception_handler.parse_exception(storage_objects)
#	var character := {}
#	if parsed_result != OK or storage_objects.objects.size() == 0:
#		return character
#
#	var decoded: Dictionary = JSON.parse(storage_objects.objects[0].value).result
#	character["name"] = decoded.name
#	character["color"] = Converter.color_string_to_color(decoded.color)
#
#	var characters: Array = yield(get_user_basic_async(), "completed")
#	for c in characters:
#		if c.name == character["name"]:
#			return character
#	return {}
#
#
## Asynchronous coroutine. Put the last logged in character into player storage on the server.
## Returns OK, or a nakama error code.
#func store_last_user_basic_async(name: String, color: Color) -> int:
#	var character := {name = name, color = JSON.print(color)}
#	var result: NakamaAPI.ApiStorageObjectAcks = yield(
#		_client.write_storage_objects_async(
#			_session,
#			[
#				NakamaWriteStorageObject.new(
#					COLLECTION,
#					KEY_BASIC,
#					ReadPermissions.OWNER_READ,
#					WritePermissions.OWNER_WRITE,
#					JSON.print(character),
#					""
#				)
#			]
#		),
#		"completed"
#	)
#	var parsed_result := _exception_handler.parse_exception(result)
#	return parsed_result


# Helper class to convert values from the server into Godot values.
class Converter:
	# Turns a string in the format `"r,g,b,a"` to a Color. Alpha is skipped.
	static func color_string_to_color(color_string: String) -> Color:
		var color_values := color_string.replace('"', '').split(",")
		return Color(float(color_values[0]), float(color_values[1]), float(color_values[2]))
