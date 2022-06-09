function Data = InitializeLoop(Settings,A,Data,locations,locLoop)

% Load pile geometries
Data.loc = locations;
Range = {'PileGeometry' 'B2:E100'
    'SCF'          'G2:J100'
    'Selected_Points' 'L2:N14'
    'SRD_prop'  'Q2:AJ52'};
Files = {'Input\PDACalc.xlsx'};
Data = ExcelData(Files,Data.loc(:,1),Range,Data);   % PNGI

% Read tip CPT data
Range = {'CPTData_tip' 'K5:N30000'          % CPT original data
    'SoilData_tip'  'Q5:U105'        % CPT interpratated data
    'SoilProfile_tip' 'A5:J55'};      % Soil Profile
Files = {Settings.Excel_tip{A.Analysis,1}};
Data = ExcelData(Files,Data.loc(:,1),Range,Data);
disp('Manual input used')


% Read shaft CPT data
Range = {'CPTData_shaft' 'K5:N30000'          % CPT original data
    'SoilData_shaft'  'Q5:U105'        % CPT interpratated data
    'SoilProfile_shaft' 'A5:J55'};      % Soil Profile
Files = {Settings.Excel_shaft{A.Analysis,1}};
Data = ExcelData(Files,Data.loc(:,1),Range,Data);
disp('Manual input used')

% Move to a structure
Data.(Data.loc{locLoop}).CPTData.tip = Data.(Data.loc{locLoop}).CPTData_tip;
Data.(Data.loc{locLoop}).SoilData.tip = Data.(Data.loc{locLoop}).SoilData_tip;
Data.(Data.loc{locLoop}).SoilProfile.tip = Data.(Data.loc{locLoop}).SoilProfile_tip;
Data.(Data.loc{locLoop}).CPTData.shaft = Data.(Data.loc{locLoop}).CPTData_shaft;
Data.(Data.loc{locLoop}).SoilData.shaft = Data.(Data.loc{locLoop}).SoilData_shaft;
Data.(Data.loc{locLoop}).SoilProfile.shaft = Data.(Data.loc{locLoop}).SoilProfile_shaft;

% Remove old variables
Data.(Data.loc{locLoop}) = rmfield(Data.(Data.loc{locLoop}),'CPTData_tip'); %
Data.(Data.loc{locLoop}) = rmfield(Data.(Data.loc{locLoop}),'SoilData_tip'); %
Data.(Data.loc{locLoop}) = rmfield(Data.(Data.loc{locLoop}),'SoilProfile_tip'); %
Data.(Data.loc{locLoop}) = rmfield(Data.(Data.loc{locLoop}),'CPTData_shaft'); %
Data.(Data.loc{locLoop}) = rmfield(Data.(Data.loc{locLoop}),'SoilData_shaft'); %
Data.(Data.loc{locLoop}) = rmfield(Data.(Data.loc{locLoop}),'SoilProfile_shaft'); %

% Work woith pile geometry
for lll = 1:size(Data.loc,1)
    TempPile = Data.(Data.loc{lll,1}).PileGeometry;
    Data.(Data.loc{lll,1}).PileGeometry(:,4) = TempPile(:,3); %replace coloumn 3 and 4
    for aaa = 1:size(TempPile(:,4),1)
        Data.(Data.loc{lll,1}).PileGeometry{aaa,3} = TempPile{aaa,4}/1000; %replace coloun 3 and 4
    end
end
    
if A.Database == 1
    % Load locations for run
    loc = Settings.Locations(any(cellfun(@(x)any(~isnan(x)),Settings.Locations(:,A.CALC+1)),2),:);
    Data.loc = [(loc(:,1)),loc(:,A.CALC+1)];
    
    % Create database matrices for all locations
    for i = 1:size(Data.loc,1)
        [Data.(Data.loc{i,1}).PileGeometry, Data.(Data.loc{i,1}).pile_top,Data.(Data.loc{i,1}).pile_tip] = Input_Pmatrix_DB(Settings,Data.loc{i,1});    % Get pile information
        if A.CaclculateFatigue == 1
        Data.(Data.loc{i,1}).SCF = Input_SCFSNmatrix_DB(Settings,Data.loc{i,1});    % Get SCF and SN information
        end
        if ~isnumeric(Data.loc{i,2})     % Check if embedment is defined manualy, else read from database
            Data.loc{i,2} = Input_embedment_DB(Settings,Data.loc{i,1});
        end

    end
    disp('Database input used')
end

%% Create D matrix
Data = D_MatrixGeneration(Settings,A,Data,locations,locLoop);
end