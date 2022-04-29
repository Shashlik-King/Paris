function [Settings] = Initialize()

% Load Locations from Excel
Range={'Locations' 'B2:W200'};
Sheets={'LOCATIONS'};
Files={'Input\PDACalc.xlsx'};
Settings=ExcelSett(Files,Sheets,Range);

Range={'LocationSwitch' 'A2:B200'};
Sheets={'LOCATIONS'};
Files={'Input\PDACalc.xlsx'};
Sett=ExcelSett(Files,Sheets,Range);

% Load calculations settings from Excel
Range={'Project' 'C3:I22'
    'DatabaseSetting' 'K3:L12'
    'Paths' 'K17:L18'
    'Output' 'N3:O5'
    'Analysis' 'B26:AA45'
    'Model' 'B49:H60'
    'SoilSett' 'J49:T60'
    'EfficiencySteps'  'B65:C81'
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
