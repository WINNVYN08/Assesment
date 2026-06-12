extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
var chasing = false

const SPEED = 5
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
		
	
	if chasing:
		navigation_agent_3d.target_position = global.player.global_position
		
	elif navigation_agent_3d.is_navigation_finished():
		var target = global_position
		target.x += randf_range(-10, 10)
		target.z += randf_range(-10, 10)
		navigation_agent_3d.target_position = target
	var direction = (destination - global_position).normalized()

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


func _on_area_3d_area_entered(area: Area3D) -> void:
	chasing == true
	pass # Replace with function body.


func _on_area_3d_area_exited(area: Area3D) -> void:
	chasing == false
	pass # Replace with function body.
