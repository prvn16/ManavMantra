classdef MLObjectAdapter < internal.matlab.variableeditor.MLAdapter
    % MLObjectAdapter
    % MATLAB Object Variable Editor Mixin
    
    % Copyright 2013-2014 The MathWorks, Inc.
    
    % DataModel
    properties (SetObservable = true, SetAccess = protected, Dependent = true)
        % DataModel Property
        DataModel;
    end %properties
    
    methods
        function storedValue = get.DataModel(this)
            % Returns the DataModel for the given object, creating a new
            % one if necessary.  The appropriate data model will be
            % created, depending on if this is a handle or value object.
            if isempty(this.DataModel_I)
                if this.HandleObject
                    this.DataModel = ...
                        internal.matlab.variableeditor.MLHandleObjectDataModel(...
                        this.Name, this.Workspace);
                else
                    this.DataModel = ...
                        internal.matlab.variableeditor.MLObjectDataModel(...
                        this.Name, this.Workspace);
                end
            end
            storedValue = this.DataModel_I;
        end
        
        function set.DataModel(this, newValue)
            % Sets the DataModel for the given object
            reallyDoCopy = ~isequal(this.DataModel_I, newValue);
            if reallyDoCopy
                this.DataModel_I = newValue;
            end
        end
    end
    
    % ViewModel
    properties (SetObservable = true, SetAccess = protected, Dependent = true)
        % ViewModel Property
        ViewModel;
    end %properties
    
    methods
        function storedValue = get.ViewModel(this)
            % Returns the ViewModel for the given object, creating a new
            % one if necessary
            if isempty(this.ViewModel_I)
                this.ViewModel_I = ...
                    internal.matlab.variableeditor.ObjectViewModel(...
                    this.DataModel);
            end
            storedValue = this.ViewModel_I;
        end
        
        function set.ViewModel(this, newValue)
            % Sets the ViewModel for the given object
            reallyDoCopy = ~isequal(this.ViewModel_I, newValue);
            if reallyDoCopy
                this.ViewModel_I = newValue;
            end
        end
    end
    
    properties (GetAccess = protected)
        % Stores whether this is a handle or value object
        HandleObject;
    end
    
    % Constructor
    methods
        function hObj = MLObjectAdapter(name, workspace, data)
            % Creates a new MLObjectAdapter
            hObj.Name = name;
            hObj.Workspace = workspace;
            if isa(data, 'handle')
                hObj.HandleObject = true;
            else
                hObj.HandleObject = false;
            end
            hObj.DataModel.Data = data;
        end
    end
end

