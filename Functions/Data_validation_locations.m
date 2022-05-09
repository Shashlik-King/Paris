function Data_validation_locations(Settings,Data)
% This function checks the input settings user has specified and notifies the user if wrong values are entered in cells

%% Soil2GRLWeap
% Repeating location names
% if size(Settings.Locations,1) > size(unique(Settings.Locations(:,1)),1)
%     error('Duplicate names of locations specified')
% end

% Missing water depth
% for i = 1:sum(Settings.LocationSwitch)
%     if isnan(Settings.Locations{Settings.LocationSwitch(i),end})
%         error('Undefined embedment length for an analysis')
%     end
% end

%% PDAcalc
% Repeating location names
% if size(Settings.Locations,1) > size(unique(Settings.Locations(:,1)),1)
%     error('Duplicate names of locations specified')
% end

% Missing water depth
% for i = 1:sum(Settings.LocationSwitch)
%     if isnan(Settings.Locations{Settings.LocationSwitch(i),end})
%         error('Undefined embedment length for an analysis')
%     end
% end

%% Final messages
disp('All data is correct')
disp('-------------------------------------------------------------------')
disp('Calculation initiated...')
end