# respawnWAI
### Description
- Respawning addon for WAI static missions

- Main functions for respawning units:
	PT_heli_patrol : respawning heli_patrol (Helicopter patrol with respawning function)
	PT_vehicle_patrol : respawning vehicle (Vehicle patrol with respawning function)
	PT_spawn_group : respawning spawn_group (Infantry patrol with respawning function)
	they use the same array as their corresponding WAI functions
- Additional sample :
	Patrol heli & cars / Roaming AIs on towns and hills

### Requirements
	WAI 2.2.5 or 2.2.6
	spawn_group, vehicle_patrol and heli_patrol must return _unitGroup

### Install
1.	Put these files in server. Structure: dayz_server\addons\patrol\*.sqf
2.	add ' execVM "\z\addons\dayz_server\addons\patrol\init_patrol.sqf"; ' at the end of dayz_server\init\server_functions.sqf

### Author
	Schalldampfer

