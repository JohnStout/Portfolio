%% cumulative density figure
% data: cell array containing data
% color: cell array containing color
% x_label: string label
% title_label: string
% paired: 1, y, or Y, for paired kstest. Nothing or anything else for
% two-sample


function [p,kstat] = cumulativeDensity(data,color,x_label,title_label,saveName,paired)

    figure('color','w'); hold on;
    for i = 1:length(data)
        c{i} = cdfplot(data{i});
        c{i}.Color = color{i};
        c{i}.LineWidth = 2;
    end
    grid off
    ylabel('Cumulative Frequency')
    xlabel(x_label)
    title(title_label)
    set(gcf,'Position',[300 250 350 300])

    if exist('paired') & ( paired == 1 | contains(paired,[{'y'},{'Y'}]) )
        [h,p,kstat]=kstest(data{1},data{2});        
    else
        [h,p,kstat]=kstest2(data{1},data{2},'Tail','unequal');
    end
    
    ylimits = ylim;
    xlimits = xlim;
    %text(xlimits(2)/2,ylimits(2)/2,['D = ',num2str(kstat) newline 'p = ', num2str(p)])

    if exist('saveName') 
        print('-painters',[saveName,'.eps'],'-depsc','-r0')
    end

    
    
    