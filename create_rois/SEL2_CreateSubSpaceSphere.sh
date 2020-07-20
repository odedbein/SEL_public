#!/bin/bash -e -u
# Author: Alexa Tompary
# This script makes all functionally and anatomically
# defined ROIs
#modified by Oded Bein to fit to SEL2 (Maril lab)


PROJECT_DIR=/Users/oded/research/SEL2_anat/analysis/SubsROIs;
analysis=gPPI_lant_hipp_F_NF_spheres

rois_dir=/Users/oded/research/SEL2_anat/analysis/GroupLevelROIs/$analysis

### declare an array variable
declare -a subjects=(080815EF 110715DA 110715YB 230615ZD 250715EB 270615SA \
080815LR 200615TF 250715LK 080815RM 110715YL 230615EF 240715TP 270615NK \
080815TN 110815EZ 230615RE 250715AG 270615RP)

##################################################################
#01 create the sphere

#copy and change the flie names so will be easier to copy and use in matlab later:
cd $rois_dir
for subj in ${subjects[@]}
do

subj_dir=$subj
if [ ! -d $subj_dir ]; then
mkdir $subj_dir
fi

subj_rois=`ls S$subj*.nii*`
echo "copying and renaming all rois $subj"
for roi in $subj_rois; do
roi_name=${roi#*_}
cp $roi $subj_dir/${roi_name}
done
done

###########################################################################
#02: creates a kernel using the 1-voxel roi as input
# also mask by the grey matter to exclude no grey matter voxels
#cd $rois_dir
for subj in ${subjects[@]}
do
subj_dir=$PROJECT_DIR/$subj
subj_mprage_dir=$subj_dir/BBR_reg

subj_roi_dir=$rois_dir/${subj}
cd $subj_roi_dir
subj_rois=`ls *.nii*`
echo "creating spheres all rois $subj"
for roi in $subj_rois; do
roi_name=${roi%%.*}
 for ks in 8 10 12; do
 fslmaths \
 $subj_roi_dir/${roi} \
 -kernel sphere $ks -fmean -bin -thr .00001 \
 -mul $subj_mprage_dir/epi_grey_masked \
 $subj_roi_dir/${roi_name}_sphereBlownInSubjSpace_${ks}_gm
#add the next line if want the brain mask rather than the gm mask:
#-mas $subj_preproc_dir/${master_run}.feat/mask_brain \

 done
done

done #subj loop


#####################################################################
#02 apply the grey matter mask on the regions - unnecessary if applied before, also I already created them in the subjects folders so no need to move anything
for subj in ${subjects[@]}
do

subj_dir=$PROJECT_DIR/$subj
subj_mprage_dir=$subj_dir/BBR_reg

subj_rois=`ls $rois_dir/S$subj*.nii*`
echo "applying grey matter mask for all regions, $subj"
for roi in $subj_rois; do

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
#apply the epi mask on the grey matter mask:
roi_name=${roi#*_}
#echo $roi
#echo ${roi_name}
#echo $rois_dir/$subj_dir/${roi_name}
cp $roi $subj_dir/${roi_name}
done
done
