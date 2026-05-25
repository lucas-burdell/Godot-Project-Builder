extends CharacterBody3D

@export_subgroup("Physics")
@export var speed: float = 3.0
@export var sprint_speed: float = 6.0
@export var deceleration: float = 3.0
@export var jump_velocity: float = 4.5
@export_subgroup("Stamina")
@export var max_stamina: float = 100.0
@export var stamina_recovery: float = 0.25
@export var stamina_drain: float = 0.25
@export var stamina_recovered_threshold: float = 50.0
@export_subgroup("Camera")
@export var controller_sensitivity: float = 0.002
@export var mouse_sensitivity: float = 0.002
@export var camera_limit_degrees: float = 80.0
@export var camera_standing: Vector3 = Vector3(0, 1.5, 0)
@export var camera_crouched: Vector3 = Vector3(0, 0.75, 0)
@export var lean_offset: Vector3 = Vector3(0.25, 0, 0)
@export var lean_angle: float = 30.0



@onready var camera: Camera3D = %Camera3D
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var crouch_collision_shape_3d: CollisionShape3D = %CrouchCollisionShape3D

var current_stamina: float
var _current_speed: float
var is_crouched: bool = false
var is_sprinting: bool = false
var is_recovering: bool = false
var camera_limit_radians: float

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_limit_radians = deg_to_rad(camera_limit_degrees)
	_current_speed = speed
	current_stamina = max_stamina

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var delta :Vector2 = -event.relative * mouse_sensitivity
		_handle_camera_movement(delta)		
	if Input.is_action_just_pressed("player_crouch"):
		is_crouched = !is_crouched
		collision_shape_3d.disabled = is_crouched
		crouch_collision_shape_3d.disabled = !is_crouched
	
	if Input.is_action_just_pressed("player_sprint") and !is_recovering and !is_crouched:
		is_sprinting = true
		_current_speed = sprint_speed
	elif Input.is_action_just_released("player_sprint"):
		is_sprinting = false
		_current_speed = speed
	


func _handle_camera_movement(move_delta: Vector2) -> void:
	rotate_y(move_delta.x)
	camera.rotate_x(move_delta.y)
	camera.rotation.x = clamp(camera.rotation.x, -camera_limit_radians, camera_limit_radians)

func _physics_process(delta: float) -> void:
	_handle_camera_offset(delta)
	
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = jump_velocity
	
	_handle_sprint(delta)
	
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * _current_speed
		velocity.z = direction.z * _current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)
	
	move_and_slide()

func _process(_delta: float) -> void:
	var axis := -Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down") * controller_sensitivity
	_handle_camera_movement(axis)

func _handle_camera_offset(delta: float) -> void:
	var lean_direction = Input.get_axis("player_lean_left", "player_lean_right")
	var camera_offset = camera_crouched if is_crouched else camera_standing
	camera_offset += lean_offset * Vector3(lean_direction, 0, 0)
	camera.position = camera.position.move_toward(camera_offset, delta)
	camera.rotation.z = lerp_angle(camera.rotation.z, -deg_to_rad(lean_angle * lean_direction), 2.0 * PI * delta)

func _handle_sprint(delta: float) -> void:
	if is_sprinting:
		current_stamina -= delta * stamina_drain * max_stamina
		if current_stamina <= 1:
			is_sprinting = false
			is_recovering = true
			_current_speed = speed
	else:
		current_stamina += delta * stamina_recovery * max_stamina
		if current_stamina > stamina_recovered_threshold:
			is_recovering = false
	
	current_stamina = clamp(current_stamina, 0, max_stamina)
