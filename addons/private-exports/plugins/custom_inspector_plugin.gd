@tool
extends EditorInspectorPlugin

const Core := preload("../lib/core.gd")

var _core: Core

func _init(core: Core):
	_core = core


func _can_handle(object: Object) -> bool:
	return object.get_script() != null


func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint_type: PropertyHint,
	hint_string: String,
	usage_flags: int,
	wide: bool
) -> bool:
	var visible := _core.is_property_visible(EditorInterface.get_edited_scene_root(), object, name)
	
	if not visible and _core.is_overwriting_default(EditorInterface.get_edited_scene_root(), object, name):
		push_warning("[Private Exports] %s.%s is a non-public property, but its value has been modified." % [object.name, name])
		return false
	
	return not visible
