function [Settings] = Initialize()
%function [Settings,Data] = Initialize()
%INITIALIZE Summary of this function goes here
%   Detailed explanation goes here
% Load Locations from Excel

Range={'Locations' 'B2:O200'};
Sheets={'LOCATIONS'};
Files={'PDACalc.xlsx'};
Settings=ExcelSett(Files,Sheets,Range);


Range={'LocationSwitch' 'A2:B200'};
Sheets={'LOCATIONS'};
Files={'PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range);

% Load calculations settings from Excel
Range={'Project' 'B3:H14'
    'Database' 'I3:M7'
    'DatabaseSetting' 'L3:M7'
    'Paths' 'L9:M10'
    'Analysis' 'B19:AA30'
    'Model' 'B35:H46'
    'SoilSett' 'AW5:BG9'
    'EfficiencySteps'  'B51:C59'
    'AppendixSwitch','I9:J9'
    'DatabaseFSwitch', 'I12:J113'
    };
Sheets={'PROJ'};
Files={'PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range,Sett);
%Settings=NameSett(Sett,Settings);

% Load appendix settings from Excel
Range={'AppInfo' 'B2:C13'
    'AppRevisionTable' 'B16:G25'   
    'SwitchApp'  'K3:W3'};
Sheets={'Appendix'};
Files={'PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range,Sett);

Range={'Plots' 'C6:AA40'};
Sheets={'Plots'};
Files={'PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range,Sett);

Range={'DBFatDam' 'C6:J40'};
Sheets={'DataBase_Fatigue'};
Files={'PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range,Sett);




Settings=NameSett(Sett,Settings);
