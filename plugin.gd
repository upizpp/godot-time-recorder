@tool
extends EditorPlugin


const Recorder = preload("res://addons/code-time-recorder/dock_slot/recorder.tscn")

var recorder: Control

func _enter_tree() -> void:
	recorder = Recorder.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UR, recorder)
	recorder.init(get_editor_interface())


func _exit_tree() -> void:
	remove_control_from_docks(recorder)
	if recorder:
		recorder.queue_free()
