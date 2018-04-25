classdef AbstractFilePath
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Used as a property type for file paths
    
    % Copyright 2017 The MathWorks, Inc.

    properties(Access = private)
        Path;
    end
    
    methods
        function obj = AbstractFilePath(path)
            if obj.validatePath(path)
                obj.Path = path;
            end
        end
        
        function v = getPath(this)
            v = this.Path;
        end
    end
    
    methods(Abstract, Access = protected)
        valid = validatePath(this, path)
    end
end

