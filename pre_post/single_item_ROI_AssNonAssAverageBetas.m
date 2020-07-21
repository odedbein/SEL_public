function single_item_ROI_AssNonAssAverageBetas(TextFile)                                                                     
                                             
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

%TextFile - (0) - don't create a text file with the results, (1) - create a
%textfile.

% The script brakes after ~500 clusters with 360 betas each

%list of analyses names, if need to re-run:
%'epi' - anatoimcaly defined regions

%clear all;
CWD=pwd;
proj_dir='/Users/oded/research/SEL2/ANALYSIS_SPM8/';
analysis_dir='GROUP/Similarity/ROI_analysis_unnormalized/AnalysisTValsAllTrials';
mat_files_dir= fullfile(proj_dir,analysis_dir,'subs_mat_files');
Results_folder=fullfile(proj_dir,analysis_dir,'Results','Average_betas','asymmetry_April2020');
if ~isdir(Results_folder), mkdir(Results_folder); end

analysis='gPPI_lant_hipp_F_NF';
gm=0;%if regions are from a group-level contrast, only grey matter was extracted, and the mask file name has gm at the end, so remove it (1). put 0 if unnecessary.
Results_folder='Results';
Results_folder=fullfile(pwd,Results_folder,'Average_betas');
if ~isdir(Results_folder), mkdir(Results_folder); end
betas_in_session=48;
items_in_cond=12;
num_conds=2;

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

masks= {...
    'gPPI_lant_hipp_F_NF_lIFG_sphereBlownInSubjSpace_12_gm',...
    'gPPI_lant_hipp_F_NF_lIFG_sphereBlownInSubjSpace_10_gm',...
    'gPPI_lant_hipp_F_NF_lAG_sphereBlownInSubjSpace_12_gm',...
    'gPPI_lant_hipp_F_NF_dmPFC_ant_small_sphereBlownInSubjSpace_12_gm',...
    'gPPI_lant_hipp_F_NF_dmPFC_sphereBlownInSubjSpace_12_gm',...
    'gPPI_lant_hipp_F_NF_lMFG_sphereBlownInSubjSpace_12_gm',...
    'gPPI_lant_hipp_F_NF_rIFG_sphereBlownInSubjSpace_12_gm',...
    'gPPI_lant_hipp_F_NF_lOFC_sphereBlownInSubjSpace_12_gm',...
    };

%% use this if you want to cut the gm off the region's name:
% for r=1:numel(masks_temp)
%  if gm %define at line 31: %if regions are from a group-level contrast, only grey matter was extracted, and the mask file name has gm at the end, so remove it beacuse it's not there in the matfiles (1). put 0 if unnecessary.
%         masks{r,1}=masks_temp(r).name(1:(find(masks_temp(r).name=='_',1,'last')-1));
%  elseif strcmp(analysis,'epi') %remove the .nii from the file names
%         masks{r,1}=masks_temp(r).name(1:(find(masks_temp(r).name=='.',1,'last')-1));
%  end
% end
%%

ResultsAssNonAss={};
ResultsAssNonAssOnlyNum={};

clust_num=length(masks);
sub_cor_vals=nan(length(subs),num_conds*2*2,clust_num); %numconds*2 - for associated and non-associated,and another time *2 for sessions 1-2 and 3-4

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%claculate similarity for culster per subject
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   for j=1:length(subs)
      fprintf('analysing subj %s\n',subs{j})
      subject=char(subs{j});
      associates=read_pairs_log(subject,mat_files_dir); 
      for i=1:clust_num
         mask_nm=masks{i};
         
         cd(mat_files_dir);
         file_name=sprintf('PRE_%s_%s.mat', subject,mask_nm);
         
         if exist (file_name)
         load(file_name, 'clust_mat_sim'); %this mat has voxels in rows and betas in columns
         data=clust_mat_sim(find(clust_mat_sim(:,1)),:);%to remove Nans
         if size(data,1)<10 %less than 10 voxels
             fprintf('subj %s region %s has less than 10 voxels',subject,mask_nm)
         end
         %else
         data_av=(data(:,1:betas_in_session)+data(:,betas_in_session+1:end))/2;
         PREsim_matrix=corrcoef(data_av);
         file_name=sprintf('POST_%s_%s', subject,mask_nm);
         load(file_name, 'clust_mat_sim'); %this mat has voxels in rows and betas in columns
         data=clust_mat_sim(find(clust_mat_sim(:,1)),:);%to remove Nans
         data_av=(data(:,1:betas_in_session)+data(:,betas_in_session+1:end))/2;
         POSTsim_matrix=corrcoef(data_av);
         %item columns - each item is in a column based on this
         %devision (multiplied by 4 for for sessions):
         %devision:
         % Famous F 1-12: 1-12
         % NF F 1-12: 13-24
         % Bface F 1-24: 25-48
         % Task AFace Famous 1-3:49-51
         % Task AFace NonFamous 1-3:52-54
         % Task BFace Famous 1-6:55-60
         % Task BFace NonFamous 1-6:61-66
         %betas 1-66 are for session 1,67-132 are fors session 2 etc.
         
         %compute similarity of the ASSociated items and the NONASSociated items
         %order of columns in the output matrix is: FF12ASS FF12NONASS NFF12ASS NFF12NONASS
         %and all repeated for 3,4 (POST) correlations
         
         %%%like SEL1  -measure between sessions and average
         for cond=1:num_conds
             curr_items=[1:1:items_in_cond]+((cond-1)*items_in_cond);
             if cond==1 %this is the famous condition, need to exclude some famous for some of the subjects:
                curr_items=ExludeUnknownFamous(curr_items,subject);
             end
             %corr (PRE) AFace with BFace:
             cor_mat1=PREsim_matrix(curr_items,associates(curr_items,2));
             corr_ass1=diag(cor_mat1);
             corr_nonass1up=triu(cor_mat1,1);corr_nonass1low=tril(cor_mat1,-1);
%              %corr second session (PRE) AFace with first session BFace:
%              cor_mat2=PREsim_matrix(curr_items+betas_in_session,associates(curr_items,2));
%              corr_ass2=diag(cor_mat2);
%              corr_nonass2up=triu(cor_mat2,1);corr_nonass2low=tril(cor_mat2,-1);
             sub_cor_vals(j,(cond-1)*2+1,i)=mean(corr_ass1);
             sub_cor_vals(j,(cond-1)*2+2,i)=mean([mean(corr_nonass1low(find(corr_nonass1low))) mean(corr_nonass1up(find(corr_nonass1up)))]);
             
             %corr (POST) AFace with BFace:
             cor_mat3=POSTsim_matrix(curr_items,associates(curr_items,2));
             corr_ass3=diag(cor_mat3);
             corr_nonass3up=triu(cor_mat3,1);corr_nonass3low=tril(cor_mat3,-1);
%              %corr forth session (POST) AFace with third session BFace:
%              cor_mat4=POSTsim_matrix(curr_items+betas_in_session,associates(curr_items,2));
%              corr_ass4=diag(cor_mat4);
%              corr_nonass4up=triu(cor_mat4,1);corr_nonass4low=tril(cor_mat4,-1);
             sub_cor_vals(j,num_conds*2+(cond-1)*2+1,i)=mean(corr_ass3);
             sub_cor_vals(j,num_conds*2+(cond-1)*2+2,i)=mean([mean(corr_nonass3low(find(corr_nonass3low))) mean(corr_nonass3up(find(corr_nonass3up)))]);
         end %ends the loop of all conditions
         %end %ends the less than 10 voxels per region
        end %ends the conditional of whether the region exists or not in the specific subject  
    end%ends all the clusters loop

   end%ends all the subjects loop
   
   %make the results structure:
   
   header={'subjects' 'FF12ASS' 'FF12NONASS' 'NFF12ASS' 'NFF12NONASS' 'FF34ASS' 'FF34NONASS' 'NFF34ASS' 'NFF34NONASS'};
   Output=cell(length(subs)+1,num_conds*2*2);
   Output(1,1:numel(header))=header;
   Output(2:numel(subs)+1,1)=subs;
   cell_rows=ones(1,size(sub_cor_vals,1));
   cell_cols=ones(1,size(sub_cor_vals,2));
   %write a file for each cluster
   for i=1:clust_num
      mask_nm=masks{i}; 
      ResultsAssNonAssOnlyNum.(mask_nm)=sub_cor_vals(:,:,i);
      curr_cor_mat=mat2cell(sub_cor_vals(:,:,i),cell_rows,cell_cols);
      Output(2:end,2:end)=curr_cor_mat;
      ResultsAssNonAss.(mask_nm)=Output;
      
      if TextFile
      file=sprintf('results_simAssNonAssAverageBetas_%s',mask_nm);
      outputfile=fullfile(Results_folder,file);
      xlswrite(outputfile,Output);
      end
   end
   save(fullfile(Results_folder,sprintf('%s_AssNonAss.mat',analysis)),'ResultsAssNonAssOnlyNum','ResultsAssNonAss');

cd(CWD);
end

%% %%%sub functions%%%%%%%%%%
function curr_items=ExludeUnknownFamous(curr_items,subject)

switch subject
    case '200615TF'
        curr_items=curr_items(1:11);
    case '230615RE'
        curr_items=curr_items([1:6 8:12]);
    case '240715TP'
        curr_items=curr_items([1:9 11 12]);
    case '270615SA'
        curr_items=curr_items([1:6 8:12]);
    case '080815EF'
        curr_items=curr_items([1:3 5:12]);
end

end

function associates=read_pairs_log (subject,mat_files_dir)

%this function reads the subject's log and returns it as a matrix
Root = 'G:\shoshi\Shoshi_Backup_(C)\fMRI_Data\SEL2\behavioral\Analysis\Encoding'; % Location of file to be analyzed
fname = sprintf('analyzed_%s-SEL2_scanner_pairs.xlsx',subject); % Name of outfile to be produced
file = fullfile(Root,fname);

[digitsraw,strings,other]=xlsread(file);
string_hd=strings(1,:);
strings=[string_hd; strings(2:end,:)];
other=[string_hd; other(2:end,:)];
% adding a line and a column to numeric matrix, so it will have the same size as other matrices
 digits=zeros(size(strings,1),size(strings,2));
 digits(2:end,2:size(strings,2))=digitsraw;

RepetitionColumn='repetition(num)';%Name of the repetition column
RepCol=strcmp(other(1,:),RepetitionColumn);
RepCol=find(RepCol);

% Define last column
LastCol=size(strings,2);

workingmat=other(digits(:,RepCol)==1,:); % writable matrix
workingmat=[string_hd;workingmat];
for i=1:size(workingmat,1)
   
    %similarity onsets columns - each stimuli has a number based on this
    %devision:
    % Famous F 1-12: 1-12
    % NF F 1-12: 13-24
    % Bface F 1-24: 25-48
    % Task AFace Famous 1-3:49-51
    % Task AFace NonFamous 1-3:52-54
    % Task BFace Famous 1-6:55-60
    % Task BFace NonFamous 1-6:61-66
    if (strcmp(strings(i,5),'Famous'))
           workingmat{i,LastCol+1}=digits(i,7);
    elseif (strcmp(strings(i,5),'NF'))
           workingmat{i,LastCol+1}=digits(i,7)+12;
    else
       workingmat{i,LastCol+1}=0; 
       workingmat{i,LastCol+2}=0; 
    end
    
    workingmat{i,LastCol+2}=digits(i,10)+24;
end
associates=cell2mat(workingmat(:,LastCol+1:LastCol+2));
associates=associates(find(associates(:,1)),:);
associates=sortrows(associates,1);
filename=fullfile(mat_files_dir,sprintf('%s_associates',subject));
save(filename,'workingmat');
end
