function p = ND_GiveDrug(p)
%% control drug application times
% 
%
%
% wolf zinke, Nov 2017

if(p.trial.Drug.StimTrial == 1 && p.trial.Drug.StimDone == 0 && p.trial.CurTime >= p.trial.Drug.StimTime )
    
   timings =  ND_PulseSeries(p.trial.datapixx.TTL_spritzerChan,    p.trial.datapixx.TTL_spritzerDur,       ...
                             p.trial.datapixx.TTL_spritzerNpulse,  p.trial.datapixx.TTL_spritzerPulseGap,  ...
                             p.trial.datapixx.TTL_spritzerNseries, p.trial.datapixx.TTL_spritzerSeriesGap, ...
                             p.trial.event.INJECT);

    p.trial.Drug.LastStimTrial = p.trial.pldaps.iTrial;
    p.trial.Drug.LastStimTime  = timings(1);   % be a bit more accurate instead of using p.trial.CurTime
    p.trial.Drug.StimDone = 1;
    p.defaultParameters.EV.Drug  = timings(1);
end
