class_name Character
extends CharacterBody3D

@export var collision_shape: Shape3D

@onready var interactable: Interactable = $Interactable
@onready var model_slot: Node3D = $ModelSlot
@onready var collision: CollisionShape3D = $CollisionShape3D

var model_instance: CharacterModel

func _ready() -> void:
	if collision_shape:
		collision.shape = collision_shape

	for child in model_slot.get_children():
		if child is CharacterModel:
			model_instance = child
			break

	if not model_instance:
		push_error("ModelSlot requires a CharacterModel child.")
