extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
var chasing = false 

const SPEED = 40
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity = direction* SPEED

		
	if navigation_agent_3d.is_navigation_finished():
		var random_movement = Vector3.ZERO
		random_movement.x = randf_range(-0.1, 0.1)
		random_movement.z = randf_range(-0.1, 0.1)
		navigation_agent_3d.set_target_position(random_movement)
	
	move_and_slide()
