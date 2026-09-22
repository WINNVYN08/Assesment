extends CharacterBody3D

var speed = 0
const DASH_SPEED = 60
const WALK_SPEED = 30
const SPRINT_SPEED = 600
const JUMP_VELOCITY = 50
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
var gravity = 0
var weight = 0

var bullet = load("res://scenes/bullet.tscn")
var instance

#  Health 
var max_health = 100
@export var health  = 0

@onready var head =$Node3D
@onready var camera = $Node3D/Camera3D
@onready var gun_animation = $Node3D/Camera3D/Sketchfab_Scene/AnimationPlayer
@onready var gun_ray = $Node3D/Camera3D/Sketchfab_Scene/RayCast3D



func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta):
	

	
	# Add the gravity.

	

	move_and_slide()



func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
