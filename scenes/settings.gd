@tool
extends Button

@export var settings_res: GenerationSettings = preload("res://scripts/WorldGen/generation_settings.gd").new()
var property_type := {}
@onready var panel: GridContainer = %SettingsPanel

func _ready() -> void:
	_build_settings_ui(settings_res)

func _build_settings_ui(res: Resource) -> void:
	for child in %SettingsPanel.get_children():
		child.queue_free()
	var process = false
	for prop:Dictionary in res.get_property_list():
		if prop.name.to_lower() == "script":
			process = true
			continue
		if !process:
			continue
		if not prop.has("usage") or prop.usage & PROPERTY_USAGE_EDITOR == 0:
			continue
		var control: Control = _make_control_for_type(prop)
		if !control:
			continue
		var label := Label.new()
		label.text = prop.name.capitalize()
		panel.add_child(label)
		panel.add_child(control)
		_connect_control(control,prop.name)


func _make_control_for_type(prop: Dictionary) -> Control:
	var val = %WorldGenerator.settings.get(prop.name)
	property_type[prop.name] = prop.type 
	var control: Control
	if prop.hint == PROPERTY_HINT_ENUM:
		control = OptionButton.new()
		var entries = prop.hint_string.split(",")
		for entry in entries:
			var parts = entry.strip_edges().split(":")
			if parts.size() == 2:
				control.add_item(parts[0].capitalize(), int(parts[1]))
				continue
			control.add_item(parts[0])
		control.select(int(val))
		return control

	if prop.type == TYPE_BOOL:
		control = CheckBox.new()
		control.button_pressed = val
		return control

	if (prop.type == TYPE_INT or 
		prop.type == TYPE_FLOAT or 
		prop.type == TYPE_STRING):
			control = LineEdit.new()
			control.text = str(val)
			return control
	return null


func _connect_control(control: Control, prop_name: String) -> void:
	if control is CheckBox:
		control.toggled.connect(func(p): update_value(prop_name, p))
		return
	if control is HSlider:
		control.value_changed.connect(func(v): update_value(prop_name, v))
		return
	if control is LineEdit:
		control.text_changed.connect(func(t): update_value(prop_name, t))
		return
	if control is OptionButton:
		control.item_selected.connect(func(idx):
			update_value(prop_name, control.get_item_id(idx))
		)
		return


func update_value(prop_name,new_value):
	match property_type[prop_name]:
		TYPE_BOOL:
			new_value = bool(new_value)
		TYPE_INT:
			new_value = int(new_value)
		TYPE_FLOAT:
			new_value = float(new_value)
		TYPE_STRING:
			new_value = str(new_value)
	%WorldGenerator.settings.set(prop_name, new_value)


func _on_pressed() -> void:
	%SettingsPanel.visible = button_pressed


func _on_default_pressed() -> void:
	var default_settings:GenerationSettings = load("res://Resources/GenerationSettings/default.tres").get_script().new()
	%WorldGenerator.settings = default_settings
	%WorldGenerator.settings.map_seed = default_settings.map_seed
	#%WorldGenerator.load_map()
	%Settings._ready()
	_build_settings_ui(default_settings)
