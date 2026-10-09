class_name Interactable
extends Area3D

signal interacted(actor: Node3D)

@export var prompt := "Interact"

func interact(actor: Node3D) -> void:
	interacted.emit(actor)
