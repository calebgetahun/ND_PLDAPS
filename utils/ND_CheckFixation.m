% !!! right now just a placeholder !!!
function p = ND_CheckFixation(p)
% Read in the eye position signal and check how much it deviates from a
% defined position.
%
% Currently, it is hard coded to calculate the median for a defined number
% of recent samples in order to determine a more robust eye position.
%
%
% TODO: Define sample based on a time period not number of samples.
%
% wolf zinke, Jan. 2017

%% get eye position data
if(p.trial.mouse.useAsEyepos)
    nSamples = p.trial.behavior.fixation.Sample;
    
    % Get the last mouse position
    mousePos = p.mouse.cursorSamples(:,end);   
    
    p.trial.eyeX = mousePos(1);
    p.trial.eyeY = mousePos(2);
    
else
    
    sIdx = (p.trial.datapixx.adc.dataSampleCount - p.trial.behavior.fixation.Sample + 1) : p.trial.datapixx.adc.dataSampleCount;  % determine the position of the sample. If this causes problems with negative values in the first trial, make sure to use only positive indices.

    % calculate a moving average of the eye position for display reasons
    p.trial.eyeX   = p.trial.eyeCalib.gain(1) * (prctile(p.trial.AI.Eye.X(sIdx), 50) - p.trial.eyeCalib.offset(1));
    p.trial.eyeY   = p.trial.eyeCalib.gain(2) * (prctile(p.trial.AI.Eye.Y(sIdx), 50) - p.trial.eyeCalib.offset(2));
end

p.trial.eyeAmp = sqrt((p.trial.behavior.fixation.fixPos(1) - p.trial.eyeX)^2 + ...
    (p.trial.behavior.fixation.fixPos(2) - p.trial.eyeY)^2 );

%% update eye position history (per frame)
if(p.trial.pldaps.draw.eyepos.use)
    p.trial.eyeXY_draw = [p.trial.eyeX, p.trial.eyeY];
    
    p.trial.eyeX_hist = [p.trial.eyeXY_draw(1), p.trial.eyeX_hist(1:end-1)];
    p.trial.eyeY_hist = [p.trial.eyeXY_draw(2), p.trial.eyeY_hist(1:end-1)];
end

%% if relevant for task determine fixation state
if(p.trial.behavior.fixation.use)

    switch p.trial.FixState.Current
        %% currently not fixating
        case p.trial.FixState.FixOut
            % all below threshold?
            if(p.trial.eyeAmp <= p.trial.behavior.fixation.FixWin/2 )
                pds.datapixx.strobe(p.trial.event.FIX_IN);
                p.trial.FixState.Current = p.trial.FixState.FixIn;
            end

        %% gaze within fixation window
        case p.trial.FixState.FixIn

            % all above threshold?
            if(p.trial.eyeAmp > p.trial.behavior.fixation.FixWin/2)
                pds.datapixx.strobe(p.trial.event.FIX_OUT);
                p.trial.FixState.Current = p.trial.FixState.FixOut;
            end

        %% if it is nan, so just get the current state
        otherwise
            if(isnan(p.trial.FixState.Current))
                if(p.trial.eyeAmp > p.trial.behavior.fixation.FixWin/2)
                    p.trial.FixState.Current = p.trial.FixState.FixOut;

                elseif(p.trial.eyeAmp <= p.trial.behavior.fixation.FixWin/2)
                    p.trial.FixState.Current = p.trial.FixState.FixIn;

                else
                    p.trial.FixState.Current = NaN;
                end
            else
                error('Unknown fixation state!');
            end
    end  % switch p.FixState.Current
end  % if(p.trial.behavior.fixation.use)

