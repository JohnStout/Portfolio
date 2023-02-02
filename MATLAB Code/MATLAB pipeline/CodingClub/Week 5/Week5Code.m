%% coherence 
% this code will be focused on common issues faced when analyzing lfp phase
% coherence

clear; clc; close all
load('data_LFP.mat')
load('Int_file.mat')

% remember to addpath to chronux toolbox to access chronux functions!
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');

%---- quick and easy coherence analysis ----%

% define chronux parameters
params.tapers     = [2 3];      % multi tapers (time band-width prod, number)
params.trialave   = 0;          % average across trials
params.err        = 0;          % this is for errorbars - dont use unless you're using chronux average and lookng within one trial
params.pad        = 0;          % zero-padding
params.fpass      = [0 100];    % frequency bandpass
params.movingwin  = [0.5 0.01]; % in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
params.Fs         = srate;      % sampling rate

% get lfp across trials for lfp1 and lfp2
numTrials = size(Int,1); % what is the size(Int,2)? Why is this better than using length(Int) or numel(Int)?
for triali = 1:numTrials
    % get index of timestamps between stem entry and t-entry for all trials
    lfp1idx{triali} = find(TimestampsLFP > Int(triali,1) & TimestampsLFP < Int(triali,5));
    lfp2idx{triali} = find(TimestampsLFP > Int(triali,1) & TimestampsLFP < Int(triali,5));
    % use that index to grab lfp
    lfp1Trials{triali} = lfp1(lfp1idx{triali});
    lfp2Trials{triali} = lfp2(lfp2idx{triali});
    
    %{
        % detrend and denoise dataset - This MUST be done on data, however to
        % save processing time, I did not include it
        lfp1Clean{triali} = DetrendDenoise(lfp1Trials{triali},srate);
        lfp2Clean{triali} = DetrendDenoise(lfp2Trials{triali},srate);
    %}
end

% generate a coherence X frequency graph for 1 trial
clear coh12 freqs
for triali = 1:numTrials
    [coh12{triali},~,~,~,~,freqs{triali}]=coherencyc(lfp1Trials{triali},lfp2Trials{triali},params);
end

% -- important point -- %
% it makes sense that each trial will have differing amounts of time spent
% on the stem. However, this creates a slight problem for us: how can we
% create a coherence X frequency plot when different trials have different
% numbers of coherence and frequency estimates?

% --> the solution is conceptually easy (down-sample your data), but can be tricky to implement.

% notice how trials with more frequency samples share similar frequencies.
% The only difference is the trial with more frequencies has a finer
% sampling rate. But to notice this ,we must open up the freqs variable and
% look at the data

% -- down-sample frequencies (down-sampling is a very useful tool!) -- %

% find all lengths of frequency samples
freqLens = cellfun(@length,freqs);
% find the frequency length that is smallest in size
freqMin = min(freqLens);
% get data from one of the minimum frequency trials
minTrial = find(freqLens == freqMin);
minTrial = minTrial(1); % select the first one - we need any example
freqsMinTrial = freqs{minTrial};
% find cases where the minimum frequency is not met, then 'down-sample' the
% data
trials2change = find(freqLens ~= freqMin); % find trials that do not equal the minimum length

% make a for loop that only loops across the trials to downsample
for changei = trials2change
    % make an index to down-sample data - use dsearchn
    downSampleIdx{changei} = dsearchn(freqs{changei}',freqsMinTrial');
    % extract relevant data using index
    freqs{changei} = freqs{changei}(downSampleIdx{changei});
    coh12{changei} = coh12{changei}(downSampleIdx{changei});
end

% down check that all of your cell arrays are the same size - this is
% important so that we can calculate an average
checkSize = cellfun(@length,coh12);
checkSize = unique(checkSize); 
if numel(checkSize) == 1 % (ie there's only one size frequency resolution)
    disp('Data down-sampled correctly')
else
    disp('Data not down-sampled correctly')
end

% average and sem
cohMat12 = horzcat(coh12{:}); % notice its now a matrix
cohMat12 = cohMat12';         % invert so that trials are rows (preference - doesn't really matter)

cohAvg12 = mean(cohMat12);
cohSEM12 = std(cohMat12)./(sqrt(numTrials));

% make figure
x_label = freqs{1}; % since all frequency resolutions are equal, select one for our x-axis
figure('color','w')
subplot 211
    shadedErrorBar(x_label,cohAvg12,cohSEM12,'b',1)
    xlabel('Frequency (Hz)')
    ylabel('Coherence')
    box off
subplot 212
    shadedErrorBar(x_label,cohAvg12,cohSEM12,'b',1)
    xlabel('Frequency (Hz)')
    ylabel('Coherence')
    box off
    xlim([0 50])
    
% create a bar graph between delta and theta
thetaIdx = find(freqs{1} > 4 & freqs{1} < 12);
deltaIdx = find(freqs{1} > 1 & freqs{1} < 3);

thetaCoh = cohMat12(:,thetaIdx);
deltaCoh = cohMat12(:,deltaIdx);

% average across frequencies
thetaAvg1 = mean(thetaCoh,2);
deltaAvg1 = mean(deltaCoh,2);

% average across trials
thetaAvg2 = mean(thetaAvg1);
deltaAvg2 = mean(deltaAvg1);

thetaSEM2 = std(thetaAvg1)/(sqrt(numTrials));
deltaSEM2 = std(deltaAvg1)/(sqrt(numTrials));

% plot bar graphs
figure('color','w'); hold on;
bar(1,deltaAvg2,'b');
errorbar(1,deltaAvg2,deltaSEM2,'b','LineWidth',2);
bar(2,thetaAvg2,'r');
errorbar(2,thetaAvg2,thetaSEM2,'r','LineWidth',2);
box off
ylabel('Coherence')
ax = gca;
ax.XTick = [1;2];
ax.XTickLabel = [{'Delta'},{'Theta'}];

%% now for cohero-grams
clearvars -except params Int lfp1 lfp2 srate TimestampsLFP

% get lfp while controlling for time ***
numTrials = size(Int,1); % what is the size(Int,2)? Why is this better than using length(Int) or numel(Int)?
for triali = 1:numTrials
    % get index of timestamps between stem entry and t-entry for all trials
    lfp1Trials{triali} = lfp1(find(TimestampsLFP > (Int(triali,5)-2*1e6) & TimestampsLFP < Int(triali,5)));
    lfp2Trials{triali} = lfp2(find(TimestampsLFP > (Int(triali,5)-2*1e6) & TimestampsLFP < Int(triali,5)));
    
    %{
        % detrend and denoise dataset - This MUST be done on data, however to
        % save processing time, I did not include it
        lfp1Clean{triali} = DetrendDenoise(lfp1Trials{triali},srate);
        lfp2Clean{triali} = DetrendDenoise(lfp2Trials{triali},srate);
    %}
end

% generate a frequency X time X coherence
clear coh12 freqs lfp1Clean lfp2Clean
for triali = 1:numTrials
    
    % fit significant sine waves to data - a cleaning approach that
    % corrects for changes in srate
    lfp1Clean{triali} = rmlinesmovingwinc(lfp1Trials{triali},params.movingwin,10,params,'n');
    lfp2Clean{triali} = rmlinesmovingwinc(lfp2Trials{triali},params.movingwin,10,params,'n');

    % coherogram
    [coh12{triali},~,~,~,~,times{triali},freqs{triali}]=cohgramc(lfp1Clean{triali},lfp2Clean{triali},params.movingwin,params);
end

% now make into a 3D matrix and average
coh12Mat = cat(3,coh12{:});
coh12Avg = mean(coh12Mat,3)';
coh12sem = std(coh12Mat,[],3)./(sqrt(numTrials));

% make figure
x_label = times{1}; % time
y_label = freqs{1}; % frequency

figure('color',[1 1 1])
pcolor(x_label,y_label,coh12Avg)
colormap(jet)
c = colorbar;   
%caxis([0.0548 0.0563])    
shading 'interp'
ylabel('frequency')
xlabel('time') 
ylabel(c,'coherence')
set(gca,'FontSize',10)

% skip delta and cut off at 50Hz
freqIdx = find(freqs{1} > 4 & freqs{1} < 50);

figure('color',[1 1 1])
pcolor(x_label,y_label(freqIdx),coh12Avg(freqIdx,:))
colormap(jet)
c = colorbar;   
%caxis([0.0548 0.0563])    
shading 'interp'
ylabel('frequency')
xlabel('time') 
ylabel(c,'coherence')
set(gca,'FontSize',10)

% extract theta and plot across time
freqIdx = find(freqs{1} > 4 & freqs{1} < 12);

% extract theta across all trials, calculate average and sem
thetaMat = mean(coh12Mat(:,freqIdx,:),2);
thetaAvg = mean(thetaMat,3);
thetaSEM = std(thetaMat,[],3)./(sqrt(numTrials));

figure('color','w')
shadedErrorBar(x_label,thetaAvg,thetaSEM,'b',1)
ylabel('Averaged Theta Coherence')
xlabel('Time (sec)')
box off
axis tight


