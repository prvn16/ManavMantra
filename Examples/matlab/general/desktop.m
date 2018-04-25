function varargout = desktop(option)
%DESKTOP Start and query the MATLAB Desktop.
%   DESKTOP starts the MATLAB Desktop using the configuration
%   stored the last time the Desktop was run, or the default
%   configuration if no configuration file is present.
%
%   DESKTOP -NORESTORE doesn't restore the configuration from the last
%   time the desktop was run.
%
%   USED = DESKTOP('-inuse') returns whether or not the Desktop is
%   currently in use.  It does not start the Desktop.
%
%   See also JAVACHK, USEJAVA.

%   Copyright 1984-2016 The MathWorks, Inc.


% Check for required level of Java support
error(javachk('swing', mfilename));

%Launch the Desktop
if nargin>0
    if strcmp(option,'-norestore')
        try
            com.mathworks.mde.desk.MLDesktop.getInstance.useAsynchronousStartup(0);
            com.mathworks.mde.desk.MLDesktop.getInstance.initMainFrame(0, 0);
        catch
            error(message('MATLAB:desktop:DesktopFailure'));
        end
    elseif strcmp(option, '-inuse')
        try
            varargout{1} = com.mathworks.mde.desk.MLDesktop.getInstance.hasMainFrame;
        catch
            error(message('MATLAB:desktop:DesktopQueryFailure'));
        end
    else
        error(message('MATLAB:desktop:FirstArgInvalid'));
    end
else
    try
        com.mathworks.mde.desk.MLDesktop.getInstance.useAsynchronousStartup(0);
        com.mathworks.mde.desk.MLDesktop.getInstance.initMainFrame(0, 1);
    catch
        error(message('MATLAB:desktop:DesktopFailure'));
    end
end
