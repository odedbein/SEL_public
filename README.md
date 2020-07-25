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


### 2.1 group_level
has the files that plot and run stats on the group level analysis (some additional analyses are done in R, file is in the misc_group_level). The scripts require first to load the relevant matlab structure created by the previous scripts (e.g., single_item_ROI_RemForgAverageBetas, each file takes its output from the relevant single_item* file ).

Analyse_plot_AssNonAss_forPaper: run group level analysis,plot and stats, for the paired vs. shuffled pre to post similarity difference comparisons (this is reported in the paper for left IFG, no plot; reported in the supplementary for other rois from the hippocmpal connectivity analysis)

Analyse_plot_RemForg_plot_paper: run group level analysis,plot and stats, for the the comparisons based on memory (reported for the left ant hipp in the main text, and then some other rois in the supp).

Analyse_plot_AssNonAss_Assymetry: run group level analysis,plot and stats, for the asymmetry measure for paired vs. shuffled comparisons (this is reported in the paper as the main left IFG finding, and in supp for other cortical rois).

Analyse_plot_RemForg_Asymmetry: run group level analysis,plot and stats, for the asymmetry measure for remembered vs. forgoten. Reported in the supplementary note 7.

* The supplementary figures 5 and 6 (and the relevant analysis in supplementary notes 8 and 9, correspondingly) were also created using these scripts, but with uploading the data from the relevant rois.

* The supplementary Note 5 (pre and post values in the left anterior hipp): this is produced by the Analyse_plot_RemForg_plot_paper script.

There are two repeated measures ANOVA files I used in this folder - the scripts use one or both.. don't remember which, so I uploaded both.

#### files for supplementary analyses:
Analyse_plot_AssNonAss_Assymetry_plot_each_score_supp: this plots and run analyses for figure 4 and related note 6. These are the values that compose the asymmetry.

Analyse_plot_RemForg_Asymmetry: same as above, but by memory (reported in the supplementary for both the hippocampus and the left IFG regions).

PrePostAssRemForgAndAsymmetryAverageBetas_single_items: this file creates the pairs data for the correlation btw hipp and lifg, reported in supp. fig. 2. The xlsx files it creates are also provided in the misc group files. Builds on the the matfiles per participant (created in section 3).

single_item_ROI_RemForgAverageBetas_subsample_trials: for the analysis reported in supp fig. 3, and note 4. This creates the distribution of values by subsampling trials to control for differnet numbers of trials in the rem/forg bins in the hipp analysis. Note that some things are copied from prior code, so there might be some unused variables/chunk of codes.

Analyse_plot_RemForg_subsampling_for_supp: this file plots and does some summary measures on the distribution of samples created by the previous script single_item_ROI_RemForgAverageBetas_subsample_trials. 

SEL2_control_univar_analysis_for_paper_linear_regressions: uses the structures created by the previous script, and runs the analyses. The outputs of the previous scripts were copied to the xlsx file i used for the analysis, and are to be found in SOURCE_DATA.xlsx file

RemForg_Rev2Analysis_FpostFpreSim: related to supp note 10. Comparing a face to itself from before and after learning. This script gather the values and create the group level strucutre for the next script.

Analyse_plot_Rev2Analysis_FpostFpreSim: related to supp note 10. this script takes the structure created by RemForg_Rev2Analysis_FpostFpreSim and run group level analysis.

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

## misc group level
Mostly, the analyses scripts above created a data structure with all subjects and all bins/conditions etc, and did most of the group level stats and plots. This folder does the group level analyses for some analyses, as is explained in the different chunks of code in SEL_analysis_for_paper code.

* SOURCE_DATA.xlsx: SEL2_analysis_for_paper script reads the group data from that file - which is copy paste from data structures created through the MATLAB files. it has group level data - it is identical to the SOURCE_DATA file provided with the paper, only I added some sheets that were not in figures/weren't requested in the source data file.
* SEL2_analysis_for_paper:group level stats and plots

* AvBetas_PrePost_Mem_Asym_single_items_gPPI_lant_hipp_F_NF_lIFG_sphereBlownInSubjSpace_12_gm, AvBetas_PrePost_Mem_Asym_single_items_epi_lhipp_ant: these are the files used to run the correlation btw hipp and lifg, reported in Supp Fig. 2


## associates_strucutre
includes these files per participant:
associates.mat: includes the pairing per subject
associates_RemForg.mat: includes the pairing and the memory outcome per subject
