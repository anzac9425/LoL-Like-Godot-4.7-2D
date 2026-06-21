extends CharacterLogic


var charges: float
var last_position: Vector2


func _ready() -> void:
	last_position = character_base.global_position


func _physics_process(_delta: float) -> void:
	if charges < 100:
		add_charges(character_base.global_position.distance_to(last_position) / 24.0)
	
	last_position = character_base.global_position


func add_charges(value: float):
	var old_energized: bool = charges >= 100.0

	charges = min(100.0, charges + value)

	var new_energized: bool = charges >= 100.0

	if old_energized != new_energized:
		character_base.calculate_statistics()


func on_attack(_damage_info: DamageInfo) -> void:
	add_charges(6.0)


func on_hit(damage_info: DamageInfo) -> void:
	if charges >= 100.0:
		charges = 0.0
		
		damage_info.add_damage_instance(DamageType.Type.MAGIC, SourceType.Type.ITEM, 40.0, false, false)
		
		character_base.calculate_statistics()


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


func modify_total_statistics(_base_statistics: Statistics, bonus_statistics: Statistics, raw_total_statistics: Statistics) -> void:
	bonus_statistics.attack_range += 0.35 * raw_total_statistics.attack_damage


func on_deal_damage(_damage_info: DamageInfo) -> void:
	pass


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_lethal_damage(_damage_info: DamageInfo) -> bool:
	return false


func on_cast(_source_type: SourceType.Type) -> void:
	pass
