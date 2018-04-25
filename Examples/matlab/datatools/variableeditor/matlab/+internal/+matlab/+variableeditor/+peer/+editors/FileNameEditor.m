classdef FileNameEditor < ...
        internal.matlab.variableeditor.peer.editors.AbstractFilePathConverter
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % FileName EditorConverter class. This class allows the client to
    % trigger file browsing on the server side
    
    % Copyright 2017 The MathWorks, Inc.

    methods
        % Called to set the client-side value
        function setClientValue(this, value)
            if ~isempty(value) && value(1) == this.BROWSE_CHAR
                args = this.getArgs(value);
                [fileName, pathName] = uigetfile(args{:});
                
                if fileName
                    % make sure file is on MATLAB path
                    if which([pathName fileName])
                        % set value to shortest path for selected file
                        % (makes sure 'which' still finds chosen file)
                        this.value = this.shortestPath(pathName, fileName);
                    else
                        % if not on path, display full path in error
                        this.value = [pathName fileName];
                    end
                end
            else
                % set value to shortest path for user-entered file
                [pathstr, name, ext] = fileparts(value);
                this.value = this.shortestPath(pathstr, [name ext]);
            end
        end
    end
    
    methods(Access = protected)
        % gets shortest file path that is found by 'which'
        function filePath = shortestPath(~, pathstr, filePath)
            if ~any(which(fullfile(pathstr, filePath)))
                % if not found, return full path (for error message)
                filePath = fullfile(pathstr, filePath);
                return;
            end
            
            pathstr = regexprep(pathstr, '[/\\]$', ''); % strip end filesep
            while ~isequal(which(fullfile(pathstr, filePath)), which(filePath))
                % add folders to filePath while which(filePath) finds a
                % different file
                
                [pathstr, folderName] = fileparts(pathstr);
                if isempty(folderName)
                    break;
                end

                filePath = fullfile(folderName, filePath);
            end
        end
    end
end
