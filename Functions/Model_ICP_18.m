function [fsi, fsres, qt, k, fs, SkinQuake, ToeQuake, SkinDamping, ToeDamping] = Model_ICP_18(j,i,~,sigv,~,CPT,z,z_D,~,~,phi,R_eqauv,Thichness,Diameter,Damping_Table)

if phi(i)-5 <= 0
    error('Wrong input of phi for sand in Model_ICP.m - phi-5 used for calculation is negative ')
end

h           = z_D(j)-z(i); % distance from the tip 
h_R_ratio   = max(h/R_eqauv,6); %lower limit of 6 is applied to the ratio Jardine et al 2018
D_tw_ratio  = Diameter/Thichness;  
sigma_r_i   = 0.031*CPT(i,1)*(h_R_ratio^(-0.481*((D_tw_ratio)^0.145)));

if z_D(j) >= z(i)
    fs = 0.5*sigma_r_i*tan((phi(i))*pi/180);   %Friction is applied only outside 
else 
    fs = NaN;   
end

fsi         = 0.5*0.031*CPT(i,1)*(6^(-0.481*((D_tw_ratio)^0.145)))*tan((phi(i))*pi/180);                   % Friction only outside
fsres       = 0.5*0.031*CPT(i,1)*((z_D(end)/R_eqauv)^(-0.481*((D_tw_ratio)^0.145)))*tan((phi(i))*pi/180); 
qt          = 0.6*CPT(i,1);
k           = (CPT(i,1)/sigv(i))^(0.5)/80;

SkinQuake   = cell2mat(Damping_Table(i,4));
ToeQuake    = cell2mat(Damping_Table(i,3));
SkinDamping = cell2mat(Damping_Table(i,2));
ToeDamping  = cell2mat(Damping_Table(i,1)); 

end