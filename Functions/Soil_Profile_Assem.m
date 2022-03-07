function [SoilTable  Damping_Table SRDMultiplier HammerBreakCoeff Glauconite_Rf_Multiplier Lehane_variables]=Soil_Profile_Assem(Data,Settings,A,loc,SRD)


%%%%Defining the soil type%%%%%%%%5    

 Soil_type=Settings.SoilType(A.Analysis);

SRD_profile=Data.(loc{1}).SRD_prop(1:sum(loc{2} > cell2mat(Data.(loc{1}).SRD_prop(:,1))),:); 


%     if ischar(SoilProfile_1{1,5})
%         SoilProfile_1(:,5)=num2cell(cellfun(@str2double,SoilProfile_1(:,5)));
%     end

    SoilProfile_1 = Data.(loc{1}).SoilProfile(1:sum(loc{2} > cell2mat(Data.(loc{1}).SoilProfile(:,2))),:);  % Soil profile Stratigraphy

    if ischar(SoilProfile_1{1,5})
        SoilProfile_1(:,5)=num2cell(cellfun(@str2double,SoilProfile_1(:,5)));
    end
    LastDepthofStr=cell2mat(Data.(loc{1}).SoilData (end,1));
    % Save soil profile with information for needed embedment length
    %ImportCPTProfile = Data.(loc{1}).SoilData(1:sum(loc{2} > cell2mat(Data.(loc{1}).SoilData(:,1))),:);  % CPT Profile
    ImportCPTProfile = Data.(loc{1}).SoilData(1:sum(LastDepthofStr >= cell2mat(Data.(loc{1}).SoilData(:,1))),:);  % CPT Profile
    %%%%%%  Assigning the SRD Model Parameters 

    
    DepthTable1(:,1:2)=cell2mat(SoilProfile_1(:,2:3));      % Depth in soil profile stratigraphy table
    
    % Converting the Interpratated CPT profile to the design profile
    
    [CPTProfile] = soilAssignment(SoilProfile_1,cell2mat(ImportCPTProfile)); %Function to Interpolate the inported CPT data
    
    
    
    
    DepthTable2(:,1:2)=cell2mat(CPTProfile(:,1:2));      % Depth of CPT Table
    DepthSRD(:,1:2)=cell2mat(SRD_profile(:,1:2));        % Depth of SRD Table
    

    %%%Check if the two tables of SRD and soil profile has the same depth
    %%%and layering 
    
    if DepthTable1==DepthSRD;
        disp('The table of soil profile and SRD profile are matched')
    else 
        error('The table of soil profile and SRD profile is not consistant') 
    end 
    
    
          SoilTableRaw = cell(size(CPTProfile,1)*2,9);
          
          
    for i = 1:size(CPTProfile,1)
        for j = 1:2           %Useful PNGI
            SoilTableRaw((i-1)*2+j,:) = num2cell([CPTProfile{i,j}, NaN, NaN, NaN, CPTProfile{i,3+j}, CPTProfile{i,5+j}, NaN, NaN,NaN]);
            SoilTableRaw((i-1)*2+j,2) = CPTProfile(i,3);
%             SoilTableRaw((i-1)*2+j,8) = SoilProfile(i,11); 

        end
    end

        
     % Add points for driveability depths
    D_vector = Data.(loc{1}).Dmatrix(Data.(loc{1}).Dindex(:,2)); % Import depths from driveability matrix used in each file
    
    for i = 1:length(D_vector)      %%Interpolate the Depth of Soil with Respect of D Vector
        if ~any(D_vector(i) == cell2mat(SoilTableRaw(:,1)))
            index = sum(cell2mat(SoilTableRaw(:,1))<D_vector(i));
            newline = [D_vector(i), SoilTableRaw(index,2), SoilTableRaw(index,3), SoilTableRaw(index,4), interp1(cell2mat(SoilTableRaw(index:index+1,1)),cell2mat(SoilTableRaw(index:index+1,5)),D_vector(i)), interp1(cell2mat(SoilTableRaw(index:index+1,1)),cell2mat(SoilTableRaw(index:index+1,6)),D_vector(i)), SoilTableRaw(index,7), SoilTableRaw(index,8) SoilTableRaw(index,9)];
            SoilTableRaw = [SoilTableRaw(1:index,:); newline; SoilTableRaw(index+1:end,:)];
        end
    end
    counter = 1;
    for i = 1:size(SoilTableRaw,1)-1
        if ~all(cellfun(@isequal, SoilTableRaw(i,:), SoilTableRaw(i+1,:)))
            SoilTable(counter,:) = SoilTableRaw(i,:);
            counter = counter+1;
        end
    end
    SoilTable(counter,:) = SoilTableRaw(end,:);     % Add last row
    
    
    %%% Assigning the SRD model, Phi and Gamma from the Soil profile and
    %%% SRD Table 
    
    z=cell2mat(SoilTable(:,1)); 
    soil_index=zeros(size(z));  % initilize the soil index vector
    Damping_Table=cell(size(SoilTable,1),size(SRD_profile,2)-12); 
    
    SRDMultiplier=zeros(size(SoilTable,1),1);
    
    
    
    for i=2:length(z)
        
        for ii=1:size(DepthSRD,1)
        if (z(i)+z(i-1))/2>= DepthSRD(ii,1) && (z(i)+z(i-1))/2 < DepthSRD(ii,2)           % to avoid confusion, middle of each sub layer should be inside of the General layering
        
            soil_index(i)=ii;
            
            
            SoilTable(i,4)=SoilProfile_1(ii,5);    % Assigning Gamma Efective 
            SoilTable(i,7)=SoilProfile_1(ii,7);    % Assigning delta  friction angle 
    
            SoilTable(i,8)=SRD_profile(ii,4);    % Assigning SRD Model
            
            SoilTable(i,9)=SoilProfile_1(ii,6);    % Assigning Friction angle
            SoilTable(i,10)=SoilProfile_1(ii,8);
            SoilTable(i,11)=SoilProfile_1(ii,9);
            %%%%Assiging the type of the soil 

           if contains(SRD_profile(ii,3),'sand') || contains(SRD_profile(ii,3),'Sand') || contains(SRD_profile(ii,3),'SAND')

            SoilTable(i,3)=num2cell(1);      % Cohesionless equal to 1 
           elseif  contains(SRD_profile(ii,3),'glauconite') || contains(SRD_profile(ii,3),'Glauconite') || contains(SRD_profile(ii,3),'GLAUCONITE')
            SoilTable(i,3)=num2cell(4);      %sand containing glauconte soil equal to 3
           elseif   strcmp(SRD_profile(ii,3),'clay') || contains(SRD_profile(ii,3),'Clay') || contains(SRD_profile(ii,3),'CLAY')
            SoilTable(i,3)=num2cell(2);      %Cohesive soil equal to 2
           elseif   strcmp(SRD_profile(ii,3),'clay_L_PI') || contains(SRD_profile(ii,3),'Clay_L_PI') || contains(SRD_profile(ii,3),'CLAY_L_PI')
            SoilTable(i,3)=num2cell(2);      %Cohesive soil with low to meduim plasticity equal to 2 (Alm&Hamre 2018)          
           elseif   strcmp(SRD_profile(ii,3),'clay_H_PI') || contains(SRD_profile(ii,3),'Clay_H_PI') || contains(SRD_profile(ii,3),'CLAY_H_PI')
            SoilTable(i,3)=num2cell(3);      %Cohesive soil with High plasticity equal to 3 (Alm&Hamre 2018)            
           end 
            %%%%%%%%%%

            %%%%Assigning the multipliers for Upper Bound , Lower Bound and
            %%%%Best Estimate 
            
            if strcmp(Soil_type,'UB')
            SRDMultiplier(i,1)=cell2mat(SRD_profile(ii,14));            
            elseif strcmp(Soil_type,'LB')
            SRDMultiplier(i,1)=cell2mat(SRD_profile(ii,13));  
            elseif strcmp(Soil_type,'LB/UB')
            SRDMultiplier(i,1)=cell2mat(SRD_profile(ii,16));  
            else                 
            SRDMultiplier(i,1)=1;     
            end 
            %%%%  
             
            Damping_Table(i,:)= SRD_profile(ii,5:12);
            HammerBreakCoeff(i,1)=SRD_profile(ii,15);
            Glauconite_Rf_Multiplier(i,1) = SRD_profile(ii,17);
            Lehane_variables(i,:) = SRD_profile(ii,18:20);
        end 

        end 
    
    
    end        

             % Assining the Frist row 
            Damping_Table(1,:)= SRD_profile(1,5:12);  
            SoilTable(1,4)=SoilProfile_1(1,5);    % Assigning Gamma Efective 
            SoilTable(1,7)=SoilProfile_1(1,7);    % Assigning Delta Friction angle          
            SoilTable(1,8)=SRD_profile(1,4);    % Assigning SRD Model 
            SoilTable(1,9)=SoilProfile_1(1,6);    % Assigning  Friction angle
            SoilTable(1,10)=SoilProfile_1(1,8);    % Assigning su sensitivity
            SoilTable(1,11)=SoilProfile_1(1,9);    % Assigning  yield stress ratio
            
            %%%%Assiging the type of the soil 
            if contains(SRD_profile(1,3),'sand')
            SoilTable(1,3)=num2cell(1);      % Cohesionless equal to 1 
           else 
            SoilTable(1,3)=num2cell(2);      %Cohesive soil equal to 2 
           end 
            %%%%%%%%%%
            if strcmp(Soil_type,'UB')
            SRDMultiplier(1,1)=cell2mat(SRD_profile(1,14));            
            elseif strcmp(Soil_type,'LB')
            SRDMultiplier(1,1)=cell2mat(SRD_profile(1,13));                
            else                 
            SRDMultiplier(1,1)=1;     
            end 
            HammerBreakCoeff(1,1)=SRD_profile(1,15);

end 