function [SoilOut,Embed] = Stevens(Cshaftsand, Cshastclay, Ctoesand, Ctoeclay, Factor1, Factor2, Factor4, ...
    rho_w, K, Nc, soil, toeArea, Embedment, z)

%%% Skin friction and end bearing calculations according to:
%%% DNVGL-ST-0126 and Stevens(1982)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Limit factors for Stevens/Static approach
delta=[15 20 25 30 35 50];
NQ=[8 12 20 40 50 50];
fL=[48 67 81 96 115 115];
qL=[1900 2900 4800 9600 12000 12000];

T=interp1(soil(:,1),soil(:,3),z,'previous');
gamma=interp1(soil(:,1),soil(:,4),z,'previous');
phi=interp1(soil(:,1),soil(:,5),z,'previous');
cu=interp1(soil(:,1),soil(:,6),z,'previous');
PI=interp1(soil(:,1),soil(:,7),z,'previous');
SetupFactor=interp1(soil(:,1),soil(:,8),z,'previous');

G=gamma-rho_w;
d=phi-5;

sigv(1)=0.5*(z(2)-z(1))*G(1);
for i = 2:length(z)
    delta_sigv(i)=(z(i)-z(i-1))*(G(i));
    sigv(i)=sum(delta_sigv);
end

%-------------------------------------------
%       Compile soil matrix
%----------------------------------
Nq=interp1(delta,NQ,d,'previous');
qmax=interp1(delta,qL,d,'previous');
fmax=interp1(delta,fL,d,'previous');

% Lookup for Limit Dist (linear extrapolated to cover k=1)
% Fitted for fL=0, fSetup=5, f0=0.01
k_lim=[0.02 0.04 0.06 0.08 0.1 0.13 0.16 0.2 0.25 0.3 0.35 0.4 1];
LimitDistlim=[230 115 78 59 48 37 30 24 20 16.5 14 12.5 5.5];
LimDist=interp1(k_lim,LimitDistlim,k,'linear');

for i = 1:length(z)
    if T(i)==1
        % sand deposits
        f(i)=min(K*sigv(i)*tan(d(i)*pi/180),fmax(i));
        q(i)=min(sigv(i)*Nq(i),qmax(i))*toeArea/10000;
        Cshaft(i)=Cshaftsand;
        Ctoe(i)=Ctoesand;
    elseif T(i)==2
        % clay deposits
        if  cu(i)/sigv(i)>1
            alph(i)=1/(2*(cu(i)/sigv(i))^(1/4));
        else
            alph(i)=1/(2*(cu(i)/sigv(i))^(1/2));
        end
        f(i)=0.5*alph(i)*cu(i)*(cu(i)/(sigv(i)*(0.11+0.0037^PI(i))))^(0.30/0.85);  %MTHG to correct;
        q(i)=Nc*cu(i);
        Cshaft(i)=Cshastclay;
        Ctoe(i)=Ctoeclay;
    end
end

%-------------------------------------------
for i = 1:length(z)
    f1(i)=Factor1;
    f2(i)=Factor2;
    % f3(i)=Factor3;
    f4(i)=Factor4;
    f5(i)=0.00;
    f6(i)=toeArea;
end

results= [z' f' q' f1' f2' Cshaft' Ctoe' SetupFactor' f4' f5' f6'];
SoilOut=results;
Embed=Embedment;
end