clc;clear all;close all;
basedir='C:\fMRI_Data\SEL2\ANALYSIS_SPM8';
onsetsdir='onsets';
num_reps=3; %three repetitions in session
analysis_dir='C:\Users\OWNER\Dropbox\Lab.Oded\SEL\SEL_fMRI\SEL2\Behavioral';
file_name='SEL2_EncodingForRTonsetes_all_subs.xlsx';
[num,txt,raw]=xlsread(fullfile(analysis_dir,file_name));

%zero padding num so it'll have the same indexes as the txt/raw structures
num_hd=zeros(1,size(num,2));
num=[num_hd;num];
num_hd=zeros(size(num,1),1);
num=[num_hd num];

%remove incorrect responses and RT outliers by replacing them with NaN in
%the RT column

for r=2:size(num,1)
    if ~strcmp(txt(r,17),'''correct''') %subject did not respond correctly
        num(r,21)=5;
    end
%     
%     if num(r,23)==1 %this is an outlier
%         num(r,15)=NaN;
%     end
%     
%     if num(r,16)==1 %subject changed response
%         num(r,15)=NaN;
%     end
end

sub_list=unique(txt(2:end,1));
cond_names=struct(...   % A structure containing all experimental conditions
'name1','Famous',...
'name2','NF',...
'name3','TaskFamous',...
'name4','TaskNonFamous'...%'name5','trash'...
);

fconds=fieldnames(cond_names);

for subj=1:numel(sub_list)
    curr_sub=sub_list(subj);
    sub_name=curr_sub{1};
    sub_name=sub_name(2:end-1);
    curr_sub_rows=(strcmp(txt(1:end,1),curr_sub));
    currr_subj_data=[num(curr_sub_rows,18) num(curr_sub_rows,20:21) num(curr_sub_rows,12)];
    %18:part(1-4),20:'True_time', 21:'Cond_model_onsets', 12: repetitions

    %% Preper onsets files - RT model

    for sess=1:4
        curr_sess=currr_subj_data(currr_subj_data(:,1)==sess,:);
        names=[];
        onsets=[];
        durations=[];
        %condons=[Output{2:size(Output,1),size(Output,2)-1}; Output{2:size(Output,1),size(Output,2)-2}]';
        %**************************************************************************
        %ONSETS CONVERSION
        %**************************************************************************
            cond_num=1;
            for i=1:length (fconds)
                %if i<5 %true condution - include repetitions
                    for rep=1:num_reps
                        condons_temp=[];
                        durons_temp=[];
                        for j=1:size(curr_sess,1)
                            if curr_sess(j,3)==i && curr_sess(j,4)==rep
                               condons_temp = [condons_temp;curr_sess(j,2)];%onset            
                            end
                        end
                        
                        if ~isempty(condons_temp)
                            names{cond_num}=[char(getfield(cond_names, sprintf('name%d', i))) int2str((sess-1)*num_reps+rep)];% Name of condition i
                            onsets{cond_num}=condons_temp; % Onsets of condition i
                            durations{cond_num}=0; % Duration of condition i
                            cond_num=cond_num+1;
                        end
                    end
%                 else %trash condition - don't mind repetitions
%                     condons_temp=[];
%                         durons_temp=[];
%                         for j=1:size(curr_sess,1)
%                             if curr_sess(j,3)==i
%                                     condons_temp = [condons_temp;curr_sess(j,2)];%onset
%                             end
%                         end
%                         cond_num=(length (fconds)-1)*num_reps+1;
%                         names{cond_num}=char(getfield(cond_names, sprintf('name%d', i)));% Name of condition i
%                         onsets{cond_num}=condons_temp; % Onsets of condition i
%                         durations{cond_num}=0; % Duration of condition i
%                 end

            end 
            
            filename=(fullfile(basedir,sub_name,onsetsdir,sprintf('onsets_SEL2_pairsRep_sess%d.mat',sess)));
            save(filename,'names','onsets','durations'); % Write onset files for current subject
    end
end


