extends CharacterLogic


var stack: Stack = Stack.new()
var amount: float


func _ready() -> void:
	stack.cooldown.remaining_duration = 8.0


func _physics_process(delta: float) -> void:
	if stack.cooldown.remaining_duration > 0:
		if stack.stack < 4.0:
			stack.cooldown.remaining_duration -= delta
		
		if stack.cooldown.remaining_duration <= 0:
			if stack.stack < 4.0:
				stack.stack = min(4.0, stack.stack + 1.0)
			
			stack.cooldown.remaining_duration = 8.0


func on_attack(_damage_info: DamageInfo) -> void:
	pass


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


func modify_total_statistics(_base_statistics: Statistics, bonus_statistics: Statistics, raw_total_statistics: Statistics) -> void:
	bonus_statistics.attack_damage += 0.02 * raw_total_statistics.mana


func on_deal_damage(damage_info: DamageInfo) -> void:
	var active: bool = false
	
	for instance in damage_info.damage_instances:
		match instance.source_type:
			SourceType.Type.AUTO_ATTACK:
				active = true
			
			SourceType.Type.SKILL_Q:
				active = true
			
			SourceType.Type.SKILL_W:
				active = true
			
			SourceType.Type.SKILL_E:
				active = true
			
			SourceType.Type.SKILL_R:
				active = true
	
	if !active:
		return
	
	Combat.apply_mana_restore(character_base, 6.0)
	
	amount += 6.0
	if amount >= 360.0:
		for i in range(character_base.items.size() -1, -1, -1):
			var item: ItemData = character_base.items[i]
			
			if item.item_name == "manamune":
				if item.item_logic.amount >= 360.0:
					character_base.items.remove_at(i)
					character_base.add_item(load(Paths.ITEM_DATA_MURAMANA))
	
	stack.stack -= 1.0


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
