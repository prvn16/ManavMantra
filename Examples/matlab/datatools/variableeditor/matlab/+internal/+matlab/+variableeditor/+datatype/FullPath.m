classdef FullPath < internal.matlab.variableeditor.datatype.AbstractFilePath
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Used as a property type for full paths
    
    % Copyright 2017 The MathWorks, Inc.

    methods
        function obj = FullPath(varargin)
            obj = obj@internal.matlab.variableeditor.datatype.AbstractFilePath(varargin{:});
        end
    end
    
    methods(Access = protected)
        function valid = validatePath(~, path)
            % a valid full path value is either:
            %   - empty
            %   - on the MATLAB path, so any(which(path)) && isequal(path, which(path))
            %   - not on the path, so ~any(which(path)) && exists(path, 'file')
            
            if isempty(path) ... 
                    || isequal(path, which(path)) ...
                    || (~any(which(path)) && exist(path, 'file'))
                valid = true;
            else
                error(struct('identifier', 'FullPath:FileNotFound', ...
                    'message', ['Could not locate file: ' path]));
            end
        end
    end
end
