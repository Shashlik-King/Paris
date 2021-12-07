function A = IndexA(Settings,CALC)
% Function defining the index for different settings

A.CALC = CALC;
A.Folder = Settings.Analysis{CALC};
A.Analysis = Settings.SettingAnalysis(CALC);
A.Model = Settings.SettingModel(CALC);
% A.Soil = Settings.SettingSoil(CALC);

A.Database = Settings.SettingDatabase(CALC);
A.SimulationLable=Settings.SimulLable{A.Analysis};
A.CaclculateFatigue=Settings.CalculateFatigue(CALC);
       
