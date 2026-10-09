class_name Character
extends CharacterBody3D

@export var collision_shape: Shape3D

@onready var model_slot: Node3D = $ModelSlot
@onready var collision: CollisionShape3D = $CollisionShape3D

var model_instance: CharacterModel

func _ready() -> void:
	if collision_shape:
		collision.shape = collision_shape

	if model_slot.get_child_count() > 0:
		model_instance = model_slot.get_child(0) as CharacterModel

	if not model_instance:
		push_error("ModelSlot requires a CharacterModel child.")
