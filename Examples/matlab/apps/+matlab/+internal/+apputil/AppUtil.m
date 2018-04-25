classdef AppUtil
% Internal class for minor utility functions used by the matlab.apputil
% package.

% Copyright 2012 - 2015 The MathWorks, Inc.
    
    properties (Constant)
        % The current extension for MATLAB App install files
        FileExtension = '.mlappinstall';
        ProjectFileExtension = '.prj';
    end
    
    methods (Static)
        function appid = makeAppID(dirname)
        % Convert an app location into an APPID.
            appid = [dirname 'APP'];
        end
        
        function valid = validateProjectFile(projectFile)
            javaProjectFile = java.io.File(projectFile);
            result = com.mathworks.project.impl.model.ProjectManager.getTarget(javaProjectFile);
            valid = ~isempty(result);            
        end
        
        function fullFileName = locateFile(filename, extension)
            % Append the file extension if not specified.
            [~, ~, ext] = fileparts(filename);
            
            if ~strcmpi(ext, extension)
                filename = [filename extension];
            end
            
            [stat, info] = fileattrib(filename);
            
            fullFileName = [];
            
            if stat
                fullFileName = info.Name;
            end
        end
        
        function indices = findAppIDs(installedIDs, id, strict)
            validateattributes(installedIDs, {'cell'}, {'nonempty'});
            validateattributes(id, {'char'}, {'nonempty'});
            if strict
                indices = strcmp(id, installedIDs);
            else
                indices = strncmpi(id, installedIDs, length(id));
            end
        end
        
        function wrapperfilename = genwrapperfilename(codedirinappinstallfolder)
            % Get App install root folder name given the path to the code
            % folder
            [~, appdir, ~] = fileparts(fileparts(codedirinappinstallfolder));
            wrapperfilename = genvarname(appdir);
        end
    end
    
end

