//Spawn loot crate
private ["_veh","_killer","_pos","_box","_objectID","_num","_item","_tool","_smoketype","_smoke"];
_veh = _this select 0;
_killer = _this select 1;

// add humanity
_killer setVariable ["humanity",(_killer getVariable ["humanity", 0]) + PT_humanity_vehicle,true]; // humanity

//wait until the vehicle hits ground
_veh setFuel 0;
_veh setVehicleAmmo 0;
while {(getPos _veh) select 2 > 1} do {
	sleep 1;
};

// spawn crate
sleep 2;
_box = "DZ_MedBox" createVehicle (getPos _veh);
_box allowDammage false;
_box setpos [(getpos _box) select 0, (getpos _box) select 1, 0];
_objectID = str(round(random 999999));
_box setVariable ["ObjectID", _objectID, true];
_box setVariable ["ObjectUID", _objectID, true];
_box setVariable ["permaLoot",true];
clearweaponcargoglobal _box;
clearmagazinecargoglobal _box;

// attach flare
if (sunOrMoon != 1) then {
	_smoketype = "RoadFlare";
} else {
	_smoketype = ["SmokeShellGreen","SmokeShellRed","SmokeShellYellow","SmokeShellPurple","SmokeShellBlue","SmokeShellOrange"] call BIS_fnc_selectRandom;
};
_smoke = _smoketype createVehicle (getPos _box);
_smoke attachTo [_box, [0,0,0]];
if (sunOrMoon != 1) then {
	PVDZ_obj_RoadFlare = [_smoke,0];
	publicVariable "PVDZ_obj_RoadFlare";
};

// add rewards
_num = (1 + (_veh emptyPositions "cargo")) * ((count (configFile >> "CfgVehicles" >> (typeOf _veh) >> "turrets")) + 2);
for "_i" from 0 to _num do {
	_tool = PT_crate_tools call BIS_fnc_selectRandom;
	_box addWeaponCargoGlobal [_tool,1];
};
_num = _num * ceil (random 3);
for "_i" from 0 to _num do {
	_item = PT_crate_items call BIS_fnc_selectRandom;
	_box addMagazineCargoGlobal [_item,1];
};

diag_log format ["[Patrol] AI patrol %1 spawned a crate @%2", typeOf _veh, getpos _box];

sleep 5;
_box allowDammage true;

// delete
sleep PT_crate_despawn_time;
deleteVehicle _box;
