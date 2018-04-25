function create(projectFile)
% matlab.apputil.create Create a project for packaging an app into an MLAPPINSTALL file.
%
%   matlab.apputil.create will open the app packaging dialog which allows
%   for the creation of an MLAPPINSTALL file.  The dialog gathers necessary
%   information for an app, such as the necessary MATLAB files, author
%   information, and other information about the app.  This information is
%   saved in a PRJ file which can be passed to the matlab.apputil.package
%   function to generate an MLAPPINSTALL file. Alternatively, the dialog
%   can be used to directly create the MLAPPINSTALL file.
%
%   matlab.apputil.create(PRJFILE) will open the app packaging dialog and
%   load the previously created project specified by PRJFILE.  The PRJFILE
%   argument is a character vector or string containing the name of the
%   project file to use. The file can be specified with either an absolute
%   path or a path relative to the current directory.
%
%   See also: matlab.apputil.package.

% Copyright 2012-2016 The MathWorks, Inc.getCurrentProject

narginchk(0,1);

if nargin == 0
    com.mathworks.project.impl.plugin.PluginManager.allowMatlabThreadUse();
    target = com.mathworks.project.impl.plugin.PluginManager.getLicensedTarget('target.mlapps');
    file = com.mathworks.project.impl.Utils.getNextAutoProject(java.io.File(pwd));
    com.mathworks.project.impl.ProjectGUI.getInstance.createAndOpen(file, target);
    return;
end

validateattributes(projectFile,{'char','string'},{'scalartext'}, ...
    'matlab.apputil.create','PRJFILE',1)
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


com.mathworks.project.impl.ProjectGUI.getInstance().open(java.io.File(fullFileName));