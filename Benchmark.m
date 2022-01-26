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
catch 
    cprintf('red','Benchmarking failed ! \n')  
end

%% Compare files
% Input check - .GWT files 
fid = fopen('Benchmark_UB_4000\ref_EW1_OSS_35_JBenchmark_UB_4000_49.txt','r');  % open the text file
new = textscan(fid,'%s');   % text scan the data
fclose(fid);      % close the file
new = new{1};
load('benchmark\reference.mat');

for i = 1:size(reference,1)
    check{i,1} = reference{i} - new{i};
    check_2(i,1) = max(check{i,1});
end
input_check = max(check_2);

% Postprocess check - SOD Output table
analysis_name='ref_EW1_OSS_35_J_Benchmark_UB_4000';
matfilename1=['output\',analysis_name,'.mat'];
inp0=load(matfilename1);
SOD=inp0.(analysis_name).SRD.SOD;
Header1={'depth','total SRD','SRD skin','SRD toe','blow count','compressive sig_max','tensile sig_max','stroke','Enthru','blow count'};
SOD_ref=readmatrix('Benchmark/output_ref.xlsx');
str_length=cellfun(@(x) length(x),Header1); max_str_length=max(str_length);
Header1_space_padded={};
for ii=1:length(Header1)
    var1=Header1{ii};
    N_spaces= max_str_length-length(var1);
    Header1_space_padded{ii}=[var1,repmat(' ',1, N_spaces)];
end

%% Restore previous CODRIVE input excels
if exist('Input\temp','dir')
    movefile('Input\temp\PDAcalc.xlsx'     , 'Input','f')   % move codrive excel file from temp folder to original folder
    movefile('Input\temp\Soil2GRLWEAP.xlsx', 'Input','f')   % move codrive excel file from temp folder to original folder
    rmdir('Input\temp')
end

%% Messages to the user
% input check
if input_check == 0
    cprintf('green','benchmarking of .gwt file is OK \n');
else
    cprintf('red','benchmarking of .gwt file is NOT OK \n');
end

% postprocess_check
for ii=1:length(Header1)
    if isequal(SOD_ref(:,ii),SOD(:,ii))
        cprintf('green', ['The computed ',Header1_space_padded{ii}, ' matches with the benchmark. OK \n']);
    else
        cprintf('red',   ['The computed ',Header1_space_padded{ii}, ' does not match with the benchmark. NOT OK \n']);
    end
end

% Final message
cprintf('black','Benchmarking for CODRIVE is complete \n');
cprintf('black','---------------------------------------------------------------------- \n');
