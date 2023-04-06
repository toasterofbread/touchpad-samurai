extends CharacterBody2D
class_name Enemy

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	velocity.y += gravity * delta
	move_and_slide()

func onScreenEntered():
	Game.player.enemySighted(self)
