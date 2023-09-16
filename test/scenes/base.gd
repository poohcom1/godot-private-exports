extends Node2D

@export_category("Basic")
@export var public_export: int
@export var protected_export: int
@export var private_export: int

@export_category("Empty category")
@export var private_in_category_1: int
@export var private_in_category_2: int

@export_category("Category with empty sections")
@export_group("Empty group")
@export var private_in_group_1: int
@export_group("Group with empty subgroup")
@export_subgroup("Empty subgroup")
@export var private_in_subgroup_1: int
