function [SoilTable, Damping_Table, SRDMultiplier, HammerBreakCoeff, Glauconite_Rf_Multiplier, Lehane_variables] = Soil_Profile_Assem(Data,Settings,A,loc,~)

%% Defining the soil type  
Soil_type       = Settings.SoilType(A.Analysis);
SRD_profile     = Data.(loc{1}).SRD_prop(1:sum(loc{2} > cell2mat(Data.(loc{1}).SRD_prop(:,1))),:); 
SoilProfile.tip   = Data.(loc{1}).SoilProfile.tip(1:sum(loc{2} > cell2mat(Data.(loc{1}).SoilProfile.tip(:,2))),:);  % Soil profile Stratigraphy
SoilProfile.shaft   = Data.(loc{1}).SoilProfile.shaft(1:sum(loc{2} > cell2mat(Data.(loc{1}).SoilProfile.shaft(:,2))),:);  % Soil profile Stratigraphy

%% Preallocation
HammerBreakCoeff           = cell(size(SRD_profile,1),1);
Glauconite_Rf_Multiplier   = cell(size(SRD_profile,1),1);
Lehane_variables           = cell(size(SRD_profile,1),3);

%% Check if gamma is a string - to be moved to data validation function
if ischar(SoilProfile.tip{1,5})
    SoilProfile.tip(:,5) = num2cell(cellfun(@str2double,SoilProfile.tip(:,5)));
end

if ischar(SoilProfile.shaft{1,5})
    SoilProfile.shaft(:,5) = num2cell(cellfun(@str2double,SoilProfile.shaft(:,5)));
end

%% Import CPT data for both tip and shaft
LastDepthofStr.tip = cell2mat(Data.(loc{1}).SoilData.tip(end,1)); % find last depth
LastDepthofStr.shaft = cell2mat(Data.(loc{1}).SoilData.shaft(end,1)); % find last depth
% Save soil profile with information for needed embedment length
ImportCPTProfile.tip    = Data.(loc{1}).SoilData.tip(1:sum(LastDepthofStr.tip >= cell2mat(Data.(loc{1}).SoilData.tip(:,1))),:);  % CPT Profile
ImportCPTProfile.shaft  = Data.(loc{1}).SoilData.shaft(1:sum(LastDepthofStr.shaft >= cell2mat(Data.(loc{1}).SoilData.shaft(:,1))),:);  % CPT Profile
% Converting the Interpratated CPT profile to the design profile
% [CPTProfile] = soilAssignment(SoilProfile_1,cell2mat(ImportCPTProfile)); %Function to Interpolate the inported CPT data 
[CPTProfile.tip] = soilAssignment(SoilProfile.tip,cell2mat(ImportCPTProfile.tip)); %Function to Interpolate the inported CPT data 
[CPTProfile.shaft] = soilAssignment(SoilProfile.shaft,cell2mat(ImportCPTProfile.shaft)); %Function to Interpolate the inported CPT data 

%% Check if the two tables of SRD and soil profile has the same depth and layering - to be moved to data validation function
DepthTable.tip(:,1:2) = cell2mat(SoilProfile.tip(:,2:3));      % Depth in soil profile stratigraphy table 
DepthTable.shaft(:,1:2) = cell2mat(SoilProfile.shaft(:,2:3));      % Depth in soil profile stratigraphy table 
DepthSRD(:,1:2) = cell2mat(SRD_profile(:,1:2));        % Depth of SRD Table    
if DepthTable.tip == DepthSRD & DepthTable.shaft == DepthSRD
    disp('The table of soil profile and SRD profile are matched')
else 
    error('The table of soil profile and SRD profile is not consistant') 
end 

%% Rearrange the table from CPT to Soil Table
SoilTableRaw.tip = cell(size(CPTProfile.tip,1)*2,14); % preallocation of cell array
SoilTableRaw.shaft = cell(size(CPTProfile.shaft,1)*2,14); % preallocation of cell array
for i = 1:size(CPTProfile.tip,1) 
    for j = 1:2
        SoilTableRaw.tip((i-1)*2+j,:)   = num2cell([CPTProfile.tip{i,j}, NaN, NaN, NaN, CPTProfile.tip{i,3+j}, CPTProfile.tip{i,5+j}, NaN, NaN, NaN, NaN, NaN, NaN, CPTProfile.tip{i,7+j} , CPTProfile.tip{i,9+j}]);
        SoilTableRaw.tip((i-1)*2+j,2)   = CPTProfile.tip(i,3);
        SoilTableRaw.shaft((i-1)*2+j,:) = num2cell([CPTProfile.shaft{i,j}, NaN, NaN, NaN, CPTProfile.shaft{i,3+j}, CPTProfile.shaft{i,5+j}, NaN, NaN, NaN, NaN, NaN, NaN, CPTProfile.shaft{i,7+j} , CPTProfile.shaft{i,9+j}]);
        SoilTableRaw.shaft((i-1)*2+j,2) = CPTProfile.shaft(i,3);
    end
end

%% Add points for driveability depths
D_vector = Data.(loc{1}).Dmatrix(Data.(loc{1}).Dindex(:,2)); % Import depths from driveability matrix used in each file
for i = 1:length(D_vector)      %%Interpolate the Depth of Soil with Respect of D Vector
    if ~any(D_vector(i) == cell2mat(SoilTableRaw.tip(:,1)))
        index               = sum(cell2mat(SoilTableRaw.tip(:,1)) < D_vector(i));
        newline.tip         = [D_vector(i), SoilTableRaw.tip(index,2), SoilTableRaw.tip(index,3), SoilTableRaw.tip(index,4), interp1(cell2mat(SoilTableRaw.tip(index:index+1,1)),cell2mat(SoilTableRaw.tip(index:index+1,5)),D_vector(i)), interp1(cell2mat(SoilTableRaw.tip(index:index+1,1)),cell2mat(SoilTableRaw.tip(index:index+1,6)),D_vector(i)), SoilTableRaw.tip(index,7), SoilTableRaw.tip(index,8) SoilTableRaw.tip(index,9), SoilTableRaw.tip(index,10), SoilTableRaw.tip(index,11), SoilTableRaw.tip(index,12), SoilTableRaw.tip(index,13), SoilTableRaw.tip(index,14)];
        SoilTableRaw.tip    = [SoilTableRaw.tip(1:index,:); newline.tip; SoilTableRaw.tip(index+1:end,:)];
    end

    if ~any(D_vector(i) == cell2mat(SoilTableRaw.shaft(:,1)))
        index                 = sum(cell2mat(SoilTableRaw.shaft(:,1)) < D_vector(i));
        newline.shaft         = [D_vector(i), SoilTableRaw.shaft(index,2), SoilTableRaw.shaft(index,3), SoilTableRaw.shaft(index,4), interp1(cell2mat(SoilTableRaw.shaft(index:index+1,1)),cell2mat(SoilTableRaw.shaft(index:index+1,5)),D_vector(i)), interp1(cell2mat(SoilTableRaw.shaft(index:index+1,1)),cell2mat(SoilTableRaw.shaft(index:index+1,6)),D_vector(i)), SoilTableRaw.shaft(index,7), SoilTableRaw.shaft(index,8) SoilTableRaw.shaft(index,9), SoilTableRaw.shaft(index,10), SoilTableRaw.shaft(index,11), SoilTableRaw.shaft(index,12), SoilTableRaw.shaft(index,13), SoilTableRaw.shaft(index,14)];
        SoilTableRaw.shaft    = [SoilTableRaw.shaft(1:index,:); newline.shaft; SoilTableRaw.shaft(index+1:end,:)];
    end
end
%% Clean table
counter = 1;
SoilTable.tip = cell(10000,size(SoilTableRaw.tip,2)); % preallocation
SoilTable.shaft = cell(10000,size(SoilTableRaw.shaft,2)); % preallocation
for i = 1:size(SoilTableRaw.tip,1)-1
    if ~all(cellfun(@isequal, SoilTableRaw.tip(i,:), SoilTableRaw.tip(i+1,:)))
        SoilTable.tip(counter,:) = SoilTableRaw.tip(i,:);
        counter = counter+1;
    end
end
counter = 1;
for i = 1:size(SoilTableRaw.shaft,1)-1
    if ~all(cellfun(@isequal, SoilTableRaw.shaft(i,:), SoilTableRaw.shaft(i+1,:)))
        SoilTable.shaft(counter,:) = SoilTableRaw.shaft(i,:);
        counter = counter+1;
    end
end
SoilTable.tip = SoilTable.tip(1:counter,:);     % cutting away unnecessary parts
SoilTable.tip(counter,:) = SoilTableRaw.tip(end,:);     % Add last row  
SoilTable.shaft = SoilTable.shaft(1:counter,:);     % cutting away unnecessary parts
SoilTable.shaft(counter,:) = SoilTableRaw.shaft(end,:);     % Add last row  
    
%% Assigning the SRD model, Phi and Gamma from the Soil profile and SRD Table 
z               = cell2mat(SoilTable.tip(:,1)); 
soil_index      = zeros(size(z));  % initilize the soil index vector
Damping_Table   = cell(size(SoilTable.tip,1),size(SRD_profile,2)-12); 
SRDMultiplier   = zeros(size(SoilTable.tip,1),1);
 
%% Assigment of variables    
for i = 2:length(z)
    for ii = 1:size(DepthSRD,1)
        if (z(i)+z(i-1))/2 >= DepthSRD(ii,1) && (z(i)+z(i-1))/2 < DepthSRD(ii,2)           % to avoid confusion, middle of each sub layer should be inside of the General layering

            soil_index(i)   = ii;
            SoilTable.tip(i,4)  = SoilProfile.tip(ii,5);      % Assigning Gamma Efective 
            SoilTable.tip(i,7)  = SoilProfile.tip(ii,7);      % Assigning delta  friction angle 
            SoilTable.tip(i,8)  = SRD_profile(ii,4);        % Assigning SRD Model
            SoilTable.tip(i,9)  = SoilProfile.tip(ii,6);      % Assigning Friction angle
            SoilTable.tip(i,10) = SoilProfile.tip(ii,8);      % Assigning YSR
            SoilTable.tip(i,11) = SoilProfile.tip(ii,9);      % Assigning sensitivity (clay)
            SoilTable.tip(i,12) = SoilProfile.tip(ii,10);     % Assigning K_0
            
            SoilTable.shaft(i,4)  = SoilProfile.shaft(ii,5);      % Assigning Gamma Efective 
            SoilTable.shaft(i,7)  = SoilProfile.shaft(ii,7);      % Assigning delta  friction angle 
            SoilTable.shaft(i,8)  = SRD_profile(ii,4);        % Assigning SRD Model
            SoilTable.shaft(i,9)  = SoilProfile.shaft(ii,6);      % Assigning Friction angle
            SoilTable.shaft(i,10) = SoilProfile.shaft(ii,8);      % Assigning YSR
            SoilTable.shaft(i,11) = SoilProfile.shaft(ii,9);      % Assigning sensitivity (clay)
            SoilTable.shaft(i,12) = SoilProfile.shaft(ii,10);     % Assigning K_0
            %Assiging the type of the soil 
            if contains(SRD_profile(ii,3),'sand') || contains(SRD_profile(ii,3),'Sand') || contains(SRD_profile(ii,3),'SAND')
                SoilTable.tip(i,3) = num2cell(1);      % Cohesionless equal to 1 
                SoilTable.shaft(i,3) = num2cell(1);      % Cohesionless equal to 1 
            elseif  contains(SRD_profile(ii,3),'glauconite') || contains(SRD_profile(ii,3),'Glauconite') || contains(SRD_profile(ii,3),'GLAUCONITE')
                SoilTable.tip(i,3) = num2cell(4);      %sand containing glauconte soil equal to 3
                SoilTable.shaft(i,3) = num2cell(4);      %sand containing glauconte soil equal to 3
            elseif   strcmp(SRD_profile(ii,3),'clay') || contains(SRD_profile(ii,3),'Clay') || contains(SRD_profile(ii,3),'CLAY')
                SoilTable.tip(i,3) = num2cell(2);      %Cohesive soil equal to 2
                SoilTable.shaft(i,3) = num2cell(2);      %Cohesive soil equal to 2
            elseif   strcmp(SRD_profile(ii,3),'clay_L_PI') || contains(SRD_profile(ii,3),'Clay_L_PI') || contains(SRD_profile(ii,3),'CLAY_L_PI')
                SoilTable.tip(i,3) = num2cell(2);      %Cohesive soil with low to meduim plasticity equal to 2 (Alm&Hamre 2018)
                SoilTable.shaft(i,3) = num2cell(2);      %Cohesive soil with low to meduim plasticity equal to 2 (Alm&Hamre 2018)
            elseif   strcmp(SRD_profile(ii,3),'clay_H_PI') || contains(SRD_profile(ii,3),'Clay_H_PI') || contains(SRD_profile(ii,3),'CLAY_H_PI')
                SoilTable.tip(i,3) = num2cell(3);      %Cohesive soil with High plasticity equal to 3 (Alm&Hamre 2018)   
                SoilTable.shaft(i,3) = num2cell(3);      %Cohesive soil with High plasticity equal to 3 (Alm&Hamre 2018)   
            end 

            %Assigning the multipliers for UB, LB and BE
            if strcmp(Soil_type,'UB')
                SRDMultiplier(i,1) = cell2mat(SRD_profile(ii,14));            
            elseif strcmp(Soil_type,'LB')
                SRDMultiplier(i,1) = cell2mat(SRD_profile(ii,13));  
            elseif strcmp(Soil_type,'LB/UB')
                SRDMultiplier(i,1) = cell2mat(SRD_profile(ii,16));  
            else                 
                SRDMultiplier(i,1) = 1;     
            end 
            
            % Assigment of other parameters 
            Damping_Table(i,:)              = SRD_profile(ii,5:12);
            HammerBreakCoeff(i,1)           = SRD_profile(ii,15);
            Glauconite_Rf_Multiplier(i,1)   = SRD_profile(ii,17);
            Lehane_variables(i,:)           = SRD_profile(ii,18:20);
        end 
    end 
end        

%% Assining the frist row variables
Damping_Table(1,:)          = SRD_profile(1,5:12);  
Lehane_variables(1,:)       = SRD_profile(1,18:20);  
SoilTable.tip(1,4)          = SoilProfile.tip(1,5);    % Assigning Gamma Efective 
SoilTable.tip(1,7)          = SoilProfile.tip(1,7);    % Assigning Delta Friction angle          
SoilTable.tip(1,8)          = SRD_profile(1,4);      % Assigning SRD Model 
SoilTable.tip(1,9)          = SoilProfile.tip(1,6);    % Assigning Friction angle
SoilTable.tip(1,10)         = SoilProfile.tip(1,8);    % Assigning su sensitivity
SoilTable.tip(1,11)         = SoilProfile.tip(1,9);    % Assigning yield stress ratio
SoilTable.tip(1,12)         = SoilProfile.tip(1,10);   % Assigning K_0

SoilTable.shaft(1,4)          = SoilProfile.shaft(1,5);    % Assigning Gamma Efective 
SoilTable.shaft(1,7)          = SoilProfile.shaft(1,7);    % Assigning Delta Friction angle          
SoilTable.shaft(1,8)          = SRD_profile(1,4);      % Assigning SRD Model 
SoilTable.shaft(1,9)          = SoilProfile.shaft(1,6);    % Assigning Friction angle
SoilTable.shaft(1,10)         = SoilProfile.shaft(1,8);    % Assigning su sensitivity
SoilTable.shaft(1,11)         = SoilProfile.shaft(1,9);    % Assigning yield stress ratio
SoilTable.shaft(1,12)         = SoilProfile.shaft(1,10);   % Assigning K_0

%% Assiging the type of the soil for first row
if contains(SRD_profile(1,3),'sand') || contains(SRD_profile(1,3),'Sand') || contains(SRD_profile(1,3),'SAND')
    SoilTable.tip(1,3) = num2cell(1);      % Cohesionless equal to 1 
    SoilTable.shaft(1,3) = num2cell(1);      % Cohesionless equal to 1 
elseif  contains(SRD_profile(1,3),'glauconite') || contains(SRD_profile(1,3),'Glauconite') || contains(SRD_profile(1,3),'GLAUCONITE')
    SoilTable.tip(1,3) = num2cell(4);      %sand containing glauconte soil equal to 3
    SoilTable.shaft(1,3) = num2cell(4);      %sand containing glauconte soil equal to 3
elseif   strcmp(SRD_profile(1,3),'clay') || contains(SRD_profile(1,3),'Clay') || contains(SRD_profile(1,3),'CLAY')
    SoilTable.tip(1,3) = num2cell(2);      %Cohesive soil equal to 2
    SoilTable.shaft(1,3) = num2cell(2);      %Cohesive soil equal to 2
elseif   strcmp(SRD_profile(1,3),'clay_L_PI') || contains(SRD_profile(1,3),'Clay_L_PI') || contains(SRD_profile(1,3),'CLAY_L_PI')
    SoilTable.tip(1,3) = num2cell(2);      %Cohesive soil with low to meduim plasticity equal to 2 (Alm&Hamre 2018)
    SoilTable.shaft(1,3) = num2cell(2);      %Cohesive soil with low to meduim plasticity equal to 2 (Alm&Hamre 2018)
elseif   strcmp(SRD_profile(1,3),'clay_H_PI') || contains(SRD_profile(1,3),'Clay_H_PI') || contains(SRD_profile(1,3),'CLAY_H_PI')
    SoilTable.tip(1,3) = num2cell(3);      %Cohesive soil with High plasticity equal to 3 (Alm&Hamre 2018)   
    SoilTable.shaft(1,3) = num2cell(3);      %Cohesive soil with High plasticity equal to 3 (Alm&Hamre 2018)   
end 

%% Assign SRD multiplier for first row
if strcmp(Soil_type,'UB')
    SRDMultiplier(1,1) = cell2mat(SRD_profile(1,14));            
elseif strcmp(Soil_type,'LB')
    SRDMultiplier(1,1) = cell2mat(SRD_profile(1,13));
elseif strcmp(Soil_type,'LB/UB')
    SRDMultiplier(1,1) = cell2mat(SRD_profile(1,16));  
else                 
    SRDMultiplier(1,1) = 1;     
end 
HammerBreakCoeff(1,1) = SRD_profile(1,15);

end 