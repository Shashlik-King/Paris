function [GWO]=GWOread(filename)
    fid=fopen(strcat(filename,'.GWO'));     %file name
    GWO=textscan(fid,'%s','delimiter','\r');     %import complete file to f. Each line in the file is treated as a separate row
    fclose(fid);
end