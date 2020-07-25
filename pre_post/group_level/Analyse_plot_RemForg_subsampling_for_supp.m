function Analyse_plot_RemForg_subsampling_for_supp(ResultsRemForgOnlyNum_per_comp,closePrev)
%this script compute the contrast on each iteration in
%ResultsRemForgOnlyNum. load the matfile created by single_item_ROI_RemForgAverageBetas_subsample_trials
%the current contrasts:
%1. PK by memory interaction
%2. HC: PK vs. n-PK
%3. PK: HC vs. forg
%4. n-PK: HC vs. forg

analyse_comps=1;
%for each, there will be the p value, and the group contrast value
num_comp=4; %the 4 analyses detailed above
if closePrev
    close all
end


reg='lhipp_ant';
data=ResultsRemForgOnlyNum_per_comp;

%Fisher transformed:
data=atanh(data);
Fisher_title='(F-transformed)';
num_iter=size(data,3);
results_struct=nan(num_comp,2,num_iter); %num_comp, as above, cols: p value, contrast value, num_iter.
%% PRE-POST difference:
data=data(:,5:8,:)-data(:,1:4,:);
num_cond=size(data,2);
n=size(data,1);
all_cons=[1 -1 -1 1 %the interaction
          1 0 -1 0 %HC: PK vs. nPK:
          1 -1 0 0 %PK: HC vs. forg:
          0 0 1 -1]; %PK: HC vs. forg:
if analyse_comps
for i = 1:num_iter
    stats_data = data(:,:,i);
    %% compute the contrasts:
    for cc = 1:num_comp
        con=repmat(all_cons(cc,:),[n,1]);
        subj_con=sum(stats_data.*con,2);
        results_struct(cc,2,i)=mean(subj_con);
    end
    
end
end
%% now plot everything:
figure('Name',reg);
all_x_labels={'Interaction','HC: PK vs. nPK','PK: HC vs. forg','n-PK: HC vs. forg'};
for cc = 1:num_comp
    %plot the contrast results:
    curr_data=squeeze(results_struct(cc,2,:));
    %print and sort:
    curr_data = sort(curr_data);
    upper=curr_data(num_iter*0.025,:);
    lower=curr_data(num_iter-num_iter*0.025,:);
    if cc <= 3
        p=(1-find(curr_data>0,1,'first')/num_iter);
        ab_bel='above';
    else
        p=find(curr_data<0,1,'last')/num_iter;
        ab_bel='below';
    end
    if isempty(p)
        fprintf('%s: all values are %s 0 \n',all_x_labels{cc},ab_bel)
    else
        fprintf('%s: %.3f of values are %s 0 \n',all_x_labels{cc},p,ab_bel)
    end
    
    %plot
    %subplot(4,2,(cc-1)*2+1);
    subplot(2,2,cc);
    hold on
    histogram(curr_data);
    xlabel(sprintf('con %s',all_x_labels{cc}));
    g=gca;
    plot([0 0],[min(g.YLim) max(g.YLim)],'blue');
    plot([upper upper],[min(g.YLim) max(g.YLim)],'red');
    plot([lower lower],[min(g.YLim) max(g.YLim)],'red');
    hold off
end

end