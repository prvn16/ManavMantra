classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, ConstructOnLoad=true) ViewModel < internal.matlab.variableeditor.Variable & internal.matlab.variableeditor.EditableVariable & internal.matlab.variableeditor.ActionMixin& JavaVisible
    % ViewModel
    % An abstract class defining the methods for a Variable View Model
    % 
    
    % Copyright 2013 The MathWorks, Inc.

    % Events
    events
       DataChange; % Fired the data in the model has changed
    end
        
    % Property Definitions:

    % DataModel
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        % DataModel Property
        DataModel;
        DataChangeListeners;
    end %properties
    methods
        function storedValue = get.DataModel(this)
            storedValue = this.DataModel;
        end
        
        function set.DataModel(this, newValue)
            reallyDoCopy = ~isequal(this.DataModel, newValue);
            if reallyDoCopy
                this.DataModel = newValue;
            end
        end
    end
    
    % Cosntructor
    methods
        function this = ViewModel(dataModel,varargin)
            this.DataModel = dataModel;
            if (~isempty(dataModel))
                this.DataChangeListeners = event.listener(dataModel,'DataChange',@(e,d) this.refresh(e,d));
            end
        end
    end
    
    % Private Methods
    methods(Access='protected')
        
        function varargout = refresh(this, ~ ,ed)
            eventdata = internal.matlab.variableeditor.DataChangeEventData;
            eventdata.Range = ed.Range;
            eventdata.Values = '';
            if (isobject(ed) && isprop(ed,'Values')) || (isstruct(ed) &&  isfield(ed, 'Values'))
                if ~isempty(eventdata.Range) && size(eventdata.Range,2)==1
                    % Refresh data for single cell and send back JSON to rebuild the cell and renderers
                    result = this.getRenderedData(eventdata.Range(1,1), ...
                        eventdata.Range(1,1), ...
                        eventdata.Range(2,1), ...
                        eventdata.Range(2,1));
                    if ~isempty(result)
                        eventdata.Values = result{1,1};
                    end
                end
            end
            this.notify('DataChange', eventdata);
            varargout = {};
        end
        
    end
    
    % Public Abstract Methods
    methods(Access='public',Abstract=true)
        % getRenderedData
        varargout = getRenderedData(this,varargin);

        % isSelectable
        selectable = isSelectable(this);

        % isEditable
        editable = isEditable(this, varargin);
    end %methods

    % Public Methods
    methods(Access='public',Abstract=false)
        function [valueSummary, isMeta] = getValueSummaryData(this)
            [valueSummary, isMeta] = internal.matlab.variableeditor.ViewModel.getValueSummary(this.DataModel.Data);
        end
    end
    
    % Public Static Methods
    methods(Static, Access='public')
        % Get variable summary information
        function [valueObject, isMeta] = getValueSummary(value)
            isMeta = false;
            try
                valueObject = workspacefunc('getshortvalueobjectj', value);
                isMeta = isequal(class(valueObject), 'com.mathworks.widgets.spreadsheet.data.ValueSummary');
            catch
            end
        end
    end
    
end %classdef