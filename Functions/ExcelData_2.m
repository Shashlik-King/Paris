function [EData] = ExcelData_2(Files,Sheets,Ranges,EData)
%ExcelData - Opens Excel file and add data from multiple sheets to Data-object.
%   2019-11-20 Started, MTHG
%Files = dir('*.xlsx');

sheet=Sheets{1,1}

if nargin ==3 || nargin==4
    
    N_File=numel(Files);
    % Open Excel App
    e = actxserver ('Excel.Application');
    h=waitbar(0,'Loading Excel...');
 
    for o = 1:N_File
    
        filename=Files{o};
         qs=numel(Files)-o;
        %clc;
        fprintf('Please wait %d second ',qs)
        fprintf(1,repmat('\n',1,1));
        waitbar(o/N_File,h);
        
        for S=1:size(Sheets,1)
        
        for oo=1:size(Ranges,1)
            
            
        
                    %Temp=xlsread(filename,sheet,Ranges{oo,2});
                    Temp=readtable(filename,'Sheet',sheet,'Range',Ranges{oo,2}); 
                    Temp = rmmissing(Temp);
                    
                    
                    EData.(Sheets{S}).(Ranges{oo,1})=num2cell(Temp);
                    
        
        end    
        
        
        
        end 
%         qs=numel(Files)-o;
%         clc;
%         fprintf('Please wait %d second ',qs)
%         fprintf(1,repmat('\n',1,1));
%         waitbar(o/N_File,h);
%         % Open file
%         ExcelWorkbook = e.workbooks.Open(fullfile(pwd,Files{o}));
%         ExcelSheets=ExcelWorkbook.Worksheets;
%         % Loop over lists of sheets
%         for S=1:size(Sheets,1)
%             % Set active sheet
%             try SingleSheet=ExcelSheets.get('Item',char(Sheets(S)));
%                 % perhaps include if exists
%                 for R=1:size(Ranges,1)
%                     % Select range
%                     
%                     SingleSheetRange=SingleSheet.get('Range',char(Ranges(R,2)));
%                     % Extract data
%                     Temp=SingleSheetRange.Value;
%                     % Delete NaN rows 
%                     Temp=Temp(any(cellfun(@(x)any(~isnan(x)),Temp),2),:);
%                     % Delete empty rows
%                     Temp=Temp(all(cellfun(@(x)any(~isempty(x)),Temp(:,2)),2),:);
%                     % Delete VT_ERROR (blanks in Excel)
%                     Temp=Temp(all(cellfun(@(x)any(~strcmp(x,'ActiveX VT_ERROR: ')),Temp),2),:);
%                     EData.(Sheets{S}).(Ranges{R,1})=Temp;
%                 end
%             end
%             
%         end
%         
%         ExcelWorkbook.Close;
    end
end
close(h);
e.Quit;
e.delete;
end


