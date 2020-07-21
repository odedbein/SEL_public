function [data, curr_data]=Analyse_plot_AssNonAss_Assymetry(ResultsAssNonAssOnlyNum,ResultsAssNonAss,closePrev,plotSingSub)

if closePrev
    close all
end
plot_pre_post=0;
Fisher=1;
fnames = fieldnames(ResultsAssNonAssOnlyNum);

for r=9 %:numel(fnames)
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
    subjs_av=mean(curr_data,2);
    withinSEM=curr_data-repmat(subjs_av,[1,num_cond]);
    SEM=abs(std(withinSEM)/sqrt(n));
    Xticks=Xt;
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
    if plot_pre_post
        figure;
        
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
        
    end
    
    %% plot pre and post values, pre and post appear one next to each other:
    %compute within-subject SEM for both tasks:
    
    shuffle_conds=[1,5,2,6,3,7,4,8];
    curr_data=curr_data(:,shuffle_conds);
    SEM=SEM(shuffle_conds);
    averageCon=mean(curr_data);
    Xticks=Xticks(shuffle_conds);
    colors=[...
        
    0        0.6470    0.9410
    0        0.4470    0.7410
    
    0.8      0.8       0.8
    0.4      0.4       0.4
    
    0.9500   0.6250    0.1980
    0.8500   0.3250    0.0980
    
    0.8      0.8       0.8
    0.4      0.4       0.4
    
    ];

%set up the graph:
if plot_pre_post
    figure;
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
            plot([1,2], [curr_data(ii,1), curr_data(ii,2)]);
            plot([3,4], [curr_data(ii,3), curr_data(ii,4)]);
            plot([5,6], [curr_data(ii,5), curr_data(ii,6)]);
            plot([7,8], [curr_data(ii,7), curr_data(ii,8)]);
        end
    end
    hold off
end
%% IN THE PAPER: plot the differences - B became more similar to A than A to B:
num_cond=size(curr_data,2);
data=[];
for i=2:2:num_cond
    data=[data (curr_data(:,i)-curr_data(:,(i-1)))];
end

num_cond=size(data,2);
n=size(data,1);
subjs_av=mean(data,2);
withinSEM=data-repmat(subjs_av,[1,num_cond]);
SEM=abs(std(withinSEM)/sqrt(n));
averageCon=mean(data);
Xticks={'FF_ASS_BtoA-AtoB','FF_NONASS_BtoA-AtoB','NF_ASS_BtoA-AtoB','NF_NONASS_BtoA-AtoB'};
colors=[...
    0        0.6470    0.9410
    0        0.4470    0.7410
    0.9500   0.6250    0.1980
    0.8500   0.3250    0.0980
    ];

%set up the graph:
figure('Name',reg);
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
        subjDataY = [subjDataY data(:,i)'];
    end
    scatter(subjDataX,subjDataY, 15, 'ko', 'filled')
    
    % Plot lines connecting all pre and all post
    for ii = 1:n
        plot([1,2], [data(ii,1), data(ii,2)]);
        plot([3,4], [data(ii,3), data(ii,4)]);
    end
end
hold off

%% plot the differences - A became more similar to B than B to A:
if plot_pre_post
    num_cond=size(curr_data,2);
    data=[];
    for i=2:2:num_cond
        data=[data (curr_data(:,(i-1))-curr_data(:,(i)))];
    end
    
    num_cond=size(data,2);
    n=size(data,1);
    subjs_av=mean(data,2);
    withinSEM=data-repmat(subjs_av,[1,num_cond]);
    SEM=abs(std(withinSEM)/sqrt(n));
    averageCon=mean(data);
    Xticks={'FF_ASS_AtoB-BtoA','FF_NONASS_AtoB-BtoA','NF_ASS_AtoB-BtoA','NF_NONASS_AtoB-BtoA'};
    colors=[...
        0        0.6470    0.9410
        0        0.4470    0.7410
        0.9500   0.6250    0.1980
        0.8500   0.3250    0.0980
        ];
    
    %set up the graph:
    figure;
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
            subjDataY = [subjDataY data(:,i)'];
        end
        scatter(subjDataX,subjDataY, 15, 'ko', 'filled')
        
        % Plot lines connecting all pre and all post
        for ii = 1:n
            plot([1,2], [data(ii,1), data(ii,2)]);
            plot([3,4], [data(ii,3), data(ii,4)]);
        end
    end
    hold off
end
%% stats:
%% B became more similar to A than A to B:
fprintf('\n\n**region %s**\n',reg)
num_cond=size(curr_data,2);
data=[];
for i=2:2:num_cond
    data=[data (curr_data(:,i)-curr_data(:,(i-1)))];
end


fprintf('\nstats for region %s\n',reg)
num_cond=size(data,2);
n=size(data,1);
Y=reshape(data,size(data,1)*size(data,2),1);
S=repmat([1:n]',num_cond,1);
F1=[ones(n*num_cond/2,1);zeros(n*num_cond/2,1)];%famous/non-famous
F2=repmat([ones(n,1);ones(n,1)*2],2,1);%number of changes
%fprintf('ANOVA post-pre similarity: %s famous vs. non-famous\n',reg)
%stats = rm_anova2(Y,S,F1,F2,{'PK:(1)Famous/(2)Non-Famous','ass-non-ass'})

labels={'PK: ass','PK: non-ass','nPK: ass','nPK: non-ass'};
for cc=1:4
    fprintf('%s mean: %.3f, SD: %.2f \n',labels{cc},mean(data(:,cc)),std(data(:,cc)))
    [h,p,ci,stats] = ttest(data(:,cc));
    CohenD=mean(data(:,cc))/std(data(:,cc));
    fprintf('%s: diff from zero: t: %.2f, p: %.3f, d: %.2f \n',labels{cc},stats.tstat,p,CohenD);
    ci
end

col1=1;
col2=2;
[h,p,ci,stats] = ttest(data(:,col1),data(:,col2));
CohenD=mean(averageCon(col1)-averageCon(col2))/std(data(:,col1)-data(:,col2));
fprintf('PK: ASS_NONASS: t: %.2f, p: %.3f, d: %.2f \n',stats.tstat,p,CohenD);
ci

col1=3;
col2=4;
[h,p,ci,stats] = ttest(data(:,col1),data(:,col2));
CohenD=mean(averageCon(col1)-averageCon(col2))/std(data(:,col1)-data(:,col2));
fprintf('nPK: ASS_NONASS: t: %.2f, p: %.3f, d: %.2f \n',stats.tstat,p,CohenD);
ci

col1=1;
col2=3;
[h,p,ci,stats] = ttest(data(:,col1),data(:,col2));
CohenD=mean(averageCon(col1)-averageCon(col2))/std(data(:,col1)-data(:,col2));
fprintf('Ass: PK-nPK: t: %.2f, p: %.3f, d: %.2f \n',stats.tstat,p,CohenD);
ci

end %ends loop for all regs



end