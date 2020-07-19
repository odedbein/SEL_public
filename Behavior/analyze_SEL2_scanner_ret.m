function analyze_SEL2_scanner_ret()
% A meta-function to run the function 'analyze_retrieval' on multile files
% See below for details about 'analyze_retrieval' function

file_list = {...,

'240715TP-SEL2_scanner_CR.log',...
'250715LK-SEL2_scanner_CR.log',...
'250715AG-SEL2_scanner_CR.log'...
'250715EB-SEL2_scanner_CR.log',...
'080815EF-SEL2_scanner_CR.log',...
'080815LR-SEL2_scanner_CR.log',...
'080815RM-SEL2_scanner_CR.log'...
'080815TN-SEL2_scanner_CR.log',...
'110815EZ-SEL2_scanner_CR.log',...
    };


for i=1:length(file_list)
    analyze_retrieval(file_list{i});
end

end



function []=analyze_retrieval(fname)

% A function that analyzes presentation log files (in the form of xls
% files).
% 
% Assumptions about the log stucture:
% - First line of input file contains column definitions (and not, for example, blank rows)
% - Participants are required to provide either a single response or two responses
% - Response codes column (contains also raw code) is adjacent to Trial
%   type column (Presentation default)
%
% RTs are calculated as a difference between time at response and time of picture presentation
%%
% Compiled by Niv Reggev, 05/04/2013
%%
% Adjustable parameters:

Root = 'C:\fMRI_Data\SEL2\behavioral'; % Location of file to be analyzed
results_dir='Analysis\Retrieval';
destin_dir=fullfile(Root,results_dir);
if ~isdir(destin_dir)
        mkdir(destin_dir);
end 
%fname = '270213LB-RS2b_test_1.xls'; % Name of file to be analyzed; Overides outside input, use with care
file = fullfile(Root,fname);
fn_first_part=fname(1:find(fname=='.')-1);
outputfile=sprintf('analyzed_%s.xlsx',fn_first_part); % Name of outfile to be produced

SummaryFlag=1; % 1 - output will contain only lines of interest (1 line per event); 0 - all output
NoDec=2; % Number of decisions for each event
nTrialRows = 1; % Number of unique rows per event (i.e., if an event has a code ("Nothing") line and a picture ("Picture") line, nTrialRows=2; if an event has only a code row, OR only a picture row, nTrialsRow=1)
                %%% at the moment - this script supports only logs in which the code ("Nothing") row preceds the picture row (important for RT calculation)
MinRespTime=3000; % Low RT cutoff - RTs shorter that this (in units of ms*10) will be automatically assigned to previous trial
MinRespTimeDec2=1000; % Low RT cutoff for the second response - RTs shorter that this (in units of ms*10) will be automatically assigned to previous trial
TrialLength=100000; % Length of each trial
MaxDelay=5000; % Maximun period of time for responses after end of trial
EvMarker1='Picture'; % Type of trial which contains the code for the entire event. Lines containing this type will contain all the relevant information
EvMarker2='Nothing'; % Type of trial which contains the code for the second decision in the event. information about this decision will be added to the base trial event (EvMarker1)
TrialCol='Event'; % Name of Event column
TimeColumn='Time'; % Name of time column
EndResponse=4; % The code of the key ending sessions
Start_exp_trials = 31; %a parameter to correct the time column so it'll be in it's right place. Shuold be the first row of experimental trial in digits, correct here when shifting from one version of the experiment to another
%% Initialization of directories amd files
WD=pwd;
cd(Root);
string_hd=[];
txt=textscan(fopen(file),'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s');
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
    strings(:,i)=txt{1,i}(4:end,:);
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

for i=Start_exp_trials:size(digits,1)
    if digits(i,7)==50
        digits(i,TimeCol)=digits(i,6);
    end
end
% Creates 3 cell arrays: (1) cell matrix contanining numerics, (2) cells containing strings, (3) all cells 
% IMPORTANT: numeric matrix is one line and one column short - first row
% contains only string headers, first column contains subject name -
% excluded from numeric matrix
% [digitsraw,strings,other]=xlsread(file);
% string_hd=strings(4,:);
% strings=[string_hd; strings(42:end,:)];
% other=[string_hd; other(42:end,:)];
% % adding a line and a column to numeric matrix, so it will have the same size as other matrices
% digits=zeros(size(strings,1),size(strings,2));
% digits(2:end,2:end)=digitsraw(37:end,:);

workingmat=strings; % writable matrix

% Find the index of the column containing event types
EvCol=strcmp(strings(1,:),TrialCol); 
EvCol=find(EvCol);

% Define last column
LastCol=size(strings,2)+1;

% Find locations of all nothing events within event types column
e=strcmp(EvMarker1,strings(:,EvCol));
Events=find(e);

%% Running the function
for i=1:size(Events,1)
    if NoDec==1
        if i < size(Events,1) % in all cases but the last
            r=strcmp('Response',strings(Events(i):Events(i+1),EvCol)); % find all responses for the current event - till the onset of next event
            if sum(r>0)>0 % if responses were given
                Resp=find(r); % find the indices of responses
            else
                workingmat{Events(i),LastCol}='NoResp';
            end
        else
            r=strcmp('Response',strings(Events(i):size(strings,1)-1,EvCol)); % find all responses for the current event - till the end of file (but from the last line which should include the repsonse ending the trial)
            if sum(r>0)>0 % if responses were given
                Resp=find(r); % find the indices of responses
            else
                workingmat{Events(i),LastCol}='NoResp';
            end
        end
        if sum(r>0)>0 
            if digits(Events(i)+Resp(1)-1,TimeCol)-digits(Events(i),TimeCol)<MinRespTime % if responses were given in a time window deemed too fast
                if i > 1 % if more than one response was given for the current event, assign the first response to the previous trial
                    if (digits(Events(i)+Resp(1)-1,TimeCol)-digits(Events(i-1),TimeCol))<(TrialLength+MaxDelay) % check if response is in the legitimate time window
                        workingmat{Events(i-1),LastCol}=digits(Events(i)+Resp(1)-1,EvCol+1); % Assign response to previous trial; Note that the use of EvCol here is artifical, enabled only because 'digits' array has one column missing
                        workingmat{Events(i-1),LastCol+1}=digits(Events(i)+Resp(1)-1,TimeCol)-digits(Events(i-1)+nTrialRows-1,TimeCol); % RT
                        workingmat{Events(i-1),LastCol+2}=1; % changed response index, to mark that response was changed
                    end
                end
                if sum(r>0)>1 % of more than one response was given for the current event, there are legitimate responses for it - take the last legitimate response
                    workingmat{Events(i),LastCol}=digits(Events(i)+Resp(end)-1,EvCol+1); % Assign response to current trial; Note that the use of EvCol here is artifical, enabled only because 'digits' array has one column missing
                    workingmat{Events(i),LastCol+1}=digits(Events(i)+Resp(end)-1,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
                    if sum(r>0)>2 % if there is more than one legitimate response for the current event
                        workingmat{Events(i),LastCol+2}=1;  % changed response index, to mark that response was changed
                    else
                        workingmat{Events(i),LastCol+2}=0;
                    end
                else
                    workingmat{Events(i),LastCol}='NoResp';
                end
            else
                if digits(Events(i)+Resp(end)-1,EvCol+1)~=EndResponse % Checking if not end of session
                    if (digits(Events(i)+Resp(end)-1,TimeCol)-digits(Events(i),TimeCol))<(TrialLength+MaxDelay) % check if last response is in the legitimate time window
                        workingmat{Events(i),LastCol}=digits(Events(i)+Resp(end)-1,EvCol+1); % Assign response to current trial
                        workingmat{Events(i),LastCol+1}=digits(Events(i)+Resp(end)-1,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
                        if sum(r>0)>1 % if there is more than one legitimate response for the current event
                            workingmat{Events(i),LastCol+2}=1;  % changed response index
                        else
                            workingmat{Events(i),LastCol+2}=0;
                        end
                    elseif sum(r>0)>1 && (digits(Events(i)+Resp(end-1)-1,TimeCol)-digits(Events(i),TimeCol))<(TrialLength+MaxDelay) % check if response one before last is in the legitimate time window
                        workingmat{Events(i),LastCol}=digits(Events(i)+Resp(end-1)-1,EvCol+1); % Assign response to current trial
                        workingmat{Events(i),LastCol+1}=digits(Events(i)+Resp(end-1)-1,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
                        if sum(r>0)>2 % if there is more than one legitimate response for the current event
                            workingmat{Events(i),LastCol+2}=1;  % changed response index
                        else
                            workingmat{Events(i),LastCol+2}=0;
                        end     
                    else
                        workingmat{Events(i),LastCol}='LateResp'; % if all responses were given after legitimate time window
                    end
                elseif sum(r>0)>1 % If end of session, but more than one response (meaning that there is a legitimate response for the last trial)
                    workingmat{Events(i),LastCol}=digits(Events(i)+Resp(end-1)-1,EvCol+1); % Assign response to current trial
                    workingmat{Events(i),LastCol+1}=digits(Events(i)+Resp(end-1)-1,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
                    if sum(r>0)>2 % if there is more than one legitimate response for the current event
                        workingmat{Events(i),LastCol+2}=1;  % changed response index
                    else
                        workingmat{Events(i),LastCol+2}=0;
                    end
                else
                    workingmat{Events(i),LastCol}='NoResp';
                end
            end
        end         
    elseif NoDec==2
        if i < size(Events,1) % in all cases but the last
            r=strcmp('Response',strings(Events(i):Events(i+1),EvCol)); % find all responses for the current event - till the onset of next event
            Ev2=strcmp(EvMarker2,strings(Events(i):Events(i+1),EvCol)); % find onset of second stage of current event/nothing events where the response meaning is written
            Ev2Onset=find(Ev2);
            workingmat{Events(i),LastCol+3}=strings{(Events(i)+Ev2Onset(1)-1),EvCol+1};
            workingmat{Events(i),LastCol+7}=strings{(Events(i)+Ev2Onset(2)-1),EvCol+1};
            if sum(Ev2>0)>0 % if second stage of event took place
                r1=strcmp('Response',strings(Events(i):(Events(i)+find(Ev2)-1),EvCol)); % find all responses for the current event - till the onset of second stage
                r2=strcmp('Response',strings((Events(i)+find(Ev2)-1):Events(i+1),EvCol)); % find all responses for the second stage of current event - till the onset of next event
                if sum(r1>0)>0
                    Resp=find(r1);
                else
                    workingmat{Events(i),LastCol}='NoResp';
                end 
                if sum(r2>0)>0
                    Resp2=find(r2);
                else
                    workingmat{Events(i),LastCol+4}='NoResp';
                end 
            else   % if second stage of event did not take place 
                r2 = 0;              
                if sum(r>0)>0 % if responses were given
                    Resp=find(r); % find the indices of responses
                else
                    workingmat{Events(i),LastCol}='NoResp';
                end
            end
        else
            r=strcmp('Response',strings(Events(i):size(strings,1)-1,EvCol)); % find all responses for the current event - till the end of file (but from the last line which should include the repsonse ending the trial)
            Ev2=strcmp(EvMarker2,strings(Events(i):size(strings,1)-1,EvCol)); % find onset of second stage of current event          
            Ev2Onset=find(Ev2);
            workingmat{Events(i),LastCol+3}=strings{(Events(i)+Ev2Onset(1)-1),EvCol+1};
            workingmat{Events(i),LastCol+7}=strings{(Events(i)+Ev2Onset(2)-1),EvCol+1};
            if sum(Ev2>0)>0 % if second stage of event took place
                r1=strcmp('Response',strings(Events(i):(Events(i)+find(Ev2)-1),EvCol)); % find all responses for the current event - till the onset of second stage
                r2=strcmp('Response',strings((Events(i)+find(Ev2)-1):size(strings,1)-1,EvCol)); % find all responses for the second stage of current event - till the onset of next event
                if sum(r1>0)>0
                    Resp=find(r1);
                else
                    workingmat{Events(i),LastCol}='NoResp';
                end 
                if sum(r2>0)>0
                    Resp2=find(r2);
                else
                    workingmat{Events(i),LastCol+4}='NoResp';
                end 
            else   % if second stage of event did not take place 
                r2 = 0;
                if sum(r>0)>0 % if responses were given
                    Resp=find(r); % find the indices of responses
                else
                    workingmat{Events(i),LastCol}='NoResp';
                end
            end
        end
        if sum(r>0)>0 
            % For first stage responses
            if digits(Events(i)+Resp(1)-1,TimeCol)-digits(Events(i),TimeCol)<MinRespTime % if responses were given in a time window deemed too fast
                if i > 1 % if more than one response was given for the current event, assign the first response to the previous trial
                    if (digits(Events(i)+Resp(1)-1,TimeCol)-digits(Events(i-1),TimeCol))<(TrialLength+MaxDelay) % check if response is in the legitimate time window
                        workingmat{Events(i-1),LastCol}=digits(Events(i)+Resp(1)-1,EvCol+1); % Assign response to previous trial; Note that the use of EvCol here is artifical, enabled only because 'digits' array has one column missing
                        workingmat{Events(i-1),LastCol+1}=digits(Events(i)+Resp(1)-1,TimeCol)-digits(Events(i-1)+nTrialRows-1,TimeCol); % RT
                        workingmat{Events(i-1),LastCol+2}=1; % changed response index, to mark that response was changed
                    end
                end
                if sum(r>0)>1 % of more than one response was given for the current event, there are legitimate responses for it - take the last legitimate response
                    workingmat{Events(i),LastCol}=digits(Events(i)+Resp(end)-1,EvCol+1); % Assign response to current trial; Note that the use of EvCol here is artifical, enabled only because 'digits' array has one column missing
                    workingmat{Events(i),LastCol+1}=digits(Events(i)+Resp(end)-1,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
                    if sum(r>0)>2 && sum(Ev2>0)>0  % if there is more than one legitimate response for the current event AND second stage took place
                        if sum(r1>0)>2
                            workingmat{Events(i),LastCol+2}=1;  % changed response index, to mark that response was changed
                        else
                            workingmat{Events(i),LastCol+2}=0;
                        end
                    elseif sum(r>0)>2
                        workingmat{Events(i),LastCol+2}=1;  % changed response index, to mark that response was changed
                    else
                        workingmat{Events(i),LastCol+2}=0;
                    end
                else
                    workingmat{Events(i),LastCol}='NoResp';
                end
            else
                if digits(Events(i)+Resp(end)-1,EvCol+1)~=EndResponse % Checking if not end of session
                    workingmat{Events(i),LastCol}=digits(Events(i)+Resp(end)-1,EvCol+1); % Assign response to current trial
                    workingmat{Events(i),LastCol+1}=digits(Events(i)+Resp(end)-1,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
                    if sum(r>0)>1 && sum(Ev2>0)>0  % if there is more than one legitimate response for the current event AND second stage took place
                        if sum(r1>0)>1
                            workingmat{Events(i),LastCol+2}=1;  % changed response index, to mark that response was changed
                        else
                            workingmat{Events(i),LastCol+2}=0;
                        end
                    elseif sum(r>0)>1 % if there is more than one legitimate response for the current event
                        workingmat{Events(i),LastCol+2}=1;  % changed response index
                    else
                        workingmat{Events(i),LastCol+2}=0;
                    end
                elseif sum(r>0)>1 % If end of session, but more than one response (meaning that there is a legitimate response for the last trial)
                    workingmat{Events(i),LastCol}=digits(Events(i)+Resp(end-1)-1,EvCol+1); % Assign response to current trial
                    workingmat{Events(i),LastCol+1}=digits(Events(i)+Resp(end-1)-1,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
                    if sum(r>0)>2 && sum(Ev2>0)>0  % if there is more than one legitimate response for the current event AND second stage took place
                        if sum(r1>0)>2
                            workingmat{Events(i),LastCol+2}=1;  % changed response index, to mark that response was changed
                        else
                            workingmat{Events(i),LastCol+2}=0;
                        end
                    elseif sum(r>0)>2 % if there is more than one legitimate response for the current event
                        workingmat{Events(i),LastCol+2}=1;  % changed response index
                    else
                        workingmat{Events(i),LastCol+2}=0;
                    end
                else
                    workingmat{Events(i),LastCol}='NoResp';
                end
            end
            % Now for second stage responses
            if sum(r2>0)>0 % if second stage responses were given at all
                if digits(Events(i)+Ev2Onset(1)+Resp2(1)-2,TimeCol)-digits(Events(i)+Ev2Onset(1)-1,TimeCol)<MinRespTimeDec2 % if responses were given in a time window deemed too fast
                    workingmat{Events(i),LastCol}=digits(Events(i)+Ev2Onset(1)+Resp2(1)-2,EvCol+1); % Assign response to previous trial; Note that the use of EvCol here is artifical, enabled only because 'digits' array has one column missing
                    workingmat{Events(i),LastCol+1}=digits(Events(i)+Ev2Onset(1)+Resp2(1)-2,TimeCol)-digits(Events(i)+nTrialRows-1,TimeCol); % RT
                    workingmat{Events(i),LastCol+2}=1; % changed response index, to mark that response was changed
                    if sum(r2>0)>1 % of more than one response was given for the current stage of event, there are legitimate responses for it - take the last legitimate response
                        workingmat{Events(i),LastCol+4}=digits(Events(i)+Ev2Onset(1)+Resp2(end)-2,EvCol+1); % Assign response to current trial; Note that the use of EvCol here is artifical, enabled only because 'digits' array has one column missing
                        workingmat{Events(i),LastCol+5}=digits(Events(i)+Ev2Onset(1)+Resp2(end)-2,TimeCol)-digits(Events(i)+Ev2Onset(1)+nTrialRows-2,TimeCol); % RT
                        if sum(r2>0)>2 % if there is more than one legitimate response for the current event
                            workingmat{Events(i),LastCol+6}=1;  % changed response index, to mark that response was changed
                        else
                            workingmat{Events(i),LastCol+6}=0;
                        end
                    else
                        workingmat{Events(i),LastCol+4}='NoResp';
                    end
                else
                    if digits(Events(i)+Ev2Onset(1)+Resp2(end)-2,EvCol+1)~=EndResponse % Checking if not end of session
                        workingmat{Events(i),LastCol+4}=digits(Events(i)+Ev2Onset(1)+Resp2(end)-2,EvCol+1); % Assign response to current trial
                        workingmat{Events(i),LastCol+5}=digits(Events(i)+Ev2Onset(1)+Resp2(end)-2,TimeCol)-digits(Events(i)+Ev2Onset(1)+nTrialRows-2,TimeCol); % RT
                        if sum(r2>0)>1 % if there is more than one legitimate response for the current event
                            workingmat{Events(i),LastCol+6}=1;  % changed response index
                        else
                            workingmat{Events(i),LastCol+6}=0;
                        end
                    elseif sum(r2>0)>1 % If end of session, but more than one response (meaning that there is a legitimate response for the last trial)
                        workingmat{Events(i),LastCol+4}=digits(Events(i)+Ev2Onset(1)+Resp2(end-1)-2,EvCol+1); % Assign response to current trial
                        workingmat{Events(i),LastCol+5}=digits(Events(i)+Ev2Onset(1)+Resp2(end-1)-2,TimeCol)-digits(Events(i)+Ev2Onset(1)+nTrialRows-2,TimeCol); % RT
                        if sum(r2>0)>2 % if there is more than one legitimate response for the current event
                            workingmat{Events(i),LastCol+6}=1;  % changed response index
                        else
                            workingmat{Events(i),LastCol+6}=0;
                        end
                    else
                        workingmat{Events(i),LastCol}='NoResp';
                    end
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
workingmat{1,LastCol+2}='Response Changed';
workingmat{1,LastCol+3}='Resonse Memory';
workingmat{1,LastCol+4}='Response_conf_bt';
workingmat{1,LastCol+5}='RT conf';
workingmat{1,LastCol+6}='Response Changed';
workingmat{1,LastCol+7}='Resonse Conf';

changed_resp1=find(cell2mat(workingmat(2:end,LastCol+2)));
if (~isempty(changed_resp1))
    sprintf('there are changed values in first response,in trials:\n')
    for i=1:length(changed_resp1)
        sprintf('%s\n',int2str(changed_resp1(i)))
    end
else
    sprintf('yay!no changed values in resp1\n')
end

changed_resp2=find(cell2mat(workingmat(2:end,LastCol+6)));
if (~isempty(changed_resp2))
    sprintf('there are changed values in second response,in trials:\n')
    for i=1:length(changed_resp2)
        sprintf('%s\n',int2str(changed_resp2(i)))
    end
else
    sprintf('yay!no changed values in resp2\n')
end

if SummaryFlag
    Output = workingmat(:,1:TimeCol);
    Output(:,TimeCol+1:TimeCol+8) = workingmat(:,LastCol:LastCol+7);
    Output1=Output(1,:);
    Output=[Output1; Output(Events,:)];
else
    Output = workingmat(:,1:TimeCol);
    Output(:,TimeCol+1:TimeCol+8) = workingmat(:,LastCol:LastCol+7);
end
full_output=fullfile(destin_dir,outputfile);
xlswrite(full_output,Output);
cd(WD);
end

