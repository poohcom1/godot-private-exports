extends Button

const PluginCore := preload("../lib/core.gd")

signal changed(modifier: PluginCore.AccessModifier)

var modifier = PluginCore.AccessModifier.Public

var public_icon := preload("../icons/Public.svg")
var private_icon := preload("../icons/Private.svg")
var protected_icon := preload("../icons/Protected.svg")


func _ready() -> void:
	icon = public_icon
	tooltip_text = "Public"

	pressed.connect(_on_press)
	update(modifier)


func _on_press():
	var new_modifier: PluginCore.AccessModifier
	match modifier:
		PluginCore.AccessModifier.Public:
			new_modifier = PluginCore.AccessModifier.Private
		PluginCore.AccessModifier.Protected:
			new_modifier = PluginCore.AccessModifier.Public
		PluginCore.AccessModifier.Private:
			new_modifier = PluginCore.AccessModifier.Protected
	#_draw()
	changed.emit(new_modifier)


func update(new_modifier: PluginCore.AccessModifier):
	modifier = new_modifier
	match new_modifier:
		PluginCore.AccessModifier.Protected:
			icon = protected_icon
			tooltip_text = "Protected"
		PluginCore.AccessModifier.Private:
			icon = private_icon
			tooltip_text = "Private"
		PluginCore.AccessModifier.Public:
			icon = public_icon
			tooltip_text = "Public"
