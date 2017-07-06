onMapSingleClick "mapclick = false; false"; 

switch (AIS_SelectedSupportType) do {
    case "artillery": 
    { 
        //Get Selected Shell Type
        _shellTypeIndex = lbCurSel AIS_Dialog_Artillery_RoundTypeToFire;          
        _shellType = lbData [AIS_Dialog_Artillery_RoundTypeToFire, _shellTypeIndex];

        //Get Selected Shell Count
        _roundsIndex =  lbCurSel AIS_Dialog_Artillery_RoundNumberToFire; 
        _shellCount = lbValue [AIS_Dialog_Artillery_RoundNumberToFire, _roundsIndex];
 
        //Get Selected Unit
 	    _index =  lbCurSel AIS_Dialog_Artillery_UnitList;           
        _unit = AIS_Artillery_Units select _index;
     
        //[Class [Class Name, Title], Description, Cost, Respect, Required Items, Min Rounds To Fire, Max Rounds To Fire, Accuracy,  RespectEarned per round fired]	
        _accuracy =  if (count _unit > 7) then [{_unit select 7 }, {100}];
        _cost = if (count _unit > 2) then [{_unit select 2 }, {100}];
        _respect = if (count _unit > 3) then [{_unit select 3 }, {100}];
        _respectEarned = if (count _unit > 8) then [{_unit select 8 }, {0}];
        _respectEarned = _respectEarned * _shellCount;

        _lockerMoney = player getVariable ["ExileLocker", 99];
        _playerMoney = player getVariable ["ExileMoney", 9999];          
	    _playerRespect = ExileClientPlayerScore; 

        if(_playerMoney + _lockerMoney < _cost) exitWith {
            ["errorTitleAndText",    
                [
                    "AI Support - Fire Mission",  
                    "You need more pop tabs for the fire mission..."
                ]
            ] call ExileClient_gui_toaster_addTemplateToast;             
        };
        if(_playerRespect < _respect) exitWith {
            ["errorTitleAndText",    
                [
                    "AI Support - Fire Mission",  
                    "You need more respect for the fire mission..."
                ]
            ] call ExileClient_gui_toaster_addTemplateToast;                          
        };



        [_shellCount, _shellType, targetPos, _accuracy] spawn AIS_Client_fnc_FireVirtualArtillery;
        targetPos = nil;
 
        if(_playerMoney >= _cost) then {
            [player, _playerMoney - _cost] remoteExec ["AIS_Server_fnc_SetPlayerMoney", 2];                        
        }
        else {
            [player, _lockerMoney - _cost] remoteExec ["AIS_Server_fnc_SetPlayerLocker", 2];                        
        }; 

        [player, _playerRespect + _respectEarned] remoteExec ["AIS_Server_fnc_SetPlayerRespect", 2];      

        ["infoTitleAndText",    
            [
                "AI Support - Fire Mission",  
                format["Fire mission called costing you %1 pop tabs. You earned %2 respect.", _cost, _respectEarned]
            ]
        ] call ExileClient_gui_toaster_addTemplateToast;                           
    };
    case "cas": 
    { 
        _index = lbCurSel AIS_Dialog_Cas_UnitList;          
        _aircraftType = lbData [AIS_Dialog_Cas_UnitList, _index];

        _durationIndex =  lbCurSel AIS_Dialog_Cas_Duration; 
        _duration = lbValue [AIS_Dialog_Cas_Duration, _durationIndex];
        
        _item = AIS_Cas_Units select _index;

        _cost = if (count _item > 2) then [{_item select 2 }, {100}];
        _respect = if (count _item > 3) then [{_item select 3 }, {100}];
        _respectEarned = if (count _item > 5) then [{_item select 5 }, {0}];

	    _lockerMoney = player getVariable ["ExileLocker", 99];
	    _playerMoney = player getVariable ["ExileMoney", 9999];     

	    _playerRespect = ExileClientPlayerScore;     

        if(_playerMoney + _lockerMoney < _cost) exitWith {
            ["errorTitleAndText",    
                [
                    "AI Support - CAS",  
                    "You need more pop tabs for this CAS mission..."
                ]
            ] call ExileClient_gui_toaster_addTemplateToast;                                       
        };
        if(_playerRespect < _respect) exitWith {
            ["errorTitleAndText",    
                [
                    "AI Support - CAS",  
                    "You need more respect for this CAS mission..."
                ]
            ] call ExileClient_gui_toaster_addTemplateToast;                                       
        };

        [_aircraftType, _duration] spawn AIS_Client_fnc_LaunchVirtualCas;
        targetPos = nil;
 

        if(_playerMoney >= _cost) then {
            [_playerMoney - _cost] call SetPlayerMoney;            
        }
        else {
            [_lockerMoney - _cost] call SetPlayerLocker; 
        }; 
        [player, _playerRespect + _respectEarned] remoteExec ["AIS_Server_fnc_SetPlayerRespect", 2];  

        ["infoTitleAndText",    
            ["AI Support - CAS",  
              format["CAS mission called costing you %1 pop tabs. You earned %2 respect.", _cost, _respectEarned]]
        ] call ExileClient_gui_toaster_addTemplateToast; 
    };    
    case "supply": 
    {  
        _crateList = ((findDisplay AIS_Dialog) displayCtrl (AIS_Dialog_Resupply_CrateList));	
        _totalCost = 0;
        _items = [];

        for "_i" from 0 to (lbSize _crateList - 1) do {  
            private["_type"];

             _class = _crateList lbData _i;
             _value = _crateList lbValue _i;
            
            _totalCost = _totalCost + _value;

            _items = _items + [_class];
        };
        
        _deliveryVehicleIndex = lbCurSel AIS_Dialog_Resupply_DeliveryVehicle;           
        _selectedAircraftItem = AIS_Resupply_Delivery_Vehicles select _deliveryVehicleIndex;
 
        _cost = if (count _selectedAircraftItem > 2) then [{_selectedAircraftItem select 2 }, {100}];
        _respect = if (count _selectedAircraftItem > 3) then [{_selectedAircraftItem select 3 }, {100}];
        _respectEarned = if (count _selectedAircraftItem > 5) then [{_selectedAircraftItem select 5 }, {0}];

        _totalCost = _totalCost + _cost;

        _lockerMoney = player getVariable ["ExileLocker", 99];
        _playerMoney = player getVariable ["ExileMoney", 9999];          
	    _playerRespect = ExileClientPlayerScore;  

        if(_playerMoney + _lockerMoney < _totalCost) exitWith {
            ["errorTitleAndText",    
                [
                    "AI Support - Resupply",  
                    "You need more pop tabs for this resupply mission..."
                ]
            ] call ExileClient_gui_toaster_addTemplateToast;   
        };
        if(_playerRespect < _respect) exitWith {
            ["errorTitleAndText",    
                [
                    "AI Support - Resupply",  
                    "You need more respect for this resupply mission..."
                ]
            ] call ExileClient_gui_toaster_addTemplateToast;                          	
        };

 
        _selectedVicIndex = lbCurSel AIS_Dialog_Resupply_DeliveryVehicle;    
        _vicClass = (AIS_Resupply_Delivery_Vehicles select _selectedVicIndex) select 0;

        [_items, _vicClass] spawn AIS_Client_fnc_SupplyDropService; 

        if(_playerMoney >= _totalCost) then {
            [_playerMoney - _totalCost] call SetPlayerMoney;            
        }
        else {
            [_lockerMoney - _totalCost] call SetPlayerLocker; 
        }; 
 
        ["infoTitleAndText",    
            ["AI Support - Resupply",  
              format["Resupply mission called costing you %1 pop tabs. You earned %2 respect.", _totalCost, _respectEarned]]
        ] call ExileClient_gui_toaster_addTemplateToast; 
    };       
};

closeDialog AIS_Dialog;
AIS_SelectedSupportType = nil;