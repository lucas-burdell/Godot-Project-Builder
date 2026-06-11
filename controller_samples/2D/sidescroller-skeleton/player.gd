extends CharacterBody2D

@export var speed := 300.0
@export var jump_velocity := -500.0
@export var coyote_time := 0.16
@export var jump_buffer := 0.1
@export var attack_cooldown: float = .25

@onready var player_animation_tree: PlayerAnimationTree = %PlayerAnimationTree
@onready var flipper: Node2D = %Flipper
@onready var raycast2d: RayCast2D = %RayCast2D
@onready var attackarea2d: Area2D = %AttackArea2D

var coyote_was_on_floor: bool = false
var coyote_timer: float = 0
var jump_buffer_timer: float = 0
var flipped: bool = false
var attack_timer: float = 0
var input_velocity: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_attack"):
		_attack()

func _process(_delta: float) -> void:
	player_animation_tree.set("is_falling", _is_falling())
	player_animation_tree.set("is_jumping", velocity.y < 0 and !_is_floor_or_ray())
	player_animation_tree.set("is_walking", input_velocity.x != 0)
	if input_velocity.x < 0 and not flipped:
		flipped = true
		flipper.scale.x = -1
		pass
	elif input_velocity.x > 0 and flipped:
		flipped = false
		flipper.scale.x = 1
		pass
	if attack_timer > 0:
		attack_timer -= _delta

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
	input_velocity = Vector2(Input.get_axis("player_left", "player_right"), 0)
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		if _can_jump():
			_do_jump()
	elif Input.is_action_just_pressed("player_jump"):
		if _can_jump():
			_do_jump()
		elif jump_buffer_timer <= 0:
			jump_buffer_timer = jump_buffer

	var direction := input_velocity.x * speed
	if input_velocity.x != 0:
		velocity.x = move_toward(velocity.x, direction, speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed  * .75)
	if input_velocity.y != 0:
		velocity.y = move_toward(velocity.y, input_velocity.y * jump_velocity, jump_velocity)

	move_and_slide()

func _can_jump() -> bool:
	return (is_on_floor() or coyote_timer > 0)

func _do_jump() -> void:
	input_velocity.y = -1
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
	
func _attack() -> void:
	if attack_timer <= 0:
		attack_timer = attack_cooldown
		player_animation_tree.play_attack_oneshot(PlayerAnimationTree.ATTACK_ONESHOTS.ATTACK)
