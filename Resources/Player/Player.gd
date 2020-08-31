extends KinematicBody2D

onready var animatedSprite = $AnimatedSprite
const UP = Vector2(0, -1)
const MAX_SPEED = 120
const ACCELERATION = 500
const FRICTION = 600
var motion = Vector2.ZERO
var dialogBody = null
var state = MOVE
enum {
	MOVE,
	DIALOG
}


func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		DIALOG:
			dialog_state(delta)
	
	move_and_slide(motion)


func move_state(delta):	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up") 
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animatedSprite.play("Run")
		animatedSprite.flip_h = motion.x < 0
		motion = motion.move_toward(input_vector * MAX_SPEED, delta * ACCELERATION)
	else:
		animatedSprite.play("Idle")
		motion = motion.move_toward(Vector2.ZERO, delta * FRICTION)
	
	if dialogBody != null && dialogBody.has_method("readBook") && Input.is_action_just_pressed("ui_cancel"):
		var dialogBox = dialogBody.readBook()
		animatedSprite.play("Idle")
		state = DIALOG
		dialogBox.connect("dialog_ended", self, "_on_dialogBox_ended")


func dialog_state(delta):
	animatedSprite.play("Idle")
	motion = motion.move_toward(Vector2.ZERO, delta * FRICTION)


func _on_dialogBox_ended():
	state = MOVE


func _on_Area2D_body_entered(body):
	if body.has_method("readBook"):
		dialogBody = body


func _on_Area2D_body_exited(body):
	dialogBody = null