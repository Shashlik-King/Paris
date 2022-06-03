function [fsi, fsres, qt, k, fs, SkinQuake, ToeQuake, SkinDamping, ToeDamping] = Model_Boughas(j,i,T,sigv,Pa,CPT,z,z_D,~,~,phi,Damping_Table,Glauconite_Rf_Multiplier, K_0, loc)
% i is the index of the soil 
% j is the the index of z matrix (location of the tip)
  
if T(i) == 4  % Glauconite
    K = (0.0132*CPT(i,1)*(sigv(i)/Pa)^(0.13))/sigv(i);
    if isnan(Glauconite_Rf_Multiplier{i})
       error(['Glauconite defined for ' loc{1} ' needs a multiplier for its higher shaft friction' ]) 
    elseif Glauconite_Rf_Multiplier{i} == -1
        Rf = 100 * CPT(i,2)/CPT(i,1);
    else
        Rf = Glauconite_Rf_Multiplier{i};
    end
%     fsi= Rf* 0.5*K*sigv(i)*tan((phi(i))*pi/180);               % Friction only outside
%     fsres = 0.2 * fsi;
    sigma_h     = K_0(i) * sigv(i) + CPT(i,5);
    fsi         = Rf * 0.5 * K * sigma_h * tan((phi(i))*pi/180);               % Friction only outside
    sigma_h_res = K_0(i) * sigv(i) + 0.5 * CPT(i,5);
%     fsres       = Rf * 0.5 * K * sigma_h_res * tan((phi(i))*pi/180);
    fsres       = Rf * 0.5 * K * sigma_h_res * tan((15)*pi/180);
    qt          = (0.1*CPT(i,1)*(CPT(i,1)/sigv(i))^0.2);
    k           = ((CPT(i,1)/sigv(i))^(0.5))/80;     

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