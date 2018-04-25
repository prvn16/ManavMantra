classdef PeerNumericArrayAdapter < internal.matlab.variableeditor.MLNumericArrayAdapter
    %PeerNumericArrayAdapter
    %   MATLAB Numeric Array Variable Editor Mixin
    
    % Copyright 2013 The MathWorks, Inc.

    
    % Constructor
    methods
        function this = PeerNumericArrayAdapter(name, workspace, data)
            this@internal.matlab.variableeditor.MLNumericArrayAdapter(name, workspace, data);
        end
    end
    
    methods(Access='public')
        % getDataModel
        function dataModel = getDataModel(this, ~)
            dataModel = this.DataModel;
        end

        % getViewModel
        function viewModel = getViewModel(this, document)
            % Delayed ViewModel creation to assure that the document
            % peerNode has been created.
            if (isempty(this.ViewModel_I) || ...
                ~isa(this.ViewModel_I,'internal.matlab.variableeditor.peer.PeerNumericArrayViewModel')) ...
                && ~isempty(document) && ~isempty(document.PeerNode)
            
                delete(this.ViewModel_I);
                % usecontext is needed for live editor use case
                this.ViewModel_I = internal.matlab.variableeditor.peer.PeerNumericArrayViewModel(document.PeerNode, this, document.UserContext);
            end
            viewModel = this.ViewModel;
        end
    end
end
