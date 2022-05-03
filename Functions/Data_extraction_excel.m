function  [] = Data_extraction_excel(Settings)
% Function to extract the data of interest into excel
%% Input
ID = Settings.Locations(:,1);
Analyses = cell(sum(Settings.AnalysisSwitch),1);
count = 1;
for i= 1:size(Settings.Analysis,1)
    if Settings.AnalysisSwitch(i)
        Analyses{count} = Settings.Analysis{i};
        count = count +1;
    end
end

path_base = strcat(pwd,'\Output');
cd(path_base)

%% Load all output files
name = cell(size(ID,1),size(Analyses,1)); 
for i= 1:size(Analyses,1)
    for j = 1:size(ID,1)
        if Settings.LocationSwitch(j,:)
            name{j,i} = strcat(ID{j,1},'_',Analyses(i)); 
            OUTPUT.(name{j,i}{1,1}) = load(name{j,i}{1,1});
        end
    end
end

%% Clean the excel output table from PDAcalc
counter_2  = 1;
Excel_setup = cell(sum([Settings.Excel_data{:,1}]),size(Settings.Excel_data,2)); % preallocation
for i = 1:size(Settings.Excel_data,1)
    Excel_setup(counter_2,:) = Settings.Excel_data(i,:);
    counter_2 = counter_2 + 1;
end



%% Save into excels
for i = 1:size(Excel_setup,1)
    XL = Excel_setup(i,:);
    XL_logic = cellfun(@isnan,XL,'UniformOutput', false);
    comp_num = (size(Excel_setup,2) - sum([XL_logic{:}]) - 4) / 2;
%     Add check to see if input is not wrong

Switch = cell2mat(Excel_setup(i,1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Blow_count
    if strcmp(Excel_setup(i,3) , 'Blowcounts') && Switch == 1
        for j = 1:comp_num
            DATA = struct2cell(OUTPUT.([Excel_setup{i,3+2*j},'_',Settings.Analysis{Excel_setup{i,4+2*j}}]));
            Dmatrix{j,1} = DATA{1,1}.DATA.Dmatrix;
            SOD{j,1}     = DATA{1,1}.SRD.SOD;
        end
        DATA_FINAL_blow = SOD{1,1}(:,1);
        header_blow(1,1) = {'Penetration depth'};
        units_blow{1,1} = {'[m]'};
        for j = 1:comp_num % add blowcounts
            DATA_FINAL_blow = [DATA_FINAL_blow , SOD{j,1}(:,5)];
            header_blow(1,end+1) = {['Blowcount_',Settings.Analysis{Excel_setup{i,4+2*j}}]};           
            units_blow(1,end+1) = {'[Blows/m]'};
        end
        for j = 1:comp_num % add hammer efficiency
            DATA_FINAL_blow = [DATA_FINAL_blow , Dmatrix{j,1}(:,6)*100];
            header_blow(1,end+1) = {['Hammer_efficiency_',Settings.Analysis{Excel_setup{i,4+2*j}}]};
            units_blow(1,end+1) = {'[%]'};
        end
        for j = 1:comp_num % add ENTHRU
            DATA_FINAL_blow = [DATA_FINAL_blow , SOD{j,1}(:,9)];
            header_blow(1,end+1) = {['ENTHRU_',Settings.Analysis{Excel_setup{i,4+2*j}}]};
            units_blow(1,end+1) = {'[kJ]'};
        end

        File_name = strcat(Excel_setup{i,5},'.xlsx');
        xlswrite(File_name, header_blow,  Excel_setup{i,4}, 'B1');
        xlswrite(File_name, units_blow,  Excel_setup{i,4}, 'B2');
        xlswrite(File_name, DATA_FINAL_blow,  Excel_setup{i,4}, 'B3');
        
    elseif strcmp(Excel_setup(i,3) , 'SRD') && Switch == 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        % SRD
        for j = 1:comp_num
            DATA = struct2cell(OUTPUT.([Excel_setup{i,3+2*j},'_',Settings.Analysis{Excel_setup{i,4+2*j}}]));
            Dmatrix{j,1} = DATA{1,1}.DATA.Dmatrix;
            SOD{j,1}     = DATA{1,1}.SRD.SOD;
        end
        DATA_FINAL_SRD = SOD{1,1}(:,1);
        header_SRD(1,1) = {'Penetration depth'};
        units_SRD{1,1} = {'[m]'};
        for j = 1:comp_num % add blowcounts
            DATA_FINAL_SRD = [DATA_FINAL_SRD , SOD{j,1}(:,3)];
            DATA_FINAL_SRD = [DATA_FINAL_SRD , SOD{j,1}(:,4)];
            header_SRD(1,end+1) = {['Friction_',Settings.Analysis{Excel_setup{i,4+2*j}}]};
            header_SRD(1,end+1) = {['End_bearing_',Settings.Analysis{Excel_setup{i,4+2*j}}]}; 
            units_SRD(1,end+1) = {'[MN]'};
            units_SRD(1,end+1) = {'[MN]'};
        end

        File_name = strcat(Excel_setup{i,5},'.xlsx');
        xlswrite(File_name, header_SRD,  Excel_setup{i,4}, 'B1');
        xlswrite(File_name, units_SRD,  Excel_setup{i,4}, 'B2');
        xlswrite(File_name, DATA_FINAL_SRD,  Excel_setup{i,4}, 'B3');

    elseif strcmp(Excel_setup(i,3) , 'Forces') && Switch == 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Forces
        for j = 1:comp_num
            DATA = struct2cell(OUTPUT.([Excel_setup{i,3+2*j},'_',Settings.Analysis{Excel_setup{i,4+2*j}}]));
            maxTen = DATA{1,1}.SRD.mxT;
            maxCom = DATA{1,1}.SRD.mxC;
            pile_length = sum([DATA{1,1}.DATA.PileGeometry{:,4}]);
            for jj = 1:size(maxCom,1)
                maxmaxTen{j,1}(jj,:) = min(maxTen(jj,:));
                maxmaxCom{j,1}(jj,:) = max(maxCom(jj,:));
                elev{j,1}(jj,:) = jj*-(pile_length/size(maxCom,1));
            end
        end
        DATA_FINAL_force = elev{1,1};
        header_force(1,1) = {'Penetration depth'};
        units_force{1,1} = {'[m]'};
        for j = 1:comp_num % add blowcounts
            DATA_FINAL_force = [DATA_FINAL_force , maxmaxTen{j,1}, maxmaxCom{j,1}];
            header_force(1,end+1) = {['Min_tension_force_',Settings.Analysis{Excel_setup{i,4+2*j}}]}; 
            header_force(1,end+1) = {['Max_compression_force_',Settings.Analysis{Excel_setup{i,4+2*j}}]}; 
            units_force(1,end+1) = {'[MN]'};
            units_force(1,end+1) = {'[MN]'};
        end

        File_name = strcat(Excel_setup{i,5},'.xlsx');
        xlswrite(File_name, header_force,  Excel_setup{i,4}, 'B1');
        xlswrite(File_name, units_force,  Excel_setup{i,4}, 'B2');
        xlswrite(File_name, DATA_FINAL_force,  Excel_setup{i,4}, 'B3');

    else
        warning('wrong type of comparison chosen. Please specify a new type.')
    end

end