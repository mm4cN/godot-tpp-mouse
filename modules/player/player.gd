extends Character

@export_range(1.0, 20.0, 0.5) var animation_blend_smoothing: float = 8.0
@export_range(0.01, 1.0, 0.01) var sensitivity_x: float = 0.12
@export_range(0.01, 1.0, 0.01) var sensitivity_y: float = 0.10
@export_range(3.0, 5.0, 0.1) var jump_velocity: float = 4.5
@export_range(1.0, 3.0, 0.1) var walk_speed: float = 2.0
@export_range(3.0, 6.0, 0.1) var run_speed: float = 5.0

@onready var camera_mount = $camera_mount
@onready var interaction_ray: RayCast3D = $camera_mount/Camera3D/InteractionRay

var interaction_available := false
signal interaction_availability_changed(available: bool)

const MIN_CAMERA_PITCH = deg_to_rad(-35.0)
const MAX_CAMERA_PITCH = deg_to_rad(50.0)

var current_blend_position := Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("talk"):
		var target := interaction_ray.get_collider() as Interactable

		if target:
			target.interact(self)

			if model_instance:
				model_instance.play_talk()

func _ready():
	super._ready()
	interaction_ray.add_exception(interactable)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity_x))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sensitivity_y))
		camera_mount.rotation.x = clampf(
			camera_mount.rotation.x,
			MIN_CAMERA_PITCH,
			MAX_CAMERA_PITCH
		)

func _update_interaction_availability() -> void:
	var available := interaction_ray.get_collider() is Interactable

	if available == interaction_available:
		return

	interaction_available = available
	interaction_availability_changed.emit(available)

func _physics_process(delta: float) -> void:
	var movement_locked := (
		model_instance != null
		and model_instance.is_talking()
	)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if (not movement_locked and Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y = jump_velocity

	var input_dir := Vector2.ZERO

	if not movement_locked:
		input_dir = Input.get_vector(
			"strafe_left",
			"strafe_right",
			"move_forward",
	        "move_backward"
		)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var is_running := Input.is_action_pressed("sprint")
	var current_speed := run_speed if is_running else walk_speed
	var blend_strength := 1.0 if is_running else 0.5
	
	var target_blend_position := input_dir * blend_strength
	current_blend_position = current_blend_position.lerp(
		target_blend_position,
		1.0 - exp(-animation_blend_smoothing * delta)
	)

	if model_instance:
		model_instance.set_locomotion(current_blend_position)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, run_speed * delta * 6.0)
		velocity.z = move_toward(velocity.z, 0.0, run_speed * delta * 6.0)

	move_and_slide()
	if model_instance:
		model_instance.set_grounded(is_on_floor())

	_update_interaction_availability()
