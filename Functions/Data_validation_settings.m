function Data_validation_settings(Settings)
% This function checks the input settings user has specified and notifies the user if wrong values are entered in cells

%% Locations Tab
% Repeating location names
if size(Settings.Locations,1) > size(unique(Settings.Locations(:,1)),1)
    error('Duplicate names of locations specified')
end

% No locations specified
if sum(Settings.LocationSwitch) == 0
    error('No location is turned on')
end

% Missing embedment length for analysis
for i = 1:sum(Settings.LocationSwitch)
    if sum(isnan([Settings.Locations{Settings.LocationSwitch(i),2:size(Settings.Analysis,1)}])) > 0
        error('Undefined embedment length for an analysis')
    end
end

% Missing water depth
for i = 1:sum(Settings.LocationSwitch)
    if isnan(Settings.Locations{Settings.LocationSwitch(i),end})
        error('Undefined embedment length for an analysis')
    end
end

%% PROJ Tab
% No analyses
if sum(Settings.AnalysisSwitch) == 0
    error('No location is turned on')
end

%% Plots Tab
% Plot names
if size(Settings.Plots(:,3),1) > size(unique(Settings.Plots(:,3)),1)
    error('Duplicate names of plots specified')
end

% Analyses needed for plot
index_needed = find([Settings.Plots{:,1}] > 0);
index_running = find([Settings.AnalysisSwitch] > 0);
for i = 1:sum([Settings.Plots{:,1}])
    analyses_needed = rmmissing([Settings.Plots{index_needed(i),5:9}]);
    [found] = ismember(analyses_needed, index_running);
    if ~all(found==1)
        error('Analysis needed for plotting not activated')
    end
end

% Symbol definition
if 1==0
    error('Symbol in plot not defined')
end

% Legend definition
if 1==0
    error('legend for plot not defined')
end

% No plot selected
if 1==0
    error('No analysis for plot selected')
end

%% Excel Tab
if Settings.Excel_switch
    % No excel output file selected
    if 1==0
        error('No excel output file selected')
    end
    % Analysis needed for writing not run
    if 1==0
        error('Analysis selected for excel file not run')
    end
    % Repeating names of excels
    if 1==0
        error('Names of excel repeating')
    end
end
%% Database Fatigue Tab
if Settings.DBFatDam
   % No switch turned on
   
   
   % Not enough information specified for given fatigue write option
   
   
   % Analysis needed for fatigue assessment not run
    
end
%% Appendix Tab
if Settings.SettingAppendix
    % Project details not specified
    
    % Revision table missing input
    
end

%% Final messages
disp('All data is correct')
disp('-------------------------------------------------------------------')
disp('Calculation initiated...')
end