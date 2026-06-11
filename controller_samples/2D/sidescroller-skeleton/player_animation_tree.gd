class_name PlayerAnimationTree
extends AnimationTree

@export var is_walking = false
@export var is_jumping = false
@export var is_falling = false

class ATTACK_ONESHOTS:
	static var ATTACK := "attack"

func _ready() -> void:
	active = true

func play_attack_oneshot(oneshot: String) -> void:
	(tree_root as AnimationNodeBlendTree).get_node("AttackOneShotAnimation").animation = oneshot
	set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
