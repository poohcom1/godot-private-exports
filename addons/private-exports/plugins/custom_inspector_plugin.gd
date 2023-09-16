@tool
extends EditorInspectorPlugin

const Core := preload("../lib/core.gd")


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
	return not Core.is_property_visible(object, name)
