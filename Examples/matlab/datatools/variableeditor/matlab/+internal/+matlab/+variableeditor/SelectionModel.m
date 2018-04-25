classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, ConstructOnLoad=true) SelectionModel < handle
    % An abstract class defining the methods for a Variable Selection Model
    % 
    
    % Copyright 2013 The MathWorks, Inc.

    % Events
    events
       SelectionChanged;  % Sent when the selection has changed
    end
    
    methods(Access='protected')
        function fireSelectionChanged(this)
            % Fire event when document is opened
            eventdata = internal.matlab.variableeditor.SelectionEventData;
            eventdata.Selection = this.getSelection();
            this.notify('SelectionChanged',eventdata);
        end
    end
    
    % Public Abstract Methods
    methods(Access='public',Abstract=true)
        % getSelection
        varargout = getSelection(this,varargin);

        % setSelection
        varargout = setSelection(this,varargin);

        % getFormattedSelection
        varargout = getFormattedSelection(this,varargin);
    end %methods

end %classdef
