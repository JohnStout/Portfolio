%% matlab club day 3
% ~~~ OVERVIEW ~~~
% 1) cover power in depth
% 2) touch on firing rate maps (mostly out of fun from the last paper we
% covered) - mention this article https://www.nature.com/articles/s41598-019-52017-8.pdf

%% power analysis - what is power? How is it estimated?
clear; clc

% get data
load('data_LFP_week3')   

% define parameters
params.tapers     = [5 9];
params.trialave   = 0;
params.err        = [2 .05];
params.pad        = 0;
params.fpass      = [0 100]; 
params.movingwin  = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
params.Fs         = srate;

% ~~~ calculate power for data1 ~~~ %

% parameters
[tapers,pad,Fs,fpass,err,trialave,params] = getparams(params);

% re-orient data
data1 = change_row_to_column(data1);

% sample size
N = size(data1,1);

% number of values in the fast fourier transform
nfft = max(2^(nextpow2(N)+pad),N);

% get frequency based on your sampling rate
df = Fs/nfft;   % sampling frequency
f  = 0:df:Fs;   % all possible frequencies - notice there are 2000 possible frequencies
f  = f(1:nfft); % get all values to be included in the fourier transform

% get frequencies included
findx = find(f>=fpass(1) & f<=fpass(end));
f     = f(findx); % use findx to index out frequencies of interest
 
% get multi-tapers
tapers = [2 3]; % [2 3] % [3 5] % [5 9]
tapers = dpsschk(tapers,N,Fs); % check tapers

figure('color','w')
for i = 1:size(tapers,2)
    subplot(str2num(['33',num2str(i)]))
    plot(tapers(:,i))
end

% multi-taper fourier transform
data_og   = data1;                      % store old copy of data
data1     = change_row_to_column(data1);
[NC,C]    = size(data1);                % size of data
[NK K]    = size(tapers);               % size of tapers
tapers    = tapers(:,:,ones(1,C));      % add channel indices to tapers - doesn't do anything
data1     = data1(:,:,ones(1,K));       % make copies of dataset to run tapers on - 3D matrix
data1     = permute(data1,[1 3 2]);     % reshape data to get dimensions to match those of tapers
data_proj = data1.*tapers;              % product of data with tapers
% plot data weighted data by tapers
figure('color','w')
for i = 1:size(tapers,2)
    subplot(str2num(['33',num2str(i)]))
    plot(data_proj(:,i))
end

% plot 3D output of fft
J = fft(data_proj,nfft)/Fs; % fft of projected data

% get relevant frequencies
J = J(findx,:,:);

% plot data as a spiral - why is the FFT output include imaginary data?
figure('color','w');
x_label = linspace(0,length(J(:,1))/2,length(J(:,1)));
% show the projection onto the real axis
plot3(x_label(1:500),real(J(1:500,1)),imag(J(1:500,1)),'m')
xlabel('Time (ms)'), ylabel('real axis'), zlabel('imaginary axis')
view(0,90)
title('A complex signal is really a spiral')

% multiply the complex conjugate of J by itself to remove the imaginary
% component
S = squeeze(mean(conj(J).*J,2)); % squeeze can be ignored - would be used if across trials, but we collapsed our entire signal

freqRange = [0 100];
freqIdx   = find(f > freqRange(1) & f < freqRange(2));

figure('color','w')
    subplot 121
    plot(f(freqIdx),S(freqIdx))
    ylabel('Power (Energy of signal at each frequency)')
    xlabel('Frequency')
    title('1/f law - not log transformed')
    
    subplot 122
    plot(f(freqIdx),log10(S(freqIdx)))
    ylabel('log10(Power)')
    xlabel('Frequency')
    title('Log transformed power')

% use chronux function
clear; clc

% get data
load('data_LFP_week3')   
    
% define parameters
params.tapers     = [2 3];
params.trialave   = 0;
params.err        = [2 .05];
params.pad        = 0;
params.fpass      = [0 100]; 
params.movingwin  = [0.5 0.01]; %(in the form [window winstep] 500ms window with 10ms sliding window Price and eichenbaum 2016 bidirectional paper
params.Fs         = srate;

% get power
clear S f Serr
params.tapers = [2 3];
[S,f,Serr]    = mtspectrumc(data1(1:10000),params); 

freqIdx = find(f > 0 & f < 100);
figure('color','w')
plot(f(freqIdx),log10(S(freqIdx)))
ylabel('Power')
xlabel('Frequency')

%% Firing rate maps - how to make? How to interpret?
clear; clc; close all

% load in sample data provided
load('rateMapData2.mat')

% plot the data first - show the structure of data
figure('color','w')
imagesc(delay_rates_mat) % heatmap
colormap default         % jet colors
cb = colorbar;           % add color bar
shading 'interp'         % make it look nicer
ylabel('Neuron #')
ylabel(cb,'Firing Rate (Hz = spk/sec) - not normalized')
xlabel('Time from delay start (sec)')
title('No rate map? Why?')

% use the function to sort it
x_label = linspace(0,20,size(delay_rates_mat,2));

figure('color','w')
subplot 221
    SortedRateMap(delay_rates_mat,delay_rates_mat)
    title('delay rates sorted by delay rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 222
    SortedRateMap(delay_rates_mat,iti_rates_mat)
    title('delay rates sorted by iti rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 223
    SortedRateMap(iti_rates_mat,delay_rates_mat)
    title('iti rates sorted by delay rates')
    set(gca,'FontSize',8)    
    shading 'interp'    
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');
    
subplot 224
    SortedRateMap(iti_rates_mat,iti_rates_mat)
    title('iti rates sorted by iti rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from delay onset');       
    
    
% less sensible analysis
clear
load('rateMapStartEndData.mat')
start_rates_mat = start_rates_mat';
end_rates_mat   = end_rates_mat';
clearvars -except start_rates_mat end_rates_mat

% use the function to sort it
x_label = linspace(0,20,size(start_rates_mat,2));

figure('color','w')
subplot 221
    SortedRateMap(start_rates_mat,start_rates_mat)
    title('start rates sorted by start rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds after session onset');
    
subplot 222
    SortedRateMap(start_rates_mat,end_rates_mat)
    title('start rates sorted by end rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds after session onset');
    
subplot 224
    SortedRateMap(end_rates_mat,end_rates_mat)
    title('end rates sorted by end rates')
    set(gca,'FontSize',8)    
    shading 'interp'    
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from session end');
    
subplot 223
    SortedRateMap(end_rates_mat,start_rates_mat)
    title('end rates sorted by start rates')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('seconds from session end');       
    
%% create a random matrix
randMat1 = randn(187,63);
randMat2 = randn(187,63);

figure('color','w')
subplot 221
    SortedRateMap(randMat1,randMat1)
    title('random data 1 sorted by itself')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('some random axis');
    
subplot 222
    SortedRateMap(randMat1,randMat2)
    title('random data 1 sorted by another randomg data 2')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('some random axis');
    
subplot 224
    SortedRateMap(randMat2,randMat2)
    title('random data 2 sorted by itself')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('some random axis');
    
subplot 223
    SortedRateMap(randMat2,randMat1)
    title('random data 2 sorted by another random data 1')
    set(gca,'FontSize',8)
    shading 'interp'
    ax = gca;
    ax.XTick = [30, 60];
    ax.XTickLabel = [{'10'};{'20'}];
    xlabel('some random axis');     













