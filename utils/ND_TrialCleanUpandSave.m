function p = ND_TrialCleanUpandSave(p)
% Finish up the trial.
% in part taken from cleanUpandSave in the PLDAPS pldapsDefaultTrialFunction
%
% TODO: watch PLDAPS future development for changes in hardware cleanUpandSave 
%       methods that will include part of this functionality. Avoid duplication!
%
% wolf zinke, Dec. 2016

    % might be moved to pds.datapixx.cleanUpandSave
    [p.trial.timing.flipTimes(:,p.trial.iFrame)] = deal(Screen('Flip', p.trial.display.ptr));

    %-------------------------------------------------------------------------%
    %% determine trial duration
    p.trial.trialend = GetSecs - p.trial.trstart;
    
    %-------------------------------------------------------------------------%
    %% end DataPixx
    if(p.trial.datapixx.use)
        p.trial.datapixx.datapixxstoptime = Datapixx('GetTime'); % WZ: Does this need to be called first or could it be combined with the following if block?
    end

    % might be moved to pds.datapixx.cleanUpandSave
    % clean up analog data collection from Datapixx
    pds.datapixx.adc.cleanUpandSave(p);
    
    if(p.trial.datapixx.use)
        p.trial.timing.datapixxTRIALEND = pds.datapixx.flipBit(p.trial.event.TRIALEND,p.trial.pldaps.iTrial);  % start of trial (Plexon)
    end

    %-------------------------------------------------------------------------%
    %% End Photo Diode
    if(p.trial.pldaps.draw.photodiode.use)
        p.trial.timing.photodiodeTimes(:,p.trial.pldaps.draw.photodiode.dataEnd:end)=[];
    end

    %-------------------------------------------------------------------------%
    %% End Keyboard
    KbQueueStop();
    KbQueueFlush();

    p.trial.keyboard.samplesTimes(       :,p.trial.keyboard.samples+1:end) = [];
    p.trial.keyboard.samplesFrames(      :,p.trial.keyboard.samples+1:end) = [];
    p.trial.keyboard.pressedSamples(     :,p.trial.keyboard.samples+1:end) = [];
    p.trial.keyboard.firstPressSamples(  :,p.trial.keyboard.samples+1:end) = [];
    p.trial.keyboard.firstReleaseSamples(:,p.trial.keyboard.samples+1:end) = [];
    p.trial.keyboard.lastPressSamples(   :,p.trial.keyboard.samples+1:end) = [];
    p.trial.keyboard.lastReleaseSamples( :,p.trial.keyboard.samples+1:end) = [];

    %-------------------------------------------------------------------------%
    %% end mouse
    if(p.trial.mouse.use)
        p.trial.mouse.cursorSamples(     :,p.trial.mouse.samples+1:end) = [];
        p.trial.mouse.buttonPressSamples(:,p.trial.mouse.samples+1:end) = [];
        p.trial.mouse.samplesTimes(      :,p.trial.mouse.samples+1:end) = [];
    end
    
    %-------------------------------------------------------------------------%
    %% Trial information
    p.trial.trialnumber   = p.trial.pldaps.iTrial;

    % system timing
    p.trial.timing.flipTimes             = p.trial.timing.flipTimes(:,1:p.trial.iFrame);  % WZ: Why here again? Was defined at the function start...
    p.trial.timing.frameStateChangeTimes = p.trial.timing.frameStateChangeTimes(:,1:p.trial.iFrame-1);

    %-------------------------------------------------------------------------%
    %%  reward system
    % TODO: Is this needed?
    pds.behavior.reward.cleanUpandSave(p);

 