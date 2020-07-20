
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
clear all

%% MODEL SIMILARITY

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CLASSICAL STATISTICAL ANALYSIS (CATEGORICAL)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE SURE ALL DEFINITIONS ARE IN ORDER
%
%
%**************************************************************************
%DEFINITIONS
%**************************************************************************
% 
basedir = 'C:\fMRI_Data\SEL2\ANALYSIS_SPM8\';% Root location of analysis folder
%funcdir = 'bold'; % Location of functional runs directories
%templdir='templates'; % Location of template files
resultsdir='results_PREsimilarity_unnormalized_msessions';
onsetdir='onsets';
%onset='onsets_RS1_2_10bins.mat';
%ntp=400;

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

filefilter = '^ra.*\.nii';%'^swra.*\.nii'; % '^s.*\.img'; % pre-processed images

runs 			= 	{... % Make sure all functional runs are included here
'Similarity1';...
'Similarity2';...
};

nRuns = length(runs);

runs_onsets 			= 	{...
    'onsets_SEL2_sim_similarity_sess1';...
    'onsets_SEL2_sim_similarity_sess2';...
    };

%**************************************************************************
%INITIALIZATION
%**************************************************************************

spm('Defaults','fMRI');
spm_jobman('initcfg');

WD=basedir;

for s = 1:nSubs % set up subjects & runs folders
    for r = 1:nRuns
        sub_dir = subs{s};
        run_dir = runs{r};
        %sub{s}.run{r} = fullfile(basedir,sprintf('%s\\%s\\%s',sub_dir,funcdir,run_dir));
        sub{s}.run{r} = fullfile(basedir,sprintf('%s\\%s',sub_dir,run_dir));
    end
end

% regressors for combining 2 sessions into 1

%r1      = [linspace(-1,1,ntp), zeros(1,ntp), zeros(1,ntp), zeros(1,ntp)];
%r2      = [zeros(1,ntp), linspace(-1,1,ntp), zeros(1,ntp), zeros(1,ntp)];
%r3      = [zeros(1,ntp), zeros(1,ntp), linspace(-1,1,ntp), zeros(1,ntp)];
%r4      = [zeros(1,ntp), zeros(1,ntp), zeros(1,ntp), linspace(-1,1,ntp)];
%r5      = [ones(1,ntp), zeros(1,ntp), zeros(1,ntp), zeros(1,ntp)];
%r6      = [zeros(1,ntp), ones(1,ntp), zeros(1,ntp), zeros(1,ntp)];
%r7      = [zeros(1,ntp), zeros(1,ntp), ones(1,ntp), zeros(1,ntp)];
%r8      = [zeros(1,ntp), zeros(1,ntp), zeros(1,ntp), ones(1,ntp)];

%R = [r1; r2; r3; r4]';%; r5; r6; r7; r8]' ;
%reg_names ={'Highpass01'; 'Highpass02'; 'Highpass03'; 'Highpass04'}; %'sess1'; 'sess2'; 'sess3'; 'sess4'};
%reg_mat='multisessionregsred.mat';
%save(fullfile(basedir,reg_mat),'R');

for s = 1:nSubs
    %data_path=fullfile(basedir,subs{s},funcdir); % Path containing data
    data_path=fullfile(basedir,subs{s}); % Path containing data
    subj_path=fullfile(basedir,subs{s});

    %% OUTPUT DIRECTORY
    %--------------------------------------------------------------------------
    clear jobs
    jobs{1}.util{1}.md.basedir = cellstr(subj_path);
    jobs{1}.util{1}.md.name = resultsdir;


    %% MODEL SPECIFICATION AND ESTIMATION
    %--------------------------------------------------------------------------
    jobs{2}.stats{1}.fmri_spec.dir = cellstr(fullfile(subj_path,resultsdir));
    jobs{2}.stats{1}.fmri_spec.timing.units = 'secs';
    jobs{2}.stats{1}.fmri_spec.timing.RT = 2;
    jobs{2}.stats{1}.fmri_spec.timing.fmri_t = 16;
    jobs{2}.stats{1}.fmri_spec.timing.fmri_t0 = 1;
    jobs{2}.stats{1}.fmri_spec.volt = 1;
    jobs{2}.stats{1}.fmri_spec.global = 'None';
    jobs{2}.stats{1}.fmri_spec.cvi = 'none'; % intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
    jobs{2}.stats{1}.fmri_spec.bases.hrf.derivs = [1 0]; % 1st number - time derivative; 2nd number - dispersion derivative
    %jobs{2}.stats{1}.fmri_spec.sess.multi_reg = {fullfile(basedir,reg_mat)};% Load previously defined multiple regressors
    %jobs{2}.stats{1}.fmri_spec.sess.hpf = 128;


    %% Load onsets - single session
    %--------------------------------------------------------------------------

%    for r=1 : length(runs)
%        if r > 1 
%            jobs{2}.stats{1}.fmri_spec.sess.scans =[jobs{2}.stats{1}.fmri_spec.sess.scans;cellstr(spm_select('FPList',sub{s}.run{r},filefilter))];%
%        else
%            jobs{2}.stats{1}.fmri_spec.sess.scans =cellstr(spm_select('FPList',sub{s}.run{r},filefilter));%
%        end
%    end
%    
%    jobs{2}.stats{1}.fmri_spec.sess.multi = cellstr(fullfile(subj_path,onsetdir,onset)); % Load onsets matrix 

    %% Load onsets - for multiple sessions!

    for r = 1:nRuns
        onsets    = load(fullfile(subj_path,onsetdir,runs_onsets{r}));

        jobs{2}.stats{1}.fmri_spec.sess(1,r).hpf = 128;
        jobs{2}.stats{1}.fmri_spec.sess(1,r).scans =cellstr(spm_select('FPList',sub{s}.run{r},filefilter));
        for i=1:numel(onsets.names)
            jobs{2}.stats{1}.fmri_spec.sess(1,r).cond(i).name = onsets.names{i};
            jobs{2}.stats{1}.fmri_spec.sess(1,r).cond(i).onset = onsets.onsets{i};
            jobs{2}.stats{1}.fmri_spec.sess(1,r).cond(i).duration = onsets.durations{i};
        end
    end

    %% Model estimation
    %--------------------------------------------------------------------------
    jobs{2}.stats{2}.fmri_est.spmmat = cellstr(fullfile(subj_path,resultsdir,'SPM.mat'));
    save(fullfile(subj_path,'results_PREsimilarity_unnormalized_msessions.mat'),'jobs');

    %% INFERENCE
    %--------------------------------------------------------------------------
    %jobs{2}.stats{3}.results.spmmat = cellstr(fullfile(data_path,'categorical','SPM.mat'));
    %jobs{2}.stats{3}.results.conspec(1).contrasts = Inf;
    %jobs{2}.stats{3}.results.conspec(1).threshdesc = 'FWE';

    %jobs{2}.stats{4}.results.spmmat = cellstr(fullfile(data_path,'categorical','SPM.mat'));
    %jobs{2}.stats{4}.results.conspec(1).titlestr = 'main effect of Rep (masked [incl.] by ...)';
    %jobs{2}.stats{4}.results.conspec(1).contrasts = 3;
    %jobs{2}.stats{4}.results.conspec(1).threshdesc = 'none';
    %jobs{2}.stats{4}.results.conspec(1).thresh = 0.001;
    %jobs{2}.stats{4}.results.conspec(1).extent = 0;
    %jobs{2}.stats{4}.results.conspec(1).mask.contrasts = 5;
    %jobs{2}.stats{4}.results.conspec(1).mask.thresh = 0.001;
    %jobs{2}.stats{4}.results.conspec(1).mask.mtype = 0;

    %jobs{2}.stats{5}.con.spmmat = cellstr(fullfile(data_path,'categorical','SPM.mat'));
    %jobs{2}.stats{5}.con.consess{1}.fcon.name = 'Movement-related effects';
    %fcont = [zeros(6,3*4) eye(6)];
    %for i=1:size(fcont,1)
    %	jobs{2}.stats{5}.con.consess{1}.fcon.convec{1,i} = fcont(i,:);
    %end
    %jobs{2}.stats{6}.results.spmmat = cellstr(fullfile(data_path,'categorical','SPM.mat'));
    %jobs{2}.stats{6}.results.conspec(1).contrasts = 17;
    %jobs{2}.stats{6}.results.conspec(1).threshdesc = 'FWE';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% RUN
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %save('face_batch_categorical.mat','jobs');
    %spm_jobman('interactive',jobs);
    spm_jobman('run',jobs);

end

clear all;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%POST LEARNING SIMILARITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% MODEL SIMILARITY

%**************************************************************************
%DEFINITIONS
%**************************************************************************

basedir = 'C:\fMRI_Data\SEL2\ANALYSIS_SPM8\';% Root location of analysis folder
%funcdir = 'bold'; % Location of functional runs directories
%templdir='templates'; % Location of template files
resultsdir='results_POSTsimilarity_unnormalized_msessions';
onsetdir='onsets';
%onset='onsets_RS1_2_10bins.mat';
%ntp=400;
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

filefilter = '^ra.*\.nii';%'^swra.*\.nii'; % '^s.*\.img'; % pre-processed images

runs 			= 	{... % Make sure all functional runs are included here
'Similarity3';...
'Similarity4';...
};

nRuns = length(runs);

runs_onsets 			= 	{...
    'onsets_SEL2_sim_similarity_sess3';...
    'onsets_SEL2_sim_similarity_sess4';...
    };

%**************************************************************************
%INITIALIZATION
%**************************************************************************

spm('Defaults','fMRI');
spm_jobman('initcfg');

WD=basedir;

for s = 1:nSubs % set up subjects & runs folders
    for r = 1:nRuns
        sub_dir = subs{s};
        run_dir = runs{r};
        %sub{s}.run{r} = fullfile(basedir,sprintf('%s\\%s\\%s',sub_dir,funcdir,run_dir));
        sub{s}.run{r} = fullfile(basedir,sprintf('%s\\%s',sub_dir,run_dir));
    end
end

% regressors for combining 2 sessions into 1

%r1      = [linspace(-1,1,ntp), zeros(1,ntp), zeros(1,ntp), zeros(1,ntp)];
%r2      = [zeros(1,ntp), linspace(-1,1,ntp), zeros(1,ntp), zeros(1,ntp)];
%r3      = [zeros(1,ntp), zeros(1,ntp), linspace(-1,1,ntp), zeros(1,ntp)];
%r4      = [zeros(1,ntp), zeros(1,ntp), zeros(1,ntp), linspace(-1,1,ntp)];
%r5      = [ones(1,ntp), zeros(1,ntp), zeros(1,ntp), zeros(1,ntp)];
%r6      = [zeros(1,ntp), ones(1,ntp), zeros(1,ntp), zeros(1,ntp)];
%r7      = [zeros(1,ntp), zeros(1,ntp), ones(1,ntp), zeros(1,ntp)];
%r8      = [zeros(1,ntp), zeros(1,ntp), zeros(1,ntp), ones(1,ntp)];

%R = [r1; r2; r3; r4]';%; r5; r6; r7; r8]' ;
%reg_names ={'Highpass01'; 'Highpass02'; 'Highpass03'; 'Highpass04'}; %'sess1'; 'sess2'; 'sess3'; 'sess4'};
%reg_mat='multisessionregsred.mat';
%save(fullfile(basedir,reg_mat),'R');

for s = 1:nSubs
    %data_path=fullfile(basedir,subs{s},funcdir); % Path containing data
    data_path=fullfile(basedir,subs{s}); % Path containing data
    subj_path=fullfile(basedir,subs{s});

    %% OUTPUT DIRECTORY
    %--------------------------------------------------------------------------
    clear jobs
    jobs{1}.util{1}.md.basedir = cellstr(subj_path);
    jobs{1}.util{1}.md.name = resultsdir;


    %% MODEL SPECIFICATION AND ESTIMATION
    %--------------------------------------------------------------------------
    jobs{2}.stats{1}.fmri_spec.dir = cellstr(fullfile(subj_path,resultsdir));
    jobs{2}.stats{1}.fmri_spec.timing.units = 'secs';
    jobs{2}.stats{1}.fmri_spec.timing.RT = 2;
    jobs{2}.stats{1}.fmri_spec.timing.fmri_t = 16;
    jobs{2}.stats{1}.fmri_spec.timing.fmri_t0 = 1;
    jobs{2}.stats{1}.fmri_spec.volt = 1;
    jobs{2}.stats{1}.fmri_spec.global = 'None';
    jobs{2}.stats{1}.fmri_spec.cvi = 'none'; % intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
    jobs{2}.stats{1}.fmri_spec.bases.hrf.derivs = [1 0]; % 1st number - time derivative; 2nd number - dispersion derivative
    %jobs{2}.stats{1}.fmri_spec.sess.multi_reg = {fullfile(basedir,reg_mat)};% Load previously defined multiple regressors
    %jobs{2}.stats{1}.fmri_spec.sess.hpf = 128;


    %% Load onsets - single session
    %--------------------------------------------------------------------------

%    for r=1 : length(runs)
%        if r > 1 
%            jobs{2}.stats{1}.fmri_spec.sess.scans =[jobs{2}.stats{1}.fmri_spec.sess.scans;cellstr(spm_select('FPList',sub{s}.run{r},filefilter))];%
%        else
%            jobs{2}.stats{1}.fmri_spec.sess.scans =cellstr(spm_select('FPList',sub{s}.run{r},filefilter));%
%        end
%    end
%    
%    jobs{2}.stats{1}.fmri_spec.sess.multi = cellstr(fullfile(subj_path,onsetdir,onset)); % Load onsets matrix 

    %% Load onsets - for multiple sessions!

    for r = 1:nRuns
        onsets    = load(fullfile(subj_path,onsetdir,runs_onsets{r}));

        jobs{2}.stats{1}.fmri_spec.sess(1,r).hpf = 128;
        jobs{2}.stats{1}.fmri_spec.sess(1,r).scans =cellstr(spm_select('FPList',sub{s}.run{r},filefilter));
        for i=1:numel(onsets.names)
            jobs{2}.stats{1}.fmri_spec.sess(1,r).cond(i).name = onsets.names{i};
            jobs{2}.stats{1}.fmri_spec.sess(1,r).cond(i).onset = onsets.onsets{i};
            jobs{2}.stats{1}.fmri_spec.sess(1,r).cond(i).duration = onsets.durations{i};
        end
    end

    %% Model estimation
    %--------------------------------------------------------------------------
    jobs{2}.stats{2}.fmri_est.spmmat = cellstr(fullfile(subj_path,resultsdir,'SPM.mat'));
    save(fullfile(subj_path,'results_POSTsimilarity_unnormalized_msessions.mat'),'jobs');

    %% INFERENCE
    %--------------------------------------------------------------------------
    %jobs{2}.stats{3}.results.spmmat = cellstr(fullfile(data_path,'categorical','SPM.mat'));
    %jobs{2}.stats{3}.results.conspec(1).contrasts = Inf;
    %jobs{2}.stats{3}.results.conspec(1).threshdesc = 'FWE';

    %jobs{2}.stats{4}.results.spmmat = cellstr(fullfile(data_path,'categorical','SPM.mat'));
    %jobs{2}.stats{4}.results.conspec(1).titlestr = 'main effect of Rep (masked [incl.] by ...)';
    %jobs{2}.stats{4}.results.conspec(1).contrasts = 3;
    %jobs{2}.stats{4}.results.conspec(1).threshdesc = 'none';
    %jobs{2}.stats{4}.results.conspec(1).thresh = 0.001;
    %jobs{2}.stats{4}.results.conspec(1).extent = 0;
    %jobs{2}.stats{4}.results.conspec(1).mask.contrasts = 5;
    %jobs{2}.stats{4}.results.conspec(1).mask.thresh = 0.001;
    %jobs{2}.stats{4}.results.conspec(1).mask.mtype = 0;

    %jobs{2}.stats{5}.con.spmmat = cellstr(fullfile(data_path,'categorical','SPM.mat'));
    %jobs{2}.stats{5}.con.consess{1}.fcon.name = 'Movement-related effects';
    %fcont = [zeros(6,3*4) eye(6)];
    %for i=1:size(fcont,1)
    %	jobs{2}.stats{5}.con.consess{1}.fcon.convec{1,i} = fcont(i,:);
    %end
    %jobs{2}.stats{6}.results.spmmat = cellstr(fullfile(data_path,'categorical','SPM.mat'));
    %jobs{2}.stats{6}.results.conspec(1).contrasts = 17;
    %jobs{2}.stats{6}.results.conspec(1).threshdesc = 'FWE';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% RUN
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %save('face_batch_categorical.mat','jobs');
    %spm_jobman('interactive',jobs);
    spm_jobman('run',jobs);

end

clear all



