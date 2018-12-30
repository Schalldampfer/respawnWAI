/*
Description:
	Respawning addon for WAI static missions
	
	Main functions for respawning units:
	PT_heli_patrol : respawning heli_patrol (Helicopter patrol with respawning function)
	PT_vehicle_patrol : respawning vehicle (Vehicle patrol with respawning function)
	PT_spawn_group : respawning spawn_group (Infantry patrol with respawning function)
	they use the same array as their corresponding WAI functions
	
	Additional sample :
	Patrol heli & cars / Roaming AIs on towns and hills
	
Requirements:
	WAI 2.2.5 or 2.2.6
	spawn_group, vehicle_patrol and heli_patrol must return _unitGroup
	
Install:
	1. Put these files in dayz_server\addons\patrol\
	2. add ' execVM "\z\addons\dayz_server\addons\patrol\init_patrol.sqf"; ' at the end of dayz_server\init\server_functions.sqf
Author:
	Schalldampfer
*/

/* config */
//general config
PT_log = false;					 // debug log
PT_Marker = false;				 // marker on/off
PT_wait_players = 1;			 // least number of players for AIs to respawn
PT_crate_despawn_time = 1200;	 // time until deleting reward crate
PT_despawn_time = 15*60;		 // time until vehicle units despawn

//patrol heli
PT_heli_patrol_wait = 600;		 // interval between being shot down and respawning heli
PT_heli_partol_time = 30*60;	 // patrol interval, they will sucide after this period
PT_heli_cargo_ratio = 0.3;		 // How many bandits get in vehicle as cargo

//patrol vehicle
PT_vehicle_patrol_wait = 450;	 // interval between being killed and respawning heli
PT_vehicle_cargo_ratio = 0.6;	 // How many bandits get in vehicle as cargo

// infantry
PT_spawn_group_wait = 1200;		 // interval between eliminated and respawn infantry
PT_spawn_group_dist = 2000;		 // max distance from players to spawn infantry
PT_respawn_group_dist = 1000;	 // least distance from players to respawn infantry

//rewards for respawning vehicles
PT_crate = true;				 // add reward crate on destroying
PT_crate_items = [				 // magazines (items)
	"ItemSodaPepsi","ItemSodaCoke","bulk_ItemSodaCokeFull","bulk_ItemSodaPepsiFull",
	"bulk_FoodbaconCookedFull","FoodNutmix","FoodPistachio",
	"ItemBandage","ItemAntibiotic","ItemBloodbag","ItemEpinephrine","ItemHeatPack","ItemMorphine",
	"ItemCanvas","ItemTent","bulk_ItemWire","bulk_ItemSandbag","bulk_ItemTankTrap","bulk_PartGeneric","MortarBucket","ItemLog","ItemPlank","ItemFertilizer",
	"PartEngine","PartFueltank","PartGlass","PartVRotor","PartWheel","ItemORP","ItemAVE","ItemLRK","ItemTNK","ItemARM","ItemNewspaper",
	"ItemDocument","ItemKiloHemp","ItemTinBar10oz","ItemBriefcaseS100oz","ItemBriefcase100oz","ItemBriefcase_Base","ItemObsidian","Laserbatteries"
];
PT_crate_tools = [				 // weapons (tools)
	"Binocular","ItemCompass","ItemCrowbar","ItemEtool","ItemFishingPole","ItemFlashlight","ItemHatchet","ItemKnife","ItemMatchbox","ItemToolbox","ChainSawB"
];
PT_humanity_vehicle = 100;		 // humanity for killing a vehicle

// addon missions
PT_activate_patrol = true;		 // activate Patrol heli & town AIs. Functions and configurations are in mission.sqf

