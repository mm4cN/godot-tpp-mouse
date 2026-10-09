@tool
extends CanvasLayer

@export var reticle_texture: Texture2D:
	set(value):
		reticle_texture = value
		_update_reticle()

@export var reticle_size := Vector2(64.0, 64.0):
	set(value):
		reticle_size = value
		_update_reticle()

@onready var reticle = $ReticleCenter/Reticle

func set_interaction_available(available: bool) -> void:
	reticle.set_interaction_available(available)

func _ready() -> void:
	_update_reticle()

func _update_reticle() -> void:
	if reticle:
		reticle.custom_minimum_size = reticle_size
		reticle.set("texture", reticle_texture)
