classdef MLCalendarDurationArrayDataModel < internal.matlab.variableeditor.MLArrayDataModel & internal.matlab.variableeditor.CalendarDurationArrayDataModel
    %MLCALENDARDURATIONARRAYDATAMODEL
    %   MATLAB Calendar Duration Array Data Model

    % Copyright 2015 The MathWorks, Inc.        
    methods(Access='public')
        % Constructor
        function this = MLCalendarDurationArrayDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLArrayDataModel(name, workspace);
        end
        
        % setData
        % Sets a block of values.
        % If only one paramter is specified that parameter is assumed to be
        % the data and all of the data is replaced by that value.
        % If three paramters are passed in the the first value is assumed
        % to be the data and the second is the row and third the column.
        % Otherwise users can specify value index pairings in the form
        % setData('value', index1, 'value2', index2, ...)
        %
        %  The return values from this method are the formatted command
        %  string to be executed to make the change in the variable.
        function varargout = setData(this,varargin)
            setStrings = this.setData@internal.matlab.variableeditor.CalendarDurationArrayDataModel(varargin{:});

            % Evaluate any MATLAB changes (TODO: Remove when LXE is in)
            if ~isempty(setStrings)
                setCommands = cell(1,length(setStrings));
                for i=1:length(setStrings)
                    setCommands{i} = this.executeSetCommand(setStrings{i});
                end
                varargout{1} = setCommands;
            end
        end
        
        % updateData
        function data = updateData(this, varargin)
            newData = varargin{1};
            origData = this.Data;
            
            % Only update the data if the formats are different and the
            % values are the same.
            if isequal(size(origData), size(newData)) && isequaln(origData,newData)
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
                
                % Set the new data
                this.Data = newData;
                
                % The eventData Values property should represent the data
                % that has changed within the cached this.Data block as it 
                % is rendered. Currently the cached data may be huge, so
                % for now don't attempt to represent it.
                % If the format of the calendar duration has changed, pass
                % back empty, which will trigger the client to refresh its
                % view.
                origFormat  = origData.Format;
                newFormat    = newData.Format;
                if ~strcmp(origFormat, newFormat)
                    eventdata.Values = [];
                    this.notify('DataChange',eventdata);
                end
            else % If the data is different, the superclass will handle it.
                this.updateData@internal.matlab.variableeditor.MLArrayDataModel(varargin{1});
            end
            data = this.Data;
        end
    end %methods

    methods(Access='protected')
        % Compares new data to the current data and returns Rows(I) and
        % Columns(J) of Unmatched Values.  Assumes this.Data and newData
        % are the same size.
        %
        % For example, the following inputs returns [1, 3]:
        % this.Data = [01:01:01, 02:02:02, 03:03:03; 04:04:04, 05:05:05, 06:06:06];
        % newData   = [01:01:01, 02:02:02, 13:03:03; 04:04:04, 05:05:05, 06:06:06];
        %
        % While these inputs return [[2;1], [2;3]]:
        % this.Data = [01:01:01, 02:02:02, 03:03:03; 04:04:04, 05:05:05, 06:06:06];
        % newData   = [01:01:01, 02:02:02, 13:03:03; 04:04:04,   NaN   , 06:06:06];
        %
        % This only checks if the year, month, day, and time are identical.
        % It does not try to check if two different calendarDurations are
        % equivalent.
        function [I,J] = doCompare(this, newData)
            [I,J] = find((this.compToZero(this.Data-newData)) | ...
                (isnan(this.Data)-isnan(newData)));
        end
    end
    
    methods(Access='private')
        function idx = compToZero(~, calDur)
            [y, m, d, t] = split(calDur, {'Year', 'Month', 'Day', 'Time'});
            y = abs(y);
            m = abs(m);
            d = abs(d);
            t = abs(t);
            idx = y > 0 | m > 0 | d > 0 | t > 0;
        end
    end
end
