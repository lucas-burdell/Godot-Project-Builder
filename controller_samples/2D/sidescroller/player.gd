extends CharacterBody2D

@export var speed := 300.0
@export var jump_velocity := -400.0
@export var coyote_time := 0.16
@export var jump_buffer := 0.1


@onready var player_animation_tree: AnimationTree = %PlayerAnimationTree
@onready var sprite2d: Sprite2D = %Sprite2D
@onready var raycast2d: RayCast2D = %RayCast2D

var coyote_was_on_floor: bool = false
var coyote_timer: float = 0
var jump_buffer_timer: float = 0


func _process(_delta: float) -> void:
	player_animation_tree.set("is_falling", _is_falling())
	player_animation_tree.set("is_jumping", velocity.y < 0 and !_is_floor_or_ray())
	player_animation_tree.set("is_walking", velocity.x != 0)
	if velocity.x < 0:
		sprite2d.flip_h = true
	elif velocity.x > 0:
		sprite2d.flip_h = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		if coyote_was_on_floor:
			coyote_timer = coyote_time
		elif coyote_timer > 0:
			coyote_timer -= delta
	else:
		jump_buffer_timer = 0
		coyote_timer = 0
	coyote_was_on_floor = is_on_floor()
		
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		if _can_jump():
			_do_jump()
	elif Input.is_action_just_pressed("player_jump"):
		if _can_jump():
			_do_jump()
		elif jump_buffer_timer <= 0:
			jump_buffer_timer = jump_buffer

	var direction := Input.get_axis("player_left", "player_right")
	if direction != 0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)


	move_and_slide()

func _can_jump() -> bool:
	return (is_on_floor() or coyote_timer > 0)

func _do_jump() -> void:
	velocity.y = jump_velocity
	jump_buffer_timer = 0
	coyote_timer = 0
	coyote_was_on_floor = false

func _is_floor_or_ray() -> bool:
	if is_on_floor():
		return true
	var floor_below := raycast2d.is_colliding()
	return floor_below

func _is_falling() -> bool:
	return !_is_floor_or_ray() && velocity.y > 0 && coyote_timer <= 0