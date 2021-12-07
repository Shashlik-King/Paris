function [] = GWOplot(Data,SRD,Settings,A,SRD_UB)
% Plot of Output
% MTHG 20-12-2019
if nargin ==4 || nargin==5
    loc = Data.loc;
    h=waitbar(0,'Plotting results');
    for i=1:size(loc,1)
        
        
        
        
        
        %% Plot SRD
        figure(1)
        hold all
        set(gcf,'position',[10,10,600,750])
        plotfric = subplot(1,2,1);
        plot(plotfric,SRD.(loc{i}).SOD(:,3),SRD.(loc{i}).SOD(:,1),'k')
        hold all
        if Settings.UB(A.Analysis)
            plot(plotfric,SRD_UB.(loc{i}).SOD(:,3),SRD_UB.(loc{i}).SOD(:,1),'r')
        end
        set(gca, 'YDir','reverse')
        ylabel('Depth below seabed [m]')
        xlabel('SRD, skin friction, [MN]')
        grid(plotfric,'on')
        plottip = subplot(1,2,2);
        plot(plottip,SRD.(loc{i}).SOD(:,4),SRD.(loc{i}).SOD(:,1),'k')
        hold all
        if Settings.UB(A.Analysis)
            plot(plottip,SRD_UB.(loc{i}).SOD(:,4),SRD.(loc{i}).SOD(:,1),'r')
        end
        set(gca, 'YDir','reverse')
        xlabel('SRD, end bearing, [MN]')
        grid(plottip,'on')
        if Settings.PlotTitle
            P = mtit(['Soil Resistance to Driving, ',(loc{i})]);
        end
        file=strcat(Settings.Analysis{A.CALC},'/Plots/',(loc{i}),'_4_SRD');
        print(gcf,file,'-dpng','-r300')
        close gcf
        
        %% Plot Blow count
        figure(1)
        hold all
        plot(SRD.(loc{i}).SOD(:,5),SRD.(loc{i}).SOD(:,1),'k')
        if Settings.UB(A.Analysis)
            plot(SRD_UB.(loc{i}).SOD(:,5),SRD_UB.(loc{i}).SOD(:,1),'r')
            legend('BE','UB','location','Northeast')
        end
        if Settings.BackCalc(A.Analysis)
            %%% Pooyan too add plot settings for back caluclation results
            % att the plot put in the driving log
        end
        if max(SRD.(loc{i}).SOD(:,5))>1500
            xlim([0 1500])
        end
        ylabel('Penetration below seabed [m]')
        xlabel('Blow count, [bl/m]')
        if Settings.PlotTitle
            title(strcat({'Blow count, '},(loc{i})));
        end
        set(gca,'YDir','reverse')
        grid on
        hold off
        file=strcat(Settings.Analysis{A.CALC},'/Plots/',(loc{i}),'_5_Blow_count');
        print(gcf,file,'-dpng','-r300')
        close gcf
        
        %% Plot Acc. Blow count
        figure(1)
        hold all
        plot(cumsum(SRD.(loc{i}).SOD(:,10)),SRD.(loc{i}).SOD(:,1),'k')
        if Settings.UB(A.Analysis)
            plot(cumsum(SRD_UB.(loc{i}).SOD(:,10)),SRD_UB.(loc{i}).SOD(:,1),'r')
            legend('BE','UB','location','Northeast')
        end
        ylabel('Penetration below seabed [m]')
        xlabel('Accumulated blow count, [bl]')
        if Settings.PlotTitle
            title(strcat({'Accumulated blow count, '},(loc{i})));
        end
        set(gca,'YDir','reverse')
        grid on
        hold off
        file=strcat(Settings.Analysis{A.CALC},'/Plots/',(loc{i}),'_6_Acc_Blow_count');
        print(gcf,file,'-dpng','-r300')
        close gcf
        
        %% Plot stresses
        figure(1)
        hold all
        arrayfun(@(j) plot(SRD.(loc{i}).TStress(:,j),SRD.(loc{i}).GWOx),1:size(SRD.(loc{i}).TStress,2));
        arrayfun(@(j) plot(SRD.(loc{i}).CStress(:,j),SRD.(loc{i}).GWOx),1:size(SRD.(loc{i}).CStress,2));
        ylabel('Distance from pile head [m]')
        xlabel('Pile stresses [MPa]')
        if Settings.PlotTitle
            title(['Calculated pile stresses,  ',(loc{i})])
        end
        set(gca,'YDir','reverse')
        grid on
        hold off
        file=strcat(Settings.Analysis{A.CALC},'/Plots/',(loc{i}),'_7_Pile_stresses');
        print(gcf, file,'-dpng','-r300')
        close gcf
        
        if Settings.UB(A.Analysis)
            figure(1)
            hold all
            arrayfun(@(j) plot(SRD_UB.(loc{i}).TStress(:,j),SRD_UB.(loc{i}).GWOx),1:size(SRD_UB.(loc{i}).TStress,2));
            arrayfun(@(j) plot(SRD_UB.(loc{i}).CStress(:,j),SRD_UB.(loc{i}).GWOx),1:size(SRD_UB.(loc{i}).CStress,2));
            ylabel('Distance from pile head [m]')
            xlabel('Pile stresses [MPa]')
            if Settings.PlotTitle
                title(['Calculated pile stresses,  ',(loc{i})])
            end
            set(gca,'YDir','reverse')
            grid on
            hold off
            file=strcat(Settings.Analysis{A.CALC},'/Plots/',(loc{i}),'_7_Pile_stresses_UB');
            print(gcf, file,'-dpng','-r300')
            close gcf
        end
        
        %% Plot fatigue
        figure(1)
        ymax=SRD.(loc{i}).Pile(end,2);
        set(gcf,'position',[0,0,700,600]);
        plotSCF=axes('Position',[0.07,0.1,0.20,0.80]);
        scatter(SRD.(loc{i}).SCF(:,2),SRD.(loc{i}).SCF(:,1),4,'filled');
        ylabel('Distance from pile top [m]');
        set(gca, 'YDir','reverse')
        xlabel('SCF');
        ylim([0 ymax]);
        xlim([0 ceil(max(SRD.(loc{i}).SCF(:,2))*2)/2])
        grid(plotSCF,'on');
        plotwt = axes('Position',[0.3,0.1,0.20,0.80]);
        scatter(SRD.(loc{i}).SCF(:,4)*1000,SRD.(loc{i}).SCF(:,1),4);
        set(gca, 'YDir','reverse')
        xlabel('Pile wall thickness, [mm]')
        ylim([0 ymax]);
        if abs(floor(min(SRD.(loc{i}).SCF(:,4))*1000/10)*10-ceil(max(SRD.(loc{i}).SCF(:,4))*1000/10)*10) < 0.000001
            xlim([floor(min(SRD.(loc{i}).SCF(:,4))*1000/10)*10-5 floor(min(SRD.(loc{i}).SCF(:,4))*1000/10)*10+5])
        else
            xlim([floor(min(SRD.(loc{i}).SCF(:,4))*1000/10)*10 ceil(max(SRD.(loc{i}).SCF(:,4)*1000/10))*10])
        end
        grid(plotwt,'on')
        plotu = axes('Position',[0.54,0.1,0.4,0.80]);
        hold all
        scatter(SRD.(loc{i}).D*100,SRD.(loc{i}).SCF(:,1),4,'filled','k');
        plot(SRD.(loc{i}).D*100,SRD.(loc{i}).SCF(:,1),'k');
        if Settings.UB(A.Analysis)
            scatter(SRD_UB.(loc{i}).D*100,SRD_UB.(loc{i}).SCF(:,1),4,'filled','r');
            plot(SRD_UB.(loc{i}).D*100,SRD_UB.(loc{i}).SCF(:,1),'r');
        end
        ylim([0 ymax]);
        set(gca, 'YDir','reverse')
        xlabel('Fatigue utilization, [%]')
        grid(plotu,'on')
        tit=strcat({'Driving induced fatigue, '},(loc{i}),{', DFF='},num2str(Settings.DFF(A.Analysis)),{', max fatigue: '},sprintf('%.2f',max(SRD.(loc{i}).D)),{'.'});
        if Settings.PlotTitle
            mtit(tit{1})
        end
        file=strcat(Settings.Analysis{A.CALC},'/Plots/',(loc{i}),'_8_Fatigue');
        print(gcf,file,'-dpng','-r300')
        close gcf
        waitbar(i/size(loc,1),h);
        
    end
    close(h)
end

