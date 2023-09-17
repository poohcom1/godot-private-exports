@tool
extends EditorPlugin

const Core := preload("./lib/core.gd")
const Configs := preload("./lib/configs.gd")
const PropertyInspectorRenderer := preload("./lib/property_inspector_renderer.gd")
const CustomInspectorPlugin := preload("./plugins/custom_inspector_plugin.gd")

var plugin_core: Core
var property_inspector_renderer: PropertyInspectorRenderer
var custom_inspector_plugin: CustomInspectorPlugin


# Setup
func _enter_tree() -> void:
	# Static initialization
	Configs.init()

	# Instance initialization
	plugin_core = Core.new()
	property_inspector_renderer = PropertyInspectorRenderer.new(self, plugin_core)
	custom_inspector_plugin = CustomInspectorPlugin.new(plugin_core)

	add_inspector_plugin(custom_inspector_plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(custom_inspector_plugin)
	custom_inspector_plugin = null

	property_inspector_renderer.terminate()
	property_inspector_renderer = null

	plugin_core = null
