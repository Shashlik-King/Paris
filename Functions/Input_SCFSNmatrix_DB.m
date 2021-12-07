function SCFSN_table = Input_SCFSNmatrix_DB(Settings,loc)
%% Manual input
% close all; clear; clc;
% loc = 'DDG06';
% Settings.Database.DBname = 'nzdb';
% Settings.Database.Username = 'nzdb_user';
% Settings.Database.Password = 'ituotdnzdb';
% Settings.Database.Rev.Geometry = 1000;
% addpath('Functions')        % Adding folder with functions to path

%% Load tables
% % % % % % % % TABattm = readtable(['FatFiles\attm_' loc '.dat']);
% % % % % % % % TABwelds = readtable(['FatFiles\scf_' loc '_in.dat']);
% % % % % % % % 
% % % % % % % % %% Open mysql database
% % % % % % % % mysql('open','DKLYCOPILOD1',Settings.Database.Username,Settings.Database.Password); % ('open','server','username','password')
% % % % % % % % mysql(['use ' Settings.Database.DBname]); % name of database
% % % % % % % % 
% % % % % % % % 
% % % % % % % % %% Database unique id's
% % % % % % % % %--------------------------------------------------------------------------
% % % % % % % % location = ['''',loc,'''']; % name of location
% % % % % % % % rev_structure   = Settings.Database.Rev.Geometry; % revision no. of structure to be used
% % % % % % % % 
% % % % % % % % if rev_structure ~= 1000 % check, if specified revision numbers are available for specified location
% % % % % % % %     [rev] = mysql(['select structural_revision from mp_main_dimensions where id=',location]);
% % % % % % % %     
% % % % % % % %     if ismember(rev_structure,str2double(rev)) == 0 % if specified structure revision is not available then output an error message
% % % % % % % %         error('Specified structural revision number doesn''t exist for this location');
% % % % % % % %     end
% % % % % % % % else
% % % % % % % %     [rev] = mysql(['select structural_revision from mp_main_dimensions where id=',location]);
% % % % % % % %     
% % % % % % % %     rev = sort(str2double(rev));
% % % % % % % %     rev_structure = max(rev(1:sum(sort(rev)<80)));
% % % % % % % % end
% % % % % % % % 
% % % % % % % % if rev_structure<10
% % % % % % % %     rev_structure   = ['''0',num2str(rev_structure),'''']; % revision no. of structure to be used
% % % % % % % % else
% % % % % % % %     rev_structure   = ['''',num2str(rev_structure),'''']; % revision no. of structure to be used
% % % % % % % % end
% % % % % % % % 
% % % % % % % % table = 'mp_main_dimensions';
% % % % % % % % [pile_top] = mysql(['select pile_top from ',table,' where id=',location,' and structural_revision=',rev_structure]);
% % % % % % % % 
% % % % % % % % mysql('close')
% % % % % % % % 
% % % % % % % % %% Create table for output
% % % % % % % % SN=[{'B1'} 4.0 5 15.117  17.146 106.97 0
% % % % % % % %     {'B2'} 4.0 5 14.885  16.856  93.59 0           	%B2 (DNV) and 140(EC3)
% % % % % % % %     {'C'}  3.0 5 12.592  16.320  73.10 0.05
% % % % % % % %     {'C1'} 3.0 5 12.449  16.081  65.50 0.1          %C1 (DNV) and 112(EC3)
% % % % % % % %     {'C2'} 3.0 5 12.301  15.835  58.48 0.15        	%C2 (DNV) and 100(EC3)
% % % % % % % %     {'D'}  3.0 5 12.164  15.606  52.63 0.2     		%1.00  D  (DNV) and  90(EC3)
% % % % % % % %     {'E'}  3.0 5 11.855  15.350  46.78 0.2];     	%1.13
% % % % % % % % 
% % % % % % % % 
% % % % % % % % for i = 1:size(TABattm,1)
% % % % % % % %     check = zeros(size(SN,1),1);
% % % % % % % %     for j = 1:size(SN)
% % % % % % % %         if contains(table2array(TABattm{i,6}),SN{j,1})
% % % % % % % %             check(j) = 1;
% % % % % % % %         end
% % % % % % % %     end
% % % % % % % %     index = find(abs(check-1)<0.01);
% % % % % % % %     if size(index,1) > 1
% % % % % % % %         for k = 1:size(index,1)
% % % % % % % %             lengthSNcurve(k) = length(SN{index(k),1});
% % % % % % % %         end
% % % % % % % %         [~,lengthIndex] = max(lengthSNcurve);
% % % % % % % %         index = index(lengthIndex);
% % % % % % % %     end
% % % % % % % %     table_attm(i,:) = {pile_top-table2array(TABattm(i,2)), table2array(TABattm(i,7)), SN{index,1}, 'attm'};
% % % % % % % % end
% % % % % % % % for i = 1:size(TABwelds,1)
% % % % % % % %     check = zeros(size(SN,1),1);
% % % % % % % %     for j = 1:size(SN)
% % % % % % % %         if contains(table2array(TABwelds{i,4}),SN{j,1})
% % % % % % % %             check(j) = 1;
% % % % % % % %         end
% % % % % % % %     end
% % % % % % % %     index = find(abs(check-1)<0.01);
% % % % % % % %     if size(index,1) > 1
% % % % % % % %         for k = 1:size(index,1)
% % % % % % % %             lengthSNcurve(k) = length(SN{index(k),1});
% % % % % % % %         end
% % % % % % % %         [~,lengthIndex] = max(lengthSNcurve);
% % % % % % % %         index = index(lengthIndex);
% % % % % % % %     end
% % % % % % % %     table_welds(i,:) = {pile_top-table2array(TABwelds(i,2)), table2array(TABwelds(i,5)), SN{index,1}, 'weld'};
% % % % % % % % end
% % % % % % % % 
% % % % % % % % 
% % % % % % % % SCFSN_table = sortrows([table_attm;table_welds],1);







%% COPILOD connection (needs to be coded proberbly)
%% Open mysql database
mysql('open','DKLYCOPILOD1',Settings.Database.Username,Settings.Database.Password); % ('open','server','username','password')
mysql(['use ' Settings.Database.DBname]); % name of database

%% Database unique id's
%--------------------------------------------------------------------------
location = ['''',Settings.Database.LoadIterationName,loc,'''']; % name of location
rev_attachments   = Settings.Database.Rev.Attachments; % revision no. of structure to be used
rev_revsub=Settings.Database.Rev.SubRevSFC;

if rev_attachments ~= 1000 % check, if specified revision numbers are available for specified location
    [rev] = mysql(['select rev from FLS_input where id=',location]);
    if ismember(rev_attachments,str2double(rev)) == 0 % if specified structure revision is not available then output an error message
        error('Specified structural revision number doesn''t exist for this location');
    end
else
    [rev] = mysql(['select rev from FLS_input where id=',location]);
    rev = sort(str2double(rev));
    rev_attachments = max(rev(1:sum(sort(rev)<80)));
end

if rev_attachments<10
    rev_attachments   = ['''0',num2str(rev_attachments),'''']; % revision no. of structure to be used
else
    rev_attachments   = ['''',num2str(rev_attachments),'''']; % revision no. of structure to be used
end

if rev_revsub<10
    rev_sub_input   = ['''0',num2str(rev_revsub),'''']; % revision no. of structure to be used
else
    rev_sub_input   = ['''',num2str(rev_revsub),'''']; % revision no. of structure to be used
end





%% Import needed data
table = 'FLS_input';
% % % % % % % % % % % % [can_id, top_od, bot_od,height,wall_thickness,steel_grade] = mysql...
% % % % % % % % % % % %     (['select can_id, top_od, bottom_od, height, wall_thickness,steel_grade from ',table,' where id=',...
% % % % % % % % % % % %     location,' and structural_revision=',rev_attachments,' ORDER BY can_id']);



%% Create table for SCF and SN values

 % Distance from top, SCF factor, SN curve (letter)
 
 
 %% Extracting the data of CW  weld
 

 
 [id_elem_cw, elev_cw, wall_thickness_nom_cw,SCF_cw, curve_cw] = mysql...
    (['SELECT id_elem, elev, wall_thickness_nom,SCF, curve FROM ',table,' where id=',...
    location,' and rev=',rev_attachments,' and rev_sub=',rev_sub_input,' and  location="inside" and type_elem="CW" ',' ORDER BY elev DESC']);
 
 %%%%% Selection of the critical  CW based on lower wall thickenss   PNGI
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%% add frist and last row for pile head and pile tip 
 GlobalID=[1:1:size(elev_cw,1)]
 
 for iii=1:size(id_elem_cw,1)/2
     elevSelc=elev_cw(2*iii,1);
     [Value, IndexLocal]=min(wall_thickness_nom_cw(find(elev_cw==elevSelc)));
     ExtractedID=GlobalID(find(elev_cw==elevSelc));
     indexMinThickness=ExtractedID(IndexLocal);
     
%      indexMinThickness=find(wall_thickness_nom_cw==min(wall_thickness_nom_cw(find(elev_cw==elevSelc))));
     
     Sel_elev(iii,1)=elev_cw(indexMinThickness,1);
     Sel_SCF(iii,1)=SCF_cw(indexMinThickness,1);        
     Sel_curve(iii,1)=curve_cw(indexMinThickness,1); 
     sel_type{iii,1}='weld';
 end 
 
 Sel_elev=[elev_cw(1,1);Sel_elev];  % Add frist row
 Sel_SCF=[SCF_cw(1,1);Sel_SCF];      % Add first  row 
 Sel_curve=[curve_cw(1,1);Sel_curve];    % Add first  row 
 sel_type=[sel_type(1,1);sel_type];    % Add first  row 

%% Extracting the data of attachment 
 
  [id_elem_ATTM, elev_ATTM, wall_thickness_nom_ATTM,SCF_ATTM, curve_ATTM] = mysql...
    (['SELECT id_elem, elev, wall_thickness_nom,SCF, curve FROM ',table,' where id=',...
    location,' and rev=',rev_attachments,' and rev_sub=',rev_sub_input,' and type_elem="ATTM" ',' ORDER BY elev DESC']);
 
 %%%%%% Selection of the  critical ATTM based on the higher SCF   PNGI
 %%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
  GlobalID=[1:1:size(elev_ATTM,1)];

 
  for jjj=1:size(elev_ATTM,1)/3
  MPKey=id_elem_ATTM{3*jjj,1};
  IndexC = strfind(id_elem_ATTM,MPKey);
  Index = find(not(cellfun('isempty',IndexC)));
  [Value, IndexLocal]=max(SCF_ATTM(Index));
  ExtractedID=GlobalID(Index);
  indexCrit=ExtractedID(IndexLocal);

  Sel_elev_ATTM(jjj,1)=elev_ATTM(indexCrit);
  Sel_SCF_ATTM(jjj,1)=SCF_ATTM(indexCrit); 
  Sel_curve_ATTM(jjj,1)=curve_ATTM(indexCrit);
  sel_elem_type{jjj,1}='attm';
  
  end 
 
 
 %% Extracting the data of opening
 
   [id_elem_Open, elev_Open, wall_thickness_nom_Open,SCF_Open, curve_Open, type_open] = mysql...
    (['SELECT id_elem, elev, wall_thickness_nom,SCF, curve,type_elem FROM ',table,' where id=',...
    location,' and rev=',rev_attachments,' and rev_sub=',rev_sub_input,' and type_elem="OPEN" and id_elem_sub="49"',' ORDER BY elev DESC']);
 

%%%%%%%Temprary_Reading all of the rows in the table 
 
 [id_elem, elev, wall_thickness_nom,SCF, curve,Type_elem] = mysql...
    (['SELECT id_elem, elev, wall_thickness_nom,SCF, curve, type_elem FROM ',table,' where id=',...
    location,' and rev=',rev_attachments,' and rev_sub=',rev_sub_input,' and  location="inside"',' ORDER BY elev DESC']);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mysql('close') 
 

elev=[Sel_elev; Sel_elev_ATTM; elev_Open];

SCF=[Sel_SCF; Sel_SCF_ATTM; SCF_Open];

curve=[Sel_curve; Sel_curve_ATTM; curve_Open];

Type_elem=[sel_type; sel_elem_type; type_open];



elev=-(elev-max(elev));



for mm=1:size(curve,1)
    if contains(curve{mm,1},'air')
      curve{mm,1}=curve{mm,1}(1:end-4);  
    elseif contains(curve{mm,1},'protected')
       curve{mm,1}=curve{mm,1}(1:end-10);           
    end     
end 









SCFSN_table=cell(size(elev,1),4);

SCFSN_table(:,1) = num2cell(elev);
SCFSN_table(:,2) = num2cell(SCF);
SCFSN_table(:,3)=curve;
SCFSN_table(:,4)=Type_elem;


SCFSN_table= sortrows(SCFSN_table,1,'ascend');
 
% % % % % SCFSN_table = 1;