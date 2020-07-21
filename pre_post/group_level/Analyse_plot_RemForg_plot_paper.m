function [data, curr_data]=Analyse_plot_RemForg_plot_paper(ResultsRemForgOnlyNum,closePrev,plotSingSub)


Exc_0808RM=1; %participant had no HC in FN pairs, excluded

if closePrev
    close all
end

plot_pre_post=0;
Fisher=1;
fnames = fieldnames(ResultsRemForgOnlyNum);

for r=1%:numel(fnames) %(start_reg-1)*3+1:end_reg*3
    reg=fnames{r}
    curr_data=ResultsRemForgOnlyNum.(reg);
   
    if  Exc_0808RM
        curr_data=curr_data([1:17 19:end],:);
    end
    
    if Fisher %fisher transform the data, that is usually desireable.
        curr_data=atanh(curr_data);
        Fisher_title='(F-transformed)';
    else
        Fisher_title='';
    end
    
    %% set up things for the graph:
    Xticks={'PK:pre, REM','PK:pre, HC','PK:pre, FORG','PK:pre, SUBCHOICE','PK:pre, SUBDIST','NPK:pre, REM','NPK:pre, HC','NPK:pre, FORG','NPK:pre, SUBCHOICE','NPK:pre, SUBDIST','PK:post, REM','PK:post, HC','PK:post, FORG','PK:post, SUBCHOICE','PK:post, SUBDIST','NPK:post, REM','NPK:post, HC','NPK:post, FORG','NPK:post, SUBCHOICE','NPK:post, SUBDIST'};
    
    %set up the graph:
    colors=[...
        0.4      0.4       0.4
        0.2      0.2       0.2
        0.8      0.8       0.8
        1        1         1
        1        1         1
        0.4      0.4       0.4
        0.2      0.2       0.2
        0.8      0.8       0.8
        1        1         1
        1        1         1
        
        0        0.4470    0.7410
        0        0.2470    0.5410
        0        0.6470    0.9410
        1        1         1
        1        1         1
        0.8500   0.3250    0.0980
        0.6500   0.1250    0.0000
        0.9500   0.6250    0.1980
        1        1         1
        1        1         1
        ];
    
    %% plot pre and post values, pre and post appear one next to each other, only HC and FORG:
    %(supplemental figure, the reviewer asked):
    %shufffle all - that's to keep things in order for later:
    jump=10;
    shuffle_conds=[1:jump;jump+(1:jump)];
    reshape(shuffle_conds,numel(shuffle_conds),1);
    curr_data=curr_data(:,shuffle_conds);
    
    %% plot the differences:
    num_cond=size(curr_data,2);
    data=[];
    for i=2:2:num_cond
        data=[data (curr_data(:,i)-curr_data(:,(i-1)))];
    end
    
    %% plot only HC-FORG by famous/non-famous, grouped by famous
    stats_data=data(:,[2,3,7,8]);%RM was removed already
    averageCon=nanmean(stats_data);
    num_cond=size(stats_data,2);
    n=size(stats_data,1);
    subjs_av=nanmean(stats_data,2);
    withinSEM=stats_data-repmat(subjs_av,[1,num_cond]);
    SEM=abs(nanstd(withinSEM)/sqrt(n));
    Xticks={'PK: REM','PK: HC','PK: FORG','PK: SUBCHOICE','PK: SUBDIST','NPK: REM','NPK: HC','NPK: FORG','NPK: SUBCHOICE','NPK: SUBDIST'};
    Xticks=Xticks([2,3,7,8]);% {'FF REM','FF HC','FF FORG','FF SUBCHOICE','FF SUBDIST','NPK: REM','NPK: HC','NPK: FORG','NPK: SUBCHOICE','NPK: SUBDIST'};
    colors=[...
        0        0.4470    0.7410
        0        0.2470    0.5410
        0        0.6470    0.9410
        1        1         1
        1        1         1
        0.8500   0.3250    0.0980
        0.6500   0.1250    0.0000
        0.9500   0.6250    0.1980
        1        1         1
        1        1         1
        ];
    colors=colors([2,3,7,8],:);
    
    %set up the graph:
    if plot_pre_post
        figure('Name',reg);
        bar(1:num_cond,averageCon);
        set(gca,'XTickLabel',Xticks)
        ylabel(sprintf('similarity%s',Fisher_title),'Fontsize',16)
        title(reg);
        %xlabel('','Fontsize',14);
        hold on
        for i=1:num_cond
            bar(i,averageCon(i),'FaceColor',colors(i,:));
            errorbar(i,averageCon(i),SEM(i),'k.');
        end
        set(gca,'xtick',1:num_cond,'XTickLabel',Xticks)
        xlim([0.5 num_cond+0.5]);
        % Plot subject data
        if plotSingSub
            subjDataX=[];
            subjDataY=[];
            for i=1:num_cond
                subjDataX = [subjDataX ones(1,n)*i];
                subjDataY = [subjDataY stats_data(:,i)'];
            end
            scatter(subjDataX,subjDataY, 15, 'ko', 'filled')
            
            % Plot lines connecting all pre and all post
            for ii = 1:n
                for ii = 1:n
                    plot(1:num_cond/2, stats_data(ii,1:num_cond/2))
                    plot((num_cond/2+1):num_cond, stats_data(ii,(num_cond/2+1):num_cond))
                end
            end
        end
        hold off
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% IN PAPER, FIG2: plot only HC-FORG by famous/non-famous, grouped by memory
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    shuffle_conds=[1 3 2 4];
    stats_data=stats_data(:,shuffle_conds);
    averageCon=nanmean(stats_data);
    num_cond=size(stats_data,2);
    n=size(stats_data,1);
    subjs_av=nanmean(stats_data,2);
    %withinSEM=stats_data-repmat(subjs_av,[1,num_cond]);
    SEM=abs(nanstd(stats_data)/sqrt(n));
    Xticks=Xticks(shuffle_conds);% {'FF REM','FF HC','FF FORG','FF SUBCHOICE','FF SUBDIST','NPK: REM','NPK: HC','NPK: FORG','NPK: SUBCHOICE','NPK: SUBDIST'};
    colors=colors(shuffle_conds,:);
    
    %set up the graph:
    figure('Name',reg);
    %subplot(1,2,2);
    bar(1:num_cond,zeros(1,num_cond),'FaceColor','none','EdgeColor','none');
    set(gca,'XTickLabel',Xticks)
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
            subjDataY = [subjDataY stats_data(:,i)'];
        end
        scatter(subjDataX,subjDataY, 15, 'ko', 'filled')
        
        % Plot lines connecting all pre and all post
        for ii = 1:n
            for ii = 1:n
                plot(1:num_cond/2, stats_data(ii,1:num_cond/2))
                plot((num_cond/2+1):num_cond, stats_data(ii,(num_cond/2+1):num_cond))
            end
        end
    end
    hold off
    
    if plot_pre_post
        %% plot all conditions
        num_cond=size(data,2);
        n=size(data,1);
        subjs_av=nanmean(data,2);
        withinSEM=data-repmat(subjs_av,[1,num_cond]);
        SEM=abs(nanstd(withinSEM)/sqrt(n));
        averageCon=nanmean(data);
        Xticks={'PK: REM','PK: HC','PK: FORG','PK: SUBCHOICE','PK: SUBDIST','NPK: REM','NPK: HC','NPK: FORG','NPK: SUBCHOICE','NPK: SUBDIST'};
        colors=[...
            0        0.4470    0.7410
            0        0.2470    0.5410
            0        0.6470    0.9410
            1        1         1
            1        1         1
            0.8500   0.3250    0.0980
            0.6500   0.1250    0.0000
            0.9500   0.6250    0.1980
            1        1         1
            1        1         1
            ];
        
        %set up the graph:
        figure;
        subplot(2,1,1);
        bar(1:num_cond,averageCon);
        set(gca,'XTickLabel',Xticks)
        ylabel(sprintf('similarity%s',Fisher_title),'Fontsize',16)
        title(reg);
        %xlabel('','Fontsize',14);
        hold on
        for i=1:num_cond
            bar(i,averageCon(i),'FaceColor',colors(i,:));
            errorbar(i,averageCon(i),SEM(i),'k.');
        end
        set(gca,'xtick',1:num_cond,'XTickLabel',Xticks,'XTickLabelRotation',45)
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
    end
    %% stats - I put them here just bc was easier for me to do it with the data set up the way it were:
    fprintf('stats for region %s, HC-FORG\n',reg)
    stats_data=data(:,[2,3,7,8]);%RM was removed already
    %stats_data=data([1:15 17:18],[2,3,7,8]);%select conditions, remove subj RM(?) (no HC)
    averageCon=nanmean(stats_data);
    num_cond=size(stats_data,2);
    n=size(stats_data,1);
    Y=reshape(stats_data,size(stats_data,1)*size(stats_data,2),1);
    S=repmat([1:n]',num_cond,1);
    F1=[ones(n*num_cond/2,1);ones(n*num_cond/2,1)*2];%famous/non-famous
    F2=repmat([ones(n,1);ones(n,1)*2],2,1);%memory
    sprintf('ANOVA %s F1; PK:(1)Famous/(2)Non-Famous, F2: memory\n',reg)
    X=[Y,F1,F2,S];
    [P,MSEAB,F3] = RMAOV2_mod(X,0.05,1); %this doesn't give the partial eta for the interaction


    labels={'PK: HC','PK: FORG','n-PK: HC','nPK: FORG'};
    for cc=1:4
        fprintf('%s mean: %.3f, SD: %.2f \n',labels{cc},mean(stats_data(:,cc)),std(stats_data(:,cc)))
    end

    col1=1;
    col2=2;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std(stats_data(:,col1)-stats_data(:,col2));
    fprintf('PK: HC-FORG: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    ci
    
    col1=3;
    col2=4;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std(stats_data(:,col1)-stats_data(:,col2));
    fprintf('nPK: HC-FORG: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    ci
    
    col1=1;
    col2=3;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std(stats_data(:,col1)-stats_data(:,col2));
    fprintf('HC: PK-nPK: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    ci
    col1=2;
    col2=4;
    [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std(stats_data(:,col1)-stats_data(:,col2));
    fprintf('FORG: PK-nPK: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    ci
    
    %% plot the pre and the post separately:
    if plot_pre_post
        
        %% set up things for the graph:
        Xticks={'PK:pre, REM','PK:pre, HC','PK:pre, FORG','PK:pre, SUBCHOICE','PK:pre, SUBDIST','NPK:pre, REM','NPK:pre, HC','NPK:pre, FORG','NPK:pre, SUBCHOICE','NPK:pre, SUBDIST','PK:post, REM','PK:post, HC','PK:post, FORG','PK:post, SUBCHOICE','PK:post, SUBDIST','NPK:post, REM','NPK:post, HC','NPK:post, FORG','NPK:post, SUBCHOICE','NPK:post, SUBDIST'};
        
        %set up the graph:
        colors=[...
            0.4      0.4       0.4
            0.2      0.2       0.2
            0.8      0.8       0.8
            1        1         1
            1        1         1
            0.4      0.4       0.4
            0.2      0.2       0.2
            0.8      0.8       0.8
            1        1         1
            1        1         1
            
            0        0.4470    0.7410
            0        0.2470    0.5410
            0        0.6470    0.9410
            1        1         1
            1        1         1
            0.8500   0.3250    0.0980
            0.6500   0.1250    0.0000
            0.9500   0.6250    0.1980
            1        1         1
            1        1         1
            ];
        
        %% plot pre and post values, pre and post appear one next to each other, only HC and FORG:
        %(supplemental figure that we eventually removed, the reviewer asked):
        %shufffle all - that's because I was lazy:
        %re-define the shuffle
        jump=10;
        shuffle_conds=[1:jump;jump+(1:jump)];
        reshape(shuffle_conds,numel(shuffle_conds),1);
        Xticks=Xticks(shuffle_conds);
        colors=colors(shuffle_conds,:);
        
        %now select:
        curr_conds=[3,5,4,6,13,15,14,16];
        data=curr_data(:,curr_conds);
        num_cond=size(data,2);
        n=size(data,1);
        SEM=nanstd(data)/sqrt(n);
        averageCon=nanmean(data);
        Xticks=Xticks(curr_conds);
        colors=colors(curr_conds,:);
        
        %set up the graph:
        figure;
        bar(1:num_cond,zeros(1,num_cond),'FaceColor','none','EdgeColor','none');
        set(gca,'XTickLabel',Xticks)
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
        hold off
        
        %stats are easy to do this way, so save it:
        stats_conds=[1,2,5,6,3,4,7,8]; %[1,2,5,6,3,4,7,8]
        all_stats_data=data(:,stats_conds);
        stats_Xticks=Xticks(stats_conds);
        stats_colors=colors(stats_conds,:);
        %additional plots:
        curr_conds=[1,5,3,7,2,6,4,8]; %[1,3,2,4,5,7,6,8]; %[1,2,5,6,3,4,7,8]
        data=data(:,curr_conds);
        num_cond=size(data,2);
        n=size(data,1);
        SEM=nanstd(data)/sqrt(n);
        averageCon=nanmean(data);
        Xticks=Xticks(curr_conds);
        colors=colors(curr_conds,:);
        
        
        %set up the graph:
        figure;
        bar(1:num_cond,zeros(1,num_cond),'FaceColor','none','EdgeColor','none');
        set(gca,'XTickLabel',Xticks)
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
        hold off
        %% stats - by MEMORY (as plotted above):
        stats_data=data(:,1:4);%RM was removed already
        num_cond=size(stats_data,2);
        n=size(stats_data,1);
        Y=reshape(stats_data,size(stats_data,1)*size(stats_data,2),1);
        S=repmat([1:n]',num_cond,1);
        F1=[ones(n*num_cond/2,1);zeros(n*num_cond/2,1)];%PRE.POST
        F2=repmat([ones(n,1);ones(n,1)*2],2,1);%famous/non-famou
        fprintf('\nANOVA HC: PRE/POST: %s famous vs. non-famous\n',reg)
        stats = rm_anova2(Y,S,F1,F2,{'PRE/POST','PK/n-PK'})
        
        %labels={'HC PRE: PK','HC PRE: n-PK','HC POST: PK','HC POST: n-PK'};
        for cc=1:4
            fprintf('%s mean: %.3f, SD: %.2f \n',Xticks{cc},mean(stats_data(:,cc)),std(stats_data(:,cc)))
        end

        col1=1;
        col2=2;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('HC PRE: PK-nPK: t: %.2f, p: %.3f, d: %.2f \n',stats.tstat,p,CohenD);
        
        col1=3;
        col2=4;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('HC POST: PK-nPK: t: %.2f, p: %.3f, d: %.2f \n',stats.tstat,p,CohenD);
        
        
        col1=1;
        col2=3;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('HC, PK: PRE-POST: t: %.2f, p: %.3f, d: %.2f \n',stats.tstat,p,CohenD);
        
        col1=2;
        col2=4;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('HC, n-PK: PRE-POST: t: %.2f, p: %.3f, d: %.2f \n',stats.tstat,p,CohenD);
        
        
        stats_data=data(:,5:8);%RM was removed already
        num_cond=size(stats_data,2);
        n=size(stats_data,1);
        Y=reshape(stats_data,size(stats_data,1)*size(stats_data,2),1);
        S=repmat([1:n]',num_cond,1);
        F1=[ones(n*num_cond/2,1);zeros(n*num_cond/2,1)];%PRE.POST
        F2=repmat([ones(n,1);ones(n,1)*2],2,1);%famous/non-famou
        fprintf('\nANOVA FORG: PRE/POST: %s famous vs. non-famous\n',reg)
        stats = rm_anova2(Y,S,F1,F2,{'PRE/POST','PK/n-PK'})
        
        %% stats - by PRE POST:
        stats_data=all_stats_data;%RM was removed already
        %just to check that all is in place, plot the order of the
        %conditions:
        averageCon=nanmean(stats_data);
        num_cond=size(stats_data,2);
        n=size(stats_data,1);
        Xticks=stats_Xticks;
        colors=stats_colors;
        
        %set up the graph:
        figure;
        bar(1:num_cond,zeros(1,num_cond),'FaceColor','none','EdgeColor','none');
        set(gca,'XTickLabel',Xticks)
        ylabel(sprintf('similarity%s',Fisher_title),'Fontsize',16)
        title(sprintf('STATS ARE THIS ORDER: %s',reg));
        %xlabel('','Fontsize',14);
        hold on
        for i=1:num_cond
            bar(i,averageCon(i),'FaceColor',colors(i,:));
            errorbar(i,averageCon(i),SEM(i),'k');
        end
        set(gca,'xtick',1:num_cond,'XTickLabel',Xticks,'XTickLabelRotation',45)
        xlim([0.5 num_cond+0.5]);
        hold off
        
        
        %actually do the stats:
        fprintf('stats PRE-LEARNING for region %s, HC-FORG\n',reg)
        stats_data=all_stats_data(:,1:4);%RM was removed already
        averageCon=nanmean(stats_data);
        num_cond=size(stats_data,2);
        n=size(stats_data,1);
        Y=reshape(stats_data,size(stats_data,1)*size(stats_data,2),1);
        S=repmat([1:n]',num_cond,1);
        F1=[ones(n*num_cond/2,1);zeros(n*num_cond/2,1)];%famous/non-famous
        F2=repmat([ones(n,1);ones(n,1)*2],2,1);%memory
        fprintf('ANOVA PRE-LEARNINGsimilarity: %s famous vs. non-famous\n',reg)
        stats = rm_anova2(Y,S,F1,F2,{'PK:(1)Famous/(2)Non-Famous','HC-FORG'})
        
        col1=1;
        col2=2;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('PK: HC-FORG: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
        
        
        col1=3;
        col2=4;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('nPK: HC-FORG: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
        
        
        col1=1;
        col2=3;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('HC: PK-nPK: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
        
        col1=2;
        col2=4;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('FORG: PK-nPK: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
        
        %actually do the stats:
        fprintf('stats POST-LEARNING for region %s, HC-FORG\n',reg)
        stats_data=all_stats_data(:,5:8);%RM was removed already
        averageCon=nanmean(stats_data);
        num_cond=size(stats_data,2);
        n=size(stats_data,1);
        Y=reshape(stats_data,size(stats_data,1)*size(stats_data,2),1);
        S=repmat([1:n]',num_cond,1);
        F1=[ones(n*num_cond/2,1);zeros(n*num_cond/2,1)];%famous/non-famous
        F2=repmat([ones(n,1);ones(n,1)*2],2,1);%memory
        fprintf('ANOVA POST-LEARNING similarity: %s famous vs. non-famous\n',reg)
        stats = rm_anova2(Y,S,F1,F2,{'PK:(1)Famous/(2)Non-Famous','HC-FORG'})
        
        col1=1;
        col2=2;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('PK: HC-FORG: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
        
        
        col1=3;
        col2=4;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('nPK: HC-FORG: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
        
        
        col1=1;
        col2=3;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('HC: PK-nPK: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
        
        col1=2;
        col2=4;
        [h,p,ci,stats] = ttest(stats_data(:,col1),stats_data(:,col2));
        CohenD=mean(averageCon(col1)-averageCon(col2))/std([data(:,col1);data(:,col2)]);
        fprintf('FORG: PK-nPK: t: %.2f, p: %.2f, d: %.2f \n',stats.tstat,p,CohenD);
    end
    
end %ends loop for all regs


end