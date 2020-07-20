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
ppi_dir=fullfile(basedir,'gPPI');
%funcdir = 'func'; % Location of functional runs directories
templdir='templates'; % Location of template files
%dicom2niftidir='C:\fMRI_tools\SPM8'; % Location of dicom2nifti script
norm_dir='Similarity1'; %where the normalizarion matrix is

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
nSubs = length(subs);

%folder of files to normalize:
runs =	{... % Make sure all functional runs are included here
'results_pairsRep_smt_unnorm_msessions\PPI_epi_lhipp_ant';...
};

nRuns = length(runs);
anat_folder='mprage';% the folder where the anatomical images are stored
% Templates Files definition
%**************************************************************************
%IMPORTANT - They have to pre-exist at the templates directory

templates = {...
    'normalize_con_images.mat';...
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



for s = 1:nSubs % Start preprocessing for all subjects

    %***********************************************************************
    % NORMALIZATION - apply the normalization matrix to the ppi contrast
    % images
    %***********************************************************************

    filefilter = '^con.*\.img'; 
    %filefilter_norm_mat = '*_sn.*\.nii';
    
    %find the normalization matrix file - typically in the Similarity1
    %folder, but for YB, in the Pairs1 folder (see experiment README)
    if strcmp(subs{s},'110715YB')
        norm_mat=fullfile(basedir,subs{s},'Pairs1','meanuaimage001_sn.mat');
    else
        norm_mat=fullfile(basedir,subs{s},norm_dir,'meanuaimage001_sn.mat');
    end
    
    load(fullfile(ppi_dir,templdir,templates{1}));
    jobs{1}.spm.spatial.normalise=matlabbatch{1}.spm.spatial.normalise;

    jobs{1}.spm.spatial.normalise.write.subj.matname={norm_mat};
    jobs{1}.spm.spatial.normalise.write.subj.resample=cellstr(spm_select('FPList',sub{s}.run{1},filefilter));

    spm_jobman('run',jobs);
    clear jobs;

end
cd(WD);

clear all
