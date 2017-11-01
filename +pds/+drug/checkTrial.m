function p = checkTrial(p)
% p = pds.drug.checkTrial(p)
% check if the current trial will be a drug trial
% 
% wolf zinke, Nov 2017

switch p.trial.Drug.StimDesign 
    case {'random', 'rand', 'r'}
    %% determine if this is a drug trial by chance for every single trial
    %ToDo: -right now it assumes a 50% chance according to an uniform distribution, different 
    %       distributions and probabilities could be implemented;   
        p.trial.Drug.StimTrial = rand(1) > 0.5;

    case {'block', 'b','key','k'}
    %% Blocks of drug injection and and wash-out, includes key trigered block

        if(p.trial.Drug.StimDesign(1) == 'k' && p.trial.Drug.StimTrial == 0)
        % No need to determine block start for keyboard triggered blocks    
            BlockRef = NaN;
        else
            switch p.trial.Drug.StimBlock
                case 'trial'
                    BlockRef = p.trial.pldaps.iTrial;
                    
                case 'time'
                    BlockRef = GetSecs;
                otherwise
                    error('Unknown block definition <%s>!', p.trial.Drug.StimBlock);
            end
        end
        
        % trigger drug delivery block
        if(BlockRef >= p.trial.Drug.BlockStart + p.trial.Drug.BlockLength(2-p.trial.Drug.StimTrial))
            p.trial.Drug.TriggerStim = 1;
        end

        % change block state
        if(p.trial.Drug.TriggerStim == 1)
            p.trial.Drug.StimTrial   = abs(p.trial.Drug.StimTrial - 1);
            p.trial.Drug.TriggerStim = 0;
            
            switch p.trial.Drug.StimBlock
                case 'trial'
                    p.trial.Drug.BlockStart = p.trial.pldaps.iTrial;
                case 'time'
                    p.trial.Drug.BlockStart = GetSecs;
                otherwise
                    error('Unknown block definition <%s>!', p.trial.Drug.StimBlock);
            end
        end

    case {'condition', 'cond', 'c'}
    %% Drug delevery determined by condition
    % not much to do here, p.trial.Drug.StimTrial should be present in the condition struct
    % or it should be set in the trial setup based on condition number

    otherwise  
        error('Drug application design <%s> unknown!', p.trial.Drug.StimDesign );
end

