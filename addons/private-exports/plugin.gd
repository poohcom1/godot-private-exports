@tool
extends EditorPlugin

const Configs := preload("./lib/configs.gd")
const PropertyInspectorRenderer := preload("./lib/property_inspector_renderer.gd")
const CustomInspectorPlugin := preload("./plugins/custom_inspector_plugin.gd")

var property_inspector_renderer: PropertyInspectorRenderer
var custom_inspector_plugin: CustomInspectorPlugin


# Setup
func _enter_tree() -> void:
	# Configs
	Configs.init()

	property_inspector_renderer = PropertyInspectorRenderer.new(self)
	custom_inspector_plugin = CustomInspectorPlugin.new()

	add_inspector_plugin(custom_inspector_plugin)


func _exit_tree() -> void:
	Configs.terminate()
	property_inspector_renderer.terminate()
	property_inspector_renderer = null

	remove_inspector_plugin(custom_inspector_plugin)
	custom_inspector_plugin = null
