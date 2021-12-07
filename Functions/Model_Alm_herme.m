function [fsi fsres qt k fs SkinQuake ToeQuake SkinDamping ToeDamping]=Model_Alm_herme(j,i,T,sigv,Pa,CPT,z,z_D,A,Settings,phi,Damping_Table, Glauconite_Rf_Multiplier)

        % i is the index of the soil 
        % j is the the index of z matrix (location of the tip)
       

        if T(i)==1   %SAND
            if phi(i)<= 0
                error('Wrong input of phi for sand in AlmHamre.m - phi-5 used for calculation is negative ')
            end
            K=(0.0132*CPT(i,1)*(sigv(i)/Pa)^(0.13))/sigv(i);
            fsi=0.5*K*sigv(i)*tan((phi(i))*pi/180);                   % Friction only outside
            fsres=0.2*fsi;
            qt=(0.15*CPT(i,1)*(CPT(i,1)/sigv(i))^0.2);
            k=((CPT(i,1)/sigv(i))^(0.5))/80;
%             SkinQuake=Settings.SkinQuake(A.Soil);
%             ToeQuake=Settings.ToeQuake(A.Soil);
%             SkinDamping=Settings.SkinDampSand(A.Soil);
%             ToeDamping=Settings.ToeDampSand(A.Soil);
        elseif (T(i)==2 || T(i)==3 )  %CLAY
            fsres=max(0.004*CPT(i,1)*(1-0.0025*CPT(i,1)/sigv(i)),0.002*CPT(i,1));
            fsi=CPT(i,2);
            qt=0.6*CPT(i,1);
            k=((CPT(i,1)/sigv(i))^(0.5))/80;
            
            %SkinQuake=Settings.SkinQuake(A.Soil);
            %ToeQuake=Settings.ToeQuake(A.Soil);
            %SkinDamping=Settings.SkinDampClay(A.Soil);
            %ToeDamping=Settings.ToeDampClay(A.Soil);
        elseif T(i)==4  %glauconite
            K=(0.0132*CPT(i,1)*(sigv(i)/Pa)^(0.13))/sigv(i);
            if isnan(Glauconite_Rf_Multiplier{i})
               error(['Glauconite defined for ' loc{1} ' needs a multiplier for its higher shaft friction.' ]) 
            elseif Glauconite_Rf_Multiplier{i} == -1
                Rf = 100 * CPT(i,2)/CPT(i,1);
            else
                Rf = Glauconite_Rf_Multiplier{i};
            end    

            fsi=Rf * 0.5*K*sigv(i)*tan((phi(i))*pi/180);               % Friction only outside
            fsres=0.2*fsi;
            qt=(0.15*CPT(i,1)*(CPT(i,1)/sigv(i))^0.2);
            k=((CPT(i,1)/sigv(i))^(0.5))/80;
            
            %SkinQuake=Settings.SkinQuake(A.Soil);
            %ToeQuake=Settings.ToeQuake(A.Soil);
            %SkinDamping=Settings.SkinDampClay(A.Soil);
            %ToeDamping=Settings.ToeDampClay(A.Soil);            
        else
            error(['Soil not defined for ' loc{1} ' in AlmHamre.m function' ])
        end
        

        
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