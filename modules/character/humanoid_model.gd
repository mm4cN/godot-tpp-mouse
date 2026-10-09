class_name HumanoidModel
extends CharacterModel

@export var animation_tree: AnimationTree

@onready var animation_state: AnimationNodeStateMachinePlayback = \
	animation_tree["parameters/playback"]

func _ready() -> void:
	animation_tree.active = true
	animation_state.start("locomotion")

func set_locomotion(blend_position: Vector2) -> void:
	animation_tree["parameters/locomotion/blend_position"] = \
		blend_position

func set_grounded(grounded: bool) -> void:
	var current_state := animation_state.get_current_node()

	if not grounded and current_state != "jump":
		animation_state.travel("jump")
	elif grounded and current_state == "jump":
		animation_state.travel("locomotion")

func play_talk() -> void:
	if not is_talking():
		animation_state.travel("talk")

func is_talking() -> bool:
	return animation_state.get_current_node() == "talk"

func on_interacted(_actor: Node3D) -> void:
	play_talk()
