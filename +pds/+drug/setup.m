function p = setup(p)
% p = pds.drug.setup(p)
% prepare drug delivery
% 
% wolf zinke, Nov 2017

p.defaultParameters.Drug.TriggerStim = 0;   % trigger drug application for next trials
p.defaultParameters.Drug.StimTrial   = 0;   % Is the current trial a drug trial
p.defaultParameters.Drug.StimDone    = 0;   % flag that drug was delivered
p.defaultParameters.Drug.StimTime    = NaN; % application time relative to task start

% ensure that block lengths are specified for ON and OFF periods
if(length(p.defaultParameters.Drug.BlockLength) == 1)
    p.defaultParameters.Drug.BlockLength = [p.defaultParameters.Drug.BlockLength, p.defaultParameters.Drug.BlockLength];
end

switch p.defaultParameters.Drug.StimBlock
    case 'trial'
        p.defaultParameters.Drug.BlockStart = 1;  % start with first trial
    case 'time'
        p.defaultParameters.Drug.BlockStart = GetSecs;
    otherwise
        error('Unknown block definition <%s>!', p.defaultParameters.Drug.StimBlock);
end

