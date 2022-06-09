function [fsi, fsres, qt, k, fs, SkinQuake, ToeQuake, SkinDamping, ToeDamping] = Model_Boughas(j,i,T,sigv,~,CPT,z,z_D,~,~,phi,Damping_Table,Glauconite_Rf_Multiplier, K_0, loc)
% i is the index of the soil 
% j is the the index of z matrix (location of the tip)
if T.tip(i) == 4  % Glauconite
    qt          = (0.1*CPT.tip(i,1)*(CPT.tip(i,1)/sigv.tip(i))^0.2);
else
    error(['Soil not defined for ' loc{1} ' in Boughas.m function' ])
end

if T.shaft(i) == 4  % Glauconite
    if isnan(Glauconite_Rf_Multiplier{i})
       error(['Glauconite defined for ' loc{1} ' needs a multiplier for its higher shaft friction' ]) 
    elseif Glauconite_Rf_Multiplier{i} == -1
        Rf = 100 * CPT.shaft(i,2)/CPT.shaft(i,1);
    else
        Rf = Glauconite_Rf_Multiplier{i};
    end
    sigma_h     = K_0.shaft(i) * sigv.shaft(i) + abs(CPT.shaft(i,5));
    fsi         = Rf * 0.5 * sigma_h * tan((phi.shaft(i))*pi/180);               % Friction only outside
    sigma_h_res = K_0.shaft(i) * sigv.shaft(i) + 0.5 *  abs(CPT.shaft(i,5));
    fsres       = Rf * 0.5 * sigma_h_res * tan((15)*pi/180);
    qt          = (0.1*CPT.tip(i,1)*(CPT.tip(i,1)/sigv.tip(i))^0.2);
    k           = ((CPT.shaft(i,1)/sigv.shaft(i))^(0.5))/80;     

else
    error(['Soil not defined for ' loc{1} ' in Boughas.m function' ])
end
     
if z_D(j) >= z(i)
   fs = (fsres+(fsi-fsres)*exp(k*(z(i)-z_D(j))));
else 
   fs = NaN;               
end

SkinQuake   = cell2mat(Damping_Table(i,4));
ToeQuake    = cell2mat(Damping_Table(i,3));
SkinDamping = cell2mat(Damping_Table(i,2));
ToeDamping  = cell2mat(Damping_Table(i,1)); 
           
end