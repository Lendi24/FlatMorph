extends Skeleton2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var Head = $Base/ArmPart1/ArmPart2/Head
onready var ArmPart2 = $Base/ArmPart1/ArmPart2/
onready var ArmPart1 = $Base/ArmPart1/
onready var Base = $Base/
onready var Target = get_tree().get_root().get_node("Node2D/Target")

onready var grabArea = Head.get_node("Area2D")
var newBody

func _ready():
	grabArea.connect("body_entered", self, "_on_physicsbody_entered")

func _process(_delta):
	animate_arm(ArmPart1, ArmPart2)
	if(newBody != null && newBody.get_parent().name == "Head"):
		newBody.global_position = Head.global_position
		newBody.rotation = Head.rotation
		newBody.position = Vector2(6.4,0)
		print("\nHeadPos:")
		print(Head.global_position)
		print("\nnewBody Position")
		print(newBody.global_position)
		print("\n")
	

	
func animate_arm(arm_upper: Bone2D, arm_lower: Bone2D):

	var offset = get_global_mouse_position() - Vector2(global_position.x, global_position.y-5)
	var distance = offset.length()
	var joint_angle_0
	var joint_angle_1
	
	var atan_val = atan2(offset.y, offset.x)
	
	var length_0 = arm_upper.default_length
	var length_1 = arm_lower.default_length
	
	# it's too far away
	if length_0 + length_1 < distance:
		joint_angle_0 = atan_val
		joint_angle_1 = 0
	else:
		var angle_0 = law_of_cos(distance, length_0, length_1)
		var angle_1 = law_of_cos(length_1, length_0, distance)
	 
		joint_angle_0 = atan_val - angle_0
		joint_angle_1 = PI - angle_1
			 

	
	#if arm_upper.rotation - joint_angle_0 > 0.05:
	#else:
	
	
	if (!is_nan(joint_angle_0)):# and !get_node("/root/Globals").GravArmStop):
		arm_upper.rotation = joint_angle_0
		
	if (!is_nan(joint_angle_1)):# and !get_node("/root/Globals").GravArmStop):
		arm_lower.rotation = joint_angle_1

func law_of_cos(a, b, c):
	if 2 * a * b == 0:
		return 0
	return acos( (a * a + b * b - c * c) / (2 * a * b) )


func _on_physicsbody_entered(body):
	var pBody = body.get_parent()
	if(pBody.get_parent().name != "Head"):
		if(pBody.name == "Cube1"):
			newBody = pBody
			print("is a cube!")
			#pBody.set_owner(self.get_parent())

			newBody.get_parent().remove_child(pBody)
			newBody.get_node("RigidBody2D").mode = RigidBody2D.MODE_STATIC

			Head.add_child(newBody)
			
	print(Head.get_children())


