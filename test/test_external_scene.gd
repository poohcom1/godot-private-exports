extends GdUnitTestSuite

const Plugin := preload("res://addons/private-exports/lib/core.gd")
const ExternalScene := preload("res://test/scenes/external_scene.tscn")

var plugin := Plugin.new()
var scene: Node
var base_node: Node
var inherited_node: Node

func before():
	scene = auto_free(ExternalScene.instantiate())
	base_node = auto_free(scene.get_node("Base"))
	inherited_node = auto_free(scene.get_node("Inherited"))

# Base
func test_base_export_visibility(property, expected, test_parameters = [
	[&"public_export", true],
	[&"protected_export", false],
	[&"private_export", false],
]):
	assert_bool(plugin.is_property_visible(scene, base_node, property)).is_equal(expected)

func test_base_ownership(property, expected, test_parameters = [
	[&"public_export", true],
	[&"protected_export", true],
	[&"private_export", true],
]):
	assert_bool(plugin.is_current_property_owner(base_node, property)).is_equal(expected)

func test_base_export_overwrite(property, expected, test_parameters := [
	[&"public_export", false],
	[&"protected_export", false],
	[&"private_export", false],
]):
	assert_bool(plugin.is_overwriting_default(scene, base_node, property)).is_equal(expected)

# Inherited
func test_inherited_export_visibility(property, expected, test_parameters = [
	[&"public_export", true],
	[&"protected_export", false],
	[&"private_export", false],
]):
	assert_bool(plugin.is_property_visible(scene, inherited_node, property)).is_equal(expected)

func test_inherited_ownership(property, expected, test_parameters = [
	[&"public_export", false],
	[&"protected_export", false],
	[&"private_export", false],
]):
	assert_bool(plugin.is_current_property_owner(inherited_node, property)).is_equal(expected)

func test_inherited_export_overwrite(property, expected, test_parameters := [
	[&"public_export", false],
	[&"protected_export", false],
	[&"private_export", false],
]):
	assert_bool(plugin.is_overwriting_default(scene, inherited_node, property)).is_equal(expected)
