function Blowcount(Settings,Figurename,PlotOpt,i,GE_SRD,GE_Data,loc)
%% Notice  
DontSave = 0;
if any(Settings.ISNoiseMit(:)==1)
    NoisemittigIdx = find(Settings.ISNoiseMit(:)==1); 
    if ~all((any(PlotOpt.(Figurename).Analysis(:)==NoisemittigIdx))==0)
        if any(Settings.DIGW(PlotOpt.(Figurename).Analysis(:))==0) 
            disp('The Noise mittigation is on and DIGW is off, therefore, blow count will not be saved')
            DontSave = 1;
        end
    end
end

%% General setting
figure(1)
clf;
set(gcf, 'Units', 'Centimeters', 'PaperPosition', [0, 0, 10, 10], 'PaperUnits', 'Centimeters', 'PaperSize', [10.0, 10.0]);
hold all
XlimEffe = 0;
for AA = 1:size(PlotOpt.(Figurename).Analysis,2)
    hold on 
    AnalysisName    = Settings.SimulLable{PlotOpt.(Figurename).Analysis(AA)};
    SOD             = GE_SRD.(AnalysisName).(loc{i}).SOD;
    Dmatrix         = GE_Data.(AnalysisName).(loc{i}).Dmatrix;
    XlimEffe        = 1.1*max(XlimEffe,max(Dmatrix(:,6)));
    SymbolIn        = PlotOpt.(Figurename).Symbol{AA};
    Symbol          = translateSymbol(SymbolIn);  % translate Symbol to the Matlab Languege 
    txt             = PlotOpt.(Figurename).Legends{AA};
    
    %% Blow Count
    subplot(1,2,1)
    plot(SOD(:,5),SOD(:,1),'linestyle',Symbol,'color','b','DisplayName',txt);
    hold on
    if max(SOD(:,5))>1500
        xlim([0 1500])
    end

    if contains(AnalysisName,'PileRun')
       xlim([0 400]) 

    end
    ylim([0 ceil(max(SOD(:,1)))])
    ylabel('Penetration depth below mudline [m]', 'FontSize',8.5)
    xlabel('Blow count, [bl/m]','FontSize',9)
    ax = gca; 
    set(ax,'YDir','reverse')
    legend show
    h = legend;  
    set(h,'Fontsize', 6.5, 'Location','northoutside');
    grid on

    %% Hammer Effiency
    subplot(1,2,2)   
    plot(Dmatrix(:,6),Dmatrix(:,1),'linestyle',Symbol,'color','r','DisplayName',txt);
    ylabel('Penetration depth below mudline [m]', 'FontSize',8.5)
    xlabel('Applied hammer energy, [%]','FontSize',9)
    xlim([0 XlimEffe])
    ylim([0 ceil(max(Dmatrix(:,1)))])
    ax = gca; 
    set(ax,'YDir','reverse')
    legend show
    h=legend;  
    set(h,'Fontsize', 6.5, 'Location','northoutside');
    grid on        
end 
hold off

%% Save the figure
if DontSave == 0   
    file = strcat(pwd,'\Plots\',loc{i},'_',Figurename);
    print(gcf,file,'-dpng','-r300')
end 
close gcf
end 
