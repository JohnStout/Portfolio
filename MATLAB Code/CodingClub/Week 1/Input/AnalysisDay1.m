%% analysis club day 1

%% grabbing position data
% load vt
load('VT1.mat')

% load int file
load('Int_file.mat')

% recreate in another language
figure('color','w')
plot(ExtractedX,ExtractedY)

% srate for vt1 30 samples/sec
sample2get = 10*30; % first 10 seconds

% get 10 seconds of data
Xfirst10 = ExtractedX(1:sample2get);
Yfirst10 = ExtractedY(1:sample2get);
Tfirst10 = TimeStamps(1:sample2get);

figure(); plot(Xfirst10,Yfirst10);

% get data from stem entry to t-exit
trials = size(Int,1);

% get timestamps and position data for all trials
clear Times X Y
for i = 1:trials
    idx      = find(TimeStamps > Int(i,1) & TimeStamps < Int(i,6));
    Times{i} = TimeStamps(idx);
    X{i}     = ExtractedX(idx);
    Y{i}     = ExtractedY(idx);
end
figure(); plot(X{1},Y{1});

% plot data trial by trial
figure(); hold on;
for i = 1:trials
    plot(X{i},Y{i})
end

%% STEP 1: get lfp data

clear; clc;

% load video tracking data
VTdata = load('VT1.mat');

% load int
load('Int_file.mat')

% load csc
CSCdata = load('CSC14');

% concatenate samples into one vector
LFP = CSCdata.Samples(:);
srate = CSCdata.SampleFrequencies(1); % srate = samples/sec

% interpolate timestamps
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
TimestampsLFP = interp_TS_to_CSC_length_non_linspaced(CSCdata.Timestamps,LFP);     

% get data from stem entry to t-exit
% Int(,1) is stem entry Int(,6) is t-junction exit
trials = size(Int,1);
clear Times X Y
for i = 1:trials
    idx             = find(TimestampsLFP > Int(i,1) & TimestampsLFP < Int(i,6));
    Times_trials{i} = TimestampsLFP(idx);
    LFP_trials{i}   = LFP(idx);
end

figure('color','w');
plot(LFP_trials{2}); % curly bracket bc cell array

%% step 2: do something with the data - maybe power and clean it
LFP_concatenated = horzcat(LFP_trials{:}); % concatenating

% define some parameters
params.tapers     = [5 9];
params.trialave   = 0;
params.err        = [2 .05];
params.pad        = 0;
params.fpass      = [0 100]; 
params.movingwin  = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
params.Fs         = srate;

% run power to visualize data for noise
[pow1,frex1] = mtspectrumc(LFP_concatenated,params);

figure('color','w'); 
plot(frex1,log10(pow1),'k')
ylabel('power')
xlabel('Frequency')

% remove 60hz signal
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Basic Functions');
LFP_cleaned = DetrendDenoise(LFP_concatenated,params.Fs);

% run power to visualize data for noise
[pow2,frex2] = mtspectrumc(LFP_cleaned,params);

figure('color','w')
plot(frex2,log10(pow2))
xlabel('power')
ylabel('frequency')



































