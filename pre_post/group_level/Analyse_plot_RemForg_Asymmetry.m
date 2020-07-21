function [data, curr_data]=Analyse_plot_RemForg_Asymmetry(ResultsRemForgOnlyNum,ResultsRemForg,closePrev,plotSingSub)


Exc_0808RM=1; %participant had no HC in FN pairs, excluded
if closePrev
    close all
end
plot_pre_post=1;
Fisher=1;
fnames = fieldnames(ResultsRemForgOnlyNum);
for r=1 %3:numel(fnames)
    reg=fnames{r};
    curr_data=ResultsRemForgOnlyNum.(reg)(:,[1:3,6:8,11:13,16:18]);
    Xt=ResultsRemForg.(reg)(1,([1:3,6:8,11:13,16:18]+1));
   
    if Exc_0808RM
        curr_data=curr_data([1:17 19:end],:);
    end
    
    
    if Fisher %fisher transform the data, that is usually desireable.
        curr_data=atanh(curr_data);
        Fisher_title='(F-transformed)';
    else
        Fisher_title='';
    end
    
    
    averageCon=nanmean(curr_data);
    
    %% plot values, grouped by direction of the asymmetry:
    %compute within-subject SEM for both tasks:
    num_cond=size(curr_data,2);
    n=size(curr_data,1);
    subjs_av=nanmean(curr_data,2);
    withinSEM=curr_data-repmat(subjs_av,[1,num_cond]);
    SEM=abs(nanstd(withinSEM)/sqrt(n));
    Xticks=Xt;
    %set up the graph:
    colors=[...
        0.4      0.4       0.4
        0.2      0.2       0.2
        0.8      0.8       0.8
        0.4      0.4       0.4
        0.2      0.2       0.2
        0.8      0.8       0.8
        
        0        0.4470    0.7410
        0        0.2470    0.5410
        0        0.6470    0.9410
        0.8500   0.3250    0.0980
        0.6500   0.1250    0.0000
        0.9500   0.6250    0.1980
        
        ];
    if plot_pre_post
        figure;
        
        bar(1:num_cond,averageCon);
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
        
    end
    %% plot pre and post values, pre and post appear one next to each other:
    %compute within-subject SEM for both tasks:
    jump=num_cond/2;
    shuffle_conds=[1:jump;jump+(1:jump)];
    reshape(shuffle_conds,numel(shuffle_conds),1);
    curr_data=curr_data(:,shuffle_conds);
    SEM=SEM(shuffle_conds);
    averageCon=nanmean(curr_data);
    Xticks=Xt(shuffle_conds);
    colors=colors(shuffle_conds,:);
    
    %set up the graph:
    if plot_pre_post
        figure;
        
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
                subjDataY = [subjDataY curr_data(:,i)'];
            end
            scatter(subjDataX,subjDataY, 15, 'ko', 'filled')
            
            % Plot lines connecting all pre and all post
            for ii = 1:n
                for pp=1:2:num_cond
                    plot([pp,pp+1], [curr_data(ii,pp), curr_data(ii,pp+1)]);
                end
            end
        end
        hold off
    end
    %% plot the differences - how much B moved to A vs. A moved to B:
    num_cond=size(curr_data,2);
    data=[];
    for i=2:2:num_cond
        data=[data (curr_data(:,i)-curr_data(:,(i-1)))];
    end
    
    num_cond=size(data,2);
    n=size(data,1);
    subjs_av=nanmean(data,2);
    withinSEM=data-repmat(subjs_av,[1,num_cond]);
    SEM=abs(nanstd(withinSEM)/sqrt(n));
    averageCon=nanmean(data);
    Xticks={'FF REM:BtoA-AtoB','FF HC:BtoA-AtoB','FF FORG:BtoA-AtoB',...
        'NFF REM:BtoA-AtoB','NFF HC:BtoA-AtoB','NFF FORG:BtoA-AtoB'...
        };
    colors=[...
        0        0.4470    0.7410
        0        0.2470    0.5410
        0        0.6470    0.9410
        
        0.8500   0.3250    0.0980
        0.6500   0.1250    0.0000
        0.9500   0.6250    0.1980
        ];
    
    %set up the graph:
    if plot_pre_post
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
    
    %% now by memory condition
    jump=3;
    shuffle_conds=[1:jump;jump+(1:jump)];
    reshape(shuffle_conds,numel(shuffle_conds),1);
    data=data(:,shuffle_conds);
    num_cond=size(data,2);
    n=size(data,1);
    SEM=SEM(shuffle_conds);
    averageCon=nanmean(data);
    Xticks=Xticks(shuffle_conds);
    colors=colors(shuffle_conds,:);
    
    %set up the graph:
    if plot_pre_post
        subplot(2,1,2);
        bar(1:num_cond,averageCon);
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
                for pp=1:2:num_cond
                    plot([pp,pp+1], [data(ii,pp), data(ii,pp+1)]);
                end
            end
        end
        hold off
    end
    %% only HC/FORG:
    data=data(:,3:end);
    num_cond=size(data,2);
    n=size(data,1);
    SEM=SEM(3:end);
    averageCon=nanmean(data);
    Xticks={'PK: HC','nPK:HC','PK:Forg','nPK:Forg'};
    colors=colors(3:end,:);
    
    figure;
    bar(1:num_cond,zeros(1,num_cond),'FaceColor','none');
    ylabel('Asymmetry:BpostApre-ApostBpre','Fontsize',16)
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
            for pp=1:2:num_cond
                plot([pp,pp+1], [data(ii,pp), data(ii,pp+1)]);
            end
        end
    end
    hold off
    
    %% stats - I put them here just bc was easier for me to do it with the data set up the way it were:
    fprintf('stats for region %s, asymmetry index, FF/NF by HC/FORG\n',reg)
    stats_data=data(:,[1,3,2,4]);%select conditions, RM was removed in the top, if didn't and want to remove: [1:16 18:19] (no HC)
    averageCon=nanmean(stats_data);
    num_cond=size(stats_data,2);
    n=size(stats_data,1);
    Y=reshape(stats_data,size(stats_data,1)*size(stats_data,2),1);
    S=repmat([1:n]',num_cond,1);
    F1=[ones(n*num_cond/2,1);zeros(n*num_cond/2,1)];%famous/non-famous
    F2=repmat([ones(n,1);ones(n,1)*2],2,1);%memory
    
    fprintf('ANOVA post-pre similarity: %s FF/NF by HC/FORG\n',reg)
    stats = rm_anova2(Y,S,F1,F2,{'PK:(1)FF,(2)NF','MEMORY:(1)HC,(2)FORG'})
    
    %this is like the last graph:
    for cc=1:4
        fprintf('%s mean: %.3f, SD: %.2f \n',Xticks{cc},mean(data(:,cc)),std(data(:,cc)))
        [h,p,ci,stats] = ttest(data(:,cc));
        CohenD=mean(data(:,cc))/std(data(:,cc));
        fprintf('%s: diff from zero: t: %.2f, p: %.3f, d: %.2f \n',Xticks{cc},stats.tstat,p,CohenD);
    end


    col1=1;
    col2=3;
    [h,p,ci,stats] = ttest(data(:,col1),data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std(data(:,col1)-data(:,col2));
    fprintf('PK: HC vs. FORG: t: %.2f, p: %.3f, d: %.3f \n',stats.tstat,p,CohenD);
    
    
    col1=2;
    col2=4;
    [h,p,ci,stats] = ttest(data(:,col1),data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std(data(:,col1)-data(:,col2));
    fprintf('nPK: HC vs. FORG: t: %.2f, p: %.3f, d: %.2f \n',stats.tstat,p,CohenD);
    
    
    col1=1;
    col2=2;
    [h,p,ci,stats] = ttest(data(:,col1),data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std(data(:,col1)-data(:,col2));
    fprintf('HC: PK-nPK: t: %.2f, p: %.3f, d: %.2f \n',stats.tstat,p,CohenD);
    
    col1=3;
    col2=4;
    [h,p,ci,stats] = ttest(data(:,col1),data(:,col2));
    CohenD=mean(averageCon(col1)-averageCon(col2))/std(data(:,col1)-data(:,col2));
    fprintf('FORG: PK-nPK: t: %.2f, p: %.3f, d: %.2f \n',stats.tstat,p,CohenD);
    
end %ends loop for all regs



end