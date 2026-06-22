extends Area2D
class_name Projectile


enum Type {
	TARGET,
	LINEAR
}

@onready var projectile_sprite: Sprite2D = $Sprite2D
@onready var projectile_collision_shape: CollisionShape2D = $CollisionShape2D

var projectile_type: Type

var damage_info: DamageInfo
var projectile_speed: float
var projectile_radius: float

var projectile_sprite_radius: float
var projectile_collision_shape_radius: float

var spawn_position: Vector2

var direction: Vector2

var max_distance: float
var traveled_distance: float

var pierce: bool

var hit_targets: Array[CharacterBase]


func _ready() -> void:
	set_radius_sprite(projectile_radius)
	set_radius_collision_shape(projectile_radius)

	match projectile_type:
		Type.LINEAR:
			global_position = spawn_position

		_:
			global_position = damage_info.attacker.global_position


func _physics_process(delta: float) -> void:
	match projectile_type:
		Type.TARGET:
			if damage_info.victim.is_dead or !damage_info.victim.can_be_targeted():
				queue_free()
				return

			global_position = global_position.move_toward(damage_info.victim.global_position, projectile_speed * delta)

			if global_position.distance_to(damage_info.victim.global_position) <= projectile_radius + damage_info.victim.character_collision_shape_radius:
				damage_info.attacker.on_deal_projectile_hit(self)
				damage_info.victim.on_take_projectile_hit(self)
				
				Combat.apply_damage(damage_info)
				
				
				queue_free()
				return
		
		Type.LINEAR:
			var movement: Vector2 = direction * projectile_speed * delta

			global_position += movement

			traveled_distance += movement.length()

			for area in get_overlapping_areas():
				if area is CharacterBase:
					if area == damage_info.attacker:
						continue

					if area in hit_targets:
						continue
					
					if area.is_dead:
						continue
						
					hit_targets.append(area)

					damage_info.victim = area
				
					damage_info.attacker.on_deal_projectile_hit(self)
					damage_info.victim.on_take_projectile_hit(self)

					Combat.apply_damage(damage_info)

					if !pierce:
						queue_free()
						return

			if traveled_distance >= max_distance:
				queue_free()


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
