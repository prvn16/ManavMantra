classdef MLStructureDataModel < internal.matlab.variableeditor.MLArrayDataModel & internal.matlab.variableeditor.StructureDataModel
    %MLSTRUCTUREDATAMODEL
    %   MATLAB Structure Data Model
    
    % Copyright 2013 The MathWorks, Inc.
       
    methods(Access='public')
        % Constructor
        function this = MLStructureDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLArrayDataModel(...
                name, workspace);
            this.Name = name;
        end
        
        function varargout = getData(this, varargin)
            if nargin>=3 && ~isempty(this.Data)
                fieldNames = fieldnames(this.Data);
                % Fetch a block of data using startRow and endRow.  The
                % columns are not used, because scalar structs always
                % display a fixed number of columns.
                startRow = min(max(1,varargin{1}),size(fieldNames,1));
                endRow = min(max(1,varargin{2}),size(fieldNames,1));
                
                % Since we can't subreference specific fields of a
                % structure as a structure, we'll convert to cell arrays,
                % to do the sub-referencing.
                values = struct2cell(this.Data);
                
                varargout{1} = values{startRow:endRow};
            else
                % Otherwise return all data
                varargout{1} = this.Data;
            end
        end

        % updateData
        function data = updateData(this, varargin)
            newData = varargin{1};
            origData = this.Data;
            classes = cellfun(@(a) class(a), struct2cell(origData), 'UniformOutput', false);
            newClasses = cellfun(@(a) class(a), struct2cell(newData), 'UniformOutput', false);

            % Check for type changes on structure elements structure elements
            if ~isequaln(classes,newClasses)
                sameSize = numel(classes) == numel(newClasses);
                if ~sameSize
                    % Keep [I, J] consistent with the value returned in
                    % doCompare, when the number of fields in the struct
                    % has changed.
                    [I,J] = meshgrid(1:size(newClasses,1),1:4);
                else
                    [I] = this.doCompare(newData);
                    %Set J to the type column since we know the class has
                    %changed
                    J = ones(size(I))*2;
                end
                eventdata = internal.matlab.variableeditor.DataChangeEventData;
                I = I(:)';
                J = J(:)';
                eventdata.Range = [I;J];
                
                % Set the new data
                this.Data = newData;

                % The eventData Values property should represent the data
                % that has changed within the cached this.Data block as it
                % is rendered. Currently the cached data may be huge, so
                % for now don't attempt to represent it.
                if sameSize && size(I,1)==1 && size(J,1)==1
                    % If there is only one change, pass this back as the
                    % Values for the event data.
                    eventdata.Values = this.getData(I(1,1),I(1,1),J(1,1),J(1,1));
                else
                    % Otherwise, pass back empty, which will trigger the
                    % client to refresh its view.
                    eventdata.Values = [];
                end
                
                this.notify('DataChange',eventdata);
                
                data = this.Data;
                return;
            end

            % Otherwise use the superclass updateData method
            data = this.updateData@internal.matlab.variableeditor.MLArrayDataModel(varargin{:});
        end
    end %methods
    
    methods(Access='protected')
        function [I,J] = doCompare(this, newData)
            origData = this.Data;
            fieldNames = fieldnames(origData);
            newFieldNames = fieldnames(newData);
            if length(fieldNames)==length(newFieldNames)
                origDataStruct = struct2cell(origData);
                newDataStruct = struct2cell(newData);
                classes = cellfun(@(a) class(a), origDataStruct, 'UniformOutput', false);
                newClasses = cellfun(@(a) class(a), newDataStruct, 'UniformOutput', false);
                % If the length of the fieldnames is the same, compare the
                % field names and values of the original struct to the
                % newData struct. If isequal throws an error, the field
                % should be changed.
                [I,J] = find(cellfun(@(a,b) ~internal.matlab.variableeditor.areVariablesEqual(a,b), ...
                    [fieldNames origDataStruct classes],...
                    [newFieldNames newDataStruct newClasses], ...
                    'ErrorHandler', @(err, a, b) true));                
            else
                % Otherwise, the number of fields has changed, so return
                % I,J where the size is not 1,1.  This is to prevent the
                % MLArrayDataModel from sending a DataChange event with a
                % single value.
                [I,J] = meshgrid(1:size(newFieldNames,1),1:4);               
            end
        end
        
        function lhs=getLHS(this, idx)
            % Return the left-hand side of an expression to assign a value
            % to a matlab structure field.  (The variable name will be
            % pre-pended by the caller).  Returns a string like: '.field'
            fieldNames = fieldnames(this.Data);
            numericIdx = str2num(idx); %#ok<ST2NM>
            lhs = [ '.' fieldNames{numericIdx(1)} ];
        end
    end
end
