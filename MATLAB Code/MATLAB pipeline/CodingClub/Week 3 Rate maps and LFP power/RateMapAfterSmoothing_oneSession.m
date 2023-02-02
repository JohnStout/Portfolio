%% Firing rate maps - how to make? How to interpret?
clear; clc; close all
datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18';

% define number of bins
nBins = 64; % was 21

% define and load some variables
cd(datafolder);  
load (strcat(datafolder,'\Int_file.mat')); 
load(strcat(datafolder, '\VT1.mat'));
cd(Datafolders);
folder_names = dir;
cd(datafolder);
clusters   = dir('TT*.txt');
TimeStamps = TimeStamps_VT;

% correct tracking errors
[ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);
    
% Create index of sample and choice trials
sample_trials = (1:2:size(Int,1));
choice_trials = (2:2:size(Int,1));     

%% normalized euclidean distance

% trying random trial data
sampleL = Int(sample_trials,:);
sampleL = Int(Int(:,3)==1,:);

% get position data
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Behavior')
clear X Y TS
for triali = 1:length(sampleL)
    X{triali}  = ExtractedX(TimeStamps_VT > sampleL(triali,1) & TimeStamps_VT < sampleL(triali,8));
    Y{triali}  = ExtractedY(TimeStamps_VT > sampleL(triali,1) & TimeStamps_VT < sampleL(triali,8));
    TS{triali} = TimeStamps_VT(TimeStamps_VT > sampleL(triali,1) & TimeStamps_VT < sampleL(triali,8));
    % calculate normalized position
    linDist{triali} = linearPosition(X{triali},Y{triali},TS{triali});
end

figure('color','w'); hold on;
for triali = 1:length(sampleL)
    plot(X{triali},Y{triali});
end

%% what if I normalize the x and y data to bw 0 and 1 first?
Xnorm = normalize(ExtractedX,'range');
Ynorm = normalize(ExtractedY,'range');

figure('color','w');
plot(Xnorm,Ynorm)

clear X Y TS
for triali = 1:length(sampleL)
    X{triali}  = Xnorm(TimeStamps_VT > sampleL(triali,1) & TimeStamps_VT < sampleL(triali,8));
    Y{triali}  = Ynorm(TimeStamps_VT > sampleL(triali,1) & TimeStamps_VT < sampleL(triali,8));
    TS{triali} = TimeStamps_VT(TimeStamps_VT > sampleL(triali,1) & TimeStamps_VT < sampleL(triali,8));
end    
% temporal down-sample


    % calculate normalized position
    linDist{triali} = linearPosition(X{triali},Y{triali},TS{triali});


figure('color','w'); hold on;
for triali = 1:length(sampleL)
    plot(X{triali},Y{triali});
end

figure('color','w'); hold on;
for triali = 1:length(linDist)
    plot(linDist{triali})
end


%% firing rates
% initialize a variable
firingrate_pop   = cell([1 nBins]);

% get rates
for ci=1:length(clusters)
    cd(datafolder);
    spikeTimes = textread(clusters(ci).name);
    cluster    = clusters(ci).name(1:end-4);

    % define a matrix used to store fr data
    firingrate_array = cell([1 nBins]);        

    for triali = 1:length(sample_trials)
        % create variables that will be used to make bins
        start_time = []; end_time = [];            
        start_time = TimeStamps_VT(1);            
        end_time   = TimeStamps_VT(1)+(0*1e6);      

        % define a matrix used to store fr data
        firingrate_array = cell([1 nBins]);

        % bins that contain evenly spaced timing values from delay
        binned_time = linspace(start_time,end_time,nBins);        

            for timei = 1:length(binned_time)-1

                % isolate spikes from multiple time points     
                spk_temp{(timei)} = find(spikeTimes>binned_time(timei) ...
                    & spikeTimes<=binned_time(timei+1));

                % find total number of spikes
                numspikes{(timei)} = length(spk_temp{(timei)});

                % find how much time
                time_temp{(timei)} = (binned_time(timei+1) - ...
                    binned_time(timei))/1e6;

                % calculate firing rate
                fr_new{(timei)} = numspikes{(timei)}/time_temp{(timei)};

            end

            firing_rate = cell2mat(fr_new)';
            clear fr_new time_temp numspikes spk_temp

        % store data
        start_rates{ci} = firing_rate;
        clear firing_rate
    end
end

for ci=1:length(clusters)
    cd(datafolder);
    spikeTimes = textread(clusters(ci).name);
    cluster    = clusters(ci).name(1:end-4);

    % define a matrix used to store fr data
    firingrate_array = cell([1 nBins]);        

    % take 20 random 20 second intervals?
    % just take the first 20 seconds and compare it to the second 20
    % seconds. Don't even average the firing rates

    firingrate_array = cell([1 nBins]);

    % create variables that will be used to make bins
    start_time = []; end_time = [];            
    start_time = TimeStamps_VT(end)-(20*1e6);            
    end_time   = TimeStamps_VT(end);      

    % define a matrix used to store fr data
    firingrate_array = cell([1 nBins]);

    % bins that contain evenly spaced timing values from delay
    binned_time = linspace(start_time,end_time,nBins);        

        for timei = 1:length(binned_time)-1;

            % isolate spikes from multiple time points     
            spk_temp{(timei)} = find(spikeTimes>binned_time(timei) ...
                & spikeTimes<=binned_time(timei+1));

            % find total number of spikes
            numspikes{(timei)} = length(spk_temp{(timei)});

            % find how much time
            time_temp{(timei)} = (binned_time(timei+1) - ...
                binned_time(timei))/1e6;

            % calculate firing rate
            fr_new{(timei)} = numspikes{(timei)}/time_temp{(timei)};

        end

        firing_rate = cell2mat(fr_new)';
        clear fr_new time_temp numspikes spk_temp

    % store data
    end_rates{nn-2}{ci} = firing_rate;
    clear firing_rate

end


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