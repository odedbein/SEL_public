# SEL_public

SEL, public folder

These are the scripts I used to analyze the data for Bein et al., 2020 (accepted), NatComms: *"Prior knowledge promotes hippocampal separation but cortical assimilation in the left inferior frontal gyrus". I did not clean them well enough, and also - this project is from the before/begining of my PhD. So the code is messy. Feel free to contact at oded.bein@nyu.edu Relevant data is abvailable on: https://osf.io/u2h3s/

## 0. Behavior
The scripts analyse_SEL2_scanner_* in this folder take the log files, miminaly process them and create xls files per participant (these are the files in the osf repository).
These files also create the relevant onsets.
The file that has "ret" at the end is for retrieval, and is only doing behavioral analysis, the imaging data was not analysed (trials were not time limited).

Then, I was very low tech and copied pasted all to a file with all participants. This way I created the file SEL2_all_subs.

Group level analysis was done using pivot tables on this file, and copying relevant data to the file data_paper_forR, found in the misc_group_level folder. The data in the file data_paper_forR is equivalent to the data in the Source Data file for the paper.
