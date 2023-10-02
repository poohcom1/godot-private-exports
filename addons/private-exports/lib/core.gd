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
	var scenes := _get_scene_data(object as Node)
	var access_modifiers: Dictionary = scenes[0].metadata if scenes.size() > 0 else {}

	var old_access_modifiers: Dictionary = access_modifiers.duplicate()
	access_modifiers[property] = modifier

	undoredo.create_action("Set export access modifier")
	undoredo.add_do_property(object, "metadata/%s" % _MetaKey, access_modifiers)
	undoredo.add_undo_property(object, "metadata/%s" % _MetaKey, old_access_modifiers)
	undoredo.commit_action()


func get_access_modifier(object: Object, property: StringName) -> AccessModifier:
	var scenes := _get_scene_data(object as Node)

	for scene in scenes:
		if property in scene.metadata and scene.metadata[property]:
			return scene.metadata[property]

	return AccessModifier.Public


func is_property_visible(scene_root: Node, object: Object, property: StringName) -> bool:
	var scenes := _get_scene_data(object, scene_root == object)
	if object == scene_root:
		# Check scene parents
		for scene: CachedSceneData in scenes.slice(1):
			if property in scene.metadata:
				var modifier: AccessModifier = scene.metadata[property]
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


func is_current_property_owner(scene_root: Node, property: StringName) -> bool:
	var scenes := _get_scene_data(scene_root)

	# Check current script
	var is_inherited_scene: bool = scenes.size() > 1
	var found := false

	if is_inherited_scene:
		var script = scenes[0].scene_script
		for prop in script.get_script_property_list():
			if prop[&"name"] == property:
				found = true
				break

	if not found and is_inherited_scene:
		return false  # Is a native property and the current script is inherited

	# Check parent scripts
	for i in range(1, scenes.size()):
		var script = scenes[i].scene_script
		if not script:
			continue
		for prop in script.get_script_property_list():
			if prop[&"name"] == property:
				return false

	return true


func is_overwriting_default(scene_root: Node, object: Object, property: StringName) -> bool:
	var scenes := _get_scene_data(object)
	
	if len(scenes) == 0:
		return false
	
	var value = scenes[0].default_values[property]
	
	if object == scene_root:
		return false
	else:
		# Just check the object
		var modifier := get_access_modifier(object, property)
		
		if modifier == AccessModifier.Public:
			return true
		
		return false


## Utils
var _cached_scene_path: String = ""
var _cached_packed_scene: PackedScene = null

func _get_scene_data(node: Node, is_root: bool = false) -> Array[CachedSceneData]:
	if node == null: return []
	var scene_path = node.scene_file_path
	if scene_path.is_empty(): return []
	if scene_path != _cached_scene_path:
		_cached_scene_path = scene_path
		_cached_packed_scene = load(scene_path)

	# Generate
	var scene_data_arr: Array[CachedSceneData] = []
	var scene := _cached_packed_scene
	
	if is_root:
		var current_scene = CachedSceneData.new()
		current_scene.metadata = node.get_meta(_MetaKey)
		current_scene.scene_script = node.get_script()
		current_scene.default_values = {}
		var current_scene_state := _cached_packed_scene.get_state()
		for i in current_scene_state.get_node_property_count(0):
			current_scene.default_values[current_scene_state.get_node_property_name(0, i)] = current_scene_state.get_node_property_value(0, i)

		scene_data_arr.append(current_scene)

		scene = _cached_packed_scene.get_state().get_node_instance(0)

	while scene != null:
		var scene_state := scene.get_state()
		var scene_data := CachedSceneData.new()

		var found_metadata = false
		for i in scene_state.get_node_property_count(0):
			var prop = scene_state.get_node_property_name(0, i)
			var val = scene_state.get_node_property_value(0, i)
			
			if prop == &"metadata/%s" % _MetaKey:
				scene_data.metadata = val
			elif prop == &"script":
				scene_data.scene_script = val
			else:
				scene_data.default_values[prop] = val

		scene = scene_state.get_node_instance(0)
		scene_data_arr.append(scene_data)
	
	# Replace null scripts with the parent script
	var current_script: Script = null
	for i in range(scene_data_arr.size() - 1, -1, -1):
		var script := scene_data_arr[i].scene_script

		if script:
			current_script = script
		else:
			scene_data_arr[i].scene_script = current_script

	return scene_data_arr

class CachedSceneData:
	var scene_script: Script = null
	var metadata := {}
	var default_values := {}
