classdef PeerObjectAdapter < internal.matlab.variableeditor.MLObjectAdapter
    %PeerObjectAdapter
    %   MATLAB Object Variable Editor Mixin
    
    % Copyright 2013-2014 The MathWorks, Inc.

    
    % Constructor
    methods
        function this = PeerObjectAdapter(name, workspace, data)
            % Creates a new PeerObjectAdapter
            this@internal.matlab.variableeditor.MLObjectAdapter(name, workspace, data);
        end
    end
    
    methods (Access = public)
        % getDataModel
        function dataModel = getDataModel(this, ~)
            % Returns the DataModel
            dataModel = this.DataModel;
        end

        % getViewModel
        function viewModel = getViewModel(this, document)
            % Returns the ViewModel
            if (isempty(this.ViewModel_I) || ...
                    ~isa(this.ViewModel_I,'internal.matlab.variableeditor.peer.PeerObjectViewModel')) && ...
                    ~isempty(document) && ~isempty(document.PeerNode)
                delete(this.ViewModel_I);
                this.ViewModel_I = internal.matlab.variableeditor.peer.PeerObjectViewModel(...
                    document.PeerNode, this);
            end
            viewModel = this.ViewModel;
        end
    end
end
