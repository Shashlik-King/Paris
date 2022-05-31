function [fsi fsres qt k fs SkinQuake ToeQuake SkinDamping ToeDamping]=Model_Lehane(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,phi,Damping_Table, Glauconite_Rf_Multiplier,Lehane_variables, Thichness, Diameter)
%FKMV - 2022-05-31 
% i is the index of the soil 
% j is the the index of z matrix (location of the tip)

a = Lehane_variables{i,1};
b = Lehane_variables{i,2};
c = Lehane_variables{i,3};


f_t = 1; % f_t/f_c should be 1 for piles in compression and 0.75 for piles in tension
f_c = 1; % f_t/f_c should be 1 for piles in compression and 0.75 for piles in tension
h = z_D(j)-z(i); % distance from the tip ; % distance from pile tip
D = Diameter; % outer diameter
D_i = Diameter - Thichness; % outer diameter
        
if T(i)==1    %SAND
    if phi(i)<= 0
        error('Wrong input of phi for sand in AlmHamre.m - phi-5 used for calculation is negative ')
    end

    if z_D(j)>=z(i)
        fs=(CPT(i,1)/a) * (f_t/f_c) * (max(1 , h/D))^b * ((1 - D_i/D)^2)^c*1.25; 
    else 
        fs=NaN;   
    end
    fsi = (CPT(i,1)/a) * (f_t/f_c) * 1^b * ((1 - D_i/D)^2)^c * tan((phi(i))*pi/180);
    fsres = (CPT(i,1)/a) * (f_t/f_c) * (z_D(end)/D)^b * ((1 - D_i/D)^2)^c * tan((phi(i))*pi/180); 
    qt=0.3*CPT(i,1);
elseif (T(i)==2 || T(i)==3 )  %CLAY
    b = 0;
    c = 0;
    fs=(CPT(i,1)/a) * (f_t/f_c) * (max(1 , h/D))^b * ((1 - D_i/D)^2)^c*2;   
    fsi = (CPT(i,1)/a) * (f_t/f_c) * 1^b * ((1 - D_i/D)^2)^c * tan((phi(i))*pi/180);
    fsres = (CPT(i,1)/a) * (f_t/f_c) * (z_D(end)/D)^b * ((1 - D_i/D)^2)^c * tan((phi(i))*pi/180); 
    qt=0.6*CPT(i,1);
elseif (T(i)==4 )  %GLAUCO
    if isnan(Glauconite_Rf_Multiplier{i})
        error(['Glauconite defined for ' loc{1} ' needs a multiplier for its higher shaft friction' ]) 
    elseif Glauconite_Rf_Multiplier{i} == -1
        Rf = 100 * CPT(i,2)/CPT(i,1);
    else
        Rf = Glauconite_Rf_Multiplier{i};
    end
    if phi(i)<= 0
        error('Wrong input of phi for sand in AlmHamre.m - phi-5 used for calculation is negative ')
    end

    if z_D(j)>=z(i)
        fs=(CPT(i,1)/a) * (f_t/f_c) * (max(1 , h/D))^b * ((1 - D_i/D)^2)^c*1.25;
    else 
        fs=NaN;   
    end
    fsi = (CPT(i,1)/a) * (f_t/f_c) * 1^b * ((1 - D_i/D)^2)^c * tan((phi(i))*pi/180);
    fsres = (CPT(i,1)/a) * (f_t/f_c) * (z_D(end)/D)^b * ((1 - D_i/D)^2)^c * tan((phi(i))*pi/180); 
    qt=0.3*CPT(i,1);
    
end

k = -5555; % shape factor not used hence Lehane does not use it. Set to random number to show this. 

SkinQuake=cell2mat(Damping_Table(i,4));
ToeQuake=cell2mat(Damping_Table(i,3));
SkinDamping=cell2mat(Damping_Table(i,2));
ToeDamping=cell2mat(Damping_Table(i,1)); 
           
end