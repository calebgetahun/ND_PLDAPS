function p = setup(p)
% p = pds.drug.setup(p)
% prepare drug delivery
% 
% wolf zinke, Nov 2017

p.defaultParameters.Drug.TriggerStim = 0;
p.defaultParameters.Drug.StimTrial   = 0;

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

