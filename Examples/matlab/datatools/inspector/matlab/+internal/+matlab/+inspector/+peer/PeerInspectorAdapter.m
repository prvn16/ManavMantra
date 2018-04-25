classdef PeerInspectorAdapter < internal.matlab.inspector.MLInspectorAdapter
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Copyright 2015 The MathWorks, Inc.
    methods
        % getDataModel
        function dataModel = getDataModel(this, ~)
            dataModel = this.DataModel;
        end
        
        % getViewModel
        function viewModel = getViewModel(this, document)
            % Delayed ViewModel creation to assure that the document
            % peerNode has been created.
            if (isempty(this.ViewModel_I) || ...
                    ~isa(this.ViewModel_I, ...
                    'internal.matlab.inspector.peer.PeerInspectorViewModel')) ...
                    && ~isempty(document) && ~isempty(document.PeerNode)
                
                delete(this.ViewModel_I);
                this.ViewModel_I = ...
                    internal.matlab.inspector.peer.PeerInspectorViewModel(...
                    document.PeerNode, this);
            end
            viewModel = this.ViewModel;
        end

        % Constructor
        function this = PeerInspectorAdapter(name, workspace, ...
                DataModel, ViewModel)
            this@internal.matlab.inspector.MLInspectorAdapter(...
                name, workspace, DataModel, ViewModel);
        end
    end
end