function StressPlot(Settings,Figurename,PlotOpt,i,GE_SRD,loc)
%% Genaral settings
figure(3)
clf;
% plot_font_size = 10;
set(gcf, 'Units', 'Centimeters', 'PaperPosition', [0, 0, 10, 10], 'PaperUnits', 'Centimeters', 'PaperSize', [10.0, 10.0]);
%% Tensile Stress  
subplot(1,2,2)   
hold all
for AA = 1:size(PlotOpt.(Figurename).Analysis,2)
    hold on
    AnalysisName    = Settings.SimulLable{PlotOpt.(Figurename).Analysis(AA)};
    SRD             = GE_SRD.(AnalysisName);
    SymbolIn        = PlotOpt.(Figurename).Symbol{AA};
    Symbol          = translateSymbol(SymbolIn);  % translate Symbol to the Matlab Languege 
    MCompress       = arrayfun(@(jjj) max(SRD.(loc{i}).mxC(jjj,:)),1:size(SRD.(loc{i}).mxC,1));
    txt             = PlotOpt.(Figurename).Legends{AA};
    plot(MCompress,SRD.(loc{i}).GWOx,'linestyle',Symbol,'color','b','DisplayName',txt);
    hold on
end  
xlabel('Max pile compression force [MN]','FontSize',8.5)
ylabel('Depth below pile head [m]','FontSize',9);
ax = gca; 
set(ax,'YDir','reverse')
legend show  
h = legend;  
set(h,'Fontsize', 6.5, 'Location','northoutside');
grid on

%% Compresion Stress 
subplot(1,2,1)          
hold all
for AA = 1:size(PlotOpt.(Figurename).Analysis,2)
    hold on
    AnalysisName    = Settings.SimulLable{PlotOpt.(Figurename).Analysis(AA)};
    SRD             = GE_SRD.(AnalysisName);
    SymbolIn        = PlotOpt.(Figurename).Symbol{AA};
    Symbol          = translateSymbol(SymbolIn);  % translate Symbol to the Matlab Languege 
    txt             = PlotOpt.(Figurename).Legends{AA};
    MTenstion       = arrayfun(@(jjj) min(SRD.(loc{i}).mxT(jjj,:)),1:size(SRD.(loc{i}).mxT,1));
    plot(MTenstion,SRD.(loc{i}).GWOx,'linestyle',Symbol,'color','r','DisplayName',txt);                    
    hold on
end           
xlabel('Min pile tension force [MN]','FontSize',8.5)
ylabel('Depth below pile head [m]','FontSize',9);
ax = gca;
set(ax,'YDir','reverse')
legend show            
h2 = legend;
set(h2,'Fontsize', 6.5, 'Location','northoutside');
grid on
hold off     
%% Save
file = strcat(pwd,'\Plots\',loc{i},'_',Figurename);
print(figure(3),'-dpng',file, '-r300');
end 