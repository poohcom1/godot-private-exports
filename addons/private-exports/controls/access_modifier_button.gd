extends Button

const PluginCore := preload("../lib/core.gd")

signal changed(modifier: PluginCore.AccessModifier)

var modifier = PluginCore.AccessModifier.Public

const public_icon := preload("../icons/Public.svg")
const private_icon := preload("../icons/Private.svg")
const protected_icon := preload("../icons/Protected.svg")

const IconMap := {
	PluginCore.AccessModifier.Public: public_icon,
	PluginCore.AccessModifier.Private: private_icon,
	PluginCore.AccessModifier.Protected: protected_icon,
}


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

	icon = IconMap[new_modifier]
	tooltip_text = PluginCore.AccessModifierNames[new_modifier]

	queue_redraw()
