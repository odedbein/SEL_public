function GetSubjSpaceROICoord(analysis)

%%% Utilizes the get_orig_coord2.m script by John Ashburner for extracting
%%% native-space coordinates of MNI coordinates for multiple subjects -
%%% this script does it for a full ROI.
%% note that if it's a sphere, it's better to get the coordinate in subj-specific space, then blow the sphere.



%% variables and folder

basedir = 'G:\shoshi\Shoshi_Backup_(C)\fMRI_Data\SEL2\ANALYSIS_SPM8';% Root location of analysis folder
addpath(basedir);

%analysis='gPPI_lant_hipp_F_NFcontrast';
%group_roi_dir='C:\fMRI_Data\SEL2\ANALYSIS_SPM8\GROUP_LocFNO\Famous_Nonfamous\ROIs';%where the group ROIs are saved
group_roi_dir=fullfile(basedir,'GROUP\Subjects_ROIs',analysis);%where the group ROIs are saved
mat_name = 'meanuaimage001_sn.mat'; % Name of normalization matrix (created by SPM in standard normalization)
mean_epi='meanuaimage001.nii'; %name of the mean epi image
destdir=fullfile(basedir,'GROUP\Subjects_ROIs',analysis);
%previous destdirs:
%'C:\fMRI_Data\SEL2\ANALYSIS_SPM8\GROUP\Subjects_ROIs\F_NF_loc'
if ~exist(destdir)
    mkdir(destdir)
end

runs 			= 	{... % where the normalization matrix is to be found
'Similarity1';...
};

nRuns = length(runs); 
%contrast='Famous_non_famous';
all_rois=dir(fullfile(group_roi_dir,'*.nii'));
ROIs={};
for i=1:numel(all_rois)
    ROIs{i,1}=all_rois(i).name(1:(end-4));
end


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
orig_coord=[];
MNI_coord=[];

%get the MNI coordinates of all clusters.
for roi=1:numel(ROIs)
    filename=[ROIs{roi} '.nii'];
    clust=spm_read_vols(spm_vol(fullfile(group_roi_dir,filename)));
    [x,y,z]=ind2sub(size(clust),find(clust));
    mask=[x,y,z];
    mask_MNIcoord=zeros(size(mask));
    mask_MNIcoord(:,1)=(-mask(:,1)+46)*2;
    mask_MNIcoord(:,2)=(mask(:,2)-64)*2;
    mask_MNIcoord(:,3)=(mask(:,3)-37)*2;
    MNI_coord.(ROIs{roi})=mask_MNIcoord;
end

%%check the script, may still need to switch coordinates/dims
for roi=1:numel(ROIs)
    for s = 1:nSubs % set up subjects & runs folders
        sub_dir = subs{s}; 
        fprintf(sprintf('subject %s, %s \n',subs{s},ROIs{roi}));
        for r = 1:nRuns
            run_dir = runs{r};
            if strcmp(subs{s},'110715YB')
                run_dir='Pairs1';
            end
            matname = fullfile(basedir,sub_dir,run_dir,mat_name);
            epi=fullfile(basedir,sub_dir,run_dir,mean_epi);
            orig_coord.(ROIs{roi}).(['S' subs{s}]) = get_orig_coord2(MNI_coord.(ROIs{roi}),matname,epi);
        end
    end
end
orig_coord_subs = {subs; orig_coord};
cd(destdir);
save(sprintf('%s_Group2Indvidual_epi.mat',analysis),'orig_coord');

%write the nii masks so that I can move them to fsl to mask by the grey
%matter extracted by FAST
for s = 1:nSubs % set up subjects & runs folders
    %upload some header of the subject:
    if strcmp(subs{s},'110715YB')
        run_dir='Pairs1';
    else
         run_dir = runs{1};
    end
    hdr=spm_vol(fullfile(basedir,subs{s},run_dir,mean_epi));
    for roi=1:numel(ROIs)
        hdr.fname=fullfile(destdir,['S' subs{s} '_' ROIs{roi} '.nii']);
        hdr.description='mask';
        mask=round(orig_coord.(ROIs{roi}).(['S' subs{s}]));
        mask=sub2ind(hdr.dim,mask(:,1),mask(:,2),mask(:,3));
        roi_mask=zeros(hdr.dim);
        roi_mask(mask)=1;
        spm_write_vol(hdr,roi_mask);
        gzip(hdr.fname);
        delete(hdr.fname);
     end
end

end





