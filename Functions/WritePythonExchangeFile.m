function WritePythonExchangeFile(Data,SRD,Settings,A,loc,i)


FileName=strcat(pwd,'\Python_Exchange\','GeneralInfo_Analysis');
fileID = fopen([FileName,'.txt'],'w');
for AA=1:size(Settings.Analysis,1)
    if strcmp(Settings.OutPutStyle{AA},'Acceleration') || strcmp(Settings.OutPutStyle{AA},'Force')
        if Settings.AnalysisSwitch(AA)    
        fprintf(fileID,'%s %s\r\n',Settings.Analysis{AA}, Settings.SimulLable{AA});
        end
    end
end 
fclose(fileID);



FileName=strcat(pwd,'\Python_Exchange\','LocationNames');
fileID = fopen([FileName,'.txt'],'w');
for LL=1:size(Settings.Locations,1)        
fprintf(fileID,'%s\r\n',Settings.Locations{LL,1});           
end 
fclose(fileID);


if strcmp(Settings.OutPutStyle{A.Analysis},'Acceleration') || strcmp(Settings.OutPutStyle{A.Analysis},'Force')
     
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
    
    NumBlock=3;
    
    
    IdxBlocTop=ImpactDepth(1);
    for blc=1:NumBlock
        
    
    IdxInter(blc)=floor(size(ImpactDepth,1)*((2*blc-1)/(NumBlock*2)));
    IdxBlocBot(blc)=IdxBlocTop+floor(size(ImpactDepth,1)/(NumBlock)); 
    idxBlock{blc}=find(((Pen_Depth<IdxBlocBot(blc)).*(Pen_Depth>=IdxBlocTop)));
   
    blockBlow=blowcount(idxBlock{blc},1); 
    
    TotalBlow(blc)=sum(blockBlow);
    
    IdxBlocTop=IdxBlocBot(blc);
    end
    
    
    FileName=strcat(pwd,'\Python_Exchange\','StructInfo_',loc{i,1},A.SimulationLable);

    fileID = fopen([FileName,'.txt'],'w');
    
    fprintf(fileID,'FileID  DepthID  Accu_Blowcount\r\n');    
    for blc=1:NumBlock
    
    fprintf(fileID,'%s  %4.0f %4.0f \r\n',A.SimulationLable, ImpactDepth(IdxInter(blc)), TotalBlow(blc));
    end 
    fclose(fileID);
    
 
    
    PointOfIntrest=Data.(loc{i,1}).Selected_Points;
    SegmentNumber=SRD.(loc{i,1}).outputSegment;
    

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