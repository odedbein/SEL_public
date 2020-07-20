clear all
% A Preprocessing script for SPM8 from DICOM to Smoothing
%
% Organized by Niv Reggev; Written by Talya Sadeh & Niv Reggev
%**************************************************************************
%**************************************************************************
%
%
% MAKE SURE ALL DEFINITIONS ARE IN ORDER
%
% Make sure that all template files (created by SPM) are available at the
% paths specified at the definitions section
%
%**************************************************************************
%DEFINITIONS
%**************************************************************************

%rawdatadir='C:\fMRI_Data\RS1\RawData\';% Root location of raw DICOMs
basedir = 'C:\fMRI_Data\SEL2\ANALYSIS_SPM8';% Root location of analysis folder
%funcdir = 'func'; % Location of functional runs directories
templdir='templates'; % Location of template files
%dicom2niftidir='C:\fMRI_tools\SPM8'; % Location of dicom2nifti script

subs= {...
%      '230615EF';...
%      '230615RE';...
%      '270615SA';...     
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


nSubs = length(subs);

runs =	{... % Make sure all functional runs are included here
'Similarity1';...
'Similarity2';...
'Pairs1';...
'Pairs2';...
'Pairs3';...
'Pairs4';...
'Similarity3';...
'Similarity4';...
'Localizer1';...
'Localizer2';...
'Localizer3';...
};

nRuns = length(runs);
anat_folder='mprage';% the folder where the anatomical images are stored
% Templates Files definition
%**************************************************************************
%IMPORTANT - They have to pre-exist at the templates directory

templates = struct(...
    'name1','slicetiming_SEL2_noCR.mat',...
    'name2','realignment_unwarp_SEL2_noCR.mat',...
    'name3','normalizing_SEL2_noSimCR.mat',...
    'name4','smoothing_SEL2_noSimCR.mat',...
    'name5','coregistration_reslice_mprage_to_epi_SEL2_noCR.mat');
templnames=fieldnames(templates);

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



for s = 1:nSubs % Start preprocessing for all subjects

    %***********************************************************************
    % SLICE TIMING CORRECTION
    %***********************************************************************

    filefilter = '^image.*\.nii$';% '^vol.*\.nii$';% % Images to go slice-timing correction

    load(fullfile(basedir,templdir,char(getfield(templates, sprintf('name1'))))); % Load appropriate template
    jobs{1}.temporal{1}=matlabbatch{1}.spm.temporal; % transfer loaded data - available as matlabbatch variable - to jobs 
    for r = 1:nRuns
        jobs{1}.temporal{1}.st.scans{r} = cellstr(spm_select('FPList',sub{s}.run{r},filefilter)); %  Select files.   WORKS ONLY FOR SPM8!
    end

    spm_jobman('run',jobs); % Run slice timing correction
    clear jobs;

     %***********************************************************************
    % REALIGNMENT and unwarp
    %***********************************************************************

    filefilter = '^a.*\.nii'; 

    jobs{1}.util{1}.cdir.directory = cellstr(fullfile(basedir,subs{s})); % Set working directory (useful for .ps only)
    load(fullfile(basedir,templdir,char(char(getfield(templates, sprintf('name2'))))));
    jobs{2}.spatial{1}.realignunwarp{1}=matlabbatch{1}.spm.spatial.realignunwarp; % In case of Realign & Unwarp 
    jobs{2}.spatial{1}.realignunwarp{1}.data=[]; %check
    for r = 1:nRuns
         jobs{2}.spatial{1}.realignunwarp.data(1,r).scans = cellstr(spm_select('FPList',sub{s}.run{r},filefilter)); %this is your data for each session
    end
    fg=spm_figure('CreateWin','Graphics'); % Open SPM graphics window (otherwise the .ps won't be written)
    spm_jobman('run',jobs);
    close % close all windows
    clear jobs;

    %***********************************************************************
    % NORMALIZATION
    %***********************************************************************

    filefilter = '^ua.*\.nii'; 
    filefilter_mean = '^mean.*\.nii';

    load(fullfile(basedir,templdir,char(char(getfield(templates, sprintf('name3'))))));
    jobs{1}.spatial{1}.normalise{1}=matlabbatch{1}.spm.spatial.normalise;

    jobs{1}.spatial{1}.normalise{1}.estwrite.subj.source{1}= strcat(spm_select('FPList',sub{s}.run{1},filefilter_mean));
    jobs{1}.spatial{1}.normalise{1}.estwrite.subj.resample= cellstr(spm_select('FPList',sub{s}.run{1},filefilter_mean));
    
    norm_runs=[3:6 9:11];%don't normalize similarity sessions
    for i = 1:length(norm_runs)  %stupid hack because jobs cannot skip cells in a structures
        r=norm_runs(i);
        fprintf('Source image %s',strcat(spm_select('FPList',sub{s}.run{1},filefilter_mean)));
        jobs{1}.spatial{1}.normalise{i}= jobs{1}.spatial{1}.normalise{1};
        jobs{1}.spatial{1}.normalise{i}.estwrite.subj.source{1}= strcat(spm_select('FPList',sub{s}.run{1},filefilter_mean));
        jobs{1}.spatial{1}.normalise{i}.estwrite.subj.resample = cellstr(spm_select('FPList',sub{s}.run{r},filefilter));
    end

    spm_jobman('run',jobs);
    clear jobs;

    %***********************************************************************
    % SMOOTHING resliced images from realignment for single subject activation analysis
    %***********************************************************************

    filefilter = '^ua.*\.nii'; 

    load(fullfile(basedir,templdir,char(char(getfield(templates, sprintf('name4'))))));
    jobs{1}.spatial{1}=matlabbatch{1}.spm.spatial;
    jobs{1}.spatial{1}.smooth.data=[];
    
    for r = [9:11] %only for localizer sessions 
        jobs{1}.spatial{1}.smooth.data=  cellstr(spm_select('FPList',sub{s}.run{r},filefilter));
        spm_jobman('run',jobs);
    end
    clear jobs;
    
    %***********************************************************************
    % SMOOTHING normaiized images for activation group findings
    %***********************************************************************

    filefilter = '^wua.*\.nii'; 

    load(fullfile(basedir,templdir,char(char(getfield(templates, sprintf('name4'))))));
    jobs{1}.spatial{1}=matlabbatch{1}.spm.spatial;
    jobs{1}.spatial{1}.smooth.data=[];

    for r = [3:6 9:11] %don't smooth similarity sessions
        jobs{1}.spatial{1}.smooth.data=  cellstr(spm_select('FPList',sub{s}.run{r},filefilter));
        spm_jobman('run',jobs);
    end
    clear jobs;
    
    %***********************************************************************
    % COREGISTRATION
    %***********************************************************************
    
    filefilter_source = 'image001.nii';% 
    filefilter_ref = '^mean.*\.nii';
    cur_anat_folder=fullfile(basedir,subs{s},anat_folder);
    load(fullfile(basedir,templdir,char(char(getfield(templates, sprintf('name5'))))));
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref=cellstr(spm_select('FPList',sub{s}.run{1},filefilter_ref));
    matlabbatch{1}.spm.spatial.coreg.estwrite.source=cellstr(spm_select('FPList',cur_anat_folder,filefilter_source));
    spm_jobman('run', matlabbatch);
    clear matlabbatch;

    disp(sprintf('***** ALL DONE preprocessing subject:   %s',subs{s}));

end

%***********************************************************************
%  CLEANING UP - delete temporary files, if they were created
%***********************************************************************


for s = 1 : nSubs
    for r = 1 : nRuns
        %cd(fullfile(basedir,sprintf('%s\\%s\\%s',subs{s},funcdir,runs{r})));
        cd(fullfile(basedir,sprintf('%s\\%s',subs{s},runs{r})));
        delete a*; %aimage*;
        delete wua*;
    end
end
        
cd(WD);

clear all
