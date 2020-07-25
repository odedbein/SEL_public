function RemForg_Rev2Analysis_FpostFpreSim(TextFile)


proj_dir='/Users/oded/research/SEL2/ANALYSIS_SPM8/';
analysis_dir='GROUP/Similarity/ROI_analysis_unnormalized/AnalysisTValsAllTrials';
mat_files_dir= fullfile(proj_dir,analysis_dir,'subs_mat_files');
%analysis='ExpDecF_NF';
analysis='Rev2Analysis_FpostFpreSim';
curr_regs='hipp_lifg';
%analysis='gPPI_lant_hipp_F_NF_vmPFC_p01';
gm=0;%if regions are from a group-level contrast, only grey matter was extracted, and the mask file name has gm at the end, so remove it (1). put 0 if unnecessary.
Results_folder=fullfile(proj_dir,analysis_dir,'Results','Average_betas',analysis);
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


%% define makses manually:
masks= {...
    'epi_lhipp_ant';...
    'gPPI_lant_hipp_F_NF_lIFG_sphereBlownInSubjSpace_12_gm';
    };

ResultsRemForg={};
ResultsRemForgOnlyNum={};

clust_num=length(masks);
clust_start=1;
num_comp=5;
sub_cor_vals=nan(length(subs),num_conds*num_comp*2,(clust_num-clust_start+1)); %numconds*5 - for all comparisons,and another time *4 for sessions 1,2, 3,4
header={'subjects' 'FF_A_REM' 'FF_A_HC' 'FF_A_FORG' 'FF_A_ASS' 'FF_A_NONASS'...
    'FF_B_REM' 'FF_B_HC' 'FF_B_FORG' 'FF_B_ASS' 'FF_B_NONASS'...
    'NF_A_REM' 'NF_A_HC' 'NF_A_FORG' 'NF_A_ASS' 'NF_A_NONASS'...
    'NF_B_REM' 'NF_B_HC' 'NF_B_FORG' 'NF_B_ASS' 'NF_B_NONASS'...
    };
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%claculate similarity for culster per subject
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:length(subs)
    subject=char(subs{j});
    %remembered/forgotten see the function below
    %associates=read_ret_log(subject,mat_files_dir); %this function create a matrix with item numbers, their pair, and whether they were
    load(fullfile(mat_files_dir,sprintf('%s_associates_RemForg',subject)));
    associates=cell2mat(workingmat(2:end,29:end));
    associates=associates(find(associates(:,1)),:);
    rem_forg_associates=sortrows(associates,1);
    
    load(fullfile(mat_files_dir,sprintf('%s_associates',subject)));
    associates=cell2mat(workingmat(2:end,22:23));
    associates=associates(find(associates(:,1)),:);
    ass_nonass_associates=sortrows(associates,1);
    
    for i=clust_start:clust_num
        
        %upload the relevant clust_mat_file, and compute the correlations
        %of all items with all items, for pre-learning and post-learning
        %similarity
        mask_nm=masks{i};
        file_name=fullfile(mat_files_dir,sprintf('PRE_%s_%s.mat', subject,mask_nm));
        
        if exist (file_name)
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
            
            for cond=1:num_conds
                curr_items=[1:1:items_in_cond]+((cond-1)*items_in_cond); %select the items in the current condition
                
                if cond==1 %this is the famous condition, need to exclude some famous for some of the subjects:
                    curr_items=ExludeUnknownFamous(curr_items,subject);
                end
                
                associates=rem_forg_associates;
                rem=(associates(curr_items,3))==2;
                HC=associates(curr_items,4)~=1; %no 'maybe' response
                HC(~rem)=0; %%%
                HC(associates(curr_items,4)==0)=0;
                forg=(associates(curr_items,3))==1;
               
                sub_gave_resp=find(associates(curr_items,5));%this is null if subject did not provide a response
                
                for ab=1:2 %1 is the A face, 2 the B face
                    %REMEMBERED: PRE with POST:
                    cor_mat1=sim_matrix(associates(curr_items(rem),ab),associates(curr_items(rem),ab)+betas_in_session);
                    sub_cor_vals(j,(cond-1)*num_comp*2+(ab-1)*num_comp+1,i)=mean(diag(cor_mat1));
                    
                    if ~isempty(find(HC))
                        %HC:corr first session AFace with first session BFace:
                        cor_mat1=sim_matrix(associates(curr_items(HC),ab),associates(curr_items(HC),ab)+betas_in_session);
                        sub_cor_vals(j,(cond-1)*num_comp*2+(ab-1)*num_comp+2,i)=mean(diag(cor_mat1));
                        
                    end
                    
                    %FORGOTTEN:
                    cor_mat1=sim_matrix(associates(curr_items(forg),ab),associates(curr_items(forg),ab)+betas_in_session);
                    sub_cor_vals(j,(cond-1)*num_comp*2+(ab-1)*num_comp+3,i)=mean(diag(cor_mat1));
                    
                    %all associated:
                    associates=ass_nonass_associates; %this is techincally unnecessary - the first two columns in this matrix are identical
                    %to the rem_forg_matrix
                    cor_mat1=sim_matrix(associates(curr_items,ab),associates(curr_items,ab)+betas_in_session);
                    corr_ass1=diag(cor_mat1);
                    corr_nonass1up=triu(cor_mat1,1);corr_nonass1low=tril(cor_mat1,-1);
                    sub_cor_vals(j,(cond-1)*num_comp*2+(ab-1)*num_comp+4,i)=mean(corr_ass1);
                    sub_cor_vals(j,(cond-1)*num_comp*2+(ab-1)*num_comp+5,i)=mean([mean(corr_nonass1low(find(corr_nonass1low))) mean(corr_nonass1up(find(corr_nonass1up)))]);
                
                end
                
            end %ends the conditions loop
            %end %ends the less than 10 voxels per region
        end %ends the conditional of whether the region exists or not in the specific subject
    end%ends all the clusters loop
    
end%ends all the subjects loop

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
save(fullfile(Results_folder,sprintf('%s_RemForg_and_AssNonAss.mat',curr_regs)),'ResultsRemForgOnlyNum','ResultsRemForg');

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

