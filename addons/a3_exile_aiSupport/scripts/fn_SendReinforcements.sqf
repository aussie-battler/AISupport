try
{	
	vic = (_this select 0);	
	smokeOut = false;

	_group = vic getVariable "group";
	_name = vic getVariable "callSign";
	_homePoint = vic getVariable "originalPosition";
	_callSign = vic getVariable ["callSign", vic];

	if (isNull vic) exitWith
    {
        diag_log format["AISupport ERROR :: Null vic in AISupport_Reinforcements (index %1). Parameters: %2", _forEachIndex, AISupport_Reinforcements deleteAt _forEachIndex];
    };

    if !(alive vic) exitWith
    { 
		
    }; 

	vic engineOn true; 

	if(vic getVariable ["isContinuous", false]) then {		
		_originalWaypoints = waypoints _group;
  
		{
			deleteWaypoint _x;
		} foreach (waypoints _group);
	};
	 	
	_wp = _group addWaypoint [position player, 0];	
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointCombatMode "GREEN"; 
	_wp setWaypointType "MOVE";
	_group setCurrentWaypoint _wp;

	_playerGroup = group player;
	  
	_reinforcementRequest = player addEventHandler ["Fired", {  
		switch (_this select 4) do {
			case "SmokeShellRed";
			case "SmokeShellGreen";
			case "SmokeShellYellow";
			case "SmokeShellPurple";
			case "SmokeShellBlue";
			case "SmokeShellOrange";
			case "SmokeShell": { 		   
				[_this select 6] spawn {
					_smoke = _this select 0;  				
					sleep 2;
					smokeOut = true; 		
					[vic , 25, (getPosASL _smoke)] call AR_Rappel_All_Cargo;
				}
			};    
			default {  };
		};
	}];
	
 	waitUntil{(vic distance2D (getPos player)) <= 750};  
 	vic allowDamage (true);  
	{
 		_x allowDamage (true); 
	} forEach crew vic; 
	 

	_doHeliIntro = true;
	if(!smokeOut) then {
		_doHeliIntro = false;
			_callSign call AISupport_Message_Reinforcements_PopSmoke;
		};
		_count = 1;
		_continueWithMission = true;
		while{!smokeOut} do {
			sleep 10;
			if(smokeOut)
				exitWith{true};
			if(_count == 1) then {
				_callSign call AISupport_Message_Reinforcements_PopSmoke_Again;
			};
			if(_count == 2) then {
				_callSign call AISupport_Message_Reinforcements_PopSmoke_Again;
			};
			if(_count == 3) then {
				_callSign call AISupport_Message_Reinforcements_PopSmoke_LastTime;
			};
			if(_count == 4) then {
				_continueWithMission = false;
				_callSign call AISupport_Message_Reinforcements_PopSmoke_RTB;				
				vic land "NONE"; 	
				vic move (_homePoint); 
				sleep 3;

				while { ( (alive vic) && !(unitReady vic) ) } do
				{
						sleep 1;
				};

				if (alive vic) then
				{
						vic land "LAND";
						waitUntil {isTouchingGround vic};
						sleep 5;
						_activeSupportUnits = player getVariable ["ActiveSupportUnits", []];
						_activeSupportUnits = _activeSupportUnits - [vic];
						player setVariable ["ActiveSupportUnits", _activeSupportUnits];
						vic setVariable ["missionComplete",true];
				}; 	
			};
			_count = _count + 1;
	};
	player removeEventHandler ["Fired", _reinforcementRequest];
	if(!_continueWithMission)
		exitWith{
		
		};
 
   _callSign call AISupport_Message_Reinforcements_OnLocation;

	sleep 5; 

	_rappelling = vic getVariable "AR_Units_Rappelling";
	while {!isNil "_rappelling"} do {
		_rappelling = vic getVariable "AR_Units_Rappelling";
		sleep 1;
	};  
	
	(group player) setBehaviour "COMBAT";
	(group player) setCombatMode "RED";

	deleteWaypoint _wp;
	vic land "NONE"; 	
	vic move (_homePoint); 
	sleep 3;

	waitUntil{(vic distance2D (_homePoint)) < 500};  
	_group setCombatMode "BLUE"; 

	 

	while { ( (alive vic) && !(unitReady vic) ) } do
	{
			sleep 1;
	};

	if (alive vic) then
	{
			vic land "LAND";
	
			waitUntil {isTouchingGround vic}; 
			sleep 5; 
			vic setVariable ["missionComplete",true];
	}; 	
 }
catch
{	
	diag_log format ["AI SUPPORT ERROR :: Calling AISupport_fnc_RequestReinforcements with error: %1",_exception];
}