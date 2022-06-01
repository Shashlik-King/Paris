function [D] = VantommeEffect(Pile_Geo, water_depth, EntraptParam, D, Effic)

a       = EntraptParam(1); % reallocate Vontomme parameter
b       = EntraptParam(2); % reallocate Vontomme parameter
c       = EntraptParam(3); % reallocate Vontomme parameter
d       = EntraptParam(4); % reallocate Vontomme parameter
beta    = 1;
Lemb    = max(D(:,1));  % Ebmede length 
Dtop    = min(Pile_Geo(:,1)); % Top diamater of conical section
Dbottom = max(Pile_Geo(:,1)); % Bottom diameter of conical section

for i = 1:size(Pile_Geo,1)
    if abs(Pile_Geo(i,1)-Pile_Geo(i,2)) < 0.00001
        HsegTaper(i,1) = 0;
    else         
        HsegTaper(i,1) = Pile_Geo(i,4);
    end 

    if Pile_Geo(i,1) < Dbottom    
        HsegCil(i,1) = 0;
    else         
        HsegCil(i,1) = Pile_Geo(i,4);
    end   
end 

HTaper      = sum(HsegTaper); % length of conical section
LCil        = sum(HsegCil); % length of straigth section after end of conical section
alpha       = radtodeg(atan(((Dbottom-Dtop)/2)/HTaper)); % angle of conical section     
Esubmerged  = water_depth*(a+b*Dbottom)+beta*HTaper*(c+d*alpha); % total reduction based on how much of conical section is submerged at target depth
 
for i = 1:size(D,1)       
    if water_depth-(LCil-D(i,1)) < 0
        K_Conical(i,1) = 0;
        D(i,6) = Effic; % take predefined efficiency           
    else 
        K_Conical(i,1) = min(water_depth-(LCil-D(i,1)),HTaper);
        D(i,6) = Effic*(1-((K_Conical(i,1)/HTaper)*Esubmerged)); % calculate final efficiency            
    end 
end     
end 