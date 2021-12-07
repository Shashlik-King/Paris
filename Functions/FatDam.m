function [SRD] = FatDam(Data,SRD,Settings,A,InputFiles,loc,locLoop)
%Routine for determining fatigue damage based on GRLWEAP output-files
%(.GWO), routine optimized for Batch calculations using DIGW.exe
% MTHG 05-12-2019
disp(['Reading the output for Analysis:  ',A.SimulationLable , ' For Location ' , loc{locLoop,1} ])

SimulationLable=Settings.SimulLable{A.Analysis};
% % InputFiles=InputFiles.(SimulationLable);

tolerance = 0.00001;
%*S-N curves in accordance with DNV-rp-c203 2012-10 table 2-1 (cathodic protection). Legend for detail categories:
%   Name   m1 m2 log(a1) log(a2) FL    k     SCF
SN=[{'B1'} 4.0 5 15.117  17.146 106.97 0
    {'B2'} 4.0 5 14.885  16.856  93.59 0           	%B2 (DNV) and 140(EC3)
    {'C'}  3.0 5 12.592  16.320  73.10 0.05
    {'C1'} 3.0 5 12.449  16.081  65.50 0.1          %C1 (DNV) and 112(EC3)
    {'C2'} 3.0 5 12.301  15.835  58.48 0.15        	%C2 (DNV) and 100(EC3)
    {'D'}  3.0 5 12.164  15.606  52.63 0.2     		%1.00  D  (DNV) and  90(EC3)
    {'E'}  3.0 5 11.855  15.350  46.78 0.2
    %*S-N curves in accordance with DNV-rp-c203 2012-10 table 2-2 (air). Legend for detail categories:
    % % %     {'B1-protected'} 4.0 5 14.917  17.146 106.97 0
    % % %     {'B2-protected'} 4.0 5 14.685  16.856  93.59 0           	%B2 (DNV) and 140(EC3)
    % % %     {'C-protected'}  3.0 5 12.192  16.320  73.10 0.05
    % % %     {'C1-protected'} 3.0 5 12.049  16.081  65.50 0.1          %C1 (DNV) and 112(EC3)
    % % %     {'C2-protected'} 3.0 5 11.901  15.835  58.48 0.15        	%C2 (DNV) and 100(EC3)
    % % %     {'D-protected'}  3.0 5 11.764  15.606  52.63 0.2     		%1.00  D  (DNV) and  90(EC3)
    % % %     {'E-protected'}  3.0 5 11.610  15.350  46.78 0.2
    
    ];     	%1.13
%    {'FAT90'} 3.0 5 6.69897  17.146 106.97 0        %GL-COWT 2012 FAT90
%    {'FAT112'} 3.0 5 6.69897  17.146 106.97 0];     %GL-COWT 2012 FAT112

gamma_m=1.0;   %material safety factor
t_ref=0.025;    %reference thickness (m) DNVGL-RP-0005_2014-06
m0=3;    %3 for welded joints according to GL-COWT 2012, Page 6-35

h=waitbar(0,'Loading .GWO files');
%%loc = Data.loc;     PNGI

% GWO read and identify Summary Over Depth
%%%for i=1:size(loc,1) PNGI
% i  Counter of the LocLoop is i in this function

%%%% Assemble the results from diffrent GWO file
[SRD]= AssembleResults (Data,SRD,Settings,A,InputFiles,loc,locLoop);

%% Create matrices with SCF and stresses
SRD.(loc{locLoop}).GWOx=max(SRD.(loc{locLoop}).gwtPile(:,1))/Settings.PileSeg(A.Analysis)*cumsum(ones(Settings.PileSeg(A.Analysis),1)); % Calculating cumulative distance from pile top related to the number of pile segments where stresses are calculated
SRD.(loc{locLoop}).GWOxMiddle=-(SRD.(loc{locLoop}).GWOx-(max(SRD.(loc{locLoop}).gwtPile(:,1))/(2*Settings.PileSeg(A.Analysis))));  %%% Distance of the middle of each segment from the pile head , the value should be negative below pile head

% Correct n to represent mid-mid
for j=2:size(SRD.(loc{locLoop}).SOD,1)-1
    SRD.(loc{locLoop}).SOD(j,10)=SRD.(loc{locLoop}).SOD(j,5)*0.5*(SRD.(loc{locLoop}).SOD(j+1,1)-SRD.(loc{locLoop}).SOD(j-1,1));
end
SRD.(loc{locLoop}).SOD(size(SRD.(loc{locLoop}).SOD,1),10)=SRD.(loc{locLoop}).SOD(size(SRD.(loc{locLoop}).SOD,1),5)*0.5*(SRD.(loc{locLoop}).SOD(size(SRD.(loc{locLoop}).SOD,1),1)-SRD.(loc{locLoop}).SOD(size(SRD.(loc{locLoop}).SOD,1)-1,1));
if A.CaclculateFatigue==1
    % Append SCF to wall thickness
    SRD.(loc{locLoop}).Pile = [NaN(size(Data.(loc{locLoop}).PileGeometry,1),2) cell2mat(Data.(loc{locLoop}).PileGeometry)];
    SRD.(loc{locLoop}).Pile(1,1) = 0;
    SRD.(loc{locLoop}).Pile(:,2) = cumsum(cell2mat(Data.(loc{locLoop}).PileGeometry(:,4)));
    SRD.(loc{locLoop}).Pile(2:end,1) = SRD.(loc{locLoop}).Pile(1:end-1,2);
    SRD.(loc{locLoop}).SCF=cell2mat(Data.(loc{locLoop}).SCF(:,1:2));    % Loading SCF table for specific location
    
    
    for j=1:size(SRD.(loc{locLoop}).SCF,1)
        Index=find(abs(SRD.(loc{locLoop}).Pile(:,1)-SRD.(loc{locLoop}).SCF(j,1)) < tolerance);  % Find index where depth in SCF table is equal to depth in pile table
        if size(Index,1) > 0
            Index_level = find(abs(SRD.(loc{locLoop}).SCF(j,1)-SRD.(loc{locLoop}).SCF(:,1)) < tolerance); % Find number of times this level appears in SCF matrix
            if length(Index_level) > 1 % use "== 1" for getting both top and bottom can weld at plot for specific levels % If only one level is defined for weld
                SRD.(loc{locLoop}).SCF(j,3)=min(SRD.(loc{locLoop}).Pile(Index(1),3),SRD.(loc{locLoop}).Pile(Index(1)-1,4)); % If SCF table level is at can connection, take minimum diameter for two connected cans (should be the same)
                SRD.(loc{locLoop}).SCF(j,4)=min(SRD.(loc{locLoop}).Pile(Index(1),5),SRD.(loc{locLoop}).Pile(Index(1)-1,5)); % If SCF table level is at can connection, take minimum wall thickness for two connected cans
                
            elseif length(Index_level) == 1
                SRD.(loc{locLoop}).SCF(j,3)=SRD.(loc{locLoop}).Pile(Index(1),3); % If SCF table level is at can connection, take minimum diameter for two connected cans (should be the same)
                SRD.(loc{locLoop}).SCF(j,4)=SRD.(loc{locLoop}).Pile(Index(1),5); % If SCF table level is at can connection, take minimum wall thickness for two connected cans
                
            elseif length(Index_level) == 2   % If both a level for bottom and top of can is present in SCF vector, take the respective can index
                Index_topbottom = find(Index_level==j);
                if Index_topbottom == 1 % If the current level is for the bottom of previous can
                    SRD.(loc{locLoop}).SCF(j,3) = SRD.(loc{locLoop}).Pile(Index(1)-1,4);
                    SRD.(loc{locLoop}).SCF(j,4) = SRD.(loc{locLoop}).Pile(Index(1)-1,5);
                elseif Index_topbottom == 2 % If the current level is for the top of next can
                    SRD.(loc{locLoop}).SCF(j,3) = SRD.(loc{locLoop}).Pile(Index(1),3);
                    SRD.(loc{locLoop}).SCF(j,4) = SRD.(loc{locLoop}).Pile(Index(1),5);
                end
            end
        else % If not in can connection/weld, use interpolation for diameter and find respective wall thickness
            SRD.(loc{locLoop}).SCF(j,3)=interp1(SRD.(loc{locLoop}).Pile(sum(SRD.(loc{locLoop}).Pile(:,1)<SRD.(loc{locLoop}).SCF(j,1)),1:2),SRD.(loc{locLoop}).Pile(sum(SRD.(loc{locLoop}).Pile(:,1)<SRD.(loc{locLoop}).SCF(j,1)),3:4),SRD.(loc{locLoop}).SCF(j,1));  % Add column 3 in SCF table with diameter for respective depth
            SRD.(loc{locLoop}).SCF(j,4)=SRD.(loc{locLoop}).Pile(sum(SRD.(loc{locLoop}).Pile(:,1)<SRD.(loc{locLoop}).SCF(j,1)),5);  % Add column 4 in SCF table with wall thickness for respective depth
        end
    end
    %%%Assign the dimeter of the pile as the diameter of tip  PNGI
    SRD.(loc{locLoop}).SCF(end,3)=SRD.(loc{locLoop}).Pile(end,4);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    SRD.(loc{locLoop}).SCF(:,5)=(SRD.(loc{locLoop}).SCF(:,3).^2-(SRD.(loc{locLoop}).SCF(:,3)-2*SRD.(loc{locLoop}).SCF(:,4)).^2)*pi/4;   % SCF table column 5 add cross section area for respective level
    
    %%%%%Add the frist and last point to the forces
    
    SRD.(loc{locLoop}).mxTforInt=[SRD.(loc{locLoop}).mxT(1,:);SRD.(loc{locLoop}).mxT;SRD.(loc{locLoop}).mxT(end,:)];
    SRD.(loc{locLoop}).mxCforInt=[SRD.(loc{locLoop}).mxC(1,:);SRD.(loc{locLoop}).mxC;SRD.(loc{locLoop}).mxC(end,:)];
    SRD.(loc{locLoop}).GWOxforInt=[0;SRD.(loc{locLoop}).GWOx; SRD.(loc{locLoop}).SCF(end,1)+0.05];
    
    
    
    % Interpolate forces (T+C) in levels from SCF table
    for j=1:size(SRD.(loc{locLoop}).SOD,1)
        
        
        SRD.(loc{locLoop}).Force(:,j)=-interp1(SRD.(loc{locLoop}).GWOxforInt,SRD.(loc{locLoop}).mxTforInt(:,j),SRD.(loc{locLoop}).SCF(:,1),'linear')+interp1(SRD.(loc{locLoop}).GWOxforInt,SRD.(loc{locLoop}).mxCforInt(:,j),SRD.(loc{locLoop}).SCF(:,1),'linear');
        SRD.(loc{locLoop}).Force_mxT(:,j) = interp1(SRD.(loc{locLoop}).GWOxforInt,SRD.(loc{locLoop}).mxTforInt(:,j),SRD.(loc{locLoop}).SCF(:,1));
        SRD.(loc{locLoop}).Force_mxC(:,j) = interp1(SRD.(loc{locLoop}).GWOxforInt,SRD.(loc{locLoop}).mxCforInt(:,j),SRD.(loc{locLoop}).SCF(:,1));
    end
    SRD.(loc{locLoop}).Stress=bsxfun(@rdivide,SRD.(loc{locLoop}).Force,SRD.(loc{locLoop}).SCF(:,5));  % calculate stresses for all forces with the cross section area from SCF table column 5
    SRD.(loc{locLoop}).Stress_mxT=bsxfun(@rdivide,SRD.(loc{locLoop}).Force_mxT,SRD.(loc{locLoop}).SCF(:,5));
    SRD.(loc{locLoop}).Stress_mxC=bsxfun(@rdivide,SRD.(loc{locLoop}).Force_mxC,SRD.(loc{locLoop}).SCF(:,5));
    
    %% Adjust for DNV mean stress and effective thickness factors
    
    %turn off/on the effective thickness and the mean stress factor:
    %note that the effective thickness on the attachments is only applied
    %for the  closed hole, i.e. S-N curve different than B2.
    %Instead the mean factor is applied only on the open holes, i.e.
    %S-N curve B2. All this assumptions as well as the 60mm weld width
    %come from the STR team during SNA project
    switch_teff_weld = 1;
    switch_teff_attm = 1;
    switch_teff_open = 1;
    switch_fm_weld = 0;
    switch_fm_attm = 0;
    switch_fm_open = 1;
    
    
    SRD.(loc{locLoop}).SCF(:,6) = SRD.(loc{locLoop}).SCF(:,4); % Create new column for adjusted wall thickness (possible to correct the value from teff
    for t = 1:size(SRD.(loc{locLoop}).SCF,1)
        if switch_teff_weld && strcmp(Data.(loc{locLoop}).SCF{t,4},'weld') && ~strcmp(Data.(loc{locLoop}).SCF{t,3},'B2')
            SRD.(loc{locLoop}).SCF(t,6) = thicknessEffective_DNV(SRD.(loc{locLoop}).SCF(t,4),0.060);%verify 60mm asuumption with MartinKelm
        elseif switch_teff_attm && strcmp(Data.(loc{locLoop}).SCF{t,4},'attm') && ~strcmp(Data.(loc{locLoop}).SCF{t,3},'B2')
            SRD.(loc{locLoop}).SCF(t,6) = thicknessEffective_DNV(SRD.(loc{locLoop}).SCF(t,4),0.060);   %verify 60mm asuumption with MartinKelm
        elseif switch_teff_open && strcmp(Data.(loc{locLoop}).SCF{t,4},'open') && ~strcmp(Data.(loc{locLoop}).SCF{t,3},'B2')
            SRD.(loc{locLoop}).SCF(t,6) = thicknessEffective_DNV(SRD.(loc{locLoop}).SCF(t,4),0.060);   %verify 60mm asuumption with MartinKelm
            
        end
    end
    
    
    mean_stress = (SRD.(loc{locLoop}).Stress_mxC+SRD.(loc{locLoop}).Stress_mxT)/2;  % Mean stress used for determining mean stress factor
    f_m_Matrix = ones(size(SRD.(loc{locLoop}).Stress));
    for t = 1:size(SRD.(loc{locLoop}).Stress,1)
        for p = 1:size(SRD.(loc{locLoop}).Stress,2)
            if switch_fm_weld && strcmp(Data.(loc{locLoop}).SCF{t,4},'weld')
                f_m_Matrix(t,p) = meanStress_DNV(SRD.(loc{locLoop}).Stress(t,p),mean_stress(t,p));
            elseif switch_fm_attm && strcmp(Data.(loc{locLoop}).SCF{t,4},'attm')
                f_m_Matrix(t,p) = meanStress_DNV(SRD.(loc{locLoop}).Stress(t,p),mean_stress(t,p));
            elseif switch_fm_open && strcmp(Data.(loc{locLoop}).SCF{t,4},'OPEN')
                f_m_Matrix(t,p) = meanStress_DNV(SRD.(loc{locLoop}).Stress(t,p),mean_stress(t,p));
                f_m_Matrix(t,p)=0.8;       %%%% Just for Comparising with Strcture team
                
            end
        end
    end
    
    
    %% Calculate fatigue damage
    N = NaN(size(SRD.(loc{locLoop}).Stress));
    for j=1:size(SRD.(loc{locLoop}).Stress,1)     % Loop over number of relevant points for SCF matrix
        Index = find(strcmp(SN(:,1),Data.(loc{locLoop}).SCF(j,3)));  % Find index for correct row in SN table for SN curves
        for k=1:size(SRD.(loc{locLoop}).Stress,2)     % Loop over number of steps / number of files used to cover the installation
            % SN capacity based on log(N)=log(a)-m*log(Dsig)
            % log rules applied       y*log(x)=log(x^y)
            %                         log(x/y)=log(x)-log(y)
            % arriving at: log(N)=log(a/(Dsig^m))
            %                  N = a/(Dsig^m)
            if SRD.(loc{locLoop}).Stress(j,k)*f_m_Matrix(j,k)*Data.(loc{locLoop}).SCF{j,2}*gamma_m>SN{Index,6} && SRD.(loc{locLoop}).Stress(j,k)>0
                N(j,k)=(10^SN{Index,4})/((SRD.(loc{locLoop}).Stress(j,k)*f_m_Matrix(j,k)*SRD.(loc{locLoop}).SCF(j,2)*gamma_m*(SRD.(loc{locLoop}).SCF(j,6)/t_ref)^SN{Index,7})^SN{Index,2});
                N_test(j,k) = 1; %Delete
            elseif SRD.(loc{locLoop}).Stress(j,k)*f_m_Matrix(j,k)*Data.(loc{locLoop}).SCF{j,2}*gamma_m<=SN{Index,6} && SRD.(loc{locLoop}).Stress(j,k)>0
                N(j,k)=(10^SN{Index,5})/((SRD.(loc{locLoop}).Stress(j,k)*f_m_Matrix(j,k)*SRD.(loc{locLoop}).SCF(j,2)*gamma_m*(SRD.(loc{locLoop}).SCF(j,6)/t_ref)^SN{Index,7})^SN{Index,3});
                N_test(j,k) = 2; %Delete
            else % for F=0
                N(j,k)=10^10;
                N_test(j,k) = 3; %Delete
            end
        end
    end
    
    SRD.(loc{locLoop}).D=Settings.DFF(A.Analysis)*sum(bsxfun(@ldivide, N', SRD.(loc{locLoop}).SOD(:,10)));
    waitbar(locLoop/size(loc,1),h);
    SRD.(loc{locLoop}).Nindex = N_test; %Delete
    %%%end   PNGI
    close(h)
    disp('----------------------------------------------------------------------------')
else
    disp('No Calculation of Fatigue damage')
    
end
end



%% Not used code
% For using FAT90 and FAT112, the following adjustments needs to be implemented
%     %Correction of reference stress for wall thickness according to GL-COWT 2012
%     %Identify FAT90
%     Ident=strfind(Data.(loc{i}).SCF(:,3),'FAT90');
%     if sum(cell2mat(Ident))>0
%         % Adjust WT
%         Index=find(not(cellfun('isempty',Ident)));
%         SRD.(loc{i}).SCF(Index,4)=90/1000*(25./(SRD.(loc{i}).SCF(Index,4)*1000)).^2;
%     end
%     %Identify FAT112
%     Ident=strfind(Data.(loc{i}).SCF(:,3),'FAT112');
%     if sum(cell2mat(Ident))>0
%         % Adjust WT
%         Index=find(not(cellfun('isempty',Ident)));
%         SRD.(loc{i}).SCF(Index,4)=112/1000*(25./(SRD.(loc{i}).SCF(Index,4)*1000)).^2;
%     end