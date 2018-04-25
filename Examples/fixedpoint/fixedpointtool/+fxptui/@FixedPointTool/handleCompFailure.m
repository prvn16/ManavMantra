function handleCompFailure(this)
%HANDLECOMPFAILURE Re-enable the client in the case of engine failures.

% Copyright 2015-2017 The MathWorks, Inc.

    msg = 'EngineCompFailed';
    % Restore system settings on failure
    this.restoreSystemSettings;
    this.reEnableUI(msg);   
end
