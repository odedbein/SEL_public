%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PRE SIMILARITY

%**************************************************************************
% DEFINITIONS - MAKE SURE EVERYTHING IS IN ORDER! (all the way down to execution)
% This script takes contrasts matrix from a file and adjusts it for use in
% multiple session design
%
% MAKE SURE nubmer of names cond_names IS IDENTICAL to number of contrasts rows in contrasts.csv
%
% compiled by Niv Reggev, 20.09.2012;
% Last modified: 08.04.2014
%**************************************************************************
clear all;
basedir = 'C:\fMRI_Data\SEL2\ANALYSIS_SPM8\';% Root location of analysis folder
resultsdir='results_PREsimilarity_unnormalized_smoothed';% results folder in each individual subject
onsetsdir='onsets';
deleteold=0; %1 = delete old contrasts; 0 = keep old contrasts
num_all_reg=266;%all regressors
num_items=48;%number of experimental items 
nsessions=2; %number of sessions
num_all_items=66;%all items in the experiment


subs= {...
    '200615TF';...
     '230615ZD';...
     '230615EF';...
     '230615RE';...
     '270615SA';...
     '270615NK';...
     '270615RP';...
     '110715DA';...
     '110715YB';...
     '110715YL';...
       '240715TP';...
       '250715LK';...
       '250715AG';...
       '250715EB';...
       '080815EF';...
       '080815LR';...
       '080815RM';...
       '080815TN';...
       '110815EZ';...
    }; 


nSubs=length(subs);


con_mat=diag(ones(num_all_reg,1)); %create a contrasts matrix
con_mat(:,2:2:num_all_reg)=0; %null all the time derivatives
con_mat(:,(num_items*2)+1:(num_all_items*2))=0;%null the regressors of the task-faces, session 1;
con_mat(:,(num_all_items*2)+(num_items*2)+1:end)=0; %null the regressors of the task-faces, session 2, and the constant session-specific regressors.
con_mat=con_mat([1:2:num_items*2 (num_all_items*2)+1:2:(num_all_items*2)+num_items*2],:);

nConts = size(con_mat,1);

%**************************************************************************
%EXECUTION
%**************************************************************************

%con_mat_temp=load(fullfile(basedir,contrasts_file));%('contrasts.csv');
WD = basedir;

spm('Defaults','fMRI');
spm_jobman('initcfg');

for s = 1:nSubs
    subj_path=fullfile(basedir,subs{s}); % define current subject
    
    for c = 1:nConts
        jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(subj_path,resultsdir,'SPM.mat'));
        jobs{1}.stats{1}.con.consess{c}.tcon.name = num2str(c);
        jobs{1}.stats{1}.con.consess{c}.tcon.convec = con_mat(c , :);
        jobs{1}.stats{1}.con.consess{c}.tcon.sessrep = 'none';
        jobs{1}.stats{1}.con.delete = deleteold;
    end;
    spm_jobman('run',jobs);

end

clear all

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%POST SIMILARITY
%**************************************************************************
% DEFINITIONS - MAKE SURE EVERYTHING IS IN ORDER! (all the way down to execution)
% This script takes contrasts matrix from a file and adjusts it for use in
% multiple session design
%
% MAKE SURE nubmer of names cond_names IS IDENTICAL to number of contrasts rows in contrasts.csv
%
% compiled by Niv Reggev, 20.09.2012;
% Last modified: 08.04.2014
%**************************************************************************

basedir = 'C:\fMRI_Data\SEL2\ANALYSIS_SPM8\';% Root location of analysis folder
resultsdir='results_POSTsimilarity_unnormalized_smoothed';% results folder in each individual subject
onsetsdir='onsets';
deleteold=0; %1 = delete old contrasts; 0 = keep old contrasts
num_all_reg=266;%all regressors
num_items=48;%number of experimental items 
nsessions=2; %number of sessions
num_all_items=66;%all items in the experiment


subs= {...
    '200615TF';...
     '230615ZD';...
     '230615EF';...
     '230615RE';...
     '270615SA';...
     '270615NK';...
     '270615RP';...
     '110715DA';...
     '110715YB';...
     '110715YL';...
       '240715TP';...
       '250715LK';...
       '250715AG';...
       '250715EB';...
       '080815EF';...
       '080815LR';...
       '080815RM';...
       '080815TN';...
       '110815EZ';...
    }; 
nSubs=length(subs);


con_mat=diag(ones(num_all_reg,1)); %create a contrasts matrix
con_mat(:,2:2:num_all_reg)=0; %null all the time derivatives
con_mat(:,(num_items*2)+1:(num_all_items*2))=0;%null the regressors of the task-faces, session 1;
con_mat(:,(num_all_items*2)+(num_items*2)+1:end)=0; %null the regressors of the task-faces, session 2, and the constant session-specific regressors.
con_mat=con_mat([1:2:num_items*2 (num_all_items*2)+1:2:(num_all_items*2)+num_items*2],:);

nConts = size(con_mat,1);

%**************************************************************************
%EXECUTION
%**************************************************************************

%con_mat_temp=load(fullfile(basedir,contrasts_file));%('contrasts.csv');
WD = basedir;

spm('Defaults','fMRI');
spm_jobman('initcfg');

for s = 1:nSubs
    subj_path=fullfile(basedir,subs{s}); % define current subject
    
    for c = 1:nConts
        jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(subj_path,resultsdir,'SPM.mat'));
        jobs{1}.stats{1}.con.consess{c}.tcon.name = num2str(c);
        jobs{1}.stats{1}.con.consess{c}.tcon.convec = con_mat(c , :);
        jobs{1}.stats{1}.con.consess{c}.tcon.sessrep = 'none';
        jobs{1}.stats{1}.con.delete = deleteold;
    end;
    spm_jobman('run',jobs);

end
 clear all;
