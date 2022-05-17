function [DBTableRaw]=createDBOutput(GE_Data,GE_SRD,Settings,A,DatabaseRev,locations,locLoop,revnumber);

revname             = DatabaseRev.Revname{revnumber,3};
Revision            = DatabaseRev.(revname).RNumber;
Sub_Rev             = DatabaseRev.(revname).rev_sub;
Hammer_Conf         = DatabaseRev.(revname).Hammer_Conf;
Idname              = locations{locLoop,1};
status              = Settings.Database.status;
responsible         = Settings.Database.responsible;
Insert              = Settings.Database.preparer;
Time                = '444';
Switch              = DatabaseRev.(revname).Switch;
AnalysisNameBlow    = Settings.SimulLable{DatabaseRev.(revname).AnalysisBlow};
AnalysisNameForce   = Settings.SimulLable{DatabaseRev.(revname).AnalysisForce};

SoilProp            = [Settings.SoilType{DatabaseRev.(revname).AnalysisBlow,1},'-',Settings.SoilType{DatabaseRev.(revname).AnalysisForce,1}]; 
SoilProp            = Settings.SoilType{DatabaseRev.(revname).AnalysisForce,1};     %%%%%PNGI to be changed

PenDepths           = GE_SRD.(AnalysisNameBlow).(locations{locLoop,1}).SOD(:,1);
driv                = GE_SRD.(AnalysisNameBlow).(locations{locLoop,1}).SOD;
LayerWidth          = [ 0; diff(driv(:,1))/2]+[ diff(driv(:,1))/2;0]; %Calculate relevant height of each layer for determination of blows in each layer
BlowCount           = GE_SRD.(AnalysisNameBlow).(locations{locLoop,1}).SOD(:,5).*LayerWidth; %%Correction of the blow count with respect to the thickness of each layer
SegmentsElev        = GE_SRD.(AnalysisNameBlow).(locations{locLoop,1}).GWOxMiddle;
MaxTForce           = GE_SRD.(AnalysisNameForce).(locations{locLoop,1}).mxT;
MaxCForce           = GE_SRD.(AnalysisNameForce).(locations{locLoop,1}).mxC;
DBTableRaw          = cell(size(PenDepths,1)*size(SegmentsElev,1),14);
index               = 0;
for pen = 1:size(PenDepths,1)
    for seg = 1:size(SegmentsElev,1)
        index = index+1;
        DBTableRaw(index,:) = [Idname,num2cell(Revision),num2cell(Sub_Rev),num2cell(Hammer_Conf),SoilProp,num2cell(PenDepths(pen)),num2cell(SegmentsElev(seg)),num2cell(BlowCount(pen)), num2cell(MaxCForce(seg,pen)),num2cell(MaxTForce(seg,pen)),status,responsible,Insert,Time];
    end 
end 
end 