classdef MLDatetimeArrayDataModel < internal.matlab.variableeditor.MLArrayDataModel & ...
        internal.matlab.variableeditor.DatetimeArrayDataModel
    %MLDATETIMEARRAYDATAMODEL
    %   MATLAB Datetime Array Data Model

    % Copyright 2015 The MathWorks, Inc.

    methods(Access='public')
        % Constructor
        function this = MLDatetimeArrayDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLArrayDataModel(name, workspace);
        end
        
        % updateData
        function data = updateData(this, varargin)
            newData = varargin{1};
            origData = this.Data;
            data = newData;
            % Only update the data if the format or time zone has changed.
            origFormat   = origData.Format;
            origTimeZone = origData.TimeZone;
            newFormat    = newData.Format;
            newTimeZone  = newData.TimeZone;
            if ~strcmp(origTimeZone, newTimeZone) || ...
                (isequal(size(origData), size(newData)) && ~strcmp(origFormat, newFormat))
                % Set the new data
                this.Data = newData;
                % Create an array the same size as newData
                % using meshgrid, so the result is viewed as all of the
                % data changed.
                %
                % Revisit: This may be too big to transfer to the
                % client when the variable is large
                % G1005445: using the max in order to handle the case
                % for switching between scalar and non-scalar
                eventdata = internal.matlab.variableeditor.DataChangeEventData;
                [I,J] = meshgrid(1:max(size(origData,1),size(newData,1)),1:max(size(origData,2),size(newData,2)));
                I = I(:)';
                J = J(:)';
                eventdata.Range = [I;J];
                eventdata.Values = [];
                this.notify('DataChange',eventdata);
            else
                data = this.updateData@internal.matlab.variableeditor.MLArrayDataModel(varargin{:});
            end
        end
    end %methods

    methods(Access='protected')
        % Compares new data to the current data and returns Rows(I) and
        % Columns(J) of Unmatched Values.  Assumes this.Data and newData
        % are the same size.
        %
        % For example, the following inputs returns [1, 3]:
        % this.Data = [01-Jan-2015, 01-Feb-2015, 01-Mar-2015; 01-Apr-2015, 01-May-2015, 01-Jun-2015];
        % newData   = [01-Jan-2015, 01-Feb-2015, 02-Mar-2015; 01-Apr-2015, 01-May-2015, 01-Jun-2015];
        %
        % While these inputs return [[2;1], [2;3]]:
        % this.Data = [01-Jan-2015, 01-Feb-2015, 01-Mar-2015; 01-Apr-2015, 01-May-2015, 01-Jun-2015];
        % newData   = [01-Jan-2015, 01-Feb-2015, 02-Mar-2015; 01-Apr-2015,    NaT     , 01-Jun-2015];
        function [I,J] = doCompare(this, newData)
            [I,J] = find((abs(this.Data-newData)>0) | ...
                (isnat(this.Data)-isnat(newData)));
        end
    end
end
