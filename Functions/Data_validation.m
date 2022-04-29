function Data_validation(Settings)
% This function checks the input settings user has specified and notifies the user if wrong values are entered in cells

%% Repeating names issues
% Location names
if size(Settings.Locations,1) > size(unique(Settings.Locations(:,1)),1)
    error('Duplicate names of locations specified')
end

% Plot names
if size(Settings.Locations,1) > size(unique(Settings.Locations(:,1)),1)
    error('Duplicate names of plots specified')
end

%% Not enough data issues
% No locations
if sum(Settings.LocationSwitch) == 0
    error('No location is turned on')
end

% No analyses
if sum(Settings.AnalysisSwitch) == 0
    error('No location is turned on')
end


disp('All data is correct')
disp('-------------------------------------------------------------------')
disp('Calculation initiated...')
end