function [fsi, fsres, qt, k, fs, SkinQuake, ToeQuake, SkinDamping, ToeDamping] = Model_Jones(j,i,T,sigv,Pa,CPT,z,z_D,~,~,phi,~,~,~,Damping_Table,YSR,St,Glauconite_Rf_Multiplier,loc)

% i is the index of the soil 
% j is the the index of z matrix (location of the tip)
%% Tip resistance calculation
if T.tip(i) == 1   %SAND
    if phi.tip(i)
        error('Wrong input of phi for sand in Jones - phi-5 used for calculation is negative ')
    end
    qt = (0.15*CPT.tip(i,1)*(CPT.tip(i,1)/sigv.tip(i))^0.2);
elseif (T.tip(i) == 2 || T.tip(i) == 3 )  %CLAY
    qt = 0.6*CPT.tip(i,1);
elseif T.tip(i) == 4  %glauconite
    qt = (0.15*CPT.tip(i,1)*(CPT.tip(i,1)/sigv.tip(i))^0.2);
else
    error(['Soil not defined for ' loc{1} ' in Jones function' ])
end

%% Shaft friction calculation
if T.shaft(i) == 1   %SAND
    if phi.tip(i) <= 0 || phi.shaft(i) <= 0
        error('Wrong input of phi for sand in Jones - phi-5 used for calculation is negative ')
    end
    K           = (0.0132*CPT.shaft(i,1)*(sigv.shaft(i)/Pa)^(0.13))/sigv.shaft(i);
    fsi         = 0.5*K*sigv.shaft(i)*tan((phi.shaft(i))*pi/180);                   % Friction only outside
    fsres       = 0.2*fsi;
    k           = ((CPT.shaft(i,1)/sigv.shaft(i))^(0.5))/80;

elseif (T.shaft(i) == 2 || T.shaft(i) == 3 )  %CLAY
    fsres       = max(0.004*CPT.shaft(i,1)*(1-0.0025*CPT.shaft(i,1)/sigv.shaft(i)),0);
    fsi_total   = CPT.shaft(i,2);
    delta_I_vy  = log10(St.shaft{i});
    K           = 0.00844 * YSR.shaft{i}^0.42 * (137.5 + YSR.shaft{i} - 54.375 * delta_I_vy);
    fsi_eff     = K * sigv.shaft(i) * tan((phi.shaft(i))*pi/180);
    fsi         = min(fsi_eff , fsi_total);
    k           = ((CPT.shaft(i,1)/sigv.shaft(i))^(0.5))/(100*tan((phi.shaft(i))*pi/180));

elseif T.shaft(i) == 4  %glauconite
    K = (0.0132*CPT.shaft(i,1)*(sigv(i)/Pa)^(0.13))/sigv.shaft(i);
    if isnan(Glauconite_Rf_Multiplier{i})
       error(['Glauconite defined for ' loc{1} ' needs a multiplier for its higher shaft friction.' ]) 
    elseif Glauconite_Rf_Multiplier{i} == -1
        Rf = 100 * CPT.shaft(i,2)/CPT.shaft(i,1);
    else
        Rf = Glauconite_Rf_Multiplier{i};
    end 
    fsi     = Rf * 0.5*K*sigv.shaft(i)*tan((phi.shaft(i))*pi/180);               % Friction only outside
    fsres   = 0.2*fsi;
    k       = ((CPT.shaft(i,1)/sigv.shaft(i))^(0.5))/80;
    
else
    error(['Soil not defined for ' loc{1} ' in Jones function' ])
end

if z_D(j)>=z(i)
   fs = (fsres+(fsi-fsres)*exp(k*(z(i)-z_D(j))));
else 
   fs = NaN;               
end

SkinQuake   = cell2mat(Damping_Table(i,4));
ToeQuake    = cell2mat(Damping_Table(i,3));
SkinDamping = cell2mat(Damping_Table(i,2));
ToeDamping  = cell2mat(Damping_Table(i,1)); 
          
end