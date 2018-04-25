classdef PropertyInspectorManager < handle
    
    % PropertyInspectorManager: Corresponds to the property inspector.
    % This class takes care of inspecting the properties for the graphic
    % objects such as axes, figure, line etc.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Constant)
        % Used to set minimum height on the inspector window
        DEFAULT_FIGURE_SIZE = get(0,'defaultFigurePosition');
    end
    
    properties(SetAccess = private, GetAccess = public)
        % PropertyUndoRedoManager helps in performing undo/redo actions
        % for figure propinserty changes.
        PropertyUndoRedoManager
        
        % Reference to the currently inspected figure
        CurrentFigure
        
        % Reference to the currently inspected object
        CurrentObject
        
        % Plot-Selection Change Listener
        PlotSelectListener
        
        % Undo/Redo addCommand Listener
        PropertyChangedListener
        
        % One-shot listener to listener to plot-edit mode being enabled
        PlotEditModeListener
        
        % Flag to not show the inspector window when closed manually by the
        % user
        IsInspectorClosedManually = false
        
        % g1694798: If OS is supported
        IsUnSupportedPlatform = false
        
        % Listener for current figure being destroyed
        FigureBeingDestroyedListener
    end
    
    methods (Static)
        % PropertyInspectorManager class is a singleton
        function h = getInstance(~)
            mlock
            persistent hInspectorManager;
            if isempty(hInspectorManager)
                hInspectorManager = matlab.graphics.internal.propertyinspector.PropertyInspectorManager();
            end
            h = hInspectorManager;
        end
        
        % Forces to show Java property inspector
        function doShowJavaInspector = showJavaInspector(state)
            persistent showInspectorFlag;
            if nargin >=1
                showInspectorFlag = state;
            end
            
            if isempty(showInspectorFlag)
                doShowJavaInspector = false;
            else
                doShowJavaInspector = showInspectorFlag;
            end
            
            if ~isempty(doShowJavaInspector) && ~doShowJavaInspector
                munlock matlab.graphics.internal.propertyinspector.PropertyInspectorManager;
                clear matlab.graphics.internal.propertyinspector.PropertyInspectorManager;
            end
        end
        
        % Called from the Java Property Inspector to find out if the
        % different figure is selected, then show the property editor
        % alongside. Handler to figure gained focus/figure window activated.
        % This helps in moving the inspector window based on which figure window
        % in plot-edit mode gets focus
        function showPropertyInspectorIfNeeded(dtClient)
            this = matlab.graphics.internal.propertyinspector.PropertyInspectorManager.getInstance();
            hFig = getfigurefordesktopclient(dtClient);
            if ~isempty(hFig)
                % Early return if the figure is invalid or is being
                % deleted. This happens when figure gets activated
                % while clicking on Close Window button.
                if ~isvalid(hFig) || strcmpi(hFig.BeingDeleted,'on')
                    return;
                end
                
                % Don't show the inspector window if inspector is
                % closed manually
                if ~this.IsInspectorClosedManually
                    if ~isequal(hFig,this.CurrentFigure)
                        if isactiveuimode(hFig,'Standard.EditPlot')
                            hMode = getuimode(hFig,'Standard.EditPlot');
                            if ~isempty(hMode)
                                selectedObject = hMode.ModeStateData.PlotSelectMode.ModeStateData.SelectedObjects;
                                styleSelectionHandles(hFig);
                                this.showInspector(selectedObject);
                            end
                        else
                            % There are situations when figure window
                            % focus listener is fired but plot-edit
                            % mode has not yet enabled on the java
                            % figure. Add a one-shot listener to listen
                            % to plot-edit mode being enabled
                            if isempty(this.PlotEditModeListener)
                                this.addPlotEditModeListener(hFig);
                            end
                        end
                    elseif isequal(hFig,this.CurrentFigure) && isactiveuimode(hFig,'Standard.EditPlot')
                        % Bring the inspector window to front if the same
                        % figure gets focus again
                        this.bringInspectorWindowToFront();
                    end
                end
            end
            
        end
        
        % Called from the Java Property Inspector to find out if the
        % different figure is selected, then show the property editor
        % alongside. Handler to figure gained focus/figure window activated.
        % This helps in moving the inspector window based on which figure window
        % in plot-edit mode gets focus
        function showInspectorForDockedFigure(dtClient, figureFrame)
            this = matlab.graphics.internal.propertyinspector.PropertyInspectorManager.getInstance();
            hFig = getfigurefordesktopclient(dtClient);
            if ~isempty(hFig)
                % Early return if the figure is invalid or is being
                % deleted. This happens when figure gets activated
                % while clicking on Close Window button.
                if ~isvalid(hFig) || strcmpi(hFig.BeingDeleted,'on')
                    return;
                end
                
                % Don't show the inspector window if inspector is
                % closed manually
                if ~this.IsInspectorClosedManually
                    % There are situations when figure window
                    % focus listener is fired but plot-edit
                    % mode has not yet enabled on the java
                    % figure. Add a one-shot listener to listen
                    % to plot-edit mode being enabled
                    if ~isactiveuimode(hFig,'Standard.EditPlot') && isempty(this.PlotEditModeListener)
                        this.addPlotEditModeListener(hFig);
                    end
                    if ~isequal(hFig,this.CurrentFigure)
                        if isactiveuimode(hFig,'Standard.EditPlot')
                            this.setFigureWindowFrame(figureFrame);
                            hMode = getuimode(hFig,'Standard.EditPlot');
                            if ~isempty(hMode)
                                selectedObject = hMode.ModeStateData.PlotSelectMode.ModeStateData.SelectedObjects;
                                styleSelectionHandles(hFig);
                                this.showInspector(selectedObject);
                            end
                        end
                    elseif isequal(hFig,this.CurrentFigure) && isactiveuimode(hFig,'Standard.EditPlot')
                        % Bring the inspector window to front if the same
                        % figure gets focus again
                        this.setFigureWindowFrame(figureFrame);
                        this.bringInspectorWindowToFront();
                    end
                end
            end
            
        end
        
        function closeAllInspectorDropDowns()
            defaultInspectorInstance = internal.matlab.inspector.peer.InspectorFactory.getInspectorInstances;
            
            if defaultInspectorInstance.isKey('/PropertyInspector')
                inspectorDocumentModel = defaultInspectorInstance('/PropertyInspector');
                inspectorDocumentModel.Documents.ViewModel.handleFocusLost();
            end
        end
        
        % If the property inspector window is closed manually,
        % inspector window will remain closed. Only context-menu or
        % inspect function or double-clicking or re-enabling plot-edit mode
        % can reopen the property inspector
        function setInspectorClosedManually(~)
            this = matlab.graphics.internal.propertyinspector.PropertyInspectorManager.getInstance();
            
            this.IsInspectorClosedManually = true;
            this.removeListenersAndRestoreSelection();
        end
        
        % Remove plot-selection listener and restore selection handles on
        % all figures in plot-edit mode
        function removeListenersAndRestoreSelection(~)
            this = matlab.graphics.internal.propertyinspector.PropertyInspectorManager.getInstance();
            
            % Remove the plot selection change listener
            delete(this.PlotSelectListener);
            this.PlotSelectListener = [];
            
            % Remove the figure destroy listener
            delete(this.FigureBeingDestroyedListener);
            this.FigureBeingDestroyedListener = [];
            
            % Need to delete the timer because we are only hiding the
            % inspector, and not deleting it (to help with performance).
            % The timer will be recreated when the inspector is opened
            % again.
            deleteTimer();
            
            % restore selection handles of all the figures in plot-edit
            % mode
            styleSelectionHandles();
        end
        
        % Returns true if we are in MATLAB Online and false otherwise.
        function isMatlabOnline = isMatlabOnline()
            isMatlabOnline = matlab.internal.environment.context.isMATLABOnline || ...
                matlab.ui.internal.desktop.isMOTW;
        end
    end
    
    methods (Access = public,Hidden = true)
        % Show the inspector jFrame and position the window relative to the
        % figure
        function initInspector(this,hFig)
            if ~isempty(hFig) && any(isvalid(hFig))
                if ~isempty(this.CurrentFigure) && isvalid(this.CurrentFigure)
                    % Style the selection handles in the figure
                    styleSelectionHandles(hFig);
                end
            end
            
            this.CurrentFigure = hFig;
            
            this.initJavaPropertyInspectorManager();
            
            % Set the height of the inspector window
            this.setInspectorHeight();
            
            this.IsInspectorClosedManually = false;
            
            % Setup the plot selection change listener
            if isempty(this.PlotSelectListener)
                this.initPlotSelectListener();
            end
            
            % Delete the listener for the previous figure if existing so
            % that only one current figure destroy listener exists at any
            % time.
            if ~isempty(this.FigureBeingDestroyedListener)
                delete(this.FigureBeingDestroyedListener);
                this.FigureBeingDestroyedListener = [];
            end
            this.initFigureBeingDestroyedListener();
        end
        
        % Show the Inspector Window and inspect the currently selected
        % object.
        function showInspector(this,objToInspect)
            % g1711013 get the object handle from hObjs. In case hObjs passed is
            % double(figure) etc
            objToInspect = handle(objToInspect);
            if ~isempty(objToInspect) && any(isvalid(objToInspect))
                hFig = ancestor(objToInspect(1),'figure');
                
                this.initInspector(hFig);
                
                % Inspect the current object
                this.inspectObj(objToInspect);
                
                % Set the title of the inspector window
                this.setTitle(objToInspect);
            end
        end
        
        % Add one-shot listener to listener to plot-edit mode being enabled
        function addPlotEditModeListener(this,hFig)
            % Get the modemanager and add a listener to respond to
            % plot-edit mode being enabled
            hManager = uigetmodemanager(hFig);
            this.PlotEditModeListener = addlistener(hManager,...
                'CurrentMode','PostSet',@(e,d)this.showWhenPlotEditEnabled(e,d,hFig));
        end
        
        % Dispose the InspectorFrame and the desktop client
        function closePropertyInspector(this)
            % Need to delete inspector manager, to make sure all timer
            % objects are deleted on closing the inspector window
            this.hideInspectorWindow();
            this.CurrentFigure = [];
            this.IsInspectorClosedManually = true;
        end
    end
    
    methods (Access = private)
        % handler to show inspector when plot-edit mode is enabled
        function showWhenPlotEditEnabled(this,~,d,hFig)
            % Show inspector when plot-edit mode is enabled
            hMode = d.AffectedObject.CurrentMode;
            if ~isempty(hMode) && strcmpi(hMode.Name,'Standard.EditPlot')
                selectedObjects = hMode.ModeStateData.PlotSelectMode.ModeStateData.SelectedObjects;
                styleSelectionHandles(hFig);
                this.showInspector(selectedObjects);
            end
            
            % Remove the one-shot plot edit mode listener
            delete(this.PlotEditModeListener);
            this.PlotEditModeListener = [];
        end         
        
        function initPlotSelectListener(this)
            % Get the plotmgr and add a listener to respond to clicks in
            % Plot Edit mode
            plotmgr = feval(graph2dhelper('getplotmanager'));
            this.PlotSelectListener  = event.listener(plotmgr,'PlotSelectionChange',@this.localChangedSelectedObjectsCallback);
        end
        
        function initFigureBeingDestroyedListener(this)
            this.FigureBeingDestroyedListener  = event.listener(this.CurrentFigure, ...
                'ObjectBeingDestroyed',@(e,d) this.hideInspectorWindow());
        end
        
        % Plot Selection change event handler for the figure
        function localChangedSelectedObjectsCallback(this,~,eventData)
            if ~this.IsInspectorClosedManually
                this.showInspector(eventData.SelectedObjects);
            end
        end
        
        % Set the title onto the inspector window
        function setTitle(this,hObj)
            if numel(hObj) == 1
                % Set the title of the inspector window based on the figure
                % window
                objTypeString = hObj.Type;
                objTypeString(1) = upper(objTypeString(1));
                titleString = objTypeString;
                if ~isempty(this.CurrentFigure) && isvalid(this.CurrentFigure)
                    titleString = ['Figure ',num2str(this.CurrentFigure.Number),': ',titleString];
                end
            else
                resBundle = javaMethodEDT('getBundle','java.util.ResourceBundle',...
                    'com.mathworks.mde.inspector.resources.RES_PropView');
                
                titleString = char(resBundle.getString('status.MultipleObjects'));
                
                if ~isempty(this.CurrentFigure) && isvalid(this.CurrentFigure)
                    titleString = ['Figure ',num2str(this.CurrentFigure.Number),...
                        ': ',titleString];
                end
            end
            
            this.setInspectorWindowTitle(titleString);
        end
        
        % Set the height of the inspector window. Default width set is 350
        function setInspectorHeight(this)
            if ~isempty(this.CurrentFigure) && isvalid(this.CurrentFigure)
                figureToolBarHeight = this.CurrentFigure.OuterPosition(4) - this.CurrentFigure.Position(4);
                defaultFigureHeight = this.DEFAULT_FIGURE_SIZE(4)+figureToolBarHeight;
                this.setInspectorWindowSize(defaultFigureHeight);
            end
        end
    end
    
    methods(Access = protected)
        % Initializes the java inspector window
        function initJavaPropertyInspectorManager(this)
            % Current Figure's Window Frame is needed to add Window
            % Listeners onto the figure
            com.mathworks.page.plottool.propertyinspectormanager.PropertyInspectorManager.setCurrentFigure(this.CurrentFigure,matlab.graphics.internal.getFigureJavaFrame(this.CurrentFigure));
            
            % Position the inspector window relative to the current figure
            com.mathworks.page.plottool.propertyinspectormanager.PropertyInspectorManager.setInspectorWindowLocation();
            
            com.mathworks.page.plottool.propertyinspectormanager.PropertyInspectorManager.showInspector();
        end
        
        % bring java inspector window to the front
        function bringInspectorWindowToFront(~)
            com.mathworks.page.plottool.propertyinspectormanager.PropertyInspectorManager.bringInspectorToFront();
        end
        
        % Hide Inspector Window
        function hideInspectorWindow(this)
            com.mathworks.page.plottool.propertyinspectormanager.PropertyInspectorManager.hideInspector();
            this.removeListenersAndRestoreSelection();
        end
        
        % Sets the size of the inspector window
        function setInspectorWindowSize(~,figureHeight)
            com.mathworks.page.plottool.propertyinspectormanager.PropertyInspectorManager.setInspectorWindowSize(figureHeight);
        end
        
        % Sets the title on the window
        function setInspectorWindowTitle(~,titleString)
            com.mathworks.page.plottool.propertyinspectormanager.PropertyInspectorManager.setInspectorWindowTitle(titleString);
        end
        
        % Sets the figureFrame on the window
        function setFigureWindowFrame(~,figureFrame)
            com.mathworks.page.plottool.propertyinspectormanager.PropertyInspectorManager.setFigureWindowFrame(figureFrame);
        end
        
        % Initial Setup. Happens only once when PropertyInspectorManager is
        % instantiated
        function this = PropertyInspectorManager(~)
            com.mathworks.page.plottool.propertyinspectormanager.PropertyInspectorManager.createPropertyInspectorManager();
            
            % If the platform is unsupported or is MATLAB Online, show old
            % java inspector g1699881
            if this.isMatlabOnline() || ...
                    com.mathworks.page.plottool.propertyinspectormanager.PropertyInspectorManager.isPlatformUnSupported()
                this.IsUnSupportedPlatform = true;
                return;
            end
            
            % This is needed so that the server-side
            % DefaultPropertyInspector is ready to show. Inspector startup
            internal.matlab.inspector.peer.DefaultPropertyInspector.startup;
            
            % PropertyUndoRedoManager helps in performing undo/redo actions
            % for figure property changes.
            this.PropertyUndoRedoManager = matlab.graphics.internal.propertyinspector.PropertyUndoRedoManager.getInstance();
        end
        
        % Inspect the selected object
        function inspectObj(this,obj)
            % Call DefaultPropertyInspector's inspect method
            defaultInspectorInstance = internal.matlab.inspector.peer.InspectorFactory.getInspectorInstances;
            
            if defaultInspectorInstance.isKey('/PropertyInspector') && any(isvalid(obj))
                inspectorDocumentModel = defaultInspectorInstance('/PropertyInspector');
                % Close the error dialog if showing previously. Make sure,
                % Documents and ViewModel exists since they can empty
                % before calling inspect
                if ~isempty(inspectorDocumentModel.Documents) && ~isempty(inspectorDocumentModel.Documents.ViewModel)
                    inspectorDocumentModel.Documents.ViewModel.handleSelectChange();
                end
                
                if isempty(this.CurrentObject) || ~isequal(obj,this.CurrentObject)
                    
                    inspectorDocument = inspectorDocumentModel.inspect(obj,...
                        internal.matlab.inspector.MultiplePropertyCombinationMode.INTERSECTION,...
                        internal.matlab.inspector.MultipleValueCombinationMode.LAST);
                    
                    this.CurrentObject = obj;
                    
                    % ViewModel changes when we change the selection. Need to listen to
                    % the new view everytime
                    % DataChange event is thrown from PeerInspectorViewModel and
                    % PropertyUndoRedoManager needs the eventdata to add the
                    % undoredo command onto the figure uiundo stack
                    this.PropertyChangedListener = event.listener(inspectorDocument.ViewModel, 'DataChange', ...
                        @(e,d)this.PropertyUndoRedoManager.addCommandToUiUndo(e,d,this.CurrentFigure));
                end
            end
        end
    end
end

% helper function to delete the timer
% Need to delete the timer because we are only hiding the
% inspector, and not deleting it (to help with performance).
% The timer will be recreated when the inspector is opened
% again.
function deleteTimer()
t = timerfindall('Name', 'veHandleObj_inspector');
if ~isempty(t)
    stop(t);
    delete(t);
end
end
