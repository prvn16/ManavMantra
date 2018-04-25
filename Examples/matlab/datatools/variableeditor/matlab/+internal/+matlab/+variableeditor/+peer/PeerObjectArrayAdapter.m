classdef PeerObjectArrayAdapter < ...
        internal.matlab.variableeditor.MLObjectArrayAdapter
    %PeerObjectArrayAdapter
    %   MATLAB Peer Object Array Variable Editor Mixin
    %
    % Copyright 2015 The MathWorks, Inc.
    
    
    % Constructor
    methods
        function this = PeerObjectArrayAdapter(name, workspace, data)
            this@internal.matlab.variableeditor.MLObjectArrayAdapter(...
                name, workspace, data);
        end
    end
    
    methods
        % getDataModel
        function dataModel = getDataModel(this, ~)
            dataModel = this.DataModel;
        end
        
        % getViewModel
        function viewModel = getViewModel(this, document)
            if (isempty(this.ViewModel_I) || ...
                    ~isa(this.ViewModel_I, 'internal.matlab.variableeditor.peer.PeerObjectArrayViewModel')) && ...
                    ~isempty(document) && ~isempty(document.PeerNode)
                delete(this.ViewModel_I);
                this.ViewModel_I = ...
                    internal.matlab.variableeditor.peer.PeerObjectArrayViewModel(...
                    document.PeerNode, this);
            end
            viewModel = this.ViewModel;
        end
    end
end
