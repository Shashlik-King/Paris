function [fsi fsres qt k fs SkinQuake ToeQuake SkinDamping ToeDamping]=Model_Alm_herme_Clay(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,phi,Damping_Table)

        % i is the index of the soil 
        % j is the the index of z matrix (location of the tip)
       


            fsres=max(0.004*CPT(i,1)*(1-0.0025*CPT(i,1)/sigv(i)),0.002*CPT(i,1));
            fsi=CPT(i,2);
            qt=0.6*CPT(i,1);
            k=((CPT(i,1)/sigv(i))^(0.5))/80;
        
           if z_D(j)>=z(i)
               fs=(fsres+(fsi-fsres)*exp(k*(z(i)-z_D(j))));
               
           else 
               fs=NaN;               
           end


            SkinQuake=cell2mat(Damping_Table(i,4));
            ToeQuake=cell2mat(Damping_Table(i,3));
            SkinDamping=cell2mat(Damping_Table(i,2));
            ToeDamping=cell2mat(Damping_Table(i,1)); 
           


end