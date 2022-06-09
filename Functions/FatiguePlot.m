function FatiguePlot(Settings,Figurename,PlotOpt,i,GE_SRD,loc)

figure(1)
%% General settings
hold all
        
for AA=1:size(PlotOpt.(Figurename).Analysis,2)
    hold on 
    AnalysisName    = Settings.SimulLable{PlotOpt.(Figurename).Analysis(AA)};
    D               = GE_SRD.(AnalysisName).(loc{i}).D';
    SCF             = GE_SRD.(AnalysisName).(loc{i}).SCF;
    SymbolIn        = PlotOpt.(Figurename).Symbol{AA};
    Symbol          = translateSymbol(SymbolIn);  % translate Symbol to the Matlab Languege 
    txt             = PlotOpt.(Figurename).Legends{AA};
    %% Plotting
    plot(D*100,SCF(:,1),'linestyle',Symbol,'color','b','DisplayName',txt);
    hold on
end     
ylabel('Depth below pile head [m]')
xlabel('Fatigue Damage, [%]')
if Settings.PlotTitle
    title(strcat({'Fatigue Damage, '},loc{i}));
end
legend show
set(gca,'YDir','reverse')
grid on
hold off
%% Save
file = strcat(pwd,'\Plots\',loc{i},'_',Figurename);
print(gcf,file,'-dpng','-r300')
close gcf       
end 
