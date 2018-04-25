classdef MLNumericArrayDataModel < internal.matlab.variableeditor.MLArrayDataModel & internal.matlab.variableeditor.NumericArrayDataModel
    %MLNUMERICARRAYDATAMODEL
    %   MATLAB Numeric Array Data Model

    % Copyright 2013 The MathWorks, Inc.

    methods(Access='public')
        % Constructor
        function this = MLNumericArrayDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLArrayDataModel(name, workspace);
        end
    end %methods

    methods(Access='protected')
        % Compares new data to the current data and returns Rows(I) and
        % Columns(J) of Unmatched Values.  Assumes this.Data and newData
        % are the same size.
        %
        % For example, the following inputs returns [1, 3]:
        % this.Data = [1, 2, 3; 4, 5, 6];
        % newData = [1, 2, pi; 4, 5, 6];
        %
        % While these inputs return [[2;1], [2;3]]:
        % this.Data = [1, 2, 3; 4, 5, 6];
        % newData = [1, 2, pi; 4, NaN, 6];
        function [I,J] = doCompare(this, newData)
            [I,J] = find((abs(this.Data-newData)>0) | ...
                (isnan(this.Data)-isnan(newData)));
        end
    end
end
