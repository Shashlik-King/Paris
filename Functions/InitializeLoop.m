function Data = InitializeLoop(Settings,A,Data,locations,locLoop)
%if  A.Database == 0  % If local data are used instead of database
    % Load locations with defined embedment length for specific run
    %     loc=Settings.Locations(any(cellfun(@(x)any(~isnan(x)),Settings.Locations(:,A.CALC+1)),2),:);
    %      PNGI
    %     Data.loc = [(loc(:,1)),loc(:,A.CALC+1) loc(:,end)];    PNGI
    
    % Load pile geometries
    Data.loc =locations;
    
    
    Range={'PileGeometry' 'B2:E36'
        'SCF'          'G2:J36'
        'Selected_Points' 'L2:N14'
        'SRD_prop'  'Q2:AJ30'};
    Files={'Input\PDACalc.xlsx'};
    Data=ExcelData(Files,Data.loc(:,1),Range,Data);   % PNGI
    
    Range={'CPTData' 'K5:M30000'          % CPT original data
        'SoilData'  'Q5:S44'        % CPT interpratated data
        'SoilProfile' 'A5:I45'};      % Soil Profile
    Files={Settings.Excel{A.Analysis,1}};
    Data=ExcelData(Files,Data.loc(:,1),Range,Data);
    disp('Manual input used')
    
    for lll=1:size(Data.loc,1)
        TempPile=Data.(Data.loc{lll,1}).PileGeometry;
        Data.(Data.loc{lll,1}).PileGeometry(:,4)=TempPile(:,3); %replace coloumn 3 and 4
        for aaa=1:size(TempPile(:,4),1)
            Data.(Data.loc{lll,1}).PileGeometry{aaa,3}=TempPile{aaa,4}/1000; %replace coloun 3 and 4
        end
    end
    
if A.Database == 1
    % Load locations for run
    loc=Settings.Locations(any(cellfun(@(x)any(~isnan(x)),Settings.Locations(:,A.CALC+1)),2),:);
    Data.loc = [(loc(:,1)),loc(:,A.CALC+1)];
    
    % Create database matrices for all locations
    for i = 1:size(Data.loc,1)
        [Data.(Data.loc{i,1}).PileGeometry, Data.(Data.loc{i,1}).pile_top,Data.(Data.loc{i,1}).pile_tip]= Input_Pmatrix_DB(Settings,Data.loc{i,1});    % Get pile information
        if A.CaclculateFatigue==1
        Data.(Data.loc{i,1}).SCF            = Input_SCFSNmatrix_DB(Settings,Data.loc{i,1});    % Get SCF and SN information
        end
        if ~isnumeric(Data.loc{i,2})     % Check if embedment is defined manualy, else read from database
            Data.loc{i,2} = Input_embedment_DB(Settings,Data.loc{i,1});
        end
        %%% PNGI 
% % % % % % % % % %         Data.(Data.loc{i,1}).SoilData       = Input_Smatrix_DB(Settings,Data.loc(i,:),DataDB);
        %Data.(Data.loc{i,1}).CPTData
        %clc;
    end
    disp('Database input used')
% else
%     error('Define correct switch for input - Database switch (0/1)')
end

%% Create D matrix
Data = D_MatrixGeneration(Settings,A,Data,locations,locLoop);


