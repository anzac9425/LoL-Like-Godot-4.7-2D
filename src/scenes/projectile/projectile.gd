extends Area2D
class_name Projectile

@onready var projectile_sprite: Sprite2D = $Sprite2D
@onready var projectile_collision_shape: CollisionShape2D = $CollisionShape2D

var damage_info: DamageInfo
var projectile_speed: float
var projectile_radius: float

var projectile_sprite_radius: float
var projectile_collision_shape_radius: float


func _ready() -> void:
	set_radius_sprite(projectile_radius)
	set_radius_collision_shape(projectile_radius)
	
	global_position = damage_info.attacker.global_position


func _physics_process(delta: float) -> void:
	if !damage_info.victim.can_be_targeted():
		queue_free()
		return

	global_position = global_position.move_toward(
		damage_info.victim.global_position,
		projectile_speed * delta
	)

	if global_position.distance_to(damage_info.victim.global_position) <= projectile_radius + damage_info.victim.character_collision_shape_radius:
		Combat.apply_damage(damage_info)
		
		queue_free()
		return


func set_radius_sprite(radius: float) -> void:
	projectile_sprite.scale = Vector2.ONE * (
		radius * 2.0 / projectile_sprite.texture.get_size().x
	)
	
	projectile_sprite_radius = radius


func set_radius_collision_shape(radius: float) -> void:
	var shape: CircleShape2D = CircleShape2D.new()
	
	shape.radius = radius

	projectile_collision_shape.shape = shape
	
	projectile_collision_shape_radius = radius
