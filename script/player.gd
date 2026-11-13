extends CharacterBody2D

enum State {
	IDLE, 
	WALK, 
	ATTACK, 
	JUMP, 
	DEATH,
	}

@export var speed: float = 300
@export var damage: float = 20
@export var health: float = 30

var input_direction: Vector2 = Vector2.ZERO
var current_state: State = State.IDLE

@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var figter_sprite: Sprite2D = $FigterSprite
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var sfx_hit: AudioStreamPlayer2D = $SFXHit

func  _ready() -> void:
	EventBus.player_requested.connect(_on_player_requested)
	hurtbox_shape.disabled = true
	current_state = State.WALK

func _physics_process(delta: float) -> void:
	input_direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	match current_state:
		State.IDLE:
			pass
		State.WALK:
			
			var not_moving: bool = is_equal_approx(input_direction.length(), 0)
			
			if not_moving:
				animation_player.play("idle")
			elif animation_player.current_animation != "walk":
				animation_player.play("walk")
			
			velocity = input_direction * speed
			if Input.is_action_just_pressed("attack"):
				attack()
			if abs(velocity.x) > 0.1:
				figter_sprite.flip_h = velocity.x < 0
				
				#hurtbox.scale.x =-1 if figter_sprite.flip_h else 1
				
				if figter_sprite.flip_h == true:
					hurtbox.scale.x = -1
					hitbox.scale.x = -1
				else:
					hurtbox.scale.x = 1
					hitbox_shape.scale.x = 1
		State.ATTACK:
			pass
		State.JUMP:
			pass
		State.DEATH:
			pass
		_:
			pass
	
	move_and_slide()


func  attack() -> void:
	velocity = Vector2.ZERO
	animation_player.play("attack")
	animation_player.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
	current_state = State.ATTACK
	

func _on_attack_finished(anim_name:StringName) -> void:
	animation_player.play("idle")
	current_state = State.WALK

func _on_hurtbox_area_entered(area: Area2D) -> void:
	EventBus.attacked.emit(self, area, 10)


func _on_player_requested(enemy: Enemy) -> void:
	enemy.player = self

func hit_feedback() -> void:
	sfx_hit.play()
	var tween: Tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(self, "modulate", Color.WHITE, 0.4). from(Color.WHITE * 8)

func _on_damage_taken() -> void:
	hit_feedback()
