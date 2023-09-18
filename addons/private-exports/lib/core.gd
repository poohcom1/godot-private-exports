## Core logic for creating

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


func set_access_modifier(
	undoredo: EditorUndoRedoManager, object: Object, property: StringName, modifier: AccessModifier
) -> void:
	var metadatas := _get_modifier_metadatas(object as Node)
	var access_modifiers: Dictionary = metadatas[0] if metadatas.size() > 0 else {}

	var old_access_modifiers: Dictionary = access_modifiers.duplicate()
	access_modifiers[property] = modifier

	undoredo.create_action("Set export access modifier")
	undoredo.add_do_property(object, "metadata/%s" % _MetaKey, access_modifiers)
	undoredo.add_undo_property(object, "metadata/%s" % _MetaKey, old_access_modifiers)
	undoredo.commit_action()


func get_access_modifier(object: Object, property: StringName) -> AccessModifier:
	var metadatas := _get_modifier_metadatas(object as Node)

	for metadata in metadatas:
		if property in metadata and metadata[property]:
			return metadata[property]

	return AccessModifier.Public


func is_property_visible(object: Object, property: StringName) -> bool:
	if object == EditorInterface.get_edited_scene_root():
		# Check scene parents
		var metadatas = _get_modifier_metadatas(object)

		for metadata in metadatas.slice(1):
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


func invalidate_cache():
	_cached_scene_path = ""
	_cached_packed_scene = null


func is_current_property_owner(property: StringName) -> bool:
	var object := EditorInterface.get_edited_scene_root()
	var scripts := _get_scripts(object)

	# Check current script
	var is_inherited_scene: bool = scripts.size() > 1
	var found := false

	if is_inherited_scene:
		var script = scripts[0]
		for prop in script.get_script_property_list():
			if prop[&"name"] == property:
				found = true
				break

	if not found and is_inherited_scene:
		return false  # Is a native property and the current script is inherited

	# Check parent scripts
	for i in range(1, scripts.size()):
		var script = scripts[i]
		for prop in script.get_script_property_list():
			if prop[&"name"] == property:
				return false

	return true


## Utils
var _cached_scene_path: String = ""
var _cached_packed_scene: PackedScene = null


## Returns an array of Dictionary of modifiers for the node and its parents
func _get_modifier_metadatas(node: Node) -> Array[Dictionary]:
	var scene_path = node.scene_file_path

	if scene_path.is_empty():
		return []

	if scene_path != _cached_scene_path:
		_cached_scene_path = scene_path
		_cached_packed_scene = load(scene_path)

	# Generate
	var metadatas: Array[Dictionary] = []
	var scene := _cached_packed_scene

	while scene != null:
		var scene_state := scene.get_state()

		var found = false
		for i in scene_state.get_node_property_count(0):
			if scene_state.get_node_property_name(0, i) == &"metadata/%s" % _MetaKey:
				metadatas.append(scene_state.get_node_property_value(0, i))
				found = true
				break

		if not found:
			metadatas.append({})

		scene = scene_state.get_node_instance(0)

	return metadatas


## Returns an array of scripts for the node and its parents
func _get_scripts(node: Node) -> Array[Script]:
	if node == null:
		return []

	var scene_path = node.scene_file_path

	if scene_path.is_empty():
		return []

	if scene_path != _cached_scene_path:
		_cached_scene_path = scene_path
		_cached_packed_scene = load(scene_path)

	var scripts: Array[Script] = []

	var scene: PackedScene = _cached_packed_scene
	while scene != null:
		var scene_state := scene.get_state()

		var found = false
		for i in scene_state.get_node_property_count(0):
			if scene_state.get_node_property_name(0, i) == &"script":
				scripts.append(scene_state.get_node_property_value(0, i))
				found = true
				break

		if not found:
			scripts.append(null)

		scene = scene_state.get_node_instance(0)

	# Replace nulls with the parent script
	var current_script: Script = null
	for i in range(scripts.size() - 1, -1, -1):
		var script := scripts[i]

		if script:
			current_script = script
		else:
			scripts[i] = current_script

	return scripts
