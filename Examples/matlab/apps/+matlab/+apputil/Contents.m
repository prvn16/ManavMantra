% matlab.apputil Summary of the MATLAB Apps programmatic interface 
%
% The matlab.apputil package is a collection of utilities for
% programmatically working with MATLAB Apps and MATLAB App installation
% files.  It contains functionality for creating mlappinstall files as well
% installing and uninstalling them.  Functions are also provided to run
% apps and find information about all installed apps.
%
% Create MATLAB App install files:
%  matlab.apputil.create              - Launch the UI to define the contents of an app.
%  matlab.apputil.package             - Use the prj file produced by create to generate a new mlappinstall file.
%
% Work with installed apps:
%   matlab.apputil.getInstalledAppInfo - Find information about the currently installed apps.
%   matlab.apputil.run                 - Run an installed app.
%
% Manage which apps are installed:
%   matlab.apputil.install             - Install the app contained in an mlappinstall file.
%   matlab.apputil.uninstall           - Uninstall a previously installed app.

% Copyright 2012 The MathWorks, Inc.
