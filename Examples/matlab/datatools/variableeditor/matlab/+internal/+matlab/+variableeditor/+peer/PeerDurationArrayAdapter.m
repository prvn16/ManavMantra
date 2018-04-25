classdef PeerDurationArrayAdapter < ...
        internal.matlab.variableeditor.MLDurationArrayAdapter
    %PeerDurationArrayAdapter
    %   MATLAB Duration Array Variable Editor Mixin
    
    % Copyright 2015 The MathWorks, Inc.

    
    % Constructor
    methods
        function this = PeerDurationArrayAdapter(name, workspace, data)
            this@internal.matlab.variableeditor.MLDurationArrayAdapter( ...
                name, workspace, data);
        end
    end
    
    methods(Access='public')
        % getDataModel
        function dataModel = getDataModel(this, ~)
            dataModel = this.DataModel;
        end

        % getViewModel
        function viewModel = getViewModel(this, document)
            if (isempty(this.ViewModel_I) || ...
                    ~isa(this.ViewModel_I, 'internal.matlab.variableeditor.peer.PeerDurationArrayViewModel')) ...
                    && ~isempty(document) && ~isempty(document.PeerNode)
                delete(this.ViewModel_I);
                this.ViewModel_I = internal.matlab.variableeditor.peer.PeerDurationArrayViewModel(...
                    document.PeerNode, this);
            end
            viewModel = this.ViewModel;
        end
    end
end
