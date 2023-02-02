%% recap on power
clear; clc
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous');

%% fourier transform
% manual fourier transform stuff and most the code below was taken from MxC
% ANTS chaps 10 and 11

% why do we care about frequencies?
% define a sampling rate
srate = 500;
 
% list some frequencies
frex = [ 3   10   5   15   35 ];

% list some random amplitudes... make sure there are 
% the same number of amplitudes as there are frequencies!
amplit = [ 5   15   10   5   7 ];

% phases... list some random numbers between -pi and pi
phases = [  pi/7  pi/8  pi  pi/2  -pi/4 ];

% define time...
time=-1:1/srate:1;

% now we loop through frequencies and create sine waves
sine_waves = zeros(length(frex),length(time)); % remember: always initialize!
for fi=1:length(frex)
    sine_waves(fi,:) = amplit(fi) * sin(2*pi*frex(fi).*time + phases(fi));
end

% now plot each wave separately
figure
for fi=1:length(frex)
    subplot(length(frex),1,fi)
    plot(sine_waves(fi,:),'linew',2)
    axis([ 0 length(time) -max(amplit) max(amplit) ])
end

% add together frequencies and we get our signal
figure
set(gcf,'Name','Sum of sine waves plus random noise.')
plot(sum(sine_waves+5*randn(size(sine_waves))))
axis([ 0 1020 -40 50 ]) % this sets the x-axis (first two numbers) and y-axis (last two numbers) limits
title('sum of sine waves plus white noise')

% ~~~~ when we collect data, we aren't given those frequencies, but instead 
% the summated signal in the time domain ~~~~ %

% --> we need to find those frequencies! <-- %

% taken from MxC ANTS chp 11
N       = 10;         % length of sequence
data    = randn(1,N); % random numbers
srate   = 200;        % sampling rate in Hz
nyquist = srate/2;    % Nyquist frequency -- the highest frequency you can measure in the data

% initialize Fourier output matrix
fourier = zeros(size(data)); 

% These are the actual frequencies in Hz that will be returned by the
% Fourier transform. The number of unique frequencies we can measure is
% exactly 1/2 of the number of data points in the time series (plus DC). 
frequencies = linspace(0,nyquist,N/2+1);
time = ((1:N)-1)/N;

% Fourier transform is dot-product between sine wave and data at each frequency
for fi=1:N
    sine_wave{fi} = exp(-1i*2*pi*(fi-1).*time);
    fourier(fi)   = sum(sine_wave{fi}.*data);
end
fourier=fourier/N;

figure
subplot(221)
plot(data,'-o')
set(gca,'xlim',[0 N+1])
title('Time domain representation of the data')

subplot(222)
plot3(frequencies,angle(fourier(1:N/2+1)),abs(fourier(1:N/2+1)).^2,'-o','linew',3)
grid on
xlabel('Frequency (Hz)')
ylabel('Phase')
zlabel('power')
title('3-D representation of the Fourier transform')
view([20 20])

subplot(223)
bar(frequencies,abs(fourier(1:N/2+1)).^2)
set(gca,'xlim',[-5 105])
xlabel('Frequency (Hz)')
ylabel('Power')
title('Power spectrum derived from discrete Fourier transform')

subplot(224)
bar(frequencies,angle(fourier(1:N/2+1)))
set(gca,'xlim',[-5 105])
xlabel('Frequency (Hz)')
ylabel('Phase angle')
set(gca,'ytick',-pi:pi/2:pi)
title('Phase spectrum derived from discrete Fourier transform')

% ~~~ how to use fft, extract power and phase quickly? ~~~ %
fft_result = fft(data);
fft_power  = abs(fft_result).^2;
fft_phase  = angle(fft_result);

figure('color','w')
subplot 211
    bar(fft_power);
    ylabel('Power')
subplot 212
    bar(fft_phase);
    ylabel('Phase (radians)')
    xlabel('Frequency')

img = imread('phase angle and power image.png');
figure('color','w')
image(img);
axis off

%% trial averaged power and calculating power
clear; clc;
load('data_LFP');
load('Int_file');

numTrials = size(Int,1);

% get lfp data from a 1 second epoch
for triali = 1:numTrials
    lfp1Trials{triali} = lfp1(find(TimestampsLFP > (Int(triali,5) - (1*1e6)) & TimestampsLFP < Int(triali,5)));
    lfp2Trials{triali} = lfp2(find(TimestampsLFP > (Int(triali,5) - (1*1e6)) & TimestampsLFP < Int(triali,5)));
end

% define low pass and high pass filters
lowPass  = 4;
highPass = 12;

% we have a filter to bandpass filter - it a third degree butterworth
% filter
signal_filtered = skaggs_filter_var(lfp1Trials{1}, lowPass, highPass , srate);

figure('color','w')
subplot 311
    plot(lfp1Trials{1},'b','LineWidth',1);
    hold on;
    plot(signal_filtered,'k','LineWidth',2)
    legend('raw signal',['filtered ',num2str(lowPass), ' to ',num2str(highPass),'Hz'])
    xlabel('Samples (aka time: 2000 samples per 1sec)')
    ylabel('Voltage')

% extract instantaneous phase and power using hilbert transform
lfp_hilbert = (hilbert(signal_filtered)); % hilbert transform
inst_power  = (abs(lfp_hilbert)).^2;      % instantaneous power
inst_phase  = angle(lfp_hilbert);         % instantaneous phase

% You can get these values and the hilbert output using hilbert_metrics.m
[phase360,~,~] = hilbert_metrics(signal_filtered);

% plot phase and power
subplot 312
    plot(phase360,'r','LineWidth',2)
    ylabel([num2str(lowPass), '-',num2str(highPass),'Hz',' Phase (rad)'])
subplot 313
    plot(inst_power,'y','LineWidth',2)
    ylabel([num2str(lowPass), '-',num2str(highPass),'Hz',' Power'])

% ~~~~ can get trial averaged power in 3 ways with chronux ~~~~ %

    % define parameters
    params.tapers     = [2 3];      % multi tapers (time band-width prod, number)
    params.trialave   = 0;          % average across trials
    params.err        = 0;          % this is for errorbars
    params.pad        = 0;          % zero-padding
    params.fpass      = [0 100];    % frequency bandpass
    params.movingwin  = [0.5 0.01]; % in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
    params.Fs         = srate;      % sampling rate

    % #1 - calculate power separately across trials - preferred**
        params.tapers = [2 3]; % watch what happens when we change this to [5 9] on a small segment of time
        for triali = 1:numTrials
            [pow1{triali},f{triali}] = mtspectrumc(lfp1Trials{triali},params);
        end
        
        % now that we know there is only one size of frequencies across all
        % power estimates, we can concatenate and average
        pow1Mat = horzcat(pow1{:}); % (frequencies, trial)
        pow1Mat = pow1Mat';         % re-orient so trials are rows, freqs are columns
        pow1Log = log10(pow1Mat);
        
        % average and sem
        pow1Avg = mean(pow1Log);
        pow1SEM = std(pow1Log)./(sqrt(numTrials));
        
        % make plot
        figure('color','w')
        shadedErrorBar(f{1},pow1Avg,pow1SEM,[],1)
        ylabel('Power - 60Hz noise not corrected!')
        xlabel('Frequency')
        
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  

    % #2 - calculate power on one long concatenated signal
        signalCat = horzcat(lfp1Trials{:});
        [pow2,freq] = mtspectrumc(signalCat,params);
        pow2log = log10(pow2);
        
        figure('color','w')
        plot(freq,pow2log,'k')
        ylabel('Power - 60Hz noise not corrected!')
        xlabel('Frequency')
        
    % #3 - calculate power and average across all trials within the function
    
        % notice how an error pops up when we try this - it's because we
        % have inconsistent sizes of arrays
        signalWide = vertcat(lfp1Trials{:});
        
        % get sizes
        lfpSizes    = cellfun(@length,lfp1Trials);
        uniqueSizes = unique(lfpSizes);

        % find cases where you have more than 2000 points (1 second)
        lfp2large = find(lfpSizes == uniqueSizes(2));
        
        % remove the first point in those cases where sample size was too
        % large - this may or may not be the best approach - a subjective
        % call
        for i = 1:length(lfp2large)
            lfp1Trials{lfp2large(i)}(1) = [];
        end
        
        % concatenate
        signalWide = vertcat(lfp1Trials{:});
        signalWide = signalWide';
        
        % power
        params.trialave = 1;
        params.err      = [2 .05];
        [pow3,freq3,Err] = mtspectrumc(signalWide,params);
        
        % log transform
        logPow3 = log10(pow3);
        figure(); 
        subplot 211
            plot(freq3,pow3)
            title('not log transformed')
        subplot 212
            plot(freq3,logPow3)
            title('log transformed')
            xlabel('Frequency')
            ylabel('Power')


