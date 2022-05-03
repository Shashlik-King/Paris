function[SRD] = AlmHamre(Data,Settings,A,loc,SRD)
if nargin ==4 || nargin==5
    %%% Skin friction and end bearing calculations.
    %%% Soil model for pile driveability predictions based on CPT interpretation,
    %%% T.Alm and L.Hamre
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Type 1 = sand
    %Type 2 = clay
    %Type 3 = glauconite
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Pa = 100;          % Reference atmospheric pressure [kPa]
    MPa=1000;         % Convert MPa to kPa
    
    R_eqauv=SRD.(loc{1}).Eqau_Redius_bot(end,1);
    Thichness=SRD.(loc{1}).tw(end,1);       %Thickness at pile tip
    Diameter=SRD.(loc{1}).out_daim(end,1);  %Diameter at pile tip
    
    [SoilTable  Damping_Table SRDMultiplier HammerBreakCoeff Glauconite_Rf_Multiplier]=Soil_Profile_Assem(Data,Settings,A,loc,SRD);
    
    % Import data from PDAcalc
    Setup=cell2mat(Damping_Table(:,5));     % Setup factor
    LimDist=cell2mat(Damping_Table(:,6));  % Limit distance
    Nc=cell2mat(Damping_Table(:,8));       % Dimensionless bearing capcaity factor, Nc 
    
    % Generate z
    n=size(SoilTable,1);  % Set number of soil springs
    z=cell2mat(SoilTable(:,1));
    
    
    % Interpolate soil onto z
    gamma = cell2mat(SoilTable(:,4));          %Unitweight
    T = cell2mat(SoilTable(:,3));              %Soilmodel
    Model=SoilTable(:,8);                      %SRD Model
    YSR=SoilTable(:,10);                       %SRD Model
    St=SoilTable(:,11);                        %SRD Model
    
    su = cell2mat(SoilTable(:,12));            %SRD Model    
    OCR = cell2mat(SoilTable(:,13));           %SRD Model
    UCS = cell2mat(SoilTable(:,14));           %SRD Model
    Delta_phi = cell2mat(SoilTable(:,7));      %Delta phi
    phi = cell2mat(SoilTable(:,9));            %phi
    
    % CPT values onto z and convert to kPa
    CPT(:,1) = cell2mat(SoilTable(:,5))*MPa;     %qc in kPa
    CPT(:,2) = cell2mat(SoilTable(:,6))*MPa;     %fs in kPa
    CPT(:,3)= T ;
    
    % Overburden pressure, sigma_v0
    sigv = NaN(size(SoilTable,1),1);
    sigv(1)=0;
    for i = 2:size(SoilTable,1)
        sigv(i) = sigv(i-1)+ (z(i)-z(i-1))*(gamma(i-1)-10);
    end
%     if T(1)==1 
        sigv(1)=0.01;  % Adjust first index at 0 depth so we dont divide by 0 at side friction calculation
%     end
    
    %    Compile matrix for unit skin friction ans vector for tip resistance
    %------
    
        % Generating exponential-decay-matrix (vector for each AStep)
    z_D = Data.(loc{1}).Dmatrix(Data.(loc{1}).Dindex(:,2),1);   % Depths to analyse taken from D matrix
    fs = nan(length(z_D),n);
    
    for j = 1:length(z_D)    % loop over the location of the tip

    for i=1:n     %Loop over the soil profile depth
           
        SRD_model=Model{i};
        
        switch SRD_model
            case  'Alm_Hamre'
        
        [fsi(i) fsres(i) qt(i) k(i) fs(j,i) SkinQuake(i) ToeQuake(i) SkinDamping(i) ToeDamping(i)]=Model_Alm_herme(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,Delta_phi,Damping_Table ,Glauconite_Rf_Multiplier);
    
            case 'Alm_Hamre_2018'
                
        [fsi(i) fsres(i) qt(i) k(i) fs(j,i) SkinQuake(i) ToeQuake(i) SkinDamping(i) ToeDamping(i)]=Model_Alm_herme_2018(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,Delta_phi,Damping_Table,Glauconite_Rf_Multiplier);
                
            case  'ICP_18' 
                
        [fsi(i) fsres(i) qt(i) k(i) fs(j,i) SkinQuake(i) ToeQuake(i) SkinDamping(i) ToeDamping(i)]=Model_ICP_18(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,Delta_phi,R_eqauv,Thichness,Diameter,Damping_Table);
        
            case  'Jones'  
        [fsi(i) fsres(i) qt(i) k(i) fs(j,i) SkinQuake(i) ToeQuake(i) SkinDamping(i) ToeDamping(i)]=Model_Jones(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,Delta_phi,R_eqauv,Thichness,Diameter,Damping_Table,YSR,St);

            case  'Stevens'
        [qt(i), fs(i), SkinQuake(i), ToeQuake(i), SkinDamping(i), ToeDamping(i)]=Model_Stevens(i,T,sigv,phi,Delta_phi,OCR,su,Damping_Table,loc,Nc,UCS);    
          
            case  'Puech_rock'
        [qt(i), fs(i), SkinQuake(i), ToeQuake(i), SkinDamping(i), ToeDamping(i)]=Model_Puech(i,T,sigv,phi,Delta_phi,OCR,su,Damping_Table,Diameter,Thichness,loc,Nc,SoilTable,UCS);
        %%Case Model is Alpaca

        
        %% Case Model is Holly Man
        end 
        
        %%Applying the Hammer Break Down  , if the depth of penetration is
        %%larger than the define depth, then we apply the coefficient on
        %%the Shaft from the top to the depth of hammer break down
        %%Note : Hammer break down is applied only two meters according to
        %%DNV GL 
        if z_D(j) >= z_D(end)-Settings.HammerBreakDepth(A.Analysis) && z_D(j)<= z_D(end)-Settings.HammerBreakDepth(A.Analysis)+2  && z(i)<=z_D(end)-(Settings.HammerBreakDepth(A.Analysis)-2) 
            fs(j,i)=fs(j,i)*cell2mat(HammerBreakCoeff(i,1)); % Shaft resistance from depth to the depth of hammer break down would be multiplied by factor.            
        end  

    end
    end    
    
    % Save results in SRD structure for current location for later use 
    SRD.(loc{1}).Soil.z=z;
    SRD.(loc{1}).Soil.z_D=z_D; % IF exist fres fo AlmHamre
    SRD.(loc{1}).Soil.CPT=CPT;
    if exist('fres','var')
        SRD.(loc{1}).Soil.fsres=fsres; % IF exist fres fo AlmHamre
        SRD.(loc{1}).Soil.fsi=fsi; % IF exist fres fo AlmHamre
        SRD.(loc{1}).Soil.k=k;
    end
    SRD.(loc{1}).Soil.fs=fs;
    SRD.(loc{1}).Soil.qt=qt;
    SRD.(loc{1}).Soil.qt_gwt = qt*SRD.(loc{1}).gwtPile(end,2)/(100^2); % Multiplied with bottom pile area for getting correct input for .gwt files
    SRD.(loc{1}).Soil.QuakeDamp=[SkinQuake' ToeQuake' SkinDamping' ToeDamping'];
    SRD.(loc{1}).Soil.LimDist=LimDist; 
    SRD.(loc{1}).Soil.Setup=Setup; 
    SRD.(loc{1}).Soil.SoilTable=SoilTable;
    SRD.(loc{1}).Soil.SRDMultiplier=SRDMultiplier;
    
end
end