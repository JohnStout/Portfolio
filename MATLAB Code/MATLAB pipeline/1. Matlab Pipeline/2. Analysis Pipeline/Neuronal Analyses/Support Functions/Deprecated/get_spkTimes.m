%% get_spikeData
% this function extracts spike timestamps for a given datafolder. It
% requires you to define what the start of the tetrode name is. This is
% particularly useful if you have multiple regions and have named the
% cluster files accordingly (i.e hpc*.txt, where * indicates the rest of
% the name).
%
% Utility: This would be a good function to use in combination with
%           linearizedFR, linearizedFR_acrossTrials,
%           inst_neuronal_activity, inst_neuronal_activity_acrossTrials
%           functions. Those functions require a session spike times
%           variable, and for you to define the specific time points in the
%           'times' argument. Note that inst_neuronal_activity will also
%           give you the averaged firing rate, along with the instantaneous
%           firing rates.
%
% -- INPUTS -- %
% datafolder: directory that houses data of interest
% tt_name: the beginning of the tetrode name. Say your tt name is
%           TT6_SS_02, then tt_name = 'TT'; Alternatively, lets say your tt
%           name is PFC5_SS_01, then tt_name = 'PFC'
%
% -- OUTPUTS -- %
% spkTimes: cell array containing spike time stamps for all neurons
%               collected on a session (datafolder)
% clusterID: cluster name
% spike_duration: duration of spike (ie time it takes from spike peak to
%                   spike trough)
%
% written by John Stout


function [spkTimes,clusterID,spikeDuration] = get_spkTimes(datafolder,tt_name)

    % load TTs
    cd(datafolder);
    clusters = dir([tt_name,'*.txt']);
  
    if isempty(clusters)
        disp(['No clusters by the name of ',tt_name,' were found.'])
        spkTimes = [];
        clusters = [];
        clusterID = NaN;
        return
    else

        % get field names
        clusterID = extractfield(clusters,'name');

        % get spike time stamps
        for ci=1:length(clusters)
            spkTimes{ci} = textread(clusters(ci).name);
        end
        
        % get spike features, but only for those units where there are .txt
        % files
        datafolderMod = [datafolder,'\'];
        clust_ntt = clusters;
        for ci = 1:size(clust_ntt,1)
            % split name up
            splitName = strsplit(clust_ntt(i).name,'.');
            splitName{2} = '.ntt'; % add .ntt
            % glue it back together
            clust_ntt(ci).name = horzcat(splitName{:});
            
            [Timestamps, ScNumbers, CellNumbers, Features, Samples,...
                        Header] = Nlx2MatSpike(strcat(datafolderMod,...
                        clust_ntt(ci).name), [1 1 1 1 1], 1, 1, [] );
                    
            % Calculate spike duration        
            spikeDuration = [];
            spikeDuration{ci} = calculate_spike_duration(Samples,Header);                    
        end 
    end
end