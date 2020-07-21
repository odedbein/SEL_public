# SEL_public

SEL, public folder

These are the scripts I used to analyze the data for Bein et al., 2020 (accepted), NatComms: *"Prior knowledge promotes hippocampal separation but cortical assimilation in the left inferior frontal gyrus".* I did not clean them well enough, and also - this project is from the before/begining of my PhD. So the code is messy. Feel free to contact at oded.bein@nyu.edu Relevant data is abvailable on: https://osf.io/u2h3s/
Analysis was done primarily in SPM/matlab, with some fsl mainly for creating subjects' rois.

## 0. Behavior
The scripts analyse_SEL2_scanner_* in this folder take the log files, miminaly process them and create xls files per participant (these are the files in the osf repository).
These files also create the relevant onsets.
The file that has "ret" at the end is for retrieval, and is only doing behavioral analysis, the imaging data was not analysed (trials were not time limited).

* There's a file called _SEL2_pairsRep_PrepOnsetsFromAnalyzed_ - that's the one I used to prepare the onsets for the univariate analysis of the associative learning.

Then, I was very low tech and copied pasted all to a file with all participants. This way I created the file SEL2_all_subs.

Group level analysis was done using pivot tables on this file, and copying relevant data to the file data_paper_forR, found in the misc_group_level folder. The data in the file data_paper_forR is equivalent to the data in the Source Data file for the paper.

## 1. PreprocessingAndModel

preproc_SEL2: runs preprocessing for all participants. You need the templates in the templates folder for that to run
preproc_SEL2_BotUp: due to a scanner mistake, two participants were scanned bottom up. This is their preproc (only slice timing correction is different)

model_msessions_SEL2_PRE_POST_similairity: runs the models of the pre/post similarity scans. outputs a t-map for each face, in each scan. I later on average pre and post. That's it - after that, you got your t-maps, continue to the pre_post folder.
model_msessions_SEL2_pairsReps: This is the model that was used to run the univariate analysis on the associative learning (pairs) task.

contrasts_SEL2_PRE_POST_sim_msessions: in SPM, to obtain t-maps, one needs to run contrasts after estimating the models. This does that for the pre/post similarity
contrasts_SEL2_pairsRep_msessions: in SPM, to obtain t-maps, one needs to run contrasts after estimating the models. This does that for the univariate analysis on the associative learning (pairs) task. It uses the csv file: contrasts_SEL2_pairsRep.csv

FilesRelocationPairsRep.m: this file moves the contrast files to a group folder, for group level analysis. The group level analysis is then done using SPM gui.

## 1.2 create_rois
In the paper, we report results from anatomically segmented left anterior hippocmapus (other hippocampal regions are reported in the supplementary), as well as from rois from the functional connectivity analysis (lifg is the main one, but also AG, and more in the supplementary). The scripts I used to prepare them are in this folder.
This was done using a mix of fsl commands and matlab code.
Mostly, I ran these scripts by chunks, not as full scripts.

SEL2_make-Anatomical_ROIs_Oded: this script runs fsl's first to segment the hippocampus, registers the epi to mprage using fsl's BBR (and inverse the matrix), and applies the transformation matrix from mprage to epi on the hippocampal subfields. Then it also copies the files and organizes, this was because I was working on it on my computer, and had to copy things to the lab's computer to continue analysis.

split_hipp_axis_Oded: split the hippocampus to thirds, based on the anterior to posterior axis

GetSubjSpaceROICoord: The group level rois I got from the connectivity analysis were in MNI. To obtain the similarity values, I wanted to get them back to subject space. This script did that. then, for the lifg and other cortical rois, a sphere was blown in subj space. This script uses the get_orig_coord2 script that is in this folder as well.


SEL2_apply_fast_maskOnRois: run FAST for each participant. Also has a section that and applies the grey matter mask on rois.

SEL2_CreateSubSpaceSphere: create a shpere aroound a voxel in subject space. was used to create subject specific spheres for cortical rois. Create the sphere, and applies the grey matter mask that was created using fsl FAST with SEL2_apply_fast_maskOnRois.

## 2. pre_post folder: Pre/post similarity analyses
has all the analyses to grab the tstats, create the group level structure and run the stats.

single_item_ROI_compute_mat_files: grabs the roi data (t-stats in all voxels in an roi) per participant, arrange them in a matlab structure.
single_item_ROI_AssNonAssAverageBetas: uses the matlab structure created by single_item_ROI_compute_mat_files, and compute the similarity values for associated (ASS) versus shuffled pairs (NONASS) based on each participant specific pairing. Participants pairings are loaded from a behavioral file (found in the osf repository), or, you can modify the script to directly upload each participants' associates.mat file, found in the associates_strucutre folder (see below). outputs a matlab strucutre with the group results (i.e., each participant average values, to go to statistical analysis.
* This script also exclude pairs for which participants did not recognize the famous face (see paper, Methods), using the subfunction, in the script, called ExludeUnknownFamous.
single_item_ROI_RemForgAverageBetas: same as AssNonAss, but computes similarity based on memory. Participants pairings and memory stauts are loaded from a behavioral file (found in the osf repository), or, you can modify the script to directly upload each participants' associates_RemForg.mat file, found in the associates_strucutre folder (see below).
single_item_ROI_AssNonAssAverageBetasAsymmetry: same as the two above, computes the asymmetry measure (like in left IFG, regardless of memory). This script loads the associates strucutre, rather than re-making it based on the behavioral log, if you want to do that.
single_item_ROI_RemForgAverageBetasAsymmetry: same as above, computes the asymmetry measure separately for remembered and forgotten. Reported in the supplementary, and mentioned in the main text. This script loads the associates_RemForg strucutre, rather than re-making it based on the behavioral log, if you want to do that.

## 3. functional connectivity (gPPI) during associative learning
We report functional connectivity with the left anterior hippocampus. This was done using the gPPI toolbox in matlab (McLaren et al. 2012), and some costume scripts, that are modified versions of the toolbox scripts, to adapt for the current study.

gPPI_wrapper_SEL2_anatomical_roi: wrapper script that runs the analysis
PairsRepContrasts.mat: contrasts mat needed for the analysis, runs the contrasts after conducting the gPPI models.
PairsRep_gPPI.mat: gPPI runs using a .mat structure that has all kinds of definitions - this is it.
SEL2_normalize_ppi_con.m: after running the gPPI in subjects' native epi space, I used this script to register them to MNI. This script uses SPM template: normalize_con_images.mat, found in the templates folder inside the functional_connectivity folder.

FilesRelocationPairsRepPPI: this file copies the participants' contrast files to a group folder, for group level analysis. The group level analysis is then done using SPM gui.

* note that gPPI (see 3. functional connectivity) is run after the univariate models have ran. To run the gPPI in the subject native space (because the left anterior hipp sead region was segmented anatomicaly for each participant, doesn't make sense to run the analysis in MNI space), I needed to run the univariate models on data from the associative learning that was not registered to MNI, that was done by running the model_msessions_SEL2_pairsReps scripts, only on unnormalized images (SPM calls registration to MNI "normalizaion").

### 3.1 first level scripts:
I had to modify some of the toolbox scripts to debug them, first level scripts are scripts that are used to run the analysis in the participant level. they are found in this folder.The wrapper script calls them.

## associates_strucutre
includes these files per participant:
associates.mat: includes the pairing per subject
associates_RemForg.mat: includes the pairing and the memory outcome per subject
