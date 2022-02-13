function [Settings] = Initialize()

% Load Locations from Excel
Range={'Locations' 'B2:O200'};
Sheets={'LOCATIONS'};
Files={'Input\PDACalc.xlsx'};
Settings=ExcelSett(Files,Sheets,Range);

Range={'LocationSwitch' 'A2:B200'};
Sheets={'LOCATIONS'};
Files={'Input\PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range);

% Load calculations settings from Excel
Range={'Project' 'B3:H14'
    'Database' 'I3:M7'
    'DatabaseSetting' 'L3:M7'
    'Paths' 'L9:M10'
    'Output' 'L13:M13'
    'Analysis' 'B19:AA30'
    'Model' 'B35:H46'
    'SoilSett' 'AW5:BG9'
    'EfficiencySteps'  'B51:C59'
    'AppendixSwitch','I9:J9'
    'DatabaseFSwitch', 'I12:J113'
    };
Sheets={'PROJ'};
Files={'Input\PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range,Sett);
%Settings=NameSett(Sett,Settings);

% Load appendix settings from Excel
Range={'AppInfo' 'B2:C13'
    'AppRevisionTable' 'B16:G25'   
    'SwitchApp'  'K3:W3'};
Sheets={'APPENDIX'};
Files={'Input\PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range,Sett);

% Load plot settings from Excel
Range={'Plots' 'D3:AB40'};
Sheets={'PLOTS'};
Files={'Input\PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range,Sett);

% Load fatigue settings from Excel
Range={'DBFatDam' 'D3:K40'};
Sheets={'DATABASE_FATIGUE'};
Files={'Input\PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range,Sett);

% Load excel data extraction settings from Excel
Range={'Excel' 'D3:Z102'};
Sheets={'EXCEL'};
Files={'Input\PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range,Sett);

% Add settings to general structure
Settings=NameSett(Sett,Settings);
