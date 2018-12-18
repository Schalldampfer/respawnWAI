private["_unit","_hit","_damage","_source","_ammo"];
_unit = _this select 0;
_hit = _this select 1;
_damage = _this select 2;
_source = _this select 3;
_ammo = _this select 4;

if (_hit == "") then {
	if (((damage _unit + _damage) > 0.89) && (alive _unit)) then {
		_unit removeAllEventHandlers "GetOut";
		{
			_x action ["eject",_unit];
			unassignVehicle _x;
		} forEach (crew _unit);
		_unit spawn {
			sleep 1;
			_this setDamage 1;
		};
	};
};
if (_hit == "motor") then {
	if (((([_unit,_hit] call object_getHit) + _damage) > 0.88) && {alive _unit}) then {
		_damage = 0.88;
	};
};

_damage
