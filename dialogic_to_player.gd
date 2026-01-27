extends Node

var player: Player
var ship: Ship
var price_scaling: float = 1.2

func get_player_carrying() -> int:
	return player.cargo_carrying

func get_player_money() -> int:
	return player.money

func get_upgrade_amount(upgrade: String) -> String:
	match upgrade:
		"o2_tank_size":
			return str(player.o2_tank_size_amount * player.o2_tank_size_level)
		"cargo_space":
			return str(player.cargo_space_amount * player.cargo_space_level)
	push_warning("get_upgrade_amount called for undefined response")
	return ""

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
		"ship_thruster_power":
			return ship.ship_thruster_power_level
		"cargo_space":
			return player.cargo_space_level
	push_warning("get_upgrade_level called with unknown upgrade name!")
	return 0

func can_upgrade(upgrade: String) -> bool:
	match upgrade:
		"suit_resilience":
			return (player.suit_resilience_level < player.suit_resilience_max_level and player.money >= calculate_price(upgrade))
		"suit_gravity_resistance":
			return (player.gravity_resistance_level < player.gravity_resistance_max_level and player.money >= calculate_price(upgrade))
		"suit_thruster_power":
			return (player.suit_thruster_power_level < player.suit_thruster_power_max_level and player.money >= calculate_price(upgrade))
		"o2_tank_size":
			return (player.o2_tank_size_level < player.o2_tank_size_max_level and player.money >= calculate_price(upgrade))
		"suit_repair":
			return (player.health < player.max_health and player.money >= calculate_price(upgrade))
		
		"ship_damage_resistance":
			return (ship.damage_resistance_level < ship.damage_resistance_max_level and player.money >= calculate_price(upgrade))
		"ship_gravity_resistance":
			return (ship.gravity_resistance_level < ship.gravity_resistance_max_level and player.money >= calculate_price(upgrade))
		"ship_thruster_power":
			return (ship.ship_thruster_power_level < ship.ship_thruster_power_max_level and player.money >= calculate_price(upgrade))
		"cargo_space":
			return (player.cargo_space_level < player.cargo_space_max_level and player.money >= calculate_price(upgrade))
		"ship_repair":
			return (ship.health < ship.maxHealth and player.money >= calculate_price(upgrade))
	push_warning("can_upgrade called with unknown upgrade name!")
	return false

func calculate_price(upgrade: String) -> int:
	match upgrade:
		"suit_resilience":
			return roundi(player.suit_resilience_price * (player.suit_resilience_level + 1) * pow(price_scaling, player.suit_resilience_level))
		"suit_gravity_resistance":
			return roundi(player.gravity_resistance_price * (player.gravity_resistance_level + 1) * pow(price_scaling, player.gravity_resistance_level))
		"suit_thruster_power":
			return roundi(player.suit_thruster_power_price * (player.suit_thruster_power_level + 1) * pow(price_scaling, player.suit_thruster_power_level))
		"o2_tank_size":
			return roundi(player.o2_tank_size_price * (player.o2_tank_size_level - 1) * pow(price_scaling, player.o2_tank_size_level - 2))
		"suit_repair":
			return roundi(player.repair_price)
		
		"ship_damage_resistance":
			return roundi(ship.damage_resistance_price * (ship.damage_resistance_level + 1) * pow(price_scaling, ship.damage_resistance_level))
		"ship_gravity_resistance":
			return roundi(ship.gravity_resistance_price * (ship.gravity_resistance_level + 1) * pow(price_scaling, ship.gravity_resistance_level))
		"ship_thruster_power":
			return roundi(ship.ship_thruster_power_price * (ship.ship_thruster_power_level + 1) * pow(price_scaling, ship.ship_thruster_power_level))
		"cargo_space":
			return roundi(player.cargo_space_price * (player.cargo_space_level - 1) * pow(price_scaling, player.cargo_space_level - 2))
		"ship_repair":
			return roundi(ship.repair_price)
	push_warning("calculate_price called with unknown upgrade name!")
	return false

func get_price_str(upgrade: String) -> String:
	return str(calculate_price(upgrade))

func perform_upgrade(upgrade: String):
	match upgrade:
		"suit_resilience":
			player.money -= calculate_price(upgrade)
			player.upgrade_suit_resilience()
			return
		"suit_gravity_resistance":
			player.money -= calculate_price(upgrade)
			player.upgrade_gravity_resistance()
			return
		"suit_thruster_power":
			player.money -= calculate_price(upgrade)
			player.upgrade_thruster_power()
			return
		"o2_tank_size":
			player.money -= calculate_price(upgrade)
			player.upgrade_o2_tank_size()
			return
		"suit_repair":
			player.money -= calculate_price(upgrade)
			player.repair_suit()
			return
		
		"ship_damage_resistance":
			player.money -= calculate_price(upgrade)
			ship.upgrade_damage_resistance()
			return
		"ship_gravity_resistance":
			player.money -= calculate_price(upgrade)
			ship.upgrade_gravity_resistance()
			return
		"ship_thruster_power":
			player.money -= calculate_price(upgrade)
			ship.upgrade_thruster_power()
			return
		"cargo_space":
			player.money -= calculate_price(upgrade)
			player.upgrade_cargo_size()
			return
		"ship_repair":
			player.money -= calculate_price(upgrade)
			ship.repair()
			return
	push_warning("can_upgrade called with unknown upgrade name!")
	return false
