## All protected and private exports are broken (i.e. they have an overwritten value)
extends GdUnitTestSuite

const Base := preload("res://test/scenes/base.gd")

const Plugin := preload("res://addons/private-exports/lib/core.gd")
const ExternalBrokenScene := preload("res://test/scenes/external_broken_scene.tscn")

var plugin := Plugin.new()
var scene: Node
var base_node: Node
var inherited_node: Node

func before():
	scene = auto_free(ExternalBrokenScene.instantiate())
	base_node = auto_free(scene.get_node("Base"))
	inherited_node = auto_free(scene.get_node("Inherited"))
	
# Overwrite
func test_public_export_overwrite():
	assert_bool(plugin.is_overwriting_default(scene, base_node, &"public_export")).is_false()
func test_protected_export_overwrite(do_skip=true, skip_reason="Script.get_property_default_value does not work outside of editor context"):
	assert_bool(plugin.is_overwriting_default(scene, base_node, &"protected_export")).is_true()
func test_private_export_overwrite(do_skip=true):
	assert_bool(plugin.is_overwriting_default(scene, base_node, &"private_export")).is_true()

func test_inherited_public_export_overwrite():
	assert_bool(plugin.is_overwriting_default(scene, inherited_node, &"public_export")).is_false()
func test_inherited_protected_export_overwrite(do_skip=true):
	assert_bool(plugin.is_overwriting_default(scene, inherited_node, &"protected_export")).is_true()
func test_inherited_private_export_overwrite(do_skip=true):
	assert_bool(plugin.is_overwriting_default(scene, inherited_node, &"private_export")).is_true()
