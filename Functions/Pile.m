function [SRD] = Pile(Data,Settings,SRD,A,loc)
%% Function generates pile input for GRLWeap DIGW
% MTHG 03-12-2019

    Atop=pi/4*100^2*((cell2mat(Data.(loc).PileGeometry(:,1))).^2-(cell2mat(Data.(loc).PileGeometry(:,1))-2*cell2mat(Data.(loc).PileGeometry(:,3))).^2);
    Abottom=pi/4*100^2*((cell2mat(Data.(loc).PileGeometry(:,2))).^2-(cell2mat(Data.(loc).PileGeometry(:,2))-2*cell2mat(Data.(loc).PileGeometry(:,3))).^2);
    Ptop=pi*(2*cell2mat(Data.(loc).PileGeometry(:,1))-2*cell2mat(Data.(loc).PileGeometry(:,3)));
    Pbottom=pi*(2*cell2mat(Data.(loc).PileGeometry(:,2))-2*cell2mat(Data.(loc).PileGeometry(:,3)));
    
    SRD.(loc).out_daim=cell2mat(Data.(loc).PileGeometry(:,1));
    
    R_outer_2_top=(cell2mat(Data.(loc).PileGeometry(:,1))/2).^2;
    R_inner_2_top=(cell2mat(Data.(loc).PileGeometry(:,1))/2-cell2mat(Data.(loc).PileGeometry(:,3))).^2;
    
    R_outer_2_bot=(cell2mat(Data.(loc).PileGeometry(:,2))/2).^2;
    R_inner_2_bot=(cell2mat(Data.(loc).PileGeometry(:,2))/2-cell2mat(Data.(loc).PileGeometry(:,3))).^2;
    
   SRD.(loc).tw= cell2mat(Data.(loc).PileGeometry(:,3));    
   SRD.(loc).Eqau_Redius_top=(R_outer_2_top-R_inner_2_top).^0.5;    
   SRD.(loc).Eqau_Redius_bot=(R_outer_2_bot-R_inner_2_bot).^0.5;
    
    z=cumsum(cell2mat(Data.(loc).PileGeometry(:,4)));
    Temp(1,:)=[0 Atop(1) Settings.ESteel(A.Model) Settings.GSteel(A.Model) Ptop(1) 0.000];
    Temp(2,:)=[z(1) Abottom(1) Settings.ESteel(A.Model) Settings.GSteel(A.Model) Pbottom(1) 0.000];
    for i = 1:size(z)-1
        Temp(2*i+1,:)=[z(i) Atop(i+1) Settings.ESteel(A.Model) Settings.GSteel(A.Model) Ptop(i+1) 0.000];
        Temp(2*i+2,:)=[z(i+1) Abottom(i+1) Settings.ESteel(A.Model) Settings.GSteel(A.Model) Pbottom(i+1) 0.000];
    end
    SRD.(loc).gwtPile=Temp;
    
    SRD.(loc).Depth_pile_can=z;
    
    NumSement=Settings.PileSeg(A.Model);
    PointOutput= cell2mat(Data.(loc).Selected_Points(:,2));
    lengthSegment=z(end)/NumSement;
    
    SegmentsVector=[0: lengthSegment: z(end)];
    
    PointSegment=[NumSement-12:1:NumSement]; 
    
    if strcmp(Settings.OutPutStyle{A.Analysis},'Acceleration') || strcmp(Settings.OutPutStyle{A.Analysis},'Force') || strcmp(Settings.OutPutStyle{A.Analysis},'Displacement') || strcmp(Settings.OutPutStyle{A.Analysis},'Velocity') || strcmp(Settings.OutPutStyle{A.Analysis},'Stress')
    
    for i =1:length(PointOutput)
        
        for j=2:length(SegmentsVector);
    
            if SegmentsVector(j-1)<PointOutput(i) &&  PointOutput(i) <=SegmentsVector(j)   
                
              PointSegment_temp(i)=  j-1;
              break
            end 
        end  
    end 
    
    PointSegment_temp2=unique(PointSegment_temp);
    for i=1:length(PointSegment_temp2)
    PointSegment(i)=PointSegment_temp2(i);
    end 
    
    SRD.(loc).outputSegment=PointSegment';
    SRD.(loc).PointSegment_temp=PointSegment_temp';    
    end 
    
end