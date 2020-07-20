# SEL_public

SEL, public folder

These are the scripts I used to analyze the data for Bein et al., 2020 (accepted), NatComms: *"Prior knowledge promotes hippocampal separation but cortical assimilation in the left inferior frontal gyrus". I did not clean them well enough, and also - this project is from the before/begining of my PhD. So the code is messy. Feel free to contact at oded.bein@nyu.edu Relevant data is abvailable on: https://osf.io/u2h3s/

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

## 1.2 Anatomical ROIs - hippocampus segmentation
## 2. pre_post folder: Pre/post similarity analyses

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

