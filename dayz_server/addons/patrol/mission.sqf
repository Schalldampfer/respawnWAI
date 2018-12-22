private ["_BH_ratio","_heli_num","_heliList","_helis","_vehicle_num","_vehicleList","_vehicles","_cityAI","_villageAI","_villageAI_chance","_positions"];
if (!PT_activate_patrol) exitWith {};

/* config */
_BH_ratio = ["Bandit","Bandit","Bandit","Hero"];

//chopper patrol in this script
_heli_num = 3; // number of heli patrol
_heliList = [ // list of heli patrol, [classname,chance in integer]
	["Mi17_DZ",1],
	["Mi17_TK_EP1_DZ",1],
	["Mi17_CDF_DZ",1],
	["Mi171Sh_CZ_EP1_DZ",1],
	["UH1H_DZ",1],
	["UH1H_2_DZ",1],
	["UH1Y_DZ",1],
	["MH60S_DZ",1],
	["UH60M_EP1_DZ",1],
	["Mi17_UN_CDF_EP1_DZE",1],
	["Mi17_Civilian_DZ",1],
	["AH6J_EP1_DZ",1],
	["CSJ_GyroP",1],
	["Ka137_PMC",1],
	["Ka137_MG_PMC",1],
	["GNT_C185T",1],
	["CYBP_Camel_us",1],
	["CYBP_Camel_rus",1],
	["Pchela1T_CDF",1],
	["Pchela1T",1]
];

//vehicle patrol in this script
_vehicle_num = 3; // number of heli patrol
_vehicleList = [ // list of heli patrol, [classname,chance in integer]
	["BAF_Offroad_W",1],
	["BAF_Offroad_D",1],
	["LandRover_CZ_EP1",1],
	["LandRover_TK_CIV_EP1",1],
	["BTR40_TK_GUE_EP1",1],
	["BTR40_TK_INS_EP1",1],
	["Ikarus",1],
	["Ikarus_TK_CIV_EP1",1],
	["V3S_Open_TK_EP1",1],
	["V3S_Open_TK_CIV_EP1",1],
	["UralOpen_CDF",1],
	["UralOpen_INS",1],
	["UralCivil2_DZE",1],
	["Ural_ZU23_Gue", 1],
	["Ural_ZU23_TK_GUE_EP1", 1],
	["Offroad_SPG9_Gue", 1],
	["LandRover_SPG9_TK_INS_EP1", 1],
	["Pickup_PK_TK_GUE_EP1_DZ", 1],
	["Pickup_PK_INS_DZ", 1],
	["Pickup_PK_GUE_DZ", 1]
];

// Town Bandits
_cityAI	 = true; // bandits on big cities
_villageAI	 = true; // bandits on village and hills
_villageAI_chance = 0.01; // spawn chance

/* run */

//spawn chopper patrol
_helis = [];
{
	for "_i" from 1 to (_x select 1) do {
		_helis = _helis + [_x select 0];
	};
} foreach _heliList;
diag_log format["[Patrol] Choppers:%1",_helis];

for "_i" from 1 to _heli_num do {
	private ["_adm"];
	_adm = _BH_ratio call BIS_fnc_selectRandom;
	//spawn
	[
		[getMarkerPos "center",0,((getMarkerSize "center") select 1)/2,15,0,1.0,0] call BIS_fnc_findSafePos,
		((getMarkerSize "center") select 1)/2,
		10,
		_helis,
		"Random",
		_adm,
		_adm
	] spawn PT_heli_patrol;
};

//spawn vehicle patrol
_vehicles = [];
{
	for "_i" from 1 to (_x select 1) do {
		_vehicles = _vehicles + [_x select 0];
	};
} foreach _vehicleList;
diag_log format["[Patrol] Vehicles:%1",_vehicles];

for "_i" from 1 to _vehicle_num do {
	private ["_adm","_dest","_strt","_rad"];
	_adm = _BH_ratio call BIS_fnc_selectRandom;
	_rad = 1000;
	//spawn
	[
		PT_roadpos,
		PT_roadpos,
		_rad,
		10,
		_vehicles,
		"Random",
		_adm,
		_adm
	] spawn PT_vehicle_patrol;
};

//spawn town AIs
if (_cityAI) then {
{
	private ["_pos","_text"];
	_text=text _x;
	if (_text != "") then {
		_pos = locationPosition _x;
		
		//safezone check
		if ({_pos distance (_x select 0) < ((_x select 1) * 10)} foreach DZE_SafeZonePosArray) exitWith {};
		
		//spawn
		[_pos,ceil(random 4) + 2,"Medium",0,5,"Random","Bandit","Random",_BH_ratio call BIS_fnc_selectRandom] spawn PT_spawn_group;
		diag_log format["[Patrol] Town Infantry @ %1 %2",_text,_pos];
	};
} foreach (nearestLocations [getMarkerPos "center", ["NameCityCapital","NameCity"],(getMarkerSize "center") select 1]);
};

if (_villageAI) then {
{
	private ["_pos","_text"];
	_text=text _x;
	if (_text != "" && ((random 1) < _villageAI_chance)) then {
		_pos = locationPosition _x;
		
		//safezone check
		if ({_pos distance (_x select 0) < ((_x select 1) * 10)} foreach DZE_SafeZonePosArray) exitWith {};
		
		//spawn
		[_pos,ceil(random 4),"Easy",0,3,"none","Bandit",1,"Bandit"] spawn PT_spawn_group;
		diag_log format["[Patrol] Village Infantry @ %1 %2",_text,_pos];
	};
} foreach (nearestLocations [getMarkerPos "center", ["NameLocal","NameVillage","Hill"],(getMarkerSize "center") select 1]);
};
