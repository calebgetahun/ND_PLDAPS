function p=joy_task(p, state, task)
% Main trial function for initial joystick training. 
% 
% The animal needs to learn how to operate a joystick (i.e. lever) in order
% to receive a juice reward.
% 
% 1) The trial starts with a change of background color (maybe changed to a
%    appearance of a frame). 
% 2) The animal has to press a lever and a large square is shown together
%    with a juice reward (this first reward will be disabled once the main 
%    principle is understood).
% 3) If the animal keeps the lever pressed for a minimum hold time and then
%    releases it, the square changes its contrast and another reward will be
%    delivered.
% 
% TODO: add accoustic feedback
%
% wolf zinke, Dec. 2016

% ####################################################################### %        
%% define the task name that will be used to create a sub-structure in the trial struct
if(nargin < 3)
    if(isfield(p.defaultParameters, 'TaskName'))
        task = p.defaultParameters.TaskName;
    elseif(isfield(p.trial, 'TaskName'))
        task = p.trial.TaskName;        
    else
        task='joy_train'; % this will be used to create a sub-struct in the trial structure
    end
end

if(~exist('state', 'var'))
    state = [];
end

% ####################################################################### %        
%% Call standard routines before executing task related code
% This carries out standard routines, mainly in respect to hardware interfacing.
% Be aware that this is done first for each trial state!
p = ND_GeneralTrialRoutines(p, state, task); 

% ####################################################################### %        
%% Initial call of this function. Use this to define general settings of the experiment/session.
% Here, default parameters of the pldaps class could be adjusted if needed.
% This part corresponds to the experimental setup file and could be a separate
% file. In this case p.defaultParameters.pldaps.trialFunction needs to be defined
% here to refer to the file with the actual trial 
if(isempty(state))

    p.trial.pldaps.TaskName = task;

    % --------------------------------------------------------------------%
    %% get task parameters
    p = joy_train_taskdef(p, task);  % WZ: could it be removed here and just run in trialSetup?
    
    % --------------------------------------------------------------------%
    %% define ascii output file 
    % call this after ND_InitSession to be sure that output directory exists!
    Trial2Ascii(p, task, 'init');

    % --------------------------------------------------------------------%
    %% Color definitions of stuff shown during the trial
    % PLDAPS uses color lookup tables that need to be defined before executing pds.datapixx.init, hence
    % this is a good place to do so. To avoid conflicts with future changes in the set of default
    % colors, use entries late in the lookup table (>200) for the definition of task related colors.
    ND_DefineCol(p, 'bg',         200, [0.25, 0.25, 0.25], [0.25, 0.25, 0.25]);
    ND_DefineCol(p, 'TargetOn',   201, [1.00, 0.00, 0.00], [1.00, 0.00, 0.00]);
    ND_DefineCol(p, 'TargetDimm', 203, [0.00, 1.00, 0.00], [0.00, 1.00, 0.00]);

    % --------------------------------------------------------------------%
    %% Determine conditions and their sequence
    % define conditions (conditions could be passed to the pldaps call as
    % cell array, or defined here within the main trial function. The
    % control of trials, especially the use of blocks, i.e. the repetition
    % of a defined number of trials per condition, needs to be clarified.
    % Right now, it is a placeholder).

    maxTrials_per_BlockCond = 10;  
    maxBlocks = 100;
    
    % condition 1
    c1.Nr = 1; 
      
    % condition 2
    c2.Nr = 2; 
    
    % condition 3
    c3.Nr = 3; 
      
    % condition 4
    c4.Nr = 4; 
    
    % create a cell array containing all conditions
    conditions = {c1, c2, c3, c4};
    
    p = ND_GetConditionList(p, conditions, maxTrials_per_BlockCond, maxBlocks);
    
else
% ####################################################################### %        
%% Subsequent calls during actual trials
% execute trial specific commands here.

    task = p.trial.pldaps.TaskName;
    
    switch state
% ####################################################################### %        
% DONE BEFORE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialSetup
        %% trial set-up
        % prepare everything for the trial, including allocation of stimuli
        % and all other more time demanding stuff.
        
        TaskSetUp(p, task);
        
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialPrepare
        %% trial preparation            
        % just prior to actual trial start, use it for time sensitive preparations;
                
        
        
        ND_CtrlMsg(p, 'TRIAL Start');

% ####################################################################### %        
% DONE DURING THE MAIN TRIAL LOOP:        
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.framePrepareDrawing
        %% Get ready to display
        % prepare the stimuli that should be shown, do some required calculations
        
        TaskDesign(p, task);
        
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.frameDraw
        %% Display stuff on the screen
        % Just call graphic routines, avoid any computations
        
        TaskDraw(p, task)

% ####################################################################### %        
% DONE AFTER THE MAIN TRIAL LOOP:
        % ----------------------------------------------------------------%
        case p.trial.pldaps.trialStates.trialCleanUpandSave
        %% trial end
          
            % FinishTask(p);
                        
            p = ND_CheckCondRepeat(p); % ensure all conditions were performed correctly equal often
            
            Trial2Ascii(p, task, 'save');
            
            % just as fail safe, make sure to finish when done
            if(p.trial.pldaps.iTrial == length(p.conditions))
                p.trial.pldaps.finish = p.trial.pldaps.iTrial;
            end
            
            ND_CtrlMsg(p, 'TRIAL END');
            
    end  %/ switch state
end  %/  if(nargin == 1) [...] else [...]

% ------------------------------------------------------------------------%
%% Task related functions
% TODO: Some of these functions should become stand alone functions that
% could be called from other paradigms as well. 
  
% ------------------------------------------------------------------------%
function TaskSetUp(p, task)
%% main task outline
% 
    p = joy_train_taskdef(p, task);  % brute force: read in task parameters every time to allow for online modifications. TODO: make it robust and let it work with parameter changes via keyboard, see e.g. monkeylogic editable concept.

    p.trial.(task).Timing.ITI = ND_GetITI(p.trial.(task).Timing.MinITI, p.trial.(task).Timing.MaxITI);

    p.trial.(task).TaskStart   = NaN;
    p.trial.(task).CurrOutcome = NaN;

    p.trial.CurrEpoch = p.trial.epoch.GetReady;

% ------------------------------------------------------------------------%
function TaskDesign(p, task)
%% main task outline
% The different task stages (i.e. 'epochs') are defined here.

    switch p.trial.(task).CurrEpoch
        % ----------------------------------------------------------------%
        case p.trial.epoch.GetReady
        %% before the trial can start joystick needs to be in a released state
            if(p.trial.pldaps.JoyState.Current == p.trial.pldaps.JoyState.JoyRest)
            % joystick in a released state, let's start the trial    
                p.trial.CurrEpoch = p.trial.epoch.WaitStart;
                p.trial.(task).EV.TaskStart = GetSecs;
                
                ND_CtrlMsg(p, 'Trial started');
                
                p.trial.(task).Timing.WaitTimer = p.trial.(task).EV.TaskStart + p.trial.(task).Timing.WaitStart;
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitStart
        %% Wait for joystick press   
            ctm = GetSecs;
            if(ctm > p.trial.(task).Timing.WaitTimer) 
            % no trial initiated in the given time window
                ND_CtrlMsg(p, 'No joystick press');
                p.trial.(task).CurrOutcome = p.trial.outcome.NoPress;
                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
                
            elseif(p.trial.(task).CurrJoyState == p.pldaps.FixState.JoyHold)
            % we just got a press in time
                ND_CtrlMsg(p, 'Joystick press');
                p.trial.CurrEpoch = p.trial.epoch.WaitGo;
                
                p.trial.(task).EV.JoyPress      = ctm;
                p.trial.(task).Timing.WaitTimer = ctm + p.trial.(task).Timing.HoldTime;
            end
        
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitGo
        %% delay before response is needed     
            ctm = GetSecs;
            if(p.trial.(task).CurrJoyState == p.pldaps.FixState.JoyRest) % early release
                ND_CtrlMsg(p, 'Early releases');
                p.trial.(task).CurrOutcome = p.trial.outcome.Early;
                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
                p.trial.(task).EV.JoyRelease = ctm;
                
            elseif(ctm > p.trial.(task).Timing.WaitTimer) 
                ND_CtrlMsg(p, 'Wait response');
                p.trial.CurrEpoch = p.trial.epoch.WaitResponse;
                p.trial.(task).EV.GoCue         = ctm;
                p.trial.(task).Timing.WaitTimer = ctm + p.trial.(task).Timing.WaitResp;
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitResponse
        %% Wait for joystick release     
            ctm = GetSecs;
            if(ctm > p.trial.(task).Timing.WaitTimer) 
                ND_CtrlMsg(p, 'No Response');
                p.trial.(task).CurrOutcome = p.trial.outcome.Miss;
                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;             
           
            elseif(p.trial.(task).CurrJoyState == p.pldaps.FixState.JoyRest)
            % we just got a release
                ND_CtrlMsg(p, 'Correct Response');
                p.trial.(task).CurrOutcome = p.trial.outcome.Correct;
                p.trial.(task).EV.JoyRelease    = ctm;
                p.trial.(task).Timing.WaitTimer = ctm + p.trial.(task).Reward.Lag;
                p.trial.CurrEpoch = p.trial.epoch.WaitReward;
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitReward
        %% Wait for for reward   
        % add error condition for new press
            ctm = GetSecs;
            if(ctm > p.trial.(task).Timing.WaitTimer) 
                p.trial.(task).EV.Reward = ctm;
                % TODO: add function to select current reward amount based on time or
                %       number of consecutive correct trials preceding the current one.
                
                pds.behavior.reward.give(p, p.trial.(task).Reward.Dur);
                ND_CtrlMsg(p, 'Reward');
                
                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
            end
            
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitRelease
        %% Wait for joystick release after missed response    
            if(p.trial.(task).CurrJoyState == p.pldaps.FixState.JoyRest)
                p.trial.(task).EV.JoyRelease = GetSecs;
                p.trial.CurrEpoch = p.trial.epoch.TaskEnd;
            end
        
        % ----------------------------------------------------------------%
        case p.trial.epoch.TaskEnd
        %% finish trial and error handling
            if(p.trial.(task).CurrOutcome == p.trial.outcome.Correct)
                p.trial.(task).Timing.WaitTimer = GetSecs + p.trial.(task).Timing.ITI;
                ND_CtrlMsg(p, ['Next trial in ', num2str(p.trial.(task).Timing.ITI, '%.4f'), 'seconds.']);
            else
                p.trial.(task).Timing.WaitTimer = GetSecs + p.trial.(task).Timing.ITI + p.trial.(task).Timing.TimeOut;
            end

        % ----------------------------------------------------------------%
        case p.trial.epoch.ITI
        %% inter-trial interval: wait before next trial to start   
            if(GetSecs > p.trial.(task).Timing.WaitTimer) 
                p.trial.flagNextTrial = 1;
            end
    end


% ------------------------------------------------------------------------%
function TaskDraw(p, task)
%% show epoch dependent stimuli
% go through the task epochs as defined in TaskDesign and draw the stimulus
% content that needs to be shown during this epoch.
    switch p.trial.(task).CurrEpoch             
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitStart
        %% Wait for joystick press   
            ND_TrialOn(p);    
        
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitGo
        %% delay before response is needed     
            ND_TrialOn(p);
            Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.TargetOn, p.trial.(task).TargetRect);

        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitResponse
        %% Wait for joystick release     
            ND_TrialOn(p);
            Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.TargetOn, p.trial.(task).TargetRect);
        
        % ----------------------------------------------------------------%
        case p.trial.epoch.WaitReward
        %% Wait for for reward   
            ND_TrialOn(p);
            Screen('FillRect', p.trial.display.overlayptr, p.trial.display.clut.TargetDimm, p.trial.(task).TargetRect);
                       
    end

    

% ------------------------------------------------------------------------%
function Trial2Ascii(p, task, act)
%% Save trial progress in an ASCII table
% 'init' creates the file with a header defining all columns
% 'save' adds a line with the information for the current trial
%
% make sure that number of header names is the same as the number of entries
% to write, also that the position matches.

    switch act
        case 'init'
            p.trial.session.asciitbl = [datestr(now,'yyyy_mm_dd_HHMM'),'.dat'];
            tblptr = fopen(fullfile(p.trial.pldaps.dirs.data, p.trial.session.asciitbl) , 'w');
            
            fprintf(tblptr, 'Date  Subject  Experiment  Tcnt  Tstart');
            
        case 'save'
            trltm = p.trial.timing.datapixxTrialStart - p.trial.timing.datapixxSessionStart;
            
            tblptr = fopen(fullfile(p.trial.pldaps.dirs.data, p.trial.session.asciitbl) , 'w');
            fprintf(tblptr, '%s  %s  %s  %d  %.5f \n' , ...
                            datestr(p.trial.session.initTime,'yyyy_mm_dd'), p.trial.session.subject, ...
                            p.trial.session.experimentSetupFile, ...
                            p.trial.pldaps.iTrial, trltm);  
    end

    fclose(tblptr);
    
    
    
% ------------------------------------------------------------------------%
function TargetOn(p)
%%  Joystick pressed, target comes on
%
%  This function should draw a blinking rectangle as the cue to engage the
%  joystick.
%
%  In PLDAPS the pointer to the stimulus window is p.trial.display.ptr

    width = p.trial.stimulus.features.baited.cue_width;
    baseRect = [0 0 width width];
    centeredRect = CenterRectOnPointd(baseRect, p.trial.display.ctr(1), p.trial.display.ctr(2));

    display_time = p.trial.stimulus.features.baited.cue_period*p.trial.stimulus.features.baited.cue_duty_cycle;
    cue_period = p.trial.stimulus.features.baited.cue_period;
    if(isnan(p.trial.stimulus.timing.baited_cue_start_time))
        p.trial.stimulus.timing.baited_cue_start_time = GetSecs;
        Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.baited.cue_color,centeredRect,p.trial.stimulus.features.baited.cue_linewidth);
    else
        if(p.trial.stimulus.timing.baited_cue_start_time > GetSecs-display_time)
            Screen('FrameRect',p.trial.display.ptr,p.trial.stimulus.features.baited.cue_color,centeredRect,p.trial.stimulus.features.baited.cue_linewidth);
        elseif(p.trial.stimulus.timing.baited_cue_start_time <= GetSecs-cue_period)
            p.trial.stimulus.timing.baited_cue_start_time = NaN;
        end
    end


    
    
    
    

    
    
  