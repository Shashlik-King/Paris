function[SRD] = Soil_model_caller(Data,Settings,A,loc,SRD)

if nargin ==4 || nargin==5
    %% Skin friction and end bearing calculations - calling different types of soil models
    Pa          = 100;          % Reference atmospheric pressure [kPa]
    MPa         = 1000;         % Convert MPa to kPa
    R_eqauv     = SRD.(loc{1}).Eqau_Redius_bot(end,1);
    Thichness   = SRD.(loc{1}).tw(end,1);
    Diameter    = SRD.(loc{1}).out_daim(end,1);  
    [SoilTable, Damping_Table, SRDMultiplier, HammerBreakCoeff, Glauconite_Rf_Multiplier, Lehane_variables] = Soil_Profile_Assem(Data,Settings,A,loc,SRD);
    
    % Generate z
    n = size(SoilTable.tip,1);  % Set number of soil springs
    z = cell2mat(SoilTable.tip(:,1));
    
    %% Interpolate soil onto z
    % Tip values
    gamma.tip       = cell2mat(SoilTable.tip(:,4));  %Unitweight
    T.tip           = cell2mat(SoilTable.tip(:,3));      %Soilmodel
    Model.tip       = SoilTable.tip(:,8);              %SRD Model
    YSR.tip         = SoilTable.tip(:,10);              %SRD Model
    St.tip          = SoilTable.tip(:,11);              %SRD Model
    Delta_phi.tip   = cell2mat(SoilTable.tip(:,7));    % Delta phi
%     phi.tip = cell2mat(SoilTable.tip(:,9));    %phi
    K_0.tip         = cell2mat(SoilTable.tip(:,12));    % K_0
    
    % Shaft values
    gamma.shaft       = cell2mat(SoilTable.shaft(:,4));  %Unitweight
    T.shaft           = cell2mat(SoilTable.shaft(:,3));      %Soilmodel
    Model.shaft       = SoilTable.shaft(:,8);              %SRD Model
    YSR.shaft         = SoilTable.shaft(:,10);              %SRD Model
    St.shaft          = SoilTable.shaft(:,11);              %SRD Model
    Delta_phi.shaft   = cell2mat(SoilTable.shaft(:,7));    % Delta phi
%     phi.shaft = cell2mat(SoilTable.shaft(:,9));    %phi
    K_0.shaft         = cell2mat(SoilTable.shaft(:,12));    % K_0

    %% CPT tip values onto z and convert to kPa
    % Tip values
    CPT.tip(:,1) = cell2mat(SoilTable.tip(:,5))*MPa;     %qc in kPa (end bearing)
    CPT.tip(:,2) = cell2mat(SoilTable.tip(:,6))*MPa;     %fs in kPa (sleeve friction)
    CPT.tip(:,3) = T.tip ;
    CPT.tip(:,4) = cell2mat(SoilTable.tip(:,13));    %Rf in kPa (friction ratio)
    CPT.tip(:,5) = cell2mat(SoilTable.tip(:,14))*MPa;    %u2 in kPa (pore pressure)
    
    % Shaft values
    CPT.shaft(:,1) = cell2mat(SoilTable.shaft(:,5))*MPa;     %qc in kPa (end bearing)
    CPT.shaft(:,2) = cell2mat(SoilTable.shaft(:,6))*MPa;     %fs in kPa (sleeve friction)
    CPT.shaft(:,3) = T.shaft ;
    CPT.shaft(:,4) = cell2mat(SoilTable.shaft(:,13));    %Rf in kPa (friction ratio)
    CPT.shaft(:,5) = cell2mat(SoilTable.shaft(:,14))*MPa;    %u2 in kPa (pore pressure)
    
    %% Overburden pressure, sigma_v0
    sigv.tip = NaN(size(SoilTable.tip,1),1);
    sigv.shaft = NaN(size(SoilTable.shaft,1),1);
    sigv.tip(1) = 0;
    sigv.shaft(1) = 0;
    for i = 2:size(SoilTable.tip,1)
        sigv.tip(i) = sigv.tip(i-1)+ (z(i)-z(i-1))*(gamma.tip(i-1)-10);
    end
    for i = 2:size(SoilTable.shaft,1)
        sigv.shaft(i) = sigv.shaft(i-1)+ (z(i)-z(i-1))*(gamma.shaft(i-1)-10);
    end
    sigv.tip(1) = 0.01;  % Adjust first index at 0 depth so we dont divide by 0 at side friction calculation
    sigv.shaft(1) = 0.01;  % Adjust first index at 0 depth so we dont divide by 0 at side friction calculation

    %%    Compile matrix for unit skin friction ans vector for tip resistance
    %------
        % Generating exponential-decay-matrix (vector for each AStep)
    z_D = Data.(loc{1}).Dmatrix(Data.(loc{1}).Dindex(:,2),1);   % Depths to analyse taken from D matrix
    fs = nan(length(z_D),n);
    
    for j = 1:length(z_D)    % loop over the location of the tip
        % Pile diameter inner calculations used for Lehane
%         cum_pile_length = 0;
%         for iii = 1:size(Data.(loc{1}).PileGeometry,1)
%             cum_pile_length(iii+1) =  cum_pile_length(iii) + Data.(loc{1}).PileGeometry{end-iii+1,4};
%         end
%         wt_index = find(cum_pile_length < z_D(j));
%         wall_thickness = Data.(loc{1}).PileGeometry{end-wt_index+1,3};% find wall thickness at given distance from pile tip 
%         D_i = Diameter - wall_thickness; % calculate internal pile diameter
        
        for i = 1:n     %Loop over the soil profile depth   
            SRD_model = Model.tip{i};
        
            switch SRD_model
                case  'Alm_Hamre' % Case Model is Alm and Hamre
                    [fsi(i) fsres(i) qt(i) k(i) fs(j,i) SkinQuake(i) ToeQuake(i) SkinDamping(i) ToeDamping(i)] = Model_Alm_Hamre(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,Delta_phi,Damping_Table ,Glauconite_Rf_Multiplier);

                case 'Alm_Hamre_2018' % Case Model is Alm and Hamre 2018 modification  
                    [fsi(i) fsres(i) qt(i) k(i) fs(j,i) SkinQuake(i) ToeQuake(i) SkinDamping(i) ToeDamping(i)] = Model_Alm_Hamre_2018(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,Delta_phi,Damping_Table,Glauconite_Rf_Multiplier,loc);

                case  'ICP_18'  % Case Model is Stevens  
                    [fsi(i) fsres(i) qt(i) k(i) fs(j,i) SkinQuake(i) ToeQuake(i) SkinDamping(i) ToeDamping(i)] = Model_ICP_18(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,Delta_phi,R_eqauv,Thichness,Diameter,Damping_Table);

                case  'Jones'  % Case Model is Jones
                    [fsi(i) fsres(i) qt(i) k(i) fs(j,i) SkinQuake(i) ToeQuake(i) SkinDamping(i) ToeDamping(i)] = Model_Jones(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,Delta_phi,R_eqauv,Thichness,Diameter,Damping_Table,YSR,St,Glauconite_Rf_Multiplier, loc);

                case  'Lehane'  % Case Model is Lehane
                    [fsi(i) fsres(i) qt(i) k(i) fs(j,i) SkinQuake(i) ToeQuake(i) SkinDamping(i) ToeDamping(i)] = Model_Lehane(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,Delta_phi,Damping_Table ,Glauconite_Rf_Multiplier,Lehane_variables, Thichness, Diameter,loc);
                
                case 'Boughas' % Case Model is Bouteiller - Ghasemi 2022
                    [fsi(i) fsres(i) qt(i) k(i) fs(j,i) SkinQuake(i) ToeQuake(i) SkinDamping(i) ToeDamping(i)] = Model_Boughas(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,Delta_phi,Damping_Table,Glauconite_Rf_Multiplier, K_0, loc);
            end 

            %%Applying the Hammer Break Down  , if the depth of penetration is
            %%larger than the define depth, then we apply the coefficient on
            %%the Shaft from the top to the depth of hammer break down
            %%Note : Hammer break down is applied only two meters according to
            %%DNV GL 
            if z_D(j) >= z_D(end)-Settings.HammerBreakDepth(A.Analysis) && z_D(j)<= z_D(end)-Settings.HammerBreakDepth(A.Analysis)+2  && z(i)<=z_D(end)-(Settings.HammerBreakDepth(A.Analysis)-2) 
                fs(j,i) = fs(j,i)*cell2mat(HammerBreakCoeff(i,1)); % Shaft resistance from depth to the depth of hammer break down would be multiplied by factor.            
            end  
        end
    end    
    
    % Save results in SRD structure for current location for later use 
    SRD.(loc{1}).Soil.z             = z;
    SRD.(loc{1}).Soil.z_D           = z_D;
    SRD.(loc{1}).Soil.CPT           = CPT;
    SRD.(loc{1}).Soil.fsres         = fsres;
    SRD.(loc{1}).Soil.fsi           = fsi;
    SRD.(loc{1}).Soil.fs            = fs;
    SRD.(loc{1}).Soil.k             = k;
    SRD.(loc{1}).Soil.qt            = qt;
    SRD.(loc{1}).Soil.qt_gwt        = qt*SRD.(loc{1}).gwtPile(end,2)/(100^2); % Multiplied with bottom pile area for getting correct input for .gwt files
    SRD.(loc{1}).Soil.QuakeDamp     = [SkinQuake' ToeQuake' SkinDamping' ToeDamping'];
    SRD.(loc{1}).Soil.LimDist       = 0;
    SRD.(loc{1}).Soil.Setup         = 1;
    SRD.(loc{1}).Soil.SoilTable.tip   = SoilTable.tip;
    SRD.(loc{1}).Soil.SoilTable.shaft = SoilTable.shaft;
    SRD.(loc{1}).Soil.SRDMultiplier = SRDMultiplier;
    
end
end