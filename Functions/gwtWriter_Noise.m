function [filelist,SRD] = gwtWriter_Noise(Data,SRD,Settings,A,outstyle,out,Switch,i,j)
%% Fundtion generates filelist and writes .gwt's to project folder
% MTHG 03-12-2019
% i is the index of locations 
% j is the index of Step of Penetration 

if nargin ==8 || nargin==9
    h=waitbar(0,'Writing .gwt files');
    loc = Data.loc; % Get the Location data 
    SimulationLable=Settings.SimulLable{A.Analysis};
    factor_soil_method=SRD.(loc{i,1}).Soil.SRDMultiplier;
    SRD.(loc{i}).UB_factor = factor_soil_method(2);
    Index(j) = sum(SRD.(loc{i,1}).Soil.z_D(j)>=SRD.(loc{i,1}).Soil.z); % Define index for soil properties
    filelist = {strcat(pwd,'\',Settings.Analysis{A.CALC},'\',loc{i,1},SimulationLable,'_',num2str(j))};
    %%-------------------Setup of InputGWL.gwt-----------------
    fileID = fopen([filelist{end},'.gwt'],'w');
    fprintf(fileID,'%-41s %13s\r\n',[loc{i,1} ' ' SimulationLable ' ' num2str(j)],'VER. 2010 0 0');
    fprintf(fileID,'%4.0f %3.0f%4.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f %3.0f%4.0f %3.0f %3.0f %3.0f%4.0f %6.3f\r\n',[outstyle Switch Settings.HammerNo(A.Analysis) 0 1 0 Settings.PileSeg(A.Analysis) 0 1 0 0 1 0 Settings.TimeIncreament(A.Analysis) Settings.Residual_stress_anlysis(A.Analysis) 0 0 Settings.DurationAnalysis(A.Analysis) 0.000]);  % PNGI  3 0  ----> 4 1 
    fprintf(fileID,'%10.4f %9.4f %14.3f %9.4f ',[Settings.G(A.Model) Settings.G(A.Model) SRD.(loc{i,1}).gwtPile(size(SRD.(loc{i,1}).gwtPile,1),2) 0.0000]');
    fprintf(fileID,'%19s\r\n','Unknown');
    fprintf(fileID,'%10.2f %9.2f %9.1f %9.1f %9.4f %9.4f %9.0f\r\n',[Settings.AnvilWeight(A.Analysis) 0 0 0 Settings.COR(A.Model) 3 Settings.AnvilStiffness(A.Analysis)]');
    fprintf(fileID,'%10.1f %9.1f %9.1f %9.4f %9.4f %9.0f\r\n',[0 0 0 0 0 0]');
    fprintf(fileID,'%10.2f %9.2f %9.1f %9.3f %9.3f %9.3f %9.4f %9.4f\r\n',[max(SRD.(loc{i,1}).gwtPile(:,1)) SRD.(loc{i,1}).gwtPile(1,2:size(SRD.(loc{i,1}).gwtPile,2)) 0 0]');
    fprintf(fileID,'%10.2f %9.2f %9.1f %9.3f %9.3f %9.3f\r\n',SRD.(loc{i,1}).gwtPile(2:size(SRD.(loc{i,1}).gwtPile,1),:)');
    fprintf(fileID,'%10.3f %9.3f %9.1f %9.2f %9.4f %9.3f %9.4f %9.3f\r\n',[Settings.HammerStroke(A.Analysis) Settings.HammerEfficiency(A.Analysis) 0 0 0 0 0 Settings.AssemWeight(A.Analysis)]');
    fprintf(fileID,'%10.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f\r\n',[SRD.(loc{i,1}).Soil.QuakeDamp(1,1) SRD.(loc{i,1}).Soil.QuakeDamp(1,2) SRD.(loc{i,1}).Soil.QuakeDamp(1,3) SRD.(loc{i,1}).Soil.QuakeDamp(1,4) 0 0 0 0]');
    fprintf(fileID,'%10.4f %9.4f %9.4f %9.4f\r\n',[0 0 0 0]');
    fprintf(fileID,'%10.4f %9.4f %9.4f %9.4f\r\n',[0 0 0 0]');
    fprintf(fileID,'%8.2f%10.3f%10.2f %7.3f %7.3f %7.3f %7.3f %7.3f %7.2f %7.4f %4.2f\r\n',[0 0 0 SRD.(loc{i,1}).Soil.QuakeDamp(1,1) SRD.(loc{i,1}).Soil.QuakeDamp(1,2) SRD.(loc{i,1}).Soil.QuakeDamp(1,3) SRD.(loc{i,1}).Soil.QuakeDamp(1,4) SRD.(loc{i,1}).Soil.Setup SRD.(loc{i,1}).Soil.LimDist(1) 0 SRD.(loc{i,1}).gwtPile(size(SRD.(loc{i,1}).gwtPile,1),2)]');
    if size(SRD.(loc{i,1}).Soil.z(1:Index(j)),1) < 98
        fprintf(fileID,'%8.2f%10.3f%10.2f %7.3f %7.3f %7.3f %7.3f %7.3f %7.2f %7.4f %4.2f\r\n',[SRD.(loc{i,1}).Soil.z(1:Index(j)) SRD.(loc{i,1}).Soil.fs(j,1:Index(j))'.*factor_soil_method(1:Index(j),1) SRD.(loc{i,1}).Soil.qt_gwt(1:Index(j))'.*factor_soil_method(1:Index(j),1) SRD.(loc{i,1}).Soil.QuakeDamp(1:Index(j),1) SRD.(loc{i,1}).Soil.QuakeDamp(1:Index(j),2) SRD.(loc{i,1}).Soil.QuakeDamp(1:Index(j),3) SRD.(loc{i,1}).Soil.QuakeDamp(1:Index(j),4) SRD.(loc{i,1}).Soil.Setup*ones(Index(j),1) SRD.(loc{i,1}).Soil.LimDist(1)*ones(Index(j),1) zeros(Index(j),1) SRD.(loc{i,1}).gwtPile(size(SRD.(loc{i,1}).gwtPile,1),2)*ones(Index(j),1)]');
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
        fprintf(fileID,'%8.2f%10.3f%10.2f %7.3f %7.3f %7.3f %7.3f %7.3f %7.2f %7.4f %4.2f\r\n',[SRD.(loc{i,1}).Soil.z(III) SRD.(loc{i,1}).Soil.fs(j,III)'.*factor_soil_method(III,1) SRD.(loc{i,1}).Soil.qt_gwt(III)'.*factor_soil_method(III,1) SRD.(loc{i,1}).Soil.QuakeDamp(III,1) SRD.(loc{i,1}).Soil.QuakeDamp(III,2) SRD.(loc{i,1}).Soil.QuakeDamp(III,3) SRD.(loc{i,1}).Soil.QuakeDamp(III,4) SRD.(loc{i,1}).Soil.Setup*ones(size(III,2),1) SRD.(loc{i,1}).Soil.LimDist(1)*ones(size(III,2),1) zeros(size(III,2),1) SRD.(loc{i,1}).gwtPile(size(SRD.(loc{i,1}).gwtPile,1),2)*ones(size(III,2),1)]');
    end
    fprintf(fileID,'%8.2f%10.3f%10.2f %7.3f %7.3f %7.3f %7.3f %7.3f %7.2f %7.4f %4.2f\r\n',[max(SRD.(loc{i,1}).gwtPile(:,1)) SRD.(loc{i,1}).Soil.fs(j,Index(j))*factor_soil_method(Index(j)) SRD.(loc{i,1}).Soil.qt_gwt(Index(j))*factor_soil_method(Index(j)) SRD.(loc{i,1}).Soil.QuakeDamp(Index(j),1) SRD.(loc{i,1}).Soil.QuakeDamp(Index(j),2) SRD.(loc{i,1}).Soil.QuakeDamp(Index(j),3) SRD.(loc{i,1}).Soil.QuakeDamp(Index(j),4) SRD.(loc{i,1}).Soil.Setup SRD.(loc{i,1}).Soil.LimDist(1) 0 SRD.(loc{i,1}).gwtPile(size(SRD.(loc{i,1}).gwtPile,1),2)]');
    fprintf(fileID,'%8.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\r\n',[Settings.SkinGainLoss(A.Model) 0 0 0 0 0 0 0 0 0]');
    fprintf(fileID,'%8.3f %7.3f %7.3f %7.3f %7.3f %7.1f %7.3f %7.3f %7.3f %7.3f\r\n',[Settings.ToeGainLoss(A.Model) 0 0 0 0 SRD.(loc{i,1}).gwtPile(size(SRD.(loc{i,1}).gwtPile,1),2) 0 0 0 0]');
    fprintf(fileID,'%10.2f %9.2f %9.2f %9.3f %9.2f %9.4f %9.4f %9.4f\r\n',Data.(loc{i,1}).Dmatrix(Data.(loc{i,1}).Dindex(j,1):Data.(loc{i,1}).Dindex(j,2),:)');
    fprintf(fileID,'%10.2f %9.2f %9.2f %9.3f %9.2f %9.4f %9.4f %9.4f\r\n',[0 0 0 0 0 0 0 0]');

    if strcmp(Settings.OutPutStyle{A.Analysis},'Acceleration') || strcmp(Settings.OutPutStyle{A.Analysis},'Force') || strcmp(Settings.OutPutStyle{A.Analysis},'Displacement') || strcmp(Settings.OutPutStyle{A.Analysis},'Velocity') || strcmp(Settings.OutPutStyle{A.Analysis},'Stress')   
        fprintf(fileID,'%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f%4.0f\r\n',[SRD.(loc{i,1}).outputSegment(:,1)'   4   0   0]);
    end       
    fclose(fileID);
    waitbar(i/size(loc,1),h);
    SRD.(loc{i,1}).Index=Data.(loc{i,1}).Dindex;
    SRD.(loc{i,1}).IndexS=Index;
    SRD.(loc{i,1}).Indexfilelist(2) = size(filelist,1);
    disp(['GRLWEAP input piles for Location: ', loc{i}, ' has been created']) 
    close(h)
end
end

