## Deals with the metadata setting and retrieval

const _MetaKey = "_access_modifiers"

enum AccessModifier {
	Public = 0,
	Protected = 1,
	Private = 2,
}

const AccessModifierNames = [
	"Public",
	"Protected",
	"Private",
]


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


static func set_access_modifier(object: Object, property: StringName, modifier: AccessModifier):
	var access_modifiers = object.get_meta(_MetaKey, {})

	access_modifiers[property] = modifier

	object.set_meta(_MetaKey, access_modifiers)


static func get_access_modifier(object: Object, property: StringName) -> AccessModifier:
	var object_metadata = object.get_meta(_MetaKey, {})

	if property in object_metadata:
		return object_metadata[property]

	var parent_metadatas := _get_parent_metadatas(object as Node)

	for metadata in parent_metadatas:
		if property in metadata and metadata[property]:
			return metadata[property]

	return AccessModifier.Public


static func is_property_visible(object: Object, property: StringName) -> bool:
	if object == EditorInterface.get_edited_scene_root():
		# Check scene parents
		var metadatas = _get_parent_metadatas(object)

		for metadata in metadatas:
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

		return false


static func is_current_property_owner(property: StringName) -> bool:
	var parent_scripts := _get_parent_scripts(EditorInterface.get_edited_scene_root())

	for script in parent_scripts:
		for prop in script.get_script_property_list():
			if prop[&"name"] == property:
				return false

	return true


## Utils
static var _cached_script: Script = null
static var _cached_scene: String


static func _get_script(node: Node) -> Script:
	var scene_path = node.scene_file_path

	if scene_path.is_empty():
		return null

	#if scene_path == _cached_scene and _cached_script:
	#	return _cached_script

	var packed_scene: PackedScene = load(node.scene_file_path)

	if not packed_scene:
		return null

	var scene_state = packed_scene.get_state()

	for i in scene_state.get_node_property_count(0):
		if scene_state.get_node_property_name(0, i) == &"script":
			_cached_script = scene_state.get_node_property_value(0, i)
			break

	_cached_scene = scene_path

	return _cached_script


#static var _cached_scene_hierarchy: Array[PackedScene] = []
static var _cached_scene_metadata: Array[Dictionary] = []


static func _get_parent_metadatas(node: Node) -> Array[Dictionary]:
	var scene_path = node.scene_file_path

	if scene_path.is_empty():
		return []

	#if scene_path == _cached_scene and not _cached_scene_metadata.is_empty():
	#	return _cached_scene_metadata

	# Generate
	_cached_scene_metadata = []

	var parent_scene: PackedScene = load(scene_path).get_state().get_node_instance(0)
	while parent_scene != null:
		#_cached_scene_hierarchy.append(parent_scene)

		var scene_state := parent_scene.get_state()

		for i in scene_state.get_node_property_count(0):
			if scene_state.get_node_property_name(0, i) == &"metadata/%s" % _MetaKey:
				_cached_scene_metadata.append(scene_state.get_node_property_value(0, i))
				break

		parent_scene = scene_state.get_node_instance(0)

	_cached_scene = scene_path

	return _cached_scene_metadata


static func _get_parent_scripts(node: Node) -> Array[Script]:
	if node == null:
		return []

	var scene_path = node.scene_file_path

	if scene_path.is_empty():
		return []

	var parent_scripts: Array[Script] = []

	var parent_scene: PackedScene = load(scene_path).get_state().get_node_instance(0)
	while parent_scene != null:
		var scene_state := parent_scene.get_state()

		for i in scene_state.get_node_property_count(0):
			if scene_state.get_node_property_name(0, i) == &"script":
				parent_scripts.append(scene_state.get_node_property_value(0, i))
				break

		parent_scene = scene_state.get_node_instance(0)

	return parent_scripts
