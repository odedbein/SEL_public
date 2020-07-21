function ResultsAssNonAssOnlyNum=single_item_ROI_AssNonAssAverageBetasAsymmetry()

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

%computes whether there is an assymetry in the change of representation.
%i.e., if madonna and its B-face got more similar (as we saw in the putemen), did e.g., Madonna stayed the same and the B-face
%representation changed from bbeofre learning to after, or did both just changed
%to become more similar to one another.
%This analysis only makes sense if some pre-post difference was observed - e.g., in
%the putamen famous became more similar to one another.
%TextFile - (0) - don't create a text file with the results, (1) - create a
%textfile.

% The script brakes after ~500 clusters with 360 betas each

%list of analyses names, if need to re-run:
%Famous_non_famous
%ExpDecF_NF'
%'epi' - anatoimcaly defined regions
%'Task_baseline'

CWD=pwd;
proj_dir='/Users/oded/research/SEL2/ANALYSIS_SPM8/';
analysis_dir='GROUP/Similarity/ROI_analysis_unnormalized/AnalysisTValsAllTrials';
mat_files_dir= fullfile(proj_dir,analysis_dir,'subs_mat_files');
%analysis='gPPI_lant_hipp_F_NF_spheres';
analysis='anatomical_hipp';
Results_folder=fullfile(proj_dir,analysis_dir,'Results','Average_betas','asymmetry_April2020');
if ~isdir(Results_folder), mkdir(Results_folder); end
gm=0;%if regions are from a group-level contrast, only grey matter was extracted, and the mask file name has gm at the end, so remove it (1). put 0 if unnecessary.
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


% these are the masks for asymmetry in the regions from hipp connectivity:
%     'gPPI_lant_hipp_F_NF_lIFG_sphereBlownInSubjSpace_12_gm',...
%     'gPPI_lant_hipp_F_NF_lIFG_sphereBlownInSubjSpace_10_gm',...
%     'gPPI_lant_hipp_F_NF_lAG_sphereBlownInSubjSpace_12_gm',...
%     'gPPI_lant_hipp_F_NF_dmPFC_ant_small_sphereBlownInSubjSpace_12_gm',...
%     'gPPI_lant_hipp_F_NF_dmPFC_sphereBlownInSubjSpace_12_gm',...
%     'gPPI_lant_hipp_F_NF_lMFG_sphereBlownInSubjSpace_12_gm',...
%     'gPPI_lant_hipp_F_NF_rIFG_sphereBlownInSubjSpace_12_gm',...
%     'gPPI_lant_hipp_F_NF_lOFC_sphereBlownInSubjSpace_12_gm',...
    
masks= {...
    'epi_lhipp_ant';...
    'epi_lhipp_post';...
    'epi_rhipp_ant';...
    'epi_rhipp_post';...
    };


ResultsAssNonAss={};
ResultsAssNonAssOnlyNum={};
num_comp=2; %ass,non-ass

clust_num=numel(masks);
sub_cor_vals=nan(numel(subs),num_conds*2*2,clust_num); %numconds*2 - for associated and non-associated,and another time *2 for sessions 1-2 and 3-4

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%claculate similarity for culster per subject - btw sessions, as in SEL1 -
%similarity is examined between AFace sess1 and BFace sess 2 and the
%opposite
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:length(subs)
    fprintf('analysing subj %s\n',subs{j})
    subject=char(subs{j});
    load(fullfile(mat_files_dir,sprintf('%s_associates',subject)));
    associates=cell2mat(workingmat(2:end,22:23));
    associates=associates(find(associates(:,1)),:);
    associates=sortrows(associates,1);
    for i=1:clust_num
        mask_nm=masks{i};
        %display(sprintf('analysing roi %s\n',mask_nm));
        %cd(mat_files_dir);
        file_name=fullfile(mat_files_dir,sprintf('PRE_%s_%s.mat', subject,mask_nm));
        
        if exist(file_name)
            load(file_name,'clust_mat_sim'); %this mat has voxels in rows and betas in columns
            data=clust_mat_sim;
            PREdata_av=(data(:,1:betas_in_session)+data(:,betas_in_session+1:end))/2;
            voxelsPRE=(clust_mat_sim(:,1)~=0);%to remove Nans
            %PREsim_matrix=corrcoef(data_av);
            file_name=fullfile(mat_files_dir,sprintf('POST_%s_%s.mat', subject,mask_nm));
            load(file_name, 'clust_mat_sim'); %this mat has voxels in rows and betas in columns
            data=clust_mat_sim;%to remove Nans
            voxelsPOST=(clust_mat_sim(:,1)~=0);%to remove Nans
            all_vox=((voxelsPRE+voxelsPOST)==2);
            POSTdata_av=(data(:,1:betas_in_session)+data(:,betas_in_session+1:end))/2;
            data_av=[PREdata_av(all_vox,:) POSTdata_av(all_vox,:)];
            
            sim_matrix=corrcoef(data_av);
            %item columns - each item is in a column based on this
            %devision (multiplied by 4 for for sessions):
            %devision:
            % Famous F 1-12: 1-12
            % NF F 1-12: 13-24
            % Bface F 1-24: 25-48
            
            %compute similarity of the ASSociated items and the NONASSociated items
            %order of columns in the output matrix is: FF12ASS FF12NONASS NFF12ASS NFF12NONASS
            %and all repeated for 3,4 (POST) correlations
            
            
            for cond=1:num_conds
                curr_items=[1:1:items_in_cond]+((cond-1)*items_in_cond);
                if cond==1 %this is the famous condition, need to exclude some famous for some of the subjects:
                    curr_items=ExludeUnknownFamous(curr_items,subject);
                end
                
                %AFace POST with BFace PRE:
                cor_mat1=sim_matrix(curr_items+betas_in_session,associates(curr_items,2));
                corr_ass1=diag(cor_mat1);
                corr_nonass1up=triu(cor_mat1,1);corr_nonass1low=tril(cor_mat1,-1);
                sub_cor_vals(j,(cond-1)*2+1,i)=mean(corr_ass1);
                sub_cor_vals(j,(cond-1)*2+2,i)=mean([mean(corr_nonass1low(find(corr_nonass1low))) mean(corr_nonass1up(find(corr_nonass1up)))]);
                
                % BFace POST with AFace PRE:
                cor_mat3=sim_matrix(curr_items,associates(curr_items,2)+betas_in_session);
                corr_ass3=diag(cor_mat3);
                corr_nonass3up=triu(cor_mat3,1);corr_nonass3low=tril(cor_mat3,-1);
                sub_cor_vals(j,num_conds*2+(cond-1)*2+1,i)=mean(corr_ass3);
                sub_cor_vals(j,num_conds*2+(cond-1)*2+2,i)=mean([mean(corr_nonass3low(find(corr_nonass3low))) mean(corr_nonass3up(find(corr_nonass3up)))]);
         
            end %ends the loop of all conditions
        end %ends the conditional of whether the region exists or not in the specific subject
    end%ends all the clusters loop
    
end%ends all the subjects loop

%make the results structure:

cd(CWD);
header={'subjects','FF_APOST_BPRE_ASS','FF_APOST_BPRE_NONASS','NFF_APOST_BPRE_ASS','NFF_APOST_BPRE_NONASS',...
        'FF_BPOST_APRE_ASS','FF_BPOST_APRE_NONASS','NFF_BPOST_APRE_ASS','NFF_BPOST_APRE_NONASS'};
%header={'subjects' 'Face_num' 'FF_Asym_ASS' 'FF_Asym_NONASS' 'NFF_Asym_ASS' 'NFF_Asym_NONASS'};
Output=cell(length(subs)+1,num_conds*2*2);
Output(1,1:numel(header))=header;
Output(2:numel(subs)+1,1)=subs;
cell_rows=ones(1,size(sub_cor_vals,1));
cell_cols=ones(1,size(sub_cor_vals,2));%write a file for each cluster
for i=1:clust_num
    mask_nm=masks{i};
    ResultsAssNonAssOnlyNum.(mask_nm)=sub_cor_vals(:,:,i);
    curr_cor_mat=mat2cell(sub_cor_vals(:,:,i),cell_rows,cell_cols);
    Output(2:end,2:end)=curr_cor_mat;
    ResultsAssNonAss.(mask_nm)=Output;
end
%save it:
    save(fullfile(Results_folder,sprintf('%s_AssNonAss.mat',analysis)),'ResultsAssNonAssOnlyNum','ResultsAssNonAss');
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

%sort it by the  order of the numbering 1-72
%use the sim script to assign the correct number to each item based on it's
%pair
%read also the RC data and assign a rem/forg value
%return it to the mane function
