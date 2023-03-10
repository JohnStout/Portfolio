%% linearPosition_binData
%
% ONLY USING THIS FOR SPEED FOR NOW
%
% this function bins data per each linear position bin. Data will be
% structured in 1xN where N is the number of data points and each element
% corresponds to the data of interest. For example, if you had
% instantaneous spikes, where each element corresponds to spike counts
% across time, then your output variable 'dataBinned' will be number of
% spikes per linear position bin.
%
% -- INPUTS -- %
% data: vector or matrix of data
% linearPosition: vector of linear position - this needs to be the same
%                   size as data
% method: how do you want to handle the binned data? (ie per each bin, do
%           you want to average? Sum?). For example, if you have firing
%           rates, it would make sense to set method = 'mean'; However, if
%           you want the total amount of time or total spikes, then set
%           method = 'sum;
%                           -> SUMMARY <-
%
%                   method = 'mean'; % for averaging within bins (ie firing rate)
%                   method = 'sum';  % for summing within bins (ie spike counts or time)
%
% noData: 'interp' interpolates missing data. 'zero' sets values to
%                   zero. Utility: if you are working with spike data, you
%                   may be better off setting missing data to zero (for
%                   example spike counts). However, if you're working with
%                   firing rates, it may be better to interpolate missing
%                   data. If working with power/coherence, it's probably
%                   better to interpolate.
%
% total_dist: total distance traveled (total theoretical distance), so if
%               you set linear bins to 300, and you have 299, enter 300
%
% -- OUTPUTS -- %
% dataBinned: data binned according to linear position. This is
%               additionally spline interpolated to handle any missing bins
%
% written by John Stout

function [dataOut] = linearPosition_binData(data,linearPosition,method,method_inputs,noData,total_dist)

% re-orient data if necessary
checkSize = size(data);
if checkSize(1) == length(linearPosition)
    % flip size
    dataNew = [];
    dataNew = data';
    % repurpose variable
    data    = [];
    data    = dataNew;
end

% make sure linear position is rounded
checkInteger = isinteger(linearPosition);
if checkInteger == 0
    linearPostion_new = [];
    linearPosition_new = round(linearPosition);
    % repurpose
    linearPosition = [];
    linearPosition = linearPosition_new;
end

% get data per bin
dataBinned = cell([1 total_dist]); 
for i = 1:total_dist % loop across the number of bins
    dataBinned{i} = data(:,linearPosition == i);
end

% take average
dataBinnedMethod = [];
dataBinnedMethod = cellfun2(dataBinned,method,method_inputs);

% often, doing the method above can leave you with nans. Therefore, you may
% not need to do this
if find(cellfun('isempty',dataBinnedMethod) > 0)
    if contains(noData,[{'interp'} {'interpolate'}])

        % do interpolation to handle NaNs
        xLabel = linspace(0,total_dist,total_dist);
        badElements = isnan(dataBinnedMethod);
        newY = dataBinnedMethod(~badElements);
        newX = xLabel(~badElements);
        xq   = xLabel;
        dataInterp = interp1(newX, newY, xq, 'spline');

        % organize output
        dataOut = dataInterp;

    elseif contains(noData,[{'zero'} {'zeros'}]) 

        % find nans and replace with zero
        badElements = isnan(dataBinnedMethod);
        dataBinnedMethod(badElements) = 0;

        % organize output
        dataOut = dataBinnedMethod;

    elseif contains(noData,[{'raw'}]) | isempty(noData);
        dataOut = dataBinnedMethod;
    end
else
    dataOut = dataBinnedMethod;
end
