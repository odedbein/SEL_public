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
resultsdir='results_pairsRep_smt_norm_msessions';% results folder in each individual subject
contrasts_file='contrasts_SEL2_pairsRep.csv'; % contrasts csv file; located in basedir
onsetsdir='onsets';
deleteold=1; %1 = delete old contrasts; 0 = keep old contrasts
nsessions=4; % number of sessions per subject
nconds=5; % number of conditions per subject Famous,NonFamous,TaskFamous,TaskNonFamous,trash


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

cond_names = {... % array of all contrasts names; this is the way they will appear in the results menu;
'FamousAndNonFamousAll',...
'Famous',...
'Nonfamous',...
'Famous_Nonfamous',...
'Nonfamous_Famous',...
'Famous1',...
'NonFamous1',...
'Famous123',...
'NonFamous123',...
'FamousLinDecrease',...
'NonFamousLinDecrease',...
'FamousExpDecreaseNatlog',...
'NonFamousExpDecreaseNatlog',...
'FamousExpDecrease2PowerRep',...
'NonFamousExpDecrease2PowerRep',...
};

Famous1=[1 zeros(1,11); zeros(1,12); zeros(1,12); zeros(1,12)];
NonFamous1=[0 0 0 0 0 0 1 0 0 0 0 0; zeros(1,12); zeros(1,12); zeros(1,12)];
Famous123=[1 0 1 0 1 0 zeros(1,6); zeros(1,12); zeros(1,12); zeros(1,12)];
NonFamous123=[zeros(1,6) 1 0 1 0 1 0; zeros(1,12); zeros(1,12); zeros(1,12)];

%preparing the linear decrease regresssor
LinDecrease=[12:-1:1]-mean(12:-1:1);
FamousLinDecrease=[];
NonFamousLinDecrease=[];
for i=1:nsessions
    FamousLinDecreaseCurrSess=[LinDecrease((i-1)*3+1) 0 LinDecrease((i-1)*3+2) 0 LinDecrease((i-1)*3+3) 0 zeros(1,6)];
    NonFamousLinDecreaseCurrSess=[zeros(1,6) LinDecrease((i-1)*3+1) 0 LinDecrease((i-1)*3+2) 0 LinDecrease((i-1)*3+3) 0];
    FamousLinDecrease=[FamousLinDecrease;FamousLinDecreaseCurrSess];
    NonFamousLinDecrease=[NonFamousLinDecrease;NonFamousLinDecreaseCurrSess];
end

%preparing the natural log exponential decay regresssor
ExpDecay=-log(1:1:12)-mean(-log(1:1:12));
FamousExpDecreaseNatlog=[];
NonFamousExpDecreaseNatlog=[];
for i=1:nsessions
    FamousExpDecreaseCurrSess=[ExpDecay((i-1)*3+1) 0 ExpDecay((i-1)*3+2) 0 ExpDecay((i-1)*3+3) 0 zeros(1,6)];
    NonFamousExpDecreaseCurrSess=[zeros(1,6) ExpDecay((i-1)*3+1) 0 ExpDecay((i-1)*3+2) 0 ExpDecay((i-1)*3+3) 0];
    FamousExpDecreaseNatlog=[FamousExpDecreaseNatlog;FamousExpDecreaseCurrSess];
    NonFamousExpDecreaseNatlog=[NonFamousExpDecreaseNatlog;NonFamousExpDecreaseCurrSess];
end

%preparing the 2^rep exponential decay regresssor
ExpDecay=((2.^(12:-1:1))-mean(2.^(12:-1:1)))/1000;
FamousExpDecrease2PowerRep=[];
NonFamousExpDecrease2PowerRep=[];

for i=1:nsessions
    FamousExpDecreaseCurrSess=[ExpDecay((i-1)*3+1) 0 ExpDecay((i-1)*3+2) 0 ExpDecay((i-1)*3+3) 0 zeros(1,6)];
    NonFamousExpDecreaseCurrSess=[zeros(1,6) ExpDecay((i-1)*3+1) 0 ExpDecay((i-1)*3+2) 0 ExpDecay((i-1)*3+3) 0];
    FamousExpDecrease2PowerRep=[FamousExpDecrease2PowerRep;FamousExpDecreaseCurrSess];
    NonFamousExpDecrease2PowerRep=[NonFamousExpDecrease2PowerRep;NonFamousExpDecreaseCurrSess];
end

add_con_mat=zeros(10,12,nsessions);

for i=1:nsessions
    add_con_mat(1,:,i)=Famous1(i,:);
    add_con_mat(2,:,i)=NonFamous1(i,:);
    add_con_mat(3,:,i)=Famous123(i,:);
    add_con_mat(4,:,i)=NonFamous123(i,:);
    add_con_mat(5,:,i)=FamousLinDecrease(i,:);
    add_con_mat(6,:,i)=NonFamousLinDecrease(i,:);
    add_con_mat(7,:,i)=FamousExpDecreaseNatlog(i,:);
    add_con_mat(8,:,i)=NonFamousExpDecreaseNatlog(i,:);
    add_con_mat(9,:,i)=FamousExpDecrease2PowerRep(i,:);
    add_con_mat(10,:,i)=NonFamousExpDecrease2PowerRep(i,:);
end

nConts = length(cond_names);

%**************************************************************************
%EXECUTION
%**************************************************************************

con_mat_temp=load(fullfile(basedir,contrasts_file));%('contrasts.csv');
WD = basedir;

spm('Defaults','fMRI');
spm_jobman('initcfg');

for s = 1:nSubs
    subj_path=fullfile(basedir,subs{s}); % define current subject
    %for the task items, each subject sometimes have no items in a
    %repetition, so need to zero pad based on that
    con_mat=[];
    for sess=1:nsessions
    sub_onsets_file=fullfile(subj_path,onsetsdir,sprintf('onsets_SEL2_pairsRep_sess%d.mat',sess));
    load(sub_onsets_file,'names');
    con_mat_singleSess=[con_mat_temp; add_con_mat(:,:,sess)];
    con_mat_singleSess=[con_mat_singleSess zeros(size(con_mat_singleSess,1),numel(names)*2-size(con_mat_temp,2))];
    con_mat=[con_mat con_mat_singleSess];
    end
    
    for c = 1:nConts
        jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(subj_path,resultsdir,'SPM.mat'));
        jobs{1}.stats{1}.con.consess{c}.tcon.name = cond_names{c};
        jobs{1}.stats{1}.con.consess{c}.tcon.convec = con_mat(c , :);
        jobs{1}.stats{1}.con.consess{c}.tcon.sessrep = 'none';
        jobs{1}.stats{1}.con.delete = deleteold;
    end;
    spm_jobman('run',jobs);

end

clear all

