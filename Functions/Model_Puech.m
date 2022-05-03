function [qt, fs, SkinQuake, ToeQuake, SkinDamping, ToeDamping] = Model_Puech(i,T,sigv,phi,Delta_phi,OCR,su,Damping_Table,Diameter,Thichness,loc,Nc,SoilTable,UCS)

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
    error(['Sand not defined in Model_Puech.m function' ])
    
    
    
    
elseif T(i)==2  || T(i)==3  %CLAY
    error(['Clay not defined in Model_Puech.m function' ])
    
    
    
    
elseif T(i)==4              %CLAUCONITE
    
    error(['Clauconite not defined in Model_Puech.m function' ])
    
    
    
    
elseif T(i)==5              %ROCK ("Puech_rock")
    if phi(i) > 0 % Stevens Beta method (Sand)
        fs=min(0.7*sigv(i)*tan(Delta_phi(i)*pi/180),fmax(i));
    else % Stevens Alpha method (clay)
        if  su(i)/sigv(i)<1
            alpha(i)=min(0.5*(su(i)/sigv(i))^(-1/2),1);
        else
            alpha(i)=min(0.5*(su(i)/sigv(i))^(-1/4),1);
        end
        Fp(i)=0.5*OCR(i)^0.3;
        fs=Fp(i)*alpha(i)*su(i);
        
        %Manche-Normandie:
        %Contribution of inner shaft resistance is estimated to 60%
        %relative to the outer shaft resistance. 
        
        Factor_inner_shaft = 0.8;
        fs = fs*Factor_inner_shaft; 
    end
    
    
    % Puech method differs from Stevens wrt pile tip resistance in rock.
    % Pile tip resistance is calculated as the most likely failure
    % mechanism out of 3 types of failure mechanisms. The one that
    % provide the lowest end bearing is considered.
    
    %%% Determination of distance (e) from top of current soil layer to top of
    %%% sybsequent SOFTER layer
    counter=2;
    pile_tip_layer = 'not_rock';
    
    for k = i:size(SoilTable,1)
        if isnan(SoilTable{i+counter,8}) %meaning pile tip is in rock layer
            pile_tip_layer = 'rock';
        else
            if (~strcmp(SoilTable(i+counter,8),'Puech_rock') || cell2mat(SoilTable(i+counter,14))< cell2mat(SoilTable(i,14))) && sigv(i)~=sigv(i+1)
                e = cell2mat(SoilTable(i+counter,1))-cell2mat(SoilTable(i,1));
                index_softer = i+counter;
            elseif (~strcmp(SoilTable(i+counter,8),'Puech_rock') || cell2mat(SoilTable(i+counter,14))< cell2mat(SoilTable(i,14))) && sigv(i)==sigv(i+1)
                e = cell2mat(SoilTable(i-1+counter,1))-cell2mat(SoilTable(i-1,1));
                index_softer = i-1+counter;
            else
                counter = counter+2;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Nu = 3.5; % bearing capacity factor
    Ap(i) = pi*Diameter^2/4; % plug area
    Aw = pi*Diameter^2/4-pi*(Diameter-2*Thichness)^2/4; %Toe area
    
    if strcmp(pile_tip_layer,'rock')
        Qp2(i) = UCS(i)*Nu*Aw;                          % Cookie-cutter failure for thick layers of rock (Puech 1990) - plugged failure mechanism - su = UCS
        qt=Qp2(i)/Aw;
    else
        
        % Nq, qmax and qp of layer below rock
        Nq_next=interp1(delta,NQ,Delta_phi(index_softer),'previous');
        qmax_next=interp1(delta,qL,Delta_phi(index_softer),'previous');
        if T(index_softer)==1 %SAND
            qp(i)=min(sigv(index_softer)*Nq_next,qmax_next); % qp = unit tip resistance below rock
        elseif T(index_softer)==2  || T(index_softer)==3 % CLAY
            qp(i)=Nc(index_softer)*su(index_softer);
        elseif T(index_softer)==5 %ROCK
            qp(i)=UCS(index_softer)*Nu;
        end


        Qp1(i) = pi*Diameter*e*UCS(i)/2+Ap(i)*qp(i);    % Cookie-cutter failure for thin layers of rock (Puech 1990) - plugged failure mechanism - su = UCS/2
        Qp2(i) = UCS(i)*Nu*Aw;                          % For thick layers of rock (Puech 1990) - plugged failure mechanism - su = UCS
        Qp3(i) = 2*pi*Diameter*e*UCS(i)/2;              % Cookie-cutter failure when penetrating rock - unplugged failure mechanism - su = UCS/2

        qt=min([Qp1(i)/Aw,Qp2(i)/Aw,Qp3(i)/Aw]);        %Qp divided by toe area to get input unit tip resistance
    
    end
else
    error(['Soil not defined for ' loc{1} ' in Model_Puech.m function' ])
end



SkinQuake=cell2mat(Damping_Table(i,4));
ToeQuake=cell2mat(Damping_Table(i,3));
SkinDamping=cell2mat(Damping_Table(i,2));
ToeDamping=cell2mat(Damping_Table(i,1));


end