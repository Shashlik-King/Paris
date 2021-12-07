function Data = D_MatrixGeneration(Settings,A,Data,locations,locLoop)
% Function for generating and saving the D matrix for GRLweap
%for i = 1:size(Data.loc,1)

    loc = locations(locLoop,:);
    if Settings.BackCalc(A.Analysis)==1   % Overwrite stroke for back-calculations

          
      %    D(:,4)=import stroke from excel
        %end
        error('Code what to do for back calculations')
        %%% D = ;%%%%%%%%%%%%%%%%%%%%%%%%%% Pooyan to put in function here and delete error above 
        
         
        
        NoSteps = size(D,1)-1;
        IndexD=zeros(NoSteps,2);
        IndexD(1,1)=1;
        IndexD(NoSteps,2)=size(D,1);
        if loc{2}>40
            dEmb=ceil((loc{2}-20)/(NoSteps-1));
        else
            dEmb=ceil((loc{2}-10)/(NoSteps-1));
        end
        for j = 1:NoSteps-1
            IndexD(j,2)=IndexD(NoSteps,2)-(NoSteps-j)*dEmb;
            IndexD(j+1,1)=IndexD(j,2);
        end
        IndexD = IndexD+1;
        
    elseif A.Database && 0>1    % Remove last criterion when implementet
        % Code what to do if database switch is turned on with regards to D matrix
        error('Code what to do for D matrix when using DB')
        % This elseif might be unneeded, as same should be done for all cases
     else
  
        % Compile D matrix
        D_vector = unique([1:loc{2} loc{2}])';
        D=zeros(length(D_vector),8);
        D(:,1)=D_vector;
        
        % Define number of steps
        if Settings.AnalysisSteps(A.Analysis) == 0
            NoSteps = ceil(loc{2});
        else
            NoSteps = Settings.AnalysisSteps(A.Analysis);
        end
            
        % Set Index for D and fs
        IndexD=zeros(NoSteps,2);
        IndexD(1,1)=1;
        IndexD(NoSteps,2)=size(D,1);
        if loc{2}>40
            dEmb=ceil((loc{2}-20)/(NoSteps-1));
        else
            dEmb=ceil((loc{2}-10)/(NoSteps-1));
        end
        for j = 1:NoSteps-1
            IndexD(j,2)=IndexD(NoSteps,2)-(NoSteps-j)*dEmb;
            IndexD(j+1,1)=IndexD(j,2);
        end
        IndexD = IndexD+1;
        IndexD(1,1) = 1;
        D = [D(1,:); D];
        D(1,1) = 0.1;
        
        
        
        
         water_depth=cell2mat(loc(3));
         IsEntrapedWater=Settings.EntrapedWater{A.Analysis};
         Effic=Settings.HammerEfficiency(A.Analysis);
         
         D(:,6)=Effic; % Hammer Efficiency to the D matrix 
         
         Pile_Geo=cell2mat(Data.(loc{1}).PileGeometry);
         
        if~all(Pile_Geo(:,1)==Pile_Geo(:,2))  % Entrap Water only if pile is conical shape
         if strcmp(IsEntrapedWater,'IHC S-4000')
          
             EntraptParam=[0.00025, 0.00007, -0.001, 0.00125];
            [D]=VantommeEffect(Pile_Geo, water_depth,EntraptParam,D,Effic);
             
         elseif strcmp(IsEntrapedWater,'IHC S-1200')
             EntraptParam=[0.00025, 0.00020, -0.001, 0.00125];
            [D]=VantommeEffect(Pile_Geo, water_depth,EntraptParam,D,Effic);             
                
         elseif strcmp(IsEntrapedWater,'IHC S-3000')
             
             EntraptParam=[0.00025, 0.00013, -0.001, 0.00125];
            [D]=VantommeEffect(Pile_Geo, water_depth,EntraptParam,D,Effic); 
                 
         else 
             display('Entraped water is not applied')
             
         end 
        end 

        
        
        
     
 
    
    % Save D matrix and index for current location
    Data.(loc{1}).Dmatrix = D;
    Data.(loc{1}).Dindex = IndexD;
    Data.(loc{1}).NoSteps = NoSteps;
    end    
%end
end