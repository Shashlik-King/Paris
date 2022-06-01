function WritePythonExchangeFile(Time_series_out,GE_Data,GE_SRD,Settings,A,loc,i)

Time_S_OPT=Time_series_out.Time_S_OPT;
FileName=strcat(pwd,'\Python_Exchange\','GeneralInfo_Analysis');
fileID = fopen([FileName,'.txt'],'w');
    
for AnanlysN=1:Time_series_out.N_Time_output
    
    AnaBlow_count=Time_series_out.(Time_S_OPT{AnanlysN,1}).AnalysisBlow;
    Analysis_time=Time_series_out.(Time_S_OPT{AnanlysN,1}).Analysis_time;


% FileName=strcat(pwd,'\Python_Exchange\','GeneralInfo_Analysis');
% fileID = fopen([FileName,'.txt'],'w');
%for AA=1:size(Settings.Analysis,1)
% % % %     if strcmp(Settings.OutPutStyle{AA},'Acceleration') || strcmp(Settings.OutPutStyle{AA},'Force')
% % % %         if Settings.AnalysisSwitch(AA)    
   fprintf(fileID,'%s %s\r\n',Settings.Analysis{Analysis_time}, Settings.SimulLable{Analysis_time});
% % % %         end
% % % %     end
%end 
end
fclose(fileID);

FileName=strcat(pwd,'\Python_Exchange\','LocationNames');
fileID2 = fopen([FileName,'.txt'],'w');
for LL=1:size(Settings.Locations,1)        
fprintf(fileID2,'%s\r\n',Settings.Locations{LL,1});           
end 
fclose(fileID2);

for AnanlysN=1:Time_series_out.N_Time_output

    AnaBlow_count=Settings.SimulLable{Time_series_out.(Time_S_OPT{AnanlysN,1}).AnalysisBlow};
    Analysis_time=Settings.SimulLable{Time_series_out.(Time_S_OPT{AnanlysN,1}).Analysis_time};
    
    Data=GE_Data.(AnaBlow_count);
    Data_time=GE_Data.(Analysis_time);
    SRD=GE_SRD.(AnaBlow_count);    
    SRD_time=GE_SRD.(Analysis_time);
    TypeofExtract=Time_series_out.(Time_S_OPT{AnanlysN,1}).extract_opt;    
    A.SimulationLable=Analysis_time;

    
    
% if strcmp(Settings.OutPutStyle{A.Analysis},'Acceleration') || strcmp(Settings.OutPutStyle{A.Analysis},'Force')
    
    
    SelfArray=SRD.(loc{i,1}).SelfPen;
    Pen_Depth=SRD.(loc{i,1}).Soil.z_D;
    StartBlow=length(find(SelfArray==1))+1;
    TotalStep=length(SelfArray);
    %blowcount=SRD.(loc{i,1}).SOD(:,5);
	

	
	driv=SRD.(loc{i,1}).SOD;

	LayerWidth=[ 0; diff(driv(:,1))/2]+[ diff(driv(:,1))/2;0]; %Calculate relevant height of each layer for determination of blows in each layer
	blowcount=SRD.(loc{i,1}).SOD(:,5).*LayerWidth; %%Correction of the blow count with respect to the thickness of each layer
	blowcount(1)=[];
    
    ImpactDepth=find(~SelfArray);
    
    if TypeofExtract==-1   % when all of the depth are extracted 
        NumBlock=size(ImpactDepth,1);
        TotalBlow=blowcount(ImpactDepth);
        IdxInter=(1:size(ImpactDepth,1))';
    else
        NumBlock=TypeofExtract;
        
        IdxBlocTop=ImpactDepth(1);
        for blc=1:NumBlock      % when blow count is extracted in some block
            IdxInter(blc)=floor(size(ImpactDepth,1)*((2*blc-1)/(NumBlock*2)));
            IdxBlocBot(blc)=IdxBlocTop+floor(size(ImpactDepth,1)/(NumBlock));
            idxBlock{blc}=find(((Pen_Depth<IdxBlocBot(blc)).*(Pen_Depth>=IdxBlocTop)));            
            blockBlow=blowcount(idxBlock{blc},1);            
            TotalBlow(blc)=sum(blockBlow);            
            IdxBlocTop=IdxBlocBot(blc);
        end
    end
    
    FileName=strcat(pwd,'\Python_Exchange\','StructInfo_',loc{i,1},A.SimulationLable);

    fileID = fopen([FileName,'.txt'],'w');
    
    fprintf(fileID,'FileID  DepthID  Accu_Blowcount\r\n');    
    for blc=1:NumBlock
    
    fprintf(fileID,'%s  %4.0f %4.0f \r\n',A.SimulationLable, ImpactDepth(IdxInter(blc)), TotalBlow(blc));
    end 
    fclose(fileID);
    
 
    
    PointOfIntrest=Data_time.(loc{i,1}).Selected_Points;
    SegmentNumber=SRD_time.(loc{i,1}).outputSegment;
    

    FileName=strcat(pwd,'\Python_Exchange\','SWPData_',loc{i,1},A.SimulationLable);
    fileID = fopen([FileName,'.txt'],'w');
    fprintf(fileID,'%3.0f %3.0f\r\n',StartBlow, TotalStep);
    fclose(fileID);


    FileName=strcat(pwd,'\Python_Exchange\','Pen_Depth',loc{i,1},A.SimulationLable);
    fileID = fopen([FileName,'.txt'],'w');
    for ff=1:size(Pen_Depth,1)
    fprintf(fileID,'%3.4f %3.0f\r\n',[Pen_Depth(ff,1), SelfArray(ff,1)]);
    end
    fclose(fileID);

    FileName=strcat(pwd,'\Python_Exchange\','SectionInfo',loc{i,1},A.SimulationLable);
    fileID = fopen([FileName,'.txt'],'w');
    for CC=1:size(PointOfIntrest,1)
    fprintf(fileID,'%3.5f %3.0f  %3.0f\r\n',PointOfIntrest{CC,2}, SegmentNumber(CC,1), PointOfIntrest{CC,3});
    end
    fclose(fileID);


 end 

fclose all;

end 


