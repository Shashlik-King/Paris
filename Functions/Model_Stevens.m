function [qt, fs, SkinQuake, ToeQuake, SkinDamping, ToeDamping] = Model_Stevens(i,T,sigv,phi,Delta_phi,OCR,su,Damping_Table,loc,Nc,UCS)

% i is the index of the soil
% j is the the index of z matrix (location of the tip)




%delta=[15 20 25 30 35 50];
delta=[15 20 25 30 35 36 37 38 39 40 41 42]; % Manche Normandie
%NQ=[8 12 20 40 50 50];
NQ=[8 12 20 40 50 55 60 70 80 100 120 140]; % Manche Normandie
%fL=[48 67 81 96 115 115];
fL=[48 67 81 96 115 118.8 122.6 126.4 130.2 134 137.8 141.6]; % Manche Normandie
%qL=[1900 2900 4800 9600 12000 12000];
qL=[1900 2900 4800 9600 12000 12480 12960 13440 13920 14400 14880 15360]; % Manche Normandie

Nq(i)=interp1(delta,NQ,Delta_phi(i),'previous');
qmax(i)=interp1(delta,qL,Delta_phi(i),'previous');
fmax(i)=interp1(delta,fL,Delta_phi(i),'previous');

%%%%%%%%%%%%%% Limit factors for Stevens/Static approach


    if T(i)==1                  %SAND
        if phi(i)== 0
            error('Wrong input of phi for sand  - phi-5 used for calculation is negative ')
        end
        fs=min(0.7*sigv(i)*tan(Delta_phi(i)*pi/180),fmax(i));
        qt=min(sigv(i)*Nq(i),qmax(i));

        
        
        
    elseif T(i)==2  || T(i)==3  %CLAY
        % clay deposits
        if  su(i)/sigv(i)<1
            alpha(i)=min(0.5*(su(i)/sigv(i))^(-1/2),1);
        else
            alpha(i)=min(0.5*(su(i)/sigv(i))^(-1/4),1);
        end
        Fp(i)=0.5*OCR(i)^0.3;
        fs=Fp(i)*alpha(i)*su(i);
        qt=Nc(i)*su(i);

        
        

    elseif T(i)==4              %CLAUCONITE

        error(['clauconite not defined in Model_Stevens.m function' ])

        
        
        
    elseif T(i)==5              %ROCK
        if phi(i) > 0 % Stevens Beta method (Sand)
            fs=min(0.7*sigv(i)*tan(Delta_phi(i)*pi/180),fmax(i));
            Nu = 3;
            qt=UCS(i)*Nu;
        else % Stevens Alpha method (clay)
            if  su(i)/sigv(i)<1
                alpha(i)=max(0.5*(su(i)/sigv(i))^(-1/2),1);
            else
                alpha(i)=max(0.5*(su(i)/sigv(i))^(-1/4),1);
            end
            Fp(i)=0.5*OCR(i)^0.3;
            Factor_inner_shaft = 0.8;
            fs=Fp(i)*alpha(i)*su(i)*Factor_inner_shaft;
            Nu = 3;
            qt=UCS(i)*Nu; 

        end



    else
        error(['Soil not defined for ' loc{1} ' in Model_Stevens.m function' ])
    end

ToeDamping=cell2mat(Damping_Table(i,1));
SkinDamping=cell2mat(Damping_Table(i,2));
ToeQuake=cell2mat(Damping_Table(i,3));
SkinQuake=cell2mat(Damping_Table(i,4));


end