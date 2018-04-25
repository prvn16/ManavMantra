classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, ConstructOnLoad=true) Manager < handle & JavaVisible
    % An abstract class defining the methods for a Variable Manager
    % 

    % Copyright 2013-2016 The MathWorks, Inc.

    % Events
    events
       DocumentOpened;  % Sent when a document is opened
       DocumentClosed;  % Sent when a document is closed
       DocumentFocusGained; % Sent when a document gains focus
       DocumentFocusLost; % Sent when a document loses focus
    end
    
    % Property Definitions:

    % Documents_I
    properties (SetObservable=true, SetAccess='protected', GetAccess='protected', Dependent=false, Hidden=true)
        % Documents_I Property
        Documents_I;
    end %properties
    methods
        function storedValue = get.Documents_I(this)
            storedValue = this.Documents_I;
        end
        
        function set.Documents_I(this, newValue)
            reallyDoCopy = ~isequal(this.Documents_I, newValue);
            if reallyDoCopy
                this.Documents_I = newValue;
            end
        end
    end
    
    % Documents
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=true, Hidden=false)
        % Documents Property
        Documents;
    end %properties
    methods
        function storedValue = get.Documents(this)
            storedValue = this.Documents_I;
        end
        
        function set.Documents(this, newValue)
            this.Documents_I = newValue;
        end
    end
    
    % FocusedDocument
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Hidden=false)
        % FocusedDocument Property
        FocusedDocument;
    end %properties
    methods
        function storedValue = get.FocusedDocument(this)
            storedValue = this.FocusedDocument;
        end
        
        function set.FocusedDocument(this, newValue)
            % Short circuit if old value is same as new value
            if internal.matlab.variableeditor.areVariablesEqual(this.FocusedDocument, newValue) || ...
               (~isempty(newValue) && ~isa(newValue, 'internal.matlab.variableeditor.Document')) || ...
               (~isempty(newValue) && ~this.containsDocument(newValue))
                return;
            end
            
            % Fire event when document focus is lost
            if ~isempty(this.FocusedDocument) && isvalid(this.FocusedDocument)
                eventdata = internal.matlab.variableeditor.DocumentChangeEventData;
                eventdata.Document = this.FocusedDocument;
                this.notify('DocumentFocusLost',eventdata);
            end
            
            this.FocusedDocument = newValue;
            
            % Fire event when document focus is gained
            if ~isempty(newValue)
                eventdata = internal.matlab.variableeditor.DocumentChangeEventData;
                eventdata.Document = newValue;
                this.notify('DocumentFocusGained',eventdata);
            end
        end
    end
    
    methods(Access='public')
        % Checks to see if the manager contains the specified document
        function hasDoc = containsDocument(this, doc)
            hasDoc = false;
            for i=1:length(this.Documents)
                if internal.matlab.variableeditor.areVariablesEqual(doc, this.Documents(i))
                    hasDoc = true;
                    return;
                end
            end
        end
    end
    
    % Public Abstract Methods
    methods(Access='public',Abstract=true)
        % openvar
        varargout = openvar(this,varargin);

        % closevar
        varargout = closevar(this,varargin);
        
        % getVariableAdapter
        veVar = getVariableAdapter(this, name, workspace, varClass, varSize, data);
    end
end
