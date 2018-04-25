function packageToolbox(toolboxProjectLocation, outputFilename)
%PACKAGETOOLBOX Package a toolbox project 
%   PACKAGETOOLBOX(PROJECTFILE) packages the PROJECTFILE into a MATLAB 
%   toolbox (MLTBX) of the same name.  PROJECTFILE can be either a 
%   relative or absolute path to the toolbox project (PRJ).  
%
%   PACKAGETOOLBOX(PROJECTFILE, OUTPUTFILE) packages the PROJECTFILE into a  
%   MATLAB toolbox file (MLTBX) at the location of the OUTPUTFILE.      
%   PROJECTFILE and OUTPUTFILE can be either a relative or absolute path.
%   If the OUTPUTFILE does not have the extension .mltbx, it will be
%   appended automatically.   
%
%   See also matlab.addons.toolbox.toolboxVersion, matlab.addons.toolbox.installToolbox, 
%   matlab.addons.toolbox.installedToolboxes, matlab.addons.toolbox.uninstallToolbox
%
%   Copyright 2016 The MathWorks, Inc.
    
    narginchk(1,2);
    
    % Verify the projectFile exists 
    validateattributes(toolboxProjectLocation, ...
        {'char','string'},{'scalartext'}, ...
        'matlab.addons.toolbox.packageToolbox','ProjectFile',1)
    toolboxProjectLocation = char(toolboxProjectLocation);
    if exist(toolboxProjectLocation, 'file') ~= 2
        error(message('MATLAB:toolbox_packaging:packaging:ToolboxFileNotFound',toolboxProjectLocation));
    end
    
    % Validate 2nd input
    if nargin > 1
        validateattributes(outputFilename, ...
            {'char','string'},{'scalartext'}, ...
            'matlab.addons.toolbox.packageToolbox','OutputFile',2)
        outputFilename = char(outputFilename);
        validateattributes(outputFilename,{'char'},{'nonempty'}, ...
            'matlab.addons.toolbox.packageToolbox','OutputFile',2)
    end
    
    service = com.mathworks.toolbox_packaging.services.ToolboxPackagingService;
            
    % Get the absolute path to the file in case it was input as a relative path
    if ~java.io.File(toolboxProjectLocation).isAbsolute
        toolboxProjectLocation = fullfile(pwd,toolboxProjectLocation);
    end

    % Open the project and package it
    try
        configKey = service.openProject(toolboxProjectLocation);
        %close the project without saving it - no edits to save
        c = onCleanup(@()service.closeProject(configKey, false));
    catch e
        error(message('MATLAB:toolbox_packaging:packaging:InvalidToolboxProjectFile',toolboxProjectLocation));
    end
     
    % Set up the output file if needed, then do the package operation
    try
        if nargin == 2
            % If the input file is relative, we need to append pwd
            if ~java.io.File(outputFilename).isAbsolute
                outputFilename = fullfile(pwd,outputFilename);
            end
            % If the output file doesn't specify an mltbx extension, we will
            % automatically tack one on
            [~, ~, ext] = fileparts(outputFilename);
            if ~strcmpi(ext,'.mltbx')
                outputFilename = [outputFilename '.mltbx'];
            end
            service.packageProject(configKey, outputFilename);
        else
            service.packageProject(configKey);
        end
    catch e
        if isa(e,'matlab.exception.JavaException')
            % The project either wasn't ready to package or the packaging
            % operation itself failed - the exception object message tells us
            msg = char(e.ExceptionObject().getMessage());
            if isempty(msg)
                msg = message('MATLAB:toolbox_packaging:packaging:UnknownError').getString();
            end
            error(message( ...
                'MATLAB:toolbox_packaging:packaging:PackagingError', ...
                toolboxProjectLocation, ...
                msg));    
        else
            % Rethrow any MATLAB exceptions
            throw(e);
        end
    end
end
