function TableFull = Input_Smatrix_DB(Settings,loc,DataDB)

%%% Open mysql database
mysql('open','DKLYCOPILOD1',Settings.Database.Username,Settings.Database.Password); % ('open','server','username','password')
mysql(['use ' Settings.Database.DBname]); % name of database

%%% Manual input for testing
% close all; clear; clc;
% data.location = 'DDG04';
% data.revision.soil = 1000;
%
% mysql('open','DKLYCOPILOD1','nzdb_user','ituotdnzdb'); % ('open','server','username','password')
% mysql('use nzdb'); % name of database

%% Database unique id's
%--------------------------------------------------------------------------
location = ['''',loc{1},'''']; % name of location
rev_soil   = Settings.Database.Rev.Soil; % revision no. of structure to be used
if rev_soil ~= 1000 % check, if specified revision numbers are available for specified location
    [rev] = mysql(['select soil_revision from soil_data_detail where id=',location]);
    if ismember(rev_soil,str2double(rev)) == 0 % if specified structure revision is not available then output an error message
        error('Specified structural revision number doesn''t exist for this location');
    end
else
    [rev] = mysql(['select soil_revision from soil_data_detail where id=',location]);
    rev = sort(str2double(rev));
    rev_soil = max(rev(1:sum(sort(rev)<80)));
end

if rev_soil<10
    rev_soil   = ['''0',num2str(rev_soil),'''']; % revision no. of structure to be used
else
    rev_soil   = ['''',num2str(rev_soil),'''']; % revision no. of structure to be used
end

%% Load values from database
table = 'soil_data_detail';
[layer, top_level, bottom_level, gamma_eff, phi, c_u, legend_code, description] = mysql...
    (['select layer, top_level, bottom_level, gamma_eff, phi, c_u, legend_code, description from ',table,' where id=',...
    location,' and soil_revision=',rev_soil,' ORDER BY layer']);

mysql('close')

T = NaN(length(layer),1);
for i = 1:length(layer)
    if  c_u(i) == 0 && ~phi(i)==0
        T(i) = 1;
    elseif ~c_u(i) == 0 && phi(i)==0
        T(i) = 2;
    else
        error('Define what to do when implementing soil data from DB if conditions for sand and clay not accepted')
    end
end

% Create the soil table from database data
SoilTable = num2cell([abs(top_level) abs(bottom_level) NaN(length(layer),1) T gamma_eff+10 NaN(length(layer),1)  NaN(length(layer),1)  NaN(length(layer),1) NaN(length(layer),1) phi]);
SoilTable(:,3) = description;
%SoilTable = num2cell(SoilTableDB);

% Check no missing layers
if ~all((layer == (1:length(layer))'))
    warndlg(['Error in importet data from database - check soil layer for ' loc{1}],'Error soil table')
end


%% Build CPT into table
% Output should be a table with the columns: (Top layer level, bottom layer level, Description, calculation type (clay, 2, or sand, 1), Unit weight, top qc, bottom qc, top fs, bottom fs, phi)
TableFull = includeCPT(DataDB.CPTlocal.qc,DataDB.CPT_interpretation_qc.Global,SoilTable,[6 7],loc);
TableFull = includeCPT(DataDB.CPTlocal.fs,DataDB.CPT_interpretation_fs.Global,TableFull,[8 9],loc);



function SoilFull = includeCPT(inputL,inputG,SoilTable,IndexMainTable,loc)
%inputL = DataDB.CPTlocal.qc;    % Set local table
%inputG = DataDB.CPT_interpretation_qc.Global;    % Set global table
CPT = 1;
depth = 2;

locString = strings(size(inputL(:,1)));
[locString{:}] = inputL{:,1};
IndexL = find(strcmp(locString,loc{1}));

SoilFull = [];
if isempty(IndexL) || isempty(inputL{IndexL(depth),3}) || loc{2} < inputL{IndexL(depth),3} % Only use global values if no local CPT or embedment < first local CPT measurement
    nlayer.global = size(SoilTable,1);
    for i = 1:nlayer.global
        LayerG = inputG((strcmp(SoilTable(i,3),inputG(:,1))),8:end)';
        LayerG = cell2mat(LayerG(any(cellfun(@(x)any(~isnan(x)),LayerG(:,depth)),2),:));  % CPT value, depth
        indexG = find(and(cell2mat(SoilTable(i,1))<LayerG(:,depth),cell2mat(SoilTable(i,2))>LayerG(:,depth))==1);
        LayerG_1 = LayerG(indexG,:);
        SoilFull = [SoilFull; SoilTable(i,:); num2cell(NaN(size(LayerG_1,1)-1,size(SoilTable,2))) ; SoilTable(i,:)];
        if ~isempty(LayerG_1) % if there are extra layers from CPT
            SoilFull(end-size(LayerG_1,1)+1:end,1) = num2cell(LayerG_1(:,depth));
            SoilFull(end-size(LayerG_1,1)+1:end,6) = num2cell(NaN(size((LayerG_1(:,depth)))));
            SoilFull(end-size(LayerG_1,1)+1:end,8) = num2cell(NaN(size((LayerG_1(:,depth)))));
            SoilFull(end-size(LayerG_1,1):end,IndexMainTable(1)) = num2cell([interp1(LayerG(min(indexG)-1:min(indexG),depth),LayerG(min(indexG)-1:min(indexG),CPT),SoilFull{end-size(LayerG_1,1),1});LayerG_1(:,CPT)]);
            
            
            
            SoilFull(end-size(LayerG_1,1):end-1,2) = num2cell(LayerG_1(:,depth));
            SoilFull(end-size(LayerG_1,1):end-1,7) = num2cell(NaN(size((LayerG_1(:,depth)))));
            SoilFull(end-size(LayerG_1,1):end-1,9) = num2cell(NaN(size((LayerG_1(:,depth)))));
            
            SoilFull(end-size(LayerG_1,1):end,IndexMainTable(2)) = num2cell([LayerG_1(:,CPT);interp1(LayerG(max(indexG):max(indexG)+1,depth),LayerG(max(indexG):max(indexG)+1,CPT),SoilFull{end,2})]);
        else  % if there are no extra layers from CPT
            SoilFull(end,:) = [];
            for j = 1:2
                if sum(SoilFull{end,j}>LayerG(:,depth)) == 0% if equal to
                    SoilFull(end,IndexMainTable(j)) = num2cell(interp1(LayerG(1:2,depth),LayerG(1:2,CPT),SoilFull{end,j}));
                else
                    SoilFull(end,IndexMainTable(j)) = num2cell(interp1(LayerG(sum(SoilFull{end,j}>LayerG(:,depth)):sum(SoilFull{end,j}>LayerG(:,depth))+1,depth),LayerG(sum(SoilFull{end,j}>LayerG(:,depth)):sum(SoilFull{end,j}>LayerG(:,depth))+1,CPT),SoilFull{end,j}));
                end
            end
        end
    end
else % Include both local and global CPT
    values.local = inputL(IndexL,3:end)';
    values.local = cell2mat(values.local(any(cellfun(@(x)any(~isnan(x)),values.local(:,depth)),2),:));  % CPT value, depth
    
    % Make layers before CPT
    nlayer.before = sum(cell2mat(SoilTable(:,1))<values.local(1,depth));
    if ~nlayer.before == 0
        for i = 1:nlayer.before
            if i == nlayer.before
                endLayer = values.local(1,depth);
            else
                endLayer = cell2mat(SoilTable(i,2));
            end
            LayerG = inputG((strcmp(SoilTable(i,3),inputG(:,1))),8:end)';
            LayerG = cell2mat(LayerG(any(cellfun(@(x)any(~isnan(x)),LayerG(:,depth)),2),:));  % CPT value, depth
            indexG = find(and(cell2mat(SoilTable(i,1))<LayerG(:,depth),endLayer>LayerG(:,depth))==1);
            LayerG_1 = LayerG(indexG,:);
            SoilFull = [SoilFull; SoilTable(i,:); num2cell(NaN(size(LayerG_1,1)-1,size(SoilTable,2))) ; SoilTable(i,:)];
            if ~isempty(LayerG_1) % if there are extra layers from CPT
                SoilFull(end-size(LayerG_1,1)+1:end,1) = num2cell(LayerG_1(:,depth));
                SoilFull(end-size(LayerG_1,1):end,IndexMainTable(1)) = num2cell([interp1(LayerG(min(indexG)-1:min(indexG),depth),LayerG(min(indexG)-1:min(indexG),CPT),SoilFull{end-size(LayerG_1,1),1});LayerG_1(:,CPT)]);
                SoilFull(end-size(LayerG_1,1):end-1,2) = num2cell(LayerG_1(:,depth));
                SoilFull(end-size(LayerG_1,1):end,IndexMainTable(2)) = num2cell([LayerG_1(:,CPT);interp1(LayerG(max(indexG):max(indexG)+1,depth),LayerG(max(indexG):max(indexG)+1,CPT),cell2mat(SoilTable(i,2)))]);
            else  % if there are no extra layers from CPT
                SoilFull(end,:) = [];
                for j = 1:2
                    if sum(SoilFull{end,j}>LayerG(:,depth)) == 0% if equal to
                        SoilFull(end,IndexMainTable(j)) = num2cell(interp1(LayerG(1:2,depth),LayerG(1:2,CPT),SoilFull{end,j}));
                    else
                        SoilFull(end,IndexMainTable(j)) = num2cell(interp1(LayerG(sum(SoilFull{end,j}>LayerG(:,depth)):sum(SoilFull{end,j}>LayerG(:,depth))+1,depth),LayerG(sum(SoilFull{end,j}>LayerG(:,depth)):sum(SoilFull{end,j}>LayerG(:,depth))+1,CPT),SoilFull{end,j}));
                    end %% CHECK INTERPOLATION TO USE "endLayer" AND INSERT CORRECT VALUES (LAST VALUE SHOULD USE CPT START)
                end
            end
        end
    end
    if nlayer.before < size(SoilTable,1)
        SoilFull = [SoilFull;SoilTable(nlayer.before+1:end,:)];
    end
    
    % Include CPT
    for i = 1:size(values.local,1)
        nlayer.CPT(i) = sum(values.local(i,depth)>cell2mat(SoilFull(:,1))==1);
        if nlayer.CPT(i) == 0  % If no previous layers
            if SoilFull{1,1} == 0 && values.local(i,depth) == 0
                SoilFull{1,IndexMainTable(1)} = values.local(i,CPT);
            else
                error('Code what to do if CPT starts at 0m depth')
            end
        elseif nlayer.CPT(i) == size(SoilFull,1) && cell2mat(SoilFull(end,2)) < values.local(i,depth) % If no layers after CPT point
            SoilFull = [SoilFull(1:nlayer.CPT(i),:); num2cell(NaN(1,10))];
            SoilFull{nlayer.CPT(i)+1,1} = SoilFull{nlayer.CPT(i),2};
            SoilFull{nlayer.CPT(i)+1,2} = values.local(i,depth);
            SoilFull{nlayer.CPT(i)+1,IndexMainTable(2)} = values.local(i,CPT);
            
        else % If in between layer
            if nlayer.CPT(i) == size(SoilFull,1)
                SoilFull = [SoilFull(1:nlayer.CPT(i),:); num2cell(NaN(1,10))];
            else
                SoilFull = [SoilFull(1:nlayer.CPT(i),:); num2cell(NaN(1,10)); SoilFull(nlayer.CPT(i)+1:end,:)];
            end
            
            SoilFull{nlayer.CPT(i)+1,1} = values.local(i,depth);
            SoilFull{nlayer.CPT(i)+1,2} = SoilFull{nlayer.CPT(i),2};
            SoilFull{nlayer.CPT(i)+1,IndexMainTable(1)} = values.local(i,CPT);
            if i > 1
                if abs(SoilFull{nlayer.CPT(i),2}-SoilFull{nlayer.CPT(i)+1,2})<0.001 && all(IndexMainTable == [8 9])
                    SoilFull{nlayer.CPT(i)+1,7} = SoilFull{nlayer.CPT(i),7};
                end
                SoilFull{nlayer.CPT(i),2} = values.local(i,depth);
                if all(IndexMainTable == [8 9])
                    SoilFull{nlayer.CPT(i),7} = interp1([SoilFull{nlayer.CPT(i),1}, SoilFull{nlayer.CPT(i)+1,2}],[SoilFull{nlayer.CPT(i),6}, SoilFull{nlayer.CPT(i)+1,7}],SoilFull{nlayer.CPT(i),2});
                end
                if isnan(SoilFull{nlayer.CPT(i),IndexMainTable(2)})
                    SoilFull{nlayer.CPT(i),IndexMainTable(2)} = values.local(i,CPT);
                end
            end
            if i == 1
                if SoilFull{end,2} > values.local(1,depth)
                    SoilFull{nlayer.CPT(i),IndexMainTable(2)} = interp1(cell2mat(SoilFull(nlayer.CPT(i),1:2)),cell2mat(SoilFull(nlayer.CPT(i),IndexMainTable)),values.local(1,depth));
                    SoilFull{nlayer.CPT(i),2} = values.local(1,depth);
                end
            end
        end
    end
    
    % Remove NaN for new layers and remove layers with 0 thickness
    for i = 2:size(SoilFull,1)
        if isnan(SoilFull{i,3})
            SoilFull(i,3:5) = SoilFull(i-1,3:5);
            SoilFull(i,10) = SoilFull(i-1,10);
        end
    end
    TabSize = size(SoilFull,1);
    for i = 1:TabSize-1
        II = TabSize-i;
        if SoilFull{II,1} == SoilFull{II,2} && (SoilFull{II,IndexMainTable(1)} == SoilFull{II-1,IndexMainTable(2)} || isnan(SoilFull{II,IndexMainTable(1)}) == isnan(SoilFull{II-1,IndexMainTable(2)})) && (SoilFull{II,IndexMainTable(2)} == SoilFull{II+1,IndexMainTable(1)} || isnan(SoilFull{II,IndexMainTable(2)}) == isnan(SoilFull{II+1,IndexMainTable(1)}))
            SoilFull(II,:) = [];
        end
    end
    
    TabSize = size(SoilFull,1);
    for i = 1:TabSize-1
        II = TabSize-i;
        if SoilFull{II,1} == SoilFull{II,2}
            index_suddenChange = find(values.local(:,depth) == SoilFull{II,1});
            
            SoilFull{II-1,IndexMainTable(2)} = values.local(index_suddenChange(1),CPT);
            SoilFull{II+1,IndexMainTable(1)} = values.local(index_suddenChange(2),CPT);
            SoilFull(II,:) = [];
        end
    end
    
    % Make layers after CPT
    nlayer.after = sum(values.local(end,depth)<cell2mat(SoilTable(:,2)));
    for i = 1:nlayer.after
        index = size(SoilFull,1)-nlayer.after+i;
        LayerG = inputG((strcmp(SoilFull(index,3),inputG(:,1))),8:end)';
        LayerG = cell2mat(LayerG(any(cellfun(@(x)any(~isnan(x)),LayerG(:,depth)),2),:));  % CPT value, depth
        indexG = find(and(cell2mat(SoilFull(index,1))<LayerG(:,depth),cell2mat(SoilFull(index,2))>LayerG(:,depth))==1);
        LayerG_1 = LayerG(indexG,:);
        if ~isempty(LayerG_1) % if there are extra layers from CPT
            if index == size(SoilFull,1)
                SoilFull = [SoilFull(1:index,:); num2cell(NaN(size(LayerG_1,1),size(SoilFull,2)))];
            else
                SoilFull = [SoilFull(1:index,:); num2cell(NaN(size(LayerG_1,1),size(SoilFull,2)));SoilFull(index+1:end,:)];
            end
            SoilFull(end-size(LayerG_1,1)+1:end,1) = num2cell(LayerG_1(:,depth));
            SoilFull(end-size(LayerG_1,1):end,IndexMainTable(1)) = num2cell([interp1(LayerG(min(indexG)-1:min(indexG),depth),LayerG(min(indexG)-1:min(indexG),CPT),SoilFull{end-size(LayerG_1,1),1});LayerG_1(:,CPT)]);
            SoilFull(end-size(LayerG_1,1):end-1,2) = num2cell(LayerG_1(:,depth));
            SoilFull(end-size(LayerG_1,1):end,IndexMainTable(2)) = num2cell([LayerG_1(:,CPT);interp1(LayerG(max(indexG):max(indexG)+1,depth),LayerG(max(indexG):max(indexG)+1,CPT),SoilFull{end,2})]);
        else  % if there are no extra layers from CPT
            for j = 1:2
                if sum(SoilFull{end,j}>LayerG(:,depth)) == 0% if equal to
                    SoilFull(end,IndexMainTable(j)) = num2cell(interp1(LayerG(1:2,depth),LayerG(1:2,CPT),SoilFull{end,j}));
                else
                    SoilFull(end,IndexMainTable(j)) = num2cell(interp1(LayerG(sum(SoilFull{end,j}>LayerG(:,depth)):sum(SoilFull{end,j}>LayerG(:,depth))+1,depth),LayerG(sum(SoilFull{end,j}>LayerG(:,depth)):sum(SoilFull{end,j}>LayerG(:,depth))+1,CPT),SoilFull{end,j}));
                end
            end
        end
    end
end

%% Adjust table
% Remove NaN for new layers
for i = 2:size(SoilFull,1)
    if isnan(SoilFull{i,3})
        SoilFull(i,3:5) = SoilFull(i-1,3:5);
        SoilFull(i,10) = SoilFull(i-1,10);
    end
end

% Remove layers with 0 thickness
TabSize = size(SoilFull,1);
for i = 1:TabSize
    II = TabSize+1-i;
    if SoilFull{II,1} == SoilFull{II,2}
        SoilFull(II,:) = [];
    end
end

% Remove NaN from CPT values
% Find NaN index
if all(IndexMainTable == [8 9])
    for i = 1:size(SoilFull,1) % Adjust qc values if any missing
        for j = 1:2
            if ~isnan(SoilFull{i,5+j})
                number_last = SoilFull{i,5+j};
                depth_last = SoilFull{i,j};
            else    % If NaN cell
                if j == 1 && ~isnan(SoilFull{i,7})
                    SoilFull{i,5+j} = interp1([depth_last, SoilFull{i,2}],[number_last, SoilFull{i,7}],SoilFull{i,j});
                else
                    flag = 0;
                    for i_forward = i+1:size(SoilFull,1) % Adjust qc values if any missing
                        for j_forward = 1:2
                            if ~isnan(SoilFull{i_forward,5+j_forward})
                                flag = 1;
                                break
                            end
                        end
                        if flag == 1
                            break
                        end
                    end
                    if abs(flag-1) < 0.0001
                        SoilFull{i,5+j} = interp1([depth_last, SoilFull{i_forward,j_forward}],[number_last, SoilFull{i_forward,5+j_forward}],SoilFull{i,j});
                    else
                        SoilFull{i,5+j} = number_last;
                    end
                end
            end
            
        end
    end
    
    for i = 1:size(SoilFull,1) % Adjust fs values if any missing
        for j = 1:2
            if ~isnan(SoilFull{i,7+j})
                number_last = SoilFull{i,7+j};
                depth_last = SoilFull{i,j};
            else    % If NaN cell
                if j == 1 && ~isnan(SoilFull{i,9})
                    SoilFull{i,7+j} = interp1([depth_last, SoilFull{i,2}],[number_last, SoilFull{i,9}],SoilFull{i,j});
                else
                    flag = 0;
                    for i_forward = i+1:size(SoilFull,1) % Adjust qc values if any missing
                        for j_forward = 1:2
                            if ~isnan(SoilFull{i_forward,7+j_forward})
                                flag = 1;
                                break
                            end
                        end
                        if flag == 1
                            break
                        end
                    end
                    if abs(flag-1) < 0.0001
                        SoilFull{i,7+j} = interp1([depth_last, SoilFull{i_forward,j_forward}],[number_last, SoilFull{i_forward,7+j_forward}],SoilFull{i,j});
                    else
                        SoilFull{i,7+j} = number_last;
                    end
                end
            end
            
        end
    end
    
elseif all(IndexMainTable == [6 7])
    for i = 1:size(SoilFull)
        for j = 1:2
            if isnan(SoilFull{i,IndexMainTable(j)})
                index = sum(SoilFull{i,j}>values.local(:,depth));
                SoilFull{i,IndexMainTable(j)} = interp1(values.local(index:index+1,depth),values.local(index:index+1,CPT),SoilFull{i,j});
            end
        end
    end
end

%% Check all levels are correct
if ~isequal(cell2mat(SoilFull(2:end,1)),cell2mat(SoilFull(1:end-1,2)))
    disp(SoilFull)
    error('Wrong soil matrix - levels does not correspond to each other')
end
