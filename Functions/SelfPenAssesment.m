function [SRD]=SelfPenAssesment(Data,SRD,Settings,A,loc,locLoop)

disp(['Self Penetration assessment for Analysis:  ',A.SimulationLable , ' For Location ' , loc{locLoop,1} ]) 



AnvilWeight=Settings.AnvilWeight(A.Analysis);
Assem_Weight=Settings.AssemWeight(A.Analysis);


    
    Z_D=SRD.(loc{locLoop}).Soil.z_D; % Penetration Depths 
    
    
    Pile_Data=SRD.(loc{locLoop}).gwtPile;
    
    [PileWeight]=calcPileWeight(Pile_Data); 

    TotalWeight=PileWeight+AnvilWeight+Assem_Weight;
    
    SRD.(loc{locLoop}).TotalWeight=TotalWeight;
    SRD.(loc{locLoop}).PileWeight=PileWeight;
    

    
    z=SRD.(loc{locLoop}).Soil.z;   %soil stratigraphy 
    
    ToeResistance=SRD.(loc{locLoop}).Soil.qt_gwt'';
   
%     Shaft_res_long=SRD.(loc{locLoop}).Soil.fsi';
    Shaft_res_long=SRD.(loc{locLoop}).Soil.fs; % FKMV
    
    Piameter=Pile_Data(end,5);
    
  
    [SRD.(loc{locLoop}).SWPpileWtIdx,  SRD.(loc{locLoop}).SWPpileWtDepth,  SRD.(loc{locLoop}).SkinSWP,   SRD.(loc{locLoop}).TipSWP,    SRD.(loc{locLoop}).totalRes]=SelfPenDepth(Z_D,z,ToeResistance,Shaft_res_long,Piameter,PileWeight,SRD.(loc{locLoop,1}) );
    
    [SRD.(loc{locLoop}).SWPTotalWtIdx, SRD.(loc{locLoop}).SWPTotalWtDepth, SRD.(loc{locLoop}).SkinSWP ,  SRD.(loc{locLoop}).TipSWP,    SRD.(loc{locLoop}).totalRes]=SelfPenDepth(Z_D,z,ToeResistance,Shaft_res_long,Piameter,TotalWeight,SRD.(loc{locLoop,1}) );   
    
 
        
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 function [IdxSWP,DepthSWP,total_Shaft, TipRes,  totalRes]=SelfPenDepth(Z_D,z,ToeResistance,Shaft_res_long,Piameter,Weight,SRD)
        DepthSWP=Z_D; % Assign the Pile run equal to the Last Depth , The value would be over written with the actual value of Self penetration depth 
        IdxSWP=length(Z_D);
       for j=1:length(Z_D)
        D_ActiveSoil=z(find(Z_D(j)>=z));
        Tip_ActiveSoil=ToeResistance(find(Z_D(j)>=z))*SRD.Soil.SRDMultiplier(j);
%         Skin_ActiveSoil=Shaft_res_long(find(Z_D(j)>=z))*SRD.Soil.SRDMultiplier(j);
        Shaft_res_long_mod = Shaft_res_long(j,:);
        Shaft_res_long_mod = Shaft_res_long_mod(~isnan(Shaft_res_long_mod));
        Skin_ActiveSoil = Shaft_res_long_mod*SRD.Soil.SRDMultiplier(j);
        TipRes(j,1)=Tip_ActiveSoil(end);
        
        if length(D_ActiveSoil)>1 
            for i=1:length(D_ActiveSoil)-1 
%                 Skin_ActiveSoil = Shaft_res_long(j,i)*SRD.Soil.SRDMultiplier(j);
                deltaD=D_ActiveSoil(i+1)-D_ActiveSoil(i);
                Delta_ShaftRes(i)=Skin_ActiveSoil(i)*Piameter*deltaD;           
            end 
        else 
           Delta_ShaftRes(1)=Skin_ActiveSoil(1)*Piameter*deltaD;  
        end          
            total_Shaft(j,1)=sum(Delta_ShaftRes);
            totalRes(j,1)=total_Shaft(j)+TipRes(j);
            
            if Weight<totalRes(j,1)
               % Disp(['self penetration until depth of', num2str(Z_D(j))])  
                DepthSWP=Z_D(j);
                IdxSWP=j; %FKMV mod
                break
            end    
       end     
 end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [PileWeight]=calcPileWeight(Pile_Data)
        
         for ii=1:size(Pile_Data,1)-1
             
             deltaL=Pile_Data(ii+1,1)-Pile_Data(ii,1);  
             DeltaWt(ii)=deltaL*(Pile_Data(ii,2)/(100^2))*Pile_Data(ii,4);             
         end          
         PileWeight=sum(DeltaWt);
    end 
end 