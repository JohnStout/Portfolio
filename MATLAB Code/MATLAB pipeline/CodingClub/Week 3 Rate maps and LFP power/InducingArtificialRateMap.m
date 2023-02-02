%% Firing rate maps - how to make? How to interpret?
clear; clc; close all

% load in sample data provided
load('rateMapData2.mat')

% use the function to sort it
x_label = linspace(0,20,size(delay_rates_mat,2));

figure('color','w')
subplot 221
    SortedRateMap(delay_rates_mat,delay_rates_mat,1)
    title('delay rates sorted by delay rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 222
    SortedRateMap(delay_rates_mat,iti_rates_mat,1)
    title('delay rates sorted by iti rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 223
    SortedRateMap(iti_rates_mat,delay_rates_mat,1)
    title('iti rates sorted by delay rates')
    set(gca,'FontSize',8)    
    shading 'interp'    
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 224
    SortedRateMap(iti_rates_mat,iti_rates_mat,1)
    title('iti rates sorted by iti rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');       

% make a plot that shows rate overtime
sortedDelay = SortedRateMap(delay_rates_mat,delay_rates_mat,0);

% Create Gaussian filter for rate plot smoothing
srate       = size(delay_rates_mat,2)/20; % samples/sec (total samples / total time)
samples     = ceil(srate*3); % >3 second filter
secPerSam   = samples/srate; % amount of time considered
windowWidth = int16(samples); % 10 is roughly a 3 second filter if your srate is .3 sec (divide the number of points sampled by the amount of time)
halfWidth   = windowWidth/2;
gaussFilter = gausswin(windowWidth);
gaussFilter = gaussFilter/sum(gaussFilter);
del_Smooth  = conv(sortedDelay(80,:),gaussFilter);

% figure
figure('color','w')
colorR = abs(rand(3,1))';
area(del_Smooth(halfWidth:end-halfWidth),'FaceColor',colorR,'EdgeColor','k','LineWidth',2)
axis tight;

% plot 10 neurons from start to finish
figure('color','w')
n = 30;
figSize = ceil(size(delay_rates_mat,1)/n);
vecSkip = 1:n:size(delay_rates_mat,1); % vector used for skipping plotting all neurons
for i = 1:length(1:n:size(delay_rates_mat,1))
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

% smooth data with gaussian
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Toolboxes\signal\signal')

gauss_width = (32000)*32; % 32ms * samples per ms = 64 samples = 32 ms of data
alpha       = 4; % std = (N)/(alpha*2) -> https://www.mathworks.com/help/signal/ref/gausswin.html
w           = gausswin(gauss_width,alpha);   

% convolve the gaussian kernel with lfp data
lfp_smoothed = conv(lfp_hilbert,w,'same');

figure('color','w')
plot(smooth(sortedDelay(:,50)),'k')
    
%% less sensible analyses still induce diagonal pattern
clear
load('rateMapStartEndData.mat')
start_rates_mat = start_rates_mat';
end_rates_mat   = end_rates_mat';
clearvars -except start_rates_mat end_rates_mat

% use the function to sort it
x_label = linspace(0,20,size(start_rates_mat,2));

figure('color','w')
subplot 221
    SortedRateMap(start_rates_mat,start_rates_mat,1)
    title('start rates sorted by start rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds after session onset');
    
subplot 222
    SortedRateMap(start_rates_mat,end_rates_mat,1)
    title('start rates sorted by end rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds after session onset');
    
subplot 224
    SortedRateMap(end_rates_mat,end_rates_mat,1)
    title('end rates sorted by end rates')
    set(gca,'FontSize',8)    
    shading 'interp'    
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from session end');
    
subplot 223
    SortedRateMap(end_rates_mat,start_rates_mat,1)
    title('end rates sorted by start rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from session end');       
    
%% create a random matrix
%randMat1 = randn(187,63);
%randMat2 = randn(187,63);

randMat1 = randi(50,187,63);
randMat2 = randi(50,187,63);

[~, randMat1] = sort(rand(187,63),2);
[~, randMat2] = sort(rand(187,63),2);

figure('color','w')
subplot 221
    SortedRateMap(randMat1,randMat1,1)
    title('random data 1 sorted by itself')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('some random axis');
    
subplot 222
    SortedRateMap(randMat1,randMat2,1)
    title('random data 1 sorted by another random data 2')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('some random axis');
    
subplot 224
    SortedRateMap(randMat2,randMat2,1)
    title('random data 2 sorted by itself')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('some random axis');
    
subplot 223
    SortedRateMap(randMat2,randMat1,1)
    title('random data 2 sorted by another random data 1')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('some random axis');     













