% uninstallToolbox Uninstall an installed toolbox
%
%   matlab.addons.toolbox.uninstallToolbox(INSTALLEDTOOLBOX) uninstalls the
%   specified toolbox. All files and folders associated with the toolbox
%   are removed from the path and then deleted.
%
%   INSTALLEDTOOLBOX is a struct with the toolbox information.  This struct
%   is the element of the array returned from the
%   matlab.addons.toolbox.installedToolboxes function and corresponds to
%   the toolbox to uninstall. MATLAB uses the unique identifier in the Guid
%   field to determine which toolbox to uninstall.
%
%   If the uninstall is successful, there is no output from the function.
%   Otherwise, MATLAB displays an error.
%
%   Example: Remove a previous installed toolbox
%
%       installed =
%       matlab.addons.toolbox.installToolbox('C:\Downloads\MyToolbox.mltbx');
%
%       matlab.addons.toolbox.uninstallToolbox(installed)
%
%   See also: matlab.addons.toolbox.installToolbox,
%   matlab.addons.toolbox.installedToolboxes,
%   matlab.addons.toolbox.packageToolbox,
%   matlab.addons.toolbox.toolboxVersion.

 
% Copyright 2015 The MathWorks, Inc.

