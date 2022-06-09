function [fsi, fsres, qt, k, fs, SkinQuake, ToeQuake, SkinDamping, ToeDamping] = Model_Lehane(j,i,T,~,~,CPT,z,z_D,~,~,phi,Damping_Table, Glauconite_Rf_Multiplier,Lehane_variables, Thichness, Diameter, loc)
%FKMV - 2022-05-31 
% i is the index of the soil 
% j is the the index of z matrix (location of the tip)

a   = Lehane_variables{i,1};
b   = Lehane_variables{i,2};
c   = Lehane_variables{i,3};
f_t = 1; % f_t/f_c should be 1 for piles in compression and 0.75 for piles in tension
f_c = 1; % f_t/f_c should be 1 for piles in compression and 0.75 for piles in tension
h   = z_D(j)-z(i); % distance from the tip ; % distance from pile tip
D   = Diameter; % outer diameter
D_i = Diameter - Thichness; % outer diameter

%% Tip resistance calculation
if T.tip(i) == 1    %SAND
    qt = 0.3*CPT(i,1);
elseif (T.tip(i) == 2 || T.tip(i) == 3 )  %CLAY
    qt = 0.6*CPT.tip(i,1);
elseif (T.tip(i) == 4 )  %GLAUCO 
    qt = 0.3*CPT.tip(i,1);
end

%% Shaft friction calculation
if T.shaft(i) == 1    %SAND
    if phi.shaft(i) <= 0
        error('Wrong input of phi for sand in Lehane - phi-5 used for calculation is negative ')
    end

    if z_D(j) >=z (i)
        fs = (CPT.shaft(i,1)/a) * (f_t/f_c) * (max(1 , h/D))^b * ((1 - D_i/D)^2)^c*1.25; 
    else 
        fs = NaN;   
    end
    fsi     = (CPT.shaft(i,1)/a) * (f_t/f_c) * 1^b * ((1 - D_i/D)^2)^c * tan((phi.shaft(i))*pi/180);
    fsres   = (CPT.shaft(i,1)/a) * (f_t/f_c) * (z_D(end)/D)^b * ((1 - D_i/D)^2)^c * tan((phi.shaft(i))*pi/180); 
elseif (T.shaft(i) == 2 || T.shaft(i) == 3 )  %CLAY
    b       = 0;
    c       = 0;
    fs      = (CPT.shaft(i,1)/a) * (f_t/f_c) * (max(1 , h/D))^b * ((1 - D_i/D)^2)^c*2;   
    fsi     = (CPT.shaft(i,1)/a) * (f_t/f_c) * 1^b * ((1 - D_i/D)^2)^c * tan((phi.shaft(i))*pi/180);
    fsres   = (CPT.shaft(i,1)/a) * (f_t/f_c) * (z_D(end)/D)^b * ((1 - D_i/D)^2)^c * tan((phi.shaft(i))*pi/180); 
elseif (T.shaft(i) == 4 )  %GLAUCO
    if isnan(Glauconite_Rf_Multiplier{i})
        error(['Glauconite defined for ' loc{1} ' needs a multiplier for its higher shaft friction' ]) 
    elseif Glauconite_Rf_Multiplier{i} == -1
        Rf = 100 * CPT.shaft(i,2)/CPT.shaft(i,1);
    else
        Rf = Glauconite_Rf_Multiplier{i};
    end
    if phi.shaft(i)<= 0
        error('Wrong input of phi for sand in Lehane - phi-5 used for calculation is negative ')
    end

    if z_D(j) >= z(i)
        fs = (CPT.shaft(i,1)/a) * (f_t/f_c) * (max(1 , h/D))^b * ((1 - D_i/D)^2)^c*1.25;
    else 
        fs = NaN;   
    end
    fsi     = (CPT.shaft(i,1)/a) * (f_t/f_c) * 1^b * ((1 - D_i/D)^2)^c * tan((phi.shaft(i))*pi/180);
    fsres   = (CPT.shaft(i,1)/a) * (f_t/f_c) * (z_D(end)/D)^b * ((1 - D_i/D)^2)^c * tan((phi.shaft(i))*pi/180); 

end

k           = -5555; % shape factor not used hence Lehane does not use it. Set to random number to show this. 
SkinQuake   = cell2mat(Damping_Table(i,4));
ToeQuake    = cell2mat(Damping_Table(i,3));
SkinDamping = cell2mat(Damping_Table(i,2));
ToeDamping  = cell2mat(Damping_Table(i,1)); 
           
end