class_name Enemy
extends CharacterBody2D

var player: CharacterBody2D
var is_player_available: bool = false

var target_acquired_elapsed: float = 0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sfx_hit: AudioStreamPlayer2D = $SFXHit

func  _ready() -> void:
	await  get_tree().physics_frame
	EventBus.player_requested.emit(self)
	is_player_available = true

func _physics_process(delta: float) -> void:
	if is_player_available == false:
		return
	
	if target_acquired_elapsed > 1:
		nav_agent.target_position = player.global_position
		target_acquired_elapsed = 0
	
	var next_position: Vector2 = nav_agent.get_next_path_position()
	velocity = global_position.direction_to(next_position) * 50
	
	var distace = global_position.distance_to(nav_agent.target_position)
	if distace <= 50:
			velocity = Vector2.ZERO
	
	move_and_slide()

	target_acquired_elapsed += delta

func _on_hutbox_area_entered(area: Area2D) -> void:
	EventBus.attacked.emit(self, area, 10)

func _on_entity_died() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self,"scale", Vector2.ZERO, 1.0)
	tween.tween_property(self,"modulate:a",0.0, 1.0)
	
	await tween.finished
	queue_free()

func hit_feedback() -> void:
	sfx_hit.play()
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_loops(3)
	tween.tween_property(self, "modulate", Color.WHITE, 0.4).from(Color.WHITE * 8)
	tween.set_loops(1)
	#tween.tween_property(self, "scale", )
	


func _on_damage_taken() -> void:
	hit_feedback()
