classdef MLLogicalArrayAdapter < internal.matlab.variableeditor.MLAdapter
    % MLLogicalArrayAdapter
    % MATLAB Logical Array Variable Editor Mixin

    % Copyright 2015 The MathWorks, Inc.

    % DataModel
    properties (SetObservable = true, SetAccess = protected, Dependent=true)
        % DataModel Property
        DataModel;
    end
    
    methods
        function storedValue = get.DataModel(this)
            % Get the DataModel for logical arrays
            if isempty(this.DataModel_I)
                % Create a new DataModel
                this.DataModel = ...
                    internal.matlab.variableeditor.MLLogicalArrayDataModel(...
                    this.Name, this.Workspace);
            end
            storedValue = this.DataModel_I;
        end
        
        function set.DataModel(this, newValue)
            % Set the DataModel for logical arrays
            reallyDoCopy = ~isequal(this.DataModel_I, newValue);
            if reallyDoCopy
                this.DataModel_I = newValue;
            end
        end
    end
    
    % ViewModel
    properties (SetObservable = true, SetAccess = protected, Dependent=true)
        % ViewModel Property
        ViewModel;
    end
    
    methods
        function storedValue = get.ViewModel(this)
            % Get the ViewModel for logical arrays
            if isempty(this.ViewModel_I)
                % Create a new ViewModel
                this.ViewModel_I = ...
                    internal.matlab.variableeditor.LogicalArrayViewModel(...
                    this.DataModel);
            end
            storedValue = this.ViewModel_I;
        end
        
        function set.ViewModel(this, newValue)
            % Set the ViewModel for logical arrays
            reallyDoCopy = ~isequal(this.ViewModel_I, newValue);
            if reallyDoCopy
                this.ViewModel_I = newValue;
            end
        end
    end

    % Constructor
    methods
        function hObj = MLLogicalArrayAdapter(name, workspace, data)
            % Create MLLogicalArrayAdapter for the specified variable and
            % workspace
            hObj.Name = name;
            hObj.Workspace = workspace;
            hObj.DataModel.Data = data;
        end
    end
    
    methods(Static)
        function c = getClassType()
            c = internal.matlab.variableeditor.LogicalArrayDataModel.ClassType;
        end
    end
end