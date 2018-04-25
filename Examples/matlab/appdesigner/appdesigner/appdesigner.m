function appdesigner(inputFileNameOrPath)
% APPDESIGNER  Open App Designer.
%
% APPDESIGNER opens App Designer and creates a new app with the default
% name, App1.
%
% APPDESIGNER(filespec) opens App Designer and the file specified by
% 'filespec'. The 'filespec' must be the full path to the file, or a
% partial path or file name on the MATLAB search path.
%
% If App Designer is already open, all variations of the appdesigner
% syntax make App Designer visible and raise it on the screen.
%
% If a specified file is already open, the tab of the specified app
% gets focus.

% Copyright 2014 - 2017 The MathWorks, Inc.

filePath = '';
if (nargin == 1)
    % validate the fileName, and get the valid full filename
    filePath = appdesigner.internal.application.getValidatedInputAppFileName(inputFileNameOrPath);    
end

appDesignEnvironment = appdesigner.internal.application.getAppDesignEnvironment();
if isempty(filePath)
    % Launch/Bring to front App Designer
    appDesignEnvironment.startAppDesigner();
else
    % Open the app in App Designer and brings it to front
    appDesignEnvironment.openApp(filePath);
end

end