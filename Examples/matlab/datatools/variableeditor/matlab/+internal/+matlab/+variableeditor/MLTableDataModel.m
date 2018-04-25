classdef MLTableDataModel < internal.matlab.variableeditor.MLArrayDataModel & internal.matlab.variableeditor.TableDataModel
    %MLTableDATAMODEL
    %   MATLAB Cell Array Data Model

    % Copyright 2013-2014 The MathWorks, Inc.
    
    events
        MetaDataChanged;
    end

    methods(Access='public')
        % Constructor
        function this = MLTableDataModel(name, workspace)
            this@internal.matlab.variableeditor.MLArrayDataModel(name, workspace);
        end

        % updateData
        function data = updateData(this, varargin)
            newData = varargin{1};
            currentData = this.Data;
            data = newData;

            % Detect a property change
            if isequal(size(currentData),size(newData)) && ~isequal(currentData,newData)
                [I,J] = this.doCompare(newData);
                if isempty(I) && isempty(J)
                    this.Data = newData;

                    propNames = fieldnames(currentData.Properties);
                    for i=1:length(propNames)
                        if ~isequal(currentData.Properties.(propNames{i}), newData.Properties.(propNames{i}))
                            changeEventData = internal.matlab.variableeditor.MetaDataChangeEventData;
                            changeEventData.Property = propNames{i};
                            changeEventData.IsTypeChange = false;
                            changeEventData.OldValue = currentData.Properties.(propNames{i});
                            changeEventData.NewValue = newData.Properties.(propNames{i});
                            this.notify('MetaDataChanged',changeEventData);
                        end
                    end

                    return;
                end
            elseif isequal(size(currentData),size(newData)) && isequal(currentData,newData)
                % There seems to be a bug in isequal for tables where type
                % changes in properties aren't flagged as differences, we
                % will try and detect this
                [I,J] = this.doCompare(newData);
                foundTypeChange = false;
                foundDatetimeChange = false;
                if isempty(I) && isempty(J)
                    propNames = currentData.Properties.VariableNames;
                    for i=1:length(propNames)
                        if ~strcmp(class(currentData.(propNames{i})), class(newData.(propNames{i})))
                            this.Data = newData;
                            foundTypeChange = true;

                            changeEventData = internal.matlab.variableeditor.MetaDataChangeEventData;
                            changeEventData.Property = propNames{i};
                            changeEventData.IsTypeChange = true;
                            changeEventData.OldValue = class(currentData.(propNames{i}));
                            changeEventData.NewValue = class(newData.(propNames{i}));
                            this.notify('MetaDataChanged',changeEventData);
                        end
                        
                        if isa(newData.(propNames{i}), 'datetime')
                            currentFormat   = currentData.(propNames{i}).Format;
                            currentTimeZone = currentData.(propNames{i}).TimeZone; 
                            newFormat       = newData.(propNames{i}).Format;
                            newTimeZone     = newData.(propNames{i}).TimeZone;
                            if ~strcmp(currentFormat, newFormat) || ~strcmp(currentTimeZone, newTimeZone)
                                this.Data = newData;
                                foundDatetimeChange = true;
                            end
                        end
                        
                    end                 
                    %handle the RowTime format change condition, g1610416
                    %This is needed because changes to the RowTimes format aren't picked up by the isequal() check above.
                    if isfield(currentData.Properties, 'RowTimes') && isfield(newData.Properties, 'RowTimes') && ~strcmp(currentData.Properties.RowTimes.Format, newData.Properties.RowTimes.Format)
                        this.Data = newData;
                        changeEventData = internal.matlab.variableeditor.MetaDataChangeEventData;
                        changeEventData.Property = 'RowTimes';
                        changeEventData.IsTypeChange = false;
                        changeEventData.OldValue = currentData.Properties.('RowTimes');
                        changeEventData.NewValue = newData.Properties.('RowTimes');
                        this.notify('MetaDataChanged',changeEventData);
                    end  
                    
                    % Return if a type change was found
                    if foundTypeChange || foundDatetimeChange
                        % Force a data update because the data itself may
                        % have changed if it's type has changed
                        eventdata = internal.matlab.variableeditor.DataChangeEventData;
                        eventdata.Range = [];
                        eventdata.Values = [];

                        this.notify('DataChange',eventdata);
                        return;
                    end                 
                end
            end

            % No type or property changes found so call the superclass
            % updateData method to send the actual data change
            data = this.updateData@internal.matlab.variableeditor.MLArrayDataModel(varargin{:});
        end
    end %methods
    
    methods(Access='protected')
        function [I,J] = doCompare(this, newData)
            [I,J] = find(cellfun(@(a,b) ~isequal(a,b), table2cell(this.Data), table2cell(newData)));
        end
    end
end
