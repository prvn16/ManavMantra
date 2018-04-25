classdef VariableEditorArrayAdapter < internal.matlab.variableeditor.MLAdapter
    %ARRAYADAPTER
    % MATLAB Web UITable Variable Editor Mixin to create
    % UITableArrayDataModel and PeerUITableArrayViewModel instance.

    % Copyright 2014 The MathWorks, Inc.
    
    
    % @ToDo Need to refactor to directly inherit the Mixin and implement
    % only getDataModel and getViewModel methods.
    
    properties (GetAccess='private')
        viewInterface; % controller
    end
    
    % DataModel
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=true, Hidden=false)
        % DataModel Property
        DataModel;
    end 
    
    methods
        function storedValue = get.DataModel(this)
            if isempty(this.DataModel_I) || ~isvalid(this.DataModel_I)
                this.DataModel = matlab.ui.internal.controller.uitable.UITableArrayDataModel(this.Name, this.Workspace, this.viewInterface);
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
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=true, Hidden=false)
        % ViewModel Property
        ViewModel;
    end %properties
    methods
        function storedValue = get.ViewModel(this)
            if isempty(this.ViewModel_I)
                this.ViewModel_I = internal.matlab.variableeditor.NumericArrayViewModel(this.DataModel);
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
        function this = VariableEditorArrayAdapter(viewInterface)
            this.Name = 'UITableData';
            this.Workspace = 'caller';
            this.viewInterface = viewInterface;
            
        end
    end
    
    methods (Access='public')
        
        % getDataModel
        function dataModel = getDataModel(this, ~)
            dataModel = this.DataModel;
        end

        % getViewModel
        function viewModel = getViewModel(this, document)
            % Delayed ViewModel creation to assure that the document
            % peerNode has been created.
            if (isempty(this.ViewModel_I) || ...
                ~isa(this.ViewModel_I,'matlab.ui.internal.controller.uitable.PeerUITableArrayViewModel')) ...
                && ~isempty(document) && ~isempty(document.PeerNode)
            
                delete(this.ViewModel_I);
                this.ViewModel_I = matlab.ui.internal.controller.uitable.PeerUITableArrayViewModel(document.PeerNode, this);
            end
            viewModel = this.ViewModel;
        end
    end
end

