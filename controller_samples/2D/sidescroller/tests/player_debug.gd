extends Label

@export var player: CharacterBody2D

func _process(_delta: float) -> void:
	text = _generate_debug_text()

func _generate_debug_text() -> String:
	var output := "FPS: %d" % Engine.get_frames_per_second()
	if player == null:
		return output
	output += "\nposition: %d, %d" % [player.global_position.x, player.global_position.y]
	output += "\nvelocity: %d, %d" % [player.velocity.x, player.velocity.y]
	if player.coyote_timer != null:
		output += "\ncoyote timer: %.3f" % player.coyote_timer
	if player.jump_buffer_timer != null:
		output += "\njump buffer timer: %.3f" % player.jump_buffer_timer
	if player.player_animation_tree != null:
		var anim_tree := player.player_animation_tree as AnimationTree
		if anim_tree.is_walking != null:
			output += "\nis walking: %s" % anim_tree.is_walking
		if anim_tree.is_jumping != null:
			output += "\nis jumping: %s" % anim_tree.is_jumping
		if anim_tree.is_falling != null:
			output += "\nis falling: %s" % anim_tree.is_falling
	return output
