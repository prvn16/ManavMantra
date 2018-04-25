classdef PlotsTabListeners < handle
    % Adds Listeners to the variable editor and workspace browser selection
    % events so that the appropriate plots in the plots gallery can be
    % enabled.
    
    % Copyright 2013-2015 The MathWorks, Inc.
    properties
        % factory objects gets instances of the variable editor and
        % workspace browser managers
        factory;
        managerFocusGainedListener;
        
        % variable editor listeners
        veManager;
        veManagerFocusGainedListener;
        veDocumentFocusGainedListener;
        veSelectionChangeListener;
        veDocumentClosedListener;
        veDataChangedListener;
        veDocumentTypeChangedListener; 
        
        % workspace browser listeners
        wbManager;
        wbSelectionChangedListener;
        
        % timers for variable editor and workspace browser
        %selectionVETimer;
        %selectionWBTimer;
        
        % cache to store the previous selection to allow swapping
        prevSelectedFieldsWB;
        prevSelectedFieldsVE;
        
        % subscribing for events on the client side
        figSubscription;
        swapSubscription;
        
    end
    
    methods(Access='private')
        
        % This function adds the workspace browser and variable editor selection listeners
        function addPlotsGalleryListeners(this)            
            % instantiate a factory object to keep track of which manager
            % has focus
            this.factory = internal.matlab.variableeditor.peer.PeerManagerFactory.getInstance();
             this.managerFocusGainedListener = event.listener(this.factory, 'ManagerFocusGained',...
                 @(es, ed)this.handleManagerFocusEvents(ed));
            
            %------------ Variable Editor Listeners ----------------------%
            
            % create a variable editor manager
            % listen to manager focus gained events
            % if manager gains focus, add a document focus gained listener
            this.veManager = internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance.PeerManager;
            
            % the veManager and document may gain focus at the same time.
            % Hence the document focus listener is added simultaneously.
            this.veDocumentFocusGainedListener = event.listener(this.veManager, 'DocumentFocusGained',...
                @(es, ed) this.handleVEDocumentFocus(es, ed));
                        
            % Document closed listener so that when the last tab is closed,
            % the plots gallery reacts to ve collapse
            this.veDocumentClosedListener = event.listener(this.veManager, 'DocumentClosed',...
                @(es, ed) this.handleDocumentClosed());

            
            %------------- Workspace Browser Listeners -------------------%
            
            % create workspace manager
            % listen to the wb manager focus gained events
            % when the workspace gains focus, listen to selection changed
            % events
			% we also need a listener to the dataChanged event in the
            % workspace so that the selected variable can be updated in the
            % plots gallery
            this.wbManager = internal.matlab.workspace.peer.PeerWorkspaceBrowser.getInstance.Manager;
            this.wbSelectionChangedListener = event.listener(this.wbManager.Documents.ViewModel, 'SelectionChanged',...
                @(es, ed) internal.matlab.plotstab.PlotsTabListeners.handleWBSelectionChange(ed.EventName));
            
            %------------Listener for variables swapped event and Resuse figure state change-------------%
            
            this.swapSubscription = message.subscribe('/PlotsChannel', @(es)this.swap(es));
            this.figSubscription = message.subscribe('/PlotsChannel', @(es)this.handleCreateNewFig(es));
            if isempty(this.swapSubscription) || isempty(this.figSubscription)
                delete(sInstance);
            end
        end
        
        % This function to call the method which swaps the currently selected
        % variables in the workspace browser
        function swap(this, es)
            if strcmp(es.eventType,'variablesSwapped')
                plotsTabInstance = internal.matlab.plotstab.PlotsTabState.getInstance();
                if strcmp(plotsTabInstance.currentManagerForPlotsTab, this.veManager.Channel)
                    this.handleVESelectionChange(es.eventType);
                else
                    this.handleWBSelectionChange(es.eventType);
                end
            end
        end
        
        function handleCreateNewFig(this, es)
            if strcmp(es.eventType, 'figureCreationChanged')
                % the createfig object value is modified
                plotsTabInstance = internal.matlab.plotstab.PlotsTabState.getInstance();
                plotsTabInstance.createNewFig = es.createNewFigure;
                
                % then send the new execution strings
                if strcmp(plotsTabInstance.currentManagerForPlotsTab, char(this.wbManager.Channel))
                    this.handleWBSelectionChange(es.eventType);
                else
                    this.handleVESelectionChange(es.eventType);
                end
            end
        end
        
        % This function adds a listener to listen to selection change events.
        % This listener is added when the variable editor gains focus.
        function handleVEDocumentFocus(this, es, ed)
            plotsTabInstance = internal.matlab.plotstab.PlotsTabState.getInstance();
            plotsTabInstance.currentManagerForPlotsTab = char(this.veManager.Channel);
            % Call the selectionChange method to update the plots gallery.
            % This allows the plots gallery to reflect the correct
            % selection while switching between different document tabs             
            internal.matlab.plotstab.PlotsTabListeners.handleVESelectionChange(ed.EventName);
            
            % event.listener ensures that when this document view model
            % goes out of scope, the listener tied to it no longer exists
            if isa(es.FocusedDocument.ViewModel,'internal.matlab.variableeditor.SelectionModel')
                this.veDocumentTypeChangedListener = event.listener(es.FocusedDocument, 'DocumentTypeChanged',...
                     @(es, ed) this.handleDocTypeChanged(ed.EventName));
                 this.veSelectionChangeListener = event.listener(es.FocusedDocument.ViewModel,...
                    'SelectionChanged', @(es, ed) internal.matlab.plotstab.PlotsTabListeners.handleVESelectionChange(ed.EventName));
            end
        end        
        
%         % This function sets a timer so that selection events are not fired on
%         % each individual cell during a drag action in the variable editor
%         function throttleVESelectionEvents(this, ed)
%             if isempty(this.selectionVETimer)
%                this.selectionVETimer = timer('TimerFcn', @(~, ~) internal.matlab.plotstab.PlotsTabListeners.handleVESelectionChange(ed.EventName), 'StartDelay',0.08);
%             end
%             
%             % resets the timer when a new event is fired. This way the
%             % selection is handled only when the drag action is completed
%             stop(this.selectionVETimer);
%             start(this.selectionVETimer);
%         end
%         
%         % This function sets a timer so that selection events are not fired on
%         % each individual cell during a drag action in the workspace
%         % browser
%         function throttleWBSelectionEvents(this, es, ed)
%             if isempty(this.selectionWBTimer)
%                 this.selectionWBTimer = timer('TimerFcn', @(~, ~) internal.matlab.plotstab.PlotsTabListeners.handleWBSelectionChange(es, false, ed.EventName), 'StartDelay',0.08);
%             end
%             
%             % resets the timer when a new event is fired. This way the
%             % selection is handled only when the drag action is completed
%             stop(this.selectionWBTimer);
%             start(this.selectionWBTimer);
%         end
        
        function handleDocumentClosed(this)
            event = 'selectionChanged';
            filteredData = struct('eventType',char(event));
            filteredPlotItems = struct('tag',{},'executionStsring',{});
            varsSelectedArray = cell(1,0);
            filteredData.items = filteredPlotItems;
            filteredData.variables = varsSelectedArray;
            if isempty(this.veManager.Documents)
                message.publish('/PlotsChannel', filteredData);
            end
        end
               
        
        function handleManagerFocusEvents(this, ed)
        plotsTabStateInstance = internal.matlab.plotstab.PlotsTabState.getInstance();
            if strcmp(ed.Manager.Channel, '/WorkspaceBrowser') && ...
                    ~isempty(this.wbManager) && ...
                    ~isempty(this.wbManager.Channel)
					% check if the currently active manager cached in the PlotsTabState(plotsTabStateInstance.currentManagerForPlotsTab) 
                    % and the new manager(this.wbManager.Channel) are the same. If not then 
					% execute selection changed call back 
					if ~isequal(plotsTabStateInstance.currentManagerForPlotsTab, char(this.wbManager.Channel))
						plotsTabStateInstance.currentManagerForPlotsTab = char(this.wbManager.Channel);
						this.wbSelectionChangedListener.Enabled = true;
						this.handleWBSelectionChange(ed.EventName);
					end
            elseif strcmp(ed.Manager.Channel, '/VariableEditor') && ...
                    ~isempty(this.veManager) && ...
                    ~isempty(this.veManager.Channel)
					% check if the currently active manager cached in the PlotsTabState(plotsTabStateInstance.currentManagerForPlotsTab) 
                    % and the new manager(this.veManager.Channel) are the same. If not then 
					% execute selection changed call back 
					if ~isequal(plotsTabStateInstance.currentManagerForPlotsTab, char(this.veManager.Channel))
						plotsTabStateInstance.currentManagerForPlotsTab = char(this.veManager.Channel);
						this.wbSelectionChangedListener.Enabled = false;
						this.handleVESelectionChange(ed.EventName);
					end
            end
        end
        
        function handleDocTypeChanged(this, eventname)
            if isa(this.veManager.FocusedDocument.ViewModel,'internal.matlab.variableeditor.SelectionModel')
                this.veSelectionChangeListener = event.listener(this.veManager.FocusedDocument.ViewModel,...
                    'SelectionChanged', @(es, ed) internal.matlab.plotstab.PlotsTabListeners.handleVESelectionChange(ed.EventName));
            end
            internal.matlab.plotstab.PlotsTabListeners.handleVESelectionChange(eventname);
        end
    end
    
    methods(Access='public')
        % For testing purpose only
        function callHandleManagerFocusEvents(this, ed)
            this.handleManagerFocusEvents(ed);
        end
    end
    
    methods(Static=true)        
        % This function ensures that the state of the listeners is a
        % singleton.
        function out = getInstance()
            persistent sInstance;
            mlock;
            if isempty(sInstance) || ~isvalid(sInstance)
                sInstance = internal.matlab.plotstab.PlotsTabListeners;
                sInstance.addPlotsGalleryListeners();
            end
            out = sInstance;
        end
        

                
        % This function gets the formatted string for the selected cells, and
        % calls the event which sends this data to the client. Since the
        % current workspace at this instant is not the base workspace, this
        % call is executed using a web worker.
        function formattedSelection = handleVESelectionChange(eventName)
            this = internal.matlab.plotstab.PlotsTabListeners.getInstance();
            formattedSelection = '';
            if strcmp(eventName, 'variablesSwapped')
                fieldsSelected = strsplit(this.prevSelectedFieldsVE, ';');
                if length(fieldsSelected) == 2
                    temp = fieldsSelected{1};
                    fieldsSelected{1} = fieldsSelected{2};
                    fieldsSelected{2} = temp;
                end
                formattedSelection = [fieldsSelected{1} ';' fieldsSelected{2}];
            elseif ~isempty(this.veManager.FocusedDocument) && isa(this.veManager.FocusedDocument.ViewModel,'internal.matlab.variableeditor.SelectionModel')            
                if isa(this.veManager.FocusedDocument.ViewModel.DataModel.Workspace, 'internal.matlab.variableeditor.MLWorkspace') && ...
                     ~this.veManager.FocusedDocument.ViewModel.DataModel.Workspace.supportsPlotGallery 
                    this.handlePrivateWorkspaceSelection(this.veManager.FocusedDocument.ViewModel.DataModel.Workspace,{},eventName);
                    return
                end
                formattedSelection = this.veManager.FocusedDocument.ViewModel.getFormattedSelection();
            end
            
            % Create a cell array containing a string representaiton of the 
            % selected data as a cell array e.g. '{data.Age(1:100);data.Weight(1:100)}'
            selectionRange = {strcat('{',formattedSelection,'}')};   
            
            % to allow swapping
            this.prevSelectedFieldsVE = formattedSelection;
            
            % The call to handle selection method (which evaluates the execution 
            % strings of the selected data) needs to be called using a web 
            % worker since we will not be in the same workspace as the 
            % variables at this instant of execution
            % Here we build a string which represents the call to
            % handleSelection and pass it to the web worker for evaluation.
            % Create a string literal representation of the selected
            % variables, e.g., '{'data.Column1(1:100)','data.Column2(1:100)'}'
            if ~isempty(formattedSelection)
                selectionVarNames = internal.matlab.plotstab.PlotsTabUtils.getSelectionVarNamesForVariableEditor(formattedSelection);
                selectionVarNamesLiteral = ['{''' selectionVarNames{1} ''''];
                for k=2:length(selectionVarNames)
                    selectionVarNamesLiteral = [selectionVarNamesLiteral ,',''',selectionVarNames{k} '''']; %#ok<AGROW>
                end
                selectionVarNamesLiteral = [selectionVarNamesLiteral,'}'];
            else
                selectionVarNamesLiteral = '{}';
                selectionVarNames = {};
            end
            
            % For private workspaces which support the Plot Gallery,
            % internal.matlab.plotstab.PlotsTabUtils.handleSelection
            % should be called directly since the selected 
            % variables can be derived from a call to the MLWokspace
            % evalin() method
            if ~isempty(this.veManager.FocusedDocument) && isa(this.veManager.FocusedDocument.ViewModel,'internal.matlab.variableeditor.SelectionModel') && ...
                     isa(this.veManager.FocusedDocument.ViewModel.DataModel.Workspace, 'internal.matlab.variableeditor.MLWorkspace')
                 this.handlePrivateWorkspaceSelection(this.veManager.FocusedDocument.ViewModel.DataModel.Workspace,selectionVarNames,eventName);
            else 
                execCommandString = strcat('[~] = internal.matlab.plotstab.PlotsTabUtils.handleSelection(',selectionRange,',', selectionVarNamesLiteral , ',''', eventName , ''')');
                com.mathworks.datatools.variableeditor.web.WebWorker.executeCommand(execCommandString);
            end
        end
        
        % This function constructs the string with the information about the
        % currently selected workspace variables and calls the function
        % which communicates this data to the client
        function handleWBSelectionChange(eventName)
            this = internal.matlab.plotstab.PlotsTabListeners.getInstance();
            selectedFields = {};
            if strcmp(eventName, 'variablesSwapped')
                % the 2 variables in the cached selection are swapped
                if length(this.prevSelectedFieldsWB) == 2
                    temp = this.prevSelectedFieldsWB{1};
                    this.prevSelectedFieldsWB{1} = this.prevSelectedFieldsWB{2};
                    this.prevSelectedFieldsWB{2} = temp;
                end
                selectedFields = this.prevSelectedFieldsWB;                    
            else
                if ~isempty(this.wbManager.FocusedDocument.ViewModel.SelectedRowIntervals)             
                     if isa(this.wbManager.FocusedDocument.ViewModel.DataModel.Workspace,'internal.matlab.variableeditor.MLWorkspace') && ...
                        ~this.wbManager.FocusedDocument.ViewModel.DataModel.Workspace.supportsPlotGallery 
                         this.handlePrivateWorkspaceSelection(this.wbManager.FocusedDocument.ViewModel.DataModel.Workspace,{},eventName);
                         return;
                     end
                    selectedFields = this.wbManager.FocusedDocument.ViewModel.SelectedFields;
                end
            end
            % selectedFields is a 1xn cell array, where n is the number of
            % selected rows. Each cell contains a cell which contains the 
            % name of the selected variable
            
            % TODO: getSelectedFieldsString returns a cell array not a
            % string. Method and variable name should be renamed
            selectedFieldsString = this.getSelectedFieldsString(selectedFields);

            % the previous selection is remembered to allow swapping
            this.prevSelectedFieldsWB = selectedFields;

            % Create a string literal representation of the selected
            % variables, e.g., '{'a','b'}'
            if ~isempty(selectedFieldsString)
                selectionNames = strsplit(selectedFieldsString,',');
                selectionVarNamesLiteral = ['{''' selectionNames{1} ''''];
                for k=2:length(selectionNames)
                    selectionVarNamesLiteral = [selectionVarNamesLiteral ,',''',selectionNames{k} '''']; %#ok<AGROW>
                end 
                selectionVarNamesLiteral = [selectionVarNamesLiteral,'}'];
            else
                selectionVarNamesLiteral = '{}';
            end

            % For private workspaces which support the Plot Gallery,
            % internal.matlab.plotstab.PlotsTabUtils.handleSelection
            % should be called directly since the selected 
            % variables can be derived from a call to the MLWokspace
            % evalin() method
            if isa(this.wbManager.FocusedDocument.ViewModel.DataModel.Workspace,'internal.matlab.variableeditor.MLWorkspace')
                 this.handlePrivateWorkspaceSelection(this.wbManager.FocusedDocument.ViewModel.DataModel.Workspace,selectionNames,eventName);
            else   
                 % The string containing the current selection is passed to the
                 % function which communicates this data to the client. This is
                 % done via a web worker since we are not in the base workspace
                 % at this instant       
                 execCommandString = strcat('[~] = internal.matlab.plotstab.PlotsTabUtils.handleSelection(','{',selectedFieldsString,'},', selectionVarNamesLiteral , ',''',eventName,''')');
                 com.mathworks.datatools.variableeditor.web.WebWorker.executeCommand(execCommandString);
            end
        end
        
        function selectedFieldsString = getSelectedFieldsString(selectedFields)
            % SelectedFields is a 1xn cell array, where n is the number of
            % selected rows or an empty cell array. Each cell contains 
            % a cell which contains the name of the selected variable
            selectedFieldsString = '';
            for k = 1:length(selectedFields)
                if k>1
                    selectedFieldsString = strcat(selectedFieldsString, ',');
                end
                if iscell(selectedFields{k}) && ~isempty(selectedFields{k})
                    selectedFieldsString = strcat(selectedFieldsString, selectedFields{k}{1});
                elseif ischar(selectedFields{k})
                    selectedFieldsString = strcat(selectedFieldsString, selectedFields{k});
                end
            end
        end
        
        function publishData = handlePrivateWorkspaceSelection(ws,selectionNames,eventName)
             if ws.supportsPlotGallery
                     % Create a length(selectionVarNames)-by-1 cell array
                     % containing the actual selected data
                     selectedData = cell(length(selectionNames),1);
                     for k=1:length(selectedData)
                         selectedData{k} = ws.evalin(selectionNames{k});
                     end
                     % Selection in private workspace with no execution
                     % strings
                     publishData = internal.matlab.plotstab.PlotsTabUtils.handleSelection(...
                         selectedData,selectionNames,eventName,true);
             else
                     publishData = internal.matlab.plotstab.PlotsTabUtils.handleSelection(...
                         {},{},eventName,true);
             end
        end
        
    end
    
%     methods
%         % destructor called when the plotsTabListener object is deleted.
%         % The delete method is overridden to ensure that the timers are
%         % deleted from the memory once the object is destroyed
%         function delete(this)
%             %delete(this.selectionVETimer);
%             %clear this.selectionVETimer;
%             %delete(this.selectionWBTimer);
%             %clear this.selectionWBTimer;
%         end
%     end
end







