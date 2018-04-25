% installedToolboxes Return information about installed toolboxes
%
%   TOOLBOXES =  matlab.addons.toolbox.installedToolboxes returns a struct
%   array, TOOLBOXES, containing information about the currently installed
%   toolboxes. Each struct contains the following fields:
%
%         Name - Name of the toolbox
%      Version - Version of the toolbox
%         Guid - Unique identifier representing the toolbox
%
%   Example: Install toolbox and display its information.
%
%       matlab.addons.toolbox.installToolbox('C:\Downloads\MyToolbox.mltbx');
%
%       matlab.addons.toolbox.installedToolboxes
%
%       ans =
%
%           Name: 'MyToolbox'
%        Version: '1.0'
%           Guid: 'my-toolbox-identifier-guid'
%
%   See also: matlab.addons.toolbox.installToolbox,
%   matlab.addons.toolbox.packageToolbox,
%   matlab.addons.toolbox.toolboxVersion,
%   matlab.addons.toolbox.uninstallToolbox.

 
% Copyright 2015 The MathWorks, Inc.

