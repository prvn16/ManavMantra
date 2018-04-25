function out=openprj(filename)
%OPENPRJ opens a MATLAB Compiler, MATLAB Coder project or Simulink Project. 
%
%   OPENPRJ(FILENAME) opens the MATLAB Compiler, MATLAB Coder project or
%   Simulink Project. If FILENAME is not a valid project file then it is
%   opened in the MATLAB Editor. 
%
%   See also DEPLOYTOOL, MCC, MBUILD, CODER, SIMULINKPROJECT

%   Copyright 2006-2014 The MathWorks, Inc.

out=[];

if ~usejava('swing')
	edit(filename);
    return;
end

% Try opening as a Compiler or Coder project:
try %#ok<TRYNC>
    com.mathworks.project.impl.plugin.PluginManager.allowMatlabThreadUse();
    valid = i_openDeploymentProject(filename, java.io.File(filename));
    if valid
        return
    end
end

% Try opening as a Simulink Project if it is available
isSlProjectAvailable = false;
try %#ok<TRYNC>
    isSlProjectAvailable  = com.mathworks.toolbox.slproject.project.matlab.api.APIAvailable.isAPIAvailable();
end

if isSlProjectAvailable 
    try
        valid = i_openSimulinkProject(filename);
        if valid
            return
        end
    catch exception
        if exception.identifier == "SimulinkProject:api:LoadFail"
            title = DAStudio.message('SimulinkProject:util:OpenPrjErrorTitile');
            error('MATLAB:open:openFailure', '%s\n%s', title, exception.message)
        end
    end
end

% We do not have a product installed that uses this .prj file, so treat it
% like a third-party file.
edit(filename);
return;
end


function valid = i_openDeploymentProject(filename, projectFile)
    % Try to open as a Deployment Project:
    if ~projectFile.isAbsolute()
        projectFile = java.io.File(java.io.File(pwd), filename);
    end

    valid = com.mathworks.project.impl.model.ProjectManager.isProject(projectFile);
    if valid
        com.mathworks.project.impl.DeployTool.invoke(projectFile);
    end
end

function valid = i_openSimulinkProject(filename)

    % Do not use an import here because MATLAB will fail to parse the entire file
    % when the imported class doesn't exist (i.e. slproject not installed)
    valid =  Simulink.ModelManagement.Project.File.PathUtils.loadProjectForOpenPRJ(filename);

end
