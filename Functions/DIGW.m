function [] = DIGW(SRD, filelist,Settings,A,loc,locLoop)
%DIGW This function Run all of Gwt files 
%if the Automatic skip penetration is on 
%it would skip the depth which are smaller than the SWP Depth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp([' Running the DIGW  for Analysis:  ',A.SimulationLable , ' For Location ' , loc{locLoop,1} ]) 
filelist = filelist.(loc{locLoop,1});

%if Skiping run of Self penetrated depth 
if Settings.AutomaticSW(A.Analysis) == 1
    StartIdx = SRD.(loc{locLoop,1}).SWPpileWtIdx;
else 
    StartIdx = 1; 
end 
    
    h=waitbar(0,'DIGW...');
    for i = StartIdx:size(filelist,1)    %%% Starting from the depth end of self penetration instead of 1
        Command =strcat({'cd '},Settings.DIGWFolder(1),{' & DIGW.exe '},filelist(i),{'.gwt'});
        system(Command{1});
        waitbar((i-StartIdx+1)/(length(filelist)-StartIdx),h,['DIGW - File ' num2str(i) '/' num2str(length(filelist))]);
    end
    close(h)

end
