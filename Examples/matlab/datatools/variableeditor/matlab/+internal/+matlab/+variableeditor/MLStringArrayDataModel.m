classdef MLStringArrayDataModel < internal.matlab.variableeditor.MLArrayDataModel & internal.matlab.variableeditor.StringArrayDataModel
    %MLSTRINGARRAYDATAMODEL
    %   MATLAB String Array Data Model

    % Copyright 2015 The MathWorks, Inc.

    methods(Access='public')
        % Constructor
        function this = MLStringArrayDataModel(name, workspace)
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
            [I,J] = find(this.Data~=newData);
        end
    end
end


