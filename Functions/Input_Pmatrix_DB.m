function [PileGeometry,pile_top,pile_tip] = Input_Pmatrix_DB(Settings,loc)

%% Open mysql database
mysql('open','DKLYCOPILOD1',Settings.Database.Username,Settings.Database.Password); % ('open','server','username','password')
mysql(['use ' Settings.Database.DBname]); % name of database

%% Database unique id's
%--------------------------------------------------------------------------
location = ['''',Settings.Database.LoadIterationName,loc,'''']; % name of location
rev_structure   = Settings.Database.Rev.Geometry; % revision no. of structure to be used
if rev_structure ~= 1000 % check, if specified revision numbers are available for specified location
    [rev] = mysql(['select structural_revision from mp_cans where id=',location]);
    if ismember(rev_structure,str2double(rev)) == 0 % if specified structure revision is not available then output an error message
        error('Specified structural revision number doesn''t exist for this location');
    end
else
    [rev] = mysql(['select structural_revision from mp_cans where id=',location]);
    rev = sort(str2double(rev));
    rev_structure = max(rev(1:sum(sort(rev)<80)));
end

if rev_structure<10
    rev_structure   = ['''0',num2str(rev_structure),'''']; % revision no. of structure to be used
else
    rev_structure   = ['''',num2str(rev_structure),'''']; % revision no. of structure to be used
end

table = 'mp_cans';
[can_id, top_od, bot_od,height,wall_thickness,steel_grade] = mysql...
    (['select can_id, top_od, bottom_od, height, wall_thickness,steel_grade from ',table,' where id=',...
    location,' and structural_revision=',rev_structure,' ORDER BY can_id']);


table = 'mp_main_dimensions';
[pile_top, pile_tip] = mysql(['select pile_top, pile_tip from ',table,...
    ' where id=',location,' and structural_revision=',rev_structure]);


mysql('close')

% Create the pile geometry table from database data
PileGeometry = num2cell([top_od, bot_od, wall_thickness/1000, height]);

% Check no missing cans
if ~(sum(can_id) == sum(1:length(can_id)))
    warndlg(['Error in importet data from database - check can_id for ' Settings.Locations{Index_loop}],'Error pile geometry')
end


