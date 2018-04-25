function port = getConnectorPort
%% This will return the port # to which webapp will consume

%   Copyright 2014 The MathWorks, Inc.

    try 
        connectorInfo = connector.ensureServiceOn;
        port = connectorInfo.port;
    catch e
        port = ''
    end
    
end