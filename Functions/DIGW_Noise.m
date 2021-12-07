function [] = DIGW_Noise(filelist,Settings,A,NoSteps,j)
%DIGW Summary of this function goes here
%   Detailed explanation goes here


SimulationLable=Settings.SimulLable{A.Analysis};


        fclose all;
%     for i=1:size(filelist,1)
        Command=strcat({'cd '},Settings.DIGWFolder(1),{' & DIGW.exe '},filelist,{'.gwt'});
        AO=system(Command{1});

%     end
    
%    AO=system('cd C:\PDI\GRLWEAP 2010 & DIGW.exe \\cowi.net\projects\A225000\A225662\20-Data\GEO\CODRIVE\NoiseSTR_FOR\EW2_OSS_NORM_JonNoiseSTR_FOR_83.gwt')

end   

