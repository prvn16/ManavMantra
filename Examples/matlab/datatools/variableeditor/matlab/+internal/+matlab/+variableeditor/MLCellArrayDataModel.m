classdef MLCellArrayDataModel < internal.matlab.variableeditor.MLArrayDataModel & internal.matlab.variableeditor.CellArrayDataModel
    %MLCellARRAYDATAMODEL
    %   MATLAB Cell Array Data Model

    % Copyright 2014-2015 The MathWorks, Inc.

    methods(Access='public')
        % Constructor
        function this = MLCellArrayDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLArrayDataModel(name, workspace);
        end
    end %methods
    
    methods(Access='protected')
        function [I,J] = doCompare(this, newData)
            [I,J] = find(cellfun(@(a,b) ~isequal(a,b), this.Data, newData));
        end
    end
end
