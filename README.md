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

model_msessions_SEL2_PRE_POST_similairity: runs the models of the pre/post similarity scans. outputs a t-map for each face, in each scan. I later on average pre and post.
model_msessions_SEL2_pairsReps: This is the model that was used to run the univariate analysis on the associative learning (pairs) task.

contrasts_SEL2_PRE_POST_sim_msessions: in SPM, to obtain t-maps, one needs to run contrasts after estimating the models. This does that for the pre/post similarity
contrasts_SEL2_pairsRep_msessions: in SPM, to obtain t-maps, one needs to run contrasts after estimating the models. This does that for the univariate analysis on the associative learning (pairs) task. It uses the csv file: contrasts_SEL2_pairsRep.csv
