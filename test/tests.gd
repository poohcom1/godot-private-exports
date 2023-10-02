@tool
extends EditorScript

const PluginCore := preload("res://addons/private-exports/lib/core.gd")

const BaseScene := preload("res://test/scenes/base.tscn")
const InheritedScene := preload("res://test/scenes/inherited_scene.tscn")
const ExternalScene := preload("res://test/scenes/external_scene.tscn")

const InheritedScript := preload("res://test/scenes/inherited_script.tscn")

const ExternalBrokenScene := preload("res://test/scenes/external_broken_scene.tscn")
const InheritedBrokenScene := preload("res://test/scenes/inherited_broken_scene.tscn")

var plugin := PluginCore.new()

func _run():
	test_base_scene()
	test_inherited_properties()
	test_external_properties()
	
	test_inherited_script()
	
	test_external_broken_properties()
	test_inherited_broken_properties()
	
	print("Tests finished!")
	

func test_base_scene():
	var root := BaseScene.instantiate()
	
	assert(plugin.is_property_visible(root, root, "public_export") == true, "Public export should be visible")
	assert(plugin.is_property_visible(root, root, "protected_export") == true, "Protected export should be visible")
	assert(plugin.is_property_visible(root, root, "private_export") == true, "Protected export should be visible")
	
	assert(plugin.is_current_property_owner(root, "public_export") == true, "Base should own public_export")
	assert(plugin.is_current_property_owner(root, "protected_export") == true, "Base should own protected_export")
	assert(plugin.is_current_property_owner(root, "private_export") == true, "Base should own private_export")

func test_inherited_properties():
	var root := InheritedScene.instantiate()
	
	assert(plugin.is_property_visible(root, root, "public_export") == true, "Public export should be visible")
	assert(plugin.is_property_visible(root, root, "protected_export") == true, "Protected export should be visible")
	assert(plugin.is_property_visible(root, root, "private_export") == false, "Protected export should not be visible")
	
	assert(plugin.is_current_property_owner(root, "public_export") == false, "Inherited should not own public_export")
	assert(plugin.is_current_property_owner(root, "protected_export") == false, "Inherited should not own protected_export")
	assert(plugin.is_current_property_owner(root, "private_export") == false, "Inherited should own not private_export")

func test_inherited_script():
	var root := InheritedScript.instantiate()
	
	assert(plugin.is_current_property_owner(root, "inherited_public_export") == true, "Inherited should own inherited_public_export")
	assert(plugin.is_current_property_owner(root, "inherited_protected_export") == true, "Inherited should own inherited_protected_export")
	assert(plugin.is_current_property_owner(root, "inherited_private_export") == true, "Inherited should own inherited_private_export")


func test_external_properties():
	var root := ExternalScene.instantiate()
	var base = root.get_node("Base")
	
	assert(plugin.is_property_visible(root, base, "public_export") == true, "Public export should be visible")
	assert(plugin.is_property_visible(root, base, "protected_export") == false, "Protected export should not be visible")
	assert(plugin.is_property_visible(root, base, "private_export") == false, "Protected export should not be visible")

func test_external_broken_properties():
	var root := ExternalBrokenScene.instantiate()
	var base = root.get_node("Base")
	
	assert(plugin.is_overwriting_default(root, base, "public_export") == false, "Non-modified public value on external base should not be detected")
	assert(plugin.is_overwriting_default(root, base, "protected_export") == true, "Non-modified protected on external base value should be detected")
	assert(plugin.is_overwriting_default(root, base, "private_export") == true, "Modified private value on external base should be detected")

	var inherited = root.get_node("Inherited")
	assert(plugin.is_overwriting_default(root, inherited, "public_export") == false, "Modified public value on external inherited should not be detected")
	assert(plugin.is_overwriting_default(root, inherited, "protected_export") == true, "Modified protected value on external inherited should be detected")
	assert(plugin.is_overwriting_default(root, inherited, "private_export") == true, "Modified private value on external inherited should be detected")

func test_inherited_broken_properties():
	var root := InheritedBrokenScene.instantiate()
	
	assert(plugin.is_overwriting_default(root, root, "public_export") == false, "Non-modified public value on inheritedbase should not be detected")
	assert(plugin.is_overwriting_default(root, root, "protected_export") == false, "Non-modified protected on inherited value should not be detected")
	assert(plugin.is_overwriting_default(root, root, "private_export") == true, "Modified private value on inherited should be detected")

