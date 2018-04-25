function varargout = mdw1dpartmngr(varargin)
% MDW1DPARTMNGR MATLAB file for mdw1dpartmngr.fig
%   VARARGOUT = MDW1DPARTMNGR(VARARGIN)

% Last Modified by GUIDE v2.5 15-Mar-2012 15:00:57

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Oct-2005.
%   Last Revision 29-Apr-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mdw1dpartmngr_OpeningFcn, ...
                   'gui_OutputFcn',  @mdw1dpartmngr_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
%--------------------------------------------------------------------------
% --- Executes just before mdw1dpartmngr is made visible.
function mdw1dpartmngr_OpeningFcn(hObject,eventdata,handles,varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.

% Choose default command line output for mdw1dpartmngr
handles.output = 0;

% Update handles structure
guidata(hObject,handles);

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos = get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=getMonitorSize;
    set(0,'Units',ScreenUnits);
    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4) = [FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Show a question icon from dialogicons.mat 
% variables questIconData and questIconMap
load dialogicons.mat
IconData = questIconData;
questIconMap(256,:) = get(handles.Fig_Part_MNGR, 'Color');
IconCMap = questIconMap;
Img = image(IconData,'Parent',handles.Axe_Icon);
set(handles.Fig_Part_MNGR,'Colormap',IconCMap);

set(handles.Axe_Icon, ...
    'Visible', 'off', 'YDir'   , 'reverse'  , ...
    'XLim'   , get(Img,'XData'), 'YLim'   , get(Img,'YData')  ...
    );

% Make the GUI modal
set(handles.Fig_Part_MNGR,'WindowStyle','modal')

% Initialization with tool OPTION.
optionMNGR = lower(varargin{1});
fig = varargin{2};
callingFIG = blockdatamngr('get',fig,'fig_Storage','callingFIG');

ena_Act_2  = 'On';
vis_Rad    = 'Off';
vis_Act_2  = 'Off';
switch optionMNGR
    case 'clear'
        str_ACTION = getWavMSG('Wavelet:mdw1dRF:Clear_Partition');
        num_ACTION = 1;
        
    case 'import'
        str_ACTION = getWavMSG('Wavelet:mdw1dRF:Str_Import');
        num_ACTION = 2;
        vis_Act_2  = 'On';
        idxPART_Import = varargin{3};
        if isempty(idxPART_Import) || isequal(idxPART_Import,0)
            ena_Act_2 = 'Off';
        end
        
    case 'save'
        str_ACTION = getWavMSG('Wavelet:commongui:Str_Save');
        num_ACTION = 3;
        vis_Rad    = 'On';
        
    case 'savecur'
        str_ACTION = getWavMSG('Wavelet:mdw1dRF:Save_Curr');
        num_ACTION = 4;
        vis_Rad    = 'On';
        
    case 'exportcur'
        str_ACTION = getWavMSG('Wavelet:mdw1dRF:Export_Curr');
        num_ACTION = 5;
        vis_Rad    = 'On';
        
end
set(handles.Pus_Action,'String',str_ACTION,'UserData',num_ACTION);
set(handles.Pus_Cancel,'UserData',0);
set(handles.Pus_Act_2,...
    'Visible',vis_Act_2,'Enable',ena_Act_2,'UserData',-1)
set([handles.Rad_ALL_PART,handles.Rad_IDX_PART],'Visible',vis_Rad)
SET_of_Partitions = wtbxappdata('get',callingFIG,'SET_of_Partitions');
if isempty(SET_of_Partitions)
    names = [];
else
    names = getpartnames(SET_of_Partitions);
end
idxLST = 1;
if isequal(optionMNGR,'clear')
    idxCUR = find(strcmp(getWavMSG('Wavelet:moreMSGRF:Curr_Part'),names));
    if ~isempty(idxCUR) , names(idxCUR) = []; end
elseif isequal(optionMNGR,'savecur')
    current_PART = wtbxappdata('get',gcbf,'current_PART');
    namePART = get(current_PART,'Name');
    names = {namePART};
end
set(handles.Lst_Part,'String',names,'Value',idxLST,'UserData',callingFIG);
if isequal(optionMNGR,'savecur') || isequal(optionMNGR,'exportcur')
    set(handles.Lst_Part,'Enable','Off');
    set(handles.Txt_Select_Part, ...
        'String',getWavMSG('Wavelet:mdw1dRF:Current_Part'))
elseif isequal(optionMNGR,'import')
    set(handles.Lst_Part,'Max',1);
end
wtranslate(mfilename,hObject);

% UIWAIT makes mdw1dpartmngr wait for user response (see UIRESUME)
uiwait(handles.Fig_Part_MNGR);
%--------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = mdw1dpartmngr_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);

varargout{1} = handles.output;
numPART =  0;
switch varargout{1}
    case 0       % Cancel
    case -1      % Clear Import 
        numPART = -1;
                
    case {1,2}   % Clear Partition or Import
        numPART = get(handles.Lst_Part,'Value');
        if isempty(numPART) , numPART = 0; end        

    case {3,4}  % Save or Save Curr.
        currFLAG = ~isequal(varargout{1},3);
        if ~currFLAG
            numPART = get(handles.Lst_Part,'Value');
            if isempty(numPART)
                uiwait(msgbox(getWavMSG('Wavelet:mdw1dRF:No_Part_Sel'),...
                    'Message','modal'));
                numPART = 0;
            end
        else
            numPART = Inf;
        end
        
        if numPART>0
            callingFIG = get(handles.Lst_Part,'UserData');
            mask = {...
                '*.mat;*.par;*.clu','Partitions ( *.mat , *.par , *.clu)';
                '*.*','All Files (*.*)'};            
            [filename,pathname,ok] = ...
                utguidiv('test_save',handles.Fig_Part_MNGR, ...
                mask,getWavMSG('Wavelet:mdw1dRF:Pus_PART_SAVE'));
        else
            ok = false;
        end
        
        if ok
            [name,ext] = strtok(filename,'.');
            if isempty(ext) || isequal(ext,'.')
                ext = '.mat'; filename = [name ext];
            end
            fullPART = isequal(get(handles.Rad_ALL_PART,'Value'),1);
            if ~currFLAG
                SET_of_Partitions = ...
                    wtbxappdata('get',callingFIG,'SET_of_Partitions');
                SET_of_Partitions = SET_of_Partitions(numPART);
            else
                SET_of_Partitions = wtbxappdata('get',gcbf,'current_PART');
            end
            if fullPART
                varName = 'SET_of_Partitions';
            else
                tab_IdxCLU = [];
                for k=1:length(SET_of_Partitions)
                    tab_IdxCLU = [tab_IdxCLU,get(SET_of_Partitions(k),'IdxCLU')]; %#ok<AGROW>
                end
                varName = 'tab_IdxCLU';
            end
            try
                save([pathname filename],varName);
            catch ME    %#ok<NASGU>
                errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
            end
        end
    case 5 % Export to the workspace
end
varargout{1} = numPART;

% The figure can be deleted now
delete(handles.Fig_Part_MNGR);
%--------------------------------------------------------------------------
function Pus_OPTION_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

handles.output = get(hObject,'UserData');

% Update handles structure
guidata(hObject,handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.Fig_Part_MNGR);
%--------------------------------------------------------------------------
function Rad_PART_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

if isequal(hObject,handles.Rad_ALL_PART)
    set(handles.Rad_ALL_PART,'Value',1)
    set(handles.Rad_IDX_PART,'Value',0)
else
    set(handles.Rad_ALL_PART,'Value',0)
    set(handles.Rad_IDX_PART,'Value',1)
end
%--------------------------------------------------------------------------
function Fig_Part_MNGR_CloseRequestFcn(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

if isequal(get(handles.Fig_Part_MNGR,'waitstatus'),'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.Fig_Part_MNGR);
else
    % The GUI is no longer waiting, just close it
    delete(handles.Fig_Part_MNGR);
end
%--------------------------------------------------------------------------
function Fig_Part_MNGR_KeyPressFcn(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 0;
    
    % Update handles structure
    guidata(hObject,handles);
    uiresume(handles.Fig_Part_MNGR);
end        
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.Fig_Part_MNGR);
end    
%--------------------------------------------------------------------------
