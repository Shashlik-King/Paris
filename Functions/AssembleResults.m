function  [SRD]= AssembleResults (Data,SRD,Settings,A,filelist,loc,locLoop)

%%%% i is the index of location 

%%%% j is the index of Step is the location 

if Settings.AutomaticSW(A.Analysis)==1;   %if the skip self penetration is active 

    StartIdx=SRD.(loc{locLoop,1}).SWPpileWtIdx;
else 
    StartIdx=1; 
end 




%%%Important What is 







  % Define number of steps/files
    NoSteps = Data.(loc{locLoop,1}).NoSteps;
    %% Load all data from GWO files for location
    for j=1:NoSteps
        
    if j>=StartIdx  
        %Load Summary Over Depths
%         GWO=GWOread(filelist.({SRD.(loc{i,1}).Indexfilelist(1)+j-1});    %%%%%PNGI Attention 
        GWO=GWOread(filelist.(loc{locLoop,1}){j,1});
        Ident=strfind(GWO{1,1},'SUMMARY OVER DEPTHS');
        Index=find(not(cellfun('isempty',Ident)))+5;
        Ident=strfind(GWO{1,1},'Total No. of Blows:');
        Index2=find(not(cellfun('isempty',Ident)))-2;
        
        if isempty(Index2)  % in the case of refusal, Keyword Total No.Blow is not written 
           Ident=strfind(GWO{1,1}, 'Refusal occurred; no driving time output possible');
           Index2=find(not(cellfun('isempty',Ident)))-2;
        end 

        
        if j == StartIdx  % only for the frist penetration depth 
            
            tableToRead=cell2mat(cellfun(@(x) textscan(x,'%f'),GWO{1,1}(Index:Index2)'))';
            
            SRD.(loc{locLoop}).SOD(SRD.(loc{locLoop}).Index(j,1):SRD.(loc{locLoop}).Index(j,2),:)=cell2mat(cellfun(@(x) textscan(x,'%f'),GWO{1,1}(Index:Index2)'))';

            if sum(tableToRead(:,5))==0   % To check whether we have self penetration on that depth From GRLWEAP
                
              SRD.(loc{locLoop}).SelfPen(j,:)=1;
            else 
              SRD.(loc{locLoop}).SelfPen(j,:)=0;
            end 

        else    % if not the first file for location, then dont consider the first level, as this is the last level analysed in previous file
            SRD.(loc{locLoop}).SOD(SRD.(loc{locLoop}).Index(j,1)+1:SRD.(loc{locLoop}).Index(j,2),:)=cell2mat(cellfun(@(x) textscan(x,'%f'),GWO{1,1}(Index+1:Index2)'))';

            tableToRead=cell2mat(cellfun(@(x) textscan(x,'%f'),GWO{1,1}(Index+1:Index2)'))';
            if sum(tableToRead(:,5))==0   % To check weather we have only self penetration on that depth
                
              SRD.(loc{locLoop}).SelfPen(j,:)=1;
            else 
              SRD.(loc{locLoop}).SelfPen(j,:)=0;
            end   
        end
        

        
        if Settings.BackCalc(A.Analysis)
            % Pooyan to put in overwritting blow count values in table
            % (column 5)
        end
        
        
        %Load forces in pile
        Ident=strfind(GWO{1,1},'No mxTForce');
        Index=find(not(cellfun('isempty',Ident)));
        if j > 1    % If for accounting for first analysed depth is the previous file's last depth
            N_table = ceil(Settings.PileSeg(A.Analysis)/50);
            Index = Index(N_table+1:end);
        end
        %Identify kN/MN
        Temp=GWO{1,1}(Index(1)+1);
        MN=Temp{1,1}(1:2);
        if strcmp(MN,'MN')
            MN=1;
        else
            MN=1/1000;
        end
        if j==1
            H=0;
        else
            H=size(SRD.(loc{locLoop}).mxT,2);
        end
        for k=1:size(Index,1)/2     % Looping over all tables with results for the stresses
            Temp=cell2mat(cellfun(@(x) textscan(x,'%f'),GWO{1,1}(Index(2*k-1)+2:Index(2*k-1)+50)'))';
            SRD.(loc{locLoop}).mxT(1:49,H+k)=Temp(:,2)*MN;
            SRD.(loc{locLoop}).mxC(1:49,H+k)=Temp(:,3)*MN;
            SRD.(loc{locLoop}).TStress(1:49,H+k)=Temp(:,4);
            SRD.(loc{locLoop}).CStress(1:49,H+k)=Temp(:,5);
            Temp=cell2mat(cellfun(@(x) textscan(x,'%f'),GWO{1,1}(Index(2*k)+2:Index(2*k)+(Settings.PileSeg(A.Analysis)-48))'))';
            SRD.(loc{locLoop}).mxT(50:Settings.PileSeg(A.Analysis),H+k)=Temp(:,2)*MN;
            SRD.(loc{locLoop}).mxC(50:Settings.PileSeg(A.Analysis),H+k)=Temp(:,3)*MN;
            SRD.(loc{locLoop}).TStress(50:Settings.PileSeg(A.Analysis),H+k)=Temp(:,4);
            SRD.(loc{locLoop}).CStress(50:Settings.PileSeg(A.Analysis),H+k)=Temp(:,5);
        end
    else 
        
        %%Assiging the zero value for those peth covered by self
        %%penetration 
        SRD.(loc{locLoop}).SOD(SRD.(loc{locLoop}).Index(j,1)+1:SRD.(loc{locLoop}).Index(j,2),:)=horzcat(SRD.(loc{locLoop}).Soil.z_D(j),SRD.(loc{locLoop}).totalRes(j)/1000,SRD.(loc{locLoop}).SkinSWP(j)/1000, SRD.(loc{locLoop}).TipSWP(j)/1000, 0,0,0, Settings.HammerStroke(A.Analysis),0);      
        SRD.(loc{locLoop}).mxT(1:Settings.PileSeg(A.Analysis),j:j+1)=0;
        SRD.(loc{locLoop}).mxC(1:Settings.PileSeg(A.Analysis),j:j+1)=0;
        SRD.(loc{locLoop}).TStress(1:Settings.PileSeg(A.Analysis),j:j+1)=0;
        SRD.(loc{locLoop}).CStress(1:Settings.PileSeg(A.Analysis),j:j+1)=0;
        SRD.(loc{locLoop}).SelfPen(j,:)=1;
      
    end     
    end 
        SRD.(loc{locLoop}).toe.diameter_out=(SRD.(loc{locLoop}).out_daim(end));
        SRD.(loc{locLoop}).toe.wt=(SRD.(loc{locLoop}).tw(end));
        SRD.(loc{locLoop}).toe.diameter_in=SRD.(loc{locLoop}).toe.diameter_out-2*SRD.(loc{locLoop}).toe.wt;
        SRD.(loc{locLoop}).toe.area=pi*(SRD.(loc{locLoop}).toe.diameter_out.^2-SRD.(loc{locLoop}).toe.diameter_in.^2)/4;
        SRD.(loc{locLoop}).toeStress=max(SRD.(loc{locLoop}).mxC(end,:))/SRD.(loc{locLoop}).toe.area;
    end 
    
  