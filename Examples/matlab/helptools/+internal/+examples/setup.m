function port = setup()
%Set up and configure the MATLAB Connector in support of Examples Gallery 
%
%   This function is unsupported and might change or be removed without
%   notice in a future version.

%   Copyright 2014-2017 The MathWorks, Inc.

connectorInfo = connector.ensureServiceOn;

connector.isRunning;

port = connectorInfo.securePort;

end
