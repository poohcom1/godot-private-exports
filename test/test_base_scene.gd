extends GdUnitTestSuite

const Plugin := preload("res://addons/private-exports/lib/core.gd")
const BaseScene := preload("res://test/scenes/base.tscn")

var plugin := Plugin.new()
var base_scene: Node = BaseScene.instantiate()

func test_export_visibility(property, expected, test_parameters = [
	[&"public_export", true],
	[&"protected_export", true],
	[&"private_export", true],
]):
	assert_bool(plugin.is_property_visible(base_scene, base_scene, property)).is_equal(expected)

func test_ownership(property, expected, test_parameters = [
	[&"public_export", true],
	[&"protected_export", true],
	[&"private_export", true],
]):
	assert_bool(plugin.is_current_property_owner(base_scene, property)).is_equal(expected)

func test_export_overwrite(property, expected, test_parameters := [
	[&"public_export", false],
	[&"protected_export", false],
	[&"private_export", false],
]):
	assert_bool(plugin.is_overwriting_default(base_scene, base_scene, property)).is_equal(expected)
