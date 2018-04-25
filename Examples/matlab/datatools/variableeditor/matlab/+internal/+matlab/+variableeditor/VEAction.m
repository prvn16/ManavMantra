classdef (Abstract) VEAction  < internal.matlab.datatoolsservices.Action
    % VEAction Abstract class is a subclass of the Action class
    
    % This class gets an instance of the VariableEditor's PeerManager and
    % listens to changes in Selection/Focus etc and calls the
    % UdpateActionState. Subclasses implementing the UpdateActionState
    % will be able to re-evaluate the Action state and update on these events.
    
    % Copyright 2017 The MathWorks, Inc.

    properties (Access = 'protected')       
        veManager
    end
    
    properties (Access = private)
        % Listeners for any events on the Variable Editor
        managerFocusGainedListener        
        managerFocusLostListener        
        veDocumentFocusGainedListener
        veDocumentFocusLostListener
        veDocumentOpenedListener
        veDocumentClosedListener                
        veDocumentTypeChangedListener
        veSelectionChangeListener        
        dataChangeListener      
    end    
    
    methods 
        % Adds listeners on the PeerManager and PeerManagerFactory instances.
        function this = VEAction(props, manager)
            this@internal.matlab.datatoolsservices.Action(props);        
                
            factory = internal.matlab.variableeditor.peer.PeerManagerFactory.getInstance();
            this.veManager = manager;           
            
            this.managerFocusGainedListener = event.listener(factory, 'ManagerFocusGained',...
                 @(es, ed) this.UpdateActionState());           
             this.managerFocusLostListener = event.listener(factory, 'ManagerFocusLost',...
                 @(es, ed) this.UpdateActionState());           
            
            this.veDocumentFocusGainedListener = event.listener(this.veManager, 'DocumentFocusGained',...
                @(es, ed) this.handleVEDocumentFocus(es, ed));           
            this.veDocumentFocusLostListener = event.listener(this.veManager, 'DocumentFocusLost',...
                @(es, ed) this.handleVEDocumentFocus(es, ed));           
            this.veDocumentOpenedListener = event.listener(this.veManager, 'DocumentOpened',...
                @(es, ed) this.UpdateActionState());           
            this.veDocumentClosedListener = event.listener(this.veManager, 'DocumentClosed',...
                @(es, ed) this.UpdateActionState());            
        end             
      
        % Adds Listeners on the Variable Editor PeerDocument during
        % Focus/Selection changes.
        function handleVEDocumentFocus(this, es, ~)
            if ~isempty(this.veDocumentTypeChangedListener)
                delete(this.veDocumentTypeChangedListener);
            end
            if ~isempty(es.FocusedDocument)
                this.veDocumentTypeChangedListener = event.listener(es.FocusedDocument, 'DocumentTypeChanged',...
                                @(es, ed) this.handleDocTypeChanged(es, ed));
                if isa(es.FocusedDocument.ViewModel,'internal.matlab.variableeditor.SelectionModel')        
                    if ~isempty(this.veSelectionChangeListener)
                         delete(this.veSelectionChangeListener);
                    end
                    this.veSelectionChangeListener = event.listener(es.FocusedDocument.ViewModel, ...
                            'SelectionChanged', @(es, ed) this.UpdateActionState());            
                end
                if ~isempty(this.dataChangeListener)
                     delete(this.dataChangeListener);
                end
                this.dataChangeListener = event.listener(es.FocusedDocument.ViewModel,'DataChange', @(es, ed) this.UpdateActionState());                        
            end             
            this.UpdateActionState();
        end
     
        % Adds listeners on the ViewModel of the PeerDocument for Selection changes. 
        function handleDocTypeChanged(this, es, ~)
            if isa(es.ViewModel,'internal.matlab.variableeditor.SelectionModel')
                if ~isempty(this.veSelectionChangeListener)
                     delete(this.veSelectionChangeListener);
                end
                this.veSelectionChangeListener = event.listener(es.ViewModel,'SelectionChanged', @(es, ed) this.UpdateActionState());            
            end
            this.UpdateActionState();
        end        
    end
    
    methods(Abstract)
        UpdateActionState(this);        
    end    
end

