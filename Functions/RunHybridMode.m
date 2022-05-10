function [SRD ,filelist,Data]=RunHybridMode(Data,SRD,filelist,Settings,A,loc,locLoop)

if nargin == 6 || nargin == 7
    disp(['Run the Hybrid driving analysis for location ' , loc{locLoop,1} ])
    
    EffDepth        = Settings.HybridSteps(:,1);   % Sequance of incearing the hammer efficiency
    EffLevel        = Settings.HybridSteps(:,2);   % Sequance of incearing the hammer efficiency
    hybrid_style    = Settings.Hybrid_driving_analysis(A.Analysis);  % Style of hybrid driving definition
    SimulationLable = Settings.SimulLable{A.Analysis};
    
    %Select the Output Style 
    if strcmp(Settings.OutPutStyle{A.Analysis},'Normal')
    outstyle    = 0;
    out         = '_Nor_';
    Switch      = 0;
    elseif strcmp(Settings.OutPutStyle{A.Analysis},'Acceleration')
    outstyle    = 4;
    out         = '_Acc_'; 
    Switch      = 1;
    elseif strcmp(Settings.OutPutStyle{A.Analysis},'Force')
    outstyle    = 1;
    out         = '_Frc_';
    Switch      = 1;
    elseif strcmp(Settings.OutPutStyle{A.Analysis},'Velocity')
    outstyle    = 2;
    out         = '_Vel_';
    Switch      = 1;
    elseif strcmp(Settings.OutPutStyle{A.Analysis},'Stress')
    outstyle    = 3;
    out         = '_Str_';
    Switch      = 1;
    elseif strcmp(Settings.OutPutStyle{A.Analysis},'Displacement')
    outstyle    = 5;
    out         = '_Dis_';
    Switch      = 1;
    else
    warning('The output is Normal without time series');
    outstyle    = 0;
    Switch      = 0;
    out         = '_Nor_';
    end       
    
    NoSteps = Data.(loc{locLoop}).NoSteps;    % Load stored number of step
    EffStep = 1;  % Starting with the first efficiency level
    h       = waitbar(0,'Hybrid driving strategy...');
    j       = 0;

    while j < NoSteps
        
        j                                       = j+1;
        SRD.(loc{locLoop,1}).AppliedEff(j,1)    = EffLevel(EffStep);   % To recorded the applied Energy
        Settings.HammerEfficiency(A.Analysis)   = EffLevel(EffStep);% To re generate the D matrix Using new Energy Level
        Data                                    = D_MatrixGeneration(Settings,A,Data,loc,locLoop); 
        SRD.(loc{locLoop}).AppliedEnergy(j,1)   = EffLevel(EffStep); % Store the applied energy in each depth for future use
        [NameOfFiles{j,1},SRD]                  = gwtWriter_Noise(Data,SRD,Settings,A,outstyle,out,Switch,locLoop,j);

        if Settings.AutomaticSW(A.Analysis) == 1  && j < SRD.(loc{locLoop,1}).SWPpileWtIdx
            disp(['Skip running DIGW in Hybrid driving mode for step ',num2str(j),' due to self penetration'])
        elseif Settings.DIGW(A.Analysis)
            back_path = pwd;
            cd(Settings.DIGWFolder)
            DIGW_Noise(NameOfFiles{end},Settings,A,NoSteps,NoSteps);
            cd(back_path)
        end
        
        [SRD] = AssembleResults_Noise (Data,SRD,Settings,A,NameOfFiles{end},loc,locLoop,j);
        
        %% Check if desired depth is reached
        if hybrid_style == 1
            if EffStep == size(EffLevel,1)
                if j == EffDepth(EffStep) % Depth of change of efficiency is met
                    EffStep = EffStep + 1;
                end
            else
                if j == EffDepth(EffStep + 1) % Depth of change of efficiency is met
                    EffStep = EffStep + 1;
                end
            end
        elseif hybrid_style == 2
            if EffStep == size(EffLevel,1)
                if NoSteps - j == EffDepth(end) % Depth of change of efficiency is met
                    EffStep = EffStep + 1;
                end
            else
                if NoSteps - j == EffDepth(EffStep + 1) % Depth of change of efficiency is met
                    EffStep = EffStep + 1;
                end
            end
        else
            error('Wrong hybrid driving style selected')
        end
        
        waitbar(j/NoSteps,h,['DIGW - File ' num2str(j) '/' num2str(NoSteps) ]);
        
    end
    
    %% Assign the name of the files to the Strings List for future use
    filelist.(loc{locLoop,1}) = NameOfFiles{1,1};
    for j = 2:NoSteps
        filelist.(loc{locLoop,1}) = [filelist.(loc{locLoop,1}); strcat(NameOfFiles{j,1})];
    end
    
    %% Store the applyied effciency in D matrix of this analysis
    Data.(loc{locLoop}).Dmatrix(:,6) = [SRD.(loc{locLoop,1}).AppliedEff(1,1); SRD.(loc{locLoop,1}).AppliedEff];
    if Settings.DIGW(A.Analysis)
        StoredData = Data.(loc{locLoop}).Dmatrix(:,6);
        save(strcat(pwd,'\',Settings.Analysis{A.CALC},'\',loc{locLoop,1},SimulationLable,'_AppliedEffic.mat'),'StoredData')
    end
    close(h)
    disp('----------------------------------------------------------------------------')
    
end