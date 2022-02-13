function [Settings] = NameSett(Sett,Settings)
% Name Settings imported from Excel
%   MTHG 26-11-2019
Settings.LocationSwitch=cell2mat(Sett.LocationSwitch(:,1));

% Proj
Settings.Analysis=Sett.Project(:,1);
Settings.AnalysisSwitch=cell2mat(Sett.Project(:,2));
Settings.SettingAnalysis=cell2mat(Sett.Project(:,3));
Settings.SettingModel=cell2mat(Sett.Project(:,4));
Settings.SettingSoil=1;
Settings.SettingDatabase=cell2mat(Sett.Project(:,5));
Settings.SettingAppendix=0;
Settings.AutomaticSW=cell2mat(Sett.Project(:,6));
Settings.CalculateFatigue=cell2mat(Sett.Project(:,7));

% Plot
Settings.Plots=Sett.Plots;

% Excel
Settings.Excel=Sett.Excel;

% Database
Settings.DBFatDam=Sett.DBFatDam;
Settings.Database.FSwitch=Sett.DatabaseFSwitch{1,2};
Settings.Database.LoadIterationName=Sett.DatabaseFSwitch{2,2};
Settings.Database.DBname = Sett.Database{1,2};
Settings.Database.Username = Sett.Database{2,2};
Settings.Database.Password = Sett.Database{3,2};
Settings.Database.Server = Sett.Database{4,2};
Settings.Database.Table = Sett.Database{5,2};
Settings.Database.Rev.Geometry = Sett.DatabaseSetting{1,2};
Settings.Database.Rev.Soil = Sett.DatabaseSetting{2,2};
Settings.Database.Rev.Attachments = Sett.DatabaseSetting{3,2};
Settings.Database.Rev.SubRevSFC = Sett.DatabaseSetting{4,2};

% Paths
Settings.DIGWFolder=Sett.Paths {1,2};
Settings.pythonPath=Sett.Paths {2,2};

% Output - Excel
Settings.Excel_switch=Sett.Output;
Settings.Excel_data = Sett.Excel;

% Calc
Settings.AlmHamre=1;
Settings.SimulLable=Sett.Analysis(:,2);
Settings.BackCalc=cell2mat(Sett.Analysis(:,3));
Settings.DFF=cell2mat(Sett.Analysis(:,4));
Settings.DIGW=cell2mat(Sett.Analysis(:,5));
Settings.HammerNo=cell2mat(Sett.Analysis(:,6));
Settings.HammerStroke=cell2mat(Sett.Analysis(:,7));
Settings.HammerEfficiency=cell2mat(Sett.Analysis(:,8));
Settings.AnvilWeight=cell2mat(Sett.Analysis(:,9));
Settings.AnvilStiffness=cell2mat(Sett.Analysis(:,10));
Settings.PileSeg=cell2mat(Sett.Analysis(:,11));
Settings.GeometryFile=Sett.Analysis(:,12);                  % Not used? Do something smart with this
index = cellfun(@ischar,Sett.Analysis(:,13));
for i = 1:length(index)
    if index(i)
        Settings.AnalysisSteps(i,1)=0;
    else
        Settings.AnalysisSteps(i,1)=cell2mat(Sett.Analysis(i,13));
    end
end
Settings.RefusalCrit=cell2mat(Sett.Analysis(:,14));
Settings.CPTData=cell2mat(Sett.Analysis(:,15));
Settings.Excel=Sett.Analysis(:,16);
Settings.Plotting=cell2mat(Sett.Analysis(:,17));
Settings.OutPutStyle=Sett.Analysis(:,18);     %PNGI
Settings.TimeIncreament=cell2mat(Sett.Analysis(:,19));    %PNGI
Settings.DurationAnalysis=cell2mat(Sett.Analysis(:,20));       %PNGI
Settings.AssemWeight=cell2mat(Sett.Analysis(:,21));     %PNGI
Settings.SoilType=Sett.Analysis(:,22);     %PNGI
Settings.EntrapedWater=Sett.Analysis(:,23);     %PNGI
Settings.NoiseMitRef=cell2mat(Sett.Analysis(:,24)); 
Settings.ISNoiseMit=Settings.NoiseMitRef;   % Make a logical Variable 
Settings.ISNoiseMit(Settings.ISNoiseMit>0)=1;
Settings.StepsOfHammer=cell2mat(Sett.EfficiencySteps(:,2));
Settings.HammerBreakDepth=cell2mat(Sett.Analysis(:,25));     %PNGI
Settings.HammerBreakDepth(Settings.HammerBreakDepth==0)=-5; % When the hammerbreak down is off , the applied  depth is -5 to avoid confusion in the code. 
Settings.Residual_stress_anlysis=cell2mat(Sett.Analysis(:,26)); 

% GL
Settings.COR=cell2mat(Sett.Model(:,2));
Settings.G=cell2mat(Sett.Model(:,3));
Settings.SkinGainLoss=cell2mat(Sett.Model(:,4));
Settings.ToeGainLoss=cell2mat(Sett.Model(:,5));
Settings.ESteel=cell2mat(Sett.Model(:,6));
Settings.GSteel=cell2mat(Sett.Model(:,7));

% Soil
Settings.K=cell2mat(Sett.SoilSett(:,2));
Settings.Nc=cell2mat(Sett.SoilSett(:,3));
Settings.ToeDampSand=cell2mat(Sett.SoilSett(:,4));
Settings.ToeDampClay=cell2mat(Sett.SoilSett(:,5));
Settings.SkinDampSand=cell2mat(Sett.SoilSett(:,6));
Settings.SkinDampClay=cell2mat(Sett.SoilSett(:,7));
Settings.ToeQuake=cell2mat(Sett.SoilSett(:,8));
Settings.SkinQuake=cell2mat(Sett.SoilSett(:,9));
Settings.Setup=cell2mat(Sett.SoilSett(:,10));
Settings.LimitDist=cell2mat(Sett.SoilSett(:,11));

% Appendix generation

Settings.Appendix.Swtich=Sett.AppendixSwitch{1,2};
Settings.Appendix.ProjectName = Sett.AppInfo{1,2};
Settings.Appendix.ProjectNumber = Sett.AppInfo{2,2};
Settings.Appendix.DocumentNoCOWI = Sett.AppInfo{3,2};
Settings.Appendix.DocumentNoClient = Sett.AppInfo{4,2};
Settings.Appendix.DocumentNoEmployer = Sett.AppInfo{5,2};
Settings.Appendix.ProjectClient = Sett.AppInfo{6,2};
Settings.Appendix.ProjectEmployer = Sett.AppInfo{7,2};
Settings.Appendix.DocumentDate = Sett.AppInfo{8,2};
Settings.Appendix.RevisionTable = Sett.AppRevisionTable;
Settings.Appendix.Soil_input = Sett.SwitchApp{1,1};
Settings.Appendix.Pile_Geometry  = Sett.SwitchApp{1,2};
Settings.Appendix.hammer_input = Sett.SwitchApp{1,3};
Settings.Appendix.SRD_out = Sett.SwitchApp{1,4};
Settings.Appendix.blow_count = Sett.SwitchApp{1,5};
Settings.Appendix.stress_drive = Sett.SwitchApp{1,6};
Settings.Appendix.fatigue = Sett.SwitchApp{1,7};
Settings.Appendix.NoiseMStratgy = Sett.SwitchApp{1,8};
Settings.Appendix.PileRun = Sett.SwitchApp{1,9};
Settings.Appendix.HammerBreak = Sett.SwitchApp{1,10};
Settings.Appendix.TimeSeries = Sett.SwitchApp{1,11};
Settings.Appendix.LocationInfo = Sett.SwitchApp{1,12};
Settings.Appendix.SoilStratiraphy = Sett.SwitchApp{1,13};