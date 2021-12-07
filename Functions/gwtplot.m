function [] = gwtplot(Data,SRD,Settings,A,SRD_UB)
% Plot of input parameters
% MTHG 04-12-2019

if nargin ==4 || nargin==5
    loc = Data.loc;
    h=waitbar(0,'Plotting analysis input');
    for i=1:size(loc,1)
        %% Soil input
        figure(1)
        ymax=max(SRD.(loc{i}).Soil.z);
        set(gcf,'position',[0,0,700,950]);
        %   title(['CPT data for ',Position]);
        plotST=axes('Position',[0.07,0.1,0.13,0.80]);
        plot(plotST,SRD.(loc{i}).Soil.CPT(:,3),SRD.(loc{i}).Soil.z,'color','r','DisplayName','Applied qc');
        
        ylabel('Depth below seabed [m]');
        set(gca, 'YDir','reverse')
        xlabel('Soil type');
        xlim([0.5 2.5]);
        ylim([0 ymax]);
        SoilTypes={'Coarse' 'Fine' ' '};
        x=linspace(1,3,3);
        set(plotST,'xtick',x,'xticklabel',SoilTypes)
        grid(plotST,'off');
        
        plotqc = axes('Position',[0.24,0.1,0.35,0.80]);
        hold on
        if Settings.CPTData(A.Analysis)
            scatter(cell2mat(Data.(loc{i}).CPTData(:,2)),cell2mat(Data.(loc{i}).CPTData(:,1)),2,'filled','DisplayName','CPT')
        end
        plot(plotqc,SRD.(loc{i}).Soil.CPT(:,1)/1000,SRD.(loc{i}).Soil.z,'color','r','DisplayName','Applied qc')
        hold off
        set(gca, 'YDir','reverse')
        xlabel('Cone tip resistance, qc [MPa]')
        ylim([0 ymax]);
        grid(plotqc,'on')
        legend('-DynamicLegend')
        
        plotfs = axes('Position',[0.63,0.1,0.35,0.80]);
        hold on
        if Settings.CPTData(A.Analysis)==1
            scatter(cell2mat(Data.(loc{i}).CPTData(:,3)),cell2mat(Data.(loc{i}).CPTData(:,1)),2,'filled','DisplayName','CPT')
        end
        plot(plotfs,SRD.(loc{i}).Soil.CPT(:,2)/1000,SRD.(loc{i}).Soil.z,'color','r','DisplayName','Applied fs')
        xlim([0 2])
        ylim([0 ymax]);
        hold off
        set(gca, 'YDir','reverse')
        xlabel('Sleeve Friction, fs [MPa]')
        grid(plotfs,'on')
        legend('-DynamicLegend')
        tit=strcat({'CPT data, '},(loc{i}));
        if Settings.PlotTitle
            mtit(tit{1})
        end
        file=strcat(Settings.Analysis{A.CALC},'/Plots/',(loc{i}),'_1_CPT');
        print(gcf,file,'-dpng','-r300')
        close gcf
        
        %% Unit skin friction
        figure(2)
        hold all
        plot(SRD.(loc{i}).Soil.fsi,SRD.(loc{i}).Soil.z,'DisplayName','Initial')
        plot(SRD.(loc{i}).Soil.fsres,SRD.(loc{i}).Soil.z,'DisplayName','Residual')
        for j=1:Data.(loc{i}).NoSteps
            plot(SRD.(loc{i}).Soil.fs(j,1:SRD.(loc{i}).IndexS(j)),SRD.(loc{i}).Soil.z(1:SRD.(loc{i}).IndexS(j)),'DisplayName',strcat(num2str(SRD.(loc{i}).Soil.z(SRD.(loc{i}).IndexS(j))),'m'))
        end
        ylabel('Depth below seabed [m]')
        xlabel('Unit skin friction [kPa]')
        if Settings.PlotTitle
            title(strcat({'Unit tip resistance, '},(loc{i})));
        end
        set(gca,'YDir','reverse')
        legend('-DynamicLegend')
        grid on
        hold off
        file=strcat(Settings.Analysis{A.CALC},'/Plots/',(loc{i}),'_2_Unit_skin_friction');
        print(gcf,file,'-dpng','-r300')
        close gcf
        
        %% Unit end bearing
        figure(3)
        hold all
        plot(SRD.(loc{i}).Soil.qt,SRD.(loc{i}).Soil.z,'color','r')
        ylabel('Depth below seabed [m]')
        xlabel('Unit tip resistance [kPa]')
        if Settings.PlotTitle
            title(strcat({'Unit tip resistance, '},(loc{i})));
        end
        set(gca,'YDir','reverse')
        grid on
        hold off
        file=strcat(Settings.Analysis{A.CALC},'/Plots/',(loc{i}),'_3_Unit_tip_resistance');
        print(gcf,file,'-dpng','-r300')
        close gcf
        waitbar(i/size(loc,1),h);
    end
    close(h)
end

