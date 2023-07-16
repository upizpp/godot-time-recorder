@tool
extends HBoxContainer
class_name Todo


@onready var name_label: Label = $Name
@onready var rename_edit: LineEdit = $RenameEdit
@onready var rename_buttons: HBoxContainer = $RenameButtons
@onready var edit_button: Button = $Edit
@onready var check_box: CheckBox = $CheckBox
@onready var remove_button: Button = $Remove


## 显示交互按钮。
func show_buttons():
	hide_edit()
	remove_button.show()

## 隐藏交互按钮。
func hide_buttons():
	edit_button.hide()
	rename_buttons.hide()
	remove_button.hide()


## 显示重命名编辑器。
func show_edit():
	name_label.hide()
	rename_edit.show()
	rename_edit.text = name_label.text
	rename_edit.select_all()
	rename_edit.grab_focus.call_deferred()
	rename_buttons.show()
	edit_button.hide()

## 设置TODO内容。
func set_text(text: String):
	name_label.text = text

## 获取TODO内容
func get_text():
	return name_label.text

## 设置是否完成。
func set_finished(finished: bool):
	check_box.button_pressed = finished

## 获取否完成。
func is_finished():
	return check_box.button_pressed

## 重命名。
func rename(to: String):
	if to.is_empty():
		queue_free()
		return
	
	name_label.text = to
	hide_edit()

## 隐藏重命名编辑器。
func hide_edit():
	name_label.show()
	rename_edit.hide()
	rename_buttons.hide()
	edit_button.show()


func _on_edit_pressed() -> void:
	show_edit()


func _on_rename_edit_focus_exited() -> void:
	if (not rename_buttons.get_child(0).is_hovered() and
		not rename_buttons.get_child(1).is_hovered()):
		hide_edit()


func _on_rename_edit_text_submitted(new_text: String) -> void:
	rename(new_text)


func _on_confim_pressed() -> void:
	rename(rename_edit.text)


func _on_close_pressed() -> void:
	hide_edit()


func _on_remove_pressed() -> void:
	queue_free()
