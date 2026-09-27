extends CharacterBody3D


# Movement constants.
const DASH_SPEED = 60.0
const WALK_SPEED = 30.0
const SPRINT_SPEED = 10.0
const JUMP_VELOCITY = 10.0
const SENSITIVITY = 0.009
const MAX_HEALTH = 100

# Head bob variables.
const BOB_FREQ = 0.4
const BOB_AMP = 0.15
var t_bob = 0.0
var damage = false
var speed = 0

# FOV variables.
const BASE_FOV = 75.0
const FOV_CHANGE = 0.5
var can_dash = true

# Gravity variables.
var gravity = 9
var weight = 80.0

# Load the bullet scene so bullets can be created when the player shoots.
var bullet = load("res://scenes/bullet.tscn")
var instance

# Health variables.
var max_health = MAX_HEALTH
@export var health = 0

# References to important nodes in the player scene.
@onready var head = $Node3D
@onready var camera = $Node3D/Camera3D
@onready var gun_animation = (
	$Node3D/Camera3D/Sketchfab_Scene/AnimationPlayer
)
@onready var gun_ray = $Node3D/Camera3D/Sketchfab_Scene/RayCast3D


# Set up the player when the scene starts.
func _ready():
	health = max_health

	# Capture the mouse so it can control the camera.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	global.player = self


# Handle mouse movement to control the player's camera.
func _unhandled_input(event):
	# Check if the input event was caused by mouse movement.
	if event is InputEventMouseMotion:
		# Rotate the player's head from left to right.
		head.rotate_y(-event.relative.x * SENSITIVITY)

		# Rotate the camera up and down.
		camera.rotate_x(-event.relative.y * SENSITIVITY )

		# Limit how far the player can look up and down.
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-90),
			deg_to_rad(90)
		)


# Handle the player's movement, shooting, jumping, and camera effects.
func _physics_process(delta):
	# Check if the player's health has reached zero.
	if health <= 0:
		get_tree().reload_current_scene()

	# Check if the player has pressed the shoot button.
	if Input.is_action_just_pressed("shoot"):
		if not gun_animation.is_playing():
			gun_animation.play("shoot")
			$LaserShoot.play()
			instance = bullet.instantiate()
			instance.position = gun_ray.global_position
			instance.transform.basis = gun_ray.global_transform.basis
			get_parent().add_child(instance)

	# Apply gravity while the player is in the air.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Check if the player presses jump while standing on the floor.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		$Jump.play()

		velocity.y = JUMP_VELOCITY - abs(velocity.x) * 0.1

	# Check if the sprint button is being held.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the player's movement input.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	# The direction is based on where the player's head is facing.
	var direction = (
		head.transform.basis
		* transform.basis
		* Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	# Handle movement while the player is on the floor.
	if is_on_floor():
		if direction:
			velocity.x = lerp(
				velocity.x,
				direction.x * speed,
				delta * 4
			)
			velocity.z = lerp(
				velocity.z,
				direction.z * speed,
				delta * 4
			)
		else:
			velocity.x = lerp(
				velocity.x,
				direction.x * speed,
				delta * 3
			)
			velocity.z = lerp(
				velocity.z,
				direction.z * speed,
				delta * 3
			)
	else:
		velocity.x = lerp(
			velocity.x,
			direction.x * speed,
			delta
		)
		velocity.z = lerp(
			velocity.z,
			direction.z * speed,
			delta
		)

	# Increase the head bob timer based on the player's movement speed.
	t_bob += delta * velocity.length() * float(is_on_floor())

	# Apply the head bob effect to the camera.
	camera.transform.origin = _headbob(t_bob)

	# Calculate the player's current movement speed.
	var velocity_clamped = clamp(
		velocity.length(),
		0.5,
		SPRINT_SPEED * 2
	)
	
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped

	# Smoothly change the camera's FOV.
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	move_and_slide()


# Calculate the camera position used for the head bob effect.
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


# Detect when an enemy enters the player's damage area.
func _on_area_3d_area_entered(area: Area3D) -> void:
	# Check if the area belongs to an enemy.
	if area.is_in_group("enemy"):
		$HitHurt.play()
		damage = true
		health -= 5
		await get_tree().create_timer(0.2).timeout
		# Print the damage state for debugging.
		print(damage)


# Detect when the player enters the kill floor.
func _on_kill_floor_area_entered(area: Area3D) -> void:
	get_tree().reload_current_scene()


func _on_end_point_area_entered(area: Area3D) -> void:
	get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
	pass # Replace with function body.
