function [data, curr_data]=Analyse_plot_Rev2Analysis_FpostFpreSim(ResultsRemForgOnlyNum,closePrev,plotSingSub)

%analyses to use:
if closePrev
    close all
end

Fisher=1;
fnames = fieldnames(ResultsRemForgOnlyNum);
PK_A_HC=[];
for r=[1,2]%:numel(fnames) %(start_reg-1)*3+1:end_reg*3
    reg=fnames{r}
    curr_data=ResultsRemForgOnlyNum.(reg);
    
    if Fisher %fisher transform the data, that is usually desireable.
        curr_data=atanh(curr_data);
        Fisher_title='(F-transformed)';
    else
        Fisher_title='';
    end
    
    %% set up things for the graph:
    Xticks={'PK:A, REM','PK:A, HC','PK:A, FORG','PK:A, ASS','PK:A, NONASS',...
            'PK:B, REM','PK:B, HC','PK:B, FORG','PK:B, ASS','PK:B, NONASS',...
            'NPK:A, REM','NPK:A, HC','NPK:A, FORG','NPK:A, ASS','NPK:A, NONASS',...
            'NPK:B, REM','NPK:B, HC','NPK:B, FORG','NPK:B, ASS','NPK:B, NONASS'};
    
    %set up the graph:
    colors=[...
        0        0.4470    0.7410
        0        0.2470    0.5410
        0        0.6470    0.9410
        1        1         1
        1        1         1
        0.4      0.4       0.4
        0.2      0.2       0.2
        0.8      0.8       0.8
        1        1         1
        1        1         1
        
        0.8500   0.3250    0.0980
        0.6500   0.1250    0.0000
        0.9500   0.6250    0.1980
        1        1         1
        1        1         1
        0.4      0.4       0.4
        0.2      0.2       0.2
        0.8      0.8       0.8
        1        1         1
        1        1         1
        ];
    
    %% plot all conditions:
    num_cond=size(curr_data,2);
    n=size(curr_data,1);
    SEM=nanstd(curr_data)/sqrt(n);
    averageCon=nanmean(curr_data);
    figure('Name',reg);
    bar(1:num_cond,zeros(1,num_cond),'FaceColor','none','EdgeColor','none');
    ylabel(sprintf('similarity%s',Fisher_title),'Fontsize',16)
    title(reg);
    %xlabel('','Fontsize',14);
    hold on
    for i=1:num_cond
        bar(i,averageCon(i),'FaceColor',colors(i,:));
        errorbar(i,averageCon(i),SEM(i),'k');
    end
    set(gca,'xtick',1:num_cond,'XTickLabel',Xticks,'XTickLabelRotation',45)
    xlim([0.5 num_cond+0.5]);
    % Plot subject data
    if plotSingSub
        subjDataX=[];
        subjDataY=[];
        for i=1:num_cond
            subjDataX = [subjDataX ones(1,n)*i];
            subjDataY = [subjDataY curr_data(:,i)'];
        end
        scatter(subjDataX,subjDataY, 15, 'ko', 'filled')
        
        % Plot lines connecting all pre and all post
        for ii = 1:n
            plot(1:num_cond/2, curr_data(ii,1:num_cond/2))
            plot((num_cond/2+1):num_cond, curr_data(ii,(num_cond/2+1):num_cond))
        end
    end
    hold off
    
    %% plot only HC-FORG by famous/non-famous, grouped by memory
    choose_conds=[2 3 5];
    shuffle_conds=[choose_conds choose_conds+5 choose_conds+10 choose_conds+15];
    data=curr_data(:,shuffle_conds);
    averageCon=nanmean(data);
    num_cond=size(data,2);
    n=size(data,1);
    %subjs_av=nanmean(data,2);
    %withinSEM=data-repmat(subjs_av,[1,num_cond]);
    SEM=abs(nanstd(data)/sqrt(n));
    Xticks=Xticks(shuffle_conds);
    colors=colors(shuffle_conds,:);
    
    %set up the graph:
    figure('Name',reg);
    %subplot(1,2,2);
    bar(1:num_cond,zeros(1,num_cond),'FaceColor','none','EdgeColor','none');
    set(gca,'XTickLabel',Xticks,'XTickLabelRotation',45)
    %ylabel(sprintf('similarity%s',Fisher_title),'Fontsize',16)
    title(reg);
    %xlabel('','Fontsize',14);
    hold on
    for i=1:num_cond
        bar(i,averageCon(i),'FaceColor',colors(i,:));
        errorbar(i,averageCon(i),SEM(i),'k');
    end
    %set(gca,'xtick',1:num_cond,'XTickLabel',Xticks)
    xlim([0.5 num_cond+0.5]);
    % Plot subject data
    if plotSingSub
        subjDataX=[];
        subjDataY=[];
        for i=1:num_cond
            subjDataX = [subjDataX ones(1,n)*i];
            subjDataY = [subjDataY data(:,i)'];
        end
        scatter(subjDataX,subjDataY, 15, 'ko', 'filled')
        
        % Plot lines connecting all pre and all post
        for ii = 1:n
            for ii = 1:n
                plot(1:num_cond/2, data(ii,1:num_cond/2))
                plot((num_cond/2+1):num_cond, data(ii,(num_cond/2+1):num_cond))
            end
        end
    end
    hold off
    
    
    %% stats - I put them here just bc was easier for me to do it with the data set up the way it were:
    fprintf('stats for region %s, PK HC-FORG\n',reg)
    % mean and SD of each condition:
    for cc=1:num_cond
        fprintf('%s mean: %.3f, SD: %.2f \n',Xticks{cc},mean(data(:,cc)),std(data(:,cc)))
    end
    PK_A_HC=[PK_A_HC data(:,1)];
    stats_data=data(:,[1,2,4,5]);%RM was removed already
    %stats_data=data([1:15 17:18],[2,3,7,8]);%select conditions, remove subj RM(?) (no HC)
    averageCon=nanmean(stats_data);
    num_cond=size(stats_data,2);
    n=size(stats_data,1);
    Y=reshape(stats_data,size(stats_data,1)*size(stats_data,2),1);
    S=repmat([1:n]',num_cond,1);
    F1=[ones(n*num_cond/2,1);zeros(n*num_cond/2,1)];%A/B face
    F2=repmat([ones(n,1);ones(n,1)*2],2,1);%memory
    fprintf('ANOVA post to pre similarity: %s PK: A/B face by HC-FORG\n',reg)
    stats = rm_anova2(Y,S,F1,F2,{'A/B face','HC-FORG'})
    
    col1=1;
    col2=2;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('PK A: HC-FORG: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    
    
    col1=3;
    col2=4;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('PK B: HC-FORG: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    
    
    col1=1;
    col2=3;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('PK HC: A-B: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    
    col1=2;
    col2=4;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('PK FORG: A-B: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    
    fprintf('\nstats for region %s, NPK HC-FORG\n',reg)
    stats_data=data(:,[1,2,4,5]+6);%RM was removed already
    %stats_data=data([1:15 17:18],[2,3,7,8]);%select conditions, remove subj RM(?) (no HC)
    averageCon=nanmean(stats_data);
    num_cond=size(stats_data,2);
    n=size(stats_data,1);
    Y=reshape(stats_data,size(stats_data,1)*size(stats_data,2),1);
    S=repmat([1:n]',num_cond,1);
    F1=[ones(n*num_cond/2,1);zeros(n*num_cond/2,1)];%A/B face
    F2=repmat([ones(n,1);ones(n,1)*2],2,1);%memory
    fprintf('ANOVA post to pre similarity: %s NPK: A/B face by HC-FORG\n',reg)
    stats = rm_anova2(Y,S,F1,F2,{'A/B face','HC-FORG'})
    
    col1=1;
    col2=2;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('NPK A: HC-FORG: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    
    
    col1=3;
    col2=4;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('NPK B: HC-FORG: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    
    
    col1=1;
    col2=3;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('NPK HC: A-B: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    
    col1=2;
    col2=4;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('NPK FORG: A-B: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    
    %% differences from non-ass:
    fprintf('\nstats for region %s, PK HC-NONASS\n',reg)
    stats_data=data(:,[1,3,4,6]);%RM was removed already
    col1=1;
    col2=2;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('PK A: HC-NONASS: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    
    
    col1=3;
    col2=4;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('PK B: HC-NONASS: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    
    fprintf('\nstats for region %s, NPK HC-NONASS\n',reg)
    stats_data=data(:,[1,3,4,6]+6);%RM was removed already
    col1=1;
    col2=2;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('NPK A: HC-NONASS: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    
    
    col1=3;
    col2=4;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
    fprintf('NPK B: HC-NONASS: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
end %ends loop for all regs

%compare PK_A_HC across regs:
stats_data=PK_A_HC;
col1=1;
col2=2;
[h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
CohenD=mean(averageCon(col1)-averageCon(col2))/std([stats_data(:,col1);stats_data(:,col2)]);
fprintf('PK_A_HC reg1 vs. reg2: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);

end