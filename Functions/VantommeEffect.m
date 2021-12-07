function [D]=VantommeEffect(Pile_Geo, water_depth,EntraptParam,D,Effic)

a=EntraptParam(1);
b=EntraptParam(2);
c=EntraptParam(3);
d=EntraptParam(4);

beta=1;

Lemb=max(D(:,1));  % Ebmede length 

Dtop=min(Pile_Geo(:,1));

Dbottom=max(Pile_Geo(:,1));

for i =1:size(Pile_Geo,1);
    
    if abs(Pile_Geo(i,1)-Pile_Geo(i,2))<0.00001
        HsegTaper(i,1)=0;
    else         
        HsegTaper(i,1)=Pile_Geo(i,4);
    end 
    
    if Pile_Geo(i,1)<Dbottom    
        HsegCil(i,1)=0;
    else         
        HsegCil(i,1)=Pile_Geo(i,4);
    end   
end 
        HTaper=sum(HsegTaper);
        LCil=sum(HsegCil);

        alpha=radtodeg(atan(((Dbottom-Dtop)/2)/HTaper));      
        Esubmerged=water_depth*(a+b*Dbottom)+beta*HTaper*(c+d*alpha);

        
        
 for i =1:size(D,1);       
        if water_depth-(LCil-D(i,1))<0
            K_Conical(i,1)=0;
            D(i,6)=Effic;            
        else 
            K_Conical(i,1)=min(water_depth-(LCil-D(i,1)),HTaper);
            D(i,6)=Effic*(1-((K_Conical(i,1)/HTaper)*Esubmerged));            
        end 
 end 
        
        
        
end 