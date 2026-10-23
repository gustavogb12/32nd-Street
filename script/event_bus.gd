extends Node

signal attacked(source: Node, targwet: Node, damage: float)
signal entity_attacked(entity: EntityComponent)
signal entity_ready(entity: EntityComponent)
signal player_requested(enemy: Enemy)
