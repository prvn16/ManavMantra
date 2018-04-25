function ret = enableservice(service, status)
%ENABLESERVICE Enable, disable, or report status of
%   Automation server; enable DDE server.
%
%   STATE = ENABLESERVICE('AutomationServer', ENABLE) Enables the
%   Automation server where ENABLE is a logical input that enables or
%   disables the service. STATE indicates the previous state of the
%   Automation server.
%   
%   ENABLESERVICE('AutomationServer') returns the current state of the
%   Automation server.
%
%   ENABLESERVICE('DDEServer', true) Enables MATLAB DDE server. Please
%   note that this service cannot be disabled after this command is called.
%   The outgoing MATLAB DDE commands (ddeinit, ddeterm, ddeexec, ddereq,
%   ddeadv, ddeunadv, ddepoke) function normally without the MATLAB DDE
%   server. Only acceptable input for STATUS is "true".

% Copyright 2006 The MathWorks, Inc.

% first check number of arguments
narginchk(0,2);

if (~ischar(service) || (nargin > 1) && (~islogical(status)))
    error(message('MATLAB:enableservice:InvalidInput'));
end

switch lower(service)
    
    case 'ddeserver'
        narginchk(2,2);
        if (~status)
            error('MATLAB:enableservice:InvalidInput','%s', getString(message('MATLAB:enableservice:InvalidInput2')));
        end
        feature('EnableDDE', 1)
        
    case 'automationserver'
        if(nargin == 1)
            ret = feature('AutomationServer');
        elseif(status)
            ret = feature('AutomationServer', 1);
        else
            ret = feature('AutomationServer', 0);
        end
    otherwise
        error(message('MATLAB:enableservice:InvalidService'));
end
