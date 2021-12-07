function database_write_Fatigue(GE_Data,GE_SRD,Settings,A,DatabaseRev,locations,locLoop)
%--------------------------------------------------------------------------
% CHANGE LOG
% 2019.11.21    ASSV    Programming



%% Connect to database
%     if strcmp(type,'py')
%         disp('Exporting py-curves to database')
%     elseif strcmp(type,'tz')
%         disp('Exporting tz-curves to database')
%     end



% DatabaseRev.rev1.RNumber=1;
% DatabaseRev.rev1.rev_sub=1;
% DatabaseRev.rev1.Hammer_Conf=1;



DatabaseRev.rev_sub=DatabaseRev.rev1.rev_sub;


% % % % DatabaseRev.rev1.AnalysisofBLow='Red_HB';
% % % % DatabaseRev.rev1.AnalysisofStress='Red_HB_NN';
% % % % DatabaseRev.rev1.Switch=1;
% % % % DatabaseRev.Revname={'rev1'};
% % % %
% % % % DatabaseRev.rev1.AnalysisBlow=9;
% % % % DatabaseRev.rev1.AnalysisForce=10;

settings.db_server              ='DKLYCOPILOD1';  %  Databse server
settings.db_user                ='ao1db_user';    %   Database user
settings.db_pass                ='ituotdao1db';    % Database pass
settings.db_name                ='ao1db';    % Database name

table='ao1db.pda_input';

%%%%%%%EW
settings.db_server              ='DKLYCOPILOD1';  %  Databse server
settings.db_user                ='ewdb_user';    %   Database user
settings.db_pass                ='ituotdewdb';    % Database pass
settings.db_name                ='ewdb';    % Database name

table='ewdb.pda_input';

%%%%%PNGI Commmented at the moment since the database is not working
% % % % % % % % % %
% % % % % % % % % %
% % % % % % % % % %     % Access MySQL-database
mysql('close')
mysql('open',settings.db_server,settings.db_user,settings.db_pass); % ('open','server','username','password')
mysql(['use ',settings.db_name]); % name of database


for revnumber=1:size(DatabaseRev.Revname(:,3),1)
    
    
    revname=DatabaseRev.Revname{revnumber,3};
    data.revision.global=DatabaseRev.(revname).RNumber;
    data.revision.Sub_Rev=DatabaseRev.(revname).rev_sub;
    Sub_Rev=num2str(DatabaseRev.(revname).rev_sub);
    Switch=cell2mat(DatabaseRev.(revname).Switch);
    
    if Switch
        
        [DBtabletoWrite]=createDBOutput(GE_Data,GE_SRD,Settings,A,DatabaseRev,locations,locLoop,revnumber);
        
        %% Database unique id's - Verify revisions
        %--------------------------------------------------------------------------
        id = ['''',Settings.Database.LoadIterationName,locations{locLoop,1},'''']; % name of id
        if data.revision.global == -1 % saved results only if a global revision (configuration) is used
            disp('Global revision not specified - > SSI springs are saved into the database with data.revision.output')
            rev_global = data.revision.output; % global revision no. for specified id to be used
            rev_check = rev_global;
            % check, if specified global revision is available for specified id
            [rev]       = mysql(['select rev from ',table,' where id=',id]);
            if rev_global<10
                rev_global          = ['''0',num2str(rev_global),'''']; % revision no. to be used
            else
                rev_global          = ['''',num2str(rev_global),'''']; % revision no. to be used
            end
        else
            rev_global = data.revision.global; % global revision no. for specified id to be used
            % check, if specified global revision is available for specified id
            rev_check = rev_global;
            [rev]       = mysql(['select rev from ',table,' where id=',id]);
            if rev_global<10
                rev_global          = ['''0',num2str(rev_global),'''']; % revision no. to be used
            else
                rev_global          = ['''',num2str(rev_global),'''']; % revision no. to be used
            end
        end
        
        
        % if specified global revision exists for this id -> delete all
        % py-entries for this id and revision (necessary, if update of
        % py-curves shall be done using a different discretisation of pile):
        if ismember(rev_check,str2double(rev)) > 0
            mysqlstr = ['DELETE FROM ',table,' where id=',id,' and rev=',rev_global,' and rev_sub=''',Sub_Rev,''';'];
            mysql(mysqlstr);
        end
        
        
        
        %%%%%%%%PNGI
        
        
        
        
        %% Definining spring type values
        
        
        
        
        
        % % % % % %
        % % % % % %
        % % % % % %
        % % % % % %
        % % % % % %
        % % % % % %   if strcmp(type,'py')
        % % % % % %         spring.col_value = 'p_y_value';
        % % % % % %         spring.col_p = 'p';
        % % % % % %         spring.col_y = 'y';
        % % % % % %         spring.col_model = 'model_py';
        % % % % % %         spring.ncol = 20;
        % % % % % %     elseif strcmp(type,'tz')
        % % % % % %         spring.col_value = 't_z_value';
        % % % % % %         spring.col_p = 't';
        % % % % % %         spring.col_y = 'z';
        % % % % % %         spring.col_model = 'model_tz';
        % % % % % %         spring.ncol = 15;
        % % % % % %     end
        
        %% Correction for nodes with 2 springs
        % p_av is calculated as a weighted average with element thickness
        % between p.top and p.bottom when these two are different in the same node
        % due to a boundary between two different soil layers
        % % % % % %
        % % % % % %     p_av=zeros(length(p.top),length(p.top(1,:)));
        % % % % % %
        % % % % % %     for i =2:element.nelem-1
        % % % % % %         for j=1:length(p.top(1,:))
        % % % % % %             if p.top(i,j)<p.bottom(i-1,j)||p.top(i,j)>p.bottom(i-1,j)
        % % % % % %                 p_av(i,j) = (p.top(i,j).*(abs(element.level(i,2))-...
        % % % % % %                     abs(element.level(i,1)))+p.bottom(i-1,j).*...
        % % % % % %                     (abs(element.level(i,1))-abs(element.level(i-1,1))))...
        % % % % % %                     ./((abs(element.level(i,2))-abs(element.level(i,1)))...
        % % % % % %                     +(abs(element.level(i,1))-abs(element.level(i-1,1))));
        % % % % % %             else
        % % % % % %                 p_av(i,j) = p.top(i,j);
        % % % % % %             end
        % % % % % %         end
        % % % % % %     end
        
        %% Create strings and save top srpings until nelem-1
        for row =1:size(DBtabletoWrite,1)
            
            id = ['''',Settings.Database.LoadIterationName,DBtabletoWrite{row,1},''''];
            rev = rev_global;
            rev_sub = ['''',num2str(DBtabletoWrite{row,3}),''''];
            hammer_config = ['''',num2str(DBtabletoWrite{row,4}),''''];
            soil_prop = ['''',DBtabletoWrite{row,5},''''];
            penetration_depth = ['''',num2str(DBtabletoWrite{row,6}),''''];
            elev = ['''',num2str(DBtabletoWrite{row,7}),''''];
            blow_count = ['''',num2str(DBtabletoWrite{row,8}),''''];
            Max_force = ['''',num2str(DBtabletoWrite{row,9}),''''];
            Min_force = ['''',num2str(DBtabletoWrite{row,10}),''''];
            status = ['''',DBtabletoWrite{row,11},''''];
            responsible = ['''',DBtabletoWrite{row,12},''''];
            inserted_by = ['''',DBtabletoWrite{row,13},''''];
            timestamp = ['''',DBtabletoWrite{row,14},''''];
            % element top nodes
            % % %         depth              = abs(element.level(i,1));
            % % %         model_py                = element.model_py{i};
            % % %         stat_cycl               = loads.static_cyclic;
            % % %         value_p_top             = zeros(1,spring.ncol); % maximum of 20 p values is allowed
            % % %         value_y_top             = zeros(1,spring.ncol);
            % % %         value_p_top(1,1:size(p_av,2)) = p_av(i,:); % maximum of 20 p values is allowed
            % % %         value_y_top(1,1:size(y.top,2)) = y.top(i,:);
            
            % % % % % % % %     if strcmp(type,'py')
            mysqlstr_ini        = ['INSERT INTO ',table,'(id,rev,rev_sub',...
                ',hammer_config,soil_prop,penetration_depth,elev,blow_count,max_force,min_force,status,responsible,inserted_by)'...
                ,' VALUES (',...
                id,',',rev,',',rev_sub,',',hammer_config,',',soil_prop,',',penetration_depth,',',elev,',',blow_count,',',Max_force,',',Min_force,',',status,',',...
                responsible,',',inserted_by,');'];
            
            % % % % % % % %     elseif strcmp(type,'tz')
            % % % % % % % %             mysqlstr_ini        = ['INSERT INTO ',table,'(id,rev,depth,'...
            % % % % % % % %                    spring.col_value,',value1,value2,value3,value4,value5,value6,value7,value8,value9,value10,'...
            % % % % % % % %                     'value11,value12,value13,value14,value15,',spring.col_model,',stat_cycl) VALUES (',...
            % % % % % % % %                     id,',',...
            % % % % % % % %                     rev_global,',',...
            % % % % % % % %                     num2str(depth),','''];
            % % % % % % % %      end
            
            % insert p values
            % % % % % % % %         mysqlstr = [mysqlstr_ini,spring.col_p,''''];
            % % % % % % % %         for j = 1:spring.ncol % p_top_values
            % % % % % % % %             mysqlstr = [mysqlstr,',',num2str(value_p_top(1,j))]; %#ok<*AGROW>
            % % % % % % % %         end
            % % % % % % % %         mysqlstr_ptop = [mysqlstr,',''',model_py,''',''', stat_cycl,''');'];
            % % % % % % % %
            % % % % % % % %         % y_top values
            % % % % % % % %         mysqlstr = [mysqlstr_ini,spring.col_y,''''];
            % % % % % % % %         for j = 1:spring.ncol
            % % % % % % % %             mysqlstr = [mysqlstr,',',num2str(value_y_top(1,j))];
            % % % % % % % %         end
            % % % % % % % %         mysqlstr_ytop = [mysqlstr,',''',model_py,''',''', stat_cycl,''');'];
            
            mysql(mysqlstr_ini);
            % % % % % % % % %         mysql(mysqlstr_ytop);
        end
        % % % % % % % % %     %% Create strings and save bot srpings for last element
        % % % % % % % % %     depth_2              = abs(element.level(length(element.level)-1,2));
        % % % % % % % % %     model_py                = element.model_py{length(element.level)-1};
        % % % % % % % % %     stat_cycl               = loads.static_cyclic;
        % % % % % % % % %     value_p_bot             = zeros(1,spring.ncol);
        % % % % % % % % %     value_y_bot             = zeros(1,spring.ncol);
        % % % % % % % % %     value_p_bot(1,1:size(p.bottom,2)) = p.bottom(length(p.bottom),:);
        % % % % % % % % %     value_y_bot(1,1:size(y.bottom,2)) = y.bottom(length(y.bottom),:);
        % % % % % % % % %
        % % % % % % % % %     if strcmp(type,'py')
        % % % % % % % % %         mysqlstr_ini        = ['INSERT INTO ',table,'(id,rev,depth,'...
        % % % % % % % % %                spring.col_value,',value1,value2,value3,value4,value5,value6,value7,value8,value9,value10,'...
        % % % % % % % % %                 'value11,value12,value13,value14,value15,value16,value17,value18,value19,value20,',spring.col_model,',stat_cycl) VALUES (',...
        % % % % % % % % %                 id,',',...
        % % % % % % % % %                 rev_global,',',...
        % % % % % % % % %                 num2str(depth_2),','''];
        % % % % % % % % %     elseif strcmp(type,'tz')
        % % % % % % % % %         mysqlstr_ini        = ['INSERT INTO ',table,'(id,rev,depth,'...
        % % % % % % % % %                spring.col_value,',value1,value2,value3,value4,value5,value6,value7,value8,value9,value10,'...
        % % % % % % % % %                 'value11,value12,value13,value14,value15,',spring.col_model,',stat_cycl) VALUES (',...
        % % % % % % % % %                 id,',',...
        % % % % % % % % %                 rev_global,',',...
        % % % % % % % % %                 num2str(depth_2),','''];
        % % % % % % % % %     end
        % % % % % % % % %     % insert p values
        % % % % % % % % %     mysqlstr = [mysqlstr_ini,spring.col_p,''''];
        % % % % % % % % %     for j = 1:spring.ncol % p_top_values
        % % % % % % % % %         mysqlstr = [mysqlstr,',',num2str(value_p_bot(1,j))];
        % % % % % % % % %     end
        % % % % % % % % %     mysqlstr_pbot = [mysqlstr,',''',model_py,''',''', stat_cycl,''');'];
        % % % % % % % % %
        % % % % % % % % %     % y_top values
        % % % % % % % % %     mysqlstr = [mysqlstr_ini,spring.col_y,''''];
        % % % % % % % % %     for j = 1:spring.ncol
        % % % % % % % % %         mysqlstr = [mysqlstr,',',num2str(value_y_bot(1,j))];
        % % % % % % % % %     end
        % % % % % % % % %     mysqlstr_ybot = [mysqlstr,',''',model_py,''',''', stat_cycl,''');'];
        % % % % % % % % %
        % % % % % % % % %     mysql(mysqlstr_pbot);
        % % % % % % % % %     mysql(mysqlstr_ybot);
        % Close MySQL-database
        
    end
end

mysql('close')
%     if strcmp(type,'py')
disp('Finished exporting Fatigue input')
%     elseif strcmp(type,'tz')
%         disp('Finished exporting tz-curves')
%     end
end
