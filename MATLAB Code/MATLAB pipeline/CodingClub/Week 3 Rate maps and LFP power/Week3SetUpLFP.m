% this will only work if you have network connection

clear; clc

cd('X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18')

% load lfp data
LFP1 = load('HPC.mat');
LFP2 = load('mPFC.mat');
LFP3 = load('Re.mat');

% load int
load('Int_file.mat')

% sampling rate
srate = LFP1.SampleFrequencies(1); % srate = samples/sec

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');
TimestampsLFP = interp_TS_to_CSC_length_non_linspaced(LFP1.Timestamps,LFP1.Samples);     

lfp1 = LFP1.Samples(:)';
lfp2 = LFP2.Samples(:)';
lfp3 = LFP3.Samples(:)';

clearvars -except lfp1 lfp2 lfp3 TimestampsLFP srate Int

clear data1 data2 data3
numTrials = size(Int,1); % number of trials
for triali = 1:numTrials
    % get data across all trials for stem running
    data1{triali} = lfp1(find(TimestampsLFP > Int(triali,1) & TimestampsLFP < Int(triali,5)));
    data2{triali} = lfp2(find(TimestampsLFP > Int(triali,1) & TimestampsLFP < Int(triali,5)));
    data3{triali} = lfp3(find(TimestampsLFP > Int(triali,1) & TimestampsLFP < Int(triali,5)));
end
% concatenate data
data1 = horzcat(data1{:});
data2 = horzcat(data2{:});
data3 = horzcat(data3{:});
 
clearvars -except data1 data2 data3 params srate
