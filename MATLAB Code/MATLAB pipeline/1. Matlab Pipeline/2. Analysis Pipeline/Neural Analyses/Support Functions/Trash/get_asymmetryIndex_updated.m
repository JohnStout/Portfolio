%% get_asymmetryIndex
%
% -- INPUTS -- %
% datafolder: string datafolder
% lfp: vector of lfp 
% lfp_srate: sampling rate of lfp
% phase_bandpass: 

function [asymmetryIDX] = get_asymmetryIndex(lfp,timesLFP,lfp_srate,phase_bandpass)

% filter 4-12 hz
%phase_bandpass = [4 12];
[signal_filtered] = skaggs_filter_var(lfp,phase_bandpass(:,1),phase_bandpass(:,2),lfp_srate);

% phase freq detect - get phase
Phase = phase_freq_detect(signal_filtered, timesLFP, 4, 12, lfp_srate);

% using phase, use find function to find closest values to 0, to 180 (peak), and
% to 360 (trough)
trough = find(Phase == 0); %should i add a line including 360?
peak   = find(Phase == 180);

%% FOR DESCENDING [TROUGH - PEAK]

figure('color','w')
plot(timesLFP, signal_filtered)

figure(); plot(timesLFP,signal_filtered,'k'); hold on;
timing = linspace(1,length(timesLFP),length(timesLFP));
plot(timesLFP(peak),signal_filtered(peak),'.r','Marker','o');
plot(timesLFP(trough),signal_filtered(trough),'.b','Marker','o');


% if peak comes first, and peak comes last
if peak(1) < trough(1) && peak(end) > trough(end)
 % delete the last peak because peak was the last observed
    peak_temp = [];    % initialize
    peak_temp = peak;  % define
    peak_temp(end)=[]; % delete
    
    % need to find a way to put peak_temp and trough into one vector,
    % sorted based on which comes first, but also tagged with a 1 or a 0.
    peak_temp(:,2) = 2;
    trough(:,2)    = 1;
    
    % cat
    peaks_troughs = vertcat(trough,peak_temp);
    
    % sort the variables
    [sorted,sort_idx] = sort(peaks_troughs,1);
    doubleDetect = peaks_troughs(sort_idx(:,1),2);
    
    % use doubledetect to get sort_idx, then use sort_idx to get peaks_troughs
    for i = 1:length(doubleDetect)-1
        % if there is double peak, and we're doing descending, and peak
        % comes first and trough comes last
        
        % detect doublets in peak
        if doubleDetect(i) == doubleDetect(i+1) & (doubleDetect(i) == 2 & doubleDetect(i+1) == 2)
            % get the index of sorted values to go back to peaks_troughs
            idxRem = sort_idx(i,1);
            % get peaks_troughs value that lets us go back to peak
            idxRem2 = peaks_troughs(idxRem);
            % get peak
            idxNan  = find(peak_temp == idxRem2);
            % set peak to nan
            peak_temp(idxNan) = NaN;
            
        % detect doublets in troughs    
        elseif doubleDetect(i) == doubleDetect(i+1) & (doubleDetect(i) == 1 & doubleDetect(i+1) == 1)
            
            % get the index of sorted values to go back to peaks_troughs
            idxRem = sort_idx(i+1,1);
            % get peaks_troughs value that lets us go back to peak
            idxRem2 = peaks_troughs(idxRem);
            % get trough
            idxNan  = find(trough == idxRem2);
            % set trough to nan
            trough(idxNan) = NaN;            
        end
    end

    % remove second columns
    trough(:,2) = [];
    peak_temp(:,2) = [];
    
    % remove nans
    peak_temp(isnan(peak_temp))=[];
    trough(isnan(trough))=[];
    
    % calculate descending
    descending = trough-peak_temp;

    % sanity checks - there should be no negative values
    if find(descending < 0)
        error('descending not correctly determined')
    end
% if peak comes first, and peak comes second-last
elseif peak(1) < trough(1) && peak(end) < trough(end)
    % this is good, just move along w/out deletions
    descending = trough-peak;
    % sanity checks - there should be no negative values
    if find(descending < 0)
        error('descending not correctly determined')
    end
% if peak comes second, and peak comes last
elseif peak(1) > trough(1) && peak(end) > trough(end)
  % delete the first trough 
    trough_temp = [];
    trough_temp = trough;
    trough_temp(1) = [];
   % delete the last peak
    peak_temp = [];
    peak_temp = peak;
    peak_temp(end) = [];
    % take difference
    descending = trough_temp-peak_temp;
    % sanity checks - there should be no negative values
    if find(descending < 0)
        error('descending not correctly determined')
    end    
% if peak comes second, and peak comes second-last
elseif peak(1) > trough(1) && peak(end) < trough(end)
    % delete the first trough
    trough_temp = [];    % initialize
    trough_temp = trough;  % define
    trough_temp(1)=[]; % delete
    % take difference
    descending = trough_temp-peak;
    % sanity checks - there should be no negative values
    if find(descending < 0)
        error('descending not correctly determined')
    end
end 


%% FOR ASCENDING [PEAK - TROUGH]

% if peak comes first, and peak comes last
if peak(1) < trough(1) && peak(end) > trough(end) 
    % delete first peak 
        peak_temp = [];
        peak_temp = peak;
        peak_temp(1) = [];
        % take difference 
        ascending = peak_temp-trough;
    % sanity checks - there should be no negative values
    if find(descending < 0)
        error('ascending not correctly determined')
    end   
% if peak comes first, and peak comes second-last
elseif peak(1) < trough(1) && peak(end) < trough(end)
    % delete first peak
        peak_temp = [];
        peak_temp = peak;
        peak_temp(1) = [];
    % delete last trough
        trough_temp = [];
        trough_temp = trough;
        trough_temp(end) = [];
    % take difference
        ascending = peak_temp-trough_temp;
    % sanity checks - there should be no negative values
    if find(ascending < 0)
        error('ascending not correctly determined')
    end
% if peak comes second, and peak comes last
elseif peak(1) > trough(1) && peak(end) > trough(end)
    % this is good, just move along w/out deletions 
        % take difference
        ascending = peak-trough;
    % sanity checks - there should be no negative values    
    if find(ascending < 0)
        error('ascending not correctly determined')
    end    
% if peak comes second, and peak comes second-last
elseif peak(1) > trough(1) && peak(end) < trough(end) 
    % delete last trough
        trough_temp = [];
        trough_temp = trough;
        trough_temp(end) = [];
    % take difference 
        ascending = peak-trough_temp;
    % sanity checks - there should be no negative values
    if find(ascending < 0)
        error('ascending not correctly determined')
    end
end

%% calculate asymmetry index log((ascending)) - log((descending))

% sanity check - check that ascend and descend variables are the same size.
% If they're not, create an error.
if length(ascending) ~= length(descending)
    error('Error in sizing')
end

asymmetryIDX = log((ascending)) - log((descending));

end
