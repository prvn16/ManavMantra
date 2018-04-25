classdef PeerInspectorDocument < ...
        internal.matlab.variableeditor.MLDocument & ...
        internal.matlab.variableeditor.peer.PeerVariableNode
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % The Peer level Inspector Document.  Differs from the PeerDocument
    % used in the Variable Editor only in that is overrides the
    % variableChanged function -- because the inspector always uses the
    % same adapter class, and doesn't need to swap out when changes happen.
    % (In specific, inspecting value object arrays would cause a size
    % change that would trigger documents to be swapped out, which was
    % undesireable)
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Constant)
        % PeerNodeType
        PeerNodeType = '_VariableEditorDocument_';
    end
    
    properties (Dependent = true)
        DocID;
    end
    
    methods
        % Constructor
        function this = PeerInspectorDocument(root, manager, variable, ...
                userContext, docID)
            
            % Call the MLDocument constructor
            this = this@internal.matlab.variableeditor.MLDocument(...
                manager, variable, userContext);
            
            % Call the PeerVariableNode constructor
            this = ...
                this@internal.matlab.variableeditor.peer.PeerVariableNode(...
                root,...
                internal.matlab.variableeditor.peer.PeerDocument.PeerNodeType,...
                'name', variable.getDataModel.Name,...
                'workspace', manager.getWorkspaceKey(variable.getDataModel.Workspace),...
                'docID', docID,...
                'userContext', userContext);
            this.DataModel = variable.getDataModel();
            this.ViewModel = variable.getViewModel(this);
        end
        
        function handlePropertySet(~, ~, ~)
        end
        
        function handlePropertyDeleted(~, ~, ~)
        end
        
        function handlePeerEvents(~, ~, ~)
        end
        
        function storedValue = get.DocID(this)
            storedValue = this.PeerNode.getProperties.docID;
        end
        
        function data = variableChanged(this, varargin)
            % Overrides the variableChanged behavior from the super class,
            % which looks for type and/or dimension changes to swap out the
            % adapter.  This isn't needed because the inspector always uses
            % the same adapter class.
            data = this.DataModel.getData();
        end
    end
end

