function varargout = toolbareditor(varargin)
% TOOLBAREDITOR GUI
%       TOOLBAREDITOR is a Graphical User Interface that allows GUI
%       designers in MATLAB to interactively create a toolbar for their
%       GUIs.
%
%       TB = TOOLBAREDITOR(...) runs the GUI and returns a toolbar object
%       once the OK button is pressed.

%       TOOLBAREDITOR('Property','Value',...) runs the GUI. This GUI
%       accepts property value pairs from the input arguments. Starting
%       from the left, property value pairs are applied to the GUI figure.
%       The following custom properties are also supported that can be used
%       to initialize this GUI. The names are not case sensitive:
%         'caller'        who is calling Toolbar Editor. Use for GUIDE and
%                         testing
%         'callerapi'     the API functions by which Toolbar Editor can
%                         talk to GUIDE
%       Other unrecognized property name or invalid value is ignored.

%   Copyright 1984-2014 The MathWorks, Inc.

% Declare non-UI data here so that they can be used in any functions in
% this GUI file.

%**************************************************************************
% Turning off uitabgroup warnings
%**************************************************************************
oldState = warning('off','MATLAB:uitabgroup:OldVersion');
warnCleaner = onCleanup(@() warning(oldState));
%**************************************************************************

mInputArgs      =   varargin;   % Command line arguments when invoking the GUI
mOutputArgs     =   {};         % Variable for storing output when GUI returns

% Variables for supporting custom property/value pairs
mPropertyDefs   =   {...        % The supported custom property/value pairs of this GUI
    'caller',      @localValidateInput, 'mCaller';
    'callerapi',   @localValidateInput, 'mCallerAPI'};
mCaller         =   '';         % The source who invoked this editor
mCallerAPI      =   struct();   % The struct that contains the function handles for working with the caller

% Process the command line input arguments supplied when the GUI is
% invoked
processUserInputs();

% do GUI loading time tasks and then return

% set up action table. The 'action' and 'user' entries should be filled up
% when the GUI is populated.
mActionTable = createActionTable();

% Setup the main window's user interface
mFigurePosition = [0 0 600 535];  % The figure will have a fixed position/size
hToolbarHostFigure=[]; %used to host the toolbar if a figure is not passed in
hEditorFigure = figure(...
    'menubar','none',...
    'toolbar','none',...
    'resize','on',...
    'dockcontrols','off',...
    'Position',mFigurePosition,...
    'IntegerHandle','off',...
    'Name',getUserString('FigureName'),...
    'Tag','ToolbarEditorTag',...
    'Visible','off',...
    'Renderer','zbuffer',...    % uicontrol selected property does not work on MAC with painters
    'numbertitle','off', ...
    'handleVisibility','callback',...
    'KeyPressFcn',@figureKeyPress,...
    'WindowButtonMotionFcn',@figureButtonMotion,...
    'WindowButtonUpFcn',@dropPreviewTool);

% Create the Toolbar Preview
hPreviewContextMenu = uicontextmenu('parent', hEditorFigure);
hPreviewToolbarContextMenu = uicontextmenu('parent', hEditorFigure);
mPreviewSelectionIndex = [];
hDropIndicator = uicontrol(...
    'Style','frame',...
    'Parent',hEditorFigure,...
    'BackgroundColor','black',...
    'Visible','off');
hPreviewPanel = uipanel(...
    'Parent',hEditorFigure,...
    'BorderType','none',...
    'Title',getUserString('ToolbarLayoutTitle'),...
    'Units','pixels',...
    'Position',[0,470,mFigurePosition(3),50]);
hPreviewLayout = uipanel(...
    'Parent', hPreviewPanel,...
    'Title','',...
    'BorderType','line',...
    'BorderWidth',1,...
    'Uicontextmenu',hPreviewToolbarContextMenu,...
    'ButtonDownFcn',@clickInToolbar,...
    'Units','pixels',...
    'Position',[3 5,mFigurePosition(3)-50, 27]);
mPreviewPosition = getpixelposition(hPreviewLayout, true);
hPreviewHelpText = uicontrol(...
    'Parent',hEditorFigure,...
    'Style', 'Text',...
    'Uicontextmenu',hPreviewToolbarContextMenu,...
    'Enable', 'inactive',...
    'Units','pixels',...
    'Position',[mPreviewPosition(1)+3,mPreviewPosition(2)+2,mPreviewPosition(3)-6,mPreviewPosition(4)-8],...
    'String', getUserString('ToolbarLayoutHelp'));
mPreviewTools = struct('style', {}, 'handle', {}, 'icon', {}, 'key',{});
% Create an empty structure that will hold the buttons style, handle and order(index into the structure)
mPreviewToolStyle = struct(...
    'width', 20,...
    'height', 20,...
    'interval', 3,...
    'separatorWidth',8);

% create and/or populate the toolbar being edited and its tools
hFinalToolbar = [];
hFinalToolbarTools = [];
mFinalToolbarCurrentToolIndex = [];     % index of current tool whose properties are shown
% counter for the number of tools in the final toolbar and in preview
mToolbarToolCounter = 0;

%todo can they be moved to local functions?
clickedMouseButton = [];
toolStartingPositions = [];

% create the property page tab panel
mPropertyButtonStyle = struct(...
    'labelWidth', 120,...
    'editorWidth', 150,...
    'height', 25,...
    'horizontalInterval', 10,...
    'verticalInterval', 5,...
    'verticalOffset', -5);
hPropertyTabPanel = uitabgroup(...
    'Parent',hEditorFigure,...
    'Units','pixels',...
    'position',[280,70,mFigurePosition(3)-280-20,360],...
    'SelectionChangedFcn',@changePropPanel);
hToolbuttonPropertyTab = uitab(...
    'Parent',hPropertyTabPanel,...
    'Title', getUserString('ToolPropertyPanelTitle'),...
    'Tag','_ToolbuttonPropertyTab');   % UITAB to contain the tool properties/menu
hToolbarPropertyTab = uitab(...
    'Parent',hPropertyTabPanel,...
    'Title',getUserString('ToolbarPropertyPanelTitle'));   % UIPANEL to contain the toolbar properties/menu
% Setup the layout inside the button properties panel:
hToolPropertyControls = [];
updateToolPropPanel();
% Setup the layout inside the toolbar properties panel:
% this needs to follow updateToolPropPanel()
hToolbarPropertyControls = [];
updateToolbarPropPanel();

% create the tool palette panel
mIsDraggingFromPalette = false;   % A Variable to track whether an object is being dragged.
mIsDraggingFromPreview = false;   % A Variable to track whether an object is being dragged.
mPaletteSelectionIndex = [];
mOrder = [];
mPassedTools = [];
hPaletteButtons = [];
hToolPalettePanel=[];

mPaletteButtonStyle = struct(...
    'buttonWidth', 108,...
    'labelHeight', 15,...
    'buttonHeight', 25,...
    'paletteBackground', get(0,'defaultuicontrolbackgroundcolor'),...
    'sectionBackground', get(0,'defaultuicontrolbackgroundcolor'),...
    'sectionForeground', get(0,'defaultuicontrolforegroundcolor'),...
    'selectionBackground', get(0,'defaultuicontrolbackgroundcolor')-0.1,...
    'horizontalInterval', 10,...
    'verticalInterval', 4);

% create the control buttons for add/remove/reorder
hControlPanel = [];
updateControlButtons();

% create the tool palette panel
createToolPalette();

% create the button panel
createButtonPanel();

% build the context menu that will be added to each tool preview
buildPreviewToolContextMenu();

% create or populate toolbar
createFinalToolbar([],[],true);

% Make changes needed for proper look and feel and running on different
% platforms
prepareLayout(hEditorFigure);
set(hEditorFigure, 'resize','off');

% make the first tool the selected tool
if ~isempty(hFinalToolbarTools)
    if ~isempty(mActionTable) && ~isempty(mActionTable.changeToolbarSelection.action)
        mActionTable.changeToolbarSelection.action(hFinalToolbarTools(1));
    end
end

% put the editor on screen
movegui(hEditorFigure,'center');
set(hEditorFigure,'visible','on');
% Restore uitabgroup warning state since this dialog is non-modal
delete(warnCleaner)

% add api for child tools to insert their own testing API
mChildToolTestingAPI = struct();
mCallerAPI.testing.setChildToolTestingAPI = @setChildToolTestingAPI;

% Send proper output
if isGUIDETool
    mOutputArgs{1} = guide2tool;
end
if nargout>0
    [varargout{1:nargout}] = mOutputArgs{:};
end

    % Debugging Function
    function debuggingFunction(hObject,eventdata) %#ok MLINT
        keyboard
        %         VIS = get(hFinalToolbar,'Visible');
        %         switch VIS
        %             case 'on'
        %                 set(hFinalToolbar,'Visible','off');
        %                 set(hObject,'String','Show')
        %             case 'off'
        %                 set(hFinalToolbar,'Visible','on');
        %                 set(hObject,'String','Hide')
        %         end
    end

    % When mouse button is released, execute the dropPreviewTool function
    function dropPreviewTool(hObject,eventdata)
        set(hEditorFigure,'pointer','arrow')
        set(hDropIndicator,'visible','off')
        if mIsDraggingFromPalette
            if ~isempty(mPaletteSelectionIndex)
                switch clickedMouseButton
                    case 'normal'
                        if ~isempty(mOrder)
                            %        disp('Dropped inside the Toolbar')
                            dummyTool = createDummyPreviewTool;
                            if max(mPassedTools) ~= mToolbarToolCounter && mToolbarToolCounter > 0
                                mPreviewTools = insertElement(mPreviewTools, mOrder, dummyTool);            % Insert the new element at its location in the structure
                            end
                            if ~isempty(mActionTable) && ~isempty(mActionTable.add.action)
                                mActionTable.add.action(hObject, eventdata, mOrder);
                            end
                        end
                        mOrder = [];
                    case 'open'
                        if ~isempty(mActionTable) && ~isempty(mActionTable.add.action)
                            mActionTable.add.action(hObject, eventdata);
                        end
                end

            end
            updateToolPropPanel();
            mIsDraggingFromPalette = false;
        end
        if mIsDraggingFromPreview
            if ~isempty(mPreviewSelectionIndex)
                if ~isempty(mOrder)
                    %        disp('Dropped inside the Toolbar')
                    mOrder;    % Locate where the new element will be placed in the tool structure based on drop location
                    POS = mPreviewSelectionIndex;
                    if POS < mOrder
                        for NEWPOS = POS:mOrder-1
                            mActionTable.swap.action(hObject,eventdata,NEWPOS+1,NEWPOS);
                            mPreviewTools = swapElements(mPreviewTools, NEWPOS+1, NEWPOS);
                            swapWithPreviousHiddenTool(hObject,eventdata, NEWPOS+1);
                            mPreviewSelectionIndex = mPreviewSelectionIndex +1;
                            mFinalToolbarCurrentToolIndex = mPreviewSelectionIndex;

                            updateToolPropPanel();
                        end
                    else
                        if mOrder < 1
                            mOrder = 1;
                        end
                        for NEWPOS = POS:-1:mOrder+1
                            mActionTable.swap.action(hObject,eventdata,NEWPOS-1,NEWPOS);
                            mPreviewTools = swapElements(mPreviewTools, NEWPOS, NEWPOS-1);
                            swapWithPreviousHiddenTool(hObject,eventdata, NEWPOS);
                            mPreviewSelectionIndex = mPreviewSelectionIndex -1;
                            mFinalToolbarCurrentToolIndex = mPreviewSelectionIndex;

                            updateToolPropPanel();
                        end
                    end
                    mOrder = [];
                end
            end
            mIsDraggingFromPreview = false;
        end
    end

    % Create a dummy tool for use as a placeholder in the tool structure
    function dummy = createDummyPreviewTool
        dummy.style = 'none';   % Set up a dummy structure element (placeholder)
        dummy.handle = 0;
        dummy.icon = zeros(16,16,3);
        dummy.key = 'dummy';
        %dummy.properties = [];
    end

    function changePropPanel(hObject, eve)%#ok MLint
        ch = get(hObject,'Children');
        tabChild = ch(1);        
        selectedTab = get(hObject,'SelectedTab');
        % SelectedTab could be empty going forward and hence it would be
        % good to do an early return. 
        if (isempty(selectedTab))
            return;
        end
        if isequal(selectedTab, handle(tabChild))
            % tool
            setActionEnabled('moreproperty',~isempty(hFinalToolbarTools));
        else
            % toolbar 
            setActionEnabled('moreproperty',ishandle(hFinalToolbar));
        end
    end

    % Display an indicator for where the dragged tool will be dropped
    function figureButtonMotion(hObject, eve)
        if mIsDraggingFromPalette || mIsDraggingFromPreview
            existingTools = findobj(hEditorFigure,'tag','PreviewTool');
            allPos = {};
            for i=1:length(existingTools)
                allPos{end+1} = getpixelposition(existingTools(i));
            end
            %allPos = get(existingTools,'position');
            if iscell(allPos)
                toolStartingPositions = zeros(length(allPos),1);
                for i = 1:length(allPos)
                    toolStartingPositions(i) = allPos{i}(1);
                end
            elseif ~isempty(allPos)
                toolStartingPositions(1) = allPos(1);
            end
            toolStartingPositions = sort(toolStartingPositions);
            oldunit = get(hEditorFigure, 'Units');
            set(hEditorFigure,'Units','Pixels');
            dropLocation = get(hEditorFigure,'currentPoint');
            set(hEditorFigure,'Units',oldunit);

            oldunit = get(hPreviewLayout, 'Units');
            set(hPreviewLayout,'Units','Pixels');
            previewLayoutPosition = get(hPreviewLayout, 'position');
            set(hPreviewLayout,'Units',oldunit);
            if dropLocation(2)<mPreviewPosition(2) || dropLocation(2)>(mPreviewPosition(2) + mPreviewPosition(4))
                %        disp('Moving outside the Toolbar')
                mOrder = [];
            else
                %        disp('Moving inside the Toolbar')
                mPassedTools = find(toolStartingPositions <= (dropLocation(1)-3*mPreviewToolStyle.width/4));
                if isempty(mPassedTools)
                    mPassedTools = 0;
                end
                if max(mPassedTools) == mToolbarToolCounter
                    mOrder = mToolbarToolCounter +1;
                elseif mToolbarToolCounter > 0
                    mOrder = min(mPassedTools(end)+1, mToolbarToolCounter+1);    % Locate where the new element will be placed in the tool structure based on drop location
                else
                    mOrder = 1;
                end
            end
            if mIsDraggingFromPreview
                if mOrder>mToolbarToolCounter
                    mOrder = mToolbarToolCounter;
                end
                posOffset = [mPreviewToolStyle.width*double(mOrder>mPreviewSelectionIndex) 0 0 0];
            else
                posOffset = [0 0 0 0];
            end
            if ~isempty(mPreviewTools) && ~isempty(mOrder)
                if mOrder<=mToolbarToolCounter && ishandle(mPreviewTools(mOrder).handle)
                    curUnits = get(mPreviewTools(mOrder).handle,'units');
                    set(mPreviewTools(mOrder).handle,'units','pixels');
                    curLocPos = get(mPreviewTools(mOrder).handle,'position');
                    set(mPreviewTools(mOrder).handle,'units',curUnits);
                    set(hDropIndicator,'Units','pixels','visible','on','position',[curLocPos(1),mPreviewPosition(2)-12,2,10]+posOffset);
                elseif mOrder>mToolbarToolCounter
                    curUnits = get(mPreviewTools(mOrder-1).handle,'units');
                    set(mPreviewTools(mOrder-1).handle,'units','pixels');
                    curLocPos = get(mPreviewTools(mOrder-1).handle,'position');
                    set(mPreviewTools(mOrder-1).handle,'units',curUnits);
                    set(hDropIndicator,'Units','pixels','visible','on','position',[curLocPos(1),mPreviewPosition(2)-12,2,8]+posOffset+[mPreviewToolStyle.width 0 0 0]);
                end
            end
        end
    end

    % Move selection when pressing arrow keys
    function figureKeyPress(hObject, eve)
        if ~isempty(mActionTable) && isfield(mActionTable, 'setPaletteSelection')
            changed = false;
            index = mPaletteSelectionIndex;
            switch eve.Key
                case 'downarrow'
                    index = index +2;
                    changed = true;
                case 'rightarrow'
                    index = index +1;
                    changed = true;
                case 'uparrow'
                    index = index -2;
                    changed = true;
                case 'leftarrow'
                    index = index -1;
                    changed = true;
                case 'return'
                    % add selected palette button to toolbar
                    if ~isempty(mActionTable.add.action)
                        mActionTable.add.action([], []);
                    end
                case 'delete'
                    % delete the currently selected toolbar tool
                    if ~isempty(mPreviewSelectionIndex) && strcmpi(get(mPreviewTools(mPreviewSelectionIndex).handle, 'Selected'), 'on')
                        if ~isempty(mActionTable.delete.action)
                            mActionTable.delete.action([], []);
                        end
                    end
                otherwise
            end

            if changed && ~isempty(mActionTable.setPaletteSelection.action)
                if index<=0
                    index =1;
                end
                if index>length(hPaletteButtons)
                    index = length(hPaletteButtons);
                end
                mActionTable.setPaletteSelection.action(index);
            end
        end
    end

    function clickInToolbar(hObject,eventdata) %#ok MLINT
        mActionTable.changeToolbarSelection.action(hFinalToolbar);
        updateControlButtons();
    end

    % Swap two elements in the Structure
    function STRUC = swapElements(STRUC,ELEM1, ELEM2)
        TEMP = STRUC(ELEM1);
        STRUC(ELEM1) = STRUC(ELEM2);
        STRUC(ELEM2) = TEMP;
    end

    % Insert a tool (ELEM) into the tools structure(STRUC) in position POS
    function STRUC = insertElement(STRUC, POS, ELEM)
        if POS <= length(STRUC)
            STRUC(POS+1:end+1) = STRUC(POS:end);
        end
        STRUC(POS) = ELEM;
    end

    % Remove a tool (POS) from the tools structure(STRUC)
    function [STRUC, COUNT] = removeElement(hObject,eventdata,STRUC, POS) %#ok MLINT

        STRUC(POS) = [];
        COUNT = mToolbarToolCounter -1;

    end

    % Create a Tool inside the preview toolbar
    function BUTTON = createPreviewTool(hObject,STYLE, ICON, TOOLTIP, ORDER, hiddenTool)
        % constants used for the tool preview
        if ORDER<mToolbarToolCounter && mToolbarToolCounter>1
            mActionTable.shiftRight.action(hObject,[],ORDER);
        end
        BUTTON.style = STYLE;
        BUTTON.handle = uicontrol(...
            'parent',hPreviewPanel,...
            'style','radiobutton',...
            'CData',ICON,...
            'Units','pixel',...
            'position',getPreviewToolPosition(ORDER),...
            'Tooltip',TOOLTIP,...
            'enable','inactive',...
            'tag','PreviewTool',...
            'ButtonDownFcn',@clickOnPreviewTool,...
            'Uicontextmenu', hPreviewContextMenu);
        set(BUTTON.handle, 'units', 'normalized');
        BUTTON.icon = ICON;
        BUTTON.key = get(hiddenTool, 'Tag');

        %add listeners for all the properties
        listenToPropertyChange(hiddenTool, BUTTON.handle);

        % Select a tool if clicked on it in the toolbar
        function clickOnPreviewTool(hObject,eventdata)%#ok MLINT
            clickBuffer = 2;
            oldunit = get(hEditorFigure, 'Units');
            set(hEditorFigure,'Units','Pixels');
            clickLoc = get(hEditorFigure,'currentPoint');
            set(hEditorFigure,'Units',oldunit);
            objPos = getpixelposition(hObject);
            if (clickLoc(1)- objPos(1) < clickBuffer) || (objPos(1) + objPos(3) - clickLoc(1) <clickBuffer)
                %   disp('too close to edge')
            else
                existingTools = findobj(hEditorFigure,'tag','PreviewTool');
                set(existingTools,'selected','off')
                allPos = {};
                for i=1:length(existingTools)
                    allPos{end+1} = getpixelposition(existingTools(i));
                end
                if iscell(allPos)
                    toolStartingPositions = zeros(length(allPos),1);
                    for i = 1:length(allPos)
                        toolStartingPositions(i) = allPos{i}(1);
                    end
                elseif ~isempty(allPos)
                    toolStartingPositions(1) = allPos(1);
                end
                toolStartingPositions = sort(toolStartingPositions);
                mPreviewSelectionIndex = [];
                selPos = getpixelposition(hObject);
                selOrder = find(toolStartingPositions == selPos(1));
                mPreviewSelectionIndex = selOrder;

                % change selection
                selectFinalToolbarTool(hFinalToolbarTools(selOrder));

                mIsDraggingFromPreview = true;
                SEL = mFinalToolbarCurrentToolIndex;
                PTR = round(mean(get(mPreviewTools(mPreviewSelectionIndex).handle,'CData'),3))+1;
                if strcmp(get(hFinalToolbarTools(SEL),'separator'),'on')
                    PTR = PTR(:,mPreviewToolStyle.separatorWidth:end);      % Make sure the actual CData shows up as a pointer shadow, not the separator
                end
                S = size(PTR);
                PTR = [PTR; nan(16-S(1), S(2))];
                PTR = [PTR, nan(16, 16-S(2))];
                PTR(1,:) = 2; PTR(:,1) = 2; PTR(:,16) = 1; PTR(16,:) = 1;
                set(hEditorFigure,'pointer','custom','PointerShapeCData',PTR(1:16,1:16),'PointerShapeHotSpot',[9 9]);

                updateControlButtons();
                updateToolPropPanel();
            end
        end

        % connect with property change from Inspector if this editor is used
        % alone
        function listenToPropertyChange(tool, toolpreview)
            %add listeners for all the properties. Only do this is this editor
            %is running alone
            if ~isGUIDETool
                obj = handle(tool);
                props = fieldnames(get(obj));
                for i=1:length(props)
                    addlistener(double(obj), props{i}, 'PostSet', @(s,e)propertyChanged(s,e));
                end
            end

            function propertyChanged(src, eve) %#ok MLINT
                updateWhenPropertyChange(eve.AffectedObject, toolpreview);
            end

        end

        function previewToolPos = getPreviewToolPosition(ORDER)
            if ORDER>1
                previousToolPos = getpixelposition(mPreviewTools(ORDER-1).handle);
                previewToolPos = [previousToolPos(1) + previousToolPos(3) + mPreviewToolStyle.interval , 8,mPreviewToolStyle.width,mPreviewToolStyle.height];
            else
                previewToolPos = [mPreviewToolStyle.interval + 3, 8,mPreviewToolStyle.width,mPreviewToolStyle.height];
            end
        end
    end

    function toggleSeparatorPreview(which)
        %disp(['add ' num2str(CurT)])
        mPreviewToolStyle.separatorWidth = 8;
        tool = hFinalToolbarTools(which);
        toolpreview = mPreviewTools(which).handle;

        if isequal(get(tool,'Separator'),'on')
            % do this only when separator is not added
            if isequal(size(get(tool, 'cdata')), size(get(toolpreview,'cdata')))
                Cdat = get(tool,'CData');
                Cdat = [nan(size(Cdat,1), 1, 3) 1/2*ones(size(Cdat,1), 1, 3) ones(size(Cdat,1), 1, 3) nan(size(Cdat,1), 5, 3) Cdat];
                setpixelposition(toolpreview, getpixelposition(toolpreview) + [0 0 mPreviewToolStyle.separatorWidth 0]);
                set(toolpreview,'CData',Cdat);
                for i = (which+1):mToolbarToolCounter
                    setpixelposition(mPreviewTools(i).handle,getpixelposition(mPreviewTools(i).handle)+[mPreviewToolStyle.separatorWidth 0 0 0])
                end
            end
        else
            % do this only when separator is added
            if ~isequal(size(get(tool, 'cdata')), size(get(toolpreview,'cdata')))
                setpixelposition(toolpreview,getpixelposition(toolpreview)-[0 0 mPreviewToolStyle.separatorWidth 0]);
                set(toolpreview,'CData',get(tool, 'cdata'));
                for i = (which+1):mToolbarToolCounter
                    setpixelposition(mPreviewTools(i).handle,getpixelposition(mPreviewTools(i).handle)-[mPreviewToolStyle.separatorWidth 0 0 0]);
                end
            end
        end
    end

    % Default Properties for a new button
    function propStruct = getDefaultProperties(STYLE)
        styleSelect = {'push','other'};
        STYLE = styleSelect{min(STYLE,2)};
        propStruct = struct();
        propNames = {    'BeingDeleted',    'BusyAction',    'ButtonDownFcn',    'CData',    'Children',    'ClickedCallback',    'Clipping',    'CreateFcn',    'DeleteFcn',    'Enable',    'HandleVisibility',    'HitTest',    'Interruptible',    'OffCallback',    'OnCallback',    'Parent',    'Selected',    'SelectionHighlight',    'Separator',    'State',    'Tag',    'TooltipString',    'Type',    'UIContextMenu',    'UserData',    'Visible'}';
        propValues = {   'off'         ,    'queue'     ,    ''             ,    []     ,    []       ,     ''               ,    'on'      ,    '','','on','on','on','on','','',[],'off','on','off','off','','',['ui' STYLE 'tool'],[],[],'on'}';
        toggleOnlyProps = [20 15 14];
        for i = 1:length(propNames)
            propStruct = setfield(propStruct,'Name',propNames);
            propStruct = setfield(propStruct,'Value',propValues);
        end
        switch STYLE
            case 'push'
                for i = toggleOnlyProps
                    propStruct.Name(i) = [];
                    propStruct.Value(i) = [];
                end
        end
    end

    % Create an actual tool in the hidden Toolbar and place it in position N.
    function createFinalToolbarTool(hObject, eventdata, N)%#ok Mlint
        toBeCreated = mPaletteSelectionIndex;
        toolid = get(hPaletteButtons(toBeCreated),'UserData');
        if toBeCreated >= 3
            hFinalToolbarTools(mToolbarToolCounter) = uitoolfactory(hFinalToolbar,toolid);
            % need to save in the GUI
            set(hFinalToolbarTools(mToolbarToolCounter), 'Serializable','on');
            set(hFinalToolbarTools(mToolbarToolCounter),'HandleVisibility','on');
        else
            if toBeCreated == 2
                hFinalToolbarTools(mToolbarToolCounter) = uitoggletool(hFinalToolbar, 'cdata',get(hPaletteButtons(toBeCreated),'cdata') );
            else
                hFinalToolbarTools(mToolbarToolCounter) = uipushtool(hFinalToolbar, 'cdata', get(hPaletteButtons(toBeCreated),'cdata'));
            end
        end

        % update callbacks so that predefined callbacks is replaced with
        % DEFAULTCALLBACK. This prevents the callback strings from being
        % saved in the GUI files
        if isGUIDETool
            guidemfile('initializeToolbarToolDefaultCallback', hFinalToolbarTools(mToolbarToolCounter),toolid);
        end

        if isGUIDETool
            mCallerAPI.addObject(hFinalToolbarTools(mToolbarToolCounter), false);
            for movingSteps = mToolbarToolCounter-1:-1:N
                mCallerAPI.moveObject(hFinalToolbarTools(movingSteps));
            end
        end

        chil = getFinalToolbarChildren();
        %Nrev = length(chil) - N +1;
        if ~isempty(chil)
            chil = flipud(chil);
            last = chil(end);
            chil(N+1:end) = chil(N:end-1);
            chil(N) = last;
            chil = flipud(chil);
            setFinalToolbarChildren(chil);
            tempHandle = hFinalToolbarTools(end);
            hFinalToolbarTools(N+1:end) = hFinalToolbarTools(N:end-1);
            hFinalToolbarTools(N) = tempHandle;
        end
    end

    function children = getFinalToolbarChildren
        show = get(0, 'showhiddenhandles');
        set(0, 'showhiddenhandles', 'on');
        children = get(hFinalToolbar,'Children');
        set(0, 'showhiddenhandles', show);
    end

    function setFinalToolbarChildren(children)
        show = get(0, 'showhiddenhandles');
        set(0, 'showhiddenhandles', 'on');
        set(hFinalToolbar,'Children', children);
        set(0, 'showhiddenhandles', show);
    end

    % Remove one of the hidden tools
    function removeFinalToolbarTool(hObject, eventdata, N) %#ok Mlint
        if ~isempty(N)
            if isGUIDETool
                mCallerAPI.removeObject(hFinalToolbarTools(N));
            end

            delete(hFinalToolbarTools(N));
            hFinalToolbarTools(N) = [];
         end
    end

    % Swap two of the hidden tools
    function swapWithPreviousHiddenTool(hObject,eventdata, RIGHTPOS) %#ok Mlint
        LEFTPOS = RIGHTPOS - 1;
        if isGUIDETool
            mCallerAPI.moveObject(hFinalToolbarTools(LEFTPOS));
        end
        chil = getFinalToolbarChildren();
        chil = flipud(chil);
        temp = chil(RIGHTPOS);
        chil(RIGHTPOS) = chil(LEFTPOS);
        chil(LEFTPOS) = temp;
        chil = flipud(chil);
        setFinalToolbarChildren(chil);
        tempHandle = hFinalToolbarTools(RIGHTPOS);
        hFinalToolbarTools(RIGHTPOS) = hFinalToolbarTools(LEFTPOS);
        hFinalToolbarTools(LEFTPOS) = tempHandle;
    end


    % Update the properties panel.
    function updateToolPropPanel(varargin)
        propDefinition = {...
            'BeingDeleted',         'Being Deleted:',            'popupmenu';...
            'BusyAction',           'Busy Action:',              'popupmenu';...
            'ButtonDownFcn',        'Button Down Function:',     'edit';...
            'CData',                getUserString('PropertyCData'),             'pushbutton';...
            'Children',             'Children:',                 'edit';...
            'ClickedCallback',      getUserString('PropertyClickedCallback'),         'edit';...
            'Clipping',             'Clipping:',                 'popupmenu';...
            'CreateFcn',            'Create Function:',          'edit';...
            'DeleteFcn',            'Delete Function:',          'edit';...
            'Enable',               getUserString('PropertyEnablethistool'),         'checkbox';...
            'HandleVisibility',     'Handle Visibility:',        'popupmenu';...
            'HitTest',              'Hit Test:',                 'popupmenu';...
            'Interruptible',        'Interruptible:',            'popupmenu';...
            'OffCallback',          getUserString('PropertyOffCallback'),             'edit';...
            'OnCallback',           getUserString('PropertyOnCallback'),              'edit';...
            'Parent',               'Parent:',                   'edit';...
            'Selected',             'Selected:',                 'popupmenu';...
            'SelectionHighlight',   'Selection Highlight:',      'popupmenu';...
            'Separator',            getUserString('PropertySeparatoronleftside'),   'checkbox';...
            'State',                'State:',                    'popupmenu';...
            'Tag',                  getUserString('PropertyTag'),                      'edit';...
            'TooltipString',        getUserString('PropertyTooltipString'),           'edit';...
            'Type',                 'Type:',                     'text';...
            'UIContextMenu',        'UIContextMenu:',            'edit';...
            'UserData',             'User Data:',                'edit';...
            'Visible',              'Visible:',                  'popupmenu'};
        % propValue = {   'off'         ,    'queue'     ,    ''             ,    []     ,    []       ,     ''               ,    'on'      ,    '','','on','on','on','on','','',[],'off','on','off','off','','','',[],[],'on'};
        pushButtonProps = 4;
        editBoxProps = [21 22];
        checkBoxProps = [10 19];
        callbackProps = [6 14 15];
        commonProps = [pushButtonProps editBoxProps checkBoxProps callbackProps];

        propRank = 0;
        % populate the property panel if not populated yet
        if isempty(hToolPropertyControls)
            hToolPropertyControls = zeros(length(commonProps),3);
            tooltipControl =[];
            pos = getpixelposition(hToolbuttonPropertyTab);
            for index = 1:length(pushButtonProps)
                hToolPropertyControls(index,1) = uicontrol(...
                    'style','text',...
                    'position',[mPropertyButtonStyle.horizontalInterval,...
                                pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index + mPropertyButtonStyle.verticalOffset,...
                                mPropertyButtonStyle.labelWidth,...
                                mPropertyButtonStyle.height],...
                    'HorizontalAlign','Left',...
                    'String',propDefinition{pushButtonProps(index),2},...
                    'Parent',hToolbuttonPropertyTab,...
                    'KeyPressFcn',@figureKeyPress);
                hToolPropertyControls(index,2) = uicontrol(...
                    'style','radiobutton',...
                    'position', [0 2 0 0] + ...
                        [mPropertyButtonStyle.horizontalInterval*2+mPropertyButtonStyle.labelWidth,...
                        pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index,...
                        mPreviewToolStyle.width,...
                        mPreviewToolStyle.height],...
                    'Parent',hToolbuttonPropertyTab,...
                    'KeyPressFcn',@figureKeyPress,...
                    'CData',nan(16,16,3));
                hToolPropertyControls(index,3) = uicontrol(...
                    'style',propDefinition{pushButtonProps(index),3},...
                    'position',[30 0 -30 0] + [mPropertyButtonStyle.horizontalInterval*2+mPropertyButtonStyle.labelWidth,...
                        pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index,...
                        mPropertyButtonStyle.editorWidth,...
                        mPropertyButtonStyle.height],...
                    'String',getUserString('PropertyEditIcon'),...
                    'Parent',hToolbuttonPropertyTab,...
                    'Tag',propDefinition{pushButtonProps(index),1});
            end
            propRank = propRank + length(pushButtonProps);
            for index = ((1:length(editBoxProps))+propRank)
                hToolPropertyControls(index,1) = uicontrol(...
                    'style','text',...
                    'position',[mPropertyButtonStyle.horizontalInterval,...
                                pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index + mPropertyButtonStyle.verticalOffset,...
                                mPropertyButtonStyle.labelWidth,...
                                mPropertyButtonStyle.height],...
                    'HorizontalAlign','Left',...
                    'String',propDefinition{editBoxProps(index - propRank),2},...
                    'Parent',hToolbuttonPropertyTab,...
                    'KeyPressFcn',@figureKeyPress);
                hToolPropertyControls(index,2) = uicontrol(...
                    'style',propDefinition{editBoxProps(index - propRank),3},...
                    'position',[mPropertyButtonStyle.horizontalInterval*2+mPropertyButtonStyle.labelWidth,...
                                pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index,...
                                mPropertyButtonStyle.editorWidth,...
                                mPropertyButtonStyle.height],...
                    'String',propDefinition{editBoxProps(index - propRank),1},...
                    'Parent',hToolbuttonPropertyTab,...
                    'Tag',propDefinition{editBoxProps(index - propRank),1});
                if strcmp(propDefinition{editBoxProps(index - propRank),1}, 'TooltipString')
                    tooltipControl = hToolPropertyControls(index,2);
                end
                hToolPropertyControls(index,3) = hToolPropertyControls(index,1);
            end
            propRank = propRank + length(editBoxProps);
            for index = ((1:length(checkBoxProps))+propRank)
                hToolPropertyControls(index,1) = uicontrol(...
                    'style','text',...
                    'Parent',hToolbuttonPropertyTab,...
                    'position',[mPropertyButtonStyle.horizontalInterval, ...
                                pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index + mPropertyButtonStyle.verticalOffset,...
                                mPropertyButtonStyle.labelWidth, ...
                                mPropertyButtonStyle.height],...
                    'String',propDefinition{checkBoxProps(index - propRank),2},...
                    'KeyPressFcn',@figureKeyPress,...
                    'visible','off');    % Create a dummy UICONTROL just to keep a valid handle in the hToolPropertyControls array The displayed string is part of the checkbox
                hToolPropertyControls(index,2) = uicontrol(...
                    'style',propDefinition{checkBoxProps(index - propRank),3},...
                    'position',[mPropertyButtonStyle.horizontalInterval,...
                                pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index,...
                                mPropertyButtonStyle.editorWidth,...
                                mPropertyButtonStyle.height],...
                    'String',propDefinition{checkBoxProps(index - propRank),2},...
                    'Parent',hToolbuttonPropertyTab,...
                    'KeyPressFcn',@figureKeyPress,...
                    'Tag',propDefinition{checkBoxProps(index - propRank),1});
                hToolPropertyControls(index,3) = hToolPropertyControls(index,1);
            end
            propRank = propRank + length(checkBoxProps);
            for index = ((1:length(callbackProps))+propRank)
                hToolPropertyControls(index,1) = uicontrol(...
                    'style','text',...
                    'position',[mPropertyButtonStyle.horizontalInterval,...
                                pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index + mPropertyButtonStyle.verticalOffset,...
                                mPropertyButtonStyle.labelWidth,...
                                mPropertyButtonStyle.height],...
                    'HorizontalAlign','Left',...
                    'String',propDefinition{callbackProps(index - propRank),2},...
                    'Parent',hToolbuttonPropertyTab);
                externalEditorWidth = 0;
                if isGUIDETool && ~isempty(mCallerAPI.editCallback)
                    externalEditorWidth = 35;
                end
                hToolPropertyControls(index,2) = uicontrol(...
                    'style',propDefinition{callbackProps(index - propRank),3},...
                    'position',[mPropertyButtonStyle.horizontalInterval*2+mPropertyButtonStyle.labelWidth,...
                                pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index,...
                                mPropertyButtonStyle.editorWidth-externalEditorWidth-mPropertyButtonStyle.horizontalInterval,...
                                mPropertyButtonStyle.height],...
                    'String',propDefinition{callbackProps(index - propRank),1},...
                    'Parent',hToolbuttonPropertyTab,...
                    'Tag',propDefinition{callbackProps(index - propRank),1});
                if externalEditorWidth>0
                    hToolPropertyControls(index,3) = uicontrol(...
                        'position',[mPropertyButtonStyle.horizontalInterval*2+mPropertyButtonStyle.labelWidth + mPropertyButtonStyle.editorWidth-externalEditorWidth, ...
                                    pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index,...
                                    externalEditorWidth,...
                                    mPropertyButtonStyle.height],...
                        'String',getUserString('EditCallback'),...
                        'Parent',hToolbuttonPropertyTab,...
                        'Callback',@editCallback,...
                        'KeyPressFcn',@figureKeyPress,...
                        'Tag',propDefinition{callbackProps(index - propRank),1});                    
                else
                    hToolPropertyControls(index,3) = hToolPropertyControls(index,1);
                end
            end

            set(hToolPropertyControls(1,3),'Callback',@openIconEditor);
            set(hToolPropertyControls([2 3],2),'Callback',@editTextBoxModifyCallback);
            set(hToolPropertyControls([4 5],2),'Callback',@checkBoxModifyCallback);
            set(hToolPropertyControls([6 7 8],2),'Callback',@editTextBoxModifyCallback);

            hToolPropertyControls = setPropValues(hToolPropertyControls, 0);

            % add supported action info to the action table
            mActionTable.editicon.action = @openIconEditor;
            mActionTable.toggleseparator.action = @toggleSeparatorProperty;
            mActionTable.toggleseparator.state = @toggleSeparatorState;
            mActionTable.edittooltip.action = {@editFinalToolbarToolTooltip, tooltipControl};
            mActionTable.moreproperty.action = {@openMoreProps, true};
            mActionTable.restoredefault.action = @restorePredefinedTool;
            mActionTable.setSelectedPropertyPage.action = @selectPropertyPage;

            addActionUser('moreproperty',...
                uicontrol(...
                'style','pushbutton',...
                'parent',hToolbuttonPropertyTab,...
                'string',mActionTable.moreproperty.name,...
                'position',[mPropertyButtonStyle.horizontalInterval*2+mPropertyButtonStyle.labelWidth, ...
                            pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*(index+2),...
                            mPropertyButtonStyle.editorWidth,...
                            mPropertyButtonStyle.height],...
                'Enable','on'));
            index =index +1;
            addActionUser('restoredefault',...
                uicontrol(...
                'style','pushbutton',...
                'parent',hToolbuttonPropertyTab,...
                'string',mActionTable.restoredefault.name,...
                'position',[mPropertyButtonStyle.horizontalInterval*2+mPropertyButtonStyle.labelWidth, ...
                            pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*(index+2),...
                            mPropertyButtonStyle.editorWidth,...
                            mPropertyButtonStyle.height],...
                'Enable','off'));
        end

        % put the controls in the right state based on the tools in the
        % toolbar
        mActionTable.setSelectedPropertyPage.action('Tool');

        SEL = mFinalToolbarCurrentToolIndex;
        if ~isempty(SEL)                
            CURHAND = hFinalToolbarTools(SEL);
            setActionEnabled('restoredefault',guidemfile('isPredefinedToolbarTool', CURHAND));

            if ~isGUIDETool
                openMoreProps([],[], false);
            end
            TYPE = get(hFinalToolbarTools(SEL),'type');

            %        currentProps = propDefinition(commonProps(propIndex),1);
            set(hToolPropertyControls(:,2),'Enable','on');
            set(hToolPropertyControls(:,3),'Enable','on');
            %                set(moreProps,'Enable','on')
            
            setCallbackEditString(hToolPropertyControls(6,2), CURHAND,'ClickedCallback');
            switch TYPE
                case 'uipushtool'
                    set(hToolPropertyControls(7,:),'visible','off');
                    set(hToolPropertyControls(8,:),'visible','off');
                case 'uitoggletool'
                    set(hToolPropertyControls(7,:),'visible','on');
                    set(hToolPropertyControls(8,:),'visible','on');
                    setCallbackEditString(hToolPropertyControls(7,2),CURHAND,'OffCallback');
                    setCallbackEditString(hToolPropertyControls(8,2),CURHAND,'OnCallback');
                    set(hToolPropertyControls(7:8,1),'enable','on');
            end

            set(hToolPropertyControls(1,2),'CData',get(CURHAND,'CData'));
            for i = [2 3]
                set(hToolPropertyControls(i,2),'String',char(get(CURHAND,propDefinition(commonProps(i),1))),'HorizontalAlign','Left');
            end

            switch get(CURHAND,'Enable')
                case 'on'
                    set(hToolPropertyControls(4,2),'Value',1)
                case 'off'
                    set(hToolPropertyControls(4,2),'Value',0)
            end
            switch get(CURHAND,'Separator')
                case 'on'
                    set(hToolPropertyControls(5,2),'Value',1)
                case 'off'
                    set(hToolPropertyControls(5,2),'Value',0)
            end
        else
            % reset all the values to the control default
            for i=1:length(hToolPropertyControls)
                [x,y] = ind2sub(size(propDefinition),find(ismember(propDefinition,get(hToolPropertyControls(i,1), 'string'),'legacy')));
                if ~isempty(x(y==2))
                    x= x(y==2);
                    propname = char(propDefinition(x,1));
                    editortype = char(propDefinition(x,3));
                    switch lower(editortype)
                        case 'pushbutton'
                            set(hToolPropertyControls(i,2),'cdata', get(0,'defaultuitoggletoolcdata'));
                        case {'edit', 'popupmenu', 'text'}
                            set(hToolPropertyControls(i,2),'string', get(0,['defaultuitoggletool' propname]));
                        case 'checkbox'
                            if  strcmpi(get(0,['defaultuitoggletool' propname]),'on')
                                value = 1;
                            else
                                value =0;
                            end
                            set(hToolPropertyControls(i,2),'value', value);
                    end
                end
            end

            set(hToolPropertyControls(:,3),'Enable','off');
            set(hToolPropertyControls(:,2),'Enable','off');
            set(hToolPropertyControls(:,1),'Enable','on');
            set(hToolPropertyControls(4:5,2),'Enable','off');
            set(hToolPropertyControls(4:5,2),'Value',0);
            %                set(moreProps,'Enable','off');            end
        end

        setActionEnabled('moreproperty',~isempty(hFinalToolbarTools));
        setActionEnabled('restoredefault',~isempty(SEL) && guidemfile('isPredefinedToolbarTool', hFinalToolbarTools(SEL)));

        function setCallbackEditString(editfield, obj, callback)
            % need to display the new callback format 
            value = guidemfile('getAutoGeneratedCallbackString', obj,callback);           
            value = guidemfile('toggelGeneratedCallbackSignature', obj,callback, value, true);
           
            set(editfield,...
                'String',value,...
                'Visible','on',...
                'HorizontalAlign','Left');
        end
               
        function editCallback(hObject,eventdata, callback)
            if isGUIDETool
                if nargin>2
                    callbackName = callback;
                else
                    callbackName = get(hObject,'Tag'); 
                end
                guidemfile('changeToolbarToolDefaultCallback', ...
                    hEditorFigure,...
                    hFinalToolbarTools(mFinalToolbarCurrentToolIndex),...
                    callbackName, mCallerAPI.editCallback);
            end
        end

        function editTextBoxModifyCallback(hObject,eventdata) %#ok Mlint
            changeProperty(hFinalToolbarTools(mFinalToolbarCurrentToolIndex), get(hObject,'Tag'), get(hObject,'String'));
        end

        function checkBoxModifyCallback(hObject,eventdata) %#ok Mlint
            STR = get(hObject,'Value');
            switch STR
                case 1
                    changeProperty(hFinalToolbarTools(mFinalToolbarCurrentToolIndex), get(hObject,'Tag'), 'on');
                case 0
                    changeProperty(hFinalToolbarTools(mFinalToolbarCurrentToolIndex), get(hObject,'Tag'), 'off');
            end
        end

        function toggleSeparatorState(varargin)
            SEL = mFinalToolbarCurrentToolIndex;
            menus = findobj(mActionTable.toggleseparator.user, 'type','uimenu');
            if ~isempty(menus)
                set(menus, 'checked',get(hFinalToolbarTools(SEL),'separator'));
            end
        end
        
        function toggleSeparatorProperty(varargin)
            SEL = mFinalToolbarCurrentToolIndex;
            if strcmp(get(hFinalToolbarTools(SEL),'separator'),'on')
                set(hFinalToolbarTools(SEL),'separator','off')
            else
                set(hFinalToolbarTools(SEL),'separator','on')
            end
            toggleSeparatorPreview(SEL);
            updateToolPropPanel
        end

        
        function editFinalToolbarToolTooltip(hObject,eventdata, tooltipControl) %#ok Mlint
            if ishandle(tooltipControl)
                uicontrol(tooltipControl);
            end
        end

        function [newCDAT, api] = openIconEditor(hObject,eventdata) %#ok Mlint
            SEL = mFinalToolbarCurrentToolIndex;
            CDAT = get(hFinalToolbarTools(SEL),'CData');
            p =fileparts(mfilename('fullpath'));
            oldpath = addpath(p);
            [newCDAT, api] = iconeditor('icon',CDAT,'caller', mCaller,'callerapi',mCallerAPI);
            path(oldpath);

            if ~isempty(newCDAT)
                CDAT = newCDAT;
                changeProperty(hFinalToolbarTools(SEL),'CData',CDAT);

                % remove separator effect and regenerate that
                if strcmpi(get(hFinalToolbarTools(SEL),'Separator'),'on')
                    set(hFinalToolbarTools(SEL),'Separator', 'off')
                    toggleSeparatorPreview(SEL);
                    set(hFinalToolbarTools(SEL),'Separator', 'on')
                    toggleSeparatorPreview(SEL);
                else
                    set(mPreviewTools(SEL).handle,'CData',CDAT);
                end

            end
        end

        function PROP = setPropValues(PROP, OBJ) %#ok Mlint
            set(PROP(2,2),'String','');
            set(PROP(3,2),'String','');
            set(PROP(6,2),'String','');
            set(PROP(7,2),'String','');
            set(PROP(8,2),'String','');
            set(PROP(:,3),'enable','off');
            set(PROP(:,2),'enable','off');
            set(PROP(:,1),'enable','on');
            set(PROP(4:5,2),'enable','inactive');
        end

        % if this is a predefined tool, go back to its default behavior
        function restorePredefinedTool(hObject, eventdata) %#ok Mlint
            % show warning dialog
            overWrite = questdlg(sprintf(getUserString('RestoreDefaultConfirmation')), ...
                get(hEditorFigure,'name'),...
                'Yes', 'No', 'No');
            if strcmpi(overWrite,'Yes')
                tool = hFinalToolbarTools(mFinalToolbarCurrentToolIndex);
                toolinfo = guidemfile('getToolbarToolInfo', tool);
                toolid =guidemfile('getToolbarToolID', toolinfo);
                % create a temporary tool
                temp = uitoolfactory(hFinalToolbar, toolid);
                set(temp, 'Serializable', 'on');
                set(temp, 'HandleVisibility', 'on');
                properties = get(temp);
                names = fieldnames(properties);
                delete(temp);

                % apply defaults except Tag
                tag = get(tool, 'Tag');
                for k=1:length(names)
                    try
                        set(tool, char(names{k}),properties.(char(names{k})));
                    catch
                    end
                end
                set(tool, 'Tag', tag);

                % update callbacks so that predefined callbacks is replaced with
                % DEFAULTCALLBACK. This prevents the callback strings from being
                % saved in the GUI files
                if isGUIDETool
                    guidemfile('initializeToolbarToolDefaultCallback', tool,toolid);
                end

                % update property panel and preview
                updateToolPropPanel();

                % notify GUIDE the property change
                if isGUIDETool
                    mCallerAPI.changeObject(tool, '');
                end
            end
        end

        % Open the inspector when clicked on the "More Properties" Button
        function openMoreProps(hObject, eventdata, activate) %#ok Mlint
            if get(hObject,'Parent') == hToolbarPropertyTab
                tool = hFinalToolbar;
            else
                if isempty(mFinalToolbarCurrentToolIndex)
                    tool =[];
                else
                    tool = hFinalToolbarTools(mFinalToolbarCurrentToolIndex);
                end
            end

            if ~isempty(tool)
                if isGUIDETool
                    mCallerAPI.inspectObject(tool);
                else
                    if activate
                        inspect(tool);
                    elseif (com.mathworks.mlservices.MLInspectorServices.isInspectorOpen)
                        inspect(tool);
                    end
                end
            end
        end
    end

    function selectPropertyPage(which)
        indexTab = hToolbuttonPropertyTab;        
        if strcmpi(which, 'Toolbar')
            indexTab = hToolbarPropertyTab;
        end
        set(hPropertyTabPanel,'SelectedTab',indexTab);
    end

    % Update the toolbar properties panel.
    function updateToolbarPropPanel(varargin)
        propDefinition = {...
            struct(...
            'name', 'Tag',...
            'string', getUserString('PropertyTag'),...
            'editor', 'edit',...
            'editorValueTarget','String',...
            'editorAction',@TBeditTextBoxModifyCallback);...
            struct(...
            'name', 'Visible',...
            'string', getUserString('PropertyMaketoolbarvisible'),...
            'editor', 'checkbox',...
            'editorValueTarget','Value',...
            'editorAction',@TBcheckBoxModifyCallbackVis);...
            };
        if isempty(hToolbarPropertyControls)
            % create toolbar property page is it is not created
            hToolbarPropertyControls = zeros(length(propDefinition),2);
            pos = getpixelposition(hToolbarPropertyTab);
            for index = 1:length(propDefinition)
                hToolbarPropertyControls(index,1) = uicontrol(...
                    'style','text',...
                    'position',[mPropertyButtonStyle.horizontalInterval,...
                                pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index + mPropertyButtonStyle.verticalOffset,...
                                mPropertyButtonStyle.labelWidth,...
                                mPropertyButtonStyle.height],...
                    'HorizontalAlign','Left',...
                    'String',propDefinition{index}.string,...
                    'KeyPressFcn',@figureKeyPress,...
                    'Parent',hToolbarPropertyTab);
                if strcmp(propDefinition{index}.editor, 'checkbox')
                    set(hToolbarPropertyControls(index,1),'vis','off');
                    pos2 = [mPropertyButtonStyle.horizontalInterval,...
                            pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index,...
                            mPropertyButtonStyle.editorWidth + mPropertyButtonStyle.labelWidth + mPropertyButtonStyle.horizontalInterval,...
                            mPropertyButtonStyle.height];
                else
                    pos2 = [mPropertyButtonStyle.horizontalInterval*2+mPropertyButtonStyle.labelWidth,...
                            pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*index,...
                            mPropertyButtonStyle.editorWidth,...
                            mPropertyButtonStyle.height];
                end
                hToolbarPropertyControls(index,2) = uicontrol(...
                    'style',propDefinition{index}.editor,...
                    'position',pos2,...
                    'String',propDefinition{index}.string,...
                    'Parent',hToolbarPropertyTab,...
                    'Tag',propDefinition{index}.name,...
                    'HorizontalAlign','Left',...
                    'Callback',propDefinition{index}.editorAction);
            end
            hToolbarPropertyControls = setTBPropValues(hToolbarPropertyControls, 0);

            mActionTable.setSelectedPropertyPage.action = @selectPropertyPage;

            addActionUser('moreproperty',...
                uicontrol(...
                'style','pushbutton',...
                'parent',hToolbarPropertyTab,...
                'string',mActionTable.moreproperty.name,...
                'position',[mPropertyButtonStyle.horizontalInterval*2+mPropertyButtonStyle.labelWidth, ...
                pos(4)-(mPropertyButtonStyle.height+mPropertyButtonStyle.verticalInterval)*(index+2),...
                mPropertyButtonStyle.editorWidth,...
                mPropertyButtonStyle.height],...
                'Enable','on'));
        end

        setActionEnabled('moreproperty',ishandle(hFinalToolbar));

        mActionTable.setSelectedPropertyPage.action('Toolbar');

        if ishandle(hFinalToolbar)
            for index = 1:length(propDefinition)
                %enable all controls
                set(hToolbarPropertyControls(index, :),'Enable','on');
                %sync editor value with the toolbar
                value = get(hFinalToolbar,propDefinition{index}.name);
                if strcmpi(propDefinition{index}.editor, 'checkbox')
                    value = strcmpi(value,'on');
                end
                set(hToolbarPropertyControls(index ,2),propDefinition{index}.editorValueTarget, value);
            end
        else
            % restore to the default
            for index=1:length(hToolbarPropertyControls)
                propname = propDefinition{index}.name;
                editortype = propDefinition{index}.editor;
                switch lower(editortype)
                    case 'pushbutton'
                        set(hToolbarPropertyControls(index,2),'cdata', get(0,'defaultuitoolbarcdata'));
                    case {'edit', 'popupmenu', 'text'}
                        set(hToolbarPropertyControls(index,2),'string', get(0,['defaultuitoolbar' propname]));
                    case 'checkbox'
                        if  strcmpi(get(0,['defaultuitoolbar' propname]),'on')
                            value = 1;
                        else
                            value =0;
                        end
                        set(hToolbarPropertyControls(index,2),'value', value);
                end
                set(hToolbarPropertyControls(index, 2),'Enable','off');
            end
        end

        function TBeditTextBoxModifyCallback(hObject,eventdata) %#ok MLINT
            changeProperty(hFinalToolbar, get(hObject,'Tag'), get(hObject,'String'));
        end

        function TBcheckBoxModifyCallbackVis(hObject,eventdata) %#ok Mlint
            value = get(hObject,'Value');
            if value ==0
                value = 'off';
            else
                value ='on';
            end

            changeProperty(hFinalToolbar, get(hObject,'Tag'), value);
        end

        function PROP = setTBPropValues(PROP, OBJ)%#ok Mlint
            set(PROP(1,2),'String','');
        end
    end

    function createToolPalette
        % get info on all the registered build-in tools
        toolInfo = uitoolfactory('getinfo');
        
        % find out how many are ready for GUIDE
        guidetools = 0;
        for i=1:length(toolInfo)
            if isfield(toolInfo(i), 'readyForGUIDE') && toolInfo(i).readyForGUIDE
                guidetools = guidetools+1;
            end
        end
        
        tabpanelpos = getpixelposition(hPropertyTabPanel);
        controlpanelpos = getpixelposition(hControlPanel);
        paletteHeight = max((ceil((guidetools+2)/2) +2) * (mPaletteButtonStyle.buttonHeight + mPaletteButtonStyle.verticalInterval)+mPaletteButtonStyle.verticalInterval, ...
                            controlpanelpos(2) + controlpanelpos(4)-tabpanelpos(2));        
        paletteWidth = 2*mPaletteButtonStyle.buttonWidth + 3*mPaletteButtonStyle.horizontalInterval;
        uipanel(...
            'parent',hEditorFigure,...
            'units','pixels',...
            'backgroundcolor',mPaletteButtonStyle.paletteBackground,...
            'position',[30,tabpanelpos(2),paletteWidth,paletteHeight],...
            'BorderType','none');   % UIPANEL to contain the button to be added
        hToolPalettePanel= uipanel(...
            'parent',hEditorFigure,...
            'units','pixels',...
            'backgroundcolor',mPaletteButtonStyle.paletteBackground,...
            'position',[15,70,paletteWidth,paletteHeight],...
            'Title',getUserString('ToolPalettePanelTitle'));   % UIPANEL to contain the button to be added
        % Create the generic toolbar tool palette entries
        paletteRow =1;
        customerLabel = uicontrol(...
            'style','text',...
            'position',[mPaletteButtonStyle.verticalInterval/2,...
            paletteHeight - paletteRow*(mPaletteButtonStyle.buttonHeight +mPaletteButtonStyle.verticalInterval)- mPaletteButtonStyle.verticalInterval,...
            mPaletteButtonStyle.buttonWidth *2 + 2*mPaletteButtonStyle.horizontalInterval,...
            mPaletteButtonStyle.labelHeight],...
            'parent',hToolPalettePanel,...
            'background',mPaletteButtonStyle.sectionBackground,...
            'foreground',mPaletteButtonStyle.sectionForeground,...
            'KeyPressFcn',@figureKeyPress,...
            'horizontalAlignment','left',...
            'String',getUserString('CustomToolSectionTitle'));
        paletteRow = paletteRow+1;
        hPaletteButtons(1) = uicontrol(...
            'style','radiobutton',...
            'position',[mPaletteButtonStyle.horizontalInterval,...
            paletteHeight - paletteRow*(mPaletteButtonStyle.buttonHeight +mPaletteButtonStyle.verticalInterval),...
            mPaletteButtonStyle.buttonWidth,...
            mPaletteButtonStyle.buttonHeight],...
            'enable','inactive',...
            'ButtonDownFcn',@paletteButtonDrag,...
            'parent',hToolPalettePanel,...
            'Tag','1',...
            'CData',pushButtonCData,...
            'KeyPressFcn',@figureKeyPress,...
            'String',getUserString('PalettePushTool')); %#ok M-lint   Generic Pushbutton to drag/select for adding
        hPaletteButtons(2) = uicontrol(...
            'style','radiobutton',...
            'position',[(mPaletteButtonStyle.horizontalInterval*2+mPaletteButtonStyle.buttonWidth),...
            paletteHeight - paletteRow*(mPaletteButtonStyle.buttonHeight +mPaletteButtonStyle.verticalInterval),...
            mPaletteButtonStyle.buttonWidth,...
            mPaletteButtonStyle.buttonHeight],...
            'enable','inactive',...
            'ButtonDownFcn',@paletteButtonDrag,...
            'parent',hToolPalettePanel,...
            'Tag','2',...
            'CData',toggleButtonCData,...
            'KeyPressFcn',@figureKeyPress,...
            'String',getUserString('PaletteToggleTool'));  %#ok M-Lint    Generic Toggle button to drag/select for adding

        paletteRow = paletteRow+1;
        workingLabel = uicontrol(...
            'style','text',...
            'position',[mPaletteButtonStyle.verticalInterval/2,...
            paletteHeight - paletteRow*(mPaletteButtonStyle.buttonHeight +mPaletteButtonStyle.verticalInterval),...
            mPaletteButtonStyle.buttonWidth *2 + 2*mPaletteButtonStyle.horizontalInterval,...
            mPaletteButtonStyle.buttonHeight-10],...
            'horizontalAlignment','left',...
            'background',mPaletteButtonStyle.sectionBackground,...
            'foreground',mPaletteButtonStyle.sectionForeground,...
            'parent',hToolPalettePanel,...
            'KeyPressFcn',@figureKeyPress,...
            'String',getUserString('PredefinedToolSectionTitle'));
        counter = 0;
        startingRow = paletteRow+1;
        tempToolbar = uitoolbar(hEditorFigure,'visible','off');

        for outer_i = 1:length(toolInfo)
            paletteRow = startingRow+floor(counter/2);

            % add to palette only when the tool is marked ready for GUIDE
            if isfield(toolInfo(outer_i), 'readyForGUIDE') && toolInfo(outer_i).readyForGUIDE
                % create a temporary tool to get its icon and other properties
                % column one
                tempTool = uitoolfactory(tempToolbar,guidemfile('getToolbarToolID',toolInfo(outer_i)));
                hPaletteButtons(counter+2+1) = uicontrol(...
                    'style','radiobutton',...
                    'position',[mPaletteButtonStyle.horizontalInterval + (counter-2*floor(counter/2))*(mPaletteButtonStyle.horizontalInterval +mPaletteButtonStyle.buttonWidth),...
                    paletteHeight - (paletteRow)*(mPaletteButtonStyle.buttonHeight +mPaletteButtonStyle.verticalInterval),...
                    mPaletteButtonStyle.buttonWidth,...
                    mPaletteButtonStyle.buttonHeight],...
                    'enable','inactive',...
                    'parent',hToolPalettePanel,...
                    'CData',get(tempTool,'CData'),...
                    'Tag',num2str(counter+2+1),...
                    'ButtonDownFcn',@paletteButtonDrag,...
                    'KeyPressFcn',@figureKeyPress,...
                    'String',toolInfo(outer_i).label,...
                    'UserData', guidemfile('getToolbarToolID',toolInfo(outer_i)));
                delete(tempTool);
                counter = counter +1;
            end
        end

        delete(tempToolbar);
        % fill palette selection function
        mActionTable.setPaletteSelection.action = @setPaletteSelectionIndex;
        mActionTable.getPaletteSelection.action = @getPaletteSelectionIndex;
        mActionTable.getSelectedPaletteButton.action = @getSelectedButton;
        mActionTable.getPaletteButtonCount.action = @getButtonCount;
        mActionTable.setPaletteSelection.action(1);

        % Generic Icon for a togglebutton
        function PCD = toggleButtonCData()
            PCD = ones(16,16);
            PCD(3:4,4:13) = 0;
            PCD(5:14,8:9) = 0;
            PCD= [PCD PCD PCD];
            PCD = reshape(PCD,16,16,3);

        end

        % Generic Icon for a pushbutton
        function PCD = pushButtonCData()
            PCD = ones(16,16);
            PCD(3:4,7:10) = 0;
            PCD(8:9,7:10) = 0;
            PCD(3:14,5:6) = 0;
            PCD(3:9,11:12) = 0;
            PCD= [PCD PCD PCD];
            PCD = reshape(PCD,16,16,3);
        end

        function index = getPaletteSelectionIndex
            index = mPaletteSelectionIndex;
        end

        function button = getSelectedButton
            button = hPaletteButtons(getPaletteSelectionIndex);
        end

        function count = getButtonCount
            count = length(hPaletteButtons);
        end

        % Un-select the palette buttons if clicked in palette
        function setPaletteSelectionIndex(toolindex)
            % clear the current selection
            set(hPaletteButtons,'background',get(hToolPalettePanel,'BackgroundColor'));
            set(hPaletteButtons,'foreground',get(hToolPalettePanel,'foreground'));

            if ishandle(hToolPalettePanel) && toolindex<=length(hPaletteButtons)
                % apply new selection
                mPaletteSelectionIndex = toolindex;
                set(hPaletteButtons(mPaletteSelectionIndex),'background',mPaletteButtonStyle.selectionBackground);
            end

            % update 'add' button
            setActionEnabled('add', ~isempty(mPaletteSelectionIndex)),
        end

        % Detect mIsDragging of a palette button
        function paletteButtonDrag(hObject,eventdata) %#ok M-lint
            clickedMouseButton = get(hEditorFigure,'SelectionType');
            if ~strcmp(clickedMouseButton,'alt')
                existingTools = findobj(hEditorFigure,'tag','PreviewTool');
                set(hEditorFigure,'pointer','circle');
                mIsDraggingFromPalette = true; %str2double(get(hObject,'Tag'));
                %                mPreviewSelectionIndex = [];
                %                mFinalToolbarCurrentToolIndex = mPreviewSelectionIndex;

                % update palette selection
                mActionTable.setPaletteSelection.action(str2double(get(hObject,'Tag')));
                PTR = round(mean(get(hPaletteButtons(mPaletteSelectionIndex),'CData'),3))+1;
                S = size(PTR);
                PTR = [PTR; nan(16-S(1), S(2))];
                PTR = [PTR, nan(16, 16-S(2))];
                PTR(1,:) = 2; PTR(:,1) = 2; PTR(:,16) = 1; PTR(16,:) = 1;
                set(hEditorFigure,'pointer','custom','PointerShapeCData',PTR(1:16,1:16),'PointerShapeHotSpot',[9 9]);

                %                updateToolPropPanel();
                updateControlButtons();
            end
        end

    end

    function removeFinalToolbar(hObject,eventdata)
        % get confirmation from users
        overWrite = questdlg(sprintf(getUserString('ToolbatDeletionConfirmation')),...
            get(hEditorFigure,'name'),...
            'Yes', 'No', 'No');
        if strcmpi(overWrite,'Yes')

            if ishandle(hFinalToolbar)
                %remove toolbar first so that deleting its children does
                %not fire more events
                if isGUIDETool
                    mCallerAPI.removeObject(hFinalToolbar);
                end

                %delete the children so that the preview data structure is
                %kept clean
                localTotalCount = mToolbarToolCounter;
                if localTotalCount>0
                    mPreviewSelectionIndex = 1;
                    for i= 1:localTotalCount
                        mActionTable.delete.action(hObject,[]);
                    end
                end
                
                delete(hFinalToolbar);
                hFinalToolbar = [];

                updateToolbarPropPanel();
                
                %select the figure in this case
                if isGUIDETool
                    mCallerAPI.selectObject(mCallerAPI.figure);
                end                
            end

            setActionEnabled('removetoolbar',~isempty(hFinalToolbar));
            setActionEnabled('addtoolbar',isempty(hFinalToolbar));
            if isempty(hFinalToolbar)
                set(hPreviewLayout,'BorderType','line');
            else
                set(hPreviewLayout,'BorderType','EtchedIn');
            end

            %show/hide toolbar help text
            if isempty(hFinalToolbar)
                set(hPreviewHelpText,'Visible','on');
            else
                set(hPreviewHelpText,'Visible','off');
            end
        end

    end

    function createFinalToolbar(hObject, event, isStartup)
        if isGUIDETool
            oldToolbar = findobj(mCallerAPI.figure,'type','uitoolbar');
            if ~isempty(oldToolbar)
                hFinalToolbar = oldToolbar;
                hFinalToolbarTools = flipud(getFinalToolbarChildren());

                addExistingToolsToPreview;
            elseif ~isStartup
                hFinalToolbar = uitoolbar(mCallerAPI.figure);
                mCallerAPI.addObject(hFinalToolbar, true);
            end
        else
            hToolbarHostFigure = figure('visi','off','handlevisibility','off');
            hFinalToolbar = uitoolbar('parent',hToolbarHostFigure);
        end

        % enable remove toolbar button
        setActionEnabled('removetoolbar',~isempty(hFinalToolbar));
        setActionEnabled('addtoolbar',isempty(hFinalToolbar));
        if isempty(hFinalToolbar)
            set(hPreviewLayout,'BorderType','line');
        else
            set(hPreviewLayout,'BorderType','EtchedIn');
        end

        %show/hide toolbar help text
        if isempty(hFinalToolbar)
            set(hPreviewHelpText,'Visible','on');
        else
            set(hPreviewHelpText,'Visible','off');
        end


        %update the toolbar property panel
        updateToolbarPropPanel();

        % add actions
        mActionTable.getToolbarToolCount.action = @getFinalToolbarToolCount;
        mActionTable.getToolbarTool.action = @getFinalToolbarTool;

        function count = getFinalToolbarToolCount
            count = mToolbarToolCounter;
        end

        function tool = getFinalToolbarTool(index)
            tool = hFinalToolbarTools(index);
        end

    end
    function addExistingToolsToPreview
        for Counter = length(hFinalToolbarTools):-1:1
            ORDER = length(hFinalToolbarTools) - Counter + 1;
            CDAT = get(hFinalToolbarTools(ORDER),'CData');

            mPreviewTools(ORDER) = createPreviewTool([],get(hFinalToolbarTools(ORDER),'type'),CDAT,get(hFinalToolbarTools(ORDER),'TooltipString'),ORDER,hFinalToolbarTools(ORDER));

            % initialize separator
            toggleSeparatorPreview(ORDER);

            % initialize enable only for 'off' state
            if strcmpi('off', get(hFinalToolbarTools(ORDER),'enable'))
                set(mPreviewTools(ORDER).handle, 'enable', 'off');
            end
        end
        mToolbarToolCounter = length(hFinalToolbarTools);
    end

%------------------------------------------------------------------
    function processUserInputs
        % helper function that processes the input property/value pairs
        % Apply possible figure and recognizable custom property/value pairs
        for index=1:2:length(mInputArgs)
            if length(mInputArgs) < index+1
                break;
            end
            match = find(ismember({mPropertyDefs{:,1}},mInputArgs{index},'legacy'));
            if ~isempty(match)
                % Validate input and assign it to a variable if given
                if ~isempty(mPropertyDefs{match,3}) && mPropertyDefs{match,2}(mPropertyDefs{match,1}, mInputArgs{index+1})
                    assignin('caller', mPropertyDefs{match,3}, mInputArgs{index+1})
                end
            else
                try
                    set(topContainer, mInputArgs{index}, mInputArgs{index+1});
                catch
                    % If this is not a valid figure property value pair, keep
                    % the pair and go to the next pair
                    continue;
                end
            end
        end
    end

%------------------------------------------------------------------
    function isValid = localValidateInput(property, value)
        % helper function that validates the user provided input property/value
        % pairs. You can choose to show warnings or errors here.
        isValid = false;
        switch lower(property)
            case 'caller'
                if ischar(value)
                    isValid = true;
                end
            case 'callerapi'
                if isstruct(value)
                    isValid = true;
                end
            case 'loadinggui'
                if islogical(value)
                    isValid = true;
                end
        end
    end

%------------------------------------------------------------------
% action table keeps track the actions this editor supports. The table
% can be filled up by different players in different places. For
% example, the button panel can add its supported actions and the
% control buttons can add its own. The table will make enable/disable
% buttons much easier by changing the 'enable' property of the user
% field of each action.
    function actions = createActionTable
        actions = struct(...
            'help',struct(...
                        'name',getUserString('ActionHelp'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionHelpTooltip'),...
                        'action', '',...    % the function called when the action is activated
                        'state', '',...     % the function maintain the state of action user
                        'user',[]),...
            'ok',struct(...
                        'name',getUserString('ActionOK'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionOKTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'add',struct(...
                        'name',getUserString('ActionAdd'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionAddTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'delete',struct(...
                        'name',getUserString('ActionDelete'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionDeleteTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'movefront',struct(...
                        'name',getUserString('ActionSendtoFirst'),...
                        'icon','movefirst.gif',...
                        'tooltip',getUserString('ActionSendtoFirstTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'moveback',struct(...
                        'name',getUserString('ActionSendtoLast'),...
                        'icon','movelast.gif',...
                        'tooltip',getUserString('ActionSendtoLastTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'moveforward',struct(...
                        'name',getUserString('ActionMovetotheRight'),...
                        'icon','moveforward.gif',...
                        'tooltip',getUserString('ActionMovetotheRightTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'movebackward',struct(...
                        'name',getUserString('ActionMovetotheLeft'),...
                        'icon','movebackward.gif',...
                        'tooltip',getUserString('ActionMovetotheLeftTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'removetoolbar',struct(...           % 041007
                        'name',getUserString('ActionDeleteToolbar'),...
                        'icon','delete.gif',...
                        'tooltip',getUserString('ActionDeleteToolbarTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'addtoolbar',struct(...           % 041007
                        'name',getUserString('ActionAddToolbar'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionAddToolbarTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'shiftRight',struct(...
                        'name',getUserString('ActionShiftPreviewToolRight'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionShiftPreviewToolRightTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'shiftLeft',struct(...
                        'name',getUserString('ActionShiftPreviewToolLeft'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionShiftPreviewToolLeftTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'swap',struct(...
                        'name','Swap Two Preview Tools',...
                        'icon',[],...
                        'tooltip','Swap the position of two given preview tools',...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'editicon',struct(...
                        'name',getUserString('ActionEditIcon'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionEditIconTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'edittooltip',struct(...
                        'name',getUserString('ActionEditTooltip'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionEditTooltipTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'toggleseparator',struct(...
                        'name',getUserString('ActionShowSeparator'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionShowSeparatorTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'setPaletteSelection',struct(...
                        'name','Set Palette Selection Index',...
                        'icon',[],...
                        'tooltip','Change the selected tool in platte to the given index',...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'getPaletteSelection',struct(...
                        'name','Get Palette Selection Index',...
                        'icon',[],...
                        'tooltip','Get the currently selected tool index in the palette',...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'getSelectedPaletteButton',struct(...
                        'name','Get Palette Selection',...
                        'icon',[],...
                        'tooltip','Get the currently selected tool in the palette',...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'getPaletteButtonCount',struct(...
                        'name','Get the Number of Buttons in the Palette',...
                        'icon',[],...
                        'tooltip','Get how many buttons in the palette',...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'changeToolbarSelection',struct(...
                        'name','Select Toolbar Tool',...
                        'icon',[],...
                        'tooltip','Change the selected tool of toolbar',...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'restoredefault',struct(...
                        'name',getUserString('RestoreDefaults'),...
                        'icon',[],...
                        'tooltip',getUserString('RestoreDefaultsTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'moreproperty',struct(...
                        'name',getUserString('ActionMoreProperties'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionMorePropertiesTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'getToolbarToolCount',struct(...
                        'name','Get the Number of Tools in Toolbar',...
                        'icon',[],...
                        'tooltip','Get how many tools are currently added to the toolbar',...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'getToolbarTool',struct(...
                        'name','Get Toolbar Tool at Given Index',...
                        'icon',[],...
                        'tooltip','Get the toolbar tool at the given index',...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'getPreviewSelection',struct(...
                        'name','Get Preview Selection Index',...
                        'icon',[],...
                        'tooltip','Get the index of the currently selected tool of toolbar preview',...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'getPreviewTool',struct(...
                        'name','Get Preview Tool at Given Index',...
                        'icon',[],...
                        'tooltip','Get a tool on the toolbar preview at a given index',...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'getPreviewToolCount',struct(...
                        'name','The Number of Tools in the Preview',...
                        'icon',[],...
                        'tooltip','Get the number of tools currently on the toolbar preview',...
                        'action', '',...
                        'state', '',... 
                        'user',[]),...
            'setSelectedPropertyPage',struct(...
                        'name','Change Property Page',...
                        'icon',[],...
                        'tooltip','Show the property page for the selected object',...
                        'action', '',...
                        'state', '',... 
                        'user',[]));
    end

%------------------------------------------------------------------
    function buildPreviewToolContextMenu
        set(hPreviewContextMenu, 'callback', @maintainMenuState);
        
        hDeleteMenu = uimenu(...
            'Parent', hPreviewContextMenu,...
            'Label', mActionTable.delete.name,...
            'Callback', mActionTable.delete.action);
        addActionUser('delete',hDeleteMenu);
        hIconMenu = uimenu(...
            'Parent', hPreviewContextMenu,...
            'Label', mActionTable.editicon.name,...
            'Separator','on');
        addActionUser('editicon',hIconMenu);
        hTooltipMenu = uimenu(...
            'Parent', hPreviewContextMenu,...
            'Label', mActionTable.edittooltip.name);
        addActionUser('edittooltip',hTooltipMenu);
        hToggleSeparatorMenu = uimenu(...
            'Parent', hPreviewContextMenu,...
            'Label', mActionTable.toggleseparator.name);
        addActionUser('toggleseparator',hToggleSeparatorMenu);

        %toolbar contextmenu
        hAddToolbarMenu = uimenu(...
            'Parent', hPreviewToolbarContextMenu,...
            'Label', mActionTable.addtoolbar.name);
        addActionUser('addtoolbar',hAddToolbarMenu);
        hRemoveToolbarMenu = uimenu(...
            'Parent', hPreviewToolbarContextMenu,...
            'Label', mActionTable.removetoolbar.name);
        addActionUser('removetoolbar',hRemoveToolbarMenu);
        
        function maintainMenuState(hObject, eve)
            children = get(hObject,'children');
            for i=1:length(children)
                if isfield(mActionTable, get(children(i),'Tag'))
                    action = mActionTable.(get(children(i),'Tag'));
                    if isfield(action, 'state') && ~isempty(action.state)
                        action.state();
                    end
                end
            end
        end
    end

%------------------------------------------------------------------
    function  addActionUser(actionid, user)
        if isfield(mActionTable,actionid) && ishghandle(user)
           if isempty(find(mActionTable.(actionid).user==user))
               mActionTable.(actionid).user(end+1) = user;
               set(user,'Tag',actionid);
               if isprop(handle(user), 'Callback')
                  set(user,'Callback',mActionTable.(actionid).action); 
               end
           end
        end
    end

%------------------------------------------------------------------
    function  setActionEnabled(actionid, isenabled)
        if isfield(mActionTable,actionid)
            if ~isempty(mActionTable.(actionid))
                if ishghandle(mActionTable.(actionid).user)
                    if isenabled
                        enabled = 'on';
                    else
                        enabled = 'off';
                    end
                    set(mActionTable.(actionid).user, 'Enable', enabled);
                end
            end
        end
    end
%------------------------------------------------------------------
    function createButtonPanel()
        pos = [10 10 mFigurePosition(3)-2*10 50];
        hButtonPanel = uipanel(...
            'Parent',hEditorFigure,...
            'Units','pixel',...
            'BorderType','none',...
            'Clipping','on',...
            'Position',pos);
        % section line
        uipanel(...
            'Parent',hButtonPanel,...
            'Units','pixel',...
            'HighlightColor',[0 0 0],...
            'BorderType','line',...
            'Title','',...
            'Clipping','on',...
            'Visible','off',...
            'Position',[0 pos(4)-1 pos(3) 1]);

        % add action info to the action table
        buttonWidth = 80;
        buttonHeight = 30;
        mActionTable.help.action = @HelpButtonCallback;
        mActionTable.ok.action = @OKButtonCallback;
        addActionUser('ok',...
            uicontrol(...
            'parent',hButtonPanel,...
            'style','pushbutton',...
            'String',mActionTable.ok.name,...
            'position',[pos(3)-2*(buttonWidth + 10), 10, buttonWidth buttonHeight],...
            'KeyPressFcn',@figureKeyPress)); 
        addActionUser('help',...
            uicontrol(...
            'parent',hButtonPanel,...
            'style','pushbutton',...
            'String',mActionTable.help.name,...
            'position',[pos(3)-(buttonWidth + 10), 10, buttonWidth buttonHeight],...
            'KeyPressFcn',@figureKeyPress));
        %applyButton = uicontrol('style','pushbutton','String','Apply','position',[210 20 70 25]);
        %cancelButton = uicontrol('style','pushbutton','String','Cancel','position',[290 20 70 25],'Callback',@cancelButtonCallback);

        % Callbacks for the local (non-inspector) property modifier uicontrols
        function OKButtonCallback(hObject,eventdata)  %#ok Mlint
            closeToolbarEditor();
        end

        function HelpButtonCallback(hObject,eventdata)  %#ok Mlint
            helpview([docroot '/techdoc/creating_guis/creating_guis.map'], 'toolbar_editor','CSHelpWindow');
        end
    end
%------------------------------------------------------------------
    function updateControlButtons
        if isempty(hControlPanel)
            mActionTable.add.action = @addSelectedPaletteTool;
            mActionTable.delete.action = @removeSelectedPreviewTool;
            mActionTable.movefront.action = @shiftSelectedPreviewToolFirst;
            mActionTable.moveforward.action = @shiftSelectedPreviewToolRight;
            mActionTable.movebackward.action = @shiftSelectedPreviewToolLeft;
            mActionTable.moveback.action = @shiftSelectedPreviewToolLast;
            mActionTable.removetoolbar.action = @removeFinalToolbar;
            mActionTable.addtoolbar.action = {@createFinalToolbar, false};
            mActionTable.shiftLeft.action = @shiftPreviewToolLeft;
            mActionTable.shiftRight.action = @shiftPreviewToolRight;
            mActionTable.swap.action = @swapPreviewTools;
            mActionTable.changeToolbarSelection.action = @selectFinalToolbarTool;

            % create the control buttons if they are not created yet
            addActionUser('removetoolbar',...
                uicontrol(...
                'parent',hEditorFigure,...
                'style','pushbutton',...
                'position',[mPreviewPosition(1)+mPreviewPosition(3)+3 mPreviewPosition(2) 25 mPreviewPosition(4)],...
                'CData',iconread(mActionTable.removetoolbar.icon),...
                'TooltipString',mActionTable.removetoolbar.tooltip,...
                'KeyPressFcn',@figureKeyPress));

            % create a panel to hold all control buttons
            tabpanelpos = getpixelposition(hPropertyTabPanel);
            buttonhgap = 10;
            buttonwidth = (tabpanelpos(3) - 5*buttonhgap - 4*30)/2;
            
            hControlPanel =uipanel(...
                'Parent',hEditorFigure,...
                'BorderType','none',...
                'Title','',...
                'Units','pixels',...
                'Position',[tabpanelpos(1) tabpanelpos(2)+tabpanelpos(4)+5 tabpanelpos(3) 30]);
            index = 0;
            addActionUser('add',...
                uicontrol(...
                'parent',hControlPanel,...
                'style','pushbutton',...
                'Units','pixels',...
                'position',[index*(buttonwidth+buttonhgap)+1 5 buttonwidth 20],...
                'String',mActionTable.add.name,...
                'TooltipString',mActionTable.add.tooltip,...
                'KeyPressFcn',@figureKeyPress));
            index = index+1;
            addActionUser('delete',...
                uicontrol(...
                'parent',hControlPanel,...
                'style','pushbutton',...
                'Units','pixels',...
                'position',[index*(buttonwidth+buttonhgap) 5 buttonwidth 20],...
                'String',mActionTable.delete.name,...
                'TooltipString',mActionTable.delete.tooltip,...
                'KeyPressFcn',@figureKeyPress));
            index = index+1;
            addActionUser('movefront',...
                uicontrol(...
                'parent',hControlPanel,...
                'style','pushbutton',...
                'Units','pixels',...
                'position',[2*(buttonwidth+buttonhgap)+(index-2)*(30+buttonhgap) 5 30 20],...
                'CData',iconread(mActionTable.movefront.icon),...
                'TooltipString',mActionTable.movefront.tooltip,...
                'KeyPressFcn',@figureKeyPress));
            index = index+1;
            addActionUser('movebackward',...
                uicontrol(...
                'parent',hControlPanel,...
                'style','pushbutton',...
                'Units','pixels',...
                'position',[2*(buttonwidth+buttonhgap)+(index-2)*(30+buttonhgap) 5 30 20],...
                'CData',iconread(mActionTable.movebackward.icon),...
                'TooltipString',mActionTable.movebackward.tooltip,...
                'KeyPressFcn',@figureKeyPress));
            index = index+1;
            addActionUser('moveforward',...
                uicontrol(...
                'parent',hControlPanel,...
                'style','pushbutton',...
                'Units','pixels',...
                'position',[2*(buttonwidth+buttonhgap)+(index-2)*(30+buttonhgap) 5 30 20],...
                'CData',iconread(mActionTable.moveforward.icon),...
                'TooltipString',mActionTable.moveforward.tooltip,...
                'KeyPressFcn',@figureKeyPress));
            index = index+1;
            addActionUser('moveback',...
                uicontrol(...
                'parent',hControlPanel,...
                'style','pushbutton',...
                'Units','pixels',...
                'position',[2*(buttonwidth+buttonhgap)+(index-2)*(30+buttonhgap) 5 30 20],...
                'CData',iconread(mActionTable.moveback.icon),...
                'TooltipString',mActionTable.moveback.tooltip,...
                'KeyPressFcn',@figureKeyPress));
        end

        % palette selection controls 'add' button
        setActionEnabled('add',~isempty(mPaletteSelectionIndex));

        % preview selection controls the other buttons
        enable = ~isempty(mFinalToolbarCurrentToolIndex);
        setActionEnabled('delete',enable);
        setActionEnabled('movefront',enable);
        setActionEnabled('moveback',enable);
        setActionEnabled('moveforward',enable);
        setActionEnabled('movebackward',enable);

        % Add a tool to the end of the toolbar when add button is pressed
        function addSelectedPaletteTool(hobject,eventdata, varargin) %#ok MLINT
            if isempty(mPaletteSelectionIndex)
                %                disp('No tool selected')
            else
                if isempty(hFinalToolbar)
                    createFinalToolbar([],[],false);
                end

                %    disp('Adding Tool')
                mToolbarToolCounter = mToolbarToolCounter + 1;   % Increment the tool counter
                if ~isempty(varargin)
                    order = varargin{1};
                else
                    order = mToolbarToolCounter;
                end

                createFinalToolbarTool(hobject, eventdata, order);
                mPreviewTools(order) = createPreviewTool([],mPaletteSelectionIndex,get(hPaletteButtons(mPaletteSelectionIndex),'CData'),['Tool #' num2str(mToolbarToolCounter)], order,hFinalToolbarTools(order));

                selectFinalToolbarTool(hFinalToolbarTools(order));


                mFinalToolbarCurrentToolIndex = order;
                mPreviewSelectionIndex = order;

                %show/hide toolbar help text
                if isempty(hFinalToolbar)
                    set(hPreviewHelpText,'Visible','on');
                else
                    set(hPreviewHelpText,'Visible','off');
                end
            end

        end

        % remove the selected tool in the preview
        function removeSelectedPreviewTool(hObject,eventdata) %#ok MLINT
            if(isempty(mPreviewSelectionIndex))
                %                disp('No tool selected')
            else
                shiftPreviewToolLeft(hObject,[],mPreviewSelectionIndex+1);
                delete(mPreviewTools(mPreviewSelectionIndex).handle);   % Remove the button from the preview
                removeFinalToolbarTool(hObject, [], mPreviewSelectionIndex);
                [mPreviewTools, mToolbarToolCounter] = removeElement(hObject, [], mPreviewTools, mPreviewSelectionIndex);            % Remove the selected element from the structure
                if mToolbarToolCounter == 0
                    mPreviewSelectionIndex = [];
                else
                    if mPreviewSelectionIndex > mToolbarToolCounter
                        mPreviewSelectionIndex = mToolbarToolCounter;
                    end
                    setSelected(mPreviewTools(mPreviewSelectionIndex).handle,'on');
                    if isGUIDETool
                        mCallerAPI.selectObject(hFinalToolbarTools(mPreviewSelectionIndex));
                    end
                end
                mFinalToolbarCurrentToolIndex = mPreviewSelectionIndex;

                updateToolPropPanel();

                updateControlButtons();
            end
        end

        % Swap two tools in the preview
        function swapPreviewTools(hObject,eventdata,TOOL1, TOOL2) %#ok MLINT
            if TOOL1>TOOL2
                TempTool = TOOL1; TOOL1 = TOOL2; TOOL2 = TempTool;
            end
            ToolPos1 = getpixelposition(mPreviewTools(TOOL1).handle);
            ToolPos2 = getpixelposition(mPreviewTools(TOOL2).handle);
            setpixelposition(mPreviewTools(TOOL1).handle,[ToolPos2(1)-ToolPos1(3)+ToolPos2(3) ToolPos2(2) ToolPos1(3) ToolPos2(4)]);
            setpixelposition(mPreviewTools(TOOL2).handle,[ToolPos1(1)                         ToolPos1(2) ToolPos2(3) ToolPos1(4)]);
            %            ToolPos1 = get(mPreviewTools(TOOL1).handle,'position');
            %            ToolPos2 = get(mPreviewTools(TOOL2).handle,'position');
            %            set(mPreviewTools(TOOL1).handle,'position',[ToolPos2(1)-ToolPos1(3)+ToolPos2(3) ToolPos2(2) ToolPos1(3) ToolPos2(4)]);
            %            set(mPreviewTools(TOOL2).handle,'position',[ToolPos1(1)                         ToolPos1(2) ToolPos2(3) ToolPos1(4)]);
        end

        % Shift a block of tools to the right
        function shiftPreviewToolRight(hObject,eventdata,ORDER) %#ok MLINT
            for curBut = mToolbarToolCounter:-1:ORDER+1
                %                 OldPos = get(mPreviewTools(curBut).handle,'position');
                %                 set(mPreviewTools(curBut).handle,'position',OldPos+[(mPreviewToolStyle.interval+mPreviewToolStyle.width) 0 0 0]);
                setpixelposition(mPreviewTools(curBut).handle,getpixelposition(mPreviewTools(curBut).handle)+[(mPreviewToolStyle.interval+mPreviewToolStyle.width) 0 0 0]);
            end
        end

        % Shift a block of tools to the left
        function shiftPreviewToolLeft(hObject,eventdata,ORDER) %#ok MLINT
            widthToRemove = getpixelposition(mPreviewTools(ORDER-1).handle);
            %            widthToRemove = get(mPreviewTools(ORDER-1).handle,'position');
            widthToRemove = widthToRemove(3)+mPreviewToolStyle.interval;
            for curBut = ORDER:mToolbarToolCounter
                %                 OldPos = get(mPreviewTools(curBut).handle,'position');
                %                 set(mPreviewTools(curBut).handle,'position',OldPos-[widthToRemove 0 0 0]);
                setpixelposition(mPreviewTools(curBut).handle,getpixelposition(mPreviewTools(curBut).handle)-[widthToRemove 0 0 0]);
            end
        end

        % Shift a tool to the rightmost position
        function shiftSelectedPreviewToolLast(hObject,eventdata)%#ok MLINT
            if isempty(mPreviewSelectionIndex)
                %                disp('No tool selected')
            else
                POS = mPreviewSelectionIndex;
                if POS == mToolbarToolCounter
                    %                    disp('Last Tool Selected')
                else
                    for NEWPOS = POS:mToolbarToolCounter-1
                        mActionTable.swap.action(hObject,[],NEWPOS+1,NEWPOS);
                        mPreviewTools = swapElements(mPreviewTools, NEWPOS+1, NEWPOS);
                        swapWithPreviousHiddenTool(hObject,[], NEWPOS+1);
                        mPreviewSelectionIndex = mPreviewSelectionIndex + 1;
                        mFinalToolbarCurrentToolIndex = mPreviewSelectionIndex;

                        updateToolPropPanel();
                    end
                end
            end
        end

        % Shift a tool to first position
        function shiftSelectedPreviewToolFirst(hObject,eventdata) %#ok MLINT
            if isempty(mPreviewSelectionIndex)
                %                disp('No tool selected')
            else
                POS = mPreviewSelectionIndex;
                if POS == 1
                    %                    disp('First Tool Selected')
                else
                    for NEWPOS = POS:-1:2
                        mActionTable.swap.action(hObject,[],NEWPOS,NEWPOS-1);
                        mPreviewTools = swapElements(mPreviewTools, NEWPOS, NEWPOS-1);
                        swapWithPreviousHiddenTool(hObject,[], NEWPOS);
                        mPreviewSelectionIndex = mPreviewSelectionIndex -1;
                        mFinalToolbarCurrentToolIndex = mPreviewSelectionIndex;

                        updateToolPropPanel();
                    end
                end
            end
        end

        % Shift a tool 1 position to the left and swap with existing tool
        function shiftSelectedPreviewToolLeft(hObject,eventdata)%#ok MLINT
            if isempty(mPreviewSelectionIndex)
                %                disp('No tool selected')
            else
                POS = mPreviewSelectionIndex;
                if POS == 1
                    %                    disp('First Tool Selected')
                else
                    mActionTable.swap.action(hObject,[],POS,POS-1);
                    mPreviewTools = swapElements(mPreviewTools, POS, POS-1);
                    swapWithPreviousHiddenTool(hObject,[], POS);
                    mPreviewSelectionIndex = mPreviewSelectionIndex -1;
                    mFinalToolbarCurrentToolIndex = mPreviewSelectionIndex;

                    updateToolPropPanel();
                end
            end
        end

        % Shift a tool 1 position to the right and swap with existing tool
        function shiftSelectedPreviewToolRight(hObject,eventdata)%#ok MLINT
            if isempty(mPreviewSelectionIndex)
                %                disp('No tool selected')
            else
                POS = mPreviewSelectionIndex;
                if POS == mToolbarToolCounter
                    %                    disp('Last Tool Selected')
                else
                    mActionTable.swap.action(hObject,[],POS+1,POS);
                    mPreviewTools = swapElements(mPreviewTools, POS+1, POS);
                    swapWithPreviousHiddenTool(hObject,[], POS+1);
                    mPreviewSelectionIndex = mPreviewSelectionIndex + 1;
                    mFinalToolbarCurrentToolIndex = mPreviewSelectionIndex;

                    updateToolPropPanel();
                end
            end
        end

    end

    function changeProperty(h, name, value)
        if isGUIDETool
            guidemfile('changeToolbarToolDefaultCallback',hEditorFigure,h,name,value);

            % notify GUIDE the property change
            mCallerAPI.changeObject(h, name);
        else
            set(h,name, value);
        end

    end

    function guidetool = isGUIDETool
        guidetool = (~isempty(mCaller) && strcmpi(mCaller,'GUIDE'));
    end

    function toolapi = guide2tool
        toolapi = struct(...
            'figure',       hEditorFigure,...
            'select',       @selectFinalToolbarTool,...
            'update',       @updateFinalToolbarTool,...
            'load',         @updateWhenLoadGUI,...
            'stop',         @closeToolbarEditor,...
            'isRecognizable',@isRecognizable,...
            'getTestAPI',   @getTestingAPI);
    end

    function recognizable = isRecognizable(tool)
        if ~isempty(hFinalToolbar)
            recognizable =true;
            for i=1:length(tool)
                try
                    thisone = double(tool{i});
                    recognizable = isequal(thisone, hFinalToolbar) || ~isempty(find(hFinalToolbarTools==thisone));
                catch
                    recognizable = false;
                end

                if ~recognizable
                    return;
                end
            end
        else
            recognizable =false;
        end
    end

    function setChildToolTestingAPI(toolname, api)
        mChildToolTestingAPI.(toolname) = api;
        if isempty(mChildToolTestingAPI.(toolname))
            mChildToolTestingAPI = rmfield(mChildToolTestingAPI, toolname);
        end
    end

    function api = getTestingAPI

        mActionTable.getPreviewSelection.action = @getPreviewSelection;
        mActionTable.getPreviewTool.action = @getPreviewTool;
        mActionTable.getPreviewToolCount.action = @getPreviewToolCount;

        api = struct(...
            'palette', struct(...
            'getSelectionIndex',mActionTable.getPaletteSelection.action,...
            'setSelectionIndex',mActionTable.setPaletteSelection.action,...
            'getSelectedButton',mActionTable.getSelectedPaletteButton.action,...
            'getButtonCount',mActionTable.getPaletteButtonCount.action),...
            'controlButtons', struct(...
            'add',mActionTable.add.user(1),...
            'delete',mActionTable.delete.user(1),...
            'moveFirst',mActionTable.movefront.user(1),...
            'moveForward',mActionTable.moveforward.user(1),...
            'moveBackward',mActionTable.movebackward.user(1),...
            'moveLast',mActionTable.moveback.user(1)),...
            'dialogButtons', struct(...
            'ok',mActionTable.ok.user(1),...            
            'help',mActionTable.help.user(1)),...
            'property', struct(...
            'editicon',mActionTable.editicon.action),...
            'toolbar', struct(...
            'getToolbarToolCount', mActionTable.getToolbarToolCount.action,...
            'getToolbarTool',mActionTable.getToolbarTool.action),...
            'preview',struct(...
            'getPreviewTool',mActionTable.getPreviewTool.action,...
            'getPreviewToolCount',mActionTable.getPreviewToolCount.action,...
            'getPreviewSelection',mActionTable.getPreviewSelection.action));

        % add testing API from child tools
        api.tools = mChildToolTestingAPI;

        function count = getPreviewToolCount
            count = length(mPreviewTools);
        end

        function index = getPreviewSelection
            index = mPreviewSelectionIndex;
        end

        function tool = getPreviewTool(index)
            tool = mPreviewTools(index).key;
        end
    end

    function selectFinalToolbarTool(varargin)
        tool=[];
        fromguide = false;
        if nargin ==1
            tool =varargin{1};
        else
            if isGUIDETool && nargin ==3
                fromguide = true;
                tools = varargin{end};
                tool = double(tools{1});
            end
        end

        selected = [];
        if ~isempty(tool)
            order = find(hFinalToolbarTools==tool);
            if ~isempty(order)
                if ~isempty(mFinalToolbarCurrentToolIndex) % && mFinalToolbarCurrentToolIndex <= length(mFinalToolbarCurrentToolIndex)
                    for ind = 1:length(mPreviewTools)
                        setSelected(mPreviewTools(ind).handle,'off');
                    end
                end
                mFinalToolbarCurrentToolIndex = order;
                if ~isempty(order)
                    setSelected(mPreviewTools(order).handle,'on');
                    mPreviewSelectionIndex = order;

                    selected = hFinalToolbarTools(order);

                    % update the property page for the selected tool
                    updateToolPropPanel();
                end

                % update control buttons
                updateControlButtons();
            else
                if double(tool) == double(hFinalToolbar)
                    if ~isempty(mPreviewSelectionIndex)
                        setSelected(mPreviewTools(mPreviewSelectionIndex).handle,'off');
                    end
                    mFinalToolbarCurrentToolIndex = [];
                    mPreviewSelectionIndex = [];
                    % update the property page for the selected tool
                    updateToolPropPanel();

                    selected = hFinalToolbar;
                    updateToolbarPropPanel();
                end
            end

            if ~isempty(selected) && isGUIDETool && ~fromguide
                mCallerAPI.selectObject(selected);
            end

        end
    end

    function setSelected(handles, value)
        handlesLogical = arrayfun(@(x) ~isprop(x,'Selected'), handles);
        handles(handlesLogical) = [];
        set(handles,'Selected',value);
    end

    function updateFinalToolbarTool(varargin)
        selection = varargin{3};
        updateWhenPropertyChange(selection{1}) ;
    end

    function updateWhenPropertyChange(varargin)
        tool = varargin{1};
        if ~isa(tool, 'uitoolbar');
            index = find(ismember(hFinalToolbarTools, tool,'legacy'));
            if ~isempty(index)
                % maintain callback properties of predefined tool
                if isGUIDETool
                    guidemfile('changeToolbarToolDefaultCallback', hEditorFigure,tool);
                end

                toolpreview = mPreviewTools(hFinalToolbarTools==tool).handle;

                % make preview synchronized
                % enable
                enable = get(tool, 'Enable');
                if isequal(enable,'off')
                    set(toolpreview, 'Enable', 'off');
                else
                    set(toolpreview, 'Enable', 'inactive');
                end
                %separator
                toggleSeparatorPreview(mFinalToolbarCurrentToolIndex);
                % tooltip
                set(toolpreview, 'TooltipString', get(tool, 'TooltipString'));
                % cdata
                separator = get(tool, 'Separator');
                if strcmpi(separator, 'on')
                    reverse = 'off';
                else
                    reverse = 'on';
                end
                set(tool,'Separator', reverse);
                toggleSeparatorPreview(mFinalToolbarCurrentToolIndex);
                set(tool,'Separator', separator)
                toggleSeparatorPreview(mFinalToolbarCurrentToolIndex);

                % update property page since certain property changed
                updateToolPropPanel();
            end
        else
            if double(tool) == double(hFinalToolbar)
                % update property page since certain property changed
                updateToolbarPropPanel();
            end
        end
    end

    function closeToolbarEditor(varargin)
        if ishandle(hEditorFigure)
            % use close not delete
            close(hEditorFigure)
        end
        if ishandle(hToolbarHostFigure)
            delete(hToolbarHostFigure);
        end
    end


    %------------------------------------------------------------------
    function string = getUserString(key)
        string = getString(message(sprintf('%s%s','MATLAB:guide:toolbareditor:',key)));
    end
end


%------------------------------------------------------------------
function prepareLayout(topContainer)
    % This is a utility function that takes care of issues related to
    % look&feel and running across multiple platforms. You can reuse
    % this function in other GUIs or modify it to fit your needs.
    allObjects = findall(topContainer);

    % Use the name of this GUI file as the title of the figure
    if isa(handle(topContainer),'figure')
        set(topContainer,'NumberTitle','off');
    end

    % Make GUI objects available to callbacks so that they cannot
    % be changed accidentally by other MATLAB commands
    %    set(allObjects(isprop(allObjects,'HandleVisibility')), 'HandleVisibility', 'Callback');

    % Make the GUI run properly across multiple platforms by using
    % the proper units
    if strcmpi(get(topContainer, 'Resize'),'on')
        set(allObjects(isprop(allObjects,'Units')),'Units','Normalized');
    else
        set(allObjects(isprop(allObjects,'Units')),'Units','Characters');
    end
    
    % You may want to change the default color of editbox,
    % popupmenu, and listbox to white on Windows
    if ispc
        candidates = [findobj(allObjects, 'Style','Popupmenu');...
            findobj(allObjects, 'Style','Edit');...
            findobj(allObjects, 'Style','Listbox')];
        set(findobj(candidates,'BackgroundColor', get(0,'defaultuicontrolbackgroundcolor')), 'BackgroundColor','white');
    end
end
