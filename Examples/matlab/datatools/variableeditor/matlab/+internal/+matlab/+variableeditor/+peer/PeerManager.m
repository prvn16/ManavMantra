classdef PeerManager < internal.matlab.variableeditor.MLManager
    % A class defining MATLAB PeerModel Variable Manager
    % 

    % Copyright 2013-2017 The MathWorks, Inc.

    % Property Definitions:

    % Events
    events
       FocusGained;  % Sent when a manager gains focus
       FocusLost;  % Sent when manager loses focus
    end

    % PeerModelServer
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        % PeerModelServer Property
        PeerModelServer;
    end %properties
    methods
        function storedValue = get.PeerModelServer(this)
            storedValue = this.PeerModelServer;
        end
        
        function set.PeerModelServer(this, newValue)
            reallyDoCopy = ~isequal(this.PeerModelServer, newValue);
            if reallyDoCopy
                this.PeerModelServer = newValue;
            end
        end
    end
    
    % Peer Listener Properties
    properties (SetObservable=false, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        PeerEventListener;
        PropertySetListener;
        PropertyDeletedListener;

        DocFocusedListener;
        DocFocusLostListener;
    end %properties
    
    % Channel
    properties
        Channel;
        ClonedVariableList;
    end
    
    properties (Access='protected')
        DelayedDocumentList = [];
        Root;
    end
    
    % HasFocus_I
    properties (SetObservable=true, SetAccess='protected', GetAccess='protected', Dependent=false, Hidden=true)
        % HasFocus_I Property
        HasFocus_I = false;
    end %properties
    methods
        function storedValue = get.HasFocus_I(this)
            storedValue = this.HasFocus_I;
        end
        
        function set.HasFocus_I(this, newValue)
            this.HasFocus_I = newValue;
        end
    end

    % HasFocus
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=true, Hidden=false)
        % HasFocus Property
        HasFocus;
    end %properties
    methods
        function storedValue = get.HasFocus(this)
            storedValue = this.HasFocus_I;
        end
        
        function set.HasFocus(this, newValue)
            if strcmp(this.Channel,internal.matlab.variableeditor.peer.PeerManagerFactory.PeerModelChannel)
               return;
            end

            if this.HasFocus_I && ~newValue
                this.HasFocus_I = newValue;
                if ~internal.matlab.variableeditor.peer.PeerManagerFactory.inFocusUpdate
                    internal.matlab.variableeditor.peer.PeerManagerFactory.setFocusedManager([]);
                end

                % Fire event when manager loses focus
                eventdata = internal.matlab.variableeditor.ManagerEventData;
                eventdata.Manager = this;
                this.notify('FocusLost',eventdata);

                % Send a peer event with the new value
                this.setProperty('HasFocus', newValue);
            elseif newValue
                this.HasFocus_I = newValue;
                if ~internal.matlab.variableeditor.peer.PeerManagerFactory.inFocusUpdate
                    internal.matlab.variableeditor.peer.PeerManagerFactory.setFocusedManager(this);
                end

                % Fire event when manager gainsfocus
                eventdata = internal.matlab.variableeditor.ManagerEventData;
                eventdata.Manager = this;
                this.notify('FocusGained',eventdata);

                % Send a peer event with the new value
                this.setProperty('HasFocus', newValue);
            end

            this.HasFocus_I = newValue;
        end

        % Initializes Actions on the server of type specified by creating an
        % ActionManager instance. Notifies ClientPeerManager by sending the
        % namespace used to initialize the Actions.
        % If no classType is provided, default to default Action class.
        function [ActionManager] = initActions(this, actionNamespace, startPath, classType)
            ActionManager = internal.matlab.variableeditor.ActionManager(this, actionNamespace , 'ActAsServer');
            if (nargin < 4)
                classType = 'internal.matlab.datatoolsservices.Action';
            end
            ActionManager.initActions(startPath, classType);            
            this.setProperty('ActionsInitialized',actionNamespace);
        end    

        % Initializes ContextMenus on the server for each instance of the
        % Manager. 'ContextMenuManager' parses through the xml file
        % provided and creates peernodes on the peermodel tree for each of the contextmenu options. 
        function [contextMenuManager] = initContextMenu(this, actionNamespace, queryString, xmlPath, contextNamespace)           
            contextMenuManager = internal.matlab.datatoolsservices.peer.ContextMenuManager(contextNamespace);
            contextMenuManager.createContextMenus(queryString, actionNamespace, xmlPath);
            this.setProperty('ContextMenuInitialized', contextNamespace);
        end        
    end

    % Constructor
    methods(Access='public')
        function this = PeerManager(Channel, RootType, IgnoreUpdates)
            this@internal.matlab.variableeditor.MLManager(IgnoreUpdates);
            this.Channel = Channel;
            this.PeerModelServer = peermodel.internal.PeerModelManagers.getServerManager(Channel);
            this.PeerModelServer.SyncEnabled = true;
            this.createRoot(RootType);
			this.ClonedVariableList = containers.Map;

            % Add document focus listeners
            this.DocFocusedListener = event.listener(this,'DocumentFocusGained',@(es, ed) this.handleDocumentFocusEvent(es, ed));
            this.DocFocusLostListener = event.listener(this,'DocumentFocusLost',@(es, ed) this.handleDocumentFocusEvent(es, ed));

            % Add listener for documents being removed
            this.PeerEventListener = ...
                event.listener(this.getRoot, ...
                'PeerEvent',@this.handlePeerEvent);
                        % Setup Property Listeners
            this.PropertySetListener = ...
                event.listener(this.getRoot, ...
                'PropertySet',@this.handlePropertySet);
            this.PropertyDeletedListener = ...
                event.listener(this.getRoot, ...
                'PropertyDeleted',@this.handlePropertyDeleted);
        end
    end
    
    % Public methods
    methods
        % Handles all peer events from the client
        function handlePeerEvent(this, ~, ed)
            if isfield(ed.EventData,'source') && strcmp('server',ed.EventData.source)
                return;
            end
            if isfield(ed.EventData,'type')
                try
                    switch ed.EventData.type
                        case 'OpenVariable'
                            if isfield(ed.EventData,'workspace') && strcmp(ed.EventData.workspace,'test')
                                this.openvar(ed.EventData.variable, 'caller', evalin('caller', ed.EventData.variable));
                            else
                                userContext = '{}';
                                if isfield(ed.EventData,'userContext')
                                    userContext = ed.EventData.userContext;
                                end
                                value = internal.matlab.variableeditor.NullValueObject(ed.EventData.variable);
                                if isfield(ed.EventData,'value')
                                    value = ed.EventData.value;
                                end
                                workspace = 'caller';
                                if isfield(ed.EventData,'workspace')
                                    workspace = ed.EventData.workspace;
                                end
                                this.delayedOpenVar(ed.EventData.variable, workspace, userContext, value);
                            end
                        case 'RemoveDocument' % Fired when a document is closed on th client
                                workspace = 'caller';
                                if isfield(ed.EventData,'workspace')
                                    workspace = ed.EventData.workspace;
                                end
                            this.cleanupClonedVariableList(ed.EventData.variable);
                            this.closevar(ed.EventData.variable, workspace);
                        case 'CloseAll' % This event is fired when the variable editor is closed on the client
                            this.closeAllVariables();
                        case 'CloneVariable'                            
                            docID = ed.EventData.docID;
                            editorId = ed.EventData.editorId;
                            this.cloneVariable(docID, editorId);							                                                                      
                    end
                catch e
                    this.sendErrorMessage(e.message);
                end
            end
        end
        
        % Given a clonedDocID, looks through the existing list of
        % ClonedVariableList if a parent DocID is present. If Yes, this
        % entry is removed from hashMap.
        function cleanupClonedVariableList(this, docID)
            clonedVariables = keys(this.ClonedVariableList);
            for i = 1: length(clonedVariables)
                key = clonedVariables{i};
                if strcmp(this.ClonedVariableList(key), docID)
                    remove(this.ClonedVariableList, key);
                    break;
                end
            end
        end    
        
        % This method clones a Variable given a docID and returns the docID
        % of the newly cloned variable. The editorID is used to construct
        % the fileName of the editor.
        function cloneVariable(this, docID, editorID)
            documents = this.Documents;                        
            try                 
                fileName = matlab.internal.editor.VariableManager.getFilenameForEditor(editorID);                    
                if ~(isKey(this.ClonedVariableList,docID))                                    
                    docIndex  = this.docIdIndex(docID);
                    clonedData = documents(docIndex).DataModel.getData();
                    varName = documents(docIndex).DataModel.Name;
                    doc = this.openvar(varName, 'base', clonedData, 'liveeditor', false);
                    internal.matlab.variableeditor.peer.PeerManager.cloneViewModelProps(documents(docIndex).ViewModel, doc.ViewModel);
                    clonedDocID = doc.DocID;                     
                    this.ClonedVariableList(docID) = clonedDocID;
                else
                    clonedDocID = this.ClonedVariableList(docID);
                end                
                this.getRoot.dispatchEvent(struct('type','ClonedVariable','docID',clonedDocID,...
                        'channel',this.Channel,'fileName',fileName));
            catch e
                this.sendErrorMessage(e.message);
            end
        end
        
        function delete(this)
            if ~isempty(this.PeerModelServer) && isvalid(this.PeerModelServer)
                this.PeerModelServer.delete;
            end
        end
        
        function handlePropertyDeleted(this, ~, ~)
            this.sendErrorMessage(getString(message(...
                'MATLAB:codetools:variableeditor:NoPropertiesShouldBeRemoved')));
        end
        
        function status = handlePropertySet(this, ~, ed)
            
            % Handles properties being set.  ed is the Event Data, and it
            % is expected that ed.EventData.key contains the property which
            % is being set.  Returns a status: empty string for success,
            % an error message otherwise.
            status = '';
            
            if ~isa(ed.EventData.newValue, 'java.util.HashMap')
                return;
            end
            
            clientGeneratedEvent = false;
            if ed.EventData.newValue.containsKey('Source')
                src = ed.EventData.newValue.get('Source');
                if strcmp('server',src)
                    return;
                elseif strcmp('client',src)
                    clientGeneratedEvent = true;
                end
            end
            
            if strcmpi(ed.EventData.key, 'HasFocus')
                if ed.EventData.newValue.containsKey('HasFocus')
                        % If the peer node property set was generated by the
                        % client, do not trigger the DocFocusedListener or DocFocusLostListener
                        % callbacks (by executing the HasFocus set function) 
                        % which will just re-transport the same peer
                        % node property set back to the client. This should be
                        % avoided as it can cause infinite loops when the time
                        % between property changes is smaller than the transport
                        % time
                    if clientGeneratedEvent
                        cachedDocFocusedListenerState = this.DocFocusedListener.Enabled;
                        cachedDocFocusLostListenerState = this.DocFocusLostListener.Enabled;
                        this.DocFocusedListener.Enabled = false; 
                        this.DocFocusLostListener.Enabled = false;
                    end                    
                    this.HasFocus = ed.EventData.newValue.get('HasFocus');
                    if clientGeneratedEvent
                        this.DocFocusedListener.Enabled = cachedDocFocusedListenerState; 
                        this.DocFocusLostListener.Enabled = cachedDocFocusLostListenerState;
                    end
                end
            elseif strcmpi(ed.EventData.key, 'FocusedDocument')
                % Set the Focused Document
                if this.HasFocus && ed.EventData.newValue.containsKey('Document')
                    docId = ed.EventData.newValue.get('Document');
                    index = this.docIdIndex(docId);
                    if ~isempty(index)
                         % If the peer node property set was generated by the
                         % client, do not trigger the DocFocusedListener or DocFocusLostListener
                         % callbacks (by executing the FocusedDocument set function) 
                         % which will just re-transport the same peer
                         % node property set back to the client. This should be
                         % avoided as it can cause infinite loops when the time
                         % between property changes is smaller than the transport
                         % time
                         if clientGeneratedEvent
                              cachedDocFocusedListenerState = this.DocFocusedListener.Enabled;
                              cachedDocFocusLostListenerState = this.DocFocusLostListener.Enabled;
                              this.DocFocusedListener.Enabled = false; 
                              this.DocFocusLostListener.Enabled = false;
                         end
                         this.FocusedDocument = this.Documents(index);
                         if clientGeneratedEvent
                             this.DocFocusedListener.Enabled = cachedDocFocusedListenerState; 
                             this.DocFocusLostListener.Enabled = cachedDocFocusLostListenerState;
                         end                         
                         
                    end
                end
            else
                this.sendErrorMessage(getString(message(...
                    'MATLAB:codetools:variableeditor:UnsupportedProperty', ...
                    ed.EventData.key)));
                status = 'error';
            end
        end
        
        function handleDocumentFocusEvent(this, ~, ed)
            % Set the Focused Document
            if ~isempty(this.FocusedDocument) && ...
                    strcmp('DocumentFocusGained', ed.EventName)
                this.setProperty('FocusedDocument', this.FocusedDocument.DocID);
            else
                this.setProperty('FocusedDocument', '');
            end
        end

        
    end
    
    % Protected methods
    methods(Access='protected')
        % Creates the root of the Peer Tree
        function createRoot(this, RootType)
            if isempty(this.Root)
                if isempty(this.PeerModelServer.getRoot())
                    this.Root = this.PeerModelServer.createRoot(RootType);
                else
                    this.Root = this.PeerModelServer.getRoot();
                end
            end
        end

        % Overrides the MLManager  method
        function varDocument = addDocument(this, veVar, userContext)
            varDocument = [];
            if ~isempty(veVar)
                docID = this.getNextDocID(veVar);
                varDocument = docID;                
                this.DelayedDocumentList = [this.DelayedDocumentList struct('docID', docID, 'veVar', veVar, 'userContext', userContext)];
            end
        end

        function docID = getNextDocID(~, veVar)
            mlock; % Keep persistent variables until MATLAB exits
            persistent docIDCounter;
            if isempty(docIDCounter)
                docIDCounter = 0;
            end
            docIDCounter = docIDCounter+1;
            docID = ['_' veVar.Name '__' num2str(docIDCounter)];
        end
        
        function varDocument = createDocument(this, veVar, userContext, docID)
            root = this.getRoot();
            varDocument = internal.matlab.variableeditor.peer.PeerDocument(root, this, veVar, userContext, docID);
            varDocument.IgnoreUpdates = this.IgnoreUpdates;
            varDocument.DataModel.IgnoreUpdates = this.IgnoreUpdates;

            if this.IgnoreUpdates
                varDocument.Name = docID;
            end

            this.Documents = [this.Documents varDocument];

            % Increment the workspace document counter
            this.incrementWorkspaceDocCount(veVar.DataModel.Workspace);
        end
        
        function delayedOpenVar(this, variable, ws, userContext, value)
            if ~isempty(userContext) && isa(userContext,'java.util.HashMap')
                s = struct();
                it = userContext.entrySet().iterator();
                while it.hasNext
                    pairs = it.next();
                    s.(pairs.getKey) = pairs.getValue;
                end
                userContext = internal.matlab.variableeditor.peer.PeerUtils.toJSON(true, s);
            end
            
            if isempty(ws)
                ws = 'caller';
            end
            
            if ischar(ws) && ~strcmp(ws, 'caller') && ~strcmp(ws, 'base')
                % Try to see if this workspace is something that needs to
                % be evaluated
                try
                    ws = eval(ws);
                    ws = this.getWorkspace(ws);
                catch
                end
            end
            
            % Get the mapped workspace key
            workspace = this.getWorkspaceKey(ws);
            
            if isa(value,'internal.matlab.variableeditor.NullValueObject')
                if ~com.mathworks.datatools.variableeditor.web.WebWorker.TESTING
                    % No value was passed in so we need to evaluate the value
                    % at a later time in the calling workspace
                    imv = 'internal.matlab.variableeditor';
                    openCmd = sprintf('[~]=%s.peer.PeerManagerFactory.getInstance.createInstance(''%s'',%s).openvar(''%s'', ''%s'', %s.NullValueObject(''%s''), ''%s'');', ...
                        imv, this.Channel, mat2str(this.IgnoreUpdates), variable, workspace, imv, variable, userContext);
                    [~] = com.mathworks.datatools.variableeditor.web.WebWorker.executeCommand(openCmd);
                end
            else
                % Check to see if this is a java matrix.
                % This can occurr if a matrix of data is sent from
                % javascript via the peermodel
                % TODO: This is a temporary code path for the LiveEditor so
                % it should be removed once they call us from MATLAB
                data = value;
                if isa(value, 'java.lang.Double[][]')
                    data = double(value);
                end

                [~] = this.openvar(variable, workspace, data, userContext);
            end
        end
        
        function sendErrorMessage(this, message)
            this.getRoot.dispatchEvent(struct('type','error','message',message,'source','server'));
        end       
        
    end
    
    methods(Static)
        % Clones all peer properties from one view model to another
        function cloneViewModelProps(originalViewModel, newViewModel)            
            if ~isempty(originalViewModel.PeerNode) && ~isempty(newViewModel.PeerNode)
                viewModelProps = originalViewModel.PeerNode.getProperties;                                   
                newViewModel.PeerNode.setProperties(viewModelProps);
            end
        end
    end

    % Public Methods
    methods(Access='public')
        % Refers to the current document Ids 
        function index = docIdIndex(this, docID)
            index = [];

            for i=1:length(this.Documents)
                doc = this.Documents(i);
                if strcmp(doc.DocID,docID)
                    index = i;
                    return;
                end
            end
        end
        
        function setProperty(this, propertyName, propertyValues)
            map = java.util.HashMap();
            map.put('Source', 'server');
            if ~isstruct(propertyValues)
                map.put(propertyName, propertyValues);
            else
                fields = fieldnames(propertyValues);
                for i=1:length(fields)
                    map.put(fields{i}, propertyValues.(fields{i}));
                end
            end

            this.getRoot.setProperty(propertyName, map);
        end
        
        function classname = getAdapterClassNameForData(this, varClass, varSize, data)
            classname = this.getAdapterClassNameForData@internal.matlab.variableeditor.MLManager(varClass, varSize, data);
            classname = strrep(classname, 'internal.matlab.variableeditor.ML', 'internal.matlab.variableeditor.peer.Peer');
        end
        
        % Gets the root node of the Peer Tree
        function root=getRoot(this)
            if isempty(this.Root)
              this.createRoot([this.Channel '_Root']);
            end

            root = this.Root;
        end
        
        function doc = doDelayedDocumentCreation(this)
            doc = [];
            while ~isempty(this.DelayedDocumentList)
                s = this.DelayedDocumentList(1);
                if ~isa(s.veVar, 'internal.matlab.variableeditor.VariableEditorMixin')
                    veVar = this.getVariableAdapter(s.veVar.Name, s.veVar.Workspace, s.veVar.VarClass, s.veVar.VarSize, s.veVar.Data);
                else
                    veVar = s.veVar;
                end
                doc = this.createDocument(veVar, s.userContext, s.docID);
                this.DelayedDocumentList(1) = [];
            end
        end
        
        % This function is only for testing purpose
        function SetDelayedDocumentList(this,value)
            this.DelayedDocumentList = value;
        end
        
        function asyncDoDelayedDocumentCreation(this)
            imv = 'internal.matlab.variableeditor';
            openCmd = sprintf('[~] = %s.peer.PeerManagerFactory.getInstance.createInstance(''%s'',%s).doDelayedDocumentCreation();', ...
                imv, this.Channel, mat2str(this.IgnoreUpdates));
            com.mathworks.datatools.variableeditor.web.WebWorker.executeCommand(openCmd);                
        end

        function varDocument = openvar(this, name, ws, data, userContext, delayDocCreation)
            if nargin <= 3 || (~istall(data) && isempty(data)) || isa(data,'internal.matlab.variableeditor.NullValueObject')
                if nargin < 3 || isempty(ws)
                    ws = 'caller';
                end
                % NullValueObject - signals that we have to ask MATLAB for the
                % data
                if nargin<=3 || isa(data,'internal.matlab.variableeditor.NullValueObject')
                    try
                        data = evalin(ws, name);
                    catch
                        data = internal.matlab.variableeditor.NullValueObject(name);
                    end
                end
            end
            if nargin<=4 || isempty(userContext)
                userContext = '';
            end
            
            if internal.matlab.variableeditor.peer.PeerUtils.isLiveEditor(userContext)
                w = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
                w.registerWidgets('internal.matlab.variableeditor.peer.PeerTableViewModel','', 'variableeditor_peer/PeerTableViewModel','','');
                w.registerWidgets('internal.matlab.variableeditor.peer.PeerNumericArrayViewModel','', 'variableeditor_peer/PeerArrayViewModel','','');
				w.registerWidgets('internal.matlab.variableeditor.peer.PeerLogicalArrayViewModel','', 'variableeditor_peer/PeerArrayViewModel','','');
            else
                w = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
                w.registerWidgets('internal.matlab.variableeditor.peer.PeerTableViewModel','', 'variableeditor/views/TableArrayView','','');
                w.registerWidgets('internal.matlab.variableeditor.peer.PeerNumericArrayViewModel','', 'variableeditor/views/NumericArrayView','','');
				w.registerWidgets('internal.matlab.variableeditor.peer.PeerLogicalArrayViewModel','', 'variableeditor/views/NumericArrayView','','');
            end
                        
            if nargin < 6 || isempty(delayDocCreation)
                delayDocCreation = false;
            end
            
            if ~delayDocCreation
                if ~this.isVariableOpen(name, ws)
                    varDocument = this.openvar@internal.matlab.variableeditor.MLManager(name, ws, data, userContext); %#ok<NASGU>
                    varDocument = this.doDelayedDocumentCreation();
                else
                    % If the variable is already opened, update the focused
                    % document. 
                    varDocument = this.updateFocusedDocument(name, ws);
                end
            else                
                varClass = class(data);
                varSize = internal.matlab.variableeditor.FormatDataUtils.getVariableSize(data);
                varDocument = this.addDocument(struct('Name', name, 'Workspace', ws, 'VarClass', varClass, 'VarSize', varSize, 'Data', data), userContext);
            end
        end
    end
end
