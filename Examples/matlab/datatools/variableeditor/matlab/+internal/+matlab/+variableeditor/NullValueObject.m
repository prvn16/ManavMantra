classdef NullValueObject < handle & matlab.mixin.CustomDisplay
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Empty class to represent an empty value
    
    % Copyright 2017 The MathWorks, Inc.
    properties(Access = private)
        varName;
    end
    
    methods(Access = public)
        function this = NullValueObject(varName)
            % varName is the variable name used in displaying the
            % "non-existent" variable message
            this.varName = varName;
        end
    end

    methods (Access = protected)
        function displayScalarObject(this)
            % Display a non-existent variable message
            disp(message('MATLAB:codetools:variableeditor:NonExistentVariable', ...
                this.varName).getString)
        end
    end
end
