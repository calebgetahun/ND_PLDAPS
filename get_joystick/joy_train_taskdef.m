function p = joy_train_taskdef(p, task)
% define task parameters for the joystick training task.
% This function will be executed at every trial start, hence it is possible
% to edit it while the experiment is in progress in order to apply online
% modifications of the task. 
%
% TODO: - Make sure that changed parameters are kept in the data file, i.e.
%         that there is some log when changes happened
%       - read in only changes in order to allow quicker manipulations via the
%         keyboard without overwriting it every time by calling this routine
%
%
% wolf zinke, Dec. 2016


% ------------------------------------------------------------------------%
%% Condition/Block design
p.trial.(task).EqualCorrect = 0; % if set to one, trials within a block are repeated until the same number of correct trials is obtained for all conditions

% ------------------------------------------------------------------------%
%% Reward
p.trial.(task).Reward.Pull = 0;                % If 1 then give reward for pulling the joystick

p.trial.(task).Reward.IncrConsecutive = 1;     % increase reward for subsequent correct trials. Otherwise reward will increase with the number of hits
p.trial.(task).Reward.Dur  = [0.1, 0.25, 0.5]; % reward duration [s], user vector to specify values used for incremental reward scheme
p.trial.(task).Reward.Step = [2, 4, 6];        % define the number of trials when to increase reward. CVector length can not be longer than p.trial.(task).Reward.Dur

p.trial.(task).Reward.Lag    = 50;             % Delay between response and reward onset
p.trial.(task).Reward.ManDur = 500;            % reward duration [s] for reward given by keyboard presses

% ------------------------------------------------------------------------%
%% Task Timings
p.trial.(task).Timing.WaitStart   =   30;      % maximal time period in seconds to press the lever in order to start a trial.
p.trial.(task).Timing.WaitResp    =  100;      % Only response times after this wait period will be considered stimulus driven responses
p.trial.(task).Timing.MaxResp     = 2500;      % maximum release time considered as stimulus driven response

% inter-trial interval
p.trial.(task).Timing.MinITI      =  200;      % minimum time period between subsequent trials
p.trial.(task).Timing.MaxITI      = 1000;      % maximum time period between subsequent trials

p.trial.(task).Timing.TimeOut     = 50;        % Time out for incorrect responses
p.trial.(task).Timing.PullTimeOut = 1000;      % this is the minimum time passed before a trial starts after random lever presses

% ------------------------------------------------------------------------%
%% Stimulus parameters
p.trial.(task).TargetSz_dva       = 2;         % Stimulus diameter in dva
p.trial.(task).TargetSz_pxl       = ND_dva2pxl(p.trial.(task).TargetSz_dva, p); % Stimulus diameter in dva



% ------------------------------------------------------------------------%
%% Joystick parameters
p.trial.(task).Joy.ActTime =   25;       % minimum time [ms] required to be considered as joystick change

% ------------------------------------------------------------------------%
%% Trial duration
% maxTrialLength is used to pre-allocate memory at several initialization
% steps. It specifies a duration in seconds.

p.trial.pldaps.maxTrialLength = 60; % this parameter is used to pre-allocate memory at several initialization steps. Unclear yet, how this terminates the experiment if this number is reached.





