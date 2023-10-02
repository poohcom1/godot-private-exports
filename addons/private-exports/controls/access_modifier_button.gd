@tool
extends Button

const Core := preload("../lib/core.gd")

signal changed(modifier: Core.AccessModifier)

const IconMap := {
	Core.AccessModifier.Public: preload("../icons/Public.svg"),
	Core.AccessModifier.Private: preload("../icons/Private.svg"),
	Core.AccessModifier.Protected: preload("../icons/Protected.svg"),
}

var _modifier := Core.AccessModifier.Public
var _popup: PopupMenu


func _init() -> void:
	pressed.connect(_on_press)

	# Popup
	_popup = PopupMenu.new()
	_popup.hide()
	add_child(_popup)
	for i in Core.AccessModifier.values():
		_popup.add_icon_item(IconMap[i], Core.AccessModifierNames[i], i)
	_popup.id_pressed.connect(
		func(id: int): 
			changed.emit(id)
			set_modifier(id)
	)


func _on_press():
	var xform := get_screen_transform()
	var rect := Rect2(xform.get_origin(), xform.get_scale() * get_size())

	rect.position.y += rect.size.y
	rect.size.y = 0
	_popup.position = rect.position
	_popup.size = rect.size

	_popup.popup()


func set_modifier(new_modifier: Core.AccessModifier):
	_modifier = new_modifier

	icon = IconMap[new_modifier]
	tooltip_text = Core.AccessModifierNames[new_modifier]


func get_modifier() -> Core.AccessModifier:
	return _modifier
