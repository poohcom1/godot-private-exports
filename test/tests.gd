@tool
extends EditorScript

const PluginCore := preload("res://addons/private-exports/lib/core.gd")

const BaseScene := preload("res://test/scenes/base.tscn")
const InheritedScene := preload("res://test/scenes/inherited_scene.tscn")
const ExternalScene := preload("res://test/scenes/external_scene.tscn")

const ExternalBrokenScene := preload("res://test/scenes/external_broken_scene.tscn")

var plugin := PluginCore.new()

func _run():
	test_base_scene()
	test_inherited_properties()
	test_external_properties()
	
	test_external_broken_properties()
	
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
	
	assert(plugin.is_property_visible(root, base, "private_export") == true, "Broken properties should be visible")
