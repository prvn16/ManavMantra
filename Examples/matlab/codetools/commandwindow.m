function commandwindow
%COMMANDWINDOW Open Command Window, or select it if already open
%   COMMANDWINDOW Opens the Command Window or brings the Command Window
%   to the front if it is already open.
%
%   See also DESKTOP.

%   Copyright 1984-2008 The MathWorks, Inc. 

try
    % Launch Java Command Window
    if usejava('desktop') %desktop mode
        % This means we are running the desktop so bring up MDE Java Command Window
        com.mathworks.mde.desk.MLDesktop.getInstance.showCommandWindow;    
    end
catch
    % Failed. Bail
    error(message('MATLAB:commandwindow:commandWindowFailed'));
end
