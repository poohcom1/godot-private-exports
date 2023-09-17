## Injects access modifier buttons into the property inspector

const Core := preload("./core.gd")
const Configs := preload("./configs.gd")
const AccessModifierButton := preload("../controls/access_modifier_button.gd")

const AccessModifier = Core.AccessModifier
const DisplayMode = Configs.DisplayMode

const ContainerGroupName = &"__private_exports_containers"
const ButtonGroupName = &"__private_exports_buttons"


var _editor_plugin: EditorPlugin

var _object: Node = null
## Dictionary[StringName, AccessModifierButton]
var _buttons: Dictionary = {}


func _init(editor_plugin: EditorPlugin):
	_editor_plugin = editor_plugin
	EditorInterface.get_inspector().edited_object_changed.connect(_draw)
	EditorInterface.get_editor_settings().settings_changed.connect(_update_buttons)
	
	_editor_plugin.get_undo_redo().version_changed.connect(_update_buttons)


func terminate() -> void:
	EditorInterface.get_inspector().edited_object_changed.disconnect(_draw)
	EditorInterface.get_editor_settings().settings_changed.disconnect(_update_buttons)
	_editor_plugin.get_undo_redo().version_changed.disconnect(_update_buttons)


# Initial Rendering
func _draw():
	Core.invalidate_cache()
	_object = EditorInterface.get_edited_scene_root()
	_buttons = {}
	_find_editor_properties(EditorInterface.get_inspector(), _draw_button)


func _draw_button(editor_property: EditorProperty):
	var object: Object = editor_property.get_edited_object()
	var script: Script = object.get_script()
	var property := editor_property.get_edited_property()
	
	if object != EditorInterface.get_edited_scene_root():
		return

	if script == null:
		return  # Not a custom object

	var is_owner = Core.is_current_property_owner(property)

	var properties = script.get_script_property_list()
	if not properties.any(func(e): return e.name == editor_property.get_edited_property()):
		return  # No custom properties

	var access_modifier = Core.get_access_modifier(object, property)

	# Draw
	var editor_control: Control = editor_property.get_child(0)
	var container: HBoxContainer
	var button := AccessModifierButton.new()
	button.add_to_group(ButtonGroupName)
	button.set_modifier(access_modifier)
	button.changed.connect(
		func(modifier: Core.AccessModifier): 
			Core.set_access_modifier_with_undo(
				_editor_plugin.get_undo_redo(), object, property, modifier
			)
			_update_buttons()
	)
	_buttons[property] = button

	editor_control.size_flags_horizontal = (
		editor_control.size_flags_horizontal | Control.SIZE_EXPAND
	)

	container = HBoxContainer.new()
	container.add_to_group(ContainerGroupName)
	editor_control.reparent(container)
	container.add_child(button)

	editor_property.add_child(container)


	# Display mode
	var display_mode := Configs.get_display_mode()

	button.disabled = not is_owner

	_update_button(button, object, property)

	editor_property.selected.connect(
		func(_path: String, _focusable_idx: int):
			# Hide other buttons
			var buttons = EditorInterface.get_base_control().get_tree().get_nodes_in_group(ButtonGroupName)
			
			for b in buttons:
				if display_mode == DisplayMode.Selected:
					b.hide()
				elif display_mode == DisplayMode.Modified and b.get_modifier() == AccessModifier.Public:
					b.hide()
			
			# Display current button
			if display_mode in [DisplayMode.Modified, DisplayMode.Selected]:
				button.show()
			# Redraw
			container.queue_sort()
	)


# Updating
func _update_button(button: AccessModifierButton, object: Object, property: StringName):
	var display_mode := Configs.get_display_mode()
	var modifier := Core.get_access_modifier(object, property)

	button.set_modifier(modifier)

	if display_mode == DisplayMode.Selected:
		button.hide()
	elif display_mode == DisplayMode.Modified and modifier == AccessModifier.Public:
		button.hide()
	else:
		button.show()


func _update_buttons():
	if not _object: return

	var display_mode := Configs.get_display_mode()
	
	for property in _buttons:
		_update_button(_buttons[property], _object, property)


# Utils
func _find_editor_properties(node: Node, callback: Callable):
	for child in node.get_children():
		if child is EditorProperty:
			callback.call(child)
		elif child.is_class(&"EditorInspectorSection") and _is_empty_section(child):
			child.hide()
		elif child.is_class(&"EditorInspectorCategory") and _is_empty_category(child, node):
			child.hide()
		else:
			_find_editor_properties(child, callback)


func _is_empty_category(category: Node, parent: Node) -> bool:
	for i in range(category.get_index() + 1, parent.get_child_count()):
		var node = parent.get_child(i)

		if node.is_class(&"EditorInspectorCategory"):
			return true
		else:
			for child in node.get_children():
				if child.is_class(&"EditorProperty"):
					return false
				elif not _is_empty_section(child):
					return false

	return false


func _is_empty_section(section: Node) -> bool:
	if section.get_child_count() == 0:
		return true

	for child in section.get_children():
		if child.is_class(&"EditorProperty"):
			return false
		elif not _is_empty_section(child):
			return false
			

	return true
