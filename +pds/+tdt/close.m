function p = close(p)
% Closes the UDP connection to TDT
% Nate Faber, August 2017

if(p.defaultParameters.tdt.use)
    % Only close the object if it exists
    if isfield(p.defaultParameters.tdt, 'UDP')
        delete(p.defaultParameters.tdt.UDP);
    end
end