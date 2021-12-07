function python_File_Exchange(GE_filelist)

 mkdir ('Python_Exchange');

 fid=fopen([pwd,'\Python_Exchange\Folder_Names.txt'],'w');

 for i=1:size(GE_filelist.Full_BE,1)
     
     fprintf(fid,'%s\r\n',GE_filelist.Full_BE{i,1});
     
 end 
 fclose(fid);
 
 Analysis_Name=fieldnames(GE_SRD);
 
 for i:1 Size(Analysis_Name,1)
     
     Locationnames= fieldnames(GE_SRD.(Analysis_Name{i,1})
 
 
 
 
 
 
end 