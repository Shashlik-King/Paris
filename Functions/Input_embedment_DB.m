function Embedment = Input_embedment_DB(Settings,loc)
% Function to connect to database and get the embedment length for the 
% desired location

%% Open mysql database
mysql('open','DKLYCOPILOD1',Settings.Database.Username,Settings.Database.Password); % ('open','server','username','password')
mysql(['use ' Settings.Database.DBname]); % name of database


%% Database unique id's
%--------------------------------------------------------------------------
location = ['''',loc,'''']; % name of location
    rev_structure   = Settings.Database.Rev.Geometry; % revision no. of structure to be used
    
    if rev_structure ~= 1000 % check, if specified revision numbers are available for specified location
        [rev] = mysql(['select structural_revision from mp_main_dimensions where id=',location]);
        
        if ismember(rev_structure,str2double(rev)) == 0 % if specified structure revision is not available then output an error message
            error('Specified structural revision number doesn''t exist for this location');
        end
    else
        [rev] = mysql(['select structural_revision from mp_main_dimensions where id=',location]);
        
        rev = sort(str2double(rev));
        rev_structure = max(rev(1:sum(sort(rev)<80)));
    end

if rev_structure<10
    rev_structure   = ['''0',num2str(rev_structure),'''']; % revision no. of structure to be used
else
    rev_structure   = ['''',num2str(rev_structure),'''']; % revision no. of structure to be used
end


table = 'water_depths';
[water_depth] = mysql(['select water_depth from ',table,' where id=',location]);

table = 'mp_main_dimensions';
[pile_tip] = mysql(['select pile_tip from ',table,' where id=',location,' and structural_revision=',rev_structure]);

mysql('close')

% Calculate the embedment length
Embedment = water_depth - pile_tip;



