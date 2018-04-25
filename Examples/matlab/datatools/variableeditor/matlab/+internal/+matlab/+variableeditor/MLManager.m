classdef MLManager < internal.matlab.variableeditor.Manager
    % A class defining MATLAB Variable Manager
    % 

    % Copyright 2013-2018 The MathWorks, Inc.

    % Workspaces
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        % Workspaces Property
        Workspaces = containers.Map;
        WorkspaceCounts = containers.Map;

        % RegisteredWorkspaces Property
        RegisteredWorkspaces = containers.Map;
    end %properties

    properties
        IgnoreUpdates = false;
    end

    methods(Access='protected')
        % Persistent method to retrieve the next workspace counter value
        % the update flag specifies whether to increment the value
        function wsc = getWorkspaceCounter(~, update)
            mlock;
            persistent workspaceCounter;
            if isempty(workspaceCounter)
                workspaceCounter = 0;
            end
            
            if nargin < 2
                update = false;
            end
            
            if update
                workspaceCounter = workspaceCounter + 1;
            end
            
            wsc = workspaceCounter;
        end
        
        % Adds a workspace to the managers workspace hash, if a key has not
        % already been created for the workspace one will be generated
        function key = addWorkspace(this, workspace)
            key = this.getWorkspaceKey(workspace);

            if isempty(key)
                workspaceCounter = this.getWorkspaceCounter(true);
                key = ['workspace_' num2str(workspaceCounter)];
            end

            if ~this.Workspaces.isKey(key)
                this.Workspaces(key) = workspace;
            end
        end
        
        % Does a check to see if any of the open documents belong to the
        % workspace passed in.
        function foundWorkspace = workspaceHasOpenDocuments(this, workspace)
            foundWorkspace = false;
            wsKey = this.getWorkspaceKey(workspace);

            if ~isempty(this.Documents) && ...
                    any(isvalid(this.Documents)) && ...
                    this.WorkspaceCounts.isKey(wsKey)
                foundWorkspace = this.WorkspaceCounts(wsKey) >= 1;
            end
        end
        
        % This removes any workspaces from the workspace hash that do not
        % have open documents.
        function cleanupWorkspace(this, workspace, wsKey)
            % If this is not a user registered workspace check to see if it
            % should be removed (i.e. no open documents)
            if ~this.workspaceHasOpenDocuments(workspace) &&...
                    ~this.RegisteredWorkspaces.isKey(wsKey)
                this.removeWorkspace(workspace);
            end
        end

        % Removed a workspace from the managers workspace hash
        function key = removeWorkspace(this, workspace)
            key = this.getWorkspaceKey(workspace);

            if isempty(key)
                workspaceCounter = this.getWorkspaceCounter(true);
                key = ['workspace_' num2str(workspaceCounter)];
            end

            if this.Workspaces.isKey(key) && ...
                ~this.workspaceHasOpenDocuments(workspace) &&...
                    ~this.RegisteredWorkspaces.isKey(key)
                this.Workspaces.remove(key);
                if this.WorkspaceCounts.isKey(key)
                    this.WorkspaceCounts.remove(key);
                end
            end
        end

        % Gets the workspace associated with the given key.  If the
        % workspace isn't already in the workspace hash it will be added.
        function workspace = getWorkspace(this, workspaceKey)
            workspace = workspaceKey;
            if ischar(workspace)
                if ~this.Workspaces.isKey(workspaceKey)
                    this.addWorkspace(workspaceKey);
                end
                workspace = this.Workspaces(workspaceKey);
            else
                if isempty(this.getWorkspaceKey(workspaceKey))
                    this.addWorkspace(workspaceKey);
                end
            end
        end

        function varDocument = addDocument(this, veVar, userContext)
            varDocument = [];
            if ~isempty(veVar)
                varDocument = internal.matlab.variableeditor.MLDocument(this, veVar, userContext);
                varDocument.IgnoreUpdates = this.IgnoreUpdates;
                varDocument.DataModel.IgnoreUpdates = this.IgnoreUpdates;
                
                this.Documents = [this.Documents varDocument];

                % Increment the workspace document counter
                this.incrementWorkspaceDocCount(veVar.DataModel.Workspace);
            end
        end
        function incrementWorkspaceDocCount(this, workspace)
            % Add to workspace counts
            wsKey = this.getWorkspaceKey(workspace);
            if ~this.WorkspaceCounts.isKey(wsKey)
                this.WorkspaceCounts(wsKey) = 1;
            else
                this.WorkspaceCounts(wsKey) = this.WorkspaceCounts(wsKey) + 1;
            end
        end
        
        function deccrementWorkspaceDocCount(this, workspace)
            % Add to workspace counts
            wsKey = this.getWorkspaceKey(workspace);
            if this.WorkspaceCounts.isKey(wsKey)
                if this.WorkspaceCounts(wsKey) > 1
                   this.WorkspaceCounts(wsKey) = this.WorkspaceCounts(wsKey) - 1;
                else
                    this.WorkspaceCounts.remove(wsKey);
                end
            end
        end
        
        function removeDocument(this, name, workspace)
            docIndex = this.documentIndex(name, workspace);
            if ~isempty(docIndex)
                if this.FocusedDocument == this.Documents(docIndex)
                    this.FocusedDocument = [];
                end

                doc = this.Documents(docIndex);
                % Delete the document
                if isvalid(doc)
                    delete(doc);
                end
                
                % Remove the element from the Documents list
                if ~isempty(this.Documents) && ...
                        docIndex <= length(this.Documents) && ...
                        isequal(this.Documents(docIndex), doc)
                    this.Documents = [this.Documents(1:docIndex-1) this.Documents(docIndex+1:end)];
                    % Decrement the document counter
                    this.deccrementWorkspaceDocCount(workspace);
                end
            end
        end
    end

    methods(Access='public')
        % Constructor
        function this = MLManager(IgnoreUpdates)
            if nargin<1
                IgnoreUpdates = false;
            end
            if ~isempty(IgnoreUpdates)
                this.IgnoreUpdates = IgnoreUpdates;
            end
        end
        
        function index = documentIndex(this, name, workspace)
            if nargin < 3 || isempty(workspace)
                workspace = 'caller';
            end
            index = [];

            for i=1:length(this.Documents)
                doc = this.Documents(i);
                
                if strcmp(doc.Name, name) && ...
                        isequal(doc.Workspace, workspace)
                    index = i;
                    return;
                end
            end
        end
        
        % Delete
        function delete(this)
            if ~isempty(this.Documents) && any(isvalid(this.Documents))
                for i=length(this.Documents):-1:1
                    if isvalid(this.Documents(i))
                        delete(this.Documents(i));
                    end
                end
				% delete the workspace since all the documents have been
                % deleted
                if ~isempty(this.findprop('Workspace')) && ~isempty(this.Workspace) && ~isempty(this.findprop('WorkspaceKey')) && ~isempty(this.WorkspaceKey)
                    workspace = this.Workspace;
                    ws = this.WorkspaceKey;
                    this.cleanupWorkspace(workspace, ws);
                end 
            end
        end

        % openvar
        function varDocument = openvar(this, name, ws, data, userContext)
            if nargin < 3 || isempty(ws)
                ws = 'caller';
            end            
            
            % Get the mapped workspace
            workspace = this.getWorkspace(ws);
            
            if (this.isVariableOpen(name, ws))
                 % Document already exists for this variable/workspace
                 % combination
                varDocument = this.updateFocusedDocument(name, ws);
                return;
            end
            % NullValueObject - signals that we have to ask MATLAB for the
            % data            

            if nargin<=3 || isa(data,'internal.matlab.variableeditor.NullValueObject')
                try
                    data = evalin(workspace, name);
                catch
                    data = internal.matlab.variableeditor.NullValueObject(name);
                end
            end
            varClass = class(data);
            varSize = internal.matlab.variableeditor.FormatDataUtils.getVariableSize(data);
            
            if nargin<=4 || isempty(userContext)
                userContext = '';
            end

            if ~isa(data, 'internal.matlab.variableeditor.VariableEditorMixin')
                veVar = this.getVariableAdapter(name, workspace, varClass, varSize, data);
            else
                veVar = data;
            end
            varDocument = this.addDocument(veVar, userContext);
            
            % Fire event when document is opened
            eventdata = internal.matlab.variableeditor.DocumentChangeEventData;
            eventdata.Name = name;
            eventdata.Workspace = workspace;
            eventdata.Document = varDocument;
            this.notify('DocumentOpened',eventdata);
        end
        
        % Updates the document corresoponding to the name as
        % focusedDocument
        function varDocument = updateFocusedDocument(this, name, ws)  
            % Get the mapped workspace
            workspace = this.getWorkspace(ws);
            docIndex = this.documentIndex(name, workspace);
            try
                varDocument = this.Documents(docIndex);
                % Give this document focus
		        this.FocusedDocument = varDocument;
			catch
				varDocument = [];
				this.FocusedDocument = varDocument;
           end           
        end

        % closevar
        function closevar(this, name, ws)
            if nargin < 3 || isempty(ws)
                ws = 'caller';
            end
            
            % Get the mapped workspace
            workspace = this.getWorkspace(ws);
            ws = this.getWorkspaceKey(workspace);

            % Check to make sure document exists
            if isempty(documentIndex(this, name, workspace))
                this.cleanupWorkspace(workspace, ws);
                return;
            end
            
            this.removeDocument(name, workspace);
            this.cleanupWorkspace(workspace, ws);

            % Fire event when document is closed
            eventdata = internal.matlab.variableeditor.DocumentChangeEventData;
            eventdata.Name = name;
            eventdata.Workspace = workspace;
            eventdata.Document = [];
            this.notify('DocumentClosed',eventdata);
            
            if ischar(workspace)
                % Discard any generated code for the variable
                c = internal.matlab.datatoolsservices.CodePublishingService.getInstance;
                channel = ['VariableEditor/' name];
                c.discardCode(channel);
            end
        end
        
        % Closes all documents that are open in the manager across all
        % workspaces
        function closeAllVariables(this)
            for i=length(this.Documents):-1:1
                if isvalid(this.Documents(i))
                    this.closevar(this.Documents(i).Name, this.Documents(i).Workspace);
                end
            end
            
            this.Documents = [];
            this.Workspaces = containers.Map;
            this.WorkspaceCounts = containers.Map;
        end
        
        % Returns a boolean to indicate if the given variable name is already
        % open in the given workspace or not. 
        function isVarOpen = isVariableOpen(this, name, ws)
            if nargin < 3 || isempty(ws)
                ws = 'caller';
            end
			
			% Performance optimization
            if this.IgnoreUpdates
                isVarOpen = false;
                return;
            end

            workspace = this.getWorkspace(ws);
            docIndex = this.documentIndex(name, workspace);
            
            isVarOpen = ~isempty(docIndex) && ~this.IgnoreUpdates && ...
                    isvalid(this.Documents(docIndex)) && ...
                    isequal(this.Documents(docIndex).DataModel.Workspace, workspace);
        end
        
        % Returns the Adapter class name to use for the given data.
        % varClass: the classname of the data
        % varSize: the size of the data
        % data: the actual data which is opened in the variable editor
        function classname = getAdapterClassNameForData(~, varClass, ...
                varSize, data)
            classname = '';
            varDims = length(varSize);

            switch (varClass)
                case internal.matlab.variableeditor.NumericArrayDataModel.NumericTypes
                    if ~issparse(data) && varDims==2
                        classname = 'internal.matlab.variableeditor.MLNumericArrayAdapter';
                    end
                    
                case 'struct'
                    if varDims==2 && varSize(1)==1 && varSize(2)==1
                        classname = 'internal.matlab.variableeditor.MLStructureAdapter';
                    elseif varDims==2 && (varSize(1)==1 || varSize(2)==1)
                        classname = 'internal.matlab.variableeditor.MLStructureArrayAdapter';
                    elseif varDims == 2 && (varSize(1) ~= 0 || varSize(2) ~= 0)
                        classname = 'internal.matlab.variableeditor.MLObjectArrayAdapter';
                    end
                    
                case 'table'
                    if varDims==2
                        classname = 'internal.matlab.variableeditor.MLTableAdapter';
                    end
                    
                case {'categorical' 'nominal' 'ordinal'}
                    % Treat categorical, nominal and ordinal all the same
                    if varDims==2
                        classname = 'internal.matlab.variableeditor.MLCategoricalAdapter';
                    end
               
                case 'timetable'
                    if varDims==2
                        classname = 'internal.matlab.variableeditor.MLTableAdapter';
                    end
                    
                case 'cell'
                    if varDims==2
                        classname = 'internal.matlab.variableeditor.MLCellArrayAdapter';
                    end
                    
                case 'datetime'
                    if varDims==2
                        classname = 'internal.matlab.variableeditor.MLDatetimeArrayAdapter';
                    end
                    
                case 'duration'
                    if varDims==2
                        classname = 'internal.matlab.variableeditor.MLDurationArrayAdapter';
                    end
                    
                case 'calendarDuration'
                    if varDims==2
                        classname = 'internal.matlab.variableeditor.MLCalendarDurationArrayAdapter';
                    end
                    
                case 'char'
                    if varDims == 2 && varSize(1) <= 1 && varSize(2) <= internal.matlab.variableeditor.FormatDataUtils.MAX_TEXT_DISPLAY_LENGTH
                        classname = 'internal.matlab.variableeditor.MLCharArrayAdapter';
                    end
                    
                case 'string'
                    if varDims == 2 && ~(isequal(varSize, [1,1]) && strlength(data) > internal.matlab.variableeditor.FormatDataUtils.MAX_TEXT_DISPLAY_LENGTH)
                        classname = 'internal.matlab.variableeditor.MLStringArrayAdapter';
                    end
                    
                case 'logical'
                    if varDims==2
                        classname = 'internal.matlab.variableeditor.MLLogicalArrayAdapter';
                    end
                    
                case {'tall', 'timerange'}
                     classname = 'internal.matlab.variableeditor.MLUnsupportedAdapter';

                otherwise
                    if isa(data, 'matlab.system.SystemImpl')
                        % MATLAB system objects should be shown in the
                        % unsupported view
                        classname = [];                    
                    elseif isobject(data) || all(all(ishandle(data)))
                        if ~issparse(data) && varDims == 2
                            if isnumeric(data)
                                % Objects which claim to be numeric can be
                                % displayed in the numeric array view (like
                                % fi, gpuArray, etc...)
                                classname = 'internal.matlab.variableeditor.MLNumericArrayAdapter';
                            elseif (isequal(varSize, [1, 1]) || numel(data) == 1)
                                % For UDD object types, display in
                                % unsupportedViewModel
                                if (isempty(meta.class.fromName(class(data))))
                                    classname = [];                                    
                                elseif (~isa(data, 'handle') || (~ismethod(data, 'isvalid') || isvalid(data))) ...
                                        && ~isa(data, 'internal.matlab.variableeditor.NullValueObject')
                                    % Scalar objects.  Invalid objects are
                                    % shown in the unsupported view.
                                    classname = 'internal.matlab.variableeditor.MLObjectAdapter';
                                else
                                    classname = [];
                                end
                            else
                                % Object Arrays.  Object arrays of size 0x0
                                % are shown in the unsupported view                                
                                classname = 'internal.matlab.variableeditor.MLObjectArrayAdapter';
                            end
                        end
                    end
            end
            
            if isempty(classname)
                classname = 'internal.matlab.variableeditor.MLUnsupportedAdapter';
            end
        end
        
        % getVariableAdapter - Returns the adapter class to use for the
        % specified data
        function varAdapter = getVariableAdapter(this, name, ws, ...
                varClass, varSize, data)
            % Determine the Variable Adapter class for the given variable         
            if isempty(ws)
                ws = 'caller';
            end

            % Get the mapped workspace
            workspace = this.getWorkspace(ws);
            
            % Get the adapter class name
            classname = this.getAdapterClassNameForData(varClass, ...
                varSize, data);
            
            % Convert the class name to a constructore function, and call
            % it with the appropriate arguments
            constructor = str2func(classname);
            varAdapter = constructor(name, workspace, data);
        end

        % getVariableAdapterClassType - Returns the class type being
        % handled by the adapter for the given variable.  This is necessary
        % because a given class type (like struct) can be handled by
        % different adapters, depending on the size.
        function varDataName = getVariableAdapterClassType(this, ...
                varClass, varSize, data)

            % Get the adapter class name
            classname = this.getAdapterClassNameForData(varClass, ...
                varSize, data);
            
            % If the adapter class implements a getClassType method, call
            % it.  Otherwise, just use the variable class (varClass)
            if ismethod(classname, 'getClassType')
                fnc = str2func([classname '.getClassType']);
                varDataName = fnc();
            else
                varDataName = varClass;
            end
        end
        
        % getWorkspaceKey
        % This will return a key generated for the workspace object.  If
        % the workspace object is already a string (i.e. caller or base)
        % then that key will be returned.
        function key = getWorkspaceKey(this, workspace)
            key = '';

            if ischar(workspace)
                key = workspace;
            else
                keys = this.Workspaces.keys;
                for i=1:length(keys)
                    if (this.Workspaces(keys{i}) == workspace)
                        key = keys{i};
                        return;
                    end
                end
            end
        end

        % registerWorkspace
        % Register a workspace with a particular key
        function registerWorkspace(this, workspace, wsKey)      
            this.Workspaces(wsKey) = workspace;
            this.RegisteredWorkspaces(wsKey) = workspace;
        end

        % deregisterWorkspace
        % Deregsiters a workspace
        function deregisterWorkspace(this, wsKey)
            % Remove it from the registry
            if ~isempty(this.RegisteredWorkspaces) && this.RegisteredWorkspaces.isKey(wsKey)
                this.RegisteredWorkspaces.remove(wsKey);
            end

            % Attempt to remove the workspace if there are not open
            % documents, otherwise once all documents are closed it will
            % automatically be removed since it will no longer be in the
            % registry
            if ~isempty(this.Workspaces) && this.Workspaces.isKey(wsKey)
                workspace = this.getWorkspace(wsKey);
                this.removeWorkspace(workspace);
            end
        end
    end
end
