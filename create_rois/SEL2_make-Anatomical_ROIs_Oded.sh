#!/bin/bash -e -u
# Author: Alexa Tompary
# This script makes all functionally and anatomically
# defined ROIs
#modified by Oded Bein to fit to SEL2 (Maril lab)

if [ $# -ne 1 ]; then
  echo "
usage: `basename $0` subj

This script uses FIRST and fslmaths to create binary masks of 
all functionally and anatomically defined ROIs
"
  exit
fi

#subj=$@
#source scripts/globals.sh

PROJECT_DIR=/Users/oded/research/SEL2_anat/analysis/SubsROIs
DROPBOX_DIR=/Users/oded/Dropbox/MariLabTemp.Oded/accumbance

### declare an array variable
declare -a subjects=(080815EF 110715DA 110715YB 230615ZD 250715EB 270615SA \
080815LR 200615TF 250715LK 080815RM 110715YL 230615EF 240715TP 270615NK \
080815TN 110815EZ 230615RE 250715AG 270615RP)


####################### remove directories
for subj in ${subjects[@]}
do
    subj_roi_dir=$PROJECT_DIR/$subj
    if [ -d $subj_roi_dir/hipp_segmentation ]; then
        rm -rf $subj_roi_dir/hipp_segmentation;
    fi

    if [ -d $subj_roi_dir/registration ]; then
        rm -rf $subj_roi_dir/registration;
    fi
done

########################## MPRAGE to std ###################################
for subj in ${subjects[@]}
    do

    subj_roi_dir=$PROJECT_DIR/$subj

    if [ ! -d $subj_roi_dir/anat_segmentation ]; then
    mkdir $subj_roi_dir/anat_segmentation;
    fi

    fslreorient2std $subj_roi_dir/MPRAGE.nii $subj_roi_dir/anat_segmentation/mprage_std
done

#################### hippocampus and striatum segmentation ##########################

for subj in ${subjects[@]}
do

    subj_roi_dir=$PROJECT_DIR/$subj

    cd $subj_roi_dir/anat_segmentation

    #pushd hipp_segmentation > /dev/null
    echo "segmenting hipp and using FIRST subject $subj"
	# run FIRST to segment hippocampus
	run_first_all -i mprage_std.nii.gz -o mprage_std -s R_Hipp,L_Hipp
	
	# extract and binarize left and right hipp separately
	fslmaths mprage_std_all_fast_firstseg -thr 17 -uthr 17 -bin mprage_lhipp
	fslmaths mprage_std_all_fast_firstseg -thr 53 -uthr 53 -bin mprage_rhipp
	fslmaths mprage_lhipp -add mprage_rhipp mprage_hipp

    cd $PROJECT_DIR
done

########################################################################################

#registration using BBR
for subj in ${subjects[@]}
do
    subj_roi_dir=$PROJECT_DIR/$subj
    if [ ! -d $subj_roi_dir/BBR_reg ]; then
    mkdir $subj_roi_dir/BBR_reg;
    fi
    cd $subj_roi_dir;

    #first, extract brain using BET
    echo "extracting subject's $subj brain using BET"
    bet anat_segmentation/mprage_std BBR_reg/mprage_std30-B_brain -f 0.30 -B

    echo "registering subject $subj using BBR registration"
    epi_reg --epi=meanuaimage001 --t1=anat_segmentation/mprage_std --t1brain=BBR_reg/mprage_std30-B_brain --out=BBR_reg/epi2mprageStd_BBR
    convert_xfm -inverse -omat BBR_reg/mprageStd2epi_BBR.mat BBR_reg/epi2mprageStd_BBR.mat
    cd $PROJECT_DIR
done

#looking at the registration
for subj in ${subjects[@]}
do
    subj_roi_dir=$PROJECT_DIR/$subj
    fslview $subj_roi_dir/anat_segmentation/mprage_std.nii.gz $subj_roi_dir/BBR_reg/epi2mprageStd_BBR.nii.gz [-b 0,1000] &
done

#now

#looking at the regions on the mprage
for subj in ${subjects[@]}
do
subj_roi_dir=$PROJECT_DIR/$subj/anat_segmentation
fslview $subj_roi_dir/mprage_std $subj_roi_dir/mprage_hipp -l Red-Yellow
done

#################################################################################################
#this loop applies the transformation matrix from the mprage to the EPIs - so register the ROIs to the epi space
#run this loop after splitting the hippocampus, for anterior/positerior
FSLOUTPUTTYPE=NIFTI
for subj in ${subjects[@]}; do

    subj_roi_dir=$PROJECT_DIR/$subj
    if [ ! -d $subj_roi_dir/registration ]; then
    mkdir $subj_roi_dir/registration;
    fi

for roi in rhipp_ant rhipp_post lhipp_ant lhipp_post hipp_ant hipp_post do
        flirt \
            -in $subj_roi_dir/anat_segmentation/mprage_$roi \
            -ref $subj_roi_dir/meanuaimage001 \
            -applyxfm -init $subj_roi_dir/BBR_reg/mprageStd2epi_BBR.mat \
            -out $subj_roi_dir/registration/epi_$roi

        fslmaths $subj_roi_dir/registration/epi_$roi -thr 0.5 -bin $subj_roi_dir/registration/epi_$roi
    done
done

#looking at the regions on the epi
for subj in ${subjects[@]}
do
subj_roi_dir=$PROJECT_DIR/$subj
fslview $subj_roi_dir/meanuaimage001 $subj_roi_dir/registration/epi_hipp_ant -l Red-Yellow $subj_roi_dir/registration/epi_hipp_post -l Blue-Lightblue
done

#copy to subj dir in the dropbox
for subj in ${subjects[@]}
do
    subj_DropBox_dir=$DROPBOX_DIR/$subj
    subj_roi_dir=$PROJECT_DIR/$subj
    if [ ! -d $subj_DropBox_dir ]; then
    mkdir $subj_DropBox_dir;
    fi

for roi in rhipp_ant rhipp_post lhipp_ant lhipp_post hipp_ant hipp_post do
        cp $subj_roi_dir/registration/epi_$roi.nii $subj_DropBox_dir/epi_$roi.nii
    done
done
