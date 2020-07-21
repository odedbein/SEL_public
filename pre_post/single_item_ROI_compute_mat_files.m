function single_item_ROI_compute_mat_files()
%type that before running: addpath(genpath('/Volumes/data/Bein/Software/spm12'));
%+---------------------------------------
%|
%| Robert C. Welsh
%| 2002.10.20
%| 
%| University of Michigan
%| Department of Radiology
%|
%| A little toolbox to apply a mask to
%| a t-map or beta-map or con-map and 
%| report the mean and variance.
%| 
%+---------------------------------------

% The script brakes after ~500 clusters with 360 betas each

%oded bein: this script doens't output a text file, onlt creates the
%sub_mat_files
CWD = pwd;
%SCCSid  = '0.5';
proj_dir='/Users/oded/research/SEL2/ANALYSIS_SPM8';
analysis_dir='GROUP/Similarity/ROI_analysis_unnormalized/AnalysisTValsAllTrials';
mat_files_dir= fullfile(proj_dir,analysis_dir,'subs_mat_files');
analysis='gPPI_lant_hipp_F_NF';
%Output_Dir = 'C:\fMRI_Data\SEL2\ANALYSIS_SPM8\GROUP\Similarity\ROI_analysis_unnormalized\AnalysisTVals\regions_txt';
%if ~exist(Output_Dir), mkdir(Output_Dir); end
if ~exist(mat_files_dir), mkdir(mat_files_dir); end
mask_type='nii';
masks_dir = 'masks';

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


%% grab masks from one subject:
masks_temp=dir(fullfile(proj_dir, '200615TF','masks',sprintf('%s*sphereBlownInSubjSpace_10_gm.nii',analysis)));
masks={};
for i=1:numel(masks_temp)
    curr_reg=masks_temp(i).name;
    curr_reg=curr_reg(1:(find(curr_reg=='.')-1));
    masks=[masks;curr_reg];
    
end
masks_temp=dir(fullfile(proj_dir, '200615TF','masks',sprintf('%s*sphereBlownInSubjSpace_12_gm.nii',analysis)));
for i=1:numel(masks_temp)
    curr_reg=masks_temp(i).name;
    curr_reg=curr_reg(1:(find(curr_reg=='.')-1));
    masks=[masks;curr_reg];
    
end
%% inseart masks manually:

% masks= {...
% %      'sphere_6_L_FFA_roi';...
% %      'sphere_6_R_FFA_roi';...
% %       'sphere_6_L_STS_roi';...
% %      'sphere_6_R_STS_roi';...
%         'epi_hipp_ant';...
%         'epi_hipp_post';...
%         'epi_hipp_mid';...
%         'epi_rhipp_ant';...
%         'epi_rhipp_post';...
%         'epi_rhipp_mid';...
%         'epi_lhipp_ant';...
%         'epi_lhipp_post';...
%         'epi_lhipp_mid';...
%         'epi_hipp';...
%         'epi_lhipp';...
%         'epi_rhipp';...
%         'epi_caudate';...
%         'epi_lcaudate';...
%         'epi_rcaudate';...
%         'epi_putamen';...
%         'epi_rputamen';...
%         'epi_lputamen'...
%     };

%% use the next section if you need to change the masks names
% for j=1:length(subs)
% 
%     subject=char(subs{j});
% 
%     for i = 1:clust_num
% 
%         mask_nm=masks{i}(1:end-4);
%         spmMaskFiles= sprintf('C:/fMRI_Data/SEL2/ANALYSIS_SPM8/%s/%s/%s.%s',subject,masks_dir,mask_nm,mask_type);
%         mask_nm=masks{i};
%         spmMaskFilesNew= sprintf('C:/fMRI_Data/SEL2/ANALYSIS_SPM8/%s/%s/%s.%s',subject,masks_dir,mask_nm,mask_type);
%         if exist(spmMaskFiles) %%if the region exists or not in the specific subject    
%         movefile(spmMaskFiles,spmMaskFilesNew);
%         end
%     end
% end

clust_num=length(masks);
T_num=48*2;%48 items,2 sessions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%extract beta values per voxel for culster per subject
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:length(subs)

subject=char(subs{j});
fprintf('extracting values for subj %s\n',subject);
nExtractions = 1; %reminicent of previous script, don't touch it.

spmValsFiles = {};

for i = 1:clust_num

mask_nm=masks{i};
spmMaskFiles= fullfile(proj_dir,subject,masks_dir,sprintf('%s.%s',mask_nm,mask_type));      

if exist(spmMaskFiles) %%if the region exists or not in the specific subject    
    
%%%%%%%%%%%%%%%%%%%%%%
%PRE_SIMILARITY
%%%%%%%%%%%%%%%%%%%%%%
  spmValsFiles{1,1}= sprintf('%s/%s/results_PREsimilarity_unnormalized_msessions/spmT_0001.img',proj_dir,subject);
  root=sprintf('%s/%s/results_PREsimilarity_unnormalized_msessions/spmT_0',proj_dir,subject);
  img='.img';
  for t=2:9
      full_root=sprintf('%s00%d%s',root,t,img);
      spmValsFiles{1,1}=[spmValsFiles{1,1};full_root];
  end
  for t=10:T_num
      full_root=sprintf('%s0%d%s',root,t,img);
      spmValsFiles{1,1}=[spmValsFiles{1,1};full_root];
  end
   
  
%cd(Output_Dir);

%  output_file = sprintf('%s_betas.txt', roi_id);
%output_file = sprintf('%s_%s_SEL2_PREsimilarity_unnorm_betas.txt', subject,mask_nm);
%fid = fopen(output_file, 'w');
  
% Now extract the files.


for iExtraction = 1:nExtractions
  spm_progress_bar('Init',size(spmValsFiles{iExtraction},1),'Files to Read','Extracting data');
  %maskHdr = spm_vol(spmMaskFiles);
  %maskVol = spm_read_vols(maskHdr);
  maskVol=niftiread(spmMaskFiles);
  maskIDX = find(maskVol);
  %fprintf('Extraction #%d\n',iExtraction);


  clust_mat_sim=[];
  for iSubject = 1:size(spmValsFiles{iExtraction},1) %for each beta (meaning, for each trial)
    spm_progress_bar('Set',iSubject);
%     valsHdr = spm_vol(spmValsFiles{iExtraction}(iSubject,:));
%     valsVol = spm_read_vols(valsHdr);
    valsHdr = spmValsFiles{iExtraction}(iSubject,:);
    valsVol = niftiread(valsHdr);
    %valsVol_masked = 0;
    valsVol_masked = valsVol(maskIDX);%choose only the voxels that are in the mask - that is, in the cluster.
    %valsVol_notNaN = 0;
    valsVol_notNaN = ~isnan(valsVol_masked);%from the voxels in the mask, put 0 for NaN and 1 for not NaN.
    Active_Voxels=sum(valsVol_notNaN);%how many not NaNs (active values) are in the cluster
    valsVol_masked(~valsVol_notNaN)=0;%if the voxel is NaN, put 0 in valsVol_masked
    valsVol_true = find(valsVol_masked);%say where in the vectors are the Not NaNs.
    meanVal = mean(valsVol_masked(valsVol_true));%compute mean
    trialVec=valsVol_masked;%copy all the voxels in the mask, including NaNs, this is done to match the size of matrices across subjects, should be discarded when computing correlations
    %trialVec(valsVol_true)=trialVec(valsVol_true)-meanVal;%those which are not NaNs, subtract the mean
    %VecSD=std(trialVec(valsVol_true));
    %trialVecSD=trialVec;
    %trialVecSD(valsVol_true)=trialVec(valsVol_true)/VecSD;
    clust_mat_sim=[clust_mat_sim trialVec];
    variVal = var (valsVol_masked(valsVol_true));%compute var
    %meanVal = mean(valsVol(maskIDX));
    %variVal = var(valsVol(maskIDX));
    nVoxels = length(maskIDX);
    %[d1 fnametoprint d2] = fileparts(valsHdr.fname);
    %fprintf(fid,'%03d %03d %03d %+6.6f %+6.6f %s\n',iSubject,nVoxels,Active_Voxels,meanVal,variVal,fnametoprint);
  end  %ends the cluster loop
  %cd(mat_files_dir);
  file_name=sprintf('PRE_%s_%s', subject,mask_nm);
  save(fullfile(mat_files_dir,file_name), 'clust_mat_sim');
  spm_progress_bar('Clear');
end %ends the Extractions loop

%%%%%%%%%%%%%%%%%%%%%%
%POST_SIMILARITY
%%%%%%%%%%%%%%%%%%%%%%
  spmValsFiles{1,1}= sprintf('%s/%s/results_POSTsimilarity_unnormalized_msessions/spmT_0001.img',proj_dir,subject);
  root=sprintf('%s/%s/results_POSTsimilarity_unnormalized_msessions/spmT_0',proj_dir,subject);
  
%   spmValsFiles{1,1}= sprintf('C:/fMRI_Data/SEL2/ANALYSIS_SPM8/%s/results_POSTsimilarity_unnormalized_msessions/spmT_0001.img',subject);
%   root=sprintf('C:/fMRI_Data/SEL2/ANALYSIS_SPM8/%s/results_POSTsimilarity_unnormalized_msessions/spmT_0',subject);
   img='.img';
  for t=2:9
      full_root=sprintf('%s00%d%s',root,t,img);
      spmValsFiles{1,1}=[spmValsFiles{1,1};full_root];
  end
  for t=10:T_num
      full_root=sprintf('%s0%d%s',root,t,img);
      spmValsFiles{1,1}=[spmValsFiles{1,1};full_root];
  end
   
  
%cd(Output_Dir);

%  output_file = sprintf('%s_betas.txt', roi_id);
%output_file = sprintf('%s_%s_SEL2_POSTsimilarity_unnorm_betas.txt', subject,mask_nm);
%fid = fopen(output_file, 'w');
  
% Now extract the files.


for iExtraction = 1:nExtractions
  spm_progress_bar('Init',size(spmValsFiles{iExtraction},1),'Files to Read','Extracting data');
  %maskHdr = spm_vol(spmMaskFiles);
  %maskVol = spm_read_vols(maskHdr);
  maskVol=niftiread(spmMaskFiles);
  maskIDX = find(maskVol);
  %fprintf('Extraction #%d\n',iExtraction);


  clust_mat_sim=[];
  for iSubject = 1:size(spmValsFiles{iExtraction},1) %for each beta (meaning, for each trial)
    spm_progress_bar('Set',iSubject);
%     valsHdr = spm_vol(spmValsFiles{iExtraction}(iSubject,:));
%     valsVol = spm_read_vols(valsHdr);
    valsHdr = spmValsFiles{iExtraction}(iSubject,:);
    valsVol = niftiread(valsHdr);
    %valsVol_masked = 0;
    valsVol_masked = valsVol(maskIDX);%choose only the voxels that are in the mask - that is, in the cluster.
    %valsVol_notNaN = 0;
    valsVol_notNaN = ~isnan(valsVol_masked);%from the voxels in the mask, put 0 for NaN and 1 for not NaN.
    Active_Voxels=sum(valsVol_notNaN);%how many not NaNs (active values) are in the cluster
    valsVol_masked(~valsVol_notNaN)=0;%if the voxel is NaN, put 0 in valsVol_masked
    valsVol_true = find(valsVol_masked);%say where in the vectors are the Not NaNs.
    meanVal = mean(valsVol_masked(valsVol_true));%compute mean
    trialVec=valsVol_masked;%copy all the voxels in the mask, including NaNs, this is done to match the size of matrices across subjects, should be discarded when computing correlations
    %trialVec(valsVol_true)=trialVec(valsVol_true)-meanVal;%those which are not NaNs, subtract the mean
    %VecSD=std(trialVec(valsVol_true));
    %trialVecSD=trialVec;
    %trialVecSD(valsVol_true)=trialVec(valsVol_true)/VecSD;
    clust_mat_sim=[clust_mat_sim trialVec];
    variVal = var (valsVol_masked(valsVol_true));%compute var
    %meanVal = mean(valsVol(maskIDX));
    %variVal = var(valsVol(maskIDX));
    nVoxels = length(maskIDX);
%    [d1 fnametoprint d2] = fileparts(valsHdr.fname);
    %fprintf(fid,'%03d %03d %03d %+6.6f %+6.6f %s\n',iSubject,nVoxels,Active_Voxels,meanVal,variVal,fnametoprint);
  end  %ends the cluster loop
  %cd(mat_files_dir);
  file_name=sprintf('POST_%s_%s', subject,mask_nm);
  save(fullfile(mat_files_dir,file_name), 'clust_mat_sim');
  spm_progress_bar('Clear');
end %ends the Extractions loop

end %ends the conditional on whether the region exists or not in the specific subject
end%ends all the clusters loop

end%ends all the subjects loop

cd(CWD);