classdef MLCharArrayDataModel < internal.matlab.variableeditor.MLArrayDataModel & internal.matlab.variableeditor.CharArrayDataModel
    %MLCHARARRAYDATAMODEL
    %   MATLAB Char Array Data Model

    % Copyright 2014 The MathWorks, Inc.

    methods(Access='public')
        % Constructor
        function this = MLCharArrayDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLArrayDataModel(name, workspace);
        end
    end %methods

    methods(Access='protected')
        % Compares new data to the current data and returns Rows(I) and
        % Columns(J) of Unmatched Values.  Assumes this.Data and newData
        % are the same size.
        %
		% called only when the data is changed. In this case since there 
		% is just one cell, changed data always has the same indices. So the
		% entire view can be refreshed.
		% Note: I,J cannot be 1 (though one cell only is changed) since the data
		% and view model have different dimensions for char arrays in VE
		% Eg: c = 'hello' 
		% size in view model is 1x1
		% size in data model is 1x5
        function [I,J] = doCompare(this, newData)
                I = [];
                J = [];
        end
        
		% returns the indexing on the left hand side. Eg: In, a(1,1) = 10, 
		% it provides the '(1,1)' string. For char arrays it is just the 
		% variable name since it is always a 1x1 cell view
        function lhs = getLHS(~, ~)
            lhs = '';
        end
    end
end


