function [filelistName,SRD] = gwtWriter(Data,SRD,filelistName,Settings,A,loc,locLoop)

if nargin ==6 || nargin==7
 disp([' Create input files for Analysis:  ',A.SimulationLable , ' For Location ' , loc{locLoop,1} ]) 
 
%% Fundtion generates filelist and writes .gwt's to project folder
% MTHG 03-12-2019



h=waitbar(0,'Writing .gwt files');

SimulationLable=Settings.SimulLable{A.Analysis};

%Select the Output Style 
if strcmp(Settings.OutPutStyle{A.Analysis},'Normal');
outstyle=0;
out='_Nor_';
Switch=0;
elseif strcmp(Settings.OutPutStyle{A.Analysis},'Acceleration');
outstyle=4;
out='_Acc_'; 
Switch=1;
elseif strcmp(Settings.OutPutStyle{A.Analysis},'Force');
outstyle=1;
out='_Frc_';
Switch=1;
elseif strcmp(Settings.OutPutStyle{A.Analysis},'Velocity');
outstyle=2;
out='_Vel_';
Switch=1;
elseif strcmp(Settings.OutPutStyle{A.Analysis},'Stress');
outstyle=3;
out='_Str_';
Switch=1;
elseif strcmp(Settings.OutPutStyle{A.Analysis},'Displacement');
outstyle=5;
out='_Dis_';
Switch=1;
else
warning('The output is Normal without time series');
outstyle=0;
Switch=0;
out='_Nor_';
end 

    
           
    factor_soil_method=SRD.(loc{locLoop,1}).Soil.SRDMultiplier;
    
    SRD.(loc{locLoop}).UB_factor = factor_soil_method(2);   %It is not used 
    NoSteps = Data.(loc{locLoop}).NoSteps;    % Load stored number of steps
    SRD.(loc{locLoop,1}).Indexfilelist(1) = 1;

        for j=1:NoSteps
            
            if Settings.Residual_stress_anlysis(A.Analysis)&&  SRD.(loc{locLoop,1}).Soil.z_D(j)>= SRD.(loc{locLoop,1}).Soil.z_D(end)-Settings.HammerBreakDepth(A.Analysis)
                ResStressSwitch=1;     % if the residual analysis is on, it reads from the pre assined value
            else
                ResStressSwitch=0;                                  % the residual analysis is not applied
            end
            Index(j) = sum(SRD.(loc{locLoop,1}).Soil.z_D(j)>=SRD.(loc{locLoop,1}).Soil.z); % Define index for soil properties
            %Create the name of the file 
            GwtFilename = {strcat(pwd,'\',Settings.Analysis{A.CALC},'\',loc{locLoop,1},SimulationLable,'_',num2str(j))};
            % Store the name of the file in a Cell list 
            NameOfFiles{j,1}=GwtFilename;
            %%-------------------Setup of InputGWL.gwt-----------------
            fileID = fopen([GwtFilename{end},'.gwt'],'w');
            fprintf(fileID,'%-41s %13s\r\n',[loc{locLoop,1} ' ' SimulationLable ' ' num2str(j)],'VER. 2010 0 0');
            fprintf(fileID,'%4.0f %3.0f%4.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f%4.0f %3.0f %3.0f %3.0f%4.0f %6.3f\r\n',[outstyle Switch Settings.HammerNo(A.Analysis) 0 1 0 Settings.PileSeg(A.Analysis) 0 1 0 0 1 0 Settings.TimeIncreament(A.Analysis) ResStressSwitch 0 0 Settings.DurationAnalysis(A.Analysis) 0.000]);  % PNGI  3 0  ----> 4 1 
            fprintf(fileID,'%10.4f %9.4f %14.3f %9.4f ',[Settings.G(A.Model) Settings.G(A.Model) SRD.(loc{locLoop,1}).gwtPile(size(SRD.(loc{locLoop,1}).gwtPile,1),2) 0.0000]');
            fprintf(fileID,'%19s\r\n','Unknown');
            fprintf(fileID,'%10.2f %9.2f %9.1f %9.1f %9.4f %9.4f %9.0f\r\n',[Settings.AnvilWeight(A.Analysis) 0 0 0 Settings.COR(A.Model) 3 Settings.AnvilStiffness(A.Analysis)]');
            fprintf(fileID,'%10.1f %9.1f %9.1f %9.4f %9.4f %9.0f\r\n',[0 0 0 0 0 0]');
            fprintf(fileID,'%10.2f %9.2f %9.1f %9.3f %9.3f %9.3f %9.4f %9.4f\r\n',[max(SRD.(loc{locLoop,1}).gwtPile(:,1)) SRD.(loc{locLoop,1}).gwtPile(1,2:size(SRD.(loc{locLoop,1}).gwtPile,2)) 0 0]');
            fprintf(fileID,'%10.2f %9.2f %9.1f %9.3f %9.3f %9.3f\r\n',SRD.(loc{locLoop,1}).gwtPile(2:size(SRD.(loc{locLoop,1}).gwtPile,1),:)');
            fprintf(fileID,'%10.3f %9.3f %9.1f %9.2f %9.4f %9.3f %9.4f %9.3f\r\n',[Settings.HammerStroke(A.Analysis) Settings.HammerEfficiency(A.Analysis) 0 0 0 0 0 Settings.AssemWeight(A.Analysis)]');
            fprintf(fileID,'%10.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f\r\n',[SRD.(loc{locLoop,1}).Soil.QuakeDamp(1,1) SRD.(loc{locLoop,1}).Soil.QuakeDamp(1,2) SRD.(loc{locLoop,1}).Soil.QuakeDamp(1,3) SRD.(loc{locLoop,1}).Soil.QuakeDamp(1,4) 0 0 0 0]');
            fprintf(fileID,'%10.4f %9.4f %9.4f %9.4f\r\n',[0 0 0 0]');
            fprintf(fileID,'%10.4f %9.4f %9.4f %9.4f\r\n',[0 0 0 0]');
            fprintf(fileID,'%8.2f%10.3f%10.2f %7.3f %7.3f %7.3f %7.3f %7.3f %7.2f %7.4f %4.2f\r\n',[0 0 0 SRD.(loc{locLoop,1}).Soil.QuakeDamp(1,1) SRD.(loc{locLoop,1}).Soil.QuakeDamp(1,2) SRD.(loc{locLoop,1}).Soil.QuakeDamp(1,3) SRD.(loc{locLoop,1}).Soil.QuakeDamp(1,4) SRD.(loc{locLoop,1}).Soil.Setup(1) SRD.(loc{locLoop,1}).Soil.LimDist(1) 0 SRD.(loc{locLoop,1}).gwtPile(size(SRD.(loc{locLoop,1}).gwtPile,1),2)]');
            i = locLoop;
            if size(SRD.(loc{i,1}).Soil.z(1:Index(j)),1) < 98
                fprintf(fileID,'%8.2f%10.3f%10.2f %7.3f %7.3f %7.3f %7.3f %7.3f %7.2f %7.4f %4.2f\r\n',[SRD.(loc{i,1}).Soil.z(1:Index(j)) SRD.(loc{i,1}).Soil.fs(j,1:Index(j))'.*factor_soil_method(1:Index(j),1) SRD.(loc{i,1}).Soil.qt_gwt(1:Index(j))'.*factor_soil_method(1:Index(j),1) SRD.(loc{i,1}).Soil.QuakeDamp(1:Index(j),1) SRD.(loc{i,1}).Soil.QuakeDamp(1:Index(j),2) SRD.(loc{i,1}).Soil.QuakeDamp(1:Index(j),3) SRD.(loc{i,1}).Soil.QuakeDamp(1:Index(j),4) SRD.(loc{i,1}).Soil.Setup(1:Index(j)) SRD.(loc{i,1}).Soil.LimDist(1:Index(j)) zeros(Index(j),1) SRD.(loc{i,1}).gwtPile(size(SRD.(loc{i,1}).gwtPile,1),2)*ones(Index(j),1)]'); %definer soil setup og limit distance inde i AlmHamre og Stevens
            else
                AAA = SRD.(loc{i,1}).Soil.z(1:Index(j)); %reassign variable
                BBB = AAA(round(AAA(:)) == (AAA(:)));  % find integers in the soil profile
                CCC = setdiff(BBB,[Data.(loc{i,1}).SoilProfile{:,2}]); % check which depth increments match with the soil profile
                DDD = setdiff(CCC,[Data.(loc{i,1}).SoilData{:,1}]); % check which depth increments match with the CPT profile
                [~,EEE] = ismember(DDD,AAA); % index/indeces of lines that CAN be removed
                FFF = size(SRD.(loc{i,1}).Soil.z(1:Index(j)),1) -97; % number of points to be removed
                if FFF>size(EEE,1)
                    error('Maximum number of points which can be removed is reached. Please simplify soil stratigraphy, assumed CPT profile or reduce penetration depth.')
                else
                    GGG = EEE(1:FFF); % indeces which WILL be removed
                end
                HHH = 1:1:size(SRD.(loc{i,1}).Soil.z(1:Index(j)),1);
                III = setdiff(HHH,GGG);% indeces of leftover data
                
%                 SRD_backup = SRD;
%                 SRD_backup.(loc{i,1}).Soil.z
                fprintf(fileID,'%8.2f%10.3f%10.2f %7.3f %7.3f %7.3f %7.3f %7.3f %7.2f %7.4f %4.2f\r\n',[SRD.(loc{i,1}).Soil.z(III) SRD.(loc{i,1}).Soil.fs(j,III)'.*factor_soil_method(III,1) SRD.(loc{i,1}).Soil.qt_gwt(III)'.*factor_soil_method(III,1) SRD.(loc{i,1}).Soil.QuakeDamp(III,1) SRD.(loc{i,1}).Soil.QuakeDamp(III,2) SRD.(loc{i,1}).Soil.QuakeDamp(III,3) SRD.(loc{i,1}).Soil.QuakeDamp(III,4) SRD.(loc{i,1}).Soil.Setup(III)' SRD.(loc{i,1}).Soil.LimDist(III)' zeros(size(III,2),1) SRD.(loc{i,1}).gwtPile(size(SRD.(loc{i,1}).gwtPile,1),2)*ones(size(III,2),1)]');
            end
            fprintf(fileID,'%8.2f%10.3f%10.2f %7.3f %7.3f %7.3f %7.3f %7.3f %7.2f %7.4f %4.2f\r\n',[max(SRD.(loc{locLoop,1}).gwtPile(:,1)) SRD.(loc{locLoop,1}).Soil.fs(j,Index(j))*factor_soil_method(Index(j)) SRD.(loc{locLoop,1}).Soil.qt_gwt(Index(j))*factor_soil_method(Index(j)) SRD.(loc{locLoop,1}).Soil.QuakeDamp(Index(j),1) SRD.(loc{locLoop,1}).Soil.QuakeDamp(Index(j),2) SRD.(loc{locLoop,1}).Soil.QuakeDamp(Index(j),3) SRD.(loc{locLoop,1}).Soil.QuakeDamp(Index(j),4) SRD.(loc{locLoop,1}).Soil.Setup(Index(j)) SRD.(loc{locLoop,1}).Soil.LimDist(Index(j)) 0 SRD.(loc{locLoop,1}).gwtPile(size(SRD.(loc{locLoop,1}).gwtPile,1),2)]');
            fprintf(fileID,'%8.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\r\n',[Settings.SkinGainLoss(A.Model) 0 0 0 0 0 0 0 0 0]');
            fprintf(fileID,'%8.3f %7.3f %7.3f %7.3f %7.3f %7.1f %7.3f %7.3f %7.3f %7.3f\r\n',[Settings.ToeGainLoss(A.Model) 0 0 0 0 SRD.(loc{locLoop,1}).gwtPile(size(SRD.(loc{locLoop,1}).gwtPile,1),2) 0 0 0 0]');
            fprintf(fileID,'%10.2f %9.2f %9.2f %9.3f %9.2f %9.4f %9.4f %9.4f\r\n',Data.(loc{locLoop,1}).Dmatrix(Data.(loc{locLoop,1}).Dindex(j,1):Data.(loc{locLoop,1}).Dindex(j,2),:)');
            fprintf(fileID,'%10.2f %9.2f %9.2f %9.3f %9.2f %9.4f %9.4f %9.4f\r\n',[0 0 0 0 0 0 0 0]');
            
            % Write the Segment of the pile in case of variable output
      if strcmp(Settings.OutPutStyle{A.Analysis},'Acceleration') || strcmp(Settings.OutPutStyle{A.Analysis},'Force')          
            fprintf(fileID,'%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f\r\n',[SRD.(loc{locLoop,1}).outputSegment(:,1)'   4   0   0]);           
      end       
            fclose(fileID);
        end  
filelistName.(loc{locLoop,1})=NameOfFiles{1,1};
for jj=2:NoSteps 
filelistName.(loc{locLoop,1})=[filelistName.(loc{locLoop,1}); strcat(NameOfFiles{jj,1})];
end 
   
    waitbar(locLoop/size(loc,1),h);
    SRD.(loc{locLoop,1}).Index=Data.(loc{locLoop,1}).Dindex;
    SRD.(loc{locLoop,1}).IndexS=Index;
    SRD.(loc{locLoop,1}).Indexfilelist(2) = size(NameOfFiles,1);
    disp(['GRLWEAP input piles for Location: ', loc{locLoop}, ' has been created']) 
     
close(h)

end
end

