classdef PeerVariableEditorPopoutHandler < internal.matlab.datatoolsservices.peer.PeerPopoutHandler
    % Copyright 2017 The MathWorks, Inc.
    
    %PEERVARIABLEEDITORPOPOUTHANDLER implements the PeerPopoutHandler for
    %the variable editor.
    properties(Constant)        
        cefDialogHandler = "internal.matlab.variableeditor.peer.PeerVariableEditorPopoutHandler";
        iframeDialogHandler = 'variableeditor_peer/PeerPopoutHandlerWidget';
        size = [600 400];
    end
    
    methods        
        function this = PeerVariableEditorPopoutHandler(varargin)
            this@internal.matlab.datatoolsservices.peer.PeerPopoutHandler(varargin{:});
            
        end       
        
        % This method cleans up PeerManager's ClonedList and
        % closing the variable.
        function close(this)                        
            close@internal.matlab.datatoolsservices.peer.PeerPopoutHandler(this);
            if (isprop(this, 'channel'))
                try
                    manager = internal.matlab.variableeditor.peer.PeerManagerFactory.createInstance(this.channel);                    
                    manager.closevar(this.docID, 'base');
                    manager.cleanupClonedVariableList(this.docID);
                catch % Do nothing, The manager probably does not exist
                end
            end
        end          
    end   
    
    % This static method starts up the DialogHandler service for
    % VariableEditor.
    methods(Static = true)
        function InitDialogHandler(varargin)
            cefHandler = internal.matlab.variableeditor.peer.PeerVariableEditorPopoutHandler.cefDialogHandler;
            iframeHandler = internal.matlab.variableeditor.peer.PeerVariableEditorPopoutHandler.iframeDialogHandler;
            internal.matlab.datatoolsservices.DialogHandlerService.getInstance(cefHandler, iframeHandler, varargin{:});            
        end
        
        % Returns the url for the Popout.
        function url = getUrl()
            url = '/toolbox/matlab/datatools/variableeditor/js/peer/VariableEditorPopoutHandler.html';            
        end
    end
end

