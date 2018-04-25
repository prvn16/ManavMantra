function sameNameRunning = isSameNameAppRunning(fullFileName, currentApp)
    % Check if there's another same name app from different folder
    % already running
    % fullFileName: app full file name
    % currentApp: the running instance of the app from fullFileName.
    %             It's usually passed in from App Designer, which could be
    %             empty

    % Copyright 2016 - 2017 The MathWorks, Inc.
    sameNameRunning = false;

    [~, appName] = fileparts(fullFileName);

    % Get all running app figures who have a property -
    % RunningAppInstance - pointing to the running app object
    runningAppFigures = findall(0, 'Type', 'figure', '-property', 'RunningAppInstance');
    
    if ~isempty(runningAppFigures)
        for ix = 1:numel(runningAppFigures)
            runningAppInstance = runningAppFigures(ix).RunningAppInstance;
            runningAppFullFileName = runningAppFigures(ix).RunningAppFullFileName;
            
            if (isempty(currentApp) || runningAppInstance ~= currentApp) && ...
                    strcmp(class(runningAppInstance), appName) && ...
                    ((~ispc && ~strcmp(runningAppFullFileName, fullFileName)) || ... 
                    (ispc && ~strcmpi(runningAppFullFileName, fullFileName))) % Ignore case on windows
                % Need to filter out the current app that is running from the
                % fullFileName. It happens the user runs the app in App Designer
                % without closing the running one
                % If currentApp is empty - not running, not equal checking
                % returns an empty logical array instead of a scalar logical
                % value, not being abled to be used as conditional value,
                % thus checking currentApp empty first.
                %
                % If there's a running app object with the same name and
                % it's from a different folder
                sameNameRunning = true;
                return;
            end
        end
    end
end