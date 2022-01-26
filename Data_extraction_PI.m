close all; clear all; % clc

%% Input
% ID = {'EW1_15','EW1_16','EW1_18','EW1_24','EW1_32','EW1_33','EW1_37','EW1_39','EW1_41','EW1_43','EW1_47','EW1_55'};
ID = {'EW1_18','EW1_32','EW1_37','EW1_39','EW1_41','EW1_43','EW1_55'};
% ID = {'EW1_43'};
% Models = {'NORM', 'SAND', 'BORS', 'SHOE', 'NOISE'};
Models = {'NORM', 'SAND', 'BORS', 'BORS3'};
% Analyses = {'NoiseSTR_ACC','Full_UB','Full_BE','PileRun_UB','PileRun_LB','Entrapped_BE','Entrapped_UB','Full_BE','Breakdown_BE'};
Analyses = {'Entrapped_BE','Entrapped_UB'};

path_base = strcat(pwd,'\Output');
cd(path_base)

%% Load all output files
for i= 1:length(Analyses)
    for j = 1:length(ID)
        for ii = 1:length(Models)
            name(i,ii) = strcat(ID(j),'_',Models(ii),'_',Analyses(i));
            OUTPUT_prelim{1,ii} = load(name{i,ii});  
        end
        OUTPUT{j,i} = OUTPUT_prelim;
    end
end

%% Save into excels

% Entrapped_BE_blow_count (Section 6)
for j = 1:length(ID)
        DATA_1 = struct2cell(OUTPUT{j,1}{1,1}); % 7 needs change if order of analyses changes
        DATA_3 = DATA_1{1,1}.DATA.Dmatrix;
        DATA_1 = DATA_1{1,1}.SRD.SOD;
        DATA_2 = struct2cell(OUTPUT{j,1}{1,2}); % 10 needs change if order of analyses changes
        DATA_4 = DATA_2{1,1}.DATA.Dmatrix;
        DATA_2 = DATA_2{1,1}.SRD.SOD;
        DATA_5 = struct2cell(OUTPUT{j,1}{1,3}); % 8 needs change if order of analyses changes
        DATA_6 = DATA_5{1,1}.DATA.Dmatrix;
        DATA_5 = DATA_5{1,1}.SRD.SOD;
        DATA_7 = struct2cell(OUTPUT{j,1}{1,4}); % 8 needs change if order of analyses changes
        DATA_8 = DATA_7{1,1}.DATA.Dmatrix;
        DATA_7 = DATA_7{1,1}.SRD.SOD;
        DATA_FINAL = [DATA_1(:,1), DATA_1(:,5), DATA_2(:,5), DATA_5(:,5), DATA_7(:,5), DATA_3(:,6)*100, DATA_4(:,6)*100, DATA_6(:,6)*100, DATA_8(:,6)*100, DATA_1(:,9), DATA_2(:,9), DATA_5(:,9), DATA_7(:,9)];
        File_name = strcat(ID(j),'.xlsx');
        col_header_ham_breakdown={'Penetration depth','Blowcount_NORM','Blowcount_SAND','Blowcount_BORS','Blowcount_SHOE','Hammer_efficiency_NORM','Hammer_efficiency_SAND','Hammer_efficiency_BORS','Hammer_efficiency_SHOE', 'ENTHRU_NORM', 'ENTHRU_SAND', 'ENTHRU_BORS', 'ENTHRU_SHOE'};
        col_units_ham_breakdown={'[m]','[Blows/m]','[Blows/m]','[Blows/m]','[Blows/m]','[%]','[%]','[%]','[%]','[kJ]','[kJ]','[kJ]'};
        xlswrite(File_name{1}, col_header_ham_breakdown,  'Entrapped BE blow count', 'B1');
        xlswrite(File_name{1}, col_units_ham_breakdown,  'Entrapped BE blow count', 'B2');
        xlswrite(File_name{1}, DATA_FINAL,  'Entrapped BE blow count', 'B3'); 

    figure(1)
    clf;
    plot_font_size = 10;
    set(gcf, 'Units', 'Centimeters', 'PaperPosition', [0, 0, 10, 10], 'PaperUnits', 'Centimeters', 'PaperSize', [10.0, 10.0]);
%     hold all
    
    subplot(1,2,1)   % Blow Count
    plot(DATA_1(:,5),DATA_1(:,1),'linestyle','-','color','b','DisplayName','Option 1');
    hold on 
    plot(DATA_2(:,5),DATA_2(:,1),'linestyle','--','color','b','DisplayName','Option 2');
    plot(DATA_5(:,5),DATA_5(:,1),'linestyle','-.','color','b','DisplayName','Option 3');
    plot(DATA_7(:,5),DATA_7(:,1),'linestyle',':','color','b','DisplayName','Option 4');
    plot([394 394],[0 max(DATA_1(:,1))],'linestyle','--','color','r','DisplayName','Refusal Criterium');
    xlim([0 min(max(max([DATA_1(:,5), DATA_2(:,5), DATA_5(:,5), DATA_7(:,5)]))*1.2, 400*1.1)])
    ylim([0 ceil(max(DATA_1(:,1)))])
    ylabel('Penetration depth below mudline [m]', 'FontSize',8.5)
    xlabel('Blow count, [bl/m]','FontSize',9)
    ax = gca; 
    set(ax,'YDir','reverse')
    legend show
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on
%     hold off

    subplot(1,2,2)   % Hammer Effiency 
    plot(DATA_3(:,6)*100, DATA_1(:,1),'linestyle','-','color','r','DisplayName','Option 1');
    hold on
    plot(DATA_3(:,6)*100, DATA_2(:,1),'linestyle','--','color','r','DisplayName','Option 2');
    plot(DATA_3(:,6)*100, DATA_5(:,1),'linestyle','-.','color','r','DisplayName','Option 3');
    plot(DATA_3(:,6)*100, DATA_7(:,1),'linestyle',':','color','r','DisplayName','Option 4');
    ylabel('Penetration depth below mudline [m]', 'FontSize',8.5)
    xlabel('Applied hammer efficiency, [%]','FontSize',9)
    xlim([0 100])
    ylim([0 ceil(max(DATA_1(:,1)))])
    ax = gca; 
    set(ax,'YDir','reverse')
    legend show 
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on       
    hold off
    file=strcat(pwd,'\',ID{j},'_','BE_blowcount');
    print(gcf,file,'-dpng','-r300')
    close gcf
end

% Entrapped_UB_blow_count (Section 6)
for j = 1:length(ID)
        DATA_1 = struct2cell(OUTPUT{j,2}{1,1}); % 7 needs change if order of analyses changes
        DATA_3 = DATA_1{1,1}.DATA.Dmatrix;
        DATA_1 = DATA_1{1,1}.SRD.SOD;
        DATA_2 = struct2cell(OUTPUT{j,2}{1,2}); % 10 needs change if order of analyses changes
        DATA_4 = DATA_2{1,1}.DATA.Dmatrix;
        DATA_2 = DATA_2{1,1}.SRD.SOD;
        DATA_5 = struct2cell(OUTPUT{j,2}{1,3}); % 8 needs change if order of analyses changes
        DATA_6 = DATA_5{1,1}.DATA.Dmatrix;
        DATA_5 = DATA_5{1,1}.SRD.SOD;
        DATA_7 = struct2cell(OUTPUT{j,2}{1,4}); % 8 needs change if order of analyses changes
        DATA_8 = DATA_7{1,1}.DATA.Dmatrix;
        DATA_7 = DATA_7{1,1}.SRD.SOD;
        DATA_FINAL = [DATA_1(:,1), DATA_1(:,5), DATA_2(:,5), DATA_5(:,5), DATA_7(:,5), DATA_3(:,6)*100, DATA_4(:,6)*100, DATA_6(:,6)*100, DATA_8(:,6)*100, DATA_1(:,9), DATA_2(:,9), DATA_5(:,9), DATA_7(:,9)];
        File_name = strcat(ID(j),'.xlsx');
        col_header_ham_breakdown={'Penetration depth','Blowcount_NORM','Blowcount_SAND','Blowcount_BORS','Blowcount_SHOE','Hammer_efficiency_NORM','Hammer_efficiency_SAND','Hammer_efficiency_BORS','Hammer_efficiency_SHOE', 'ENTHRU_NORM', 'ENTHRU_SAND', 'ENTHRU_BORS', 'ENTHRU_SHOE'};
        col_units_ham_breakdown={'[m]','[Blows/m]','[Blows/m]','[Blows/m]','[Blows/m]','[%]','[%]','[%]','[%]','[kJ]','[kJ]','[kJ]'};
        xlswrite(File_name{1}, col_header_ham_breakdown,  'Entrapped UB blow count', 'B1');
        xlswrite(File_name{1}, col_units_ham_breakdown,  'Entrapped UB blow count', 'B2');
        xlswrite(File_name{1}, DATA_FINAL,  'Entrapped UB blow count', 'B3'); 
        % Plot function
    figure(2)
    clf;
    plot_font_size = 10;
    set(gcf, 'Units', 'Centimeters', 'PaperPosition', [0, 0, 10, 10], 'PaperUnits', 'Centimeters', 'PaperSize', [10.0, 10.0]);
%     hold all
    
    subplot(1,2,1)   % Blow Count
    plot(DATA_1(:,5),DATA_1(:,1),'linestyle','-','color','b','DisplayName','Option 1');
    hold on 
    plot(DATA_2(:,5),DATA_2(:,1),'linestyle','--','color','b','DisplayName','Option 2');
    plot(DATA_5(:,5),DATA_5(:,1),'linestyle','-.','color','b','DisplayName','Option 3');
    plot(DATA_7(:,5),DATA_7(:,1),'linestyle',':','color','b','DisplayName','Option 4');
    plot([394 394],[0 max(DATA_1(:,1))],'linestyle','--','color','r','DisplayName','Refusal Criterium');
    xlim([0 min(max(max([DATA_1(:,5), DATA_2(:,5), DATA_5(:,5), DATA_7(:,5)])), 400*1.1)])
    ylim([0 ceil(max(DATA_1(:,1)))])
    ylabel('Penetration depth below mudline [m]', 'FontSize',8.5)
    xlabel('Blow count, [bl/m]','FontSize',9)
    ax = gca; 
    set(ax,'YDir','reverse')
    legend show
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on
%     hold off

    subplot(1,2,2)   % Hammer Effiency 
    plot(DATA_3(:,6)*100, DATA_1(:,1),'linestyle','-','color','r','DisplayName','Option 1');
    hold on
    plot(DATA_3(:,6)*100, DATA_2(:,1),'linestyle','--','color','r','DisplayName','Option 2');
    plot(DATA_3(:,6)*100, DATA_5(:,1),'linestyle','-.','color','r','DisplayName','Option 3');
    plot(DATA_3(:,6)*100, DATA_7(:,1),'linestyle',':','color','r','DisplayName','Option 4');
    ylabel('Penetration depth below mudline [m]', 'FontSize',8.5)
    xlabel('Applied hammer efficiency, [%]','FontSize',9)
    xlim([0 100])
    ylim([0 ceil(max(DATA_1(:,1)))])
    ax = gca; 
    set(ax,'YDir','reverse')
    legend show 
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on       
    hold off
    file=strcat(pwd,'\',ID{j},'_','UB_blowcount');
    print(gcf,file,'-dpng','-r300')
    close gcf
end

% SRD_BE (Section 5)
for j = 1:length(ID)
        DATA_1 = struct2cell(OUTPUT{j,1}{1,1}); % 7 needs change if order of analyses changes
        DATA_3 = DATA_1{1,1}.DATA.Dmatrix;
        DATA_1 = DATA_1{1,1}.SRD.SOD;
        DATA_2 = struct2cell(OUTPUT{j,1}{1,2}); % 10 needs change if order of analyses changes
        DATA_4 = DATA_2{1,1}.DATA.Dmatrix;
        DATA_2 = DATA_2{1,1}.SRD.SOD;
        DATA_5 = struct2cell(OUTPUT{j,1}{1,3}); % 8 needs change if order of analyses changes
        DATA_6 = DATA_5{1,1}.DATA.Dmatrix;
        DATA_5 = DATA_5{1,1}.SRD.SOD;
        DATA_7 = struct2cell(OUTPUT{j,1}{1,4}); % 8 needs change if order of analyses changes
        DATA_8 = DATA_7{1,1}.DATA.Dmatrix;
        DATA_7 = DATA_7{1,1}.SRD.SOD;
        DATA_FINAL = [DATA_1(:,1), DATA_1(:,3), DATA_1(:,4), DATA_2(:,3), DATA_2(:,4), DATA_5(:,3), DATA_5(:,4), DATA_7(:,3), DATA_7(:,4)];
        File_name = strcat(ID(j),'.xlsx');
        col_header_ham_breakdown={'Penetration depth','Friction Option 1','End_bearing Option 1','Friction Option 2','End_bearing Option 2','Friction Option 3','End_bearing Option 3','Friction Option 4','End_bearing Option 4'};
        col_units_ham_breakdown={'[m]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]'};
        xlswrite(File_name{1}, col_header_ham_breakdown,  'BE SRD', 'B1');
        xlswrite(File_name{1}, col_units_ham_breakdown,  'BE SRD', 'B2');
        xlswrite(File_name{1}, DATA_FINAL,  'BE SRD', 'B3');  
        
     % Plot function
    figure(3)
    clf;
    plot_font_size = 10;
    set(gcf, 'Units', 'Centimeters', 'PaperPosition', [0, 0, 10, 10], 'PaperUnits', 'Centimeters', 'PaperSize', [10.0, 10.0]);
    
    subplot(1,2,1)   % Friction
    plot(DATA_1(:,3),DATA_1(:,1),'linestyle','-','color','b','DisplayName','Option 1');
    hold on 
    plot(DATA_2(:,3),DATA_2(:,1),'linestyle','--','color','b','DisplayName','Option 2');
    plot(DATA_5(:,3),DATA_5(:,1),'linestyle','-.','color','b','DisplayName','Option 3');
    plot(DATA_7(:,3),DATA_7(:,1),'linestyle',':','color','b','DisplayName','Option 4');
%     xlim([0 min(max(max([DATA_1(:,5), DATA_2(:,5), DATA_5(:,5), DATA_7(:,5)])), 1500)])
%     ylim([0 ceil(max(DATA_1(:,1)))])
    xlabel('Friction [MN]','FontSize',8.5)
    ylabel('Penetration depth below mudline [m]','FontSize',9);
    ax = gca; 
    set(ax,'YDir','reverse')
    legend show
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on

    subplot(1,2,2)   % End bearing
    plot(DATA_1(:,4), DATA_1(:,1),'linestyle','-','color','r','DisplayName','Option 1');
    hold on
    plot(DATA_2(:,4), DATA_2(:,1),'linestyle','--','color','r','DisplayName','Option 2');
    plot(DATA_5(:,4), DATA_5(:,1),'linestyle','-.','color','r','DisplayName','Option 3');
    plot(DATA_7(:,4), DATA_7(:,1),'linestyle',':','color','r','DisplayName','Option 4');
    xlabel('End Bearing [MN]','FontSize',8.5)
    ylabel('Penetration depth below mudline [m]','FontSize',9);
%     xlim([0 100])
%     ylim([0 ceil(max(DATA_1(:,1)))])
    ax = gca; 
    set(ax,'YDir','reverse')
    legend show 
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on       
    hold off
    file=strcat(pwd,'\',ID{j},'_','BE_SRD');
    print(gcf,file,'-dpng','-r300')
    close gcf
end

% SRD_UB (Section 5)
for j = 1:length(ID)
%         DATA_1 = struct2cell(OUTPUT{3,j}); % 3 needs change if order of analyses changes
%         DATA_3 = DATA_1{1,1}.DATA.Dmatrix;
%         DATA_1 = DATA_1{1,1}.SRD.SOD;
%         DATA_FINAL = [DATA_1(:,1), DATA_1(:,3), DATA_1(:,4)];
        DATA_1 = struct2cell(OUTPUT{j,2}{1,1}); % 7 needs change if order of analyses changes
        DATA_3 = DATA_1{1,1}.DATA.Dmatrix;
        DATA_1 = DATA_1{1,1}.SRD.SOD;
        DATA_2 = struct2cell(OUTPUT{j,2}{1,2}); % 10 needs change if order of analyses changes
        DATA_4 = DATA_2{1,1}.DATA.Dmatrix;
        DATA_2 = DATA_2{1,1}.SRD.SOD;
        DATA_5 = struct2cell(OUTPUT{j,2}{1,3}); % 8 needs change if order of analyses changes
        DATA_6 = DATA_5{1,1}.DATA.Dmatrix;
        DATA_5 = DATA_5{1,1}.SRD.SOD;
        DATA_7 = struct2cell(OUTPUT{j,2}{1,4}); % 8 needs change if order of analyses changes
        DATA_8 = DATA_7{1,1}.DATA.Dmatrix;
        DATA_7 = DATA_7{1,1}.SRD.SOD;
        DATA_FINAL = [DATA_1(:,1), DATA_1(:,3), DATA_1(:,4), DATA_2(:,3), DATA_2(:,4), DATA_5(:,3), DATA_5(:,4), DATA_7(:,3), DATA_7(:,4)];
        File_name = strcat(ID(j),'.xlsx');
        col_header_ham_breakdown={'Penetration depth','Friction Option 1','End_bearing Option 1','Friction Option 2','End_bearing Option 2','Friction Option 3','End_bearing Option 3','Friction Option 4','End_bearing Option 4'};
        col_units_ham_breakdown={'[m]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]'};
        xlswrite(File_name{1}, col_header_ham_breakdown,  'Sec. 5 UB SRD', 'B1');
        xlswrite(File_name{1}, col_units_ham_breakdown,  'Sec. 5 UB SRD', 'B2');
        xlswrite(File_name{1}, DATA_FINAL,  'Sec. 5 UB SRD', 'B3'); 
        
             % Plot function
    figure(4)
    clf;
    plot_font_size = 10;
    set(gcf, 'Units', 'Centimeters', 'PaperPosition', [0, 0, 10, 10], 'PaperUnits', 'Centimeters', 'PaperSize', [10.0, 10.0]);
    
    subplot(1,2,1)   % Friction
    plot(DATA_1(:,3),DATA_1(:,1),'linestyle','-','color','b','DisplayName','Option 1');
    hold on 
    plot(DATA_2(:,3),DATA_2(:,1),'linestyle','--','color','b','DisplayName','Option 2');
    plot(DATA_5(:,3),DATA_5(:,1),'linestyle','-.','color','b','DisplayName','Option 3');
    plot(DATA_7(:,3),DATA_7(:,1),'linestyle',':','color','b','DisplayName','Option 4');
%     xlim([0 min(max(max([DATA_1(:,5), DATA_2(:,5), DATA_5(:,5), DATA_7(:,5)])), 1500)])
%     ylim([0 ceil(max(DATA_1(:,1)))])
    xlabel('Friction [MN]','FontSize',8.5)
    ylabel('Penetration depth below mudline [m]','FontSize',9);
    ax = gca; 
    set(ax,'YDir','reverse')
    legend show
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on

    subplot(1,2,2)   % End bearing
    plot(DATA_1(:,4), DATA_1(:,1),'linestyle','-','color','r','DisplayName','Option 1');
    hold on
    plot(DATA_2(:,4), DATA_2(:,1),'linestyle','--','color','r','DisplayName','Option 2');
    plot(DATA_5(:,4), DATA_5(:,1),'linestyle','-.','color','r','DisplayName','Option 3');
    plot(DATA_7(:,4), DATA_7(:,1),'linestyle',':','color','r','DisplayName','Option 4');
    xlabel('End Bearing [MN]','FontSize',8.5)
    ylabel('Penetration depth below mudline [m]','FontSize',9);
%     xlim([0 100])
%     ylim([0 ceil(max(DATA_1(:,1)))])
    ax = gca; 
    set(ax,'YDir','reverse')
    legend show 
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on       
    hold off
    file=strcat(pwd,'\',ID{j},'_','UB_SRD');
    print(gcf,file,'-dpng','-r300')
    close gcf
end

% % SRD_Long_term (Section 5)
% for j = 1:length(ID)
%         DATA_2 = struct2cell(OUTPUT{j,1}{1,2}); % 10 needs change if order of analyses changes
%         DATA_4 = DATA_2{1,1}.DATA.Dmatrix;
%         DATA_2 = DATA_2{1,1}.SRD.SOD;
%         DATA_FINAL = [DATA_2(:,1), DATA_2(:,3), DATA_2(:,4)];
%         File_name = strcat(ID(j),'.xlsx');
%         col_header_ham_breakdown={'Penetration depth','Friction','End_bearing'};
%         col_units_ham_breakdown={'[m]','[MN]','[MN]'};
%         xlswrite(File_name{1}, col_header_ham_breakdown,  'Sec. 5 Long term SRD', 'B1');
%         xlswrite(File_name{1}, col_units_ham_breakdown,  'Sec. 5 Long term SRD', 'B2');
%         xlswrite(File_name{1}, DATA_FINAL,  'Sec. 5 Long term SRD', 'B3');  
% end

% Forces_BE (Section 7)
for j = 1:length(ID)
        DATA_1 = struct2cell(OUTPUT{j,1}{1,1}); % Option 1
        DATA_2 = DATA_1{1,1}.SRD.mxT;
        DATA_ = struct2cell(OUTPUT{j,1}{1,1}); % Option 1
        DATA_2 = DATA_1{1,1}.SRD.mxT;
        pile_length = sum([DATA_1{1,1}.DATA.PileGeometry{:,4}] );
        DATA_1 = DATA_1{1,1}.SRD.mxC;
        for jj = 1:size(DATA_1,1)
            DATA_3(jj,:) = min(DATA_2(jj,:));
            DATA_4(jj,:) = max(DATA_1(jj,:));
            DATA_5(jj,:) = jj*-(pile_length/size(DATA_1,1));
        end
        
        DATA_1 = struct2cell(OUTPUT{j,1}{1,2}); % Option 2
        DATA_2 = DATA_1{1,1}.SRD.mxT;
        pile_length = sum([DATA_1{1,1}.DATA.PileGeometry{:,4}] );
        DATA_1 = DATA_1{1,1}.SRD.mxC;
        for jj = 1:size(DATA_1,1)
            DATA_6(jj,:) = min(DATA_2(jj,:));
            DATA_7(jj,:) = max(DATA_1(jj,:));
            DATA_8(jj,:) = jj*-(pile_length/size(DATA_1,1));
        end
        
        DATA_1 = struct2cell(OUTPUT{j,1}{1,3}); % Option 3
        DATA_2 = DATA_1{1,1}.SRD.mxT;
        pile_length = sum([DATA_1{1,1}.DATA.PileGeometry{:,4}] );
        DATA_1 = DATA_1{1,1}.SRD.mxC;
        for jj = 1:size(DATA_1,1)
            DATA_9(jj,:) = min(DATA_2(jj,:));
            DATA_10(jj,:) = max(DATA_1(jj,:));
            DATA_11(jj,:) = jj*-(pile_length/size(DATA_1,1));
        end
        
        DATA_1 = struct2cell(OUTPUT{j,1}{1,4}); % Option 4
        DATA_2 = DATA_1{1,1}.SRD.mxT;
        pile_length = sum([DATA_1{1,1}.DATA.PileGeometry{:,4}] );
        DATA_1 = DATA_1{1,1}.SRD.mxC;
        for jj = 1:size(DATA_1,1)
            DATA_12(jj,:) = min(DATA_2(jj,:));
            DATA_13(jj,:) = max(DATA_1(jj,:));
            DATA_14(jj,:) = jj*-(pile_length/size(DATA_1,1));
        end
        DATA_FINAL = [DATA_5(:,1), DATA_3(:,1), DATA_4(:,1) , DATA_6(:,1), DATA_7(:,1), DATA_9(:,1), DATA_10(:,1), DATA_12(:,1), DATA_13(:,1)];
        File_name = strcat(ID(j),'.xlsx');
        col_header_ham_breakdown={'Depth below pile head','Max_tension_force Option 1','Max_compression_force Option 1','Max_tension_force Option 2','Max_compression_force Option 2','Max_tension_force Option 3','Max_compression_force Option 3','Max_tension_force Option 4','Max_compression_force Option 4'};
        col_units_ham_breakdown={'[m]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]'};
        xlswrite(File_name{1}, col_header_ham_breakdown,  'Sec. 7 Forces_BE', 'B1');
        xlswrite(File_name{1}, col_units_ham_breakdown,  'Sec. 7 Forces_BE', 'B2');
        xlswrite(File_name{1}, DATA_FINAL,  'Sec. 7 Forces_BE', 'B3'); 
                        
    figure(5)
    clf;
    plot_font_size = 10;
    set(gcf, 'Units', 'Centimeters', 'PaperPosition', [0, 0, 10, 10], 'PaperUnits', 'Centimeters', 'PaperSize', [10.0, 10.0]);
    
    subplot(1,2,1)   % Friction 
    plot(DATA_3(:,1),DATA_5(:,1),'linestyle','-','color','r','DisplayName','Option 1');
    hold on
    plot(DATA_6(:,1),DATA_5(:,1),'linestyle','--','color','r','DisplayName','Option 2');
    plot(DATA_9(:,1),DATA_5(:,1),'linestyle','-.','color','r','DisplayName','Option 3');
    plot(DATA_12(:,1),DATA_5(:,1),'linestyle',':','color','r','DisplayName','Option 4');
    xlabel('Min pile tension force [MN]','FontSize',8.5)
    ylabel('Depth below pile head [m]','FontSize',9);
    ax = gca; 
%     set(ax,'YDir','reverse')
    legend show
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on
    subplot(1,2,2)   % End bearing
    plot(DATA_4(:,1),DATA_5(:,1),'linestyle','-','color','b','DisplayName','Option 1');
    hold on 
    plot(DATA_7(:,1),DATA_5(:,1),'linestyle','--','color','b','DisplayName','Option 2');
    plot(DATA_10(:,1),DATA_5(:,1),'linestyle','-.','color','b','DisplayName','Option 3');
    plot(DATA_13(:,1),DATA_5(:,1),'linestyle',':','color','b','DisplayName','Option 4');
    xlabel('Max pile compression force [MN]','FontSize',8.5)
    ylabel('Depth below pile head [m]','FontSize',9);
    ax = gca; 
%     set(ax,'YDir','reverse')
    legend show 
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on       
    hold off
    file=strcat(pwd,'\',ID{j},'_','BE_Forces');
    print(gcf,file,'-dpng','-r300')
    close gcf
    
end

% Forces_UB (Section 7)
for j = 1:length(ID)
        DATA_1 = struct2cell(OUTPUT{j,2}{1,1}); % Option 1
        DATA_2 = DATA_1{1,1}.SRD.mxT;
        pile_length = sum([DATA_1{1,1}.DATA.PileGeometry{:,4}] );
        DATA_1 = DATA_1{1,1}.SRD.mxC;
        for jj = 1:size(DATA_1,1)
            DATA_3(jj,:) = min(DATA_2(jj,:));
            DATA_4(jj,:) = max(DATA_1(jj,:));
            DATA_5(jj,:) = jj*-(pile_length/size(DATA_1,1));
        end
        
        DATA_1 = struct2cell(OUTPUT{j,2}{1,2}); % Option 2
        DATA_2 = DATA_1{1,1}.SRD.mxT;
        pile_length = sum([DATA_1{1,1}.DATA.PileGeometry{:,4}] );
        DATA_1 = DATA_1{1,1}.SRD.mxC;
        for jj = 1:size(DATA_1,1)
            DATA_6(jj,:) = min(DATA_2(jj,:));
            DATA_7(jj,:) = max(DATA_1(jj,:));
            DATA_8(jj,:) = jj*-(pile_length/size(DATA_1,1));
        end
        
        DATA_1 = struct2cell(OUTPUT{j,2}{1,3}); % Option 3
        DATA_2 = DATA_1{1,1}.SRD.mxT;
        pile_length = sum([DATA_1{1,1}.DATA.PileGeometry{:,4}] );
        DATA_1 = DATA_1{1,1}.SRD.mxC;
        for jj = 1:size(DATA_1,1)
            DATA_9(jj,:) = min(DATA_2(jj,:));
            DATA_10(jj,:) = max(DATA_1(jj,:));
            DATA_11(jj,:) = jj*-(pile_length/size(DATA_1,1));
        end
        
        DATA_1 = struct2cell(OUTPUT{j,2}{1,4}); % Option 4
        DATA_2 = DATA_1{1,1}.SRD.mxT;
        pile_length = sum([DATA_1{1,1}.DATA.PileGeometry{:,4}] );
        DATA_1 = DATA_1{1,1}.SRD.mxC;
        for jj = 1:size(DATA_1,1)
            DATA_12(jj,:) = min(DATA_2(jj,:));
            DATA_13(jj,:) = max(DATA_1(jj,:));
            DATA_14(jj,:) = jj*-(pile_length/size(DATA_1,1));
        end
        
        DATA_FINAL = [DATA_5(:,1), DATA_3(:,1), DATA_4(:,1) , DATA_6(:,1), DATA_7(:,1), DATA_9(:,1), DATA_10(:,1), DATA_12(:,1), DATA_13(:,1)];
        File_name = strcat(ID(j),'.xlsx');
        col_header_ham_breakdown={'Depth below pile head','Max_tension_force Option 1','Max_compression_force Option 1','Max_tension_force Option 2','Max_compression_force Option 2','Max_tension_force Option 3','Max_compression_force Option 3','Max_tension_force Option 4','Max_compression_force Option 4'};
        col_units_ham_breakdown={'[m]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]','[MN]'};
        xlswrite(File_name{1}, col_header_ham_breakdown,  'Sec. 7 Forces_UB', 'B1');
        xlswrite(File_name{1}, col_units_ham_breakdown,  'Sec. 7 Forces_UB', 'B2');
        xlswrite(File_name{1}, DATA_FINAL,  'Sec. 7 Forces_UB', 'B3'); 

                              
    figure(6)
    clf;
    plot_font_size = 10;
    set(gcf, 'Units', 'Centimeters', 'PaperPosition', [0, 0, 10, 10], 'PaperUnits', 'Centimeters', 'PaperSize', [10.0, 10.0]);
    
    subplot(1,2,1)   % Friction
    plot(DATA_3(:,1),DATA_5(:,1),'linestyle','-','color','r','DisplayName','Option 1');
    hold on
    plot(DATA_6(:,1),DATA_5(:,1),'linestyle','--','color','r','DisplayName','Option 2');
    plot(DATA_9(:,1),DATA_5(:,1),'linestyle','-.','color','r','DisplayName','Option 3');
    plot(DATA_12(:,1),DATA_5(:,1),'linestyle',':','color','r','DisplayName','Option 4');
    xlabel('Min pile tension force [MN]','FontSize',8.5)
    ylabel('Depth below pile head [m]','FontSize',9);
    ax = gca; 
%     set(ax,'YDir','reverse')
    legend show
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on
    subplot(1,2,2)   % End bearing
    plot(DATA_4(:,1),DATA_5(:,1),'linestyle','-','color','b','DisplayName','Option 1');
    hold on 
    plot(DATA_7(:,1),DATA_5(:,1),'linestyle','--','color','b','DisplayName','Option 2');
    plot(DATA_10(:,1),DATA_5(:,1),'linestyle','-.','color','b','DisplayName','Option 3');
    plot(DATA_13(:,1),DATA_5(:,1),'linestyle',':','color','b','DisplayName','Option 4');
    xlabel('Max pile compression force [MN]','FontSize',8.5)
    ylabel('Depth below pile head [m]','FontSize',9);
    ax = gca; 
%     set(ax,'YDir','reverse')
    legend show 
    legend({'Option 1', 'Option 2', 'Option 3', 'Option 4'},'Fontsize', 6.5, 'Location','northoutside');
    grid on       
    hold off
    file=strcat(pwd,'\',ID{j},'_','UB_Forces');
    print(gcf,file,'-dpng','-r300')
    close gcf

end

