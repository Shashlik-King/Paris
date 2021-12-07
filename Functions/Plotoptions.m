function plot=Plotoptions(Settings)

Plotname=Settings.Plots(any(cellfun(@(x)any(~isnan(x)),Settings.Plots(:,5)),2),:);

plot.Plotname=Plotname;


for i =1: size(Plotname,1)
    
    Analysis=cell2mat(Plotname(i,5:11));
    
    idx=find(~isnan(Analysis));
    
    Legends=Plotname(i,12:18);
    
    Symbol=Plotname(i,19:25);
    
    PlotType=Plotname(i,4);    
    Switch=Plotname(i,1);
    
    
    plot.(Plotname{i,3}).Analysis(1,idx)=Analysis(1,idx);
    
    plot.(Plotname{i,3}).Legends(1,idx)=Legends(1,idx);    
    
    plot.(Plotname{i,3}).PlotType=PlotType;    
    
    plot.(Plotname{i,3}).Symbol=Symbol; 
    
    plot.(Plotname{i,3}).Switch=cell2mat(Switch); 

end 




end 