#!/bin/bash -e -u
# Author: Alexa Tompary
# This script makes all functionally and anatomically
# defined ROIs
#modified by Oded Bein to fit to SEL2 (Maril lab)

PROJECT_DIR=/Users/oded/research/SEL2_anat/analysis/SubsROIs;

analysis=gPPI_lant_hipp_F_NF_spheres
rois_dir=/Users/oded/research/SEL2_anat/analysis/GroupLevelROIs/$analysis

DROPBOX_DIR=/Local/Users/oded/Dropbox/marilab.oded/SEL/SEL_fMRI/SEL2/SubSpaceAnatROI

### declare an array variable
declare -a subjects=(080815EF 110715DA 110715YB 230615ZD 250715EB 270615SA \
080815LR 200615TF 250715LK 080815RM 110715YL 230615EF 240715TP 270615NK \
080815TN 110815EZ 230615RE 250715AG 270615RP)

#####################################################################
#01. extract grey matter using FAST:
for subj in ${subjects[@]}
do
    subj_dir=$PROJECT_DIR/$subj
    subj_mprage_dir=$subj_dir/BBR_reg

    cd $subj_mprage_dir
    #cp $subj_dir/anat_segmentation/mprage_std.nii.gz $subj_mprage_dir/mprage_std.nii.gz
    #bet $subj_mprage_dir/mprage_std $subj_mprage_dir/mprage_std_brain -B

    echo "running FAST on MPRAGE subject $subj"
    fast -t 1 -o $subj_mprage_dir/mprage $subj_mprage_dir/mprage_std30-B_brain
    rm -rf $subj_mprage_dir/mprage_pve* $subj_mprage_dir/mprage_mixeltype.nii.gz
    #create the mask for only grey matter
    fslmaths $subj_mprage_dir/mprage_seg -thr 2 -uthr 2 -bin $subj_mprage_dir/mprage_grey
    #apply the transformation to epi

    flirt \
    -in $subj_mprage_dir/mprage_grey \
    -ref $subj_dir/meanuaimage001 \
    -applyxfm -init $subj_mprage_dir/mprageStd2epi_BBR.mat \
    -out $subj_mprage_dir/epi_grey

    fslmaths $subj_mprage_dir/epi_grey -thr 0.5 -bin $subj_mprage_dir/epi_grey

    #apply the epi mask on the grey matter mask:
    fslmaths $subj_mprage_dir/epi_grey -mul $subj_dir/epi_brain_mask_cons $subj_mprage_dir/epi_grey_masked

done


#looking at the extraction
for subj in ${subjects[@]}
do
    subj_roi_dir=$PROJECT_DIR/$subj
    fslview $subj_roi_dir/epi_brain $subj_roi_dir/BBR_reg/epi_grey_masked -l Red [-b 0,1000] &
done

#####################################################################
#02 apply the grey matter mask on the regions
for subj in ${subjects[@]}
do

subj_dir=$PROJECT_DIR/$subj
subj_mprage_dir=$subj_dir/BBR_reg

subj_rois=`ls $rois_dir/S$subj*.nii*`
echo "applying grey matter mask for all regions, $subj"
for roi in $subj_rois; do
       #apply the epi mask on the grey matter mask:
roi_name=${roi%%.*}
fslmaths $roi -mul $subj_mprage_dir/epi_grey_masked ${roi_name}_gm
done
done

#change the flie names so will be easier to copy and use in matlab later:
cd $rois_dir
for subj in ${subjects[@]}
do

subj_dir=$subj
if [ ! -d $subj_dir ]; then
mkdir $subj_dir
fi

subj_rois=`ls S$subj*_gm.nii*`
echo "copying and renaming all rois $subj"
for roi in $subj_rois; do

roi_name=${roi#*_}
#echo $roi
#echo ${roi_name}
#echo $rois_dir/$subj_dir/${roi_name}
cp $roi $subj_dir/${roi_name}
done
done
