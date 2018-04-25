classdef PeerWorkspaceAdapter < internal.matlab.workspace.MLWorkspaceAdapter
    %PeerWorkspaceAdapter
    %   MATLAB Workspace Variable Editor Mixin

    % Copyright 2013 The MathWorks, Inc.

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
                ~isa(this.ViewModel_I,'internal.matlab.workspace.peer.PeerWorkspaceViewModel')) ...
                && ~isempty(document) && ~isempty(document.PeerNode)
            
                delete(this.ViewModel_I);
                this.ViewModel_I = internal.matlab.workspace.peer.PeerWorkspaceViewModel(document.PeerNode, this);
            end
            viewModel = this.ViewModel;
        end
    end

    % Constructor
    methods
        function this = PeerWorkspaceAdapter(name, workspace, DataModel, ViewModel)
            this@internal.matlab.workspace.MLWorkspaceAdapter(name, workspace, DataModel, ViewModel);
        end
    end
end

