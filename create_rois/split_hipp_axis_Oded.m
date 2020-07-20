function split_hipp_axis_Oded()

% software and data paths
warning('off','all')
addpath(genpath('/Volumes/Oded/Bein/General_scripts'))
rmpath('/Volumes/Oded/Bein/fMRI_course/AnalysisScripts');

project_dir='/Local/Users/oded/SEL2_anat/FIRST_AnatROI/SubsROIs';
%cd(project_dir);
subjects={
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

rois={'hipp','rhipp','lhipp'};


for s=1:length(subjects)
    
    for r=1:3
        disp(subjects{s})
        hipp_dir=fullfile(project_dir,subjects{s},'anat_segmentation');
        
        fileName=fullfile(hipp_dir,sprintf('mprage_%s',rois{r}));
        % unzip the nifti file
        if ~exist([fileName '.nii'],'file')
            disp(['unzipping ' fileName])
            unix(['gunzip ' fileName '.nii.gz']);
        end

        [hipp hipp_header]=niftiread(sprintf('%s.nii',fileName));
        
        % zip up nifti file - we took the data, so can zip again
        unix(['gzip -f ' fileName '.nii']);

        [~,j,~]=ind2sub(size(hipp),find(hipp==1));
        axis=unique(j);
        hipp_length=axis(end)-axis(1);

%         post=axis(1):axis(1)+floor(hipp_length/2);
%         ant=axis(1)+floor(hipp_length/2)+1:axis(end);

        AllButAnt=axis(1):axis(1)+floor(hipp_length*2/3); %zero these ones to create the ant hipp mask
        AllButPost=axis(1)+floor(hipp_length/3)+1:axis(end); %zero these ones to create the post hipp mask
        post=axis(1):axis(1)+floor(hipp_length/3);
        ant=axis(1)+floor(hipp_length*2/3)+1:axis(end);
        
       
        hipp_ant=hipp;
        hipp_ant(:,AllButAnt,:)=0;
        outputFileName=fullfile(hipp_dir,sprintf('mprage_%s_ant.nii',rois{r}));
        niftiwrite(outputFileName,hipp_ant);
        unix(['gzip -f ' outputFileName]);
        %write_out_volume(hipp_ant,fullfile(hipp_dir,[rois{r} '_ant']),fullfile(hipp_dir,'hipp'))
        
        
        hipp_mid=hipp;
        hipp_mid(:,post,:)=0;
        hipp_mid(:,ant,:)=0;
        outputFileName=fullfile(hipp_dir,sprintf('mprage_%s_mid.nii',rois{r}));
        niftiwrite(outputFileName,hipp_mid);
        unix(['gzip -f ' outputFileName]);
        %write_out_volume(hipp_ant,fullfile(hipp_dir,[rois{r} '_ant']),fullfile(hipp_dir,'hipp'))

        hipp_post=hipp;
        hipp_post(:,AllButPost,:)=0;
        outputFileName=fullfile(hipp_dir,sprintf('mprage_%s_post.nii',rois{r}));
        niftiwrite(outputFileName,hipp_post);
        unix(['gzip -f ' outputFileName]);
        %write_out_volume(hipp_post,fullfile(hipp_dir,[rois{r} '_post']),fullfile(hipp_dir,'hipp'))
    end
end
end
