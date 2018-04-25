classdef PeerTableAdapter < internal.matlab.variableeditor.MLTableAdapter
    %PeerTableAdapter
    %   MATLAB Table Variable Editor Mixin
    
    % Copyright 2013-2014 The MathWorks, Inc.

    
    % Constructor
    methods
        function this = PeerTableAdapter(name, workspace, data)
            this@internal.matlab.variableeditor.MLTableAdapter(name, workspace, data);
        end
    end
    
    methods(Access='public')
        % getDataModel
        function dataModel = getDataModel(this, ~)
            dataModel = this.DataModel;
        end

        % getViewModel
        function viewModel = getViewModel(this, document)
            if (isempty(this.ViewModel_I) || ~isa(this.ViewModel_I,'internal.matlab.variableeditor.peer.PeerTableViewModel')) && ~isempty(document) && ~isempty(document.PeerNode)
                delete(this.ViewModel_I);
                this.ViewModel_I = internal.matlab.variableeditor.peer.PeerTableViewModel(document.PeerNode, this, document.UserContext);
            end
            viewModel = this.ViewModel;
        end
    end
end
