classdef FileName < internal.matlab.variableeditor.datatype.AbstractFilePath
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Used as a property type for filenames
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        function obj = FileName(varargin)
            obj = obj@internal.matlab.variableeditor.datatype.AbstractFilePath(varargin{:});
        end
    end
    
    methods(Access = protected)
        function valid = validatePath(~, path)
            % a valid file name value is either:
            %   - empty
            %   - on the MATLAB path and includes a file extension
            
            [~, ~, ext] = fileparts(path);
            if isempty(path) || (~isempty(ext) && any(which(path)))
                valid = true;
            else
                error(struct('identifier', 'FileName:FileNotFound', ...
                    'message', ['Could not locate file on MATLAB path: ' path]));
            end
        end
    end
end
