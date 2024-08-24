class_name RoundSingleEnemyData
extends Resource


## This Resource holds all the variables a Round needs to spawn at least one Enemy.
## This Resource is only meant to spawn one kind of Enemy,
## BUT many times, or somehow edited, or at specific intervals.


## The single Enemy kind this Resource allows to spawn.
@export var enemy_scene: PackedScene

## How many of these enemy_scene Enemies will spawn.
@export_range(1, 9999, 1) var number_of_enemies: int = 1

## How much time must pass between each single Enemy is spawned (in seconds).
@export_range(0.01, 10, 0.01) var enemy_spawn_interval: float = 0.1
## NOTE: Only relevant if (number_of_enemies > 0),
## NOTE: but I don't think it's worth making this script more advanced with @tool...

## When this Resource is exhausted, this variable controls how much time must pass until
## the next Resource like this is activated by the Round (in seconds)
@export_range(0.01, 10, 0.01) var time_until_next_enemies: float = 1.0
