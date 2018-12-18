// // // AT YOUR OWN LISK, EDIT BELOW - NO SUPPORT PROVIDED IF YOU EDIT BELOW // // //

PT_wait_for_WAI = {
	waitUntil{!isNil "WAIconfigloaded"};
	waitUntil{WAIconfigloaded};
	true
};
call PT_wait_for_WAI; // wait for WAI loaded

call compile preprocessFileLineNumbers "\z\addons\dayz_server\addons\patrol\config.sqf";// load config

/* functions */
PT_veh_dropcrate = compile preprocessFileLineNumbers "\z\addons\dayz_server\addons\patrol\veh_dropcrate.sqf";
PT_heli_damage = compile preprocessFileLineNumbers "\z\addons\dayz_server\addons\patrol\heli_damage.sqf";

PT_add_cargoUnits = {
	private ["_unitGroup","_vehicle","_skin","_skill","_aitype","_cargoSpots","_i","_cargo","_aicskill","_weapon","_magazine"];
	_unitGroup = _this select 0;
	_vehicle = _this select 1;
	_skill = _this select 2;
	_skin = _this select 3;
	_aitype = _this select 4;
	
	_cargoSpots = ceil((_vehicle emptyPositions "cargo") * PT_cargo_ratio);
	for "_i" from 0 to (_cargoSpots - 1) do {
		//select skin
		if(_skin == "random") 	then { _skin = ai_all_skin call BIS_fnc_selectRandom; };
		if(_skin == "hero") 	then { _skin = ai_hero_skin call BIS_fnc_selectRandom; };
		if(_skin == "bandit") 	then { _skin = ai_bandit_skin call BIS_fnc_selectRandom; };
		if(_skin == "special") 	then { _skin = ai_special_skin call BIS_fnc_selectRandom; };
		if(typeName (_skin) == "ARRAY") then { _skin = _skin call BIS_fnc_selectRandom; };
		
		//spawn
		_cargo = _unitGroup createUnit [_skin, [0,0,0], [], 1, "NONE"];
		_cargo setVariable ["bodyName",(name _cargo)];
		_cargo addEventHandler ["Killed",{[_this select 0, _this select 1] call on_kill;}];
		[_cargo] joinSilent _unitGroup;
		
		//skill
		_aicskill = call {
			if(_skill == "easy") exitWith {ai_skill_easy;};
			if(_skill == "medium") exitWith {ai_skill_medium;};
			if(_skill == "hard") exitWith {ai_skill_hard;};
			if(_skill == "extreme") exitWith {ai_skill_extreme;};
			if(_skill == "random") exitWith {ai_skill_random call BIS_fnc_selectRandom;};
			ai_skill_random select (floor (random (count ai_skill_random)));
		};
		{
			_cargo setSkill [(_x select 0),(_x select 1)];
		} count _aicskill;
		
		//weapon
		_weapon = (ai_wep_random call BIS_fnc_selectRandom) call BIS_fnc_selectRandom;
		_magazine = _weapon call find_suitable_ammunition;
		removeAllWeapons _cargo;
		removeAllItems _cargo;
		for "_i" from 1 to 4 do {
			_cargo addMagazine _magazine;
		};
		_cargo addWeapon _weapon;
		if (sunOrMoon != 1) then {
			_cargo addWeapon "NVGoggles";
		};
		
		//backpack items
		_cargo addBackpack (ai_packs call BIS_fnc_selectRandom);
		{
			(unitBackpack _cargo) addMagazineCargoGlobal [_x, 1];
		} count ((ai_gear_random call BIS_fnc_selectRandom) select 0);
		
		//humanity
		call {
			if (_aitype == "hero") exitWith {_cargo setVariable ["Hero",true]; _cargo setVariable ["humanity", ai_remove_humanity];};
			if (_aitype == "bandit") exitWith {_cargo setVariable ["Bandit",true]; _cargo setVariable ["humanity", ai_add_humanity];};
			if (_aitype == "special") exitWith {_cargo setVariable ["Special",true]; _cargo setVariable ["humanity", ai_special_humanity];};
		};
	
		//movein
		_cargo assignAsCargo _vehicle;
		_cargo moveInCargo [_vehicle,_i];
	};
	(units _unitGroup) allowGetIn true;
	_vehicle allowCrewInImmobile false;
};

PT_roadpos = [];//road position
{
	private ["_pos","_text"];
	_text=text _x;
	if (_text != "") then {
		_pos = locationPosition _x;
		_pos = getpos ((_pos nearroads 300) select 0);
		if (isNil "_pos") exitWith {};
		if ({_pos distance (_x select 0) < ((_x select 1) * 10)} foreach DZE_SafeZonePosArray) exitWith {};
		PT_roadpos set [count PT_roadpos, _pos];
	};
} foreach (nearestLocations [getMarkerPos "center", ["NameCityCapital","NameCity","NameVillage"],(getMarkerSize "center") select 1]);

PT_heli_patrol = {
	private ["_class","_skill","_skin","_unitGroup","_vehicle","_dot","_time","_vehname"];
	_class		 = _this select 3;
	_skill		 = _this select 4;
	_skin		 = _this select 5;

	while {true} do {
		//check players login
		while {{alive _x} count playableUnits < PT_wait_players} do {
			sleep 10;
		};

		// select class name if it's array
		if(typeName (_class) == "ARRAY") then {
			_class = _class call BIS_fnc_selectRandom;
		};
		_this set [3, _class];
		
		// spawn heli
		_unitGroup = _this call heli_patrol;
		_vehicle = vehicle (leader _unitGroup); //get vehicle object
		_vehname = getText (configFile >> "CfgVehicles" >> _class >> "displayName");
		diag_log format["[Patrol] %1 %2",_vehname,_this];
		_vehicle lock false;
		
		//Add units
		[_unitGroup,_vehicle,_skill,_skin,_this select 6] call PT_add_cargoUnits;
		_unitGroup allowFleeing 0;
		
		//EHs - spawn crate and eject crew
		_vehicle removeAllEventHandlers "GetOut";
		_vehicle addEventHandler ["HandleDamage",{_this call PT_heli_damage}];
		if (PT_crate) then {
			_vehicle addEventHandler ["Killed",{_this spawn PT_veh_dropcrate}];
		};
		
		//monitor - wait until inactivated
		_time = diag_tickTime;
		_dot = createMarker ["", [0,0,0]];
		while {!(isNull _vehicle) && (count (crew _vehicle) > 0) && (!isPlayer (effectiveCommander _vehicle)) && (fuel _vehicle > 0) && (damage _vehicle < 1)} do {
			if (PT_Marker) then {
				deleteMarker _dot;
				_dot = createMarker [format["PatrolDot%1%2",_class,floor(random 20)], getPos _vehicle];
				_dot setMarkerColor "ColorRed";
				_dot setMarkerType "mil_dot";
				_dot setMarkerText format["Patrol %1",_vehname];
				_dot setMarkerSize [0.5,0.5];
			};
			sleep 5;
			if ((diag_tickTime - _time) > PT_heli_partol_time) exitWith {
				{_x action ["Eject", _vehicle];_x setDamage 1;} foreach (crew _vehicle);
				_vehicle removeAllEventHandlers "HandleDamage";
				_vehicle setDamage 2;
				diag_log format["[Patrol] suicided %1", _vehicle];
			};
		}; //while vehicle alive
		
		diag_log format["[Patrol] %1 finished its duty",_vehname];
		
		deleteMarker _dot;
		sleep PT_heli_patrol_wait; //wait...wait...
	};
};

PT_vehicle_patrol = {
	private ["_dest","_strt","_rad","_class","_skill","_skin","_unitGroup","_vehicle","_dot","_vehname","_test"];
	_dest		 = _this select 0;
	_strt		 = _this select 1;
	_rad		 = _this select 2;
	_class		 = _this select 4;
	_skill		 = _this select 5;
	_skin		 = _this select 6;

	while {true} do {
		//check players login
		while {{alive _x} count playableUnits < PT_wait_players} do {
			sleep 10;
		};

		// select class name if it's array
		if(typeName (_class) == "ARRAY") then {
			_class = _class call BIS_fnc_selectRandom;
		};
		_this set [4, _class];
		
		//select wp
		if((typeName (_dest select 0)) == "ARRAY") then {
			_dest = _dest call BIS_fnc_selectRandom;
		};
		_this set [0, _dest];
		if((typeName (_strt select 0)) == "ARRAY") then {
			_test = _strt call BIS_fnc_selectRandom;
			while {(_dest distance _test) < _rad} do {_test = _strt call BIS_fnc_selectRandom;};
			_strt = _test;
		};
		_this set [1, _strt];
		
		// spawn vehicle
		_unitGroup = _this call vehicle_patrol;
		_vehicle = vehicle (leader _unitGroup); //get vehicle object
		_vehname = getText (configFile >> "CfgVehicles" >> _class >> "displayName");
		diag_log format["[Patrol] %1 %2",_vehname,_this];
		_vehicle lock false;
		_unitGroup setVariable ["assignedVehicle",_vehicle];
		
		//Add units
		[_unitGroup,_vehicle,_skill,_skin,_this select 7] call PT_add_cargoUnits;
		_unitGroup allowFleeing 0;
		
		//EHs - spawn crate and eject crew
		_vehicle removeAllEventHandlers "GetOut";
		if (PT_crate) then {
			_vehicle addEventHandler ["Killed",{_this spawn PT_veh_dropcrate}];
		};
		
		//monitor - wait until inactivated
		_dot = createMarker ["", [0,0,0]];
		while {!(isNull _vehicle) && (count (crew _vehicle) > 0) && (!isPlayer (effectiveCommander _vehicle)) && (fuel _vehicle > 0) && (damage _vehicle < 1)} do {
			if (PT_Marker) then {
				deleteMarker _dot;
				_dot = createMarker [format["PatrolDot%1%2",_class,floor(random 20)], getPos _vehicle];
				_dot setMarkerColor "ColorRed";
				_dot setMarkerType "mil_dot";
				_dot setMarkerText format["Patrol %1",_vehname];
				_dot setMarkerSize [0.5,0.5];
			};
			sleep 5;
			if (({(_x distance _vehicle) > 150} count (assignedCargo _vehicle)) > 0) then {
				_loadWP = _unitGroup addWaypoint [getPos _vehicle,0];
				_loadWP setWaypointType "LOAD";
				_loadWPCond = "_vehicle = (group this) getVariable ['assignedVehicle',objNull]; ({_x == (vehicle _x)} count (assignedCargo _vehicle)) == 0";
				_loadWP setWaypointStatements [_loadWPCond,(format ["_unitGroup = (group this); deleteWaypoint [_unitGroup,%1]; _unitGroup setCurrentWaypoint [_unitGroup,0];",(_loadWP select 1)])];
				_loadWP setWaypointCompletionRadius 20;
				_unitGroup setCurrentWaypoint _loadWP;
			};
		}; //while vehicle alive
		
		diag_log format["[Patrol] %1 finished its duty",_vehname];
		
		deleteMarker _dot;
		sleep PT_vehicle_patrol_wait; //wait...wait...
	};
};

PT_spawn_group = {
	private ["_unitGroup","_arry","_dot","_time","_pos"];
	_arry = _this; // array for spawn_group
	_pos = _arry select 0;
	
	while {true} do {
		//check players login
		while {{alive _x} count playableUnits < PT_wait_players} do {
			sleep 10;
		};
		
		//check players gets close
		while {{(_x distance _pos) < PT_spawn_group_dist} count playableUnits < 1} do { //wait for players get close
			sleep 5;
		};
		
		// spawn units
		_unitGroup = _arry call spawn_group;
		diag_log format["[Patrol] Spawning %1 %2",name (leader _unitGroup),_pos];
		
		//monitor
		_time = diag_tickTime;
		_dot = createMarker ["", [0,0,0]];
		while {{alive _x} count (units _unitGroup) > 0} do {
			if (PT_Marker) then {
				deleteMarker _dot;
				_dot = createMarker [format["PatrolDot%1%2",floor(random 20) + 20], getpos (leader _unitGroup)];
				_dot setMarkerColor "ColorRed";
				_dot setMarkerType "mil_dot";
				//_dot setMarkerText format["Patrol %1",_arry select 6];
				_dot setMarkerSize [0.4,0.4];
			};
			sleep 5;
		}; //while vehicle alive
		
		diag_log format["[Patrol] Eliminated Infantry @ %1",_pos];
		
		deleteMarker _dot;
		sleep PT_spawn_group_wait; //wait...wait...
		
		//check players not too close
		while {{(_x distance _pos) < PT_respawn_group_dist} count playableUnits > 0} do { //wait for players get far
			sleep 10;
		};
	};
};

/* run */
call compile preProcessFileLineNumbers "\z\addons\dayz_server\addons\patrol\mission.sqf";

