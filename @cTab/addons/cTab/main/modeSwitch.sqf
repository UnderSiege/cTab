// cTab - Commander's Tablet with FBCB2 Blue Force Tracking
// Battlefield tablet to access real time intel and blue force tracker.
// By - Riouken
// http://forums.bistudio.com/member.php?64032-Riouken
// You may re-use any of this work as long as you provide credit back to me.

disableSerialization;

#include <\cTab\cTab_gui_macros.hpp>
#include <\cTab\usermenu_gui_macros.hpp>

cTabUserPos = [];

_display = (uiNamespace getVariable "cTab_main_dlg");

ctrlShow [IDC_CTAB_LOADINGTXT,true];
_loadingCtrl = _display displayCtrl IDC_CTAB_LOADINGTXT;
waitUntil {ctrlShown _loadingCtrl};

_btnActCtrl = _display displayCtrl IDC_CTAB_BTNACT;

_displayItems = [
	3300,3301,3302,3303,3304,3305,3306,
	IDC_CTAB_GROUP_DESKTOP,
	IDC_CTAB_GROUP_UAV,
	IDC_CTAB_GROUP_HCAM,
	IDC_CTAB_GROUP_MESSAGE,
	IDC_CTAB_MINIMAPBG,
	IDC_CTAB_CTABHCAMMAP,
	IDC_CTAB_CTABUAVMAP,
	IDC_CTAB_SCREEN,
	IDC_CTAB_SCREEN_TOPO,
	IDC_CTAB_HCAM_FULL
];
_displayItemsToShow = [];

_mode = _this select 0;

call {
	// ---------- DESKTOP -----------
	if (_mode == "DESKTOP") exitWith {
		_displayItemsToShow = [IDC_CTAB_GROUP_DESKTOP];
		_btnActCtrl ctrlSetText "";
		_btnActCtrl ctrlSetTooltip "";
	};
	// ---------- BFT -----------
	if (_mode == "BFT") exitWith {
		_mapTypes = ["cTab_main_dlg","mapTypes"] call cTab_fnc_settings;
		_mapType = ["cTab_main_dlg","mapType"] call cTab_fnc_settings;
		_mapIDC = [_mapTypes,_mapType] call cTab_fnc_getFromPairs;
		
		_displayItemsToShow = [_mapIDC];
		_btnActCtrl ctrlSetTooltip "Delete last user placed icon";
	};
	// ---------- UAV -----------
	if (_mode == "UAV") exitWith {
		_displayItemsToShow = [IDC_CTAB_GROUP_UAV,IDC_CTAB_MINIMAPBG,IDC_CTAB_CTABUAVMAP];
		_btnActCtrl ctrlSetTooltip "View Optics";
		_uavListCtrl = _display displayCtrl IDC_CTAB_CTABUAVLIST;
		lbClear _uavListCtrl;
		// Populate list of UAVs
		{if (!(crew _x isEqualTo [])) then {_index = _uavListCtrl lbAdd (str _x)};} forEach allUnitsUav;
	};
	// ---------- HELMET CAM -----------
	if (_mode == "HCAM") exitWith {
		_displayItemsToShow = [IDC_CTAB_GROUP_HCAM,IDC_CTAB_MINIMAPBG,IDC_CTAB_CTABHCAMMAP];
		_data = ["cTab_main_dlg","hCam"] call cTab_fnc_settings;
		_btnActCtrl ctrlSetTooltip "Toggle Fullscreen";
		_hcamListCtrl = _display displayCtrl IDC_CTAB_CTABHCAMLIST;
		// Populate list of HCAMs
		lbClear _hcamListCtrl;
		{
			_index = _hcamListCtrl lbAdd format ["%2 (%1:%3)",groupId group _x,name _x,[_x] call CBA_fnc_getGroupIndex];
			_hcamListCtrl lbSetData [_index,str _x];
		} count cTabHcamlist;
		lbSort [_hcamListCtrl, "ASC"];
		for "_x" from 0 to (lbSize _hcamListCtrl - 1) do {
			if (_data == _hcamListCtrl lbData _x) exitWith {
				if (lbCurSel _hcamListCtrl != _x) then {
					_hcamListCtrl lbSetCurSel _x;
				};
				['rendertarget12',_data] spawn cTab_fnc_createHelmetCam;
			};
		};
	};
	// ---------- MESSAGING -----------
	if (_mode == "MESSAGE") exitWith {
		_displayItemsToShow = [IDC_CTAB_GROUP_MESSAGE];
		call cTab_msg_gui_load;
	};
	// ---------- FULLSCREEN HCAM -----------
	if (_mode == "HCAM_FULL") exitWith {
		_displayItemsToShow = [IDC_CTAB_HCAM_FULL];
		_data = ["cTab_main_dlg","hCam"] call cTab_fnc_settings;
		_btnActCtrl ctrlSetTooltip "Toggle Fullscreen";
		['rendertarget13',_data] spawn cTab_fnc_createHelmetCam;
	};
};

// hide every _displayItems not in _displayItemsToShow
{ctrlShow [_x,_x in _displayItemsToShow];} forEach _displayItems;

ctrlShow [IDC_CTAB_LOADINGTXT,false];

cTabUserOptions = [];
cTabUserSelIcon = [[],"","",500,cTabColorRed];
