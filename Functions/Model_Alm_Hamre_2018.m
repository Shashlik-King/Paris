function [fsi, fsres, qt, k, fs, SkinQuake, ToeQuake, SkinDamping, ToeDamping] = Model_Alm_Hamre_2018(j,i,T,sigv,Pa,CPT,z,z_D,~,~,phi,Damping_Table,Glauconite_Rf_Multiplier,loc)

% i is the index of the soil 
% j is the the index of z matrix (location of the tip)
%% Tip resistance calculation
if T.tip(i) == 1   %SAND
    qt      = (0.1*CPT.tip(i,1)*(CPT.tip(i,1)/sigv.tip(i))^0.2);
elseif T.tip(i) == 2  %CLAY with low to medium plasticity
    qt      = 0.6*CPT.tip(i,1);
elseif T.tip(i) == 3  %CLAY with high plasticity 
    qt      = 0.6*CPT.tip(i,1);          
elseif T.tip(i) == 4  %glauconite
    qt      = (0.1*CPT.tip(i,1)*(CPT.tip(i,1)/sigv.tip(i))^0.2);        
else
    error(['Soil not defined for ' loc{1} ' in AlmHamre_2018.m function' ])
end

%% Shaft friction calculation
if T.shaft(i) == 1   %SAND
    if phi.shaft(i) <= 0 
        error('Wrong input of phi for sand in AlmHamre_2018 - phi-5 used for calculation is negative ')
    end
    K       = (0.0132*CPT.shaft(i,1)*(sigv.shaft(i)/Pa)^(0.13))/sigv.shaft(i);
    fsi     = 0.5*K*sigv.shaft(i)*tan((phi.shaft(i))*pi/180);                   % Friction only outside
    fsres   = 0.2*fsi;
    k       = ((CPT.shaft(i,1)/sigv.shaft(i))^(0.5))/80;
elseif T.shaft(i) == 2  %CLAY with low to medium plasticity
    fsres   = max(0.004*CPT.shaft(i,1)*(1-0.0025*CPT.shaft(i,1)/sigv.shaft(i)),0.002*CPT.shaft(i,1));
    fsi     = CPT.shaft(i,2);
    k       = ((CPT.shaft(i,1)/sigv.shaft(i))^(0.5))/80;
elseif T.shaft(i) == 3  %CLAY with high plasticity 
    fsres   = max(0.004*CPT.shaft(i,1)*(1-0.0025*CPT.shaft(i,1)/sigv.shaft(i)),0.002*CPT.shaft(i,1));
    fsi     = 0.75*CPT.shaft(i,2);
    k       = ((CPT.shaft(i,1)/sigv.shaft(i))^(0.5))/80;           
elseif T.shaft(i) == 4  %glauconite
    K       = (0.0132*CPT.shaft(i,1)*(sigv.shaft(i)/Pa)^(0.13))/sigv.shaft(i);
    if isnan(Glauconite_Rf_Multiplier{i})
       error(['Glauconite defined for ' loc{1} ' needs a multiplier for its higher shaft friction' ]) 
    elseif Glauconite_Rf_Multiplier{i} == -1
        Rf = 100 * CPT.shaft(i,2)/CPT.shaft(i,1);
    else
        Rf = Glauconite_Rf_Multiplier{i};
    end    
    fsi     = Rf* 0.5*K*sigv.shaft(i)*tan((phi.shaft(i))*pi/180);               % Friction only outside
    fsres   = 0.2*fsi;
    k       = ((CPT.shaft(i,1)/sigv.shaft(i))^(0.5))/80;         
else
    error(['Soil not defined for ' loc{1} ' in AlmHamre_2018.m function' ])
end

if z_D(j) >=z (i)
   fs = (fsres+(fsi-fsres)*exp(k*(z(i)-z_D(j))));
else 
   fs = NaN;               
end

SkinQuake   = cell2mat(Damping_Table(i,4));
ToeQuake    = cell2mat(Damping_Table(i,3));
SkinDamping = cell2mat(Damping_Table(i,2));
ToeDamping  = cell2mat(Damping_Table(i,1)); 

end