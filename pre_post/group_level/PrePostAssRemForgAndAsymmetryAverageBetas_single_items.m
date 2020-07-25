function PrePostAssRemForgAndAsymmetryAverageBetas_single_items()

CWD=pwd;
proj_dir='/Users/oded/research/SEL2/ANALYSIS_SPM8/';
analysis_dir='GROUP/Similarity/ROI_analysis_unnormalized/AnalysisTValsAllTrials';
mat_files_dir= fullfile(proj_dir,analysis_dir,'subs_mat_files');
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
    '080815LR';... #'080815RM';... no memory
    '080815TN';...
    '110815EZ';...
    
    };

masks= {...
    'gPPI_lant_hipp_F_NF_lIFG_sphereBlownInSubjSpace_12_gm',...
    'epi_lhipp_ant'...
    };

ResultsAssNonAss={};
ResultsAssNonAssOnlyNum={};
num_comp=2; %ass,non-ass
num_cond=2;
clust_num=length(masks);
header={'subjects' 'PK_nPK' 'Face_num' 'UnknownFamous' 'memory' 'ASS' 'NONASS' 'Asym_ASS' 'Asym_NONASS'};
sub_cor_vals=nan(length(subs)*items_in_cond*num_cond,num_comp*2,clust_num); %numconds*num_comp - for associated and non-associated
ExludeUnknownFamousALL=nan(length(subs)*items_in_cond*num_cond,1);
MemAll=nan(length(subs)*items_in_cond*num_cond,1);
subsAll={};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%claculate similarity for culster per subject - btw sessions, as in SEL1 -
%similarity is examined between AFace sess1 and BFace sess 2 and the
%opposite
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:length(subs)
    display(sprintf('analysing subj %s\n',subs{j}));
    %set up the subject variable:
    subsAll((j-1)*items_in_cond*num_cond+(1:items_in_cond*num_cond))=subs(j);
    subject=char(subs{j});
    load(fullfile(mat_files_dir,sprintf('%s_associates_RemForg',subject)));
    associates=cell2mat(workingmat(2:end,29:end));
    associates=associates(find(associates(:,1)),:);
    rem_forg_associates=sortrows(associates,1);
    
    load(fullfile(mat_files_dir,sprintf('%s_associates',subject)));
    associates=cell2mat(workingmat(2:end,22:23));
    associates=associates(find(associates(:,1)),:);
    associates=sortrows(associates,1);
    
    %set up the memory column
    mem=rem_forg_associates(:,3)-1;
    %add 1 to mark HC remembered
    HC=rem_forg_associates(:,4)~=1; %no 'maybe' response
    HC(~mem)=0; %%%
    mem=mem+HC;
    mem(rem_forg_associates(:,4)==0)=0;
    MemAll((j-1)*items_in_cond*num_cond+(1:items_in_cond*num_cond))=mem;
    
    %now brain data:
    for i=1:clust_num
        mask_nm=masks{i};
        file_name=fullfile(mat_files_dir,sprintf('PRE_%s_%s.mat', subject,mask_nm));
        if exist (file_name)
            %% caslculate pre-post similarity differneces
            load(file_name, 'clust_mat_sim'); %this mat has voxels in rows and betas in columns
            data=clust_mat_sim(find(clust_mat_sim(:,1)),:);%to remove Nans
            if size(data,1)<10 %less than 10 voxels
                fprintf('subj %s region %s has less than 10 voxels',subject,mask_nm)
            end
            %else
            data_av=(data(:,1:betas_in_session)+data(:,betas_in_session+1:end))/2;
            PREsim_matrix=corrcoef(data_av);
            file_name=fullfile(mat_files_dir,sprintf('POST_%s_%s.mat', subject,mask_nm));
            load(file_name, 'clust_mat_sim'); %this mat has voxels in rows and betas in columns
            data=clust_mat_sim(find(clust_mat_sim(:,1)),:);%to remove Nans
            data_av=(data(:,1:betas_in_session)+data(:,betas_in_session+1:end))/2;
            POSTsim_matrix=corrcoef(data_av);
            %item columns - each item is in a column based on this
            %devision (multiplied by 4 for for sessions):
            % Famous F 1-12: 1-12
            % NF F 1-12: 13-24
            % Bface F 1-24: 25-48
            
            %compute similarity of the ASSociated items and the NONASSociated items
            %order of columns in the output matrix is: FF12ASS FF12NONASS NFF12ASS NFF12NONASS
            %and all repeated for 3,4 (POST) correlations
            
            for cond=1:num_conds
                curr_items=[1:1:items_in_cond]+((cond-1)*items_in_cond);
                %here, we just mark them, and remove all later:
                if i==1
                    if cond==1 %this is the famous condition, need to exclude some famous for some of the subjects:
                        ExItems=ExludeUnknownFamous(curr_items,subject);
                        ExludeUnknownFamousALL(((j-1)*items_in_cond*num_cond + (cond-1)*items_in_cond) + (1:items_in_cond))=ismember(curr_items,ExItems);
                    else
                        ExludeUnknownFamousALL(((j-1)*items_in_cond*num_cond + (cond-1)*items_in_cond) + (1:items_in_cond))=ones(items_in_cond,1);
                    end
                end
                
                
                %corr (PRE) AFace with BFace:
                cor_mat1=PREsim_matrix(curr_items,associates(curr_items,2));
                corr_ass1=diag(cor_mat1);
                corr_nonass1up=triu(cor_mat1,1);corr_nonass1low=tril(cor_mat1,-1);
                corr_non_ass1=corr_nonass1low(:,1:(end-1))+corr_nonass1up(:,2:end); %this removes the diag,
                %now each row is all the non-ass per item, average all to get
                %a measure of similarity for the non-ass. the specific
                %item-similarity is the ass-nonass per item
                
                %corr (POST) AFace with BFace:
                cor_mat3=POSTsim_matrix(curr_items,associates(curr_items,2));
                corr_ass3=diag(cor_mat3);
                corr_nonass3up=triu(cor_mat3,1);corr_nonass3low=tril(cor_mat3,-1);
                corr_non_ass3=corr_nonass3low(:,1:(end-1))+corr_nonass3up(:,2:end); %this removes the diag,
                
                %calculate the differences per participant
                ass=corr_ass3-corr_ass1;
                nonass=mean(corr_non_ass3,2)-mean(corr_non_ass1,2);
                
                sub_cor_vals(((j-1)*items_in_cond*num_cond + (cond-1)*items_in_cond) + (1:items_in_cond),1,i)=ass; %Associated Face
                sub_cor_vals(((j-1)*items_in_cond*num_cond + (cond-1)*items_in_cond) + (1:items_in_cond),2,i)=nonass; %Nonass Face
                
            end %ends the loop of all conditions
            
            %% calculate the asymmetry measure:
            file_name=fullfile(mat_files_dir,sprintf('PRE_%s_%s.mat', subject,mask_nm));
            load(file_name, 'clust_mat_sim'); %this mat has voxels in rows and betas in columns
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
                
                %AFace POST with BFace PRE:
                cor_mat1=sim_matrix(curr_items+betas_in_session,associates(curr_items,2));
                corr_ass1=diag(cor_mat1);
                corr_nonass1up=triu(cor_mat1,1);corr_nonass1low=tril(cor_mat1,-1);
                corr_non_ass1=corr_nonass1low(:,1:(end-1))+corr_nonass1up(:,2:end); %this removes the diag,
                %now each row is all the non-ass per item, average all to get
                %a measure of similarity for the non-ass. the specific
                %item-similarity is the ass-nonass per item
                
                % BFace POST with AFace PRE:
                cor_mat3=sim_matrix(curr_items,associates(curr_items,2)+betas_in_session);
                corr_ass3=diag(cor_mat3);
                corr_nonass3up=triu(cor_mat3,1);corr_nonass3low=tril(cor_mat3,-1);
                corr_non_ass3=corr_nonass3low(:,1:(end-1))+corr_nonass3up(:,2:end); %this removes the diag,
                %now each row is all the non-ass per item, average all to get
                %a measure of similarity for the non-ass. the specific
                %item-similarity is the ass-nonass per item
                
                %subtruct, to get hte asymmetry measure - note that I'm
                %doing BFace POST with AFace PRE - AFace POST with BFace PRE:
                %how much B moved to A more than A moved to B
                ass=corr_ass3-corr_ass1;
                nonass=mean(corr_non_ass3,2)-mean(corr_non_ass1,2);
                sub_cor_vals(((j-1)*items_in_cond*num_cond + (cond-1)*items_in_cond) + (1:items_in_cond),3,i)=ass; %Associated Face
                sub_cor_vals(((j-1)*items_in_cond*num_cond + (cond-1)*items_in_cond) + (1:items_in_cond),4,i)=nonass; %Nonass Face
                
            end %ends the loop of all conditions
        end %ends the conditional of whether the region exists or not in the specific subject
    end%ends all the clusters loop
    
end%ends all the subjects loop

%make the results structure:
%header={'subjects' 'PK_nPK' 'Face_num' 'UnknownFamous' 'memory' 'ASS' 'NONASS' 'Asym_ASS' 'Asym_NONASS'};
%set up Output
Output=cell(size(sub_cor_vals,1)+1,numel(header)); %put the header so that it's easy for ResultsAssNonAss
Output(2:end,1)=subsAll';
Output(2:end,2)=num2cell(repmat([ones(items_in_cond,1);zeros(items_in_cond,1)],numel(subs),1));
Output(2:end,3)=num2cell(repmat((1:items_in_cond*num_cond)',numel(subs),1));
Output(2:end,4)=num2cell(ExludeUnknownFamousALL);
Output(2:end,5)=num2cell(MemAll);
%write a file for each cluster
for i=1:clust_num
    mask_nm=masks{i};
    ResultsAssNonAssOnlyNum.(mask_nm)=sub_cor_vals(:,:,i);
    curr_cor_mat=num2cell(sub_cor_vals(:,:,i));
    Output(2:end,6:end)=curr_cor_mat;
    ResultsAssNonAss.(mask_nm)=Output;
    %set up the table to write
    T=array2table(Output(2:end,:));
    T.Properties.VariableNames=header;
    filename=fullfile(Results_folder,sprintf('AvBetas_PrePost_Mem_Asym_single_items_%s.xlsx',mask_nm));
    %write the table:
    writetable(T,filename);
    %write the mat
    save(fullfile(Results_folder,sprintf('AvBetas_PrePost_Mem_Asym_single_items_%s.mat',mask_nm)),'ResultsAssNonAssOnlyNum','ResultsAssNonAss');
end

end

%% %%%sub functions%%%%%%%%%%
function curr_items=ExludeUnknownFamous(curr_items,subject)

switch subject
    case '200615TF'
        curr_items=curr_items(1:11);
    case '230615RE'
        curr_items=curr_items([1:6 8:12]);
    case '240715NK'
        curr_items=curr_items([1 3 8:12]);
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

