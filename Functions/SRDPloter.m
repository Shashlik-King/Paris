function SRDPloter(Settings,Figurename,PlotOpt,i,GE_SRD,loc)

    figure(3)
    
            clf;
             plot_font_size = 10;
             
             set(gcf, 'Units', 'Centimeters', 'PaperPosition', [0, 0, 10, 10], 'PaperUnits', 'Centimeters', 'PaperSize', [10.0, 10.0]);
                subplot(1,2,1)   % Friction  
    
             hold all
        
                for AA=1:size(PlotOpt.(Figurename).Analysis,2)
                    hold on
                    AnalysisName=Settings.SimulLable{PlotOpt.(Figurename).Analysis(AA)};
                    SOD=GE_SRD.(AnalysisName).(loc{i}).SOD;
                    
                    SymbolIn=PlotOpt.(Figurename).Symbol{AA};
                    Symbol=translateSymbol(SymbolIn);  % translate Symbol to the Matlab Languege 
                    txt=PlotOpt.(Figurename).Legends{AA};
                    
                    plot(SOD(:,3),SOD(:,1),'linestyle',Symbol,'color','b','DisplayName',txt);
                    
                    hold on

                end  

                     xlabel('Friction [MN]','FontSize',8.5)
                     ylabel('Penetration depth below mudline [m]','FontSize',9);
                      ax = gca; 
                      set(ax,'YDir','reverse')

                 %     legend show  
                      grid on
                  %    h=legend;  
                   %    set(h,'Fontsize', 8.5, 'Location','northoutside');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    subplot(1,2,2)          % Tip Resistance 

                     hold all
        
                for AA=1:size(PlotOpt.(Figurename).Analysis,2)
                    hold on
                    AnalysisName=Settings.SimulLable{PlotOpt.(Figurename).Analysis(AA)};
                    SOD=GE_SRD.(AnalysisName).(loc{i}).SOD;
                    
                    SymbolIn=PlotOpt.(Figurename).Symbol{AA};
                    Symbol=translateSymbol(SymbolIn);  % translate Symbol to the Matlab Languege 
                    
                    txt=PlotOpt.(Figurename).Legends{AA};
                    
                    plot(SOD(:,4),SOD(:,1),'linestyle',Symbol,'color','b','DisplayName',txt);
                    
                    hold on
                end  
                
                xlabel('End Bearing [MN]','FontSize',8.5)
                ylabel('Penetration depth below mudline [m]','FontSize',9);
                ax = gca;
                set(ax,'YDir','reverse')
                %legend show
                
                %h2=legend;
                %set(h2,'Fontsize', 8.5, 'Location','northoutside');
                grid on
                hold off     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                file=strcat(pwd,'\Plots\',loc{i},'_',Figurename);
                print(gcf,file,'-dpng', '-r300');
                

     