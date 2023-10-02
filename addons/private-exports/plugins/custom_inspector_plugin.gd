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
	return not _core.is_property_visible(EditorInterface.get_edited_scene_root(), object, name)
