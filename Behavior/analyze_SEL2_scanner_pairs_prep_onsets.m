function analyze_SEL2_scanner_pairs_prep_onsets()
% A meta-function to run the function 'analyze_encoding' on multile files
% See below for details about 'analyze_encoding' function

subs= {...
%      '230615ZD';...
%      '230615EF';...
%      '230615RE';...
%      '270615SA';...
%      '270615NK';...
%      '270615RP';...
%      '110715DA';...
%      '110715YB';...
%      '110715YL';...
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

    file_names = { ...
                  '-SEL2_scanner_pairsA.log',...
                  '-SEL2_scanner_pairsB.log',...
                  '-SEL2_scanner_pairsC.log',...
                  '-SEL2_scanner_pairsD.log',...
                };


parts_order=[...
%              2 4 3 1;...%TF
%              1 4 2 3;...%ZD
%              1 3 4 2;...%EF
%              1 3 2 4;...%RE
%              4 2 1 3;...%SA
%              4 2 1 3;...%NK
%              4 2 3 1;...%RP
%              2 3 4 1;...%YB
%              3 1 2 4;...%YL
%              4 2 3 1;...%DA
              3 1 2 4;...%TP
              3 4 2 1;...%LK
              2 1 3 4;...%AG
              2 1 4 3;...%EB
              2 1 4 3;...%EF
              3 4 2 1;...%LR
              1 4 2 3;...%RM
              3 2 4 1;...%TN
              4 2 1 3;...%EZ
             ];%insert for each subject, in the order they did the parts - A is 1, B is 2, C is 3, D is 4
         %make sure the order of the parts is acording to the order of hte
         %subjects
for i=1:length(subs)
    subject=subs{i};
    curr_parts_order=parts_order(i,:);
    
        for p=1:length(curr_parts_order)
            file_name=[subject file_names{curr_parts_order(p)}];
            analyze_encoding(file_name,p,subject);
        end
    
end

end



function []=analyze_encoding(fname,part,sub)
% A function that analyzes presentation log files (in the form of xls
% files).
% 
% Assumptions about the log stucture:
% - First line of input file contains column definitions (and not, for example, blank rows)
% - Participants are required to provide either a single response 
% - Response codes column (contains also raw code) is adjacent to Trial
%   type column (Presentation default)
%
% RTs are calculated as a difference between time at response and time of picture presentation
%%
% Compiled by Niv Reggev, 05/04/2014
%%
% Adjustable parameters:

Root = 'C:\fMRI_Data\SEL2\behavioral'; % Location of file to be analyzed
%fname = '030312NL-RS2b_study_9.xls'; % Name of file to be analyzed; Overides outside input, use with care
file = fullfile(Root,fname);
fn_first_part=fname(1:find(fname=='.',1)-2);
fn_second_part=fname(find(fname=='.',1)-1);
results_dir='Analysis\Encoding';
destin_dir=fullfile(Root,results_dir);
if ~isdir(destin_dir)
        mkdir(destin_dir);
end 
outputfile=sprintf('analyzed_%s%d%s.xlsx',fn_first_part,part,fn_second_part); % Name of outfile to be produced
outputfileforSim=sprintf('analyzed_%s.xlsx',fn_first_part); % Name of outfile to be produced

SummaryFlag=1; % 1 - output will contain only lines of interest (1 line per event); 0 - all output
NoDec=1; % Number of decisions for each event; NOT IMPLEMENTED HERE
nTrialRows = 1; % Number of unique rows per event (i.e., if an event has a code ("Nothing") line and a picture ("Picture") line, nTrialRows=2; if an event has only a code row, OR only a picture row, nTrialsRow=1)
                %%% at the moment - this script supports only logs in which the code ("Nothing") row preceds the picture row (important for RT calculation)
MinRespTime=3000; % Low RT cutoff - RTs shorter that this (in units of ms*10) will be automatically assigned to previous trial
TrialLength=30000; % Length of each trial
MaxDelay=5000; % Maximun period of time for responses after end of trial
EvMarker1='Picture'; % Type of trial which contains the code for the entire event. Lines containing this type will contain all the relevant information
%EvMarker2='Nothing';
TrialCol='Event'; % Name of Event column
TimeColumn='Time'; % Name of time column
RepetitionColumn='repetition(num)';%Name of the repetition column
EndResponse=5; % The code of the key ending sessions
beg_fix_dur=4; %duration of beginning fixation in secs
% if part==1
% Start_exp_trials = 45; %a parameter to correct the time column so it'll be in it's right place. Shuold be the first row of experimental trial in digits, correct here when shifting from one version of the experiment to another
% elseif part==2
% Start_exp_trials = 49; %a parameter to correct the time column so it'll be in it's right place. Shuold be the first row of experimental trial in digits, correct here when shifting from one version of the experiment to another
% elseif part==3
% Start_exp_trials = 49; %a parameter to correct the time column so it'll be in it's right place. Shuold be the first row of experimental trial in digits, correct here when shifting from one version of the experiment to another
% else
% Start_exp_trials = 53; %a  
% end
Start_exp_trials = 14; %a parameter to correct the time column so it'll be in it's right place. Shuold be the first row of experimental trial in digits, correct here when shifting from one version of the experiment to another
Start_exp_trials = Start_exp_trials-4;
%% definitions for onsets
basedir = 'C:\fMRI_Data\SEL2\ANALYSIS_SPM8\';% Root location of analysis folder
%oldbasedir = 'E:\fMRI_Data\RS2b\1.Analysis_SPM8_NEW\';% Root location of analysis folder
onsetsdir = 'onsets'; % Onsets directory
%condfiles = 'onsets_sim_conditions_no_rep.txt'; % onsets file  to be converted
onsetdur=0;% Duration of each event, in TRs
ntrials=90; % Number of experimental trials
%nsession=4; % Number of sessions per each partticipant
%sesslength = 800; % Length of session in seconds
%% Initialization of directories amd files
WD=pwd;
cd(Root);

string_hd=[];
txt=textscan(fopen(file),'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s');
for i=1:numel(txt)
    if i~=4
    string_hd=[string_hd;txt{1,i}(3)];
    end
    if strcmp(txt{1,i}(3),'Time')
        TimeCol=i-1;
        break;
    end
end
strings={};
for i=1:TimeCol
    strings(:,i)=txt{1,i}(Start_exp_trials:end,:);
end
strings=[string_hd';strings];

digits={};
for i=1:size(strings,1)
    for j=1:size(strings,2)
        digits{i,j}=str2num(strings{i,j});
        if isempty(digits{i,j}), digits{i,j}=NaN; end
    end
end
digits=cell2mat(digits);
digits(~isnan(digits(:,5)),TimeCol)=digits(~isnan(digits(:,5)),5);

% Creates 3 cell arrays: (1) cell matrix contanining numerics, (2) cells containing strings, (3) all cells 
% IMPORTANT: numeric matrix is one line and one column short - first row
% contains only string headers, first column contains subject name -
% excluded from numeric matrix
% [digitsraw,strings,other]=xlsread(file);
% string_hd=strings(4,:);
% strings=[string_hd; strings(6:end,:)];
% other=[string_hd; other(6:end,:)];
% % adding a line and a column to numeric matrix, so it will have the same size as other matrices
% digits=zeros(size(strings,1),size(strings,2));
% digits(2:end,2:end)=digitsraw;

workingmat=strings; % writable matrix

% Find the index of the column containing event types
EvCol=strcmp(strings(1,:),TrialCol); 
EvCol=find(EvCol);

% Find the index of the column containing repetition number
RepCol=strcmp(strings(1,:),RepetitionColumn);
RepCol=find(RepCol);

% % Find the index of the column containing time stamps
% TimeCol=strcmp(other(1,:),TimeColumn);
% TimeCol=find(TimeCol);

% Define last column
LastCol=size(strings,2)+1;

% Find locations of all nothing events within event types column
e=strcmp(EvMarker1,strings(:,EvCol));
f=strcmp('fix',strings(:,EvCol+2));
e(f)=0;
Events=find(e);

Beg_time=digits(Events(1),TimeCol);

%% Running the function
for i=1:size(Events,1)
    %settings for the onsets and other analysis stuff
    workingmat{Events(i),LastCol+4}=part;
    workingmat{Events(i),LastCol+5}=digits(Events(i),RepCol)+(part-1)*3;
    workingmat{Events(i),LastCol+6}=(digits(Events(i),TimeCol)-Beg_time)/10000+beg_fix_dur;%+(part-1)*scan_dur;
    %conditional onsets columns: Famous=1,NF=2,BFace_Famous=3,BFace_NF=4;
    if(strcmp(strings(Events(i),5),'Famous'))
        workingmat{Events(i),LastCol+7}=1;
    elseif(strcmp(strings(Events(i),5),'NF'))
        workingmat{Events(i),LastCol+7}=2;
    elseif (strcmp(strings(Events(i),5),'TaskFamous'))
        workingmat{Events(i),LastCol+7}=3;
    elseif (strcmp(strings(Events(i),5),'TaskNonFamous'))
        workingmat{Events(i),LastCol+7}=4;
    else
        workingmat{Events(i),LastCol+7}='error';
    end
    
    %similarity onsets columns - each stimuli has a number based on this
    %devision:
    % Famous F 1-12: 1-12
    % NF F 1-12: 13-24
    % Task AFace Famous 1-3:25-27
    % Task AFace NonFamous 1-3:28-30
    if (strcmp(strings(Events(i),5),'Famous'))
           workingmat{Events(i),LastCol+8}=digits(Events(i),7);
    elseif (strcmp(strings(Events(i),5),'NF'))
           workingmat{Events(i),LastCol+8}=digits(Events(i),7)+12;
    elseif (strcmp(strings(Events(i),5),'TaskFamous'))
           workingmat{Events(i),LastCol+8}=digits(Events(i),7)+24;
    elseif (strcmp(strings(Events(i),5),'TaskNonFamous'))
           workingmat{Events(i),LastCol+8}=digits(Events(i),7)+27;
    end
    
    
    if NoDec==1
        if i < size(Events,1) % in all cases but the last
            r=strcmp('Response',strings(Events(i):Events(i+1),EvCol)); % find all responses for the current event - till the onset of next event
            if sum(r>0)>0 % if responses were given
                Resp=find(r); % find the indices of responses
            else
                workingmat{Events(i),LastCol+3}='NoResp';
            end
        else
            r=strcmp('Response',strings(Events(i):size(strings,1)-1,EvCol)); % find all responses for the current event - till the end of file (but from the last line which should include the repsonse ending the trial)
            if sum(r>0)>0 % if responses were given
                Resp=find(r); % find the indices of responses
            else
                workingmat{Events(i),LastCol+3}='NoResp';
            end
        end
        if sum(r>0)>0 %if responses were given
            if digits(Events(i)+Resp(1)-1,TimeCol)-digits(Events(i),TimeCol)<MinRespTime % if responses were given in a time window deemed too fast
              % if i > 1 % if more than one response was given for the current event, assign the first response to the previous trial
                    if (digits(Events(i)+Resp(1)-1,TimeCol)-digits(Events(i-1),TimeCol))<(TrialLength+MaxDelay) % check if response is in the legitimate time window
                        workingmat{Events(i-1),LastCol}=digits(Events(i)+Resp(1)-1,EvCol+1); % Assign response to previous trial; Note that the use of EvCol here is artifical, enabled only because 'digits' array has one column missing
                        workingmat{Events(i-1),LastCol+1}=digits(Events(i)+Resp(1)-1,TimeCol)-digits(Events(i-1)+nTrialRows-1,TimeCol); % RT
                        workingmat{Events(i-1),LastCol+2}=1; % changed response index, to mark that response was changed
                        cond=strings{Events(i-1),EvCol+1};
                        cond=cond(1:4);
                        if sum(cond=='Task')==4 %previous trial is a task trial
                            if workingmat{Events(i-1),LastCol}==2
                                workingmat{Events(i-1),LastCol+3}='correct';
                            else
                                workingmat{Events(i-1),LastCol+3}='incorrect';
                            end
                        else%previous trial is an experimental trial
                            if workingmat{Events(i-1),LastCol}==1
                                workingmat{Events(i-1),LastCol+3}='correct';
                            else
                                workingmat{Events(i-1),LastCol+3}='incorrect';
                            end
                        end
                    end
              %  end
                if sum(r>0)>1 % of more than one response was given for the current event, there are legitimate responses for it - take the last legitimate response
                    workingmat{Events(i),LastCol}=digits(Events(i)+Resp(end)-1,EvCol+1); % Assign response to current trial; Note that the use of EvCol here is artifical, enabled only because 'digits' array has one column missing
                    workingmat{Events(i),LastCol+1}=digits(Events(i)+Resp(end)-1,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
%                     Ev2=strcmp(EvMarker2,strings(Events(i):Events(i+1),EvCol)); % find onset of second stage of current event          
%                     Ev2Onset=find(Ev2);
%                     workingmat{Events(i),LastCol+3}=strings{(Events(i)+Ev2Onset(1)-1),EvCol+1};
                    cond=strings{Events(i),EvCol+1};
                    cond=cond(1:4);
                        if sum(cond=='Task')==4 %previous trial is a task trial
                            if workingmat{Events(i),LastCol}==2
                                workingmat{Events(i),LastCol+3}='correct';
                            else
                                workingmat{Events(i),LastCol+3}='incorrect';
                            end
                        else
                            if workingmat{Events(i),LastCol}==1
                                workingmat{Events(i),LastCol+3}='correct';
                            else
                                workingmat{Events(i),LastCol+3}='incorrect';
                            end
                        end
                        
                    if sum(r>0)>2 % if there is more than one legitimate response for the current event
                        workingmat{Events(i),LastCol+2}=1;  % changed response index, to mark that response was changed
                    else
                        workingmat{Events(i),LastCol+2}=0;
                    end
                else
                    workingmat{Events(i),LastCol+3}='NoResp';
                end
            else %no resp is too fast
                if digits(Events(i)+Resp(end)-1,EvCol+1)~=EndResponse % Checking if not end of session
                    if (digits(Events(i)+Resp(end)-1,TimeCol)-digits(Events(i),TimeCol))<(TrialLength+MaxDelay) % check if last response is in the legitimate time window
                        workingmat{Events(i),LastCol}=digits(Events(i)+Resp(end)-1,EvCol+1); % Assign response to current trial
                        workingmat{Events(i),LastCol+1}=digits(Events(i)+Resp(end)-1,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
%                         Ev2=strcmp(EvMarker2,strings(Events(i):size(strings,1)-1,EvCol)); % find onset of second stage of current event          
%                         Ev2Onset=find(Ev2);
%                        workingmat{Events(i),LastCol+3}=strings{(Events(i)+Ev2Onset(1)-1),EvCol+1};
                        cond=strings{Events(i),EvCol+1};
                        cond=cond(1:4);
                        if sum(cond=='Task')==4 %previous trial is a task trial
                            if workingmat{Events(i),LastCol}==2
                                workingmat{Events(i),LastCol+3}='correct';
                            else
                                workingmat{Events(i),LastCol+3}='incorrect';
                            end
                        else
                            if workingmat{Events(i),LastCol}==1
                                workingmat{Events(i),LastCol+3}='correct';
                            else
                                workingmat{Events(i),LastCol+3}='incorrect';
                            end
                        end
                        
                        if sum(r>0)>1 % if there is more than one legitimate response for the current event
                            
                            workingmat{Events(i),LastCol+2}=1;  % changed response index
                        else
                            workingmat{Events(i),LastCol+2}=0;
                        end
                    elseif sum(r>0)>1 && (digits(Events(i)+Resp(end-1)-1,TimeCol)-digits(Events(i),TimeCol))<(TrialLength+MaxDelay) % check if response one before last is in the legitimate time window
                        workingmat{Events(i),LastCol}=digits(Events(i)+Resp(end-1)-1,EvCol+1); % Assign response to current trial
                        workingmat{Events(i),LastCol+1}=digits(Events(i)+Resp(end-1)-1,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
                        
                        cond=strings{Events(i),EvCol+1};
                        cond=cond(1:4);
                        if sum(cond=='Task')==4 %previous trial is a task trial
                            if workingmat{Events(i),LastCol}==2
                                workingmat{Events(i),LastCol+3}='correct';
                            else
                                workingmat{Events(i),LastCol+3}='incorrect';
                            end
                        else
                            if workingmat{Events(i),LastCol}==1
                                workingmat{Events(i),LastCol+3}='correct';
                            else
                                workingmat{Events(i),LastCol+3}='incorrect';
                            end
                        end
                        
                        if sum(r>0)>2 % if there is more than one legitimate response for the current event
                            workingmat{Events(i),LastCol+2}=1;  % changed response index
                        else
                            workingmat{Events(i),LastCol+2}=0;
                        end     
                    else
                        workingmat{Events(i),LastCol+3}='LateResp'; % if all responses were given after legitimate time window
                    end
                elseif sum(r>0)>1 % If end of session, but more than one response (meaning that there is a legitimate response for the last trial)
                    workingmat{Events(i),LastCol}=digits(Events(i)+Resp(end-1)-1,EvCol+1); % Assign response to current trial
                    workingmat{Events(i),LastCol+1}=digits(Events(i)+Resp(end-1)-1,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
%                     Ev2=strcmp(EvMarker2,strings(Events(i):Events(i+1),EvCol)); % find onset of second stage of current event          
%                     Ev2Onset=find(Ev2);
%                     workingmat{Events(i),LastCol+3}=strings{(Events(i)+Ev2Onset(1)-1),EvCol+1};
                        cond=strings{Events(i),EvCol+1};
                        cond=cond(1:4);
                        if sum(cond=='Task')==4 %previous trial is a task trial
                            if workingmat{Events(i),LastCol}==2
                                workingmat{Events(i),LastCol+3}='correct';
                            else
                                workingmat{Events(i),LastCol+3}='incorrect';
                            end
                        else
                            if workingmat{Events(i),LastCol}==1
                                workingmat{Events(i),LastCol+3}='correct';
                            else
                                workingmat{Events(i),LastCol+3}='incorrect';
                            end
                        end
                    if sum(r>0)>2 % if there is more than one legitimate response for the current event
                        workingmat{Events(i),LastCol+2}=1;  % changed response index
                    else
                        workingmat{Events(i),LastCol+2}=0;
                    end
                else
                    workingmat{Events(i),LastCol+3}='NoResp';
                end              
            end
        end
        
    else
        sprintf('Number of decision unsupported in current version')
        break
    end
end

%% Sort output file (column headers, save only needed information)
workingmat{1,LastCol}='Response_bt';
workingmat{1,LastCol+1}='RT (Response - Picture)';
workingmat{1,LastCol+2}='Changed response';
workingmat{1,LastCol+3}='Response';
workingmat{1,LastCol+4}='Part';
workingmat{1,LastCol+5}='True_repetitions';
workingmat{1,LastCol+6}='True_time';
workingmat{1,LastCol+7}='Cond_model_onsets';
workingmat{1,LastCol+8}='Similarity_model_onsets';

if SummaryFlag
    Output = workingmat(:,1:TimeCol);
    Output(:,TimeCol+1:TimeCol+9) = workingmat(:,LastCol:LastCol+8); 
    Output1=Output(1,:);
    Output=[Output1; Output(Events,:)];
else
    Output = workingmat(:,1:TimeCol);
    Output(:,TimeCol+1:TimeCol+9) = workingmat(:,LastCol:LastCol+8);
end
full_output=fullfile(destin_dir,outputfile);
xlswrite(full_output,Output);

%for the similarity analysis to beable to pair the items that appeared together, it was convenient to have also a file name
%without the parts(A B C D) and numbers (1 2 3 4), so here it simply produces
%another file with a convenient name.
if part==1
    full_output=fullfile(destin_dir,outputfileforSim);
    xlswrite(full_output,Output);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Preper onsets files - conditional model

cond_names=struct(...   % A structure containing all experimental conditions
'name1','Famous',...
'name2','NF',...
'name3','TaskFamous',...
'name4','TaskNonFamous'...
);

fconds=fieldnames(cond_names);
%fnames=fieldnames(ss_names);
names=[];
onsets=[];
durations=[];
condons=[Output{2:size(Output,1),size(Output,2)-1}; Output{2:size(Output,1),size(Output,2)-2}]';
%**************************************************************************
%ONSETS CONVERSION
%**************************************************************************

    for i=1:length (fconds)
        condons_temp=[];
        for j=1:ntrials
            if condons(j,1)==i
                condons_temp = [condons_temp;condons(j,2)];
            end
        end

        names{i}=char(getfield(cond_names, sprintf('name%d', i)));% Name of condition i
        onsets{i}=condons_temp; % Onsets of condition i
        durations{i}=onsetdur; % Duration of condition i

    end 
    cd(fullfile(basedir,sub,onsetsdir));
    save(sprintf('onsets_SEL2_pairs_conditions_sess%d.mat',part),'names','onsets','durations'); % Write onset files for current subject


%% prepare onsets files - similarity model

cond_names=struct(...   % A structure containing all experimental conditions
'name1','Famous_F1',...
'name2','Famous_F2',...
'name3','Famous_F3',...
'name4','Famous_F4',...
'name5','Famous_F5',...
'name6','Famous_F6',...
'name7','Famous_F7',...
'name8','Famous_F8',...
'name9','Famous_F9',...
'name10','Famous_F10',...
'name11','Famous_F11',...
'name12','Famous_F12',...
'name13','NF_F1',...
'name14','NF_F2',...
'name15','NF_F3',...
'name16','NF_F4',...
'name17','NF_F5',...
'name18','NF_F6',...
'name19','NF_F7',...
'name20','NF_F8',...
'name21','NF_F9',...
'name22','NF_F10',...
'name23','NF_F11',...
'name24','NF_F12',...
'name25','TaskFamous_F_1',...
'name26','TaskFamous_F_2',...
'name27','TaskFamous_F_3',...
'name28','TaskNonFamous_F_1',...
'name29','TaskNonFamous_F_2',...
'name30','TaskNonFamous_F_3'...
);

fconds=fieldnames(cond_names);
%fnames=fieldnames(ss_names);
names=[];
onsets=[];
durations=[];
condons=[Output{2:size(Output,1),size(Output,2)}; Output{2:size(Output,1),size(Output,2)-2}]';
%**************************************************************************
%ONSETS CONVERSION
%**************************************************************************

    for i=1:length (fconds)
        condons_temp=[];
        for j=1:ntrials
            if condons(j,1)==i
                condons_temp = [condons_temp;condons(j,2)];
            end
        end

        names{i}=char(getfield(cond_names, sprintf('name%d', i)));% Name of condition i
        onsets{i}=condons_temp; % Onsets of condition i
        durations{i}=onsetdur; % Duration of condition i

    end 
    cd(fullfile(basedir,sub,onsetsdir));
    save(sprintf('onsets_SEL2_pairs_similarity_sess%d.mat',part),'names','onsets','durations'); % Write onset files for current subject

cd(WD);
end




