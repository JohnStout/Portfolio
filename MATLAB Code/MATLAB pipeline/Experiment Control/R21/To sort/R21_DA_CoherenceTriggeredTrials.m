% DA task that incorporates coherence detection
% must have the matlab pipeline Startup run and startup_experimentControl


%% add path to rat place - note that things are blinded, so don't open code
addpath('X:\01.Experiments\R21\Experimenter Blinding - SUHYEONG ONLY')
cd('X:\01.Experiments\R21\Experimenter Blinding - SUHYEONG ONLY');

%% IF TROUBLESHOOTING
% load in the model_thresholds, and don't load in thresholds that is below

% pause
disp('WARNING!!!!! Have you added the correct name of your rat on line 366? ')
pause();

%% prep 1 - clear history, workspace, get working directory
% _____________________________________________________

% --- MAKE SURE YOU RUN STARTUP_EXPERIMENTCONTROL --- %

%______________________________________________________

% clear/clc
clear; clc

% get directory that houses this code
codeDir = getCurrentPath();
addpath(codeDir);

%% prep 2 - define baseline parameters - CHANGE ME

% hardcode parameters
threshold.high_coherence_magnitude = .7;
threshold.low_coherence_magnitude  = .3; % change to .4? as .3 was tough to hit
threshold.coh_duration             = 0.5; % rate to sample

LFP1name = 'CSC6';  % HPC
LFP2name = 'CSC10'; % PFC

%% prep 2 - define parameters for the session

% how long should the session be?
session_length = 30; % minutes

delay_length = 30; % seconds
numTrials    = 40;
pellet_count = 1;
timeout_len  = 60*15;

% define a looping time - this is in minutes
amountOfTime = (70/60); %session_length; % 0.84 is 50/60secs, to account for initial pause of 10sec .25; % minutes - note that this isn't perfect, but its a few seconds behind dependending on the length you set. The lag time changes incrementally because there is a 10-20ms processing time that adds up

% chronux parameters
params = getCustomParams;
params.fpass  = [4 12];
params.tapers = [3 5]; % bset to [3 5] as default

%% prep 3 - connect with cheetah
% set up function
[srate,timing] = realTimeDetect_setup(LFP1name,LFP2name,threshold.coh_duration);

%% experiment design prep.

% define number of trials
numTrials  = 18;

%% auto maze prep.

% -- automaze set up -- %

% check port
if exist("s") == 0
    % connect to the serial port making an object
    s = serialport("COM6",19200);
end

% load in door functions
doorFuns = DoorActions;

% test reward wells
rewFuns = RewardActions;

% get IR information
irBreakNames = irBreakLabels;

% for arduino
if exist("a") == 0
    % connect arduino
    a = arduino('COM5','Uno','Libraries','Adafruit\MotorShieldV2');
end

irArduino.Treadmill = 'D9';

%{
for i = 1:10000000
    readDigitalPin(a,irArduino.Treadmill)
end
%}

%% coherence detection prep.

% define sampling rate
params.Fs     = srate;

% define number of samples that correspond to the amount of data in time
numSamples2use = threshold.coh_duration*srate;

% define for loop - 70 total sec
looper = ceil((amountOfTime*60/threshold.coh_duration)); %ceil((amountOfTime*60)/threshold.coh_duration); % N minutes * 60sec/1min * (1 loop is about .250 ms of data)

% define total loop time
total_loop_time = threshold.coh_duration*60; % in seconds

%% clean the stored data just in case IR beams were broken
s.Timeout = 1; % 1 second timeout
next = 0; % set while loop variable
while next == 0
   irTemp = read(s,4,"uint8"); % look for stored data
   if isempty(irTemp) == 1     % if there are no stored ir beam breaks
       next = 1;               % break out of the while loop
       disp('IR record empty - ignore the warning')
   else
       disp('IR record not empty')
       disp(irTemp)
   end
end

% close all maze doors - this gives problems with solenoid box
pause(0.25)
writeline(s,[doorFuns.centralClose doorFuns.sbLeftClose ...
    doorFuns.sbRightClose doorFuns.tLeftClose doorFuns.tRightClose]);

pause(0.25)
writeline(s,[doorFuns.gzLeftClose doorFuns.gzRightClose])

% reward dispensers need about 3 seconds to release pellets
for rewardi = 1:pellet_count
    writeline(s,rewFuns.right)
    pause(4)
    writeline(s,rewFuns.left)
    pause(4)
end


%% start recording - make a noise when recording begins
[succeeded, reply] = NlxSendCommand('-StartRecording');
load gong.mat;
sound(y);

%% trials
open_t  = [doorFuns.tLeftOpen doorFuns.tRightOpen];
close_t = [doorFuns.tLeftClose doorFuns.tRightClose];
maze_prep = [doorFuns.tLeftOpen doorFuns.tRightOpen ...
    doorFuns.gzLeftOpen doorFuns.gzRightOpen];

c = clock;
session_start = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time  = session_start-session_start; % quick definitio of this so it starts the while loop
for triali = 1:numTrials

    % set central door timeout value
    s.Timeout = timeout_len; % 5 minutes before matlab stops looking for an IR break    

    % first trial - set up the maze doors appropriately
    pause(0.25);
    writeline(s,maze_prep)

    % open central door to let rat off of treadmill
    pause(0.25);
    writeline(s,doorFuns.centralOpen)

    % set irTemp to empty matrix
    irTemp = []; 

    % central beam
    % while loop so that we continuously read the IR beam breaks
    next = 0;
    while next == 0
        irTemp = read(s,4,"uint8");            % look for IR beam breaks
        if irTemp == irBreakNames.central      % if central beam is broken
            % neuralynx timestamp command

            % close door
            writeline(s,doorFuns.centralClose) % close the door behind the rat
            next = 1;                          % break out of the loop
        end
    end

    % t-beam
    % check which direction the rat turns at the T-junction
    next = 0;
    while next == 0
        irTemp = [];
        irTemp = read(s,4,"uint8");         
        if irTemp == irBreakNames.tRight  
            % track the trajectory_text
            trajectory_text{triali} = 'R';
            trajectory(triali)      = 0;

            % close opposite door
            writeline(s,doorFuns.tLeftClose)  

            % open sb door
            pause(0.25)
            writeline(s,doorFuns.sbRightOpen)

            if triali > 1 && trajectory_text{triali} == 'R' && trajectory_text{triali-1} == 'L'
                % reward dispensers need about 3 seconds to release pellets
                for rewardi = 1:pellet_count
                    writeline(s,rewFuns.left)
                    pause(3)
                end
            end

            % break while loop
            next = 1;

        elseif irTemp == irBreakNames.tLeft
            % track the trajectory_text
            trajectory_text{triali} = 'L';
            trajectory(triali)      = 1;            

            % close door
            writeline(s,doorFuns.tRightClose)

            % open sb door
            pause(0.25)            
            writeline(s,doorFuns.sbLeftOpen)

            if triali > 1 && trajectory_text{triali} == 'L' && trajectory_text{triali-1} == 'R'
                % reward dispensers need about 3 seconds to release pellets
                for rewardi = 1:pellet_count
                    writeline(s,rewFuns.right)
                    pause(3)
                end
            end             

            % break out of while loop
            next = 1;
        end
    end    

    % Reward zone and eating
    % send to netcom 


    % return arm
    next = 0;
    while next == 0
        irTemp = read(s,4,"uint8");         
        if irTemp == irBreakNames.gzRight 
            % send neuralynx command for timestamp

            % close both for audio symmetry
            writeline(s,doorFuns.gzLeftClose)
            pause(0.25)
            writeline(s,doorFuns.gzRightClose)
            pause(0.25)
            writeline(s,doorFuns.tRightClose)

            next = 1;                          
        elseif irTemp == irBreakNames.gzLeft
            % send neuralynx command for timestamp

            % close both for audio symmetry
            writeline(s,doorFuns.gzLeftClose)
            pause(0.25)
            writeline(s,doorFuns.gzRightClose)
            pause(0.25)
            writeline(s,doorFuns.tLeftClose)            

            next = 1;
        end
    end      

    % startbox
    next = 0;
    while next == 0
        s.Timeout = timeout_len;
        irTemp = read(s,4,"uint8");         
        if irTemp == irBreakNames.sbRight 
            % track animals traversal onto the treadmill
            next_tread = 0; % hardcode next as 0 - this value gets updated when criteria is met
            while next_tread == 0 
                % try to see if the rat goes and checks out the other doors
                % IR beam
                s.Timeout = 0.1;
                irTemp = read(s,4,"uint8");
                % if rat enters the startbox, only close the door behind
                % him if he has either checked out the opposing door or
                % entered the center of the startbox zone. This ensures
                % that the rat is in fact in the startbox
                if readDigitalPin(a,irArduino.Treadmill) == 0
                    % close startbox door
                    pause(.25);                    
                    writeline(s,doorFuns.sbRightClose)
                    % tell the loop to move on
                    next_tread = 1;
                elseif isempty(irTemp) == 0
                    if irTemp == irBreakNames.sbLeft
                        % close startbox door
                        pause(0.25)
                        writeline(s,doorFuns.sbRightClose)
                        % tell the loop to move on
                        next_tread = 1;
                    end
                elseif isempty(irTemp)==1 && readDigitalPin(a,irArduino.Treadmill) == 1
                    next_tread = 0;
                end
            end

            next = 1;
        elseif irTemp == irBreakNames.sbLeft 
            % track animals traversal onto the treadmill
            next_tread = 0; % hardcode next as 0 - this value gets updated when criteria is met
            while next_tread == 0 
                % try to see if the rat goes and checks out the other doors
                % IR beam
                s.Timeout = 0.1;
                irTemp = read(s,4,"uint8");
                % if rat enters the startbox, only close the door behind
                % him if he has either checked out the opposing door or
                % entered the center of the startbox zone. This ensures
                % that the rat is in fact in the startbox
                if readDigitalPin(a,irArduino.Treadmill) == 0
                    % close startbox door
                    pause(.25);                    
                    writeline(s,doorFuns.sbLeftClose)
                    % tell the loop to move on
                    next_tread = 1;
                elseif isempty(irTemp) == 0
                    if irTemp == irBreakNames.sbRight
                        % close startbox door
                        pause(0.25)
                        writeline(s,doorFuns.sbLeftClose)
                        % tell the loop to move on
                        next_tread = 1;
                    end
                elseif isempty(irTemp)==1 && readDigitalPin(a,irArduino.Treadmill) == 1
                    next_tread = 0;
                end
            end

            next = 1;
        end 
    end

    % reset timeout
    s.Timeout = timeout_len;

    % initialize some variables
    timeStamps = []; timeConv  = [];
    coh_met    = []; coh_store = [];
    dur_met    = []; dur_sum   = [];    
    % only during delayed alternations will you start the treadmill
    if delay_length > 1

        % pause
        disp('Initial delay pause = 10s')
        pause(10); % no pause - start it immediately

        % use tic toc to store timing for yoked control
        tStart = [];
        tStart = tic;

        % coherence manipulation
        disp(['Trial type is ',trial_type{triali},'.'])

        %% CHANGE ME
        
        [coh_trial{triali},coherence_met(triali),timeConv{triali}] = rat21_5(LFP1name,LFP2name,coherence_threshold,threshold_type,params,tStart,doorFuns,s);
        

    end

    % out time
    delay_duration_master(triali) = toc(tStart);

end 

% get amount of time past since session start
c = clock;
session_time_update = str2num(strcat(num2str(c(4)),num2str(c(5))));
session_time = session_time_update-session_start;

% compute accuracy array
accuracy = [];
accuracy_text = cell(1, length(trajectory_text)-1);
for triali = 1:length(trajectory_text)-1
    if trajectory_text{triali} ~= trajectory_text{triali+1}
        accuracy(triali) = 0; % correct trial
        accuracy_text{triali} = 'correct';
    elseif trajectory_text{triali} == trajectory_text{triali+1}
        accuracy(triali) = 1; % incorrect trial
        accuracy_text{triali} = 'incorrect';
    end
end

%% ending noise - a fitting song to end the session
load handel.mat;
sound(y, 2*Fs);

%% save data
% save data
c = clock;
c_save = strcat(num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(1)),'_','EndTime',num2str(c(4)),num2str(c(5)));

prompt   = 'Please enter the rats name ';
rat_name = input(prompt,'s');

prompt   = 'Please enter the task ';
task_name = input(prompt,'s');

prompt   = 'Enter the directory to save the data ';
dir_name = input(prompt,'s');

save_var = strcat(rat_name,'_',task_name,'_',c_save);

cd(dir_name);
save(save_var);



