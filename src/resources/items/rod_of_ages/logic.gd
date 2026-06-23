extends CharacterLogic


var stack: int
var cooldown: Cooldown = Cooldown.new()
var heal: float


func _ready() -> void:
	cooldown.remaining_duration = 60.0


func _physics_process(delta: float) -> void:
	if cooldown.remaining_duration > 0:
		cooldown.remaining_duration -= delta
		
		if stack < 10:
			if cooldown.remaining_duration <= 0:
				stack += 1
				
				if stack < 10:
					cooldown.remaining_duration = 60.0
				
				else:
					character_base.level += 1
				
				character_base.calculate_statistics()
	
	if heal > 0:
		var amount: float = min(heal, 20.0 * delta)

		heal -= amount

		Combat.apply_heal(character_base, amount)


func on_attack(_damage_info: DamageInfo) -> void:
	pass


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	bonus_statistics.health += 10.0 * stack
	bonus_statistics.mana += 20.0 * stack
	bonus_statistics.ability_power += 3.0 * stack


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


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


func on_spend_mana(amount: float) -> void:
	heal += min(20.0, amount / 4.0)


func on_cast(_source_type: SourceType.Type) -> void:
	pass
