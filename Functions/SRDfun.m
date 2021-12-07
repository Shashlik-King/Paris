function [SRD] = SRDfun(Data,SRD,Settings,A,loc,locLoop)
%% This funtion organises SRD calculation and generation of pile input to GRLWeap and stores data in SRD object
%   MTHG 03-12-2019

disp(['Creating the SRD for Analysis:  ',A.SimulationLable , ' For Location ' , loc{locLoop,1} ]) 
%SRD.dummy = 1;
 
SRD=Pile(Data,Settings,SRD,A,loc{locLoop,1});

%SRD = rmfield(SRD,'dummy');

SRD=AlmHamre(Data,Settings,A,loc(locLoop,:),SRD);   % PNGI i is replaced by locLoop

disp('----------------------------------------------------------------------------') 
end

