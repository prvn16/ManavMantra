% installToolbox Install a .mltbx file
%
%   INSTALLEDTOOLBOX = matlab.addons.toolbox.installToolbox(FILENAME,
%   AGREEDTOLICENSE) installs the .mltbx file specified by the FILENAME
%   argument. The FILENAME argument is either a scalar string or a char row
%   vector containing the name of the file to install.  The file is
%   specified with either an absolute path or a path relative to the
%   current folder.
%
%   AGREEDTOLICENSE is a logical value indicating acceptance of the license
%   agreement. If AGREEDTOLICENSE is not specified, it is FALSE by default.
%
%   If AGREEDTOLICENSE is FALSE and the toolbox contains a license
%   agreement, MATLAB displays a dialog prompting to agree to the licensing
%   terms or cancel installation. If AGREEDTOLICENSE is TRUE and the
%   toolbox contains a license agreement, MATLAB installs the toolbox
%   without opening the license agreement dialog. By setting
%   AGREEDTOLICENSE to true, you accept the terms of the license agreement.
%   Be sure that you have reviewed the license agreement before installing
%   the toolbox.
%
%   AGREEDTOLICENSE has no effect on a toolbox that has no license
%   agreement.
%
%   INSTALLEDTOOLBOX is a struct that contains information about the
%   toolbox.  The matlab.addons.toolbox.installedToolboxes function
%   documents the fields of this struct.
%
%   Examples: 1. Install toolbox.
%
%       matlab.addons.toolbox.installToolbox('C:\Downloads\MyToolbox.mltbx')
%
%       ans =
%
%           Name: 'MyToolbox'
%        Version: '1.0'
%           Guid: 'my-toolbox-identifier-guid'
%
%   2. Install toolbox with license agreement and bypass license agreement
%   dialog.
%
%       matlab.addons.toolbox.installToolbox('C:\Downloads\MyToolbox.mltbx',
%       true)
%
%       ans =
%
%           Name: 'MyToolbox'
%        Version: '1.0'
%           Guid: 'my-toolbox-identifier-guid'
%
%   See also: matlab.addons.toolbox.installedToolboxes,
%   matlab.addons.toolbox.packageToolbox,
%   matlab.addons.toolbox.toolboxVersion,
%   matlab.addons.toolbox.uninstallToolbox.


% Copyright 2015 The MathWorks, Inc.

