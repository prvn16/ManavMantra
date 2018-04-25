function appCodeTool = getAppCodeTool()
%GETAPPCODETOOL Internal function to guarantee only one 
% AppCodeTool will be used
%
% GETAPPCODETOOL uses local persistent variable to make sure
% only one instance of AppCodeTool through the MATLAB session

% Copyright 2015 The MathWorks, Inc.

% Make the AppCodeTool have only one instance via 
% a persistent variable
persistent localAppCodeTool;
if isempty(localAppCodeTool) || ~isvalid(localAppCodeTool)
    
    % Get AppDesignEnvironment instance which is only one through the
    % MATLAB session to represent App Designer
    appDesignEnvironment = appdesigner.internal.application.getAppDesignEnvironment();          
    
    % Create AppCodeTool 
    localAppCodeTool = appdesigner.internal.application.AppCodeTool(appDesignEnvironment);
    
    addlistener(appDesignEnvironment,'ObjectBeingDestroyed', ...
            @(source, event)delete(localAppCodeTool));    
end

appCodeTool = localAppCodeTool;

% put a lock on the instance so this instance cannot be cleared by a
% "clear all".
mlock;

end

