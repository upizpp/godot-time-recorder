@tool
extends Control
class_name TimeRecorder


const ProjectNowTemplate = "当前时间:\n%s"
const ProjectPastTemplate = "项目创建时间：\n%s"
const ProjectUsedTemplate = "项目编辑时间：\n%s"
const CurrentScriptTemplate = "当前脚本：\n%s"
const ScriptUsedTemplate = "脚本编辑时间：\n%s"
const GodotPastTemplate = "引擎开始时间：\n%s"
const GodotUsedTemplate = "引擎用时间：\n%s"

const ProjectDataPath = "res://code_time_recorder.json"

const keys: Array[String] = [
	"year", "month", "day", "hour", "minute", "second"
]
const translated_keys: Array[String] = [
	"年", "月", "日", "小时", "分钟", "秒"
]
const advance_rates: Array[int] = [
	0xffffffffffff, 12, 30, 24, 60, 60
]


@onready var project_now: Label = $VBoxContainer/ProjectNow
@onready var project_past: Label = $VBoxContainer/ProjectPast
@onready var project_used: Label = $VBoxContainer/ProjectUsed
@onready var current_script: Label = $VBoxContainer/CurrentScript
@onready var script_used: Label = $VBoxContainer/ScriptUsed
@onready var godot_past: Label = $VBoxContainer/GodotPast
@onready var godot_used: Label = $VBoxContainer/GodotUsed
@onready var todo_list: VBoxContainer = $VBoxContainer/TodoList


var project_data: Dictionary
var godot_data: Dictionary
var interface: EditorInterface
var initial_time: String
var current_script_path: String
var temp_time: String = _get_time()


## 初始化。
func init(interface_: EditorInterface) -> void:
	interface = interface_
	interface.get_script_editor().editor_script_changed.connect(_on_script_changed)
	_on_script_changed(interface.get_script_editor().get_current_script())
	
	todo_list.init(project_data.todo_list, project_data.todo_state)


func _enter_tree() -> void:
	initial_time = _get_time()


func _exit_tree() -> void:
	save_datas()


func _ready() -> void:
	project_data = _get_project_data()
	godot_data = _get_godot_data()
	
	update_now()
	update_past()


func _get_godot_default_data() -> Dictionary:
	return {
		"time": _get_time(),
		"edited_time": _get_empty_time()
	}


func _get_project_default_data() -> Dictionary:
	return {
		"time": _get_time(),
		"scripts": {},
		"edited_time": _get_empty_time()
	}


func _get_empty_time() -> Dictionary:
	var result := {}
	for key in keys:
		result[key] = 0
	return result


func _get_godot_data() -> Dictionary:
	var data_path := _get_godot_data_path()
	var json: JSON
	if not FileAccess.file_exists(data_path):
		json = JSON.new()
		json.data = _get_godot_default_data()
		ResourceSaver.save(json, data_path)
	json = load(data_path)
	return json.data


func _get_project_data() -> Dictionary:
	var data_path := ProjectDataPath
	var json: JSON
	if not FileAccess.file_exists(data_path):
		json = JSON.new()
		json.data = _get_project_default_data()
		ResourceSaver.save(json, data_path)
	json = load(data_path)
	return json.data


func _get_godot_data_path() -> String:
	return ProjectSettings.globalize_path("user://").get_base_dir().get_base_dir().get_base_dir().path_join("code_time_recorder.json")


func _get_time() -> String:
	return Time.get_datetime_string_from_system(false, true)


func _get_string_time_delta(a: String, b: String) -> Dictionary:
	return _get_dict_time_delta(Time.get_datetime_dict_from_datetime_string(a, false), Time.get_datetime_dict_from_datetime_string(b, false))


func _get_dict_time_delta(at: Dictionary, bt: Dictionary) -> Dictionary:
	var ct := {}
	for i in keys.size():
		var key := keys[i]
		ct[key] = at[key] - bt[key]
		while ct[key] < 0:
			ct[key] = ct[key] + advance_rates[i]
			ct[keys[i - 1]] -= 1
	return ct


func _get_dict_time_sum(at: Dictionary, bt: Dictionary) -> Dictionary:
	var ct := _get_empty_time()
	for i in keys.size():
		var key := keys[i]
		ct[key] = at[key] + bt[key]
		if ct[key] > advance_rates[i]:
			ct[key] = ct[key] - advance_rates[i]
			ct[keys[i - 1]] += 1
	return ct


func _get_date_string(dict: Dictionary):
	var result := ""
	for i in keys.size():
		if dict[keys[i]] != 0:
			result += str(dict[keys[i]]) + translated_keys[i]
	if result.is_empty():
		result = "0" + translated_keys.back()
	return result


## 保存数据。
func save_datas() -> void:
	var now := _get_time()
	project_data.edited_time = _get_dict_time_sum(
		project_data.edited_time,
		_get_string_time_delta(now, initial_time)
	)
	godot_data.edited_time = _get_dict_time_sum(
		godot_data.edited_time,
		_get_string_time_delta(now, initial_time)
	)
	
	project_data.todo_list = todo_list.get_todo_list()
	project_data.todo_state = todo_list.get_buttons_state()
	
	var json_project := JSON.new()
	json_project.data = project_data
	ResourceSaver.save(json_project, ProjectDataPath)
	
	var json_godot := JSON.new()
	json_godot.data = godot_data
	ResourceSaver.save(json_godot, _get_godot_data_path())


## 更新过去时间。
func update_past() -> void:
	project_past.text = ProjectPastTemplate % project_data.time
	godot_past.text = GodotPastTemplate % godot_data.time

## 更新当前时间。
func update_now() -> void:
	var now := _get_time()
	var now_dict := Time.get_datetime_dict_from_system()
	project_now.text = ProjectNowTemplate % now
	
	project_used.text = ProjectUsedTemplate % _get_date_string(_get_dict_time_sum(
		project_data.edited_time,
		_get_string_time_delta(now, initial_time)
	))
	godot_used.text = GodotUsedTemplate % _get_date_string(_get_dict_time_sum(
		godot_data.edited_time,
		_get_string_time_delta(now, initial_time)
	))
	
	if not current_script_path.is_empty():
		script_used.text = ScriptUsedTemplate % _get_date_string(_get_dict_time_sum(
			project_data.scripts[current_script_path],
			_get_string_time_delta(now, temp_time)
		))


func _on_script_changed(script: Script):
	if not script:
		return
	
	var now := _get_time()
	if not current_script_path.is_empty():
		project_data.scripts[current_script_path] = _get_dict_time_sum(
			project_data.scripts[current_script_path],
			_get_string_time_delta(now, temp_time)
		)
	var path := script.resource_path
	current_script_path = path
	
	if not project_data.scripts.has(path):
		project_data.scripts[path] = _get_empty_time()
	temp_time = now
	
	script_used.text = ScriptUsedTemplate % _get_date_string(_get_dict_time_sum(
		project_data.scripts[current_script_path],
		_get_string_time_delta(now, temp_time)
	))
	
	current_script.text = CurrentScriptTemplate % path


func _on_timer_timeout() -> void:
	update_now()
