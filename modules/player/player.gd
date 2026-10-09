extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var animation_tree: AnimationTree = $model/HumanM_Model/AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = \
	animation_tree["parameters/playback"]

const WALK_SPEED = 2.0
const RUN_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MIN_CAMERA_PITCH = deg_to_rad(-35.0)
const MAX_CAMERA_PITCH = deg_to_rad(50.0)

@export_range(1.0, 20.0, 0.5) var animation_blend_smoothing := 8.0
@export_range(0.01, 1.0, 0.01) var sensitivity_x = 0.12
@export_range(0.01, 1.0, 0.01) var sensitivity_y = 0.10

var current_blend_position := Vector2.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_tree.active = true
	animation_state.start("locomotion")
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity_x))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sensitivity_y))
		camera_mount.rotation.x = clampf(
			camera_mount.rotation.x,
			MIN_CAMERA_PITCH,
			MAX_CAMERA_PITCH
		)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var is_running := Input.is_action_pressed("sprint")
	var current_speed := RUN_SPEED if is_running else WALK_SPEED
	var blend_strength := 1.0 if is_running else 0.5
	
	var target_blend_position := input_dir * blend_strength
	current_blend_position = current_blend_position.lerp(
		target_blend_position,
		1.0 - exp(-animation_blend_smoothing * delta)
	)

	animation_tree["parameters/locomotion/blend_position"] = \
		current_blend_position
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, RUN_SPEED * delta * 6.0)
		velocity.z = move_toward(velocity.z, 0.0, RUN_SPEED * delta * 6.0)

	move_and_slide()
	if is_on_floor():
		animation_state.travel("locomotion")
	else:
		animation_state.travel("jump")
