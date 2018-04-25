function hfig = imcolormaptool(varargin)
% IMCOLORMAPTOOL Choose Colormap tool.
%    IMCOLORMAPTOOL launches the Choose Colormap tool in a separate figure
%    which is associated with the current figure, called the target figure.
%    The Choose Colormap tool is an interactive colormap selection tool
%    that allows you to change the colormap of the image in the target
%    figure by selecting a colormap from a list of MATLAB colormap
%    functions, workspace variables, or by entering a custom MATLAB
%    expression.
%
%    IMCOLORMAPTOOL(HCLIENTFIG) launches the Choose Colormap tool using
%    HCLIENTFIG as the target figure. HCLIENTFIG must contain either a
%    grayscale or an indexed image. If HCLIENTFIG contains multiple images,
%    the original colormap is chosen from one of the images arbitrarily and
%    the new colormap is applied to all images.
%
%    IMCOLORMAPTOOL(HCLIENTAX) launches the Choose Colormap tool using
%    HCLIENTAX as the target axes. HCLIENTAX must contain either a
%    grayscale or an indexed image. Use this syntax to update the colormap
%    of a single image in a figure containing multiple images.
%
%    HFIG = IMCOLORMAPTOOL(...) returns a handle to the tool, HFIG.
%
%    Example 1
%    ---------
%    h = figure;
%    imshow('cameraman.tif')
%    imcolormaptool(h)
%
%    Example 2
%    ---------
%    figure
%    ax1 = subplot(1,2,1);
%    imshow('cameraman.tif')
%    ax2 = subplot(1,2,2);
%    imshow('trees.tif')
%    imcolormaptool(ax2)
%
%    See also IMTOOL, IMSHOW, COLORMAP.

%   Copyright 2008-2016 The MathWorks, Inc.

[hClientFig,hTarget,hReferenceAxes,hReferenceImage,hDependentAxes] = parseInputs(varargin{:});

% Strings appended to colormap names in the GUI.  (Function-level scope)
originalStr   = getString(message('images:imcolormaptoolUIStrings:original'));
customStr     = getString(message('images:imcolormaptoolUIStrings:custom'));
expressionStr = getString(message('images:imcolormaptoolUIStrings:expression'));
clearedStr    = getString(message('images:imcolormaptoolUIStrings:cleared'));

% Singleton
hCMapFig = getappdata(hClientFig, 'imcolormaptoolFig');
if ~isempty(hCMapFig)
    figure(hCMapFig);
    if nargout > 0
        hfig = hCMapFig;
    end
    return
end

% initialize function scope variables
userCanceled = true;

% create new tool
hCMapFig = figure('Toolbar','none',...
    'Menubar','none',...
    'NumberTitle','off',...
    'IntegerHandle','off',...
    'Tag','imcolormaptool',...
    'Visible','off',...
    'HandleVisibility','callback',...
    'Name',createFigureName('Choose Colormap',hTarget),...
    'WindowStyle','normal',...
    'Resize','off');

% no plot tools
suppressPlotTools(hCMapFig);

% Add an empty toolbar (to access the docking controls)
uitoolbar(hCMapFig);

% Layout Management
extraHeight = 35;
figHeight = 260 + extraHeight;
figWidth  = 250;
figSize = [figWidth figHeight];
leftMargin = 10;
rightMargin = 10;
spacing = 5;
defaultPanelWidth = figWidth - leftMargin - rightMargin;
buttonSize = [60 25];
buttonType = 'none';

lastSelectedValue = 0;

% We will be inheriting the background color from the UIPANEL
bgColor = [];
buttons = [];
SUCCESS = true;
FAILURE = false;

set(hCMapFig,'Position',getCenteredClientPosition);

% Get workspace variables
if ~isdeployed
    workspaceVariables = evalin('base','whos');
end

customButtonMargin = 185 + extraHeight;
customTopMargin = 10;
hRadioButton = [];
hRadioPanel = createRadioPanel;

customTopMargin = figHeight - customButtonMargin + spacing;
customButtonMargin = 40 + extraHeight;
displayPanel(1) = createCMapFcnPanel;

if ~isdeployed
    displayPanel(2) = createCMapVarPanel;
end

customTopMargin = figHeight - customButtonMargin + spacing;
customButtonMargin = 15 + extraHeight;
hEvalPanel = createEvalPanel;
hObj = findobj(hEvalPanel,'Type','uicontrol','style','edit');

% Put the colormap in the edit box
hEditBox = findobj(hCMapFig,'Tag','cmapFcnList');
listStrings = get(hEditBox,'String');
listValue = get(hEditBox,'Value');

selectedStr = listStrings{listValue};
if ~isempty(strfind(selectedStr, ['<' customStr '>']))
    selectedStr = '';
else
    selectedStr = strrep(selectedStr, [' (' originalStr ')'], '');
    selectedStr = sprintf('%s(%d)',selectedStr,256);
end

set(hObj,'String',selectedStr)

customTopMargin = figHeight - customButtonMargin;
customButtonMargin = 10;
createButtonPanel;

% Remember the colormaps of all axes in the figure,
% so that we can revert if the user clicks cancel
numDependentAxes = numel(hDependentAxes);
originalColormaps = cell(numDependentAxes,1);
for p = 1:numDependentAxes
    originalColormaps{p} = colormap(hDependentAxes{p});
end

iptwindowalign(hClientFig,'right',hCMapFig,'left');
iptwindowalign(hClientFig,'top',hCMapFig,'top');

% Make the "Colormap functions:" panel visible
set(displayPanel(1),'Visible','on');
set(hRadioPanel,'Visible','on');
set(hEvalPanel,'Visible','on');

% Make the dialog window visible
set(hCMapFig,'Visible','on');

% set figure callback functions
set(hCMapFig,'DeleteFcn',@deleteFcn);
set(hCMapFig,'WindowKeyPressFcn',@handleEsc);

% Add listeners in order to listen to 
% colormap changes in the reference axes
cmapListener = iptui.iptaddlistener(hReferenceAxes,'MarkedDirty',...
    @(varargin) changeFcn());
setappdata(hCMapFig,'colormapListener',cmapListener);
clear cmapListener;

reactToImageChangesInFig(hReferenceImage,hCMapFig,@deleteFcn,@refreshFcn);
registerModularToolWithManager(hCMapFig,hReferenceImage);

% Return the handle to the dialog if the caller requests it
if nargout > 0
    hfig = hCMapFig;
end

setappdata(hClientFig, 'imcolormaptoolFig', hCMapFig);

% Variable to keep track of the last expression entered
lastExpression = [];

% Variable to keep track of the last custom colormap entered
lastCustom = [];

    %---------------------------
    function deleteFcn(varargin)
        
        % close tool
        if ishghandle(hCMapFig)
            
            % if the user hit CANCEL, revert to original colormap
            if userCanceled
                revertColormapsToOriginal();
                
                % clear edit box, this is needed by IMGETVAR
                set(findall(hCMapFig,'tag','cmapEvalEdit'),'String','');
            end
            
            delete(hCMapFig);
        end
        
        % clear singleton appdata if client figure still exists
        if ishghandle(hClientFig) && isappdata(hClientFig,'imcolormaptoolFig')
            rmappdata(hClientFig,'imcolormaptoolFig');
        end
        
    end %deleteFcn

    %---------------------------------
    function revertColormapsToOriginal()
        
        for k = 1:numel(hDependentAxes)
            if ~isempty(originalColormaps{k}) && ishandle(hDependentAxes{k})
                setAxesColormap(hDependentAxes{k},originalColormaps{k});
            end
        end
        
    end %revertColormapsToOriginal

    %-------------------------------
    function refreshFcn(varargin)
        
        % verify our target image is still grayscale or indexed
        cdata = get(hReferenceImage,'Cdata');
        if isempty(cdata) || ~ismatrix(cdata)
            deleteFcn();
        end
        
    end %refreshFcn

    %-------------------------------
    function changeFcn(varargin)
        % This function gets called only if the reference
        % colormap is changed from outside this tool.
        
        % get new map
        cmap = colormap(hReferenceAxes);
        
        % check if new map is one of the predefined colormaps functions
        hList = findobj(hCMapFig,'Tag','cmapFcnList');
        cmapStr = get(hList,'String');
        
        isFound = false;
        customInd = [];
        fcnInd = [];
        for i = 1:length(cmapStr)
            curString = cmapStr{i};
            
            % skip expression strings
            isExpressionString = ~isempty(strfind(curString,['<' expressionStr '>']));
            if ~isExpressionString
                
                isCustomString = ~isempty(strfind(curString,['<' customStr '>']));
                if ~isCustomString
                    
                    if isequal(feval(strrep(curString, [' (' originalStr ')'], ''),256),cmap)
                        isFound = true;
                        fcnInd = i;
                    end
                    
                else % isCustomString
                    
                    if isempty(strfind(curString,originalStr))
                        % custom and non-original, we set to this if we
                        % cannot find it in our list
                        customInd = i;
                    end
                end
            end
        end
        
        if isFound
            % if we found the colormap then select it
            set(hList,'Value',fcnInd)
            set(hObj,'String',sprintf('%s(%d)',strrep(cmapStr{fcnInd}, [' (' originalStr ')'], ''),256))
        else
            if isempty(customInd)
                % Add a non-original <custom> to list here
                set(hList,'String',[['<' customStr '>']; cmapStr(:)]);
                set(hList,'Value',1)
                set(hObj,'String','')
            else
                % if we already had an entry for non-original custom,
                % select that one
                set(hList,'Value',customInd)
                set(hObj,'String','')
            end
            % Store custom colormap
            lastCustom = cmap;
        end
        
        % Switch to "Colormap functions:" pane
        fcnPanel = findobj(hCMapFig,'Tag','cmapFcnPanel');
        varPanel = findobj(hCMapFig,'Tag','cmapVarPanel');
        set(varPanel,'Visible','off')
        set(findobj(hCMapFig,'Tag','cmapFcnRButton'),'Value',1)
        set(fcnPanel,'Visible','on')
        hVarList = findobj(hCMapFig,'Tag','cmapVarList');
        % Unselect items in "Workspace variables" list
        set(hVarList, 'min', 0, 'max', 2);
        set(hVarList, 'Value', []);
        
    end %changeFcn

    %--------------------------
    function handleEsc(src,~)
        
        keyPressed = get(src,'CurrentKey');
        
        esc_pressed = strcmpi(keyPressed,'escape');
        
        if esc_pressed
            % escape key == cancel button
            doButtonPress(buttons(2),[]);
        end
        
    end % handleEsc


    %-------------------------------
    function pos = getPanelPos
        % determine the panel position based on the current customButtonMargin
        % and the customTopMargin
        
        height = figHeight - customButtonMargin - customTopMargin;
        pos = [leftMargin, customButtonMargin, defaultPanelWidth, height];
        
    end %getPanelPos

    %---------------------------------
    function pos = getCenteredClientPosition
        % returns the position of the import dialog
        % centered on the client (figure)
        
        clientPosition = getpixelposition(hClientFig);
        lowerLeftPosition = clientPosition(1:2) + (figSize * 0.5);
        pos = [lowerLeftPosition figSize];
        
    end % getCenteredClientPosition

    %---------------------------------
    function radioGroup = createRadioPanel
        
        panelPos = getPanelPos;
        radioGroup = uibuttongroup('Parent',hCMapFig,...
            'Tag','radioPanel',...
            'Units','pixels',...
            'TitlePosition','lefttop',...
            'Title', getString(message('images:imcolormaptoolUIStrings:source')), ...
            'BorderType',buttonType,...
            'Visible','off');
        
        set(radioGroup,'Position',panelPos);
        
        bgColor = get(radioGroup,'BackgroundColor');
        set(hCMapFig,'Color',bgColor);
        
        hRadioButton = gobjects(1,2);
        
        hRadioButton(1) = uicontrol('parent',radioGroup,...
            'Style','radiobutton',...
            'Units','pixels',...
            'Tag','cmapFcnRButton',...
            'BackgroundColor',bgColor,...
            'String', getString(message('images:imcolormaptoolUIStrings:matlabColormapFunctions')));
        
        hRadioButton(2) = uicontrol('parent',radioGroup,...
            'Style','radiobutton',...
            'Units','pixels',...
            'Tag','cmapVarRButton',...
            'BackgroundColor',bgColor,...
            'String', getString(message('images:imcolormaptoolUIStrings:workspaceVariables')));
        
        labelExtent = get(hRadioButton(1),'Extent');
        
        if isdeployed
            set(hRadioButton(2),'Enable','off');
        end
        
        rbutton_width = labelExtent(3) + 25;
        rbutton_height  = 20;
        rbutton_posX = rightMargin;
        rbutton_posY = spacing;
        rbutton_position = [rbutton_posX, rbutton_posY, rbutton_width, rbutton_height];
        
        set(hRadioButton(2),'Position',rbutton_position);
        
        rbutton_posY = rbutton_posY + spacing + rbutton_height;
        rbutton_position = [rbutton_posX, rbutton_posY, rbutton_width, rbutton_height];
        set(hRadioButton(1),'Position',rbutton_position);
        
        set(radioGroup,'SelectionChangeFcn',@showPanel);
            
    end %createRadioPanel

    %---------------------------------
    function showPanel(src,evt) %#ok<INUSL>
        % makes the panel associated with
        % the selected radio button visible
        
        % The evt.NewValue is the currently selected radio button in the
        % uibutton group.
        tag = get(evt.NewValue,'tag');
        panelTag = strrep(tag,'RButton','Panel');
        selectedPanel = findobj(displayPanel,'Tag',panelTag);
        
        if strcmp(get(selectedPanel,'Tag'),'cmapVarPanel')
            
            % refersh the workspace variable list
            hVarList = findobj(hCMapFig,'Tag','cmapVarList');
            workspaceVariables = evalin('base','whos');
            varInd = iptui.internal.filterWorkspaceVars(workspaceVariables,'colormap');
            varList = {workspaceVariables(varInd).name};
            
            hFcnList = findobj(hCMapFig,'Tag','cmapFcnList');
            if ~isempty(get(hFcnList,'Value'))
                % If the current colormap was caused by a selection in the
                % "Colormap Functions:" pane, then all items in the
                % "Workspace variables:" pane should be unselected
                set(hVarList,'String',varList);
                % Workaround to have no selected items in a listbox
                set(hVarList, 'min', 0, 'max', 2);
                set(hVarList, 'Value', []);
            else
                prevVarList = get(hVarList,'String');
                prevVarInd = get(hVarList,'Value');
                prevVar = prevVarList{prevVarInd};
                matchIdx = strcmp(prevVar, varList);
                if any(matchIdx)
                    % If previously selected workspace variable still
                    % exists in the workspace, select that item in the
                    % listbox
                    set(hVarList,'String',varList);
                    set(hVarList, 'Value', find(matchIdx));
                else
                    if isempty(strfind(prevVar,['<' clearedStr '>']))
                        % If the previously selected workspace variable has
                        % been cleared from the workspace, append
                        % "<cleared>" to the variable name and add the item
                        % to the listbox.
                        varList = [['<' clearedStr '> ' prevVar] varList];
                        set(hVarList,'String',varList);
                        set(hVarList, 'Value', 1);
                    end
                end
                
            end
            
        else
            
            % If the current colormap was caused by a selection in the
            % "Workspace variables:" pane, then all items in the
            % "Colormap Functions:" pane should be unselected
            hWorkList = findobj(hCMapFig,'Tag','cmapVarList');
            hFcnList = findobj(hCMapFig,'Tag','cmapFcnList');
            if ~isempty(get(hWorkList,'Value'))
                % Workaround to have no selected items in a listbox
                set(hFcnList, 'min', 0, 'max', 2);
                set(hFcnList, 'Value', []);
            end
        end
        
        set(displayPanel(displayPanel ~= selectedPanel),'Visible','off');
        set(selectedPanel,'Visible','on');
        
        getColormap;
        
    end

    %---------------------------------
    function hPanel = createCMapFcnPanel
        % This panel is for the list of MATLAB Colormap functions.
        panelPos = getPanelPos;
        
        hPanel = uipanel('parent',hCMapFig,...
            'Tag','cmapFcnPanel',...
            'Units','pixels',...
            'BorderType',buttonType,...
            'Position',panelPos,...
            'Visible','off');
        
        hLabel = uicontrol('parent',hPanel,...
            'Style','text',...
            'Units','Pixels',...
            'String', getString(message('images:imcolormaptoolUIStrings:colormapFunctions')),...
            'BackgroundColor',bgColor,...
            'HorizontalAlignment','left');
        
        labelExtent = get(hLabel,'Extent');
        labelHeight = labelExtent(4);
        labelPosX = leftMargin;
        labelPosY = panelPos(4) - spacing - labelHeight;
        labelPosition = [labelPosX,labelPosY,labelExtent(3),labelHeight];
        
        set(hLabel,'Position',labelPosition);
        
        hList = uicontrol('parent',hPanel,...
            'Style','listbox',...
            'Value',1,...
            'BackgroundColor','white',...
            'Units','pixels',...
            'Tag','cmapFcnList');
        
        listPosX = leftMargin;
        listPosY = 2*spacing;
        listWidth = panelPos(3) - leftMargin - rightMargin;
        listHeight = labelPosY - 2*spacing;
        listPosition = [listPosX,listPosY,listWidth,listHeight];
        
        set(hList,'Position',listPosition);
        
        % Get predefined set of colormap functions
        cmapStr = getColormapFcnList;
        
        % Check if colormap of hReferenceAxes
        % is one of the predefined colormaps
        isFound = false;
        for i = 1:length(cmapStr)
            if isequal(cmapStr{i,2}(256),colormap(hReferenceAxes))
                cmapStr{i,1} = [cmapStr{i,1} [' (' originalStr ')']];
                isFound = true;
                break;
            end
        end
        
        set(hList,'String',cmapStr(:,1));
        if isFound
            set(hList,'Value',i)
        else
            % If colormap is not one of the predefined set of colormap
            % functions, set it to "<custom> (original)"
            set(hList,'String',['<' customStr '> (' originalStr ')'; cmapStr(:,1)]);
        end
        
        set(hList,'Callback',@callGetColormap);
        
    end %createCMapFcnPanel

    %---------------------------------
    function hPanel = createCMapVarPanel
        % This panel is for the list of variables in the MATLAB workspace
        % that have size mx3.
        
        panelPos = getPanelPos;
        
        hPanel = uipanel('parent',hCMapFig,...
            'Tag','cmapVarPanel',...
            'Units','pixels',...
            'BorderType',buttonType,...
            'Position',panelPos,...
            'Visible','off');
        
        iptui.internal.setChildColorToMatchParent(hPanel,hCMapFig);
        
        hLabel = uicontrol('parent',hPanel,...
            'Style','text',...
            'Units','Pixels',...
            'String', getString(message('images:imcolormaptoolUIStrings:variables')), ...
            'BackgroundColor',bgColor,...
            'HorizontalAlignment','left');
        
        labelExtent = get(hLabel,'Extent');
        labelHeight = labelExtent(4);
        labelPosX = leftMargin;
        labelPosY = panelPos(4) - spacing - labelHeight;
        labelPosition = [labelPosX,labelPosY,labelExtent(3),labelHeight];
        
        set(hLabel,'Position',labelPosition);
        
        hList = uicontrol('parent',hPanel,...
            'Style','listbox',...
            'Value',1,...
            'BackgroundColor','white',...
            'Units','pixels',...
            'Tag','cmapVarList');
        
        listPosX = leftMargin;
        listPosY = 2*spacing;
        listWidth = panelPos(3) - leftMargin - rightMargin;
        listHeight = labelPosY-2*spacing;
        listPosition = [listPosX,listPosY,listWidth,listHeight];
        
        set(hList,'Position',listPosition);
        set(hList,'Callback',@callGetColormap);
        
        varInd = iptui.internal.filterWorkspaceVars(workspaceVariables,'colormap');
        
        varList = {workspaceVariables(varInd).name};
        
        set(hList,'String',varList);
        % Workaround to have no selected items in a listbox
        set(hList, 'min', 0, 'max', 2);
        set(hList, 'Value', []);
        
        % Context menu for refreshing "Workspace variables:" pane
        hContextMenu = uicontextmenu('Parent',hCMapFig);
        uimenu(hContextMenu,'Label', getString(message('images:imcolormaptoolUIStrings:refresh')),...
            'Callback',@refreshWorkspace,...
            'tag','refresh cmenu item');
        set(hList,'uiContextMenu',hContextMenu);
        
    end %createCMapVarPanel

    %---------------------------------
    function refreshWorkspace(~,~)
        hList = findobj(hCMapFig,'Tag','cmapVarList');
        workspaceVariables = evalin('base','whos');
        varInd = iptui.internal.filterWorkspaceVars(workspaceVariables,'colormap');
        varList = {workspaceVariables(varInd).name};
        
        hFcnList = findobj(hCMapFig,'Tag','cmapFcnList');
        if ~isempty(get(hFcnList,'Value'))
            % If the current colormap was caused by a selection in the
            % "Colormap Functions:" pane, then all items in the
            % "Workspace variables:" pane should be unselected
            set(hList,'String',varList);
            % Workaround to have no selected items in a listbox
            set(hList, 'min', 0, 'max', 2);
            set(hList, 'Value', []);
        else
            prevVarList = get(hList,'String');
            prevVarInd = get(hList,'Value');
            prevVar = prevVarList{prevVarInd};
            matchIdx = strcmp(prevVar, varList);
            if any(matchIdx)
                % If previously selected workspace variable still exists in
                % the workspace, select that item in the listbox
                set(hList,'String',varList);
                set(hList, 'Value', find(matchIdx));
            else
                if isempty(strfind(prevVar,['<' clearedStr '>']))
                    % If the previously selected workspace variable has
                    % been cleared from the workspace, append "<cleared>"
                    % to the variable name and add the item to the listbox.
                    varList = [['<' clearedStr '> ' prevVar] varList];
                    set(hList,'String',varList);
                    set(hList, 'Value', 1);
                end
            end
            
        end
    end

    %------------------------------------------------
    function hPanel = createEvalPanel
        
        % Creates the eval panel
        panelPos = getPanelPos;
        
        hPanel = uipanel('parent',hCMapFig,...
            'Units','Pixels',...
            'Tag','cmapEvalPanel',...
            'BorderType',buttonType,...
            'Position',panelPos,...
            'Visible','off');
        
        
        hEvalLabel = uicontrol('parent',hPanel,...
            'Style','Text',...
            'String', getString(message('images:imcolormaptoolUIStrings:evaluateColormap')), ...
            'HorizontalAlignment','left',...
            'BackgroundColor',bgColor,...
            'Units','pixels');
        
        labelExtent = get(hEvalLabel,'extent');
        posY = 0;
        labelPosition = [leftMargin, posY, labelExtent(3:4)];
        
        set(hEvalLabel,'Position',labelPosition);
        
        maxWidth = panelPos(3)-leftMargin-rightMargin-labelExtent(3)-spacing;
        editWidth = min([panelPos(3)-labelExtent(3)-leftMargin*2,...
            maxWidth]);
        
        editPosition = [leftMargin + labelExtent(3) + spacing,...
            posY,editWidth, 20];
        
        hEvalEdit = uicontrol('parent',hPanel,...
            'Style','edit',...
            'Tag','cmapEvalEdit',...
            'Units','pixels',...
            'HorizontalAlignment','left',...
            'Callback',@(varargin) getColormap,...
            'Position',editPosition);
        
        if ~isdeployed
            set(hEvalEdit,'BackgroundColor','white',...
                'Enable','on');
        else
            set(hEvalEdit,'BackgroundColor',[0.8 0.8 0.8],...
                'Enable','off');
        end
    end % createEvalPanel

    %---------------------------------
    function createButtonPanel
        % This panel contains the OK, Cancel and Help buttons
        
        panelPos = getPanelPos;
        hButtonPanel = uipanel('parent',hCMapFig,...
            'Tag','buttonPanel',...
            'Units','pixels',...
            'Position',panelPos,...
            'BorderType',buttonType);
        
        % Add buttons
        button_strs_n_tags = {getString(message('images:commonUIString:ok')), 'okButton';...
            getString(message('images:commonUIString:cancel')),'cancelButton'; getString(message('images:commonUIString:help')), 'helpButton'};
        
        num_of_buttons = length(button_strs_n_tags);
        
        button_spacing = (panelPos(3)-(num_of_buttons * buttonSize(1)))/(num_of_buttons+1);
        posX = button_spacing;
        posY = 0;
        buttons = zeros(num_of_buttons,1);
        
        for n = 1:num_of_buttons
            buttons(n) = uicontrol('parent',hButtonPanel,...
                'Style','pushbutton',...
                'String',button_strs_n_tags{n,1},...
                'BackgroundColor',bgColor,...
                'Tag',button_strs_n_tags{n,2});
            
            set(buttons(n),'Position',[posX, posY, buttonSize]);
            set(buttons(n),'Callback',{@doButtonPress});
            posX = posX + buttonSize(1) + button_spacing;
        end
        
    end % createButtonPanel

    %--------------------------------
    function callGetColormap(src,evt) %#ok<INUSD>
        
        % the source object is the selected list
        selectedList = src;
        
        % get valid index that was selected
        ind = get(selectedList,'Value');
        if isempty(ind)
            % There is no item in the listbox, no-op
            return
        end
        
        % if there are multiple things selected, only use the last one
        if numel(ind) > 1
            ind = ind(end);
            set(selectedList,'Value',ind);
        end
        
        % If a listbox item is selected in one pane, unselect item in other
        % pane
        selectedPanel = ancestor(selectedList,'uipanel');
        unselectedPanel = displayPanel(displayPanel ~= selectedPanel);
        unselectedList = findobj(unselectedPanel,'Style','Listbox');
        
        % Make selected listbox to allow only single select (fixes CTRL
        % click issue)
        set(selectedList,'Min',0,'Max',1);
        
        % Workaround to have no selected items in a listbox
        set(unselectedList,'Min',0,'Max',2);
        set(unselectedList,'Value',[]);
        
        doubleClick = strcmp(get(hCMapFig, 'SelectionType'), 'open');
        clickedSameListItem = ind ~= 1 && lastSelectedValue == ind;
        stat = getColormap;
        
        if doubleClick && clickedSameListItem && stat
            userCanceled = false;
            close(hCMapFig);
        end
        
        lastSelectedValue = ind;
        
    end % callGetColormap

    %------------------------------
    function doButtonPress(src,evt) %#ok<INUSD>
        % callback function for the OK and Cancel buttons
        
        tag = get(src,'tag');
        
        switch tag
            case 'okButton'
                if getColormap
                    userCanceled = false;
                    close(hCMapFig);
                end
                
            case 'cancelButton'
                revertColormapsToOriginal();
                close(hCMapFig);
                
            case 'helpButton'

                topic = 'imcolormaptool_anchor';
                helpview(fullfile(docroot,'toolbox','images','images.map'),topic);
                
        end
        
    end %doButtonPress

    %------------------------------
    function status = getColormap
        
        status = SUCCESS;
        defaultColormapLength = 256;
        
        % Get the handle of the active panel, i.e. the panel that is
        % associated with the selected radio button
        tag = get(get(hRadioPanel,'SelectedObject'),'tag');
        panelTag = strrep(tag,'RButton','Panel');
        activePanel = findobj(displayPanel,'Tag',panelTag);
        
        % Get the handle of the list box, its current value and string.
        hList = findobj(activePanel,'Type','uicontrol','Style','listbox');
        cmapStr = get(hList,'String');
        % removes trailing spaces from the string
        cmapStr = strtrim(cmapStr);
        
        selectedInd = get(hList,'Value');
        
        % Store this value so that we can revert to it in case of an error.
        previousSelectedInd = selectedInd;
        
        % Determine if it is the function list or the variable list
        isFunctionList = strcmpi('cmapFcnRButton',tag);
        
        % Determine who the caller objects are
        callerType = get(gcbo,'type');
        
        isCallerUicontrol = strcmp(callerType,'uicontrol');
        
        isCallerButton = isCallerUicontrol && ...
            strcmp(get(gcbo,'Style'),'pushbutton');
        
        isCallerListbox = isCallerUicontrol && ...
            strcmp(get(gcbo,'Style'),'listbox');
        
        isCallerEditbox = isCallerUicontrol && ...
            strcmp(get(gcbo,'Style'),'edit');
        
        isCallerFigure = strcmpi(get(gcbo,'Type'),'figure');
        
        if isCallerEditbox || isCallerButton || isCallerFigure
            
            str = get(hObj,'String');
            selectedStr = str;
            
        elseif isCallerListbox
            
            % Get the string from the list item
            if iscell(cmapStr)
                if ~isempty(selectedInd)
                    selectedStr = cmapStr{selectedInd};
                else
                    % If there are no items selected in the listbox
                    selectedStr = '';
                end
            else
                selectedStr = cmapStr;
            end
            
            if isFunctionList
                % If colormap was chosen from "Colormap functions:" pane
                if ~isempty(strfind(selectedStr,['<' customStr '>']))
                    if ~isempty(strfind(selectedStr,[' (' originalStr ')']))
                        cmapOut = originalColormaps{1}; % colormap of the reference axes
                    else
                        cmapOut = lastCustom;
                    end
                    selectedStr = '';
                    if ~isempty(cmapOut)
                        status = applyNewColormap(cmapOut);
                    end
                elseif ~isempty(strfind(selectedStr,['<' expressionStr '>']))
                    selectedStr = '';
                    cmapOut = lastExpression;
                    status = applyNewColormap(cmapOut);
                else
                    selectedStr = strrep(selectedStr, [' (' originalStr ')'], '');
                    selectedStr = sprintf('%s(%d)',selectedStr,...
                        defaultColormapLength);
                end
            end
            
        else
            % When you switch between different panes, retain the previous
            % item in the Edit Box
            selectedStr =  get(hObj,'String');
        end
        
        set(hObj,'String',selectedStr);
        
        if ~isdeployed
            % If the string is either empty or referring to a cleared
            % variable, do not evaluate it
            if isempty(selectedStr) || ~isempty(strfind(selectedStr,['<' clearedStr '>']))
                return;
            end
            if ~isempty(get(findobj(hCMapFig,'Tag','cmapVarList'),'Value')) && ...
                    ~evalin('base',['exist(''' selectedStr ''')'])
                return;
            end
            
            try
                cmapOut = evalin('base',sprintf('%s;',selectedStr));
                stat = applyNewColormap(cmapOut);
            catch ME
                % If the variable was cleared but the item in listbox was
                % not yet marked as <cleared>
                error_str = ME.message;
                errordlg(error_str,getString(message('images:setFigColormap:errorTitle')),'modal');
                status = FAILURE;
                
                % Select whatever was previously selected in the list
                set(hList,'Value',previousSelectedInd);
                return
            end
            
            % If the colormap "cmapOut" is invalid,
            % do not apply it to the axes
            if ~stat, return, end
            if strcmp(panelTag,'cmapFcnPanel')
                if isCallerEditbox
                    % Check if entered expression is one of the predefined
                    % colormaps
                    isFound = false;
                    for i = 1:length(cmapStr)
                        curString = cmapStr{i};
                        % skip expression strings
                        isExpressionString = ~isempty(strfind(curString,['<' expressionStr '>']));
                        if ~isExpressionString
                            % skip custom strings
                            isCustomString = ~isempty(strfind(curString,['<' customStr '>']));
                            if ~isCustomString
                                if isequal(feval(strrep(curString, [' (' originalStr ')'], ''),256),cmapOut)
                                    isFound = true;
                                    break;
                                end
                            end
                        end
                    end
                    if ~isFound
                        selectedInd = strmatch(['<' expressionStr '>'],cmapStr(:));
                        if isempty(selectedInd)
                            % If <expression> item does not exist in the
                            % listbox, create one.
                            set(hList,'String',[['<' expressionStr '>']; cmapStr]);
                            selectedInd = 1;
                        end
                        % Store the last expression if it is not one of the
                        % predefined colormaps
                        lastExpression = cmapOut;
                    else
                        selectedInd = i;
                    end
                end
                set(hList,'Value',selectedInd);
            else
                hFcnList = findobj(hCMapFig,'Tag','cmapFcnList');
                cmapFcnStr = get(hFcnList,'String');
                % removes trailing spaces from the string
                cmapFcnStr = strtrim(cmapFcnStr);
                if isCallerEditbox
                    selectedInd = strmatch(['<' expressionStr '>'],cmapFcnStr(:));
                    if isempty(selectedInd)
                        % If <expression> item does not exist in the
                        % listbox, create one.
                        set(hFcnList,'String',[['<' expressionStr '>']; cmapFcnStr]);
                        selectedInd = 1;
                    end
                    lastExpression = cmapOut;
                    set(hFcnList,'Value',selectedInd);
                    
                    % Switch to "Colormap Functions:" pane
                    fcnPanel = findobj(hCMapFig,'Tag','cmapFcnPanel');
                    varPanel = findobj(hCMapFig,'Tag','cmapVarPanel');
                    set(varPanel,'Visible','off')
                    set(findobj(hCMapFig,'Tag','cmapFcnRButton'),'Value',selectedInd)
                    set(fcnPanel,'Visible','on')
                end
                
            end
            
        else
            % In this case, the function_list is the only list
            
            % The list box is the only caller since the edit box
            % is disabled.
            cmapFcn = getColormapFcnList(selectedInd,2);
            
            % if there was no selection and OK was clicked
            % cmapFcn will be empty
            if isempty(cmapFcn)
                cmapOut = originalColormaps{1};
            else
                cmapOut = cmapFcn(defaultColormapLength);
            end
            
        end
        % If no item is selected, then don't update axes's colormap
        if ~isempty(cmapOut)
            status = applyNewColormap(cmapOut);
        end
        
    end %getColormap

    %-------------------------------
    function status = applyNewColormap(map)
        
        status = true;
        for k = 1:numel(hDependentAxes)
            if ishandle(hDependentAxes{k})
                status = status && setAxesColormap(hDependentAxes{k},map);
            end
        end
        
    end %applyNewColormap

    %--------------------------------
    function stat = setAxesColormap(hAx,map)
        % Disables the colormap listeners, sets the colormap, reenables the
        % listeners
        
        stat = true;
        
        try
            iptcheckmap(map,'setFigColormap','map',1);
            
            % Disable colormap listener
            hasAppdata = isappdata(hCMapFig,'colormapListener');
            if hasAppdata
                mapListener = getappdata(hCMapFig,'colormapListener');
                if isa(mapListener,'event.listener')
                    mapListener.Enabled = false;
                else
                    mapListener.Enabled = 'off';
                end
            end
            
            % Change colormap
            colormap(hAx,map);
            
            % Re-enable listener
            if hasAppdata
                if isa(mapListener,'event.listener')
                    mapListener.Enabled = true;
                else
                    mapListener.Enabled = 'on';
                end
                clear mapListener;
            end
            
        catch ME
            
            if strcmp(ME.identifier,'MATLAB:images:validate:badMapValues')
                error_str = ME.message;
            elseif strcmp(ME.identifier,'MATLAB:images:validate:badMapMatrix')
                error_str = ME.message;
            else
                error_str = getString(message('images:setFigColormap:invalidColorMap'));
            end
            errordlg(error_str,getString(message('images:setFigColormap:errorTitle')),'modal');
            stat = false;
            
        end
        
    end % setFigColormap

end % imcolormaptool

%---------------------------------------------------------
function cmapStrs_and_fcns = getColormapFcnList(varargin)

cmap_store = {'autumn', @autumn
              'bone', @bone
              'colorcube', @colorcube
              'cool', @cool
              'copper', @copper
              'flag', @flag
              'gray', @gray
              'hot', @hot
              'hsv', @hsv
              'jet', @jet
              'lines', @lines
              'parula', @parula
              'pink', @pink
              'prism', @prism
              'spring', @spring
              'summer', @summer
              'white', @white
              'winter', @winter};

switch nargin
    case 0
        cmapStrs_and_fcns = cmap_store;
    case 2
        cmapStrs_and_fcns = cmap_store{varargin{:}};
end

end %getColormapFcnList


%--------------------------------------------------------------------------
function [hClientFig,hTarget,hReferenceAxes,hReferenceImage,hDependentAxes] = parseInputs(varargin)

% One or zero input argument is allowed
narginchk(0,1);

% get client figure
if nargin == 1
    % Check if supplied target is a valid figure or axes handle
    hTarget = varargin{1};
    iptcheckhandle(hTarget,{'figure','axes'},mfilename,'HCLIENT',1);
else
    hTarget = get(0,'CurrentFigure');
end

% Find valid images in the target figure or target axes
% A valid image is grayscale or indexed
imHandle = findall(hTarget,'type','image');
hValidImages = [];
for i = 1:length(imHandle)
    % skip colorbar
    if(strcmp(get(imHandle(i),'Tag'),'TMW_COLORBAR'))
        continue;
    end
    % verify image is 2D
    if ismatrix(get(imHandle(i),'CData'))
        hValidImages = [hValidImages; imHandle(i)]; %#ok<AGROW>
    end
end

if isempty(hValidImages)
    error(message('images:imcolormaptool:noValidImage'))
end

% The reference image is the one we will listen to
% for changes made outside of the colormap tool (CData)
hReferenceImage = hValidImages(1);

% Dependent axes are axes whose colormaps we will update
% when the user chooses a colormap in the colormap tool
hDependentAxes = ancestor(hValidImages,'axes');

if ~iscell(hDependentAxes)
    % there is only one axes
    hDependentAxes = {hDependentAxes};
end

% Reference axes is the axes we will listen to
% for changes made outside of the colormap tool

% hClientFig is used for storing appdata and
% for relative figure placement

% hTarget is either hClientFig or hReferenceAxes

if ishghandle(hTarget,'figure')
    hClientFig = hTarget;
    hReferenceAxes = ancestor(hReferenceImage,'axes');
else
    % axes
    hReferenceAxes = hTarget;
    hClientFig = ancestor(hReferenceAxes,'figure');
end

% Bring hClientFig to foreground
if ~isempty(hClientFig)
    figure(hClientFig)
end

end %parseInputs
