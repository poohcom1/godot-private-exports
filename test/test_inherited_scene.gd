extends GdUnitTestSuite

const Plugin := preload("res://addons/private-exports/lib/core.gd")
const InheritedScene := preload("res://test/scenes/inherited_scene.tscn")

var plugin := Plugin.new()
var scene: Node = InheritedScene.instantiate()

func test_export_visibility(property, expected, test_parameters = [
	[&"public_export", true],
	[&"protected_export", true],
	[&"private_export", false],
]):
	assert_bool(plugin.is_property_visible(scene, scene, property)).is_equal(expected)

func test_ownership(property, expected, test_parameters = [
	[&"public_export", false],
	[&"protected_export", false],
	[&"private_export", false],
]):
	assert_bool(plugin.is_current_property_owner(scene, property)).is_equal(expected)

func test_export_overwrite(property, expected, test_parameters := [
	[&"public_export", false],
	[&"protected_export", false],
	[&"private_export", false],
]):
	assert_bool(plugin.is_overwriting_default(scene, scene, property)).is_equal(expected)
