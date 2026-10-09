extends CharacterModel

@onready var animation_tree: AnimationTree = \
	$HumanM_Model/AnimationTree

@onready var animation_state: AnimationNodeStateMachinePlayback = \
	animation_tree["parameters/playback"]


func _ready() -> void:
	animation_tree.active = true
	animation_state.start("locomotion")

func set_locomotion(blend_position: Vector2) -> void:
	animation_tree["parameters/locomotion/blend_position"] = \
		blend_position

func set_grounded(grounded: bool) -> void:
	if grounded:
		animation_state.travel("locomotion")
	else:
		animation_state.travel("jump")
