function [CelldesignProfile] = soilAssignment(SoilProfile_1,CPT_fit)
% stratDepths: 2 column array with ztop, zbot from stratigraphy
% CPT_fit: 3 column array with depth,qc,fs
% designProfile: 6 column array with ztop,zbot,qctop,qcbot,fstop,fsbot

stratDepths(:,1:2)      = cell2mat(SoilProfile_1(:,2:3)); % save depths of layers
ordered_strat           = unique(vertcat(stratDepths(:,1),stratDepths(:,2))); %save and trasform in one column the boundary depth
designDepth             = unique(sort(vertcat(CPT_fit(:,1),ordered_strat))); %merge and order boundaries depth and CPT_fit depth and keep the unique this means that it will stay only if it was not present
designTableRaw          = CPT_fit; % reassign whole CPT table
designTableRaw(end,1)   = designDepth(end); % make sure that the last depth of CPT and Design Depth are the same 

for i = 1:length(ordered_strat)
    if ~any(ordered_strat(i) == designTableRaw(:,1))
        index           = sum((designTableRaw(:,1))<ordered_strat(i));            
        newline1        = [ordered_strat(i), interp1(designTableRaw(index:index+1,1),designTableRaw(index:index+1,2),ordered_strat(i)), interp1(designTableRaw(index:index+1,1),designTableRaw(index:index+1,3),ordered_strat(i)),interp1(designTableRaw(index:index+1,1),designTableRaw(index:index+1,4),ordered_strat(i)),interp1(designTableRaw(index:index+1,1),designTableRaw(index:index+1,5),ordered_strat(i))];
        designTableRaw  = [designTableRaw(1:index,:); newline1; designTableRaw(index+1:end,:)];
    end 
end 

counter = 1;
designTable = zeros(10000 , size(designTableRaw,2));
for i = 1:size(designTableRaw,1)-1
    if ~all(isequal(designTableRaw(i,:), designTableRaw(i+1,:)))
        designTable(counter,:) = designTableRaw(i,:);
        counter = counter+1;
    end
end
designTable = designTable(1:counter,:);
designTable(counter,:) = designTableRaw(end,:); % Add last row
designDepth = designTable(:,1); % reassign depth
designQc    = designTable(:,2); % reassign end bearing qc
designFs    = designTable(:,3); % reassign friction fs
designRf    = designTable(:,4); % reassign friction ratio
designU2    = designTable(:,5); % reassign pore pressure
Dummy       = zeros(size(designDepth,1)-1,1); % create dummy variable

% Create top-bot final design table
designProfile = horzcat(designDepth(1:end-1),designDepth(2:end),Dummy,... % %
designQc(1:end-1),designQc(2:end),... % %
designFs(1:end-1),designFs(2:end),...
designRf(1:end-1),designRf(2:end),...
designU2(1:end-1),designU2(2:end));

if any(designProfile(:,1) == designProfile(:,2))  % Remove the extra lines at the boundary 
deIDX = find(designProfile(:,1) == designProfile(:,2));
designProfile(deIDX,:) = [];
end

CelldesignProfile = num2cell(designProfile);
end