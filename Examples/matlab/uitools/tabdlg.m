function varargout = tabdlg(varargin)
% This function is undocumented and will change in a future release

%TABDLG Create and manage tabbed dialog box.
%   [HFIG, SHEETPOS, HSHEETPANELS, HBUTTONPANEL] = TABDLG(...
%       'create',STRINGS,TABDIMS,CALLBACK,SHEETDIMS,OFFSETS,...
%       DEFAULT_PAGE, FONT, HFIG)
%
%   'create' - a flag for requesting dialog creation
%
%   STRINGS -  cell array of the tab labels.
%
%   TABDIMS - a cell array of length 2.
%     TABDIMS{1} - a vector of same length as 'strings' specifying the
%                  width in pixels, of each tab.
%
%     TABDIMS{2} - a scalar specifying string heights (in pixels).
%
%   See the ADDITIONAL FUNCTIONALITY section of this help for more info.
%
%   CALLBACK - name of callback function that will be called each time that
%              a new tab is selected.  The callback function will be called
%              with the following arguments:
%              1) 'tabcallbk'     - a text flag
%              2) pressedTab      - the string of selected tab
%              3) pressedTabNum   - the number of the selected tab
%              4) previousTab     - the string of the previously selected tab
%              5) previousTabNum  - the number of the previously selected tab
%              6) hfig            - handle of the figure
%
%              The callback function must manage all aspects of the tabbed
%              dialog box other than the management of the actual tabs
%              (i.e., swapping visibility of controls).
%
%   SHEETDIMS - [width, height] of the tab sheet in pixels.
%
%   OFFSETS - Four element vector of offsets between the edges
%            of the sheets and the figure border (in pixels):
%            [ offset from left side of figure
%              offset from top of figure
%              offset from right of figure
%              offset from bottom of figure ]
%
%   NOTE - if a button panel is requested, the fourth offset is the offset
%          from the bottom of the button panel.  There is a fixed offset of
%          5 pixels from the bottom of the sheet to the top of the button
%          panel, and the button panel has a fixed height of 23 pixels.
%
%   DEFAULT_PAGE - page number that is shown upon creation.
%
%   OPTIONAL ARGUMENTS:
%   FONT - a two element cell array (arg 8)
%     {'fontname', fontsize}
%
%     The FactoryUicontrolFontName and FactoryUiControlFontSize are
%     used by default.
%
%   HFIG - handle to a figure window (arg 9)
%     If this option is used, the 'font' argument must also be
%     specified.  If the default font is desired, use {}.
%     Sometimes it is necessary to create a figure in order
%     to get text extents for geometry calculations.
%     In this case, create the figure, do geometry calculations
%     and then call tabdlg.  The existing figure will be used
%     for the tabbed dialog box.  Do not place any controls on the
%     figure until after the call tabdlg.
%
%     NOTE: It is assumed that HFIG is a non-integer handle and
%     that the figure is invisible!
%
%     NOTE: The dialog is invisible so that further processing
%           may be done.
%
%    NOTE: This function does NOT work with docked figures.
%
%   RETURNS:
%     HFIG     - handle to the newly created tabbed dialog.
%     SHEETPOS - 4 element position vector [x y width height] of 
%                the sheet.
%	HSHEETPANELS - handle to the sheet panels.
%	HBUTTONPANEL - handle to the button panel that is optionally
%                    created if this output argument is specified.
%
%     NOTE - Buttons may be placed in the figure without a button
%     panel; make sure that there is enough room between the bottom
%     of the figure, the buttons and the bottom of the sheet for 
%     proper button placement.  If a button panel is specified, the 
%     buttons should be placed in this button panel.
%
%   ADDITIONAL FUNCTIONALITY
%
%   TABDIMS = TABDLG('tabdims', STRINGS, FONT)
%     Given the font and the strings, returns a tabDims cell array of
%     the form described above.  This is a fairly expensive operation
%     and as such is not done "on the fly" when creating the tabbed
%     dialog.  Doing it before hand and passing the widths in to the
%     creation call results in better performance.
%
%     STRINGS - see description above
%     FONT    - see description above
%
%     example: TABDIMS = TABDLG('tabdims', {'cat', 'bird'});
%
%     NOTE: font is an OPTIONAL argument.
%     NOTE: the height is the height of the string, NOT the height of
%           the tab
%
%   Example:
%       (this comes up when tabldg is called with zero args)
%
%        %
%        % Create tabbed dialog.
%        %
%        tabStrings = {'Random', 'Sine Wave'};
%        [dialogFig, sheetPos, sheetPanels, buttonPanel] = ...
%            tabdlg('create', tabStrings);
%
%        % put something on the sheets
%        a1 = axes('Parent',sheetPanels(1));
%        plot(rand(5),'Parent',a1);
%        ht = a1.Title;
%        ht.String = 'Random';
%
%        a2 = axes('Parent',sheetPanels(2));
%        t = 0:.01:2*pi;
%        plot(t, sin(t),'Parent',a2);
%        ht = a2.Title;
%        ht.String = 'Sine wave';
%
%        % put some buttons on the button panel
%        buttonStrings = {'OK', 'Apply', 'Cancel'};
%        buttonCallbacks = {'close(gcbf)','close(gcbf)','close(gcbf)'};
%        offsets = [5 5];
%        pos = get(0,'DefaultUicontrolPosition');
%        numControls = length(buttonStrings);
%        containerPos = getpixelposition(buttonPanel);
%        leftOffset = containerPos(3)/2 - ...
%            ((numControls-1) * offsets(1) + numControls * pos(3))/2;
%        for i = 1:numControls
%            uicontrol(buttonPanel, ...
%                'Style','pushbutton', ...
%                'String', buttonStrings{i}, ...
%                'Position', ...
%                [offsets(1) * i + leftOffset + pos(3) * (i-1) ...
%                offsets(2)/2 pos(3:4)], ...
%                'Callback', buttonCallbacks{i});
%        end
%        dialogFig.Visible = 'on';

%   Copyright 1984-2014 The MathWorks, Inc.
%     

nuserargout = nargout;

if nargin == 0
    [dialogFig, sheetPos, sheetPanels, buttonPanel] = i_SampleTabbedDialog;
    if nargout
        varargout = {dialogFig, sheetPos, sheetPanels, buttonPanel};
    end
    return;
end

Action = lower(varargin{1});

hSheets = [];

switch(Action)

    case 'create'
        [fig, sheetPos, sheets, buttonPanel] = i_CreateTabbedDialog(varargin{2:end});
        varargout = {fig, sheetPos, sheets, buttonPanel};

    case 'tabdims'
        varargout =  {i_DetermineTabDims(varargin{2:end})};

    case 'tabpress'
        % this is here incase anyone is using the old command line API
        i_TabPressHandler(varargin{2},[],varargin{3},varargin{4});

    otherwise
        error(message('MATLAB:tabdlg:InvalidAction'));
end

%******************************************************************************
% Function - handle key press function
%******************************************************************************
    function i_keypress(obj, evd)
        switch(evd.Key)
            case {'return','space'}
                % TODO find the default uicontrol and execute the callback
            case 'escape'
                close(obj)
        end
    end

%******************************************************************************
% Function - Get the user data for the tabbed dialog.                       ***
%******************************************************************************
    function data = i_GetDialogData(dialog)

        oldHiddenHandleStatus = get(0, 'ShowHiddenHandles');
        set(0, 'ShowHiddenHandles', 'on');

        dataContainer = findobj(dialog,...
            'Type',       'uicontrol', ...
            'Style',      'text', ...
            'Tag',        'TMWDlgDat@#' ...
            );

        data = get(dataContainer, 'UserData');

        set(0, 'ShowHiddenHandles', oldHiddenHandleStatus);

    end

%******************************************************************************
% Function - Set the user data for the tabbed dialog.                       ***
%******************************************************************************
    function i_SetDialogData(dialog, data)

        oldHiddenHandleStatus = get(0, 'ShowHiddenHandles');
        set(0, 'ShowHiddenHandles', 'on');

        dataContainer = findobj(dialog,...
            'Type',       'uicontrol', ...
            'Style',      'text', ...
            'Tag',        'TMWDlgDat@#' ...
            );

        if isempty(dataContainer)
            dataContainer = uicontrol(...
                'Parent',           dialog, ...
                'Style',            'text', ...
                'Visible',          'off', ...
                'Tag',              'TMWDlgDat@#' ...
                );
        end

        set(dataContainer, 'UserData', data);

        set(0, 'ShowHiddenHandles', oldHiddenHandleStatus);

    end

%******************************************************************************
% Function - Create the tabbed dialog box.                                  ***
%******************************************************************************
    function [hfig, sheetPosActual, sheets, buttonPanel] = i_CreateTabbedDialog( ...
            strings, tabDims, callback, sheetDims, offsets, default_page, font, hfig ...
            )

     %==============================================================================
        % Argument checks.
        %==============================================================================
        if nargin < 2
            tabDims='';
        end
        if nargin < 3
            callback='';
        end
        if nargin < 4
            sheetDims=[300 250];
        end
        if nargin < 5
            offsets=[ 5 5 5 5 ];
        end
        if nargin < 6
            default_page=1;
        end
        if nargin < 7
            font='';
        end
        if nargin < 8
            hfig=-1;
        end

        if ~isempty(font)
            fontsize = font{2};   %#ok
            fontname = font{1};   %#ok
        else
            fontsize = get(0, 'FactoryUicontrolFontSize');   %#ok
            fontname = get(0, 'FactoryUicontrolFontName');   %#ok
        end

        %==============================================================================
        % Create figure (dialog)
        %==============================================================================
        origDefaultUicontrolEnable = get(0, 'DefaultUicontrolEnable');

        if hfig == -1
            % g467328 - if no figure was passed in, create an undocked figure,
            % as tabdlg does not work with docked figures.            
          hfig = figure( ...
		    'WindowStyle', 				'normal', ...
                'Visible',                            'off', ...
                'Color',                              get(0,'FactoryUicontrolBackgroundColor'), ...
                'Units',                              'pixels', ...
                'Resize',                             'off', ...
                'MenuBar',                            'none', ...
                'IntegerHandle',                      'off', ...
                'NumberTitle',                        'off', ...
                'DefaultUicontrolUnits',              'pixels', ...
                'DefaultUicontrolEnable',             'inactive', ...
                'KeyPressFcn',                        @i_keypress ...
                );
        else
            % g467328 - if we are trying to use this with docked figures, 
            % error out as this is not supported.
            if (isequal(get(hfig,'WindowStyle'), 'docked'))
                error(message('MATLAB:tabdlg:NoDockedFigures'));
            end
            
            set(hfig, ...
                'Color',                              get(0,'FactoryUicontrolBackgroundColor'), ...
                'Units',                              'pixels', ...
                'Resize',                             'off', ...
                'MenuBar',                            'none', ...
                'NumberTitle',                        'off', ...
                'DefaultUicontrolUnits',              'pixels', ...
                'DefaultUicontrolEnable',             'inactive', ...
                'KeyPressFcn',                        @i_keypress ...
                );
        end

        if isempty(tabDims)
            tabDims = i_DetermineTabDims(strings);
        end

        %==============================================================================
        % Calculate geometry constants.
        %==============================================================================
        stringHeight  = tabDims{2};   %#ok
        tabHeight     = tabDims{2} + 4;
        tabWidths     = [0; tabDims{1}(:)];
        numTabs       = length(tabWidths) - 1;

        leftBevelOffset         = 0;
        rightBevelOffset        = 3;
        topBevelOffset          = 1;
        selectorHeight          = 2;
        selectorLeftFudgeFactor = 2;   %#ok
        deltaTabs               = 2;
        selectionHoffset        = 0;

        minWidth = sum(tabWidths) + (numTabs)*deltaTabs;
        sheetDims(1) = max(minWidth,sheetDims(1));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % In order to give the selected tab a 3-D look, it is made slightly
        %  taller & wider than its unselected size.  selectionVoffset is the
        %  number of pixels by which the selected tabs height is increased.
        %  Likewise for selectionHoffset.
        % NOTE: The 1st tab only lines up w/ the left side of the sheet when
        %       it is the selected tab!
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        selectionVoffset = 3;

        % If requested, put a panel below the sheets for the OK/Apply/Cancel 
        % buttons.
        % Offets are [left top right bottom]
        % sheetPosActual is [x y width height]
        % figHeight = total height of the figure
        % buttonPanelHeight = 23 (hardcoded, size needed to surround buttons.
	  % buttonPanelOffset = buttonPanelHeight + 5 (number of pixels between 
        % bottom of sheet and top of button panel
        buttonPanel = [];
        buttonPanelHeight = 0;  %#ok
        buttonPanelHeightOffset = 0;
        if (nuserargout > 3)
            buttonPanelHeight = 23;
            buttonPanel = uipanel( ...
                'Parent',           hfig, ...
                'BorderType',       'none', ...
                'Units',            'pixels', ...
                'Position',         [
                offsets(1)+1    % to the right one pixel, looks better
                offsets(4)+1   % just a bit above the bottom
                sheetDims(1)  
                buttonPanelHeight 
                ] ...
                );
            buttonPanelHeightOffset = buttonPanelHeight + 5;
        end

        %==============================================================================
        % Set figure width & height.
        %==============================================================================
        figPos = get(hfig, 'Position');

        figHeight = offsets(4) + ...               % bottom offset plus
                          sheetDims(2) + ...       % height of sheet plus
                          tabHeight + ...          % height of tab plus
                          selectionVoffset  + ...  % selection offset for etching plus
                          offsets(2) + ...         % top offset plus
                          buttonPanelHeightOffset; % buttonPanelHeightOffset (0 if no
                                                   %   buttonPanel requested)
        figWidth = offsets(1) + sheetDims(1) + offsets(3);

        figPos(3:4) = [figWidth, figHeight];
        set(hfig, 'Position', figPos);


        %==============================================================================
        % Calculate sheet position.
        %==============================================================================
        sheetPos = [
            offsets(1) + 1
            offsets(4) + 1 + buttonPanelHeightOffset 
            sheetDims(1)
            sheetDims(2)
            ];

        %==============================================================================
        % Create the tabs & store selector positions.
        %==============================================================================
        posTab(4) = tabHeight;
        posTab(2) = sheetPos(2) + sheetPos(4) - 2;
        
        tabs = createEmptyPanel(hfig);
        selectorPos   = zeros(numTabs, 4);
        for i = 1:numTabs

            butDownFcn = {@i_TabPressHandler, strings{i}, i};

            leftEdge =...
                sheetPos(1)            + ...
                selectionHoffset       + ...
                sum(tabWidths(1:i))    + ...
                ( (i-1) * deltaTabs );

            posTab(1) = leftEdge;
            posTab(3) = tabWidths(i+1) + 1;
            
  
            tabs(i) = uipanel( ...
                'Parent',           hfig, ...
                'Units',            'pixels', ...
                'Position',         posTab, ...
                'ButtonDownFcn',    butDownFcn ...
                );
            

            ppos = getpixelposition(tabs(i));
            ppos = [1 2 ppos(3) - 4 ppos(4) - 6];
            htmp = uicontrol(tabs(i), ...
                'Style',            'text', ...
                'Enable',           'inactive', ...
                'String',           strings{i}, ...
                'HorizontalAlignment',  'center', ...
                'Units',            'pixels', ...
                'Position',         ppos, ...
                'ButtonDownFcn',    butDownFcn ...
                );
            set(htmp,'Units', 'normalized');

            % we used to have this here, it's only here now
            % for backward compat with callers that call findobj
            % like testomatic
            c = uicontrol(tabs(i), ...
                'String',           get(htmp,'String'), ...
                'Position',         get(htmp,'Position'), ...
                'HorizontalAlignment',  get(htmp,'HorizontalAlignment'), ...
                'ButtonDownFcn',    {@i_buttonDownFcnProxy,htmp}, ...
                'Visible',          'off');

            % connect units between the panel and the control because
            % callers may want to change units (say to chars)
            linkproperties([tabs(i) c],'Units');

            selectorPos(i, :) = [ ...
                leftEdge - selectionHoffset + leftBevelOffset + 1 ...
                posTab(2) + 1  ...
                posTab(3) + selectionHoffset - rightBevelOffset ...
                selectorHeight ...
                ];

        end

        %==============================================================================
        % Create the sheets.
        %==============================================================================
        sheetPosActual = sheetPos;
        sheetPosActual(4) = sheetPosActual(4) + topBevelOffset;
        sheets = zeros(1,numTabs);
        for i = numTabs:-1:1
            sheets(i) = uipanel( ...     
                'Parent',             hfig, ...
                'Units',              'pixels', ...
                'Position',           sheetPosActual ...
                );
        end
        hSheets = sheets;

        % we used to have this here, it's only here now
        % for backward compat with callers that call findobj
        uicontrol(hfig, ...
            'Units',            'pixels', ...
            'Position',         sheetPosActual, ...
            'Visible',          'off');

        %==============================================================================
        % Create the selector.
        %==============================================================================
        hicolor = get(sheets(1), 'highlightcolor');
        selector = uipanel( ...
            'BorderType', 'none', ...
            'BackgroundColor', hicolor, ...
            'Units', 'pixels', ...
            'Position', selectorPos(1,:), ...
            'Parent', hfig);
        selectorChild = uipanel( ...
            'Parent', selector, ...
            'Units', 'pixels', ...
            'Position',[2 1 2 2], ...
            'BorderType', 'none' ...
            );

        %==============================================================================
        % Save pertinent info in tabbed dialog data container.
        %==============================================================================
        DialogUserData.tabs             = tabs;
        DialogUserData.selector         = selector;
        DialogUserData.selectorChild    = selectorChild;
        DialogUserData.selectorPos      = selectorPos;
        DialogUserData.selectionHoffset = selectionHoffset;
        DialogUserData.selectionVoffset = selectionVoffset;
        DialogUserData.leftBevelOffset  = leftBevelOffset;
        DialogUserData.rightBevelOffset = rightBevelOffset;
        DialogUserData.deltaTabs        = deltaTabs;
        DialogUserData.activeTabNum     = -1;
        DialogUserData.callback         = callback;
        DialogUserData.strings          = strings;
        DialogUserData.sheets           = hSheets;

        %==============================================================================
        % Select the default tab.
        %==============================================================================
        DialogUserData = i_PressTab(hfig, DialogUserData, default_page);

        %==============================================================================
        % Store the user data.
        %==============================================================================
        i_SetDialogData(hfig, DialogUserData);

        %==============================================================================
        % Restore defaults.
        %==============================================================================
        set(hfig, 'DefaultUicontrolEnable', origDefaultUicontrolEnable);

    end

%******************************************************************************
% Function - Press the specified tab.                                       ***
%******************************************************************************
    function DialogUserData = i_PressTab(hfig, DialogUserData, pressedTabNum)   %#ok

        posPressedTab = get(DialogUserData.tabs(pressedTabNum), 'Position');

        posPressedTab(1) = posPressedTab(1) - DialogUserData.selectionHoffset;
        posPressedTab(3) = posPressedTab(3) + DialogUserData.selectionHoffset;
        posPressedTab(4) = posPressedTab(4) + DialogUserData.selectionVoffset;

        set(DialogUserData.tabs(pressedTabNum), 'Position', posPressedTab);

        set(DialogUserData.selector, ...
            'Position',           DialogUserData.selectorPos(pressedTabNum,:) ...
            );

        posChild = get(DialogUserData.selectorChild,'Position');
        posChild(3) = posPressedTab(3) - 2;
        set(DialogUserData.selectorChild, ...
            'Position',           posChild ...
            );

        DialogUserData.activeTabNum = pressedTabNum;

        % Switch the visibility of the new panel to on.
        set(DialogUserData.sheets(pressedTabNum), 'Visible', 'on');
    end

%******************************************************************************
% Function - Unpress the specified tab.                                     ***
%                                                                           ***
% Reduces the size of the specified tab.                                    ***
%                                                                           ***
% NOTE: This function does not move the selector or update the              ***
%   activeTabNum field.  It is assumed that a call to i_PressTab will       ***
%   soon occur and take care of these tasks.                                ***
%******************************************************************************
    function i_UnPressTab(hTab, nTab, DialogUserData)   %#ok

        posTab = get(DialogUserData.tabs(nTab), 'Position');

        posTab(1) = posTab(1) + DialogUserData.selectionHoffset;
        posTab(3) = posTab(3) - DialogUserData.selectionHoffset;
        posTab(4) = posTab(4) - DialogUserData.selectionVoffset;

        set(DialogUserData.tabs(nTab), 'Position', posTab);

        % Switch the visibility of the currently selected  panel to off.
        set(DialogUserData.sheets(nTab), 'Visible', 'off');
    end

%******************************************************************************
% Function - Process tab press action.                                      ***
%******************************************************************************
    function [DialogUserData, bModified] = ...
            i_ProcessTabPress(hfig, DialogUserData, string, pressedTabNum)   %#ok

        %==============================================================================
        % Initialize.
        %==============================================================================
        bModified = 0;

        tabs         = DialogUserData.tabs;
        activeTabNum = DialogUserData.activeTabNum;
        if pressedTabNum == activeTabNum
            return;
        end

        i_UnPressTab(tabs(activeTabNum), activeTabNum, DialogUserData);
        DialogUserData = i_PressTab(hfig, DialogUserData, pressedTabNum);
        bModified = 1;
    end

%******************************************************************************
% Function - Determine the widths of the tabs based on the strings.         ***
%******************************************************************************
    function tabdims = i_DetermineTabDims(strings, font)

        %==============================================================================
        % Argument checks.
        %==============================================================================
        if nargin == 1
            fontsize = get(0, 'DefaultUicontrolFontSize');   %#ok
            fontname = get(0, 'DefaultUicontrolFontName');   %#ok
        else
            fontsize = font{2};   %#ok
            fontname = font{1};   %#ok
        end

        %==============================================================================
        % Create figure and sample text control.
        %==============================================================================
        hfig  = figure('Visible', 'off');
        hText = uicontrol('Style', 'text', 'FontWeight', 'bold');

        %==============================================================================
        % Get widths.
        %==============================================================================
        tabdims1 = zeros(length(strings),1);
        for i=1:length(strings)
            set(hText, 'String', strings{i});
            ext = get(hText, 'Extent');
            tabdims1(i) = ext(3) + 2; 
        end
        
        tabdims{1} = tabdims1;
        tabdims{2} = ext(4) + 2;

        %==============================================================================
        % Delete objects.
        %==============================================================================
        delete(hfig);
    end

    function i_TabPressHandler(obj, evd, string, activeTabNum)   %#ok
        hfig = ancestor(obj,'figure');
        DialogUserData = i_GetDialogData(hfig);
        previousTabNum = DialogUserData.activeTabNum;
        [DialogUserData, bModified] = ...
            i_ProcessTabPress(hfig, DialogUserData, string, activeTabNum);

        if bModified == 1
            i_SetDialogData(hfig, DialogUserData);
            if isempty(DialogUserData.callback)
                return;
            end

            feval(DialogUserData.callback, ...
                'tabcallbk', ...
                DialogUserData.strings{activeTabNum}, ...
                activeTabNum, ...
                DialogUserData.strings{previousTabNum}, ...
                previousTabNum, ...
                hfig ...
                );

        end

    end

% helper function for testomatic
    function i_buttonDownFcnProxy(obj, evd, proxyObj)   %#ok
        bdfcn = get(proxyObj,'ButtonDownFcn');
        feval(bdfcn{1}, proxyObj, [], bdfcn{2}, bdfcn{3});
    end

% sample demo function
    function [dialogFig, sheetPos, sheetPanels, buttonPanel] = i_SampleTabbedDialog
        %
        % Create tabbed dialog.
        %
        tabStrings = {getString(message('MATLAB:tabdlg:Random')), getString(message('MATLAB:tabdlg:SineWave'))};
        [dialogFig, sheetPos, sheetPanels, buttonPanel] = ...
            tabdlg('create', tabStrings);

        % put something on the sheets
        a1 = axes('Parent',sheetPanels(1));
        plot(rand(5),'Parent',a1);
        ht = get(a1,'Title');
        set(ht,'String', getString(message('MATLAB:tabdlg:Random')))

        a2 = axes('Parent',sheetPanels(2));
        t = 0:.01:2*pi;
        plot(t, sin(t),'Parent',a2);
        ht = get(a2,'Title');
        set(ht,'String',getString(message('MATLAB:tabdlg:SineWave')))

        % put some buttons on the button panel
        buttonStrings = {getString(message('MATLAB:tabdlg:OK')), getString(message('MATLAB:tabdlg:Apply')), getString(message('MATLAB:tabdlg:Cancel'))};
        buttonCallbacks = {'close(gcbf)','close(gcbf)','close(gcbf)'};
        offsets = [5 5];
        pos = get(0,'DefaultUicontrolPosition');
        numControls = length(buttonStrings);
        containerPos = getpixelposition(buttonPanel);
        leftOffset = containerPos(3)/2 - ...
            ((numControls-1) * offsets(1) + numControls * pos(3))/2;
        for i = 1:numControls
            uicontrol(buttonPanel, ...
                'Style','pushbutton', ...
                'String', buttonStrings{i}, ...
                'Position', ...
                [offsets(1) * i + leftOffset + pos(3) * (i-1) ...
                offsets(2)/2 pos(3:4)], ...
                'Callback', buttonCallbacks{i});
        end
        set(dialogFig, 'Visible', 'on');
    end

     %==============================================================================
     % A sub-function to ensure that objects have their property
     % linked.
     %==============================================================================
    function linkproperties(h,p)
       assert(all(size(h) == [1 2]));
       addlistener(h(1),p,'PostSet',@(o,e) set(h(2),p,get(h(1),p)));
       addlistener(h(2),p,'PostSet',@(o,e) set(h(1),p,get(h(2),p))); 
    end
    

end
