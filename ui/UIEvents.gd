# Autoload (Project Settings → Autoload): UIEvents.gd
extends Node

# Combat Events
signal target_changed(target: Node)
signal target_health_changed(current: int, maximum: int)
signal player_health_changed(current: int, maximum: int)
signal player_mana_changed(current: int, maximum: int)
signal damage_dealt(target: Node, amount: int, is_critical: bool)
signal damage_taken(amount: int, attacker: Node)

# Status Events
signal buff_applied(buff_name: String, duration: float, icon: Texture)
signal buff_removed(buff_name: String)
signal status_effect_added(effect_name: String, stacks: int)

# Chat/Log Events
signal chat_message(message: String, color: Color)
signal combat_log_entry(text: String)

# Inventory Events
signal item_acquired(item_name: String, quantity: int)
signal inventory_updated()

# Quest Events
signal quest_updated(quest_name: String, progress: String)
signal quest_completed(quest_name: String)

# XP/Level Events
signal experience_gained(amount: int)
signal level_up(new_level: int)

# General
signal loading_started(scene_name: String)
signal loading_finished()
