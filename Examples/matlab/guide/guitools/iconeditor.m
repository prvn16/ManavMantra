function varargout = iconeditor(varargin)
% ICONEDITOR GUI for create icon CData used for HG objects
%       CDATA = ICONEDITOR(...) runs the GUI. And return the edited icon
%       data to the caller. CDATA is a three dimensional array if the Ok
%       button is pressed. Otherwise, it is empty.
%
%       ICONEDITOR('Property','Value',...) runs the GUI. This GUI
%       accepts property value pairs from the input arguments. Starting
%       from the left, property value pairs are applied to the GUI figure.
%       The following custom properties are also supported that can be used
%       to initialize this GUI. The names are not case sensitive: 
%         'icon'          the icon array in true color format
%         'iconwidth'     desired width of the icon array
%         'iconheight'    desired height of the icon array
%         'iconfile'      source file for loading the icon for editing
%       Other unrecognized property name or invalid value is ignored.
%
%   Examples:
%
%   uicontrol('CData',iconeditor('iconwidth', 16, 'iconheight', 25));
%
%   uicontrol('CData',iconeditor('icon', rand(16,16,3)));
%
%   cdata = iconeditor('iconfile', 'eraser.gif');
%   uicontrol('CData',cdata);

%   Copyright 1984-2014 The MathWorks, Inc.

% Declare non-UI data here so that they can be used in any functions in
% this GUI file. 
mInputArgs      =   varargin;   % Command line arguments when invoking the GUI
mOutputArgs     =   {};         % Variable for storing output when GUI returns
mIsMouseDown  =   false;      % Flag for indicating whether the current mouse 
                                % move is used for editing color or not
% Variables for supporting custom property/value pairs
mPropertyDefs   =   {...        % The supported custom property/value pairs of this GUI
                     'icon',        @localValidateInput, 'mIconCData';
                     'iconwidth',   @localValidateInput, 'mIconWidth';
                     'iconheight',  @localValidateInput, 'mIconHeight';
                     'iconfile',    @localValidateInput, 'mIconFile';
                     'caller',      @localValidateInput, 'mCaller';
                     'callerapi',   @localValidateInput, 'mCallerAPI'};
mIconCData      =   [];         % The icon CData edited by this GUI of dimension
                                % [mIconHeight, mIconWidth, 3]
mIconWidth      =   16;         % Use input property 'iconwidth' to initialize
mIconHeight     =   16;         % Use input property 'iconheight' to initialize
mIconFile       =   fullfile(matlabroot,'toolbox/matlab/icons/'); 
                                % Use input property 'iconfile' to initialize
mCaller         =   '';         % The source who invoked this editor
mCallerAPI      =   struct();   % The struct that contains the function handles for working with the caller

% The current tool that will be applied to the icon editing canvas when
% mouse moves or clicks. It is a struct with field; type, tool,  and
% action. type indicate whether it is coloring or callback, tool could be a
% handle to a HG object,  and action is the callback that will be called
% with the icon data and mouse info as inputs.
mCurrentTool = [];         

% set up action table. The 'action' and 'user' entries should be filled up
% when the GUI is populated.
mActionTable = createActionTable();

% Create all the UI objects in this GUI here so that they can
% be used in any functions in this GUI
mEditorWidth    = 120; %in character
mDefaultControlColor=javax.swing.UIManager.getColor('control');
mDefaultControlColor = [mDefaultControlColor.getRed, mDefaultControlColor.getGreen, mDefaultControlColor.getBlue]/255;
hMainFigure     =   figure(...
                    'Units','characters',...
                    'MenuBar','none',...
                    'Toolbar','none',...
                    'Color',mDefaultControlColor,...
                    'Visible','off',...
                    'Resize','off',...
                    'WindowStyle', 'modal',...
                    'Position',[71.8 34.7 mEditorWidth 36.15],...
                    'WindowButtonDownFcn', @hMainFigureWindowButtonDownFcn,...
                    'WindowButtonUpFcn', @hMainFigureWindowButtonUpFcn,...
                    'WindowButtonMotionFcn', @hMainFigureWindowButtonMotionFcn,...
                    'CloseRequestFcn', @hMainFigureCloseRequestFcn);
% create tools panel                
hToolPalettePanel=   uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'BorderType','none',...
                    'Title','',...
                    'Clipping','on',...
                    'Position',[1.8 4.3 7 27.77]);
% create icon edit panel
hIconEditPanel  =    uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Clipping','on',...
                    'Position',[13 4.3 69.2 27.77]);
hIconEditAxes   =   axes(...
                    'Parent',hIconEditPanel,...
                    'vis','off',...
                    'Position',[0 0 1 1]);
% create icon file selection panel
pos = [1.8 32.9 mEditorWidth-2*1.8 1.8];
hIconFilePanel  =   uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'BorderType','none',...
                    'Clipping','on',...
                    'Position',pos);                
hIconFileText   =   uicontrol(...
                    'Parent',hIconFilePanel,...
                    'Units','characters',...
                    'HorizontalAlignment','right',...
                    'Position',[0 0 22 1.46],...
                    'String',getUserString('ImportIconFileLabel'),...
                    'Style','text');                
hIconFileEdit   =   uicontrol(...
                    'Parent',hIconFilePanel,...
                    'Units','characters',...
                    'Interruptible','off',...
                    'HorizontalAlignment','left',...
                    'Position',[23.2 0 pos(3)-12-23.2-1.8 1.62],...
                    'String',getUserString('ImportIconFilePrompt'),...
                    'Enable','inactive',...
                    'Style','edit',...
                    'ButtondownFcn',@hIconFileEditButtondownFcn,...
                    'Callback',@hIconFileEditCallback);               
hIconFileButton =   uicontrol(...
                    'Parent',hIconFilePanel,...
                    'Units','characters',...
                    'Callback',@hIconFileButtonCallback,...
                    'Position',[pos(3)-12 0 12 1.77],...
                    'String',getUserString('ImportButtonLabel'),...
                    'TooltipString',getUserString('ImportButtonTooltip'));
hPreviewPanel   =   uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Title',getUserString('PreviewPanelTitle'),...
                    'Clipping','on',...
                    'Position',[85.8 23.38 32.2 8.77]);
hPreviewControl =   uicontrol(...
                    'Parent',hPreviewPanel,...
                    'Units','characters',...
                    'Enable','inactive',...
                    'Visible','off',...
                    'Position',[2 3.77 16.2 5.46],...
                    'String','');

% create the button panel
createButtonPanel();

% create the palette panel                
hPalettePanel=  uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Title',getUserString('PanelTitleColorPalette'),...
                    'Clipping','on',...
                    'Position',[85.8 4.3 32.2 18.23]);

% The set of function handles that define the API of this iconeditor
mAPISet = struct(...
    'setCurrentTool', @setCurrentTool,...
    'setColor', @setColor,...
    'getColor', @getColor);

% Host the ColorPalette in the PaletteContainer and keep the function
% handle for getting its selected color for editing icon
mPaletteAPI = colorpalette('parent', hPalettePanel, 'iconeditorapi',mAPISet);

mToolAPI = toolpalette('parent', hToolPalettePanel, 'iconeditorapi',mAPISet);

% Make changes needed for proper look and feel and running on different
% platforms 
prepareLayout(hMainFigure);                            

% Process the command line input arguments supplied when the GUI is
% invoked 
processUserInputs();                            

% Initialize the iconeditor using the defaults or custom data given through
% property/value pairs
localUpdateIconPlot();

% Make the GUI on screen
set(hMainFigure,'visible', 'on');
movegui(hMainFigure,'onscreen');

% pass testing api to the caller
if isTesting
    mCallerAPI.testing.setChildToolTestingAPI('iconeditor',guide2tool);
end

% Make the GUI blocking
uiwait(hMainFigure);

% Return the edited icon CData if it is requested
mOutputArgs{1} =mIconCData;
if isGUIDETool
    mOutputArgs{2} = guide2tool;
else
    mOutputArgs{2} = [];
end
if nargout>0
    [varargout{1:nargout}] = mOutputArgs{:};
end

    %------------------------------------------------------------------
    function setCurrentTool(tool)
        mCurrentTool = tool;
    end

    function setColor(color)
        % update the selected color of color palette
        api = 'setColor';
        if isfield(mPaletteAPI, api)                
            mPaletteAPI.(api)(color);
        end
    end

    function color = getColor()
        % get the current selected color of color palette
        color = [];
        api = 'getColor';
        if isfield(mPaletteAPI, api)                
            color = mPaletteAPI.(api)();
        end
    end

    %------------------------------------------------------------------
    function hMainFigureWindowButtonDownFcn(hObject, eventdata)
    % Callback called when mouse is pressed on the figure. Used to change
    % the color of the specific icon data point under the mouse to that of
    % the currently selected color of the colorpalette
        mIsMouseDown = true;

        applylCurrentTool();
    end

    %------------------------------------------------------------------
    function hMainFigureWindowButtonUpFcn(hObject, eventdata)
    % Callback called when mouse is release to exit the icon editing mode
        mIsMouseDown = false;
    end

    %------------------------------------------------------------------
    function hMainFigureWindowButtonMotionFcn(hObject, eventdata)
    % Callback called when mouse is moving so that icon color data can be
    % updated in the editing mode
       applylCurrentTool();
    end

    %------------------------------------------------------------------
    function hMainFigureCloseRequestFcn(hObject, eventdata)
        delete(hObject);

        if isTesting
            mCallerAPI.testing.setChildToolTestingAPI('iconeditor',[]);
        end        
    end

    %------------------------------------------------------------------
    function hIconFileEditCallback(hObject, eventdata)
    % Callback called when user has changed the icon file name from which
    % the icon can be loaded
        file = strtrim(get(hObject,'String'));
        if ~isempty(file)
            if exist(file, 'file') ~= 2
                errordlg(getUserString('ErrorIconFileNoExistMessage',file),getUserString('InvalidIconFileTitle'),'modal');
                set(hObject, 'String', mIconFile);
            else
                mIconCData = [];
                localUpdateIconPlot();            
            end
        end
    end

    %------------------------------------------------------------------
    function hIconFileEditButtondownFcn(hObject, eventdata)
    % Callback called the first time the user pressed mouse on the icon
    % file editbox 
        set(hObject,'String','');
        set(hObject,'Enable','on');
        set(hObject,'ButtonDownFcn',[]);            
        uicontrol(hObject);

        % since this editbox is inactive initially. we receive
        % windowbuttondown nut not windowbuttonup
        mIsMouseDown = false;        
    end

    %------------------------------------------------------------------
    function hOKButtonCallback(hObject, eventdata)
    % Callback called when the OK button is pressed
        uiresume;
        close(hMainFigure);
    end

    %------------------------------------------------------------------
    function hCancelButtonCallback(hObject, eventdata)
    % Callback called when the Cancel button is pressed
        mIconCData =[];
        uiresume;
        close(hMainFigure);
    end

    %------------------------------------------------------------------
    function hHelpButtonCallback(hObject, eventdata)
    % Callback called when the Help button is pressed
        helpview([docroot '/techdoc/creating_guis/creating_guis.map'], 'icon_editor','CSHelpWindow');
    end

    %------------------------------------------------------------------
    function hIconFileButtonCallback(hObject, eventdata)
    % Callback called when the icon file selection button is pressed
        filespec = {'*.mat; *.bmp; *.jpg; *.tif; *.gif; *.png', getString(message('MATLAB:guide:iconeditor:AllImageFilesDescription'));...
                    '*.mat', getString(message('MATLAB:guide:iconeditor:MATFilesDescription'));...
                    '*.bmp', getString(message('MATLAB:guide:iconeditor:BMPFilesDescription')); ...
                    '*.jpg', getString(message('MATLAB:guide:iconeditor:JPEGFilesDescription'));...
                    '*.tif', getString(message('MATLAB:guide:iconeditor:TIFFFilesDescription'));
                    '*.gif', getString(message('MATLAB:guide:iconeditor:GIFFilesDescription'));...
                    '*.png', getString(message('MATLAB:guide:iconeditor:PNGFilesDescription'))};

        [filename, pathname] = uigetfile(filespec, getUserString('PickIconImageFile'), mIconFile);

        if ~isequal(filename,0)
            mIconFile =fullfile(pathname, filename);             
            set(hIconFileEdit, 'ButtonDownFcn',[]);            
            set(hIconFileEdit, 'Enable','on');            
            
            mIconCData = [];
            localUpdateIconPlot();            
            
        elseif isempty(mIconCData)
            set(hPreviewControl,'Visible', 'off');            
        end
    end

    %------------------------------------------------------------------
    function applylCurrentTool
    % helper function that changes the color of an icon data point to
    % that of the currently selected color in colorpalette 
        if ~isempty(mCurrentTool) && strcmpi(mCurrentTool.type, 'tool')
            ht = hittest(hMainFigure); 
            overicon =  isequal(ancestor(ht,'axes'), hIconEditAxes);
            pt = get(hIconEditAxes,'currentpoint');
            if isfield(mCurrentTool, 'action') && ~isempty(mCurrentTool.action)
                mIconCData = mCurrentTool.action(mCurrentTool, mIconCData, pt, overicon, mIsMouseDown);
            end
        end

        localUpdateIconPlot();
    end

    %------------------------------------------------------------------
    function localUpdateIconPlot   
    % helper function that updates the iconeditor when the icon data
    % changes
        %initialize icon CData if it is not initialized
        if isempty(mIconCData)
            if exist(mIconFile, 'file')==2
                try
                    mIconCData = iconread(mIconFile);
                    set(hIconFileEdit, 'String',mIconFile);            
                catch
                    errordlg(getUserString('FailureLoadingData',mIconFile),...
                              getUserString('InvalidIconFileTitle'), 'modal');
                    mIconCData = nan(mIconHeight, mIconWidth, 3);
                end
            else 
                mIconCData = nan(mIconHeight, mIconWidth, 3);
            end
        else
            % this is for passing in the cdata
            iconsize = size(mIconCData);
            if length(iconsize) == 2
                data(:,:,1) = mIconCData;
                data(:,:,2) = mIconCData;
                data(:,:,3) = mIconCData;
                mIconCData = data;
            end
            mIconHeight = size(mIconCData,1);
            mIconWidth = size(mIconCData,2);
        end
        
        % update preview control
        rows = size(mIconCData, 1);
        cols = size(mIconCData, 2);
        oldunits = get(hPreviewPanel,'units');
        set(hPreviewPanel,'Units','pixel');
        previewSize = getpixelposition(hPreviewPanel);
        % compensate for the title
        previewSize(4) = previewSize(4) -15;
        controlWidth = previewSize(3);
        controlHeight = previewSize(4);  
        controlMargin = 6;
        if rows+controlMargin<controlHeight
            controlHeight = rows+controlMargin;
        end
        if cols+controlMargin<controlWidth
            controlWidth = cols+controlMargin;
        end        
        setpixelposition(hPreviewControl,[(previewSize(3)-controlWidth)/2,(previewSize(4)-controlHeight)/2, controlWidth, controlHeight]); 
        set(hPreviewControl,'CData', mIconCData,'Visible','on');
        set(hPreviewPanel,'Units',oldunits);
        
        % update icon edit pane
        set(hIconEditPanel, 'Title',getUserString('IconEditorPaneTitle', num2str(rows), num2str(cols)));
        
        s = findobj(hIconEditPanel,'type','surface');        
        if isempty(s)
            gridColor = get(0, 'defaultuicontrolbackgroundcolor') + 0.1;
            gridColor(gridColor>1)=1;
            s(1)=surface('edgecolor','none','parent',hIconEditAxes, 'Tag','TransparentLayer');
            s(2)=surface('edgecolor',gridColor,'parent',hIconEditAxes, 'Tag','IconLayer');
        end        
        %set xdata, ydata, zdata in case the rows and/or cols change
        canvas = findobj(s,'Tag','IconLayer');
        set(canvas,'xdata',0:cols,'ydata',0:rows,'zdata',zeros(rows+1,cols+1),'cdata',localGetIconCDataWithNaNs());
        transparent = findobj(s,'Tag','TransparentLayer');
        y=ones((2*rows+1)*(2*cols+1),3);
        y(1:2:(2*rows+1)*(2*cols+1), :)= 0.6;
        y(2:2:(2*rows+1)*(2*cols+1), :)= 0.7;
        y=reshape(y, [2*rows+1,2*cols+1,3]);
        set(transparent,'xdata',0:0.5:cols,'ydata',0:0.5:rows,'zdata',zeros(2*rows+1,2*cols+1),'cdata',y);        
     
        set(hIconEditAxes,'xlim',[-.5 cols+.5],'ylim',[-.5 rows+.5]);
        axis(hIconEditAxes, 'ij', 'off');        
    end

    %------------------------------------------------------------------
	function cdwithnan = localGetIconCDataWithNaNs()
		% Add NaN to edge of mIconCData so the entire icon renders in the
		% drawing pane.  This is necessary because of surface behavior.
		cdwithnan = mIconCData;
		cdwithnan(:,end+1,:) = NaN;
		cdwithnan(end+1,:,:) = NaN;
		
	end

    %------------------------------------------------------------------
    function processUserInputs
    % helper function that processes the input property/value pairs 
        % Apply possible figure and recognizable custom property/value pairs
        for index=1:2:length(mInputArgs)
            if length(mInputArgs) < index+1
                break;
            end
            match = find(ismember({mPropertyDefs{:,1}},mInputArgs{index}));
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
            case 'icon'
                if isnumeric(value)
                    isValid = true;
                end
            case {'iconwidth', 'iconheight'}
                if isnumeric(value) && value >0
                    isValid = true;
                end
            case 'iconfile'
                if exist(value,'file')==2
                    isValid = true;                    
                end
            case 'caller'
                if ischar(value)
                    isValid = true;
                end
            case 'callerapi'
                if isstruct(value)
                    isValid = true;
                end
        end
    end

    %------------------------------------------------------------------
    function string = getUserString(key, varargin)
        key = sprintf('%s%s','MATLAB:guide:iconeditor:',key);
        if nargin>1
            string = getString(message(key, varargin{:}));
        else
            string = getString(message(key));
        end
    end

    function guidetool = isGUIDETool
        guidetool = (~isempty(mCaller) && strcmpi(mCaller,'GUIDE'));
    end

    function test = isTesting
        test = (~isempty(mCallerAPI) && isfield(mCallerAPI,'testing') && isfield(mCallerAPI.testing, 'setChildToolTestingAPI'));
    end

    function toolapi = guide2tool
        toolapi = struct(...
            'getTestAPI',   @getTestingAPI);
    end

    function api = getTestingAPI

        api = struct(...
            'dialogButtons', struct(...
            'ok',mActionTable.ok.user(1),...            
            'cancel',mActionTable.cancel.user(1),...            
            'help',mActionTable.help.user(1)));
    end

    %------------------------------------------------------------------
    % action table keeps track the actions this editor supports. The table
    % can be filled up by different players in different places. For
    % example, the button panel can add its supported actions. The table
    % will make enable/disable buttons much easier by changing the 'enable'
    % property of the user field of each action.
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
            'cancel',struct(...
                        'name',getUserString('ActionCancel'),...
                        'icon',[],...
                        'tooltip',getUserString('ActionCancelTooltip'),...
                        'action', '',...
                        'state', '',... 
                        'user',[]));
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
                if isenabled
                    enabled = 'on';
                else
                    enabled = 'off';
                end
                set(mActionTable.(actionid).user, 'Enable', enabled);
            end
        end
    end

%------------------------------------------------------------------
    function createButtonPanel()
        % create the button panel
        pos = [2 0.5 mEditorWidth-2*2 3];
        mActionTable.help.action = @hHelpButtonCallback;
        mActionTable.ok.action = @hOKButtonCallback;
        mActionTable.cancel.action = @hCancelButtonCallback;

        hButtonPanel    =    uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'BorderType','none',...
                    'Clipping','on',...
                    'Position',pos);
        hSectionLine    =   uipanel(...
                    'Parent',hButtonPanel,...
                    'Units','characters',...
                    'HighlightColor',[0 0 0],...
                    'BorderType','line',...
                    'Title','',...
                    'Clipping','on',...
                    'Visible','off',...
                    'Position',[0 3 pos(3) 0.077]);
        addActionUser('ok',...
                    uicontrol(...
                    'Parent',hButtonPanel,...
                    'Busyaction','cancel',...
                    'Units','characters',...
                    'Position',[pos(3)-3*(17.8+2.2) 0.1 17.8 2.38],...
                    'String',mActionTable.ok.name));
        addActionUser('cancel',...
                    uicontrol(...
                    'Parent',hButtonPanel,...
                    'Busyaction','cancel',...
                    'Units','characters',...
                    'Position',[pos(3)-2*(17.8+2.2) 0.1 17.8 2.38],...
                    'String',mActionTable.cancel.name));
        addActionUser('help',...
                    uicontrol(...
                    'Parent',hButtonPanel,...
                    'Busyaction','cancel',...
                    'Units','characters',...
                    'Position',[pos(3)-(17.8+2.2) 0.1 17.8 2.38],...
                    'String',mActionTable.help.name));
    end
end % end of iconeditor

%------------------------------------------------------------------
function prepareLayout(topContainer)
% This is a utility function that takes care of issues related to
% look&feel and running across multiple platforms. You can reuse
% this function in other GUIs or modify it to fit your needs.
    allObjects = findall(topContainer);

    % Use the name of this GUI file as the title of the figure
    if ishghandle(topContainer,'figure')
        set(topContainer,'Name', mfilename, 'NumberTitle','off');
        set(topContainer,'Color', get(0,'defaultuicontrolbackgroundcolor'));
    end

    % Make GUI objects available to callbacks so that they cannot
    % be changes accidentally by other MATLAB commands
    set(allObjects(isprop(allObjects,'HandleVisibility')), 'HandleVisibility', 'Callback');

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
