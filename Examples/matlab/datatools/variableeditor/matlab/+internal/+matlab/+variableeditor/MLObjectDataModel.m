classdef MLObjectDataModel < internal.matlab.variableeditor.MLArrayDataModel ...
        & internal.matlab.variableeditor.ObjectDataModel
    % MLOBJECTDATAMODEL MATLAB Object Data Model
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods(Access = public)
        % Constructor
        function this = MLObjectDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLArrayDataModel(name, workspace);
            this.Name = name;
        end
        
        function varargout = getData(this, varargin)
            % getData(this, startRow, endRow) returns a cell array with the
            % values of the fields between the start row and end rows with
            % ordering as given by fieldsnames function. If these are not
            % passed in, then all data is returned instead. This is the
            % usual use case.
            
            if nargin>=3 && ~internal.matlab.variableeditor.FormatDataUtils.isVarEmpty(this.Data)
                fieldNames = properties(this.Data);
                % Fetch a block of data using startRow and endRow.  The
                % columns are not used, because Objects always display a
                % fixed number of columns.
                startRow = min(max(1, varargin{1}), size(fieldNames, 1));
                endRow = min(max(1, varargin{2}), size(fieldNames, 1));
                
                selectionSize = abs(endRow-startRow)+1;
                values = cell(selectionSize, 1);
                
                % iterate using two indices at same time
                for i=[startRow:endRow; 1:selectionSize]
                    field = fieldNames{i(1)};
                    values{i(2)} = this.Data.(field);
                end
                
                varargout{1} = values;
            else
                % Otherwise return all data
                varargout{1} = this.Data;
            end
        end
        
        % setData: Sets a block of values. If three paramters are passed in
        % the the first value is assumed to be the data and the second is
        % the row and third the column.
        %
        % The return values from this method are the formatted command
        % string to be executed to make the change in the variable.
        %
        % Note - this is overriden here because the super method does row
        % and column indexing, while for objects assigns by property name.
        function varargout = setData(this,varargin)
            if nargin < 3
                varargout{1}='';
                return;
            end
            
            setStrings = {sprintf('%s = %s;', this.getLHS(varargin{:}), ...
                this.getRHS(varargin{1}))};
            
            % Evaluate any MATLAB changes (TODO: Remove when LXE is in)
            if ~isempty(setStrings)
                setCommands = cell(1,length(setStrings));
                for i=1:length(setStrings)
                    setCommands{i} = this.executeSetCommand(setStrings{i}, varargin{4});
                end
                varargout{1} = setCommands;
            end
        end
        
        function evalStr = executeSetCommand(this, setCommand, errorMsg)
            evalStr = sprintf('%s%s', this.Name, setCommand);
            if ischar(this.Workspace)
                if ~com.mathworks.datatools.variableeditor.web.WebWorker.TESTING
                    c = internal.matlab.datatoolsservices.CodePublishingService.getInstance;
                    channel = ['VariableEditor/' this.Name];
                    c.publishCode(channel, evalStr, errorMsg);
                end
            else
                origData = this.Data;
                evalin(this.Workspace, evalStr);
                evalStr = '';
                this.Data = evalin(this.Workspace, this.Name);
                
                % Because the change is internal to a workspace a workspace
                % event may not fire, so we must trigger the update
                % ourselves.
                eventdata = internal.matlab.variableeditor.DataChangeEventData;
                [I,J] = this.doCompare(origData);
                eventdata.Range = [I,J];
                if size(I,1)==1 && size(J,1)==1
                    % If there is only one change, pass this back as the
                    % Values for the event data.
                    eventdata.Values = this.getData(I(1,1),I(1,1),J(1,1),J(1,1));
                else
                    % Otherwise, pass back empty, which will trigger the
                    % client to refresh its view.
                    eventdata.Values = [];
                end
                
                this.notify('DataChange',eventdata);
            end
        end
        
        % updateData
        function data = updateData(this, varargin)
            currentData = this.Data;
            newData = varargin{1};
            s = warning('off', 'all');
            
            if ~isequaln(struct(currentData), struct(newData))
                % if not equal, then could not be a handle staying the same
                eventdata = internal.matlab.variableeditor.DataChangeEventData;
                
                currentPropCount = length(properties(currentData));
                newPropCount = length(properties(newData));
                
                if ~isequal(class(currentData), class(newData)) || ...
                        ~isequal(currentPropCount, newPropCount)
                    % if change in type, do full refresh
                    eventdata.Range = [];
                    eventdata.Values = newData;
                else
                    % Same data type, and not a handle.  Use doCompare to
                    % find where data changed from old to new data.
                    [I,J] = this.doCompare(newData);
                    if size(I, 1) == 1 && size(J ,1) == 1
                        eventdata.Range = [I(1), J(1)];
                        fieldNames = fields(currentData);
                        fieldName = fieldNames{I(1)};
                        
                        % Update single field
                        eventdata.Values = newData.(fieldName);
                    else
                        % More than one change. Just update all of them,
                        % instead of doing each individually
                        eventdata.Range = [];
                        eventdata.Values = newData;
                    end
                end
                this.Data = newData;
                this.notify('DataChange', eventdata);
            end
            
            data = newData;
            warning(s);
        end
    end %methods
    
    methods(Access = protected)
        function [I,J] = doCompare(this, newData)
            % Performs a field by field comparison and returns a map of
            % where every change that occurs to any fields
            
            % Could be sped up by stopping after 2 changes since the
            % function that uses this just does a full reload of data if
            % more then 1 change occurs
            oldData = this.Data;
            
            propNames = properties(oldData);
            numProps = length(propNames);
            
            I = [];
            
            for i=1:numProps
                propName = propNames{i};
                if isprop(newData, propName)
                    try
                        if ~isequaln(oldData.(propName), newData.(propName))
                            I = [I; i]; %#ok<AGROW>
                        end
                    catch
                        % Errors can occur with dependent properties (if
                        % the new value causes the dependent property to
                        % error when evaluated).  Consider this a change.
                        I = [I; i]; %#ok<AGROW>
                    end
                else
                    % The property doesn't exist in the new object.  For
                    % value objects, this can happen if the class object
                    % definition changes.  Need to do a full refresh.
                    I = [];
                    break;
                end
            end
            
            J = ones(length(I), 1)*2;
        end
    end
end
