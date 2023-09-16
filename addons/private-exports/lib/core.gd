## Deals with the metadata setting and retrieval

const _MetaKey = "_access_modifiers"

enum AccessModifier {
	Public = 0,
	Protected = 1,
	Private = 2,
}


static func set_access_modifier_with_undo(
	undoredo: EditorUndoRedoManager, object: Object, property: StringName, modifier: AccessModifier
) -> void:
	var access_modifiers: Dictionary = object.get_meta(_MetaKey, {})

	var old_access_modifiers: Dictionary = access_modifiers.duplicate()
	access_modifiers[property] = modifier

	undoredo.create_action("Set export access modifier")
	undoredo.add_do_property(object, "metadata/%s" % _MetaKey, access_modifiers)
	undoredo.add_undo_property(object, "metadata/%s" % _MetaKey, old_access_modifiers)
	undoredo.commit_action()

	set_access_modifier(object, property, modifier)


static func set_access_modifier(object: Object, property: StringName, modifier: AccessModifier):
	var access_modifiers = object.get_meta(_MetaKey, {})

	access_modifiers[property] = modifier

	object.set_meta(_MetaKey, access_modifiers)


static func get_access_modifier(object: Object, property: StringName) -> AccessModifier:
	var metadatas := _get_scene_metadatas(object as Node)

	for metadata in metadatas:
		if property in metadata and metadata[property]:
			return metadata[property]

	return AccessModifier.Public


static func is_property_visible(object: Object, property: StringName) -> bool:
	if object == EditorInterface.get_edited_scene_root():
		# Check scene parents
		var metadatas = _get_scene_metadatas(object)

		for i in range(1, metadatas.size()):
			var metadata = metadatas[i]
			if property in metadata:
				var modifier: AccessModifier = metadata[property]
				if modifier == AccessModifier.Private:
					return false

		return true
	else:
		# Just check the object
		var modifier := get_access_modifier(object, property)

		if modifier == AccessModifier.Public:
			return true

		if modifier == AccessModifier.Private and EditorInterface.get_edited_scene_root() == object:
			return true

		return false


static func is_current_property_owner(property: StringName) -> bool:
	var script: Script = _get_script(EditorInterface.get_edited_scene_root())
	if not script:
		return true

	var parent := script.get_base_script()
	if not parent:
		return true

	for prop in parent.get_script_property_list():
		if prop[&"name"] == property:
			return false

	return true


## Utils
static var _cached_script: Script = null
static var _cached_scene: String


static func _get_script(node: Node) -> Script:
	var scene_path = node.scene_file_path

	#if scene_path == _cached_scene and _cached_script:
	#	return _cached_script

	var packed_scene: PackedScene = load(node.scene_file_path)
	var scene_state = packed_scene.get_state()

	for i in scene_state.get_node_property_count(0):
		if scene_state.get_node_property_name(0, i) == &"script":
			_cached_script = scene_state.get_node_property_value(0, i)
			break

	_cached_scene = scene_path

	return _cached_script


#static var _cached_scene_hierarchy: Array[PackedScene] = []
static var _cached_scene_metadata: Array[Dictionary] = []


static func _get_scene_metadatas(node: Node) -> Array[Dictionary]:
	var scene_path = node.scene_file_path

	if scene_path.is_empty():
		return []

	#if scene_path == _cached_scene and not _cached_scene_metadata.is_empty():
	#	return _cached_scene_metadata

	# Generate
	_cached_scene_metadata = []

	var current_scene: PackedScene = load(scene_path)

	while current_scene != null:
		#_cached_scene_hierarchy.append(current_scene)

		var scene_state := current_scene.get_state()

		for i in scene_state.get_node_property_count(0):
			if scene_state.get_node_property_name(0, i) == &"metadata/%s" % _MetaKey:
				_cached_scene_metadata.append(scene_state.get_node_property_value(0, i))
				break

		current_scene = scene_state.get_node_instance(0)

	_cached_scene = scene_path

	return _cached_scene_metadata
