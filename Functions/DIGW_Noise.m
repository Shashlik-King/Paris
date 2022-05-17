function [] = DIGW_Noise(filelist,Settings,~,~,~)
%DIGW - executes the DIGW.exe for given .gwt file
fclose all;
Command=strcat({'cd '},Settings.DIGWFolder,{' & DIGW.exe '},filelist,{'.gwt'});
system(Command{1});
end   

