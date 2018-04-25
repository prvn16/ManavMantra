function setLoggingOnOutports(this, state)
% SETLOGGIGNONOUTPORTS Set signal logging for the outports in this system

% Copyright 2013 MathWorks, Inc.
%    Date: $

    outports = get_param(this.DAObject.PortHandles.Outport, 'Object');
    for idx = 1:numel(outports)
        port = outports(idx);
        if(iscell(port)); port = port{:}; end
        port.DataLogging = state;
    end
end
