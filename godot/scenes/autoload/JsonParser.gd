extends Node

# New file used for writing data
onready var file = File.new()


func read_data(url):
	"""Read a josn file as a dictionary"""
	# If the url is invalid, return nothing
	if url == null:
		print('[JsonParser] The URL in JSON parsing is NULL!')
		return null

	# If the file does not exist, return nothing
	if !file.file_exists(url):
		print('[JsonParser] The file does not exist for the URL in JSON parsing!')
		return null
	
	# Open the JSON file
	file.open(url, File.READ)
	
	# Get the JSON result
	var json_result = JSON.parse(file.get_as_text())
	
	# Monitor error message from the JSON processing
	if json_result.error_string != '':
		print('[JsonParser] Error string: ' + json_result.error_string)
		print('[JsonParser] Error on line: ' + str(json_result.error_line))
	
	# Get a dictionary from the JSON result
	var data = json_result.result
	
	# Close the JSON file
	file.close()
	
	return data


func write_data(url, dict):
	"""Load a dictionary as a josn file"""
	# If the url is invalid, return nothing
	if url == null:
		print('[JsonParser] Target directory for writing the JSON file is invalid.')
		return FAILED
	
	# Save the dictionary into a JSON file
	file.open(url, File.WRITE)
	file.store_line(JSON.print(dict))
	file.close()
	
	return OK
