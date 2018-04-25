function package(projectFile)
% matlab.apputil.package Package an app into an MLAPPINSTALL file.
%
%   matlab.apputil.package(PRJFILE) will create an MLAPPINSTALL file based
%   on the information contained in the project file specified by PRJFILE.
%   The PRJFILE argument is a character vector or string containing the
%   name of the project file to use.  The file can be specified with either
%   an absolute path or a path relative to the current directory.  Use
%   matlab.apputil.create to create the project file.
%
%   See also: matlab.apputil.create, matlab.apputil.install.

% Copyright 2012-2016 The MathWorks, Inc.

narginchk(1,1);

validateattributes(projectFile,{'char','string'},{'scalartext'}, ...
    'matlab.apputil.package','PRJFILE',1)
projectFile = char(projectFile);

fullFileName = matlab.internal.apputil.AppUtil.locateFile(projectFile, ...
    matlab.internal.apputil.AppUtil.ProjectFileExtension);
if isempty(fullFileName)
    error(message('MATLAB:apputil:create:filenotfound', projectFile));
end


validProject = matlab.internal.apputil.AppUtil.validateProjectFile(fullFileName);

if ~validProject
    error(message('MATLAB:apputil:create:invalidproject'));
end

% Open the project using the service
import com.mathworks.toolbox.apps.services.AppsPackagingService;
proj = AppsPackagingService.openAppsProject(fullFileName);

% If this is a pre-R2015b apps project, we need to update output folder
outputParam = AppsPackagingService.getOutputFolder(proj);
[pathstr,~,ext] = fileparts(char(outputParam));
if strcmp(ext,'.mlappinstall')
    AppsPackagingService.setOutputFolder(proj, pathstr);
end

% Package and close the service connection
AppsPackagingService.packageProject(proj);
pause(0.1);
AppsPackagingService.closeProject(proj, false);

