extends Node
class_name CharacterLogic


var character_base: CharacterBase


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func on_deal_damage(_damage_info: DamageInfo) -> void:
	pass


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func cast_q() -> void:
	pass


func cast_w() -> void:
	pass


func cast_e() -> void:
	pass


func cast_r() -> void:
	pass
