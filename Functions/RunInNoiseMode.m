function [SRD ,filelist,Data]=RunInNoiseMode(Data,SRD,filelist,Settings,A,loc,locLoop)

if nargin ==6 || nargin==7
    disp(['Run the Noise mittigation stratgy for location' , loc{locLoop,1} ])
    
    EffLevel=Settings.StepsOfHammer;   % Sequance of incearing the hammer efficiency
    
    RefCriterion=Settings.NoiseMitRef(A.Analysis);  % Noise mittigation refusal Criterion
    
   
    
    SimulationLable=Settings.SimulLable{A.Analysis};
        
    
    if strcmp(Settings.OutPutStyle{A.Analysis},'Normal')
        outstyle=0;
        out='Nor';
        Switch=0;
    elseif strcmp(Settings.OutPutStyle{A.Analysis},'Acceleration')
        outstyle=4;
        out='Acc';
        Switch=1;
    elseif strcmp(Settings.OutPutStyle{A.Analysis},'Force')
        outstyle=1;
        out='Frc';
        Switch=1;
    else
        warning('The output is Normal without time series');
        outstyle=0;
        out='Nor';
        Switch=0;
    end
    
    
    
    
    NoSteps = Data.(loc{locLoop}).NoSteps;    % Load stored number of steps
    
    SRD.(loc{locLoop,1}).Indexfilelist(1) = 1;
    
    soilMethodLoop=1;
    
    
    EffStep=1;  % Starting with the first efficiency level
    
    h=waitbar(0,'Noise Mittigation Stratgy...');
    
    j=0;
    % for j=1:NoSteps
    while j<NoSteps
        
        j= j+1;
        
        SRD.(loc{locLoop,1}).AppliedEff(j,1)=EffLevel(EffStep);   % To recorded the applied Energy
        Settings.HammerEfficiency(A.Analysis)=EffLevel(EffStep);% To re generate the D matrix Using new Energy Level
        Data = D_MatrixGeneration(Settings,A,Data,loc,locLoop);
        
        SRD.(loc{locLoop}).AppliedEnergy(j,1)=EffLevel(EffStep); % Store the applied energy in each depth for future use
        

        [NameOfFiles{j,1},SRD] = gwtWriter_Noise(Data,SRD,Settings,A,outstyle,out,Switch,locLoop,j);

        
        
        if Settings.AutomaticSW(A.Analysis)==1  && j < SRD.(loc{locLoop,1}).SWPpileWtIdx
            disp(['Skip running DIGW in Noise mittigation mode for step ',num2str(j),' due to self penetration'])
        elseif Settings.DIGW(A.Analysis)
            back_path = pwd;
            cd(Settings.DIGWFolder{1})
            DIGW_Noise(NameOfFiles{end},Settings,A,NoSteps,NoSteps);
            cd(back_path)
        end
        
        
        [SRD]= AssembleResults_Noise (Data,SRD,Settings,A,NameOfFiles{end},loc,locLoop,j);
        
        
        if SRD.(loc{locLoop}).SOD(end,5)>=RefCriterion      % Refusal Criterion is meet
            
            %                EffStep=min(EffStep+1,length(EffLevel));     % Jump to the next level of hammer energy
            EffStep=EffStep+1;
            if EffStep>length(EffLevel)
                EffStep=length(EffLevel); % The maximum Efficency reached.So, No further jump
            else
                j= j-1;     % Repeat the Calculation of current step
            end
            
        end
        waitbar(j/NoSteps,h,['DIGW - File ' num2str(j) '/' num2str(NoSteps) ]);
        
    end
    
    
    %%Assign the name of the files to the Strings List for future use
    filelist.(loc{locLoop,1})=NameOfFiles{1,1};
    for j=2:NoSteps
        filelist.(loc{locLoop,1})=[filelist.(loc{locLoop,1}); strcat(NameOfFiles{j,1})];
    end
    
    
    %%Store the applyied effciency in D matrix of this analysis
    Data.(loc{locLoop}).Dmatrix(:,6)=[SRD.(loc{locLoop,1}).AppliedEff(1,1); SRD.(loc{locLoop,1}).AppliedEff];
    if Settings.DIGW(A.Analysis)
        StoredData=Data.(loc{locLoop}).Dmatrix(:,6);
        save(strcat(pwd,'\',Settings.Analysis{A.CALC},'\',loc{locLoop,1},SimulationLable,'_AppliedEffic.mat'),'StoredData')
    end
    close(h)
    disp('----------------------------------------------------------------------------')
    
end