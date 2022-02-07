function database_write_Fatigue(GE_Data,GE_SRD,Settings,A,DatabaseRev,locations,locLoop)
%--------------------------------------------------------------------------
% CHANGE LOG
% 2019.11.21    ASSV    Programming
DatabaseRev.rev_sub=DatabaseRev.rev1.rev_sub;

settings.db_server              = Settings.Database.Server;  %  Databse server
settings.db_user                = Settings.Database.Username;    %   Database user
settings.db_pass                = Settings.Database.Password;    % Database pass
settings.db_name                = Settings.Database.DBname;    % Database name
table                           = Settings.Database.Table;

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
        
        if ismember(rev_check,str2double(rev)) > 0
            mysqlstr = ['DELETE FROM ',table,' where id=',id,' and rev=',rev_global,' and rev_sub=''',Sub_Rev,''';'];
            mysql(mysqlstr);
        end

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
            mysqlstr_ini        = ['INSERT INTO ',table,'(id,rev,rev_sub',...
                ',hammer_config,soil_prop,penetration_depth,elev,blow_count,max_force,min_force,status,responsible,inserted_by)'...
                ,' VALUES (',...
                id,',',rev,',',rev_sub,',',hammer_config,',',soil_prop,',',penetration_depth,',',elev,',',blow_count,',',Max_force,',',Min_force,',',status,',',...
                responsible,',',inserted_by,');'];
            mysql(mysqlstr_ini);
        end
    end
end
mysql('close')
disp('Finished exporting Fatigue input')
end
