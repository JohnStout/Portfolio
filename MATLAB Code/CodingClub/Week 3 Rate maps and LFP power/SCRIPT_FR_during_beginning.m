%% Get firing rates during startbox

% clear things out
clear; clc

% add a path
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\John code and edits\Firing Rate');
   
% define number of bins
nBins = 64; % was 21

% define major directory
Datafolders = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex';

% cd and define folder_names
cd(Datafolders);
folder_names = dir;    
   
% loop across all folders within the major directory
for nn = 3:length(folder_names)
    
    Datafolders = Datafolders;
    cd(Datafolders);
    folder_names = dir;
    temp_folder = folder_names(nn).name;
    cd(temp_folder);
    datafolder = pwd;
    cd(datafolder);    
 
    % define and load some variables
    cd(datafolder);  
    load (strcat(datafolder,'\Int_file.mat')); 
    load(strcat(datafolder, '\VT1.mat'));
    cd(Datafolders);
    folder_names = dir;
    cd(datafolder);
    clusters   = dir('TT*.txt');
    TimeStamps = TimeStamps_VT;
    
    % Create index of sample and choice trials
    sample_trials = (1:2:size(Int,1));
    choice_trials = (2:2:size(Int,1));     
    
    % initialize a variable
    firingrate_pop   = cell([1 nBins]);
    
%% Create firing rate matrix for start box
    for ci=1:length(clusters)
        cd(datafolder);
        spikeTimes = textread(clusters(ci).name);
        cluster    = clusters(ci).name(1:end-4);
    
        % define a matrix used to store fr data
        firingrate_array = cell([1 nBins]);        
        
        % take 20 random 20 second intervals?
        % just take the first 20 seconds and compare it to the second 20
        % seconds. Don't even average the firing rates
        
        firingrate_array = cell([1 nBins]);

        % create variables that will be used to make bins
        start_time = []; end_time = [];            
        start_time = TimeStamps_VT(1);            
        end_time   = TimeStamps_VT(1)+(20*1e6);      
            
        % define a matrix used to store fr data
        firingrate_array = cell([1 nBins]);
            
        % bins that contain evenly spaced timing values from delay
        binned_time = linspace(start_time,end_time,nBins);        

            for timei = 1:length(binned_time)-1;
                
                % isolate spikes from multiple time points     
                spk_temp{(timei)} = find(spikeTimes>binned_time(timei) ...
                    & spikeTimes<=binned_time(timei+1));
                
                % find total number of spikes
                numspikes{(timei)} = length(spk_temp{(timei)});
                
                % find how much time
                time_temp{(timei)} = (binned_time(timei+1) - ...
                    binned_time(timei))/1e6;
                
                % calculate firing rate
                fr_new{(timei)} = numspikes{(timei)}/time_temp{(timei)};
                     
            end
            
            firing_rate = cell2mat(fr_new)';
            clear fr_new time_temp numspikes spk_temp

        % store data
        start_rates{nn-2}{ci} = firing_rate;
        clear firing_rate
        
    end
    

    for ci=1:length(clusters)
        cd(datafolder);
        spikeTimes = textread(clusters(ci).name);
        cluster    = clusters(ci).name(1:end-4);
    
        % define a matrix used to store fr data
        firingrate_array = cell([1 nBins]);        
        
        % take 20 random 20 second intervals?
        % just take the first 20 seconds and compare it to the second 20
        % seconds. Don't even average the firing rates
        
        firingrate_array = cell([1 nBins]);

        % create variables that will be used to make bins
        start_time = []; end_time = [];            
        start_time = TimeStamps_VT(end)-(20*1e6);            
        end_time   = TimeStamps_VT(end);      
            
        % define a matrix used to store fr data
        firingrate_array = cell([1 nBins]);
            
        % bins that contain evenly spaced timing values from delay
        binned_time = linspace(start_time,end_time,nBins);        

            for timei = 1:length(binned_time)-1;
                
                % isolate spikes from multiple time points     
                spk_temp{(timei)} = find(spikeTimes>binned_time(timei) ...
                    & spikeTimes<=binned_time(timei+1));
                
                % find total number of spikes
                numspikes{(timei)} = length(spk_temp{(timei)});
                
                % find how much time
                time_temp{(timei)} = (binned_time(timei+1) - ...
                    binned_time(timei))/1e6;
                
                % calculate firing rate
                fr_new{(timei)} = numspikes{(timei)}/time_temp{(timei)};
                     
            end
            
            firing_rate = cell2mat(fr_new)';
            clear fr_new time_temp numspikes spk_temp

        % store data
        end_rates{nn-2}{ci} = firing_rate;
        clear firing_rate
        
    end
    
    % display progress    
    X = ['finished with session ',num2str(nn-2)];
    disp(X)
    
end

start_rates     = horzcat(start_rates{:});
start_rates_mat = horzcat(start_rates{:});

end_rates     = horzcat(end_rates{:});
end_rates_mat = horzcat(end_rates{:});


     

