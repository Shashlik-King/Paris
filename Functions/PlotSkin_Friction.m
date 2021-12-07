function PlotSkin_Friction(SRD,Data,loc,locLoop)
        
start=24

endplot=Data.(loc{locLoop}).NoSteps;
endplot=40


        figure(2)
        hold all
        plot(SRD.(loc{locLoop}).Soil.fsi,SRD.(loc{locLoop}).Soil.z,'DisplayName','Initial')
        plot(SRD.(loc{locLoop}).Soil.fsres,SRD.(loc{locLoop}).Soil.z,'DisplayName','Residual')
        for AA=start:endplot
            
            SRD.(loc{locLoop}).IndexS(AA) = sum(SRD.(loc{locLoop,1}).Soil.z_D(AA)>=SRD.(loc{locLoop,1}).Soil.z); % Define index for soil properties
            plot(SRD.(loc{locLoop}).Soil.fs(AA,1:SRD.(loc{locLoop}).IndexS(AA)),SRD.(loc{locLoop}).Soil.z(1:SRD.(loc{locLoop}).IndexS(AA)),'DisplayName',strcat(num2str(SRD.(loc{locLoop}).Soil.z(SRD.(loc{locLoop}).IndexS(AA))),'m'))
        end
        ylabel('Depth below seabed [m]')
        xlabel('Unit skin friction [kPa]')
%         if Settings.PlotTitle
%             title(strcat({'Unit tip resistance, '},(loc{locLoop})));
%         end
        set(gca,'YDir','reverse')
        legend('-DynamicLegend')
        grid on
        hold off
        file=strcat(Settings.Analysis{A.CALC},'/Plots/',(loc{locLoop}),'_2_Unit_skin_friction');
        print(gcf,file,'-dpng','-r300')
        close gcf
end 