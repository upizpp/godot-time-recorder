@tool
extends VBoxContainer


const TodoScene = preload("res://addons/code-time-recorder/dock_slot/todo.tscn")


@onready var list: VBoxContainer = $PanelContainer/List
@onready var hide_button: CheckBox = $HBoxContainer/HBoxContainer/HideButton


func init(list: Array, state: bool):
	hide_button.button_pressed = state
	for todo_info in list:
		var todo := add_todo()
		todo.hide_edit()
		todo.set_text(todo_info[0])
		todo.set_finished(todo_info[1])
	hide_button.pressed.emit()


func get_todo_list() -> Array:
	var result := []
	for child in list.get_children(false):
		result.push_back([
			child.get_text(),
			child.is_finished()
		])
	return result


func add_todo() -> Todo:
	var todo := TodoScene.instantiate()
	list.add_child(todo)
	if hide_button.button_pressed:
		todo.show_buttons()
		todo.show_edit()
	else:
		todo.hide_buttons()
	return todo


func hide_buttons() -> void:
	for child in list.get_children(false):
		child.hide_buttons()


func show_buttons() -> void:
	for child in list.get_children(false):
		child.show_buttons()


func get_buttons_state() -> bool:
	return hide_button.button_pressed


func _on_add_button_pressed() -> void:
	add_todo()


func _on_hide_button_pressed() -> void:
	if hide_button.button_pressed:
		show_buttons()
	else:
		hide_buttons()
