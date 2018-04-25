classdef MLStringArrayAdapter < internal.matlab.variableeditor.MLAdapter
    % MLStringArrayAdapter
    % MATLAB String Array Variable Editor Mixin
    
    % Copyright 2015 The MathWorks, Inc.
    
    % DataModel
    properties (SetObservable=true, SetAccess='protected', ...
            GetAccess='public', Dependent=true, Hidden=false)
        % DataModel Property
        DataModel;
    end
    
    methods
        function storedValue = get.DataModel(this)
            if isempty(this.DataModel_I)
                this.DataModel = internal.matlab.variableeditor.MLStringArrayDataModel(...
                    this.Name, this.Workspace);
            end
            storedValue = this.DataModel_I;
        end
        
        function set.DataModel(this, newValue)
            reallyDoCopy = ~isequal(this.DataModel_I, newValue);
            if reallyDoCopy
                this.DataModel_I = newValue;
            end
        end
    end
    
    % ViewModel
    properties (SetObservable=true, SetAccess='protected', ...
            GetAccess='public', Dependent=true, Hidden=false)
        % ViewModel Property
        ViewModel;
    end
    
    methods
        function storedValue = get.ViewModel(this)
            if isempty(this.ViewModel_I)
                this.ViewModel_I = internal.matlab.variableeditor.StringArrayViewModel(...
                    this.DataModel);
            end
            storedValue = this.ViewModel_I;
        end
        
        function set.ViewModel(this, newValue)
            reallyDoCopy = ~isequal(this.ViewModel_I, newValue);
            if reallyDoCopy
                this.ViewModel_I = newValue;
            end
        end
    end
    
    % Constructor
    methods
        function hObj = MLStringArrayAdapter(name, workspace, data)
            hObj.Name = name;
            hObj.Workspace = workspace;
            hObj.DataModel.Data = data;
        end
    end
    
    methods(Static)
        function c = getClassType()
            c = internal.matlab.variableeditor.MLStringArrayDataModel.ClassType;
        end
    end
end

