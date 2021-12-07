function [CelldesignProfile] = soilAssignment(SoilProfile_1,CPT_fit)

 stratDepths(:,1:2)=cell2mat(SoilProfile_1(:,2:3));



% stratDepths: 2 column array with ztop, zbot from stratigraphy
% CPT_fit: 3 column array with depth,qc,fs
% designProfile: 6 column array with ztop,zbot,qctop,qcbot,fstop,fsbot

%make sure the CPT fit contains unique points,otherwis shift of 1mm
% % % % % % % % % % % for i=2:size(CPT_fit,1)    PNGI
% % % % % % % % % % %     if CPT_fit(i,1)==CPT_fit(i-1,1)
% % % % % % % % % % %         CPT_fit(i,1) = CPT_fit(i,1)+0.001;
% % % % % % % % % % %     end
% % % % % % % % % % % end

%save and trasform in one column the boundary depth
ordered_strat = unique(vertcat(stratDepths(:,1),stratDepths(:,2)));

%merge and order boundaries depth and CPT_fit depth and keep the unique
%this means that it will stay only if it was not present
designDepth = unique(sort(vertcat(CPT_fit(:,1),ordered_strat)));



% make sure that the last depth of CPT and Design Depth are the same 

designTableRaw=CPT_fit;

 designTableRaw(end,1)=designDepth(end);


    for i = 1:length(ordered_strat)

        if ~any(ordered_strat(i) == designTableRaw(:,1))
            index = sum((designTableRaw(:,1))<ordered_strat(i));            
            newline1 = [ordered_strat(i), interp1(designTableRaw(index:index+1,1),designTableRaw(index:index+1,2),ordered_strat(i)), interp1(designTableRaw(index:index+1,1),designTableRaw(index:index+1,3),ordered_strat(i))];
            designTableRaw = [designTableRaw(1:index,:); newline1; designTableRaw(index+1:end,:)];
        end 
    end 
    counter = 1;    
     for i = 1:size(designTableRaw,1)-1
        if ~all(isequal(designTableRaw(i,:), designTableRaw(i+1,:)))
            designTable(counter,:) = designTableRaw(i,:);
            counter = counter+1;
        end
    end
    designTable(counter,:) = designTableRaw(end,:);     % Add last row
    

    
designDepth=designTable(:,1);
designQc=designTable(:,2);
designFs=designTable(:,3);

%interpolate the ordered cpt to give the final design profile
% % % % % % designQc = interp1(CPT_fit(:,1),CPT_fit(:,2),designDepth); 
% % % % % % designFs = interp1(CPT_fit(:,1),CPT_fit(:,3),designDepth);

Dummy=zeros(size(designDepth,1)-1,1);

%create top-bot final design table
% designProfile = horzcat(designDepth(1:end-1),designDepth(2:end),Dummy,...
%                         designQc(1:end-1),designQc(2:end),...
%                         designFs(1:end-1),designFs(2:end));

designProfile =horzcat(designDepth(1:end-1),designDepth(2:end),Dummy,... % %
designQc(1:end-1),designQc(2:end),... % %
designFs(1:end-1),designFs(2:end));


if any(designProfile(:,1)==designProfile(:,2))  % Remove the extra lines at the boundary 
deIDX=find(designProfile(:,1)==designProfile(:,2));
designProfile(deIDX,:)=[];
end

CelldesignProfile=num2cell(designProfile);
end