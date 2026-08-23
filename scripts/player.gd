extends CharacterBody3D

var speed
const DASH_SPEED = 60
const WALK_SPEED = 30
const SPRINT_SPEED = 100
const JUMP_VELOCITY = 12
const SENSITIVITY = 0.009
const MAX_HEALTH = 100

#bob variables
const BOB_FREQ = 0.4
const BOB_AMP = 0.15
var t_bob = 0
var damage = false

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 0.5
var can_dash = true

# Gravity variable
var gravity = 20
var weight = 60

var bullet = load("res://scenes/bullet.tscn")
var instance

@onready var head =$Node3D
@onready var camera = $Node3D/Camera3D
@onready var gun_animation = $Node3D/Camera3D/Sketchfab_Scene/AnimationPlayer
@onready var gun_ray = $Node3D/Camera3D/Sketchfab_Scene/RayCast3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	global.player = self


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta):
	
	if Input.is_action_just_pressed("shoot"):
		if !gun_animation.is_playing():
			gun_animation.play("shoot")
			instance = bullet.instantiate()
			instance.position = gun_ray.global_position
			instance.transform.basis = gun_ray.global_transform.basis
			get_parent().add_child(instance)
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY - abs(velocity.x) * 0.1
		
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, delta *4)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 4)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 3)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 3) 
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 1)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 1)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	

	move_and_slide()



func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("enemy"):
		damage == true
		queue_free()
		print (damage)
		
	pass # Replace with function body.
