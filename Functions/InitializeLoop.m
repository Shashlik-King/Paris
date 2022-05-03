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
        'SRD_prop'  'Q2:AG30'};
    Files={'Input\PDACalc.xlsx'};
    Data=ExcelData(Files,Data.loc(:,1),Range,Data);   % PNGI
    
    
    
    %  Data=ExcelData_2(Files,Data.loc(:,1),Range,Data);
    % % Load SoilData and CPTData from Excel
    
    % % % % %     excellnames=Settings.Excel(any(cellfun(@(x)any(~isnan(x)),Settings.Excel(:,1)),2),:);
    % % % % %     if  A.CALC==1 || ~isequal(excellnames{:})
    
%     Range={'CPTData' 'K5:M30000'          % CPT original data
%         'SoilData'  'Q5:S44'        % CPT interpratated data
%         'SoilProfile' 'A5:I45'};      % Soil Profile
    
    Range={'CPTData' 'N5:P30000'          % CPT original data
        'SoilData'  'T5:V44'        % CPT interpratated data
        'SoilProfile' 'A5:L45'};      % Soil Profile
    %Files={Settings.Excel{A.Analysis,1},'Soil2GRLWEAP.xlsm'};
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
    
    % Load CPT global values
% % % % % % %     Range={'Global' 'A2:T50'};
% % % % % % %     Sheets={'CPT_interpretation_fs','CPT_interpretation_qc'}';
% % % % % % %     Files={'CPT_global_SNA_DD.xlsm'};
% % % % % % %     DataDB=ExcelData(Files,Sheets,Range);
    
    % Load CPT local values
% % % % % % %     Range={'CPTdesign' 'A1:X500'};
% % % % % % %     Sheets={'CPT_location_fs2','CPT_location_qc2','CPT_location_fs3','CPT_location_qc3'}';
% % % % % % %     Files={'CPT_local_SNA_DD_GEO2.xlsm','CPT_local_SNA_DD_GEO3.xlsm'};
% % % % % % %     DataDB=ExcelData(Files,Sheets,Range,DataDB);
% % % % % % %     DataDB.CPTlocal.qc = [DataDB.(Sheets{2}).CPTdesign;DataDB.(Sheets{4}).CPTdesign]; % Assemble different sheet data
% % % % % % %     DataDB.CPTlocal.fs = [DataDB.(Sheets{1}).CPTdesign;DataDB.(Sheets{3}).CPTdesign]; % Assemble different sheet data
    
    % Load CPT raw data
% % % % % % %     [~,DataDB.SheetNames1] = xlsfinfo(Files{1});
% % % % % % %     [~,DataDB.SheetNames2] = xlsfinfo(Files{2});
    
% % % % % % %     if Settings.CPTData(A.Analysis)
% % % % % % %         error('CPT measurements implementation not coded proberbly yet')    % Remove when implementation finalized
% % % % % % %         DataDB.SheetList = [DataDB.SheetNames1(5:end)'; DataDB.SheetNames2(5:end)'];
% % % % % % %         Range={'CPTraw' 'A1:M5000'};
% % % % % % %         Sheets = DataDB.SheetList';
% % % % % % %         Files={'CPT_local_SNA_DD_GEO2.xlsm','CPT_local_SNA_DD_GEO3.xlsm'};
% % % % % % %         DataDB=ExcelData(Files,Sheets,Range,DataDB);
% % % % % % %     end
    
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


