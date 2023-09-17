# Godot Private Exports

[<img src="https://img.shields.io/static/v1?label=GODOT%204.2&message=Asset%20Library&color=478CBF&labelColor=FFFFFF&style=for-the-badge&logo=godotengine">]([https://godotengine.org/asset-library/asset/8918](https://godotengine.org/asset-library/asset/2136))

A Godot addon that adds access modifiers to exported variables in scenes. This can be used to prevent changes to exported variables that are only meant to be modified in the base scene or reduce clutter from the inspector.

![Example of inspector](screenshots/inspector.png)

## Access Modifiers

- `Public`: Public exports are always visible.
- `Private`: Private exports are only visible in the base scene.
- `Protected`: Protected exports are only visible in the base scene and its inheritors.

| Actor.tscn                                             | Player.tscn (extends Actor)                                      | Level.tscn                                                |
| ------------------------------------------------------ | ---------------------------------------------------------------- | --------------------------------------------------------- |
| ![Example of base scene](screenshots/example_base.png) | ![Example of inherited scene](screenshots/example_inherited.png) | ![Example of ext scene](screenshots/example_external.png) |

> Private and protected exports can be used to fine-tune how exports are shown in other scenes.

Access modifiers are only applied to _scenes_, not _scripts_. They are used for hiding exports when scenes are instantiated in other scenes. As such, they are not connected to scripts. For example, `Player.tscn` scene with an `Player.gd` script may have the `speed` property private. However, if `Player.gd` is used elsewhere, the `speed` export there is considered unrelated and will have its own access modifiers.

## Editor Settings

| Setting      | Description                                                                                                                                                      | Default |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| Display Mode | `Always`: modifier always shown <br /> `Selected`: only shown on selected properties <br /> `Modified`: only shown on modified and selected properties | `Always`  |
