function [data, curr_data]=Analyse_plot_AssNonAss_Assymetry_plot_each_score_supp(ResultsAssNonAssOnlyNum,ResultsAssNonAss,closePrev,plotSingSub)

if closePrev
    close all
end

Fisher=1;
fnames = fieldnames(ResultsAssNonAssOnlyNum);
for r=1%:numel(fnames)
    reg=fnames{r};
    curr_data=ResultsAssNonAssOnlyNum.(reg);
    Xt=ResultsAssNonAss.(reg)(1,2:end);
    
    if Fisher %fisher transform the data, that is usually desireable.
        curr_data=atanh(curr_data);
        Fisher_title='(F-transformed)';
    else
        Fisher_title='';
    end
    
    
    averageCon=mean(curr_data);
    
    %% plot pre and post values, grouped by pre and post:
    %compute within-subject SEM for both tasks:
    num_cond=size(curr_data,2);
    n=size(curr_data,1);
    %subjs_av=mean(curr_data,2);
    %withinSEM=curr_data-repmat(subjs_av,[1,num_cond]);
    %SEM=abs(std(withinSEM)/sqrt(n));
    SEM=std(curr_data)./sqrt(n);
    %set up the graph:
    colors=[...
        0.4      0.4       0.4
        0.8      0.8       0.8
        0.4      0.4       0.4
        0.8      0.8       0.8
        0        0.4470    0.7410
        0        0.6470    0.9410
        0.8500   0.3250    0.0980
        0.9500   0.6250    0.1980
        
        ];
    figure;
    Xticks=Xt;
    bar(1:num_cond,averageCon);
    set(gca,'XTickLabel',Xticks,'XTickLabelRotation',25)
    ylabel(sprintf('similarity%s',Fisher_title),'Fontsize',16)
    title(reg);
    %xlabel('','Fontsize',14);
    hold on
    for i=1:num_cond
        bar(i,averageCon(i),'FaceColor',colors(i,:));
        errorbar(i,averageCon(i),SEM(i),'k.');
    end
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
    
    
    %% plot pre and post values, ASS non ASS next to each other
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % IN THE SUPP FIGURE %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %save this for later:
    %data=curr_data(:,[1,2,5,6,3,4,7,8]);
    
    %PLOT FOR SUPPLEMENTARY:
    shuffle_conds=[5,6,1,2,7,8,3,4]; %[1,5,2,6,3,7,4,8];
    curr_data=curr_data(:,shuffle_conds);
    SEM=std(curr_data)./sqrt(n);
    averageCon=mean(curr_data);
    Xticks=Xticks(shuffle_conds);
    colors=[...
        0        0.4470    0.7410
        0.4      0.4       0.4
        
        0        0.6470    0.9410
        0.8      0.8       0.8
        0.8500   0.3250    0.0980
        0.4      0.4       0.4
       
        0.9500   0.6250    0.1980
        0.8      0.8       0.8
        ];
    %graph
    figure;
    bar(1:num_cond,zeros(1,num_cond),'FaceColor','none','EdgeColor','none');
    set(gca,'XTickLabel',Xticks,'XTickLabelRotation',25)
    ylabel(sprintf('similarity%s',Fisher_title),'Fontsize',16)
    title(reg);
    %xlabel('','Fontsize',14);
    hold on
    for i=1:num_cond
        bar(i,averageCon(i),'FaceColor',colors(i,:));
        errorbar(i,averageCon(i),SEM(i),'k');
    end
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
            plot([1,2], [curr_data(ii,1), curr_data(ii,2)]);
            plot([3,4], [curr_data(ii,3), curr_data(ii,4)]);
            plot([5,6], [curr_data(ii,5), curr_data(ii,6)]);
            plot([7,8], [curr_data(ii,7), curr_data(ii,8)]);
        end
    end
    hold off
    
    
    %% STATS:
    %each colum diff from zero:
    for i=1:num_cond
        [h,p,ci,stats] = ttest(curr_data(:,i));
        fprintf('SEPARATED CONDS: %s: ass diff from zero: t: %.2f, p: %.3f \n',Xticks{i},stats.tstat,p)
    end
    
    for i=[1,3,5,7]
        [h,p,ci,stats] = ttest(curr_data(:,i),curr_data(:,i+1));
        fprintf('SEPARATED CONDS: %s: ass-non ass diff: t: %.2f, p: %.3f \n',Xticks{i},stats.tstat,p)
    end
    
    col1=1;
    col2=3;
    [h,p,ci,stats] = ttest(curr_data(:,col1),curr_data(:,col2));
    fprintf('SEPARATED CONDS: PAIRED, PK BA vs. AB diff: t: %.2f, p: %.3f \n',stats.tstat,p)
    
    col1=5;
    col2=7;
    [h,p,ci,stats] = ttest(curr_data(:,col1),curr_data(:,col2));
    fprintf('SEPARATED CONDS: PAIRED, n-PK BA vs. AB diff: t: %.2f, p: %.3f \n',stats.tstat,p)
    
    col1=2;
    col2=4;
    [h,p,ci,stats] = ttest(curr_data(:,col1),curr_data(:,col2));
    fprintf('SEPARATED CONDS: SHUFFLED, PK BA vs. AB diff: t: %.2f, p: %.3f \n',stats.tstat,p)
    
    col1=6;
    col2=8;
    [h,p,ci,stats] = ttest(curr_data(:,col1),curr_data(:,col2));
    fprintf('SEPARATED CONDS: Shuffled, n-PK BA vs. AB diff: t: %.2f, p: %.3f \n',stats.tstat,p)
    
end %ends loop for all regs



end