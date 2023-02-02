%% week 8 code - Granger Causality using a state-space method
clear; clc; close all

%% Loading data and defining some variables
load('data_LFP.mat')
load('Int_file.mat')

% remember to addpath to chronux toolbox to access chronux functions!
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');

%% get LFP across trials
% get lfp across trials for lfp1 and lfp2
numTrials = size(Int,1); % what is the size(Int,2)? Why is this better than using length(Int) or numel(Int)?
for triali = 1:numTrials
    
    % use logical indexing to get data (can also use find function) - this
    % should be faster
    lfp1Trials{triali} = lfp1(TimestampsLFP > Int(triali,1) & TimestampsLFP < Int(triali,5));
    lfp2Trials{triali} = lfp2(TimestampsLFP > Int(triali,1) & TimestampsLFP < Int(triali,5));
  
end

% concatenate data to make one long vector containing data from the time of
% interest
signalx      = horzcat(lfp1Trials{:});
signaly      = horzcat(lfp2Trials{:});

% detrend/denoise plot before and after
signalx_cle = DetrendDenoise(signalx,srate);
signaly_cle = DetrendDenoise(signaly,srate);

% check that we cleaned data
params.Fs = srate;
[powX_raw,frequencies] = mtspectrumc(signalx,params); % raw data
powX_cle = mtspectrumc(signalx_cle,params); % clean data
freqIdx1 = frequencies > 0 & frequencies < 100; % index of frequencies

figure('color','w'); hold on;
plot(frequencies(freqIdx1),log10(powX_raw(freqIdx1)),'r');
plot(frequencies(freqIdx1),log10(powX_cle(freqIdx1)),'b');

% down-sample data
clear signalx_down signaly_down
target_sample = 125; % hz
div           = find_downsample_rate(srate,target_sample); % divisor
signalx_down  = signalx_cle(1:div:end); % use divisor to downsample data
signaly_down  = signaly_cle(1:div:end);

% check data
params2.Fs = target_sample;
[powX_down,frexDown] = mtspectrumc(signalx_down,params2);
freqIdx2 = find(frexDown > 0 & frexDown < 50); % logical index

figure('color','w');
subplot 212
plot(frexDown(freqIdx2),log10(powX_down(freqIdx2)),'k')
axis tight
title(['Power spectrum of down-sampled data (',num2str(target_sample),'Hz)'])
xlabel('Frequency');
ylabel('Power (Log10)')
subplot 211
freqIdx3 = frequencies > 0 & frequencies < 50; % index of frequencies
plot(frequencies(freqIdx3),log10(powX_cle(freqIdx3)),'b');
title('Power spectrum with srate of 2000Hz')
axis tight

% addpaths
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\mvgc_v2.0')
startup_fun;

% estimate model order
clear data
data.signals(1,:) = signalx_down;
data.signals(2,:) = signaly_down;
data.srate        = target_sample;
[pf,ssmo]         = EstimateModelOrder_2(data);

% granger state space function - error is because data is so long. Should
% do this trial-by-trial
clear fx2y fy2x freqs
[fx2y,fy2x,freqs] = StateSpaceGranger(data,ssmo,pf); 

% generate figure
frexIdx4 = (freqs > 0 & freqs < 50);
figure('color','w'); hold on;
plot(freqs(frexIdx4),fx2y(frexIdx4),'k','LineWidth',2)
plot(freqs(frexIdx4),fy2x(frexIdx4),'m','LineWidth',2)
legend('does x predict y better than y predicts itself?','does y predict x better than x predicts itself?')
ylabel('Granger Causal Estimates')
xlabel('Frequency (Hz)')

% lead index
LI = fx2y(frexIdx4)./(fx2y(frexIdx4)+fy2x(frexIdx4));
figure('color','w'); hold on;
plot(freqs(frexIdx4),LI,'b','LineWidth',2)
ylabel('Lead Index')
xlabel('Frequency (Hz)')
xlimits = xlim;
l1 = line(xlimits,[0.5 0.5]);
l1.LineStyle = '--';
l1.LineWidth = 1;
l1.Color = 'r';
legend('below .5 -> x leads y | above .5 -> y leads x','Neither leads')





