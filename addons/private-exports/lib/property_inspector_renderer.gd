## Injects access modifier buttons into the property inspector

const Core := preload("./core.gd")
const Configs := preload("./configs.gd")
const AccessModifierButton := preload("../controls/access_modifier_button.gd")

const AccessModifier = Core.AccessModifier
const DisplayMode = Configs.DisplayMode

var _editor_plugin: EditorPlugin
var _core: Core

var _object: Node = null
## Dictionary[StringName, AccessModifierButton]
var _buttons: Dictionary = {}
func _init(editor_plugin: EditorPlugin, core: Core):
	_editor_plugin = editor_plugin
	_core = core
	EditorInterface.get_inspector().edited_object_changed.connect(_draw)
	EditorInterface.get_editor_settings().settings_changed.connect(_update_buttons)
	
	_editor_plugin.get_undo_redo().version_changed.connect(_update_buttons)

	_draw()


func terminate() -> void:
	EditorInterface.get_inspector().edited_object_changed.disconnect(_draw)
	EditorInterface.get_editor_settings().settings_changed.disconnect(_update_buttons)
	_editor_plugin.get_undo_redo().version_changed.disconnect(_update_buttons)

	EditorInterface.inspect_object(null)
	EditorInterface.inspect_object(_object)


# Initial Rendering
func _draw():
	_core.invalidate_cache()
	_object = EditorInterface.get_edited_scene_root()
	_buttons = {}
	_find_editor_properties(EditorInterface.get_inspector(), _draw_button)


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


## @experimental
## Hacky solution to inject button in the EditorProperty Control
func _draw_button(editor_property: EditorProperty):
	var object: Object = editor_property.get_edited_object()
	if not object is Node:
		return # Ignore Resources
	var property := editor_property.get_edited_property()
	
	if object != EditorInterface.get_edited_scene_root():
		return
	
	var is_owner = _core.is_current_property_owner(EditorInterface.get_edited_scene_root(), property)

	var access_modifier = _core.get_access_modifier(object, property)

	# Draw
	var has_bottom_editor = _has_bottom_editor(editor_property) 
	
	var property_control: Control = editor_property.get_child(0)
	var container: HBoxContainer
	var button := AccessModifierButton.new()

	button.set_modifier(access_modifier)
	button.changed.connect(
		func(modifier: Core.AccessModifier): 
			_core.set_access_modifier(
				_editor_plugin.get_undo_redo(), object, property, modifier
			)
			_update_button(button, object, property)
	)
	_buttons[property] = button

	property_control.size_flags_horizontal = (
		property_control.size_flags_horizontal | Control.SIZE_EXPAND
	)

	container = HBoxContainer.new()

	editor_property.add_child(container)
	if has_bottom_editor:
		if object.get(editor_property.get_edited_property()) is Resource:
			editor_property.move_child(container, 0)
		else:
			editor_property.set_bottom_editor(container)
			
	property_control.reparent(container)
	container.add_child(button)

	# Display mode
	var display_mode := Configs.get_display_mode()

	button.disabled = not is_owner

	_update_button(button, object, property)

	editor_property.selected.connect(
		func(_path: String, _focusable_idx: int):
			# Hide other buttons
			for b in _buttons.values():
				if display_mode == DisplayMode.Selected:
					b.hide()
				elif display_mode == DisplayMode.Modified and b.get_modifier() == AccessModifier.Public:
					b.hide()
			
			# Display current button
			if display_mode in [DisplayMode.Modified, DisplayMode.Selected]:
				button.show()
	)


# Updating
func _update_button(button: AccessModifierButton, object: Object, property: StringName):
	var display_mode := Configs.get_display_mode()
	var modifier := _core.get_access_modifier(object, property)

	button.set_modifier(modifier)

	if display_mode == DisplayMode.Selected:
		button.hide()
	elif display_mode == DisplayMode.Modified and modifier == AccessModifier.Public:
		button.hide()
	else:
		button.show()


func _update_buttons():
	var display_mode := Configs.get_display_mode()
	
	for property in _buttons:
		_update_button(_buttons[property], _object, property)


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


# Utils

## @experimental
## Hacky solution to detect if an EditorProperty has a bottom editor
## by reverse engineering how it's min-size.
##
## See [url=https://github.com/godotengine/godot/blob/e3e2528ba7f6e85ac167d687dd6312b35f558591/editor/editor_inspector.cpp#L66-L116]editor/editor_inspector.cpp[/url]
## for the code that is being referenced.
func _has_bottom_editor(editor_property: EditorProperty) -> bool:
	if editor_property.get_child_count() == 0: return false
	
	var expected_minsize: Vector2
	
	var font := editor_property.get_theme_font(&"font", &"Tree")
	var font_size := editor_property.get_theme_font_size(&"font_size", &"Tree")
	expected_minsize.y = font.get_height(font_size) + 4 * EditorInterface.get_editor_scale()
	
	for child in editor_property.get_children():
		if not child is Control: continue
		if child.is_set_as_top_level(): continue
		if not child.visible: continue
		
		var minsize = child.get_combined_minimum_size()
		expected_minsize.x = max(expected_minsize.x, minsize.x)
		expected_minsize.y = max(expected_minsize.y, minsize.y)
	
	var hseparator := editor_property.get_theme_constant(&"hseparator", &"Tree")
	if editor_property.keying:
		var key := editor_property.get_theme_icon(&"Key", &"EditorIcons")
		expected_minsize.x += key.get_width() + hseparator
	
	if editor_property.deletable:
		var key := editor_property.get_theme_icon(&"Close", &"EditorIcons")
		expected_minsize.x += key.get_width() + hseparator
		
	if editor_property.checkable:
		var key := editor_property.get_theme_icon(&"checked", &"CheckBox")
		var h_separation := editor_property.get_theme_constant(&"h_separation", &"CheckBox")
		
		expected_minsize.x += key.get_width() + hseparator
	
	return expected_minsize != editor_property.get_minimum_size()
