class_name edir

# https://www.davidepesce.com/?p=1365
static func remove_recursive(path: String) -> void:
	var directory := DirAccess.open(path)
	# Open directory
	var error := DirAccess.get_open_error()
	if error == OK:
		directory.include_hidden = true
		# List directory content
		directory.list_dir_begin()
		var file_name := directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				remove_recursive(path + "/" + file_name)
			else:
				directory.remove(file_name)
			file_name = directory.get_next()
		
		# Remove current path
		directory.remove(path)
	else:
		Output.push("Error removing " + path)


static func path_is_valid(abs_path: String) -> bool:
	return DirAccess.dir_exists_absolute(abs_path) or FileAccess.file_exists(abs_path)


static func list_recursive(
	path: String, 
	include_hidden := false, 
	result_filter: Variant = null,
	dir_filter: Variant = null,
) -> Array[DirListResult]:
	if not result_filter:
		result_filter = func(x: DirListResult) -> bool: return true
	if not dir_filter:
		dir_filter = func(x: String) -> bool: return true
	var dirs_to_visit: Array[String] = [path]
	var result: Array[DirListResult]
	while len(dirs_to_visit) > 0:
		var dir_to_visit := dirs_to_visit.pop_front() as String
		var directory := DirAccess.open(dir_to_visit)
		var error := DirAccess.get_open_error()
		if error != OK:
			continue
		directory.include_hidden = include_hidden
		directory.include_navigational = false
		directory.list_dir_begin()
		var file_name := directory.get_next()
		while file_name != "":
			var file_path := dir_to_visit.simplify_path() + "/" + file_name
			var item := DirListResult.new(
				file_path, directory.current_is_dir()
			)
			if (result_filter as Callable).call(item):
				result.push_back(item)
			if directory.current_is_dir() and (dir_filter as Callable).call(file_path):
				dirs_to_visit.push_back(file_path)
			file_name = directory.get_next()
	return result


class DirListResult:
	var _path: String
	var _is_dir: bool
	
	var path: String: 
		get: return _path
	
	var is_dir: bool:
		get: return _is_dir
	
	var is_file: bool:
		get: return not _is_dir
	
	var extension: String:
		get: return _path.get_extension()
	
	var file: String:
		get: return _path.get_file()
	
	func _init(path: String, is_dir: bool) -> void:
		_path = path
		_is_dir = is_dir
	
	func _to_string() -> String:
		return _path
