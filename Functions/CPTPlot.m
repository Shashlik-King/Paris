function CPTPlot(GE_Data,GE_SRD,Figurename,Settings,A,PlotOpt,locLoop,loc)
        
i=locLoop;

figure(1)
        
        
 for AA=1:size(PlotOpt.(Figurename).Analysis,2)
    hold on
    AnalysisName=Settings.SimulLable{PlotOpt.(Figurename).Analysis(AA)};
    SRD=GE_SRD.(AnalysisName);
    Data=GE_Data.(AnalysisName);

    SymbolIn=PlotOpt.(Figurename).Symbol{AA};
    Symbol=translateSymbol(SymbolIn);  % translate Symbol to the Matlab Languege 
    txt=PlotOpt.(Figurename).Legends{AA};
                    
%                     plot(SOD(:,3),SOD(:,1),'linestyle',Symbol,'color','b','DisplayName',txt);
%                     
%                     hold on



        ymax=max(SRD.(loc{i}).Soil.z);
%         set(gcf,'position',[0,0,700,950]);
%         %   title(['CPT data for ',Position]);
%         plotST=axes('Position',[0.07,0.1,0.13,0.80]);
%         plot(plotST,SRD.(loc{i}).Soil.CPT(:,3),SRD.(loc{i}).Soil.z,'color','r','DisplayName','Applied qc');
%         
%         ylabel('Depth below seabed [m]');
%         set(gca, 'YDir','reverse')
%         xlabel('Soil type');
%         xlim([0.5 2.5]);
%         ylim([0 ymax]);
%         SoilTypes={'Coarse' 'Fine' ' '};
%         x=linspace(1,3,3);
%         set(plotST,'xtick',x,'xticklabel',SoilTypes)
%         grid(plotST,'off');
        subplot(1,2,1)   % Tensile Stress
%         plotqc = axes('Position',[0.24,0.1,0.35,0.80]);
        hold on
        %if Settings.CPTData(A.Analysis)
        scatter(cell2mat(Data.(loc{i}).CPTData(:,2)),cell2mat(Data.(loc{i}).CPTData(:,1)),2,'filled','DisplayName','CPT')
        %end
        plot(SRD.(loc{i}).Soil.CPT(:,1)/1000,SRD.(loc{i}).Soil.z,'color','r','DisplayName','Applied qc')
        hold off
        set(gca, 'YDir','reverse')
        xlabel('Cone tip resistance, qc [MPa]')
        ylim([0 ymax]);
        grid('on')
        legend('-DynamicLegend')
        
        
        subplot(1,2,2)
        %plotfs = axes('Position',[0.63,0.1,0.35,0.80]);
        hold on
        %if Settings.CPTData(A.Analysis)==1
         scatter(cell2mat(Data.(loc{i}).CPTData(:,3)),cell2mat(Data.(loc{i}).CPTData(:,1)),2,'filled','DisplayName','CPT')
        %end
        plot(SRD.(loc{i}).Soil.CPT(:,2)/1000,SRD.(loc{i}).Soil.z,'color','r','DisplayName','Applied fs')
        xlim([0 2])
        ylim([0 ymax]);
        hold off
        set(gca, 'YDir','reverse')
        xlabel('Sleeve Friction, fs [MPa]')
        grid('on')
        legend('-DynamicLegend')
        tit=strcat({'CPT data, '},(loc{i}));
        if Settings.PlotTitle
            mtit(tit{1})
        end
        file=strcat(pwd,'\Plots\',loc{i},'_',Figurename);
        print(gcf,file,'-dpng','-r300')
        
        close gcf
        
end
end 