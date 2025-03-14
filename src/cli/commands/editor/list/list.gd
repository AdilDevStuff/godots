class_name EditorListCommand


class Route extends Routes.Item:
	var _ctx: CliContext

	func _init(ctx: CliContext) -> void:
		_ctx = ctx

	func route(cmd: CliParser.ParsedCommandResult, user_args: PackedStringArray) -> void:
		EditorListCommand.new(_ctx.editors).execute(Request.new())

	func match(cmd: CliParser.ParsedCommandResult, user_args: PackedStringArray) -> bool:
		return cmd.verb == "list"


class Request:
	pass


var _editors: LocalEditors.List


func _init(editors: LocalEditors.List) -> void:
	_editors = editors


func execute(req: Request) -> void:
	Output.push("\n".join(_editors.all()))
