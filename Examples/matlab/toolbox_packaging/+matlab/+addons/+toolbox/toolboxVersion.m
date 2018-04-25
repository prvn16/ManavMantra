function [existingVersion] = toolboxVersion(toolboxFile, newVersion)
%TOOLBOXVERSION Query and modify the version of a toolbox file
%   [VERSION] = TOOLBOXVERSION(TOOLBOXFILE) queries the TOOLBOXFILE for the
%   current version number.  TOOLBOXFILE can be a toolbox project (PRJ) or
%   a MATLAB toolbox (MLTBX).
%
%   [VERSION] = TOOLBOXVERSION(TOOLBOXFILE, NEW_VERSION) sets the version 
%   number of the TOOLBOXFILE and returns the previous VERSION. TOOLBOXFILE
%   can be a toolbox project (PRJ) only.
%
%   Examples:
%     % Query the current version number of an MLTBX file:
%     current_version = matlab.addons.toolbox.toolboxVersion('toolbox.mltbx');
%
%     % Set the current version number of a toolbox project file:
%     old_version = matlab.addons.toolbox.toolboxVersion('toolbox.prj','1.1');
%
%   See also matlab.addons.toolbox.packageToolbox, matlab.addons.toolbox.installToolbox, 
%   matlab.addons.toolbox.installedToolboxes, matlab.addons.toolbox.uninstallToolbox
%
%   Copyright 2016 The MathWorks, Inc.

    narginchk(1,2);

    % Verify the file exists 
    validateattributes(toolboxFile,{'char','string'},{'scalartext'}, ...
        'matlab.addons.toolbox.toolboxVersion','ToolboxFile',1)
    toolboxFile = char(toolboxFile);
    if exist(toolboxFile, 'file') ~= 2
        error(message('MATLAB:toolbox_packaging:packaging:ToolboxFileNotFound',toolboxFile));
    end
    
    % Validate 2nd input
    if nargin > 1
        validateattributes(newVersion,{'char','string'},{'scalartext'}, ...
            'matlab.addons.toolbox.toolboxVersion','Version',2)
        newVersion = char(newVersion);
    end

    % Get the absolute path to the file in case it was input as a relative path
    if ~java.io.File(toolboxFile).isAbsolute
        toolboxFile = fullfile(pwd,toolboxFile);
    end

    [~,~,ext] = fileparts(toolboxFile);
    switch lower(ext)
        case '.prj'
            service = com.mathworks.toolbox_packaging.services.ToolboxPackagingService;
            
            % Load the project
            try
                configKey = service.openProject(toolboxFile);
                c = onCleanup(@()service.closeProject(configKey));
            catch e
                error(message('MATLAB:toolbox_packaging:packaging:InvalidToolboxProjectFile',toolboxFile));
            end
            
            % Fetch the current version
            existingVersion = char(service.getVersion(configKey));
            
            % Set the version if the user requested it
            if nargin == 2
                try
                    service.setVersion(configKey, newVersion);
                catch e
                    error(message('MATLAB:toolbox_packaging:packaging:InvalidToolboxVersion', newVersion));
                end
                if (~service.save(configKey))
                    error(message('MATLAB:toolbox_packaging:packaging:SaveFailed', toolboxFile));
                end
            end
            
        case '.mltbx'
            if nargin == 2
                error(message('MATLAB:toolbox_packaging:packaging:CannotSetVersionOnMLTBX'));
            end
            
            % Dig into the metadata of the mltbx to fetch the version
            try
                metadata = mlAddonGetProperties(toolboxFile);
                existingVersion = metadata.version;
            catch e
                error(message('MATLAB:toolbox_packaging:packaging:InvalidToolboxFile',toolboxFile));
            end
            
        otherwise
            error(message('MATLAB:toolbox_packaging:packaging:InvalidFile',toolboxFile));
    end

end

