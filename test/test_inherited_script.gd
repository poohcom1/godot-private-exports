extends GdUnitTestSuite

const Plugin := preload("res://addons/private-exports/lib/core.gd")
const InheritedScript := preload("res://test/scenes/inherited_script.tscn")

var plugin := Plugin.new()
var scene: Node = InheritedScript.instantiate()

# Export from inherited script
func test_inherited_export_visibility(property, expected, test_parameters = [
	[&"inherited_public_export", true],
	[&"inherited_protected_export", true],
	[&"inherited_private_export", true],
]):
	assert_bool(plugin.is_property_visible(scene, scene, property)).is_equal(expected)

func test_inherited_ownership(property, expected, test_parameters = [
	[&"inherited_public_export", true],
	[&"inherited_protected_export", true],
	[&"inherited_private_export", true],
]):
	assert_bool(plugin.is_current_property_owner(scene, property)).is_equal(expected)

func test_inherited_export_overwrite(property, expected, test_parameters := [
	[&"inherited_public_export", false],
	[&"inherited_protected_export", false],
	[&"inherited_private_export", false],
]):
	assert_bool(plugin.is_overwriting_default(scene, scene, property)).is_equal(expected)


# Regular exports
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
