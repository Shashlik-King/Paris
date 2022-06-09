function [] = GeneralGWOplot(GE_Data,GE_SRD,Settings,A,PlotOpt,loc,locLoop)
% Plot of Output
% MTHG 20-12-2019
if nargin ==6 || nargin==7
    disp([ ' Plotting the figures for Location ' , loc{locLoop,1} ])
    h=waitbar(0,'Plotting results');
    disp(['Plotting the figures for Location  ', loc{locLoop,1}])
    
    for figNum=1:size(PlotOpt.Plotname(:,1),1)
        
        Figurename=PlotOpt.Plotname{figNum,3};
        
        FigureType=PlotOpt.(Figurename).PlotType;
        
        Switch=PlotOpt.(Figurename).Switch;    %% Switch to whether plotting or not
        
        if strcmp(FigureType,'Blow Count')  &&  Switch == 1
            Blowcount(Settings,Figurename,PlotOpt,locLoop,GE_SRD,GE_Data,loc);
            
        elseif strcmp(FigureType,'Stress') &&  Switch == 1
            StressPlot(Settings,Figurename,PlotOpt,locLoop,GE_SRD,loc);
            
        elseif strcmp(FigureType,'SRD')  &&  Switch == 1
            SRDPloter(Settings,Figurename,PlotOpt,locLoop,GE_SRD,loc)
            
        elseif strcmp(FigureType,'Fatigue') &&  Switch == 1
            FatiguePlot(Settings,Figurename,PlotOpt,locLoop,GE_SRD,loc)
  
        elseif strcmp(FigureType,'CPT') &&  Switch == 1
            CPTPlot(GE_Data,GE_SRD,Figurename,Settings,A,PlotOpt,locLoop,loc)
            
        end
    end
    disp('---------------------------------------------------')
    waitbar(locLoop/size(loc,1),h);
    close(h)
end
end

