 function single_item_ROI_RemForgAverageBetas(TextFile)                                                                    
                                             

%TextFile - (0) - don't create a text file with the results, (1) - create a
%textfile.

%list of analyses names, if need to re-run:
%'epi' - anatomically defined ROIs


%clear all;
proj_dir='/Users/oded/research/SEL2/ANALYSIS_SPM8/';
mat_files_dir= fullfile(proj_dir,'GROUP/Similarity/ROI_analysis_unnormalized/AnalysisTValsAllTrials/subs_mat_files');
analysis='gPPI_lant_hipp_F_NF_vmPFC_p01';
gm=0;%if regions are from a group-level contrast, only grey matter was extracted, and the mask file name has gm at the end, so remove it (1). put 0 if unnecessary.
Results_folder='Results';
Results_folder=fullfile(pwd,Results_folder,'Average_betas');
if ~isdir(Results_folder), mkdir(Results_folder); end
betas_in_session=48;
items_in_cond=12;
num_conds=2;
num_comp = 10;%number of total comparisons here - 5(rem,hc,forg,subchoich,subdist - see below)*2,for each session

CWR=pwd;

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

%obtain masks:
masks_temp=dir(fullfile(proj_dir,'200615TF/masks/*_mask.nii'));
masks={};
for r=1:numel(masks_temp)
    masks{r,1}=masks_temp(r).name(1:(find(masks_temp(r).name=='.',1,'last')-1));
end

%% use this if you want to cut the gm off the region's name:
% for r=1:numel(masks_temp)
%  if gm %define at line 31: %if regions are from a group-level contrast, only grey matter was extracted, and the mask file name has gm at the end, so remove it beacuse it's not there in the matfiles (1). put 0 if unnecessary.
%         masks{r,1}=masks_temp(r).name(1:(find(masks_temp(r).name=='_',1,'last')-1));
%  elseif strcmp(analysis,'epi') %remove the .nii from the file names
%         masks{r,1}=masks_temp(r).name(1:(find(masks_temp(r).name=='.',1,'last')-1));
%  end
% end
%%

ResultsRemForg={};
ResultsRemForgOnlyNum={};

clust_num=length(masks);
clust_start=1;
num_comp=5; 
sub_cor_vals=nan(length(subs),num_conds*num_comp*2,(clust_num-clust_start+1)); %numconds*5 - for all comparisons,and another time *4 for sessions 1,2, 3,4

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%claculate similarity for culster per subject
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   for j=1:length(subs)
      subject=char(subs{j});
      associates=read_ret_log(subject,mat_files_dir); %this function create a matrix with item numbers, their pair, and whether they were
      %remembered/forgotten see the function below
      for i=clust_start:clust_num
         
         %upload the relevant clust_mat_file, and compute the correlations
         %of all items with all items, for pre-learning and post-learning
         %similarity
         mask_nm=masks{i}; 
         cd(mat_files_dir);
         file_name=sprintf('PRE_%s_%s.mat', subject,mask_nm);
         
         if exist (file_name)
         load(file_name, 'clust_mat_sim'); %this mat has voxels in rows and betas in columns
         data=clust_mat_sim(find(clust_mat_sim(:,1)),:);%to remove Nans
         if size(data,1)<10 %less than 10 voxels
             fprintf('subj %s region %s has less than 10 voxels \n',subject,mask_nm)
         end
         data_av=(data(:,1:betas_in_session)+data(:,betas_in_session+1:end))/2;
         PREsim_matrix=corrcoef(data_av);
         file_name=sprintf('POST_%s_%s', subject,mask_nm);
         load(file_name, 'clust_mat_sim'); %this mat has voxels in rows and betas in columns
         data=clust_mat_sim(find(clust_mat_sim(:,1)),:);%to remove Nans
         data_av=(data(:,1:betas_in_session)+data(:,betas_in_session+1:end))/2;
         POSTsim_matrix=corrcoef(data_av);
         
         %next, you want to classify and select for averaging items based on their condition and
         %subsequent memory status
         %item columns - each item is in a column based on this
         %devision (multiplied by 4 for for sessions - 2 PRE (sessions 1,2) and 2 POST (sessions 3,4)):
         %similarity onsets columns - each stimuli has a number based on this
         %devision:
         % Famous F 1-12: 1-12
         % NF F 1-12: 13-24
         % Bface F 1-24: 25-48
         % Task AFace Famous 1-3:49-51
         % Task AFace NonFamous 1-3:52-54
         % Task BFace Famous 1-6:55-60
         % Task BFace NonFamous 1-6:61-66
         
         
         %The following section computes average similarity of the remembered,  HC (High confidence),forgottern and subject's choice (wwhat the subject
         %said that apeared regardless of whther she was right or wrong.
         %order of columns in the output file is: FF1REM FF1HC FF1FORG
         %FF1SUBCHOICE FF1SUBDIST multiplied by conditions,
         %and all repeated for sessions 1,2,3,4 correlations
         %%ADD THE ASSOCIATES STRUCTURE
         
         for cond=1:num_conds
             curr_items=[1:1:items_in_cond]+((cond-1)*items_in_cond); %select the items in the current condition
             
             if cond==1 %this is the famous condition, need to exclude some famous for some of the subjects:
                curr_items=ExludeUnknownFamous(curr_items,subject);
             end
             
             rem=(associates(curr_items,3))==2;
             HC=associates(curr_items,4)~=1; %no 'maybe' response
             HC(~rem)=0; %%%
             HC(associates(curr_items,4)==0)=0;
             forg=(associates(curr_items,3))==1;
             subchoice=associates(curr_items,5);
             subdist1=associates(curr_items,6);
             subdist2=associates(curr_items,7);
             sub_gave_resp=find(associates(curr_items,5));%this is null if subject did not provide a response
             
             %REMEMBERED: PRE corr AFace with BFace:
             cor_mat1=PREsim_matrix(associates(curr_items(rem),1),associates(curr_items(rem),2));
             sub_cor_vals(j,(cond-1)*num_comp+1,i)=mean(diag(cor_mat1));
            
             if ~isempty(find(HC))
             %HC:corr first session AFace with first session BFace:
             cor_mat1=PREsim_matrix(associates(curr_items(HC),1),associates(curr_items(HC),2));
             sub_cor_vals(j,(cond-1)*num_comp+2,i)=mean(diag(cor_mat1));
             
             end
             
             %FORGOTTEN:
             cor_mat1=PREsim_matrix(associates(curr_items(forg),1),associates(curr_items(forg),2));
             sub_cor_vals(j,(cond-1)*num_comp+3,i)=mean(diag(cor_mat1));
             
             %SUBCHOICE:
             cor_mat1=PREsim_matrix(curr_items(sub_gave_resp),subchoice(sub_gave_resp));
             sub_cor_vals(j,(cond-1)*num_comp+4,i)=mean(diag(cor_mat1));
             
             %SUBDIST:
             cor_mat11=PREsim_matrix(curr_items(sub_gave_resp),subdist1(sub_gave_resp));
             cor_mat12=PREsim_matrix(curr_items(sub_gave_resp),subdist2(sub_gave_resp));
             sub_cor_vals(j,(cond-1)*num_comp+5,i)=mean([diag(cor_mat11)' diag(cor_mat12)']);
             
             %%%%%% COMPUTE SIMILARITY IN SESSIONS 3-4
             
             %REMEMBERED: POST corr AFace with BFace:
             cor_mat1=POSTsim_matrix(associates(curr_items(rem),1),associates(curr_items(rem),2));
             sub_cor_vals(j,num_conds*num_comp+(cond-1)*num_comp+1,i)=mean(diag(cor_mat1));
            
             if ~isempty(find(HC))
             %HC:POST corr AFace with BFace:
             cor_mat1=POSTsim_matrix(associates(curr_items(HC),1),associates(curr_items(HC),2));
             sub_cor_vals(j,num_conds*num_comp+(cond-1)*num_comp+2,i)=mean(diag(cor_mat1));
             
             end
             
             %FORGOTTEN:
             cor_mat1=POSTsim_matrix(associates(curr_items(forg),1),associates(curr_items(forg),2));
             sub_cor_vals(j,num_conds*num_comp+(cond-1)*num_comp+3,i)=mean(diag(cor_mat1));
             
             %SUBCHOICE:
             cor_mat1=POSTsim_matrix(curr_items(sub_gave_resp),subchoice(sub_gave_resp));
             sub_cor_vals(j,num_conds*num_comp+(cond-1)*num_comp+4,i)=mean(diag(cor_mat1));
             
             %SUBDIST:
             cor_mat11=POSTsim_matrix(curr_items(sub_gave_resp),subdist1(sub_gave_resp));
             cor_mat12=POSTsim_matrix(curr_items(sub_gave_resp),subdist2(sub_gave_resp));
             sub_cor_vals(j,num_conds*num_comp+(cond-1)*num_comp+5,i)=mean([diag(cor_mat11)' diag(cor_mat12)']);
         end %ends the conditions loop
         %end %ends the less than 10 voxels per region
         end %ends the conditional of whether the region exists or not in the specific subject
      end%ends all the clusters loop

   end%ends all the subjects loop
    header={'subjects' 'FF12REM' 'FF12HC' 'FF12FORG' 'FF12SUBCHOICE' 'FF12SUBDIST'...
                      'NFF12REM' 'NFF12HC' 'NFF12FORG' 'NFF12SUBCHOICE' 'NFF12SUBDIST'...
                      'FF34REM' 'FF34HC' 'FF34FORG' 'FF34SUBCHOICE' 'FF34SUBDIST'...
                      'NFF34REM' 'NFF34HC' 'NFF34FORG' 'NFF34SUBCHOICE' 'NFF34SUBDIST'...
           };
   Output=cell(length(subs)+1,num_conds*num_comp*2);
   Output(1,1:numel(header))=header;
   Output(2:numel(subs)+1,1)=subs;
   cell_rows=ones(1,size(sub_cor_vals,1));
   cell_cols=ones(1,size(sub_cor_vals,2));
   %write a file for each cluster
   for i=1:clust_num
      mask_nm=masks{i};
      ResultsRemForgOnlyNum.(mask_nm)=sub_cor_vals(:,:,i);
      curr_cor_mat=mat2cell(sub_cor_vals(:,:,i),cell_rows,cell_cols);
      Output(2:end,2:end)=curr_cor_mat;
      ResultsRemForg.(mask_nm)=Output;
      
      if TextFile
          file=sprintf('resultsRemForgAvBetasOnlyKnownFamous_%s',mask_nm);
          outputfile=fullfile(Results_folder,file);
          xlswrite(outputfile,Output);
      end
   end
   save(fullfile(Results_folder,sprintf('%s_RemForg.mat',analysis)),'ResultsRemForgOnlyNum','ResultsRemForg');
   
   cd(CWR);
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

function associates=read_ret_log (subject,mat_files_dir)

%some variables for later, see below
chosen=[];
distractor1=[];
distractor2=[];

%this function reads the subject's log and returns a matrix pairing which
%items appeared together and their memory status. it is clear when
%overviewed with the analysed ret xlsx file, or when looking at
%"workingmat". if this is the first time you use it, I recommend puting a
%stop-point after the working mat line (line 249 before the loop starts),
%and then going over the loop to understand what it does. it is very clear
%once having the workingmat infront of the eyes.
Root = 'G:\shoshi\Shoshi_Backup_(C)\fMRI_Data\SEL2\behavioral\Analysis\Retrieval'; % Location of file to be analyzed
fname = sprintf('analyzed_%s-SEL2_scanner_CR.xlsx',subject); % Name of outfile to be produced
file = fullfile(Root,fname);

[digitsraw,strings,other]=xlsread(file);
string_hd=strings(1,:);
strings=[string_hd; strings(2:end,:)];
other=[string_hd; other(2:end,:)];
% adding a line and a column to numeric matrix, so it will have the same size as other matrices
digits=zeros(size(strings,1),size(strings,2));
digits(2:end,2:size(strings,2)-1)=digitsraw;

% Define last column
LastCol=size(strings,2);

workingmat=other; % writable matrix
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
    %memory = correct/incorrect
    if (strcmp(strings(i,24),'correct'))
       workingmat{i,LastCol+3}=2;
    elseif (strcmp(strings(i,24),'incorrect'))
       workingmat{i,LastCol+3}=1;
    else %miss
        workingmat{i,LastCol+3}=0;
    end
    %memory = confidence
    if (strcmp(strings(i,28),'sure'))
       workingmat{i,LastCol+4}=3;
    elseif (strcmp(strings(i,28),'unsure'))
       workingmat{i,LastCol+4}=2;
    elseif (strcmp(strings(i,28),'maybe'))
       workingmat{i,LastCol+4}=1;
    else %miss
        workingmat{i,LastCol+4}=0;
    end
    
    %memory = subject's response
    resp=digits(i,21);
    if isnan(resp)
       workingmat{i,LastCol+5}=0; 
       workingmat{i,LastCol+6}=0; 
       workingmat{i,LastCol+7}=0;
    else
        place=find([digits(i,11) digits(i,15) digits(i,19)]==resp);
        if place==1%subject selected the target in digits(i,11)
            chosen=10;
            distractor1=14;
            distractor2=18;
        elseif place==2%subject selected distA in digits(i,15)
            chosen=14;
            distractor1=10;
            distractor2=18;
        elseif place==3%subject selected distB in digits(i,19)
            chosen=18;
            distractor1=14;
            distractor2=10;
        end

        workingmat{i,LastCol+5}=digits(i,chosen)+24;
        
        workingmat{i,LastCol+6}=digits(i,distractor1)+24;
            
        workingmat{i,LastCol+7}=digits(i,distractor2)+24;
    end
end

workingmat{1,LastCol+1}='AFace';
workingmat{1,LastCol+2}='BFace';
workingmat{1,LastCol+3}='MemoryCorrectness';
workingmat{1,LastCol+4}='MemoryConfidence';
workingmat{1,LastCol+5}='Subject_chosen';
workingmat{1,LastCol+6}='Subject_dist1';
workingmat{1,LastCol+7}='Subject_dist2';
associates=cell2mat(workingmat(2:end,LastCol+1:end));
associates=associates(find(associates(:,1)),:);
associates=sortrows(associates,1);
filename=fullfile(mat_files_dir,sprintf('%s_associates_RemForg',subject));
save(filename,'workingmat');
end

