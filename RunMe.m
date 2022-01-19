clear all; close all;
%% Present script performs batch calculations for pile driveability analysis using DIGW,  test
% Set GRLWeap installation folder TEST 1 2   Test for Cospin Gruop

DIGWFolder={'C:\PDI\GRLWEAP_2010'}; %remote PC
% DIGWFolder={'C:\GRLWEAP'}; % FKMV PC
pythonPath ='C:\ProgramData\Anaconda3\envs\py373\python.exe';

%% Initialize calculation
addpath('Functions')        % Adding folder with functions to path

[Settings]=Initialize();    % Import defined settings from excel file
Settings.DIGWFolder=DIGWFolder(1);
Settings.PlotTitle = 0;     % Switch for adding title or not for plots

mkdir ('Python_Exchange');
mkdir ('Plots');
mkdir ('Output');

PlotOpt=Plotoptions(Settings);

DatabaseRev=FatigueDBopt(Settings);

locfirst=Settings.Locations(any(cellfun(@(x)any(~isnan(x)),Settings.Locations(:,2)),2),:);

%%Location Loop
for locLoop = 1:size(locfirst,1)
    if Settings.LocationSwitch(locLoop,:)==1
    %% Calculations loop
    for CALC=1:size(Settings.Analysis,1)
        if Settings.AnalysisSwitch(CALC) == 1
            % Clear variables from workspace from previous run
           clearvars -except  pythonPath GE_Data GE_SRD  GE_filelist A Settings locfirst PlotOpt CALC  locLoop  DatabaseRev % Remove in order to ensure no values mistakenly used from previous run - these values are stored at the end of the loop
               
            
            % Generate index for settings
            A = IndexA(Settings,CALC);
            disp(['Running the Analysis:',A.SimulationLable])
            
            %%%% Update the embeded length based on the Analysis number
            loc=Settings.Locations(any(cellfun(@(x)any(~isnan(x)),Settings.Locations(:,A.CALC+1)),2),:);
            locations = [(loc(:,1)),loc(:,A.CALC+1) loc(:,end)];
            
            
            % Import soil, pile and embedment information
            GE_Data.(A.SimulationLable).dummy=1;
            GE_Data.(A.SimulationLable) = InitializeLoop(Settings,A,GE_Data.(A.SimulationLable),locations,locLoop);
            GE_Data.(A.SimulationLable) = rmfield(GE_Data.(A.SimulationLable),'dummy'); % Remove the Dummy object
            
            
            % Generate sub-folders
            mkdir (A.Folder);
            mkdir (A.Folder, 'Plots');
            
            %%%%%%%%%%%%%%%%%%%%%%  Generate SRD  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            GE_SRD.(A.SimulationLable).dummy=1;
            GE_SRD.(A.SimulationLable)=SRDfun(GE_Data.(A.SimulationLable),GE_SRD.(A.SimulationLable),Settings,A,locations,locLoop);
            GE_SRD.(A.SimulationLable) = rmfield(GE_SRD.(A.SimulationLable),'dummy'); % Remove the Dummy object
            
            %%%%%%%%%%%%%%%%%%%%%%  Calculate Self Penetration  %%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [GE_SRD.(A.SimulationLable)]=SelfPenAssesment(GE_Data.(A.SimulationLable),GE_SRD.(A.SimulationLable),Settings,A,locations,locLoop);
            % Generate .gwt files
            
            %%%%%%%%%%%%%%%%%%%%%%  Running GRLWEAP %%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            GE_filelist.(A.SimulationLable).dummy=1;   % Create a Dummy object just for first anlysis
            if Settings.ISNoiseMit(A.Analysis)  % Nose mittigation run mode
                [GE_SRD.(A.SimulationLable) ,GE_filelist.(A.SimulationLable),GE_Data.(A.SimulationLable)]=RunInNoiseMode(GE_Data.(A.SimulationLable),GE_SRD.(A.SimulationLable),GE_filelist.(A.SimulationLable),Settings,A,loc,locLoop);
            else                                % Usual Run Mode
                [GE_filelist.(A.SimulationLable),GE_SRD.(A.SimulationLable)]=gwtWriter(GE_Data.(A.SimulationLable),GE_SRD.(A.SimulationLable),GE_filelist.(A.SimulationLable),Settings,A,locations,locLoop);
                % Run DIGW
                if Settings.DIGW(A.Analysis)
                    back_path = pwd;
                    cd(Settings.DIGWFolder{1})
                    DIGW(GE_SRD.(A.SimulationLable),GE_filelist.(A.SimulationLable),Settings,A,locations,locLoop);   % run GRLweap files
                    cd(back_path)
                end
            end
            GE_filelist.(A.SimulationLable)=rmfield(GE_filelist.(A.SimulationLable),'dummy'); % Remove the Dummy object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%% Reading output%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            GE_SRD.(A.SimulationLable)=FatDam(GE_Data.(A.SimulationLable),GE_SRD.(A.SimulationLable),Settings,A,GE_filelist.(A.SimulationLable),locations,locLoop);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            disp([A.SimulationLable, '  Has been finished succsesfully'])
            disp('--------------------------------------------------')
            %%%%%%%%%%%% Writting the Python Exchange files%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(Settings.OutPutStyle{A.Analysis},'Acceleration') || strcmp(Settings.OutPutStyle{A.Analysis},'Force')
                WritePythonExchangeFile(GE_Data.(A.SimulationLable),GE_SRD.(A.SimulationLable),Settings,A,loc,locLoop);
            end
            
            % eval(['output_',locations{locLoop,1},'_',(A.SimulationLable),'.SRD=GE_SRD;']);
            % eval(['output_',locations{locLoop,1},'_',(A.SimulationLable),'.DATA=GE_Data;']);   
            % save([pwd,'\Mat_files\output_',locations{locLoop,1},'_',(A.SimulationLable),'.mat'],['output_',locations{locLoop,1},'_',(A.SimulationLable)])
    
            %eval([locations{locLoop,1},'_',(A.SimulationLable),'.SRD=GE_SRD;']);
            eval([locations{locLoop,1},'_',(A.SimulationLable),'.SRD=GE_SRD.',(A.SimulationLable),'.',locations{locLoop,1},';']);

            eval([locations{locLoop,1},'_',(A.SimulationLable),'.DATA=GE_Data.',(A.SimulationLable),'.',locations{locLoop,1},';']); 
            eval([locations{locLoop,1},'_',(A.SimulationLable),'.Settings=Settings;']); 

            save([pwd,'\Output\',locations{locLoop,1},'_',(A.SimulationLable),'.mat'],[locations{locLoop,1},'_',(A.SimulationLable)])
        end
    end
    
    GeneralGWOplot(GE_Data,GE_SRD,Settings,A,PlotOpt,locations,locLoop)
    
    
    
    %%%%Store the Data in a Variable
    StoredData.Data = GE_Data;
    StoredData.Settings = Settings;
    StoredData.filelist = GE_filelist;
    StoredData.A = A;
    StoredData.SRD = GE_SRD;
%      
% 
%     save([pwd,'\Plots\DocumentationData',locations{locLoop,1},'.mat'],'StoredData')
    
    
    if Settings.Database.FSwitch
        database_write_Fatigue(GE_Data,GE_SRD,Settings,A,DatabaseRev,locations,locLoop)
    end
    end
end


if any(strcmp(Settings.OutPutStyle,'Acceleration')) && Settings.Appendix.Swtich
    disp('Appendix switch and time series analyses are activated...Please run the Conventor.py then press enter to create appendix')
    pause;
end

if Settings.Appendix.Swtich
    AppendixGeneration(GE_Data,Settings,A,locLoop)
end

% % if any(strcmp(Settings.OutPutStyle,'Acceleration')) && any(strcmp(Settings.OutPutStyle,'Force'))
% %     system([pythonPath,' conventor.py'])
% % end
         
%%% Code to combine plots put in here

% Shut down pc after completing run (can be used when looping over many locations over night)
% system('shutdown -s')   % Shutdown pc

