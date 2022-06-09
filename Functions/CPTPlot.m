function CPTPlot(GE_Data,GE_SRD,Figurename,Settings,~,PlotOpt,locLoop,loc)
        
i = locLoop;
figure(1)
             
 for AA = 1:size(PlotOpt.(Figurename).Analysis,2)
    hold on
    AnalysisName    = Settings.SimulLable{PlotOpt.(Figurename).Analysis(AA)};
    SRD             = GE_SRD.(AnalysisName);
    Data            = GE_Data.(AnalysisName);
%     SymbolIn        = PlotOpt.(Figurename).Symbol{AA};
%     Symbol          = translateSymbol(SymbolIn);  % translate Symbol to the Matlab Languege 
%     txt             = PlotOpt.(Figurename).Legends{AA};
    ymax            = max(SRD.(loc{i}).Soil.z);
    
    subplot(1,4,1)   % plot qc
    hold on
    scatter(cell2mat(Data.(loc{i}).CPTData.tip(:,2)),cell2mat(Data.(loc{i}).CPTData.tip(:,1)),2,'filled','DisplayName','CPT')
    plot(SRD.(loc{i}).Soil.CPT.tip(:,1)/1000,SRD.(loc{i}).Soil.z,'color','r','DisplayName','Applied qc')
    hold off
    set(gca, 'YDir','reverse')
    xlabel('Cone tip resistance, qc [MPa]')
    ylim([0 ymax]);
    grid('on')
    legend('-DynamicLegend')
        
    subplot(1,4,2) % plot fs
    hold on
    scatter(cell2mat(Data.(loc{i}).CPTData.shaft(:,3)),cell2mat(Data.(loc{i}).CPTData.shaft(:,1)),2,'filled','DisplayName','CPT')
    plot(SRD.(loc{i}).Soil.CPT.shaft(:,2)/1000,SRD.(loc{i}).Soil.z,'color','r','DisplayName','Applied fs')
    xlim([0 2])
    ylim([0 ymax]);
    hold off
    set(gca, 'YDir','reverse')
    xlabel('Sleeve Friction, fs [MPa]')
    grid('on')
    legend('-DynamicLegend')
    
    subplot(1,4,3) % plot Rf
    hold on
    scatter(cell2mat(Data.(loc{i}).CPTData.shaft(:,3))./cell2mat(Data.(loc{i}).CPTData.shaft(:,2))*100,cell2mat(Data.(loc{i}).CPTData.shaft(:,1)),2,'filled','DisplayName','CPT')
    plot(SRD.(loc{i}).Soil.CPT.shaft(:,4),SRD.(loc{i}).Soil.z,'color','r','DisplayName','Applied Rf')
    xlim([0 8])
    ylim([0 ymax]);
    hold off
    set(gca, 'YDir','reverse')
    xlabel('Friction ratio, Rf [-]')
    grid('on')
    legend('-DynamicLegend')
    
    subplot(1,4,4) % plot u2
    hold on
    scatter(cell2mat(Data.(loc{i}).CPTData.shaft(:,4)),cell2mat(Data.(loc{i}).CPTData.shaft(:,1)),2,'filled','DisplayName','CPT')
    plot(SRD.(loc{i}).Soil.z*9.81/1000,SRD.(loc{i}).Soil.z,'color','b','DisplayName','Hydrostatic pressure')
    plot(SRD.(loc{i}).Soil.CPT.shaft(:,5)/1000,SRD.(loc{i}).Soil.z,'color','r','DisplayName','Applied u2')
    xlim([0 max(SRD.(loc{i}).Soil.CPT.shaft(:,5)/1000)*1.1])
    ylim([0 ymax]);
    hold off
    set(gca, 'YDir','reverse')
    xlabel('Pore pressure, u2 [MPa]')
    grid('on')
    legend('-DynamicLegend')
    
    tit = strcat({'CPT data, '},(loc{i}));
    if Settings.PlotTitle
        mtit(tit{1})
    end
    file = strcat(pwd,'\Plots\',loc{i},'_',Figurename);
    print(gcf,file,'-dpng','-r300')
    close gcf
        
end
end 