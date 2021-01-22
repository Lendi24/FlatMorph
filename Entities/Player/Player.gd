extends KinematicBody2D 

const TARGET_FPS = 60
const ACCELERATION = 8
const MAX_SPEED = 64
const FRICTION = 10
const AIR_RESISTANCE = 1
const GRAVITY = 5
const JUMP_FORCE = 140
const PUSH = 7 

var motion = Vector2.ZERO

onready var PlayerControl = $PlayerControl
onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer 

func _ready():
	PlayerControl.currentlySelectedEntity = self
	
func _physics_process(delta):
	if not PlayerControl.Possessed(self):
		#print("PlayerPlaying")
		motion = Vector2.ZERO
	#else:
		#print("NotDoingThat")
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if (x_input != 0):
		animationPlayer.play("Run")
		motion.x += x_input * ACCELERATION * delta * TARGET_FPS
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		sprite.flip_h = x_input < 0
		
	else:
		#print("Stand")
		animationPlayer.play("Stand")
	
	motion.y += GRAVITY * delta * TARGET_FPS
	
	if is_on_floor():
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION * delta)
			
		if Input.is_action_just_pressed("key_space"):
			motion.y = -JUMP_FORCE
	else:
		animationPlayer.play("Jump")
		
		if Input.is_action_just_released("key_space") and motion.y < -JUMP_FORCE/2:
			motion.y = -JUMP_FORCE/2
	
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE * delta)
	
	#print(motion)
	motion = move_and_slide(motion, Vector2.UP, false, 4, PI/4, false)
	
	#collitionCheck
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("ent_arm") and !is_on_floor():
			print("STop")
			get_node("/root/Globals").GravArmStop = true
		else:
			get_node("/root/Globals").GravArmStop = false
		
		if collision.collider.is_in_group("movable"):
			collision.collider.apply_central_impulse(-collision.normal * PUSH)

func _on_Player_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		PlayerControl.currentlySelectedEntity = self
		print("Press player")
