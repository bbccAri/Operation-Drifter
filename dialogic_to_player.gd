extends Node

var player: Player
var ship: Ship
var price_scaling: float = 1.2

func get_player_carrying() -> int:
	return player.cargo_carrying

func get_player_money() -> int:
	return player.money

func get_upgrade_level(upgrade: String) -> int:
	match upgrade:
		"suit_resilience":
			return player.suit_resilience_level
		"suit_gravity_resistance":
			return player.gravity_resistance_level
		"suit_thruster_power":
			return player.suit_thruster_power_level
		"o2_tank_size":
			return player.o2_tank_size_level
		
		"ship_damage_resistance":
			return ship.damage_resistance_level
		"ship_gravity_resistance":
			return ship.gravity_resistance_level
	push_warning("get_upgrade_level called with unknown upgrade name!")
	return 0

func can_upgrade(upgrade: String) -> bool:
	match upgrade:
		"suit_resilience":
			return (player.suit_resilience_level < player.suit_resilience_max_level and player.money >= roundi(player.suit_resilience_price * (player.suit_resilience_level + 1) * pow(price_scaling, player.suit_resilience_level)))
		"suit_gravity_resistance":
			return (player.gravity_resistance_level < player.gravity_resistance_max_level and player.money >= roundi(player.gravity_resistance_price * (player.gravity_resistance_level + 1) * pow(price_scaling, player.gravity_resistance_level)))
		"suit_thruster_power":
			return (player.suit_thruster_power_level < player.suit_thruster_power_max_level and player.money >= roundi(player.suit_thruster_power_price * (player.suit_thruster_power_level + 1) * pow(price_scaling, player.suit_thruster_power_level)))
		"o2_tank_size":
			return (player.o2_tank_size_level < player.o2_tank_size_max_level and roundi(player.money >= player.o2_tank_size_price * (player.o2_tank_size_level + 1) * pow(price_scaling, player.o2_tank_size_level)))
		"suit_repair":
			return (player.health < player.max_health)
		
		
		"ship_gravity_resistance":
			return (ship.gravity_resistance_level < ship.gravity_resistance_max_level and player.money >= ship.gravity_resistance_price * (ship.gravity_resistance_level + 1) * price_scaling)
	push_warning("get_upgrade_level called with unknown upgrade name!")
	return false
