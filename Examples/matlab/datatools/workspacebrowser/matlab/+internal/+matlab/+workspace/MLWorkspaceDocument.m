classdef MLWorkspaceDocument < internal.matlab.variableeditor.MLDocument    
    methods
        function this = MLWorkspaceDocument(manager, variable, userContext)
            this@internal.matlab.variableeditor.MLDocument(manager, variable, userContext);
        end
        
        % Overridden to ensure that we do not swap out Data and View Models
        % if the data changes
        function data = variableChanged(this, varargin)
            data = this.DataModel.Data;
            currFormat = get(0, 'format');
            if ~strcmp(this.PreviousFormat, currFormat)
                ed = internal.matlab.variableeditor.DataChangeEventData;
                % Force a refresh of the whole viewport with an arbitrary range, since having
                % the range be more than one element will cause a
                % refresh of the whole view
                ed.Range = {1:1000, 1:1000};
                this.ViewModel.notify('DataChange', ed);
                this.PreviousFormat = currFormat;
            end
        end
    end
end
