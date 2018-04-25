classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, ConstructOnLoad=true) Document < handle & internal.matlab.variableeditor.VariableObserver & JavaVisible
    % Document
    % An abstract class defining the methods for a Variable Document
    % 
    
    % Copyright 2013 The MathWorks, Inc.

    % Events
    events
        DocumentTypeChanged % Fired when the variable type has changed
    end
    
    % Property Definitions:

    % ViewModel
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        % ViewModel Property
        ViewModel;
    end %properties
    methods
        function storedValue = get.ViewModel(this)
            storedValue = this.ViewModel;
        end
        
        function set.ViewModel(this, newValue)
            reallyDoCopy = ~isequal(this.ViewModel, newValue);
            if reallyDoCopy
                this.ViewModel = newValue;
            end
        end
    end
    
    % DataModel
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        % DataModel Property
        DataModel;
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
    
    % Manager
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        % Manager Property
        Manager;
    end %properties
    methods
        function storedValue = get.Manager(this)
            storedValue = this.Manager;
        end
        
        function set.Manager(this, newValue)
            reallyDoCopy = ~isequal(this.Manager, newValue);
            if reallyDoCopy
                this.Manager = newValue;
            end
        end
    end
    
    % UserContext
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=false, Hidden=false)
        % UserContext Property
        UserContext;
    end %properties
    methods
        function storedValue = get.UserContext(this)
            storedValue = this.UserContext;
        end
        
        function set.UserContext(this, newValue)
            reallyDoCopy = ~isequal(this.UserContext, newValue);
            if reallyDoCopy
                this.UserContext = newValue;
            end
        end
    end

    % IgnoreScopeChange
    properties (SetObservable=false, SetAccess='public', GetAccess='public', Dependent=false, Hidden=true)
        % IgnoreScopeChange Property
        IgnoreScopeChange = false;
    end
    
    methods(Access='public')
        function this = Document(manager, dataModel, viewModel, userContext)
            this.DataModel = dataModel;
            this.ViewModel = viewModel;
            this.Manager = manager;
            this.UserContext = userContext;
        end
    end
    
    % Public methods
    methods (Access='public')
        % Delete
        function delete(this)
            if ~isempty(this.ViewModel) && isvalid(this.ViewModel)
                delete(this.ViewModel);
            end
            if ~isempty(this.DataModel) && isvalid(this.DataModel)
                delete(this.DataModel);
            end
        end 
        
        % set DataModel 
        function setDataModel(this, value)
            this.DataModel = value;
        end
        
        % set ViewModel
        function setViewModel(this, value)
            this.ViewModel = value;
        end        
    end
end %classdef
