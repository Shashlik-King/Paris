function AppendixGeneration_LocationInput(Data,Settings,Position,embed_length)
% Generate the .tex input for each location

%% Blow count per meter
% % [value1, value2] = max(SRD.(Position).SOD(:,5)); 
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxBCm_BE.tex'), 'w+');
% % fprintf(FID, '%1.1f', value1);
% % fclose(FID);
% % 
% % 
if Settings.Appendix.LocationInfo
    FID = fopen(char('AppendixGenerationFiles/ProjectLocation/pile_depth.tex'), 'w+');
    fprintf(FID, '%1.2f', Data.(Position).Dmatrix(end,1));
    fclose(FID);
end

if Settings.Appendix.LocationInfo
    FID = fopen(char('AppendixGenerationFiles/ProjectLocation/pile_length.tex'), 'w+');
    fprintf(FID, '%1.2f', abs(Data.(Position).pile_top)+abs(Data.(Position).pile_tip));
    fclose(FID);
end

if Settings.Appendix.LocationInfo
    FID = fopen(char('AppendixGenerationFiles/ProjectLocation/MP_top.tex'), 'w+');
    fprintf(FID, '%1.2f', Data.(Position).pile_top);
    fclose(FID);
end

if Settings.Appendix.LocationInfo
    FID = fopen(char('AppendixGenerationFiles/ProjectLocation/MP_bottom.tex'), 'w+');
    fprintf(FID, '%1.2f', Data.(Position).pile_tip);
    fclose(FID);
end

if Settings.Appendix.LocationInfo
    FID = fopen(char('AppendixGenerationFiles/ProjectLocation/water_depth.tex'), 'w+');
    fprintf(FID, '%1.2f', abs(Data.(Position).pile_tip + Data.(Position).Dmatrix(end,1)));
    fclose(FID);
end

FID = fopen(char('AppendixGenerationFiles/ProjectLocation/ID_location.tex'), 'w+');
fprintf(FID, '%s', Position);
fclose(FID);
% % 
% % 
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxBCmdepth_BE.tex'), 'w+');
% % fprintf(FID, '%1.1f', SRD.(Position).SOD(value2,1));
% % fclose(FID);
% % 
% % [value1, value2] = max(SRD_UB.(Position).SOD(:,5));
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxBCm_UB.tex'), 'w+');
% % fprintf(FID, '%1.1f', value1);
% % fclose(FID);
% % 
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxBCmdepth_UB.tex'), 'w+');
% % fprintf(FID, '%1.1f', SRD_UB.(Position).SOD(value2,1));
% % fclose(FID);

%% Accumulated blow     -   Check this 
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/AccumulatedBC_BE.tex'), 'w+');
% % fprintf(FID, '%1.0f', max(cumsum(SRD.(Position).SOD(:,10))));
% % fclose(FID);
% % 
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/AccumulatedBC_UB.tex'), 'w+');
% % fprintf(FID, '%1.0f', max(cumsum(SRD_UB.(Position).SOD(:,10))));
% % fclose(FID);

%% SRD
% % [value1, value2] = max(SRD.(Position).SOD(:,2));
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxSRD_BE.tex'), 'w+');
% % fprintf(FID, '%1.1f', value1/1000);
% % fclose(FID);
% % 
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxSRDdepth_BE.tex'), 'w+');
% % fprintf(FID, '%1.1f', SRD.(Position).SOD(value2,1));
% % fclose(FID);
% % 
% % 
% % [value1, value2] = max(SRD_UB.(Position).SOD(:,2));
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxSRD_UB.tex'), 'w+');
% % fprintf(FID, '%1.1f', value1/1000);
% % fclose(FID);
% % 
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxSRDdepth_UB.tex'), 'w+');
% % fprintf(FID, '%1.1f', SRD_UB.(Position).SOD(value2,1));
% % fclose(FID);

%% Fatigue damage
% % [value1, value2] = max(SRD.(Position).D);
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxfatique_BE.tex'), 'w+');
% % fprintf(FID, '%1.1f', value1*100);
% % fclose(FID);
% % 
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxfatiquedepth_BE.tex'), 'w+');
% % fprintf(FID, '%1.2f', Data.(Position).SCF{value2,1});
% % fclose(FID);
% % 
% % [value1, value2] = max(SRD_UB.(Position).D);
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxfatique_UB.tex'), 'w+');
% % fprintf(FID, '%1.1f', value1*100);
% % fclose(FID);
% % 
% % FID = fopen(char('AppendixGenerationFiles/ProjectLocation/maxfatiquedepth_UB.tex'), 'w+');
% % fprintf(FID, '%1.2f', Data.(Position).SCF{value2,1});
% % fclose(FID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%soil stratigrapgy in appendix%%%%%%%%%%%%%%%%


SoilStratigraphy=Data.(Position).SoilProfile;

F = fopen(char('AppendixGenerationFiles/ProjectLocation/Soil_Stratigraphy.tex'),'wt');
for i = 1:size(SoilStratigraphy,1)
       fprintf(F,'%.1f & %.1f & %s & %.1f & %.1f  \\\\\\hline \n',cell2mat(SoilStratigraphy(i,2)),cell2mat(SoilStratigraphy(i,3)),SoilStratigraphy{i,4},cell2mat(SoilStratigraphy(i,5)),cell2mat(SoilStratigraphy(i,7)));  %%%%,pile_geometry{i,7},cell2mat(pile_geometry(i,8))); 
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Pile table for appendix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% geometry(top diameter, bottom diamter, thickness, can height, SCF, S-N curve, embedment(constant for all rows))
SCF=[Data.(Position).SCF(:,2) Data.(Position).SCF(:,3)];

SCF(size(SCF,1)+1,:)=num2cell(0);

geometry=[Data.(Position).PileGeometry(:,1) Data.(Position).PileGeometry(:,2) Data.(Position).PileGeometry(:,3) Data.(Position).PileGeometry(:,4)]; %%% SCF(:,1) SCF(:,2)]; 




can.top = cumsum(cell2mat(geometry(:,4)))-embed_length;
for i = 1:size(geometry,1)
    if i == 1
       pile_geometry(i,:) = [i, 0 , geometry(i,1), geometry(i,2), geometry(i,4), geometry(i,3)]; %%%%%%, geometry(i,6), geometry(i,5)];
    elseif i == size(geometry,1)
        pile_geometry(i,:) = [i, sum(cell2mat(geometry(1:1:i-1,4))), geometry(i,1), geometry(i,2), geometry(i,4), geometry(i,3)];%%%, NaN, NaN];
    else
       pile_geometry(i,:) = [i, sum(cell2mat(geometry(1:1:i-1,4))), geometry(i,1), geometry(i,2), geometry(i,4), geometry(i,3)];%%%%%, geometry(i,6), geometry(i,5)];  
    end
end
F = fopen(char('AppendixGenerationFiles/ProjectLocation/pile_geometry.tex'),'wt');
for i = 1:size(pile_geometry,1)
   if i ==  size(pile_geometry,1)
       fprintf(F,'%.0f & %.2f & %.3f & %.3f & %.2f & %.0f \\\\\\hline \n',cell2mat(pile_geometry(i,1)),cell2mat(pile_geometry(i,2)),cell2mat(pile_geometry(i,3)),cell2mat(pile_geometry(i,4)),cell2mat(pile_geometry(i,5)),cell2mat(pile_geometry(i,6))*1000);
   else
       fprintf(F,'%.0f & %.2f & %.3f & %.3f & %.2f & %.0f  \\\\\\hline \n',cell2mat(pile_geometry(i,1)),cell2mat(pile_geometry(i,2)),cell2mat(pile_geometry(i,3)),cell2mat(pile_geometry(i,4)),cell2mat(pile_geometry(i,5)),cell2mat(pile_geometry(i,6))*1000);  %%%%,pile_geometry{i,7},cell2mat(pile_geometry(i,8))); 
   end
end
fclose(F);




%% Create footer file
%char(strcat(Project,'/',Position,'/Plots/',cell2mat(Position),' footer.tex')), 'w+')
FID = fopen(char('AppendixGenerationFiles/ProjectLocation/footer.tex'), 'w+');
fprintf(FID, '%s\\_Pile\\_Driveability\\_Appendix\\_for\\_%s, V%s', Settings.Appendix.DocumentNoCOWI,Position,Settings.Appendix.RevisionTable{end,1});
fclose(FID);

