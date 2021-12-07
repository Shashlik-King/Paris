function DatabaseRev=FatigueDBopt(Settings)

Revname=Settings.DBFatDam(any(cellfun(@(x)any(~isnan(x)),Settings.DBFatDam(:,5)),2),:);

DatabaseRev.Revname=Revname;


for i =1: size(Revname,1)
    
    rev_number=cell2mat(Revname(i,4));
    rev_sub=cell2mat(Revname(i,5));
    hammer_conf=cell2mat(Revname(i,6));
    AnalysisBlow=cell2mat(Revname(i,7));  
    AnalysisForce=cell2mat(Revname(i,8));     
    Switch=Revname(i,1);
    
    
% % % % %     
% % % % %     idx=find(~isnan(Analysis));
% % % % %     
% % % % %     Legends=Revname(i,12:18);
% % % % %     
% % % % %     Symbol=Revname(i,19:25);
% % % % %     
% % % % %     PlotType=Revname(i,4);    

    
    
    DatabaseRev.(Revname{i,3}).RNumber=rev_number;
    
    DatabaseRev.(Revname{i,3}).rev_sub=rev_sub;    
    
    DatabaseRev.(Revname{i,3}).Hammer_Conf=hammer_conf;    
    
    DatabaseRev.(Revname{i,3}).AnalysisBlow=AnalysisBlow; 
    
    DatabaseRev.(Revname{i,3}).AnalysisForce=AnalysisForce; 

    DatabaseRev.(Revname{i,3}).Switch=Switch;
    
    
end 




end 