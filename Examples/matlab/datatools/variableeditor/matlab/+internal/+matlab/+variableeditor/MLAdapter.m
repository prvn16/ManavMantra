classdef MLAdapter < handle & internal.matlab.variableeditor.VariableEditorMixin & internal.matlab.variableeditor.NamedVariable
    %MLAdapter
    %   MATLAB Variable Editor Mixin

    % Copyright 2013 The MathWorks, Inc.

    % DataModel_I
    properties (SetObservable=true, SetAccess='protected', GetAccess='protected', Dependent=false, Hidden=false)
        % DataModel_I Property
        DataModel_I;
    end %properties
    methods
        function storedValue = get.DataModel_I(this)
            storedValue = this.DataModel_I;
        end
        
        function set.DataModel_I(this, newValue)
            reallyDoCopy = ~isequal(this.DataModel_I, newValue);
            if reallyDoCopy
                this.DataModel_I = newValue;
            end
        end
    end
    
    % ViewModel_I
    properties (SetObservable=true, SetAccess='protected', GetAccess='protected', Dependent=false, Hidden=false)
        % ViewModel_I Property
        ViewModel_I;
    end %properties
    methods
        function storedValue = get.ViewModel_I(this)
            storedValue = this.ViewModel_I;
        end
        
        function set.ViewModel_I(this, newValue)
            reallyDoCopy = ~isequal(this.ViewModel_I, newValue);
            if reallyDoCopy
                this.ViewModel_I = newValue;
            end
        end
    end
    
    methods
        % getDataModel
        function dataModel = getDataModel(this, ~)
            dataModel = this.DataModel;
        end

        % getViewModel
        function viewModel = getViewModel(this, ~)
            viewModel = this.ViewModel;
        end
        
        % getType
        function type = getType(this)
            type = this.DataModel.getType();
        end
    end
    
end

