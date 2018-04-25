classdef MLObjectArrayDataModel < ...
        internal.matlab.variableeditor.MLArrayDataModel & ...
        internal.matlab.variableeditor.ObjectArrayDataModel
    %MLOBJECTARRAYDATAMODEL
    % MATLAB Object Array Data Model
    %
    % Copyright 2015 The MathWorks, Inc.

    methods
        % Constructor
        function this = MLObjectArrayDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLArrayDataModel(...
                name, workspace);
        end
    end
    
    methods (Access = protected)
        function [I,J] = doCompare(this, newData)
            [I,J] = find(arrayfun(@(a,b) ~isequal(a,b), ...
                this.Data, newData));
        end
    end
end
