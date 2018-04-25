function hDialog = dialog(varargin)
%DIALOG Create dialog figure.
%   H = DIALOG(...) returns a handle to a dialog box and is
%   basically a wrapper function for the FIGURE command.  In addition,
%   it sets the figure properties that are recommended for dialog boxes.
%   These properties and their corresponding values are:
%
%   'ButtonDownFcn'     - 'if isempty(allchild(gcbf)), close(gcbf), end'
%   'Colormap'          - []
%   'Color'             - DefaultUicontrolBackgroundColor
%   'DockControls'      - 'off'
%   'HandleVisibility'  - 'callback'
%   'IntegerHandle'     - 'off'
%   'InvertHardcopy'    - 'off'
%   'MenuBar'           - 'none'
%   'NumberTitle'       - 'off'
%   'PaperPositionMode' - 'auto'
%   'Resize'            - 'off'
%   'Visible'           - 'on'
%   'WindowStyle'       - 'modal'
%    
%   Any parameter from the figure command is valid for this command.
%
%   Example:
%       out = dialog;
%
%       out = dialog('WindowStyle', 'normal', 'Name', 'My Dialog');
%
%   See also ERRORDLG, FIGURE, HELPDLG, INPUTDLG, LISTDLG, 
%     MSGBOX, QUESTDLG, UIRESUME, UIWAIT, WARNDLG.

%   Copyright 1984-2014 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Generate a warning in -nodisplay and -noFigureWindows mode.
warnfiguredialog('dialog');

if rem(nargin, 2) == 1
    error (message('MATLAB:dialog:NeedParamPairs'));
end

% -------- set the dialog background color
dlgColor = get(0, 'DefaultUicontrolBackgroundColor');

dlgMenubar   ='none';
btndown      ='if isempty(allchild(gcbf)), close(gcbf), end';
colormap     =[];
dockctrls    ='off';
handlevis    ='callback';
inthandle    ='off';
invhdcpy     ='off';
numtitle     ='off';
ppmode       ='auto';
resize       ='off';
visible      ='on';
winstyle     ='modal';

extrapropval=varargin;

rmloc=[];

for lp=1:2:size(varargin,2)
  switch lower(varargin{lp})
    case 'buttondownfcn'    , btndown   =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'colormap'         , colormap  =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'color'            , dlgColor  =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'dockcontrols'     , dockctrls =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'handlevisibility' , handlevis =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'integerhandle'    , inthandle =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'inverthardcopy'   , invhdcpy  =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'menubar'          , dlgMenubar=varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'numbertitle'      , numtitle  =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'paperpositionmode', ppmode    =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'resize'           , resize    =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'visible'          , visible   =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
    case 'windowstyle'      , winstyle  =varargin{lp+1}; rmloc=[rmloc;lp lp+1];
  end
end

if ~isempty(rmloc)
  extrapropval(rmloc)=[];
end  

% Create the dialog
hDialog = figure('ButtonDownFcn'    ,btndown   , ...
                 'Color'            ,dlgColor  , ...
                 'Colormap'         ,colormap  , ...
                 'IntegerHandle'    ,inthandle , ...
                 'InvertHardcopy'   ,invhdcpy  , ...
                 'HandleVisibility' ,handlevis , ...
                 'MenuBar'          ,dlgMenubar, ...
                 'NumberTitle'      ,numtitle  , ...
                 'PaperPositionMode',ppmode    , ...
                 'WindowStyle'      ,winstyle  , ...
                 'Resize'           ,resize    , ...
                 'Visible'          ,visible   , ...
                 'DockControls'     ,dockctrls , ... % Make sure DockControls is set after WindowStyle, because DockControls cannot be turned off if Windowstyle is set to 'docked'.
                  extrapropval{:}                ...
                 );

