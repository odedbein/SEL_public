function FilesRelocationPairsRepPPI()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PART I: copy ENCODING files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%variables and folder

DirName='F:\shoshi\Shoshi_Backup_(C)\fMRI_Data\SEL2\ANALYSIS_SPM8\';% Root location of analysis folder


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


region={...
      'epi_lhipp_ant';...
       };

resdir= 'results_pairsRep_smt_unnorm_msessions';
destdir='gPPI\GROUP_pairs_RepModel';
% nconts=length(condnm);

for r=1:numel(region)
    roi=region{r};

for j=1:numel(subs)
    patient=subs{j};
    
    Files=dir(fullfile(DirName,patient,resdir, sprintf('PPI_%s',roi),'wcon_*'));
    
    for i = 1:2:numel(Files) %one image file and one header file

        
        loc=find(Files(i).name=='_');
        condnm= Files(i).name((loc(2)+1):(loc(end)-1));
        ContrastFolder = fullfile(DirName, destdir,roi,condnm);

            if ~exist(ContrastFolder)
            mkdir (ContrastFolder);
            mkdir (fullfile(ContrastFolder,'subs_con_files'));
            end
         
        FileSource=fullfile(DirName,patient,resdir, sprintf('PPI_%s',roi), Files(i).name);%that's the hdr
        FileDestination=fullfile(ContrastFolder, 'subs_con_files',Files(i).name); 
        copyfile(FileSource, FileDestination)
        
        FileSource=fullfile(DirName,patient,resdir, sprintf('PPI_%s',roi), Files(i+1).name); %that's the img
        FileDestination=fullfile(ContrastFolder, 'subs_con_files',Files(i+1).name); %that's the hdr
        copyfile(FileSource, FileDestination)
    end

end %ends the subjects loop
end %ends the regions loop

clear all
