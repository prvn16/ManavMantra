function commandhistory
%COMMANDHISTORY Open Command History window, or select it if already open
%   COMMANDHISTORY Opens the Command History window or brings the Command
%   History window to the front if it is already open.

%   Copyright 1984-2013 The MathWorks, Inc. 

% Make sure that we can support the Command History window on this platform.
error(javachk('swing', mfilename));

try
    % Launch Command History window
    com.mathworks.mde.desk.MLDesktop.getInstance.showCommandHistory;
catch
    error(message('MATLAB:cmdhist:CmdHistFailed'));
end
