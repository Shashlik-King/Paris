%% BENCHMARKING
% Script comparing the benchmark model of the original version to the checked out version from the repo
clc; close all; clear;
cprintf('black','Benchmarking initiated \n');
cprintf('black','---------------------------------------------------------------------- \n');

%% Run codrive RunMe.m of the new version

if exist('Input\PDAcalc.xlsx','file') && exist('Input\Soil2GRLWEAP.xlsx','file')
    warning('off','MATLAB:MKDIR:DirectoryExists'); mkdir('Input\temp');
    movefile('Input\PDAcalc.xlsx'     , 'Input\temp','f')   % move codrive excel file to a temporary folder
    movefile('Input\Soil2GRLWEAP.xlsx', 'Input\temp','f')   % move codrive excel file to a temporary folder
else
    cprintf('black','Input folder does not contain all of CODRIVE excel interfaces!')
end

copyfile('Benchmark\PDAcalc_ref.xlsx'     , 'Input\PDAcalc.xlsx','f')        % move codrive reference excel files to input folder
copyfile('Benchmark\Soil2GRLWEAP_ref.xlsx', 'Input\Soil2GRLWEAP.xlsx','f')   % move codrive reference excel files to input folder


try
    
    RunMe(); % run codrive
    
    %% Comparison of the reference output to the computed output
    
    analysis_name='ref_EW1_OSS_35_J_Benchmark_UB_4000';
    matfilename1=['output\',analysis_name,'.mat'];
    inp0=load(matfilename1);
    
    SOD=inp0.(analysis_name).SRD.SOD;
    
    Header1={'depth','total SRD','SRD skin','SRD toe','blow count','compressive sig_max','tensile sig_max','stroke','Enthru','blow count'};
    %writecell([Header1;num2cell(SOD)],'Benchmark/output_ref.xlsx');
    
    
    % References values
    SOD_ref=readmatrix('Benchmark/output_ref.xlsx');
    
    str_length=cellfun(@(x) length(x),Header1); max_str_length=max(str_length);
    Header1_space_padded={};
    for ii=1:length(Header1)
        var1=Header1{ii};
        N_spaces= max_str_length-length(var1);
        Header1_space_padded{ii}=[var1,repmat(' ',1, N_spaces)];
    end
    
    for ii=1:length(Header1)
        
        if isequal(SOD_ref(:,ii),SOD(:,ii))
            cprintf('green', ['The computed ',Header1_space_padded{ii}, ' matches with the benchmark. OK \n']);
        else
            cprintf('red',   ['The computed ',Header1_space_padded{ii}, ' does not match with the benchmark. NOT OK \n']);
        end
        
    end
    
catch
    
    cprintf('red',['Benchmarking failed ! '])
    
end


if exist('Input\temp','dir')
    movefile('Input\temp\PDAcalc.xlsx'     , 'Input','f')   % move codrive excel file from temp folder to original folder
    movefile('Input\temp\Soil2GRLWEAP.xlsx', 'Input','f')   % move codrive excel file from temp folder to original folder
    rmdir('Input\temp')
end

cprintf('black','Benchmarking for CODRIVE is complete \n');
cprintf('black','---------------------------------------------------------------------- \n');
