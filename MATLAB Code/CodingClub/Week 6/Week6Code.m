%% Entrainment 
clear; clc; close all

%% Loading data and defining some variables
clear; clc; close all
load('data_LFP.mat')
load('Int_file.mat')

% load clusters (neurons) and spikeTimes
clusters = dir('TT*.txt');
ci       = 1; % cluster number
spkTimes = textread(clusters(ci).name);

% remember to addpath to chronux toolbox to access chronux functions!
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');

% define a phase bandpass filter
phase_bandpass = [4 12]; % theta

%% get LFP across trials
% get lfp across trials for lfp1 and lfp2
numTrials = size(Int,1); % what is the size(Int,2)? Why is this better than using length(Int) or numel(Int)?
for triali = 1:numTrials
    % get index of timestamps between stem entry and t-entry for all trials
    lfpIdx{triali} = find(TimestampsLFP > Int(triali,1) & TimestampsLFP < Int(triali,5));
    
    % use that index to grab lfp and timestamps
    lfp1Trials{triali} = lfp1(lfpIdx{triali});
    lfp2Trials{triali} = lfp2(lfpIdx{triali});
    eegTimes{triali}   = TimestampsLFP(lfpIdx{triali});
    
    % get spikes
    spkCell{triali} = spkTimes((find(spkTimes>Int(triali,1) & spkTimes<Int(triali,5)))');     
end

% concatenate data to make one long vector containing data from the time of
% interest
spikes       = vertcat(spkCell{:});
LFP          = (horzcat(lfp1Trials{:}))';
signalTimes  = (horzcat(eegTimes{:}))';
clearvars -except spikes LFP signalTimes phase_bandpass srate clusters

% Filter phase signal
[signal_filtered] = skaggs_filter_var(LFP,phase_bandpass(:,1),phase_bandpass(:,2),srate);
figure('color','w'); plot(LFP(1:8000),'k'); hold on; plot(signal_filtered(1:8000),'r','LineWidth',1.5);

% downsample data - Jadhav et al., 2016  
target_downSample = 125;
div = find_downsample_rate(srate,target_downSample);

% provide new srate
srateNew = length(1:div:srate);

% downsample data after filtering example - https://dsp.stackexchange.com/questions/36399/which-order-to-perform-downsampling-and-filtering
times_down = signalTimes(1:div:end);
lfpOG_down = LFP(1:div:end);
lfp_down   = signal_filtered(1:div:end);

% plot stuff to visualize - this is how we check our work
figure('color','w');
subplot 211;  hold on;
    plot(LFP(1:8000),'k');
    plot(signal_filtered(1:8000),'r','LineWidth',1);
subplot 212; hold on;
    plot(lfpOG_down(1:500),'k');
    plot(lfp_down(1:500),'r','LineWidth',1);

% Extract phase information from filtered signal
Phase        = phase_freq_detect(lfp_down, times_down, phase_bandpass(:,1), phase_bandpass(:,2), srateNew); 
PhaseRadians = Phase*(pi/180); 

figure('color','w'); 
subplot 211;
plot(lfp_down(1:500),'k','LineWidth',2)
ylabel('Voltage')
subplot 212;
plot(Phase(1:500),'m','LineWidth',2)
ylabel('Theta Phase')
xlabel('Samples (125 Samples/1 Sec)')

figure('color','w')
subplot 211
    plot(lfp_down(12:27),'k','LineWidth',2);
    ylabel('Voltage')
    title('1 theta cycle')
    box off
subplot 212
    plot(Phase(12:27),'m','LineWidth',2);
    ylabel('Theta Phase (0:360)')
    box off

% Assign a phase value to each spike
numSpikes = length(spikes);
for j = 1:numSpikes
    spk_ind          = dsearchn(times_down,spikes(j)');
    spkPhaseRad(j,:) = PhaseRadians(spk_ind,:);
    spkPhaseDeg(j,:) = Phase(spk_ind,:);  
    
    spkIndex(j) = spk_ind;
end

%-- purely plotting purposes --%
NanVec = NaN([1 length(lfp_down)]);
NanVec(spkIndex)=lfp_down(spkIndex)'; % fill in elements with 1 if there was a spike
%NanVec(spkIndex)=1;

figure('color','w');
subplot 211
    plot(lfp_down(1:125),'k'); hold on;
    plot(NanVec(1:125),'r.','MarkerSize',20);
    ylabel('Filtered Theta')
    box off
    legend('Theta','Spikes')
    legend boxoff    
    
% plot spikes on phase
NanVec = NaN([1 length(Phase)]);
NanVec(spkIndex)=Phase(spkIndex)'; % fill in elements with 1 if there was a spike
subplot 212
    plot(Phase(1:125),'k'); hold on;
    plot(NanVec(1:125),'r.','MarkerSize',20);
    ylabel('Filtered Theta Phase')
    box off

% -- back to entrainment stuff -- %

% Get rid of spikes that could not be assigned a phase value due to low
% amplitude oscillations
spkPhaseRad(isnan(spkPhaseRad)) = [];
spkPhaseDeg(isnan(spkPhaseDeg)) = [];
  
% get the number of included spikes
includedSpikeCount = length(spkPhaseRad);

% Create sub-sampled MRL value from bootstrapped spike-phase distribution
permnum = 1000;
for i = 1:permnum  
    random_spikes = randsample(spkPhaseRad,50);
    mrl_sub(i)    = circ_r(random_spikes);      
end

% Calculate MRL, Rayleigh's z-statistic, and p-value based on null
% hypothesis of uniform spike-phase distribution
mrl_subbed  = mean(mrl_sub,2);
mrl         = circ_r(spkPhaseRad); 
[p, z]      = circ_rtest(spkPhaseRad); 
[n, xout]   = hist(spkPhaseDeg,[0:30:360]); 

figure('color','w')
subplot(121)
circ_plot(spkPhaseRad,'hist','k',18,false,true,'lineWidth',4,'color','r');
subplot(122)
bar(xout,n)
xlim ([0 360])
xlabel ('Phase')
ylabel ('Spike Count')
ax = gca;
ax.XTickLabelRotation = 45;
box off

% create a fake dataset
xmin=210;
xmax=270;
n=1273;
PhaseFake=xmin+rand(1,n)*(xmax-xmin);
RadFake=((xmin*(pi/180))+rand(1,n))*((xmax*(pi/180))-(xmin*(pi/180)));
[n, xout] = hist(PhaseFake,[0:30:360]); 

figure('color','w')
subplot(121)
circ_plot(RadFake','hist','k',18,false,true,'lineWidth',4,'color','r');
subplot(122)
bar(xout,n)
xlim ([0 360])
xlabel ('Phase')
ylabel ('Spike Count')
ax = gca;
ax.XTickLabelRotation = 45;
box off
title('Fake Data - demonstrating MRL')