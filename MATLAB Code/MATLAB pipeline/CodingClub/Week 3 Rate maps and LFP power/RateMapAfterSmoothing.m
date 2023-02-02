%% Firing rate maps - how to make? How to interpret?
clear; clc; close all

% load in sample data provided
load('rateMapData2.mat')     

% Create Gaussian filter for rate plot smoothing
srate       = size(delay_rates_mat,2)/20; % samples/sec (total samples / total time)
samples     = ceil(srate*3); % >3 second filter
secPerSam   = samples/srate; % amount of time considered
windowWidth = int16(samples); % 10 is roughly a 3 second filter if your srate is .3 sec (divide the number of points sampled by the amount of time)
halfWidth   = windowWidth/2;
gaussFilter = gausswin(windowWidth);
gaussFilter = gaussFilter/sum(gaussFilter);

% smooth all data
for celli = 1:size(delay_rates_mat,1)
    delay_rates_smooth(celli,:)  = conv(delay_rates_mat(celli,:),gaussFilter);
    iti_rates_smooth(celli,:)    = conv(iti_rates_mat(celli,:),gaussFilter);    
end

% remove unneeded data
delay_rates_smooth = delay_rates_smooth(:,halfWidth:end-halfWidth);
iti_rates_smooth   = iti_rates_smooth(:,halfWidth:end-halfWidth);

% use the function to sort it
x_label = linspace(0,20,size(delay_rates_smooth,2));
jetOn   = 1; % jet color

figure('color','w')
subplot 221
    SortedRateMap(delay_rates_smooth,delay_rates_smooth,1,jetOn);
    title('delay rates sorted by delay rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 222
    SortedRateMap(delay_rates_smooth,iti_rates_smooth,1,jetOn);
    title('delay rates sorted by iti rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 223
    SortedRateMap(iti_rates_smooth,delay_rates_smooth,1,jetOn);
    title('iti rates sorted by delay rates')
    set(gca,'FontSize',8)    
    shading 'interp'    
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 224
    SortedRateMap(iti_rates_smooth,iti_rates_smooth,1,jetOn);
    title('iti rates sorted by iti rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');  

% make a plot that shows rate overtime
sortedDelay = SortedRateMap(delay_rates_smooth,delay_rates_smooth,0);
del_Smooth  = conv(sortedDelay(80,:),gaussFilter);

% figure - plot a single neuron
figure('color','w')
colorR = abs(rand(3,1))';
area(del_Smooth(halfWidth:end-halfWidth),'FaceColor',colorR,'EdgeColor','k','LineWidth',2)
axis tight;

% plot 10 neurons from start to finish
figure('color','w')
n = 30;
figSize = ceil(size(delay_rates_smooth,1)/n);
vecSkip = 1:n:size(delay_rates_smooth,1); % vector used for skipping plotting all neurons
for i = 1:length(1:n:size(delay_rates_smooth,1))
    subplot([num2str(figSize),'1',num2str(i)])
    % smooth data
    del_Smooth  = conv(sortedDelay(vecSkip(i),:),gaussFilter);  
    % generate random color
    colorR      = abs(rand(3,1))';
    % plot data
    area(del_Smooth(halfWidth:end-halfWidth),'FaceColor',colorR,'EdgeColor','k','LineWidth',2);
    axis tight
    box off
end    
ylabel('Normalized Rate')
xlabel('Samples')
    
%% less sensible analyses still induce diagonal pattern
clear
load('rateMapStartEndData.mat')
start_rates_mat = start_rates_mat';
end_rates_mat   = end_rates_mat';
clearvars -except start_rates_mat end_rates_mat

% Create Gaussian filter for rate plot smoothing
srate       = size(start_rates_mat,2)/20; % samples/sec (total samples / total time)
samples     = ceil(srate*3); % >3 second filter
secPerSam   = samples/srate; % amount of time considered
windowWidth = int16(samples); % 10 is roughly a 3 second filter if your srate is .3 sec (divide the number of points sampled by the amount of time)
halfWidth   = windowWidth/2;
gaussFilter = gausswin(windowWidth);
gaussFilter = gaussFilter/sum(gaussFilter);

% smooth all data
for celli = 1:size(start_rates_mat,1)
    start_rates_smooth(celli,:)  = conv(start_rates_mat(celli,:),gaussFilter);
    end_rates_smooth(celli,:)    = conv(end_rates_mat(celli,:),gaussFilter);    
end

% remove unneeded data
start_rates_smooth = start_rates_smooth(:,halfWidth:end-halfWidth);
end_rates_smooth   = end_rates_smooth(:,halfWidth:end-halfWidth);

% use the function to sort it
x_label = linspace(0,20,size(start_rates_smooth,2));
jetOn   = 1; % jet color

figure('color','w')
subplot 221
    SortedRateMap(start_rates_smooth,start_rates_smooth,1,jetOn);
    title('start rates sorted by start rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 222
    SortedRateMap(start_rates_smooth,end_rates_smooth,1,jetOn);
    title('start rates sorted by end rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 223
    SortedRateMap(end_rates_smooth,start_rates_smooth,1,jetOn);
    title('end rates sorted by start rates')
    set(gca,'FontSize',8)    
    shading 'interp'    
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 224
    SortedRateMap(end_rates_smooth,end_rates_smooth,1,jetOn);
    title('end rates sorted by end rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');  

% make a plot that shows rate overtime
sortedStart = SortedRateMap(start_rates_smooth,start_rates_smooth,0);

% figure - plot a single neuron
figure('color','w')
colorR = abs(rand(3,1))';
area(sortedStart(halfWidth:end-halfWidth),'FaceColor',colorR,'EdgeColor','k','LineWidth',2)
axis tight;

% plot 10 neurons from start to finish
figure('color','w')
n = 30;
figSize = ceil(size(start_rates_smooth,1)/n);
vecSkip = 1:n:size(start_rates_smooth,1); % vector used for skipping plotting all neurons
for i = 1:length(1:n:size(start_rates_smooth,1))
    subplot([num2str(figSize),'1',num2str(i)])
    % smooth data
    del_Smooth  = conv(sortedStart(vecSkip(i),:),gaussFilter);  
    % generate random color
    colorR      = abs(rand(3,1))';
    % plot data
    area(del_Smooth(halfWidth:end-halfWidth),'FaceColor',colorR,'EdgeColor','k','LineWidth',2);
    axis tight
    box off
end    
ylabel('Normalized Rate')
xlabel('Samples')
    
%% create a random matrix
clear; clc; close all
%randMat1 = randn(187,63);
%randMat2 = randn(187,63);

randMat1 = randi(50,187,63);
randMat2 = randi(50,187,63);

[~, randMat1] = sort(rand(187,63),2);
[~, randMat2] = sort(rand(187,63),2);

% Create Gaussian filter for rate plot smoothing
srate       = size(randMat1,2)/20; % samples/sec (total samples / total time)
samples     = ceil(srate*3); % >3 second filter
secPerSam   = samples/srate; % amount of time considered
windowWidth = int16(samples); % 10 is roughly a 3 second filter if your srate is .3 sec (divide the number of points sampled by the amount of time)
halfWidth   = windowWidth/2;
gaussFilter = gausswin(windowWidth);
gaussFilter = gaussFilter/sum(gaussFilter);

% smooth all data
for celli = 1:size(randMat1,1)
    randMat1_smooth(celli,:)  = conv(randMat1(celli,:),gaussFilter);
    randMat2_smooth(celli,:)  = conv(randMat2(celli,:),gaussFilter);    
end

% remove unneeded data
randMat1_smooth = randMat1_smooth(:,halfWidth:end-halfWidth);
randMat2_smooth = randMat2_smooth(:,halfWidth:end-halfWidth);

% use the function to sort it
x_label = linspace(0,20,size(randMat2_smooth,2));
jetOn   = 1; % jet color

figure('color','w')
subplot 221
    SortedRateMap(randMat1_smooth,randMat1_smooth,1,jetOn);
    %title('rand1 rates sorted by rand1 rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 222
    SortedRateMap(randMat1_smooth,randMat2_smooth,1,jetOn);
    %title('rand1 rates sorted by rand2 rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 223
    SortedRateMap(randMat2_smooth,randMat1_smooth,1,jetOn);
    %title('rand2 rates sorted by rand1 rates')
    set(gca,'FontSize',8)    
    shading 'interp'    
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 224
    SortedRateMap(randMat2_smooth,randMat2_smooth,1,jetOn);
    %title('rand2 rates sorted by rand2 rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');  

% make a plot that shows rate overtime
sortedRand = SortedRateMap(randMat1_smooth,randMat1_smooth,0);

% figure - plot a single neuron
figure('color','w')
colorR = abs(rand(3,1))';
area(sortedRand(halfWidth:end-halfWidth),'FaceColor',colorR,'EdgeColor','k','LineWidth',2)
axis tight;

% plot 10 neurons from start to finish
figure('color','w')
n = 30;
figSize = ceil(size(start_rates_smooth,1)/n);
vecSkip = 1:n:size(start_rates_smooth,1); % vector used for skipping plotting all neurons
for i = 1:length(1:n:size(start_rates_smooth,1))
    subplot([num2str(figSize),'1',num2str(i)])
    % smooth data
    del_Smooth  = conv(sortedStart(vecSkip(i),:),gaussFilter);  
    % generate random color
    colorR      = abs(rand(3,1))';
    % plot data
    area(del_Smooth(halfWidth:end-halfWidth),'FaceColor',colorR,'EdgeColor','k','LineWidth',2);
    axis tight
    box off
end    
ylabel('Normalized Rate')
xlabel('Samples')