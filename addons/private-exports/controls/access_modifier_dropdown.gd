extends OptionButton

const Core := preload("../lib/core.gd")

signal changed(modifier: Core.AccessModifier)

var modifier = Core.AccessModifier.Public:
	set(val):
		select(val)
	get:
		return selected

const public_icon := preload("../icons/Public.svg")
const private_icon := preload("../icons/Private.svg")
const protected_icon := preload("../icons/Protected.svg")

const IconMap := {
	Core.AccessModifier.Public: public_icon,
	Core.AccessModifier.Private: private_icon,
	Core.AccessModifier.Protected: protected_icon,
}


func _init() -> void:
	for i in Core.AccessModifier.values():
		add_icon_item(IconMap[i], "", i)
		set_item_tooltip(i, Core.AccessModifierNames[i])

	item_selected.connect(func(item: int): changed.emit(item))
