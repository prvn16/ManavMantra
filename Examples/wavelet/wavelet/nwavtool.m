function varargout = nwavtool(varargin)
%NWAVTOOL New wavelet for continuous analysis tool.
%   VARARGOUT = NWAVTOOL(VARARGIN)

% NWAVTOOL MATLAB file for nwavtool.fig
%      NWAVTOOL, by itself, creates a new NWAVTOOL or raises the existing
%      singleton*.
%
%      H = NWAVTOOL returns the handle to a new NWAVTOOL or the handle to
%      the existing singleton*.
%
%      NWAVTOOL('Property','Value',...) creates a new NWAVTOOL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to nwavtool_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      NWAVTOOL('CALLBACK') and NWAVTOOL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in NWAVTOOL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 13-Apr-2006 18:24:09
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $ $Date: 2013/07/05 04:30:22 $ 


%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nwavtool_OpeningFcn, ...
                   'gui_OutputFcn',  @nwavtool_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%*************************************************************************%
%                END initialization code - DO NOT EDIT                    %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Opening Function                                   %
%                ----------------------                                   %
% --- Executes just before nwavtool is made visible.                      %
%*************************************************************************%
function nwavtool_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for nwavtool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manualy in the automatic generated code  %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles);
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = nwavtool_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;
%*************************************************************************%
%                END Output Function                                      %
%*************************************************************************%


%=========================================================================%
%                BEGIN Callback Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function Pop_ApproxMeth_Callback(hObject,eventdata,handles) %#ok<INUSL>

hPolDefFra  = ...
    [handles.Fra_PolDegree handles.Pop_PolDegree handles.Txt_PolDegree];
[~,ApproxMethVal] = getApproxMeth(hObject);
switch ApproxMethVal
    case 1  % 'Polynomial' 
        set(hPolDefFra,'Visible','on');
        BoundCondStr = { ...
            getWavMSG('Wavelet:commongui:Str_None'); ...
            getWavMSG('Wavelet:divGUIRF:Str_Continuous'); ...
            getWavMSG('Wavelet:divGUIRF:Str_Differentiable')};
    case 2, % 'OrthConst'
        set(hPolDefFra,'Visible','off');
        BoundCondStr = {...
            getWavMSG('Wavelet:commongui:Str_None'); ...
            getWavMSG('Wavelet:divGUIRF:Str_Continuous')};
end
set(handles.Pop_BoundCond,'String',BoundCondStr);
set(handles.Pop_BoundCond,'Value',2);
Pop_PolDegree = get(handles.Pop_PolDegree,'Value');
set(handles.Pop_PolDegree,'Value',max([3,Pop_PolDegree]));
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
hRunSig     = tool_PARAMS.hRunSig;
set(hRunSig,'Enable','Off');
%--------------------------------------------------------------------------
function Edi_LowBound_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
LowInter = tool_PARAMS.LowInter;
LowBound = str2double(get(hObject,'String'));
if LowBound > LowInter || isnan(LowBound)
    set(hObject,'String',sprintf('%0.4g',LowInter));
end
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
hRunSig     = tool_PARAMS.hRunSig;
set(hRunSig,'Enable','Off');
%--------------------------------------------------------------------------
function Edi_UppBound_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
UppInter = tool_PARAMS.UppInter;
UppBound = str2double(get(hObject,'String'));
if UppBound < UppInter  || isnan(UppBound)
    set(hObject,'String',sprintf('%0.4g',UppInter));
end 
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
hRunSig     = tool_PARAMS.hRunSig;
set(hRunSig,'Enable','Off');
%--------------------------------------------------------------------------
function Pop_PolDegree_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

[~,ApproxMethVal] = getApproxMeth(handles.Pop_ApproxMeth);
switch ApproxMethVal
    case 1  % 'Polynomial'
        Regularity = getRegularity(handles.Pop_BoundCond);
        PolDegree  = get(hObject,'Value');
        NBConstraint = 1 + 2*(Regularity + 1);
        freeDegree = PolDegree - NBConstraint;
        if freeDegree<0
            Regularity = floor((PolDegree-3)/2);
        end
        set(handles.Pop_BoundCond,'Value',Regularity+2);
        
    case 2  % 'OrthConst',
end
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
hRunSig     = tool_PARAMS.hRunSig;
set(hRunSig,'Enable','Off');
%--------------------------------------------------------------------------
function Pop_BoundCond_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>
[~,ApproxMethVal] = getApproxMeth(handles.Pop_ApproxMeth);
switch ApproxMethVal
    case 1  % 'Polynomial'
        Regularity = getRegularity(hObject);        
        NBConstraint = 1 + 2*(Regularity + 1);
        % PolDegree  = get(handles.Pop_PolDegree,'Value');
        % freeDegree = PolDegree - NBConstraint;
        % if freeDegree<0
        %     Regularity = floor((PolDegree-3)/2);
        % end
        set(handles.Pop_PolDegree,'Value',NBConstraint);
    case 2  % 'OrthConst',
end
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
hRunSig     = tool_PARAMS.hRunSig;
set(hRunSig,'Enable','Off');
%--------------------------------------------------------------------------
function Rad_Trans_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

set(hObject,'Value',1);
set(handles.Rad_Super,'Value',0);
%--------------------------------------------------------------------------
function Rad_Super_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

set(hObject,'Value',1);
set(handles.Rad_Trans,'Value',0);
%--------------------------------------------------------------------------
function Pus_Approximate_Callback(hObject,eventdata,handles) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Cleaning.
%-----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
cleanTOOL([handles.Axe_PatWav handles.Axe_RunSig handles.Axe_Detect]);
ColorBarVisibility(handles.Axe_ColBar,'Off');

% Computing.
%-----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));

% Get parameter values.
%----------------------
tool_PARAMS     = wtbxappdata('get',hObject,'tool_PARAMS');
X               = tool_PARAMS.X;
Y               = tool_PARAMS.Y;
hRunSig         = tool_PARAMS.hRunSig;
[ApproxMeth,ApproxMethVal] = getApproxMeth(handles.Pop_ApproxMeth);
LowBound        = str2double(get(handles.Edi_LowBound,'String'));
UppBound        = str2double(get(handles.Edi_UppBound,'String'));
PolDegreeStr    = get(handles.Pop_PolDegree,'String');
PolDegreeVal    = get(handles.Pop_PolDegree,'Value');
PolDegree       = str2double(PolDegreeStr{PolDegreeVal});
BoundCondVal    = get(handles.Pop_BoundCond,'Value');
switch ApproxMethVal
    case 1  % 'Polynomial'
        switch BoundCondVal
            case 2 , Regularity =  0;  % 'Continuous' ,     
            case 3 , Regularity =  1;  % 'Differentiable'
            otherwise ,             Regularity = -1;
        end
    case 2  % 'OrthConst'
        switch BoundCondVal
            case 1 ,    Regularity = -1; PolDegree = 0;  % 'none'
            case 2 ,    Regularity =  0; PolDegree = 2;  % 'Continuous'
            otherwise , Regularity = -1; PolDegree = 0;
        end
end

% Compute approximation.
%-----------------------
[PSI,X_PSI,NC_PSI] = pat2cwav(Y,ApproxMeth,PolDegree,Regularity);
PSI_pat = NC_PSI*PSI;     % Approximation of the original pattern.
deltaX   = 0.05;
XVAL_PSI = [LowBound-deltaX,LowBound,min(X_PSI)-eps, ...
            NaN,X_PSI,NaN,max(X_PSI)+eps,UppBound,UppBound+deltaX];
XVAL_FUN = [LowBound-deltaX,LowBound,NaN,X,NaN,UppBound,UppBound+deltaX];
YVAL_PSI = [0,0,0,NaN,PSI_pat,NaN,0,0,0];
YVAL_FUN = [NaN,NaN,NaN,Y,NaN,NaN,NaN];

% Store PSI.
%-----------
tool_PARAMS        = wtbxappdata('get',hObject,'tool_PARAMS');
tool_PARAMS.PSI    = PSI;
tool_PARAMS.NC_PSI = NC_PSI;
wtbxappdata('set',hObject,'tool_PARAMS',tool_PARAMS);

% Pattern and wavelet axes display.
%----------------------------------
lw = 2;
axeCur = handles.Axe_PatWav;
line(XVAL_FUN,YVAL_FUN,'Color','r','LineWidth',lw,'Parent',axeCur);
line(XVAL_PSI,YVAL_PSI,'Color','g','LineWidth',lw,'Parent',axeCur);
Xlim = [LowBound-deltaX UppBound+deltaX];
Ymin = min(min(PSI_pat),min(Y));
Ymax = max(max(PSI_pat),max(Y));
ext = abs(Ymax - Ymin) / 100;
Ylim = [Ymin-ext Ymax+ext];
set(axeCur,'XLim',Xlim,'YLim',Ylim);

% Init DynVTool.
%---------------
axe_IND = [...
    handles.Axe_Pattern ,   ...
    handles.Axe_PatWav      ...
    ];
axe_CMD = [...
    handles.Axe_RunSig ,    ...
    handles.Axe_Detect      ...
    ];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% Set the axes visible.
%----------------------
set(handles.Axe_PatWav,'Visible','on');

% Set visible and enabled uicontrols.
%------------------------------------
set(hRunSig,'Visible','on','Enable','On');

% get Menu Handles.
%------------------
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');

% Enable the Save synthesized signal Menu item.
%----------------------------------------------
set([hdl_Menus.m_save,hdl_Menus.m_exp_wrks],'Enable','on');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pus_Run_Callback(hObject,eventdata,handles) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Cleaning.
%-----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
cleanTOOL([handles.Axe_RunSig handles.Axe_Detect]);

% Computing.
%-----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));

% Get parameter values.
%----------------------
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
Y           = tool_PARAMS.Y;
PSI         = tool_PARAMS.PSI;
RadTrans    = get(handles.Rad_Trans,'Value');
ChkNoise    = get(handles.Chk_Noise,'Value');
ChkTriangle = get(handles.Chk_Triangle,'Value');

% Running signal construction.
%-----------------------------
titleSTR{1} = getWavMSG('Wavelet:divGUIRF:Running_Signal');
if RadTrans
    nbFormeBASE = 8; scaleBASE = 8; rapport = 2; PONDERATIONS =  [1,1];
    signalBASE = getSignal('translate',Y,rapport,PONDERATIONS,nbFormeBASE);
    lenSIG  = length(signalBASE);
    scaleMIN = 1;
    scaleMAX = 2*scaleBASE;
    NoiseLevel = 1.25;
    titleSTR{2} = 'F((t-20)/8) + sqrt(2)\timesF((t-40)/4)';
else
    nbFormeBASE = 3; scaleBASE = 32; rapport = 4; PONDERATIONS =  [1,1];
    signalBASE = getSignal('superpose',Y,rapport,PONDERATIONS,nbFormeBASE);
    lenSIG  = length(signalBASE);
    scaleMIN = 1;
    scaleMAX = 2*scaleBASE;
    NoiseLevel = 0.75;
    titleSTR{2} = 'F((t-40)/32) + 2\timesF((t-40)/8)';
end
signal = signalBASE;

if ChkNoise
    NoiseLevel = NoiseLevel*std(signal);
    Noise = NoiseLevel*randn(1,lenSIG);
    signal = signal + Noise;
    titleSTR{2} = [titleSTR{2} ' + N'];
end
if ChkTriangle
    L = lenSIG/2;
    Triangle = [1:floor(L) , ceil(L):-1:1]/ceil(L);
    signal = signal + Triangle;
    titleSTR{2} = [titleSTR{2} ' + T'];
end
intervalleSIG = [0,nbFormeBASE*scaleBASE];
stepSIG = (intervalleSIG(2)-intervalleSIG(1))/(lenSIG-1);
xvalSIG = linspace(intervalleSIG(1),intervalleSIG(2),lenSIG);
stepScales = 1;
scales  = (scaleMIN:stepScales:scaleMAX);

% Running signal axes display.
%-----------------------------
lw = 1;
axeCur = handles.Axe_RunSig;
lin_SIG =  line(xvalSIG,signal,'Color','b',...
   'LineWidth',lw,'Visible','Off','Parent',axeCur);
Xlim = intervalleSIG;
ext = abs(max(signal) - min(signal)) / 100;
Ylim = [min(signal)-ext max(signal)+ext];
set(axeCur,'XLim',Xlim,'YLim',Ylim);

% Set the hdl visible.
%---------------------
set([axeCur,lin_SIG],'Visible','on');
wguiutils('setAxesTitle',axeCur,titleSTR);

% Compute the cwt.
%-----------------
C_psi = wavelet.internal.cwt({signal,stepSIG},scales,PSI);

% Plot contours and local grid lines.
%------------------------------------
plotCONTOUR(C_psi,scales,xvalSIG,handles.Axe_Detect,handles.Axe_ColBar);
LocalGrid(handles.Axe_Detect,RadTrans)

% Set the axes visible.
%----------------------
set(handles.Axe_Detect,'Visible','on');

% Set Colorbar visible.
%----------------------
ColorBarVisibility(handles.Axe_ColBar,'On');

% Init DynVTool.
%---------------
axe_IND = [...
        handles.Axe_Pattern , ...
        handles.Axe_PatWav ...
        ];
axe_CMD = [...
        handles.Axe_RunSig , ...
        handles.Axe_Detect ...
        ];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pus_Compare_Callback(hObject,eventdata,handles) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% get Tool Parameters.
%---------------------
Nwavetool_PARAMS             = wtbxappdata('get',hFig,'tool_PARAMS');
Nwavetool_PARAMS.RadTrans    = get(handles.Rad_Trans,'Value');
Nwavetool_PARAMS.RadSuper    = get(handles.Rad_Super,'Value');
Nwavetool_PARAMS.ChkNoise    = get(handles.Chk_Noise,'Value');
Nwavetool_PARAMS.ChkTriangle = get(handles.Chk_Triangle,'Value');
Nwavetool_PARAMS.Pus_Compare = handles.Pus_Compare;

% Call the compwav figure and pass the tool_PARAMS structure.
%------------------------------------------------------------
compwav('NwavtoolCall_Callback',hFig,[],handles,Nwavetool_PARAMS);
%--------------------------------------------------------------------------
function Pus_CloseWin_Callback(hObject, eventdata, handles)

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
hFig = get(hObject,'Parent');
if isequal(lower(ena_Save),'on')
    status = wwaitans({hFig,getWavMSG('Wavelet:divGUIRF:Sav_AdapWav')},...
        getWavMSG('Wavelet:divGUIRF:Sav_AdapWavQuest'),2,'Cancel');
    switch status
        case -1 , return;
        case  1
            Men_SaveWave_Callback(m_save, eventdata, handles)
        otherwise
    end
end
delete(handles.Axe_ColBar); % BUG AXES
close(hFig) 
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%
function Men_LoadPat_Callback(hObject,eventdata,handles, ...
                pathname,filename,flagWRKS) %#ok<INUSD,INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing file.
%--------------
if nargin<4
    [sigInfos,~,ok] = ...
        utguidiv('load_sig',hFig,'*.mat', ...
        getWavMSG('Wavelet:divGUIRF:Load_Pattern'));
    if ~ok, return; end
    pathname = sigInfos.pathname;
    filename = sigInfos.filename;
    loadSIG = true;
    
elseif nargin<6
    ok = 1;
    try
        load(filename); 
    catch ME  %#ok<NASGU>
        ok = 0; 
    end
    if ~ok, return; end
    loadSIG = true;
    
else
    [sigInfos,Y,ok] = wtbximport('1d');
    if ~ok, return; end
    name = sigInfos.name;
    loadSIG = false;
end

% Cleaning.
%-----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
set([hdl_Menus.m_save,hdl_Menus.m_exp_wrks],'Enable','Off');
cleanTOOL([ handles.Axe_Pattern handles.Axe_PatWav ...
            handles.Axe_RunSig handles.Axe_Detect]);
ColorBarVisibility(handles.Axe_ColBar,'Off');

% Reinitialization of the GUI default values.
%--------------------------------------------
hPolDefFra  = [handles.Fra_PolDegree handles.Pop_PolDegree handles.Txt_PolDegree];
set(hPolDefFra,'Visible','on');
BoundCondStr = { ...
    getWavMSG('Wavelet:commongui:Str_None'); ...
    getWavMSG('Wavelet:divGUIRF:Str_Continuous'); ...
    getWavMSG('Wavelet:divGUIRF:Str_Differentiable')};
set(handles.Pop_BoundCond,'String',BoundCondStr);
set(handles.Pop_BoundCond,'Value',2);
set(handles.Pop_ApproxMeth,'Value',1);
set(handles.Pop_PolDegree,'Value',3);
set(handles.Rad_Super,'Value',0);
set(handles.Rad_Trans,'Value',1);
set(handles.Chk_Noise,'Value',0);
set(handles.Chk_Triangle,'Value',0);

% Loading file.
%--------------
if loadSIG
    [name,ext] = strtok(filename,'.');
    if isempty(ext) || isequal(ext,'.')
        ext = '.mat'; filename = [name ext];
    end
    try
        fullName = [pathname filename];
        TMP = load(fullName);
        DUM = fieldnames(TMP);
        idxY = find(strcmp(DUM,'Y'));
        if ~isempty(idxY)
            Y = TMP.(DUM{idxY});
        else
            Y = TMP.(DUM{1});
        end
        clear TMP DUM idxY
    catch ME  %#ok<NASGU>
        errargt(mfilename,getWavMSG('Wavelet:commongui:LoadERROR'),'msg');
        wwaiting('off',hFig);
        return;
    end
end

% Get variable values.
%---------------------
X = linspace(0,1,length(Y));
if size(X)~=size(Y) , Y = Y'; end
LowInter = X(1);
UppInter = X(end);
Interval = sprintf('[%0.4g , %0.4g]',LowInter,UppInter);

% Store variable values.
%-----------------------
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
tool_PARAMS.LowInter = LowInter;
tool_PARAMS.UppInter = UppInter;
tool_PARAMS.X = X;
tool_PARAMS.Y = Y;
wtbxappdata('set',hObject,'tool_PARAMS',tool_PARAMS);

% Update uicontrols on the command part.
%---------------------------------------
set(handles.Edi_Pattern,'String',name);
set(handles.Edi_Interval,'String',Interval);
set(handles.Edi_LowBound,'String',sprintf('%0.4g',LowInter));
set(handles.Edi_UppBound,'String',sprintf('%0.4g',UppInter));
set(handles.Pus_Approximate,'Enable','on');

% Axe_Pattern axes display.
%--------------------------
lw = 1;
axeCur = handles.Axe_Pattern;
lin_PAT = line(X,Y,'Color','r','LineWidth',lw,...
    'Visible','Off','Parent',axeCur);
ext     = abs(max(Y) - min(Y)) / 100;
Ylim    = [min(Y)-ext max(Y)+ext];
Xlim    = [min(X) max(X)];
set(axeCur,'XLim',Xlim,'YLim',Ylim);

% Set Title in the pattern axes.
%-------------------------------
IntegVAL = 0.5*sum((Y(1:end-1)+Y(2:end)).*diff(X));
titleSTR{1} = getWavMSG('Wavelet:divGUIRF:Pattern_F');
titleSTR{2} = getWavMSG('Wavelet:divGUIRF:Integral_Val',num2str(IntegVAL,4));
% Set the axes visible.
%----------------------
set([handles.Axe_Pattern,lin_PAT],'Visible','on');
wguiutils('setAxesTitle',handles.Axe_Pattern,titleSTR);

% Set unvisible the running signal block of uicontrols.
%----------------------------------------------------
set(tool_PARAMS.hRunSig,'Enable','Off');

% Init DynVTool.
%---------------
axe_IND = [handles.Axe_Pattern , handles.Axe_PatWav];
axe_CMD = [handles.Axe_RunSig ,  handles.Axe_Detect];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Men_SaveWave_Callback(hObject,eventdata,handles) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Begin waiting.
%---------------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitSave'));

% Get PSI values.
%----------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
Y = tool_PARAMS.PSI;
LowInter = tool_PARAMS.LowInter;
UppInter = tool_PARAMS.UppInter;
X = linspace(LowInter,UppInter,length(Y)); %#ok<NASGU>

% Testing file.
%--------------
[filename,pathname,ok] = utguidiv('test_save',hFig, ...
    '*.mat',getWavMSG('Wavelet:divGUIRF:Sav_AdapWav'));
if ~ok,
    wwaiting('off',hFig);   % End waiting.
    return; 
end

% Saving file.
%-------------
[name,ext] = strtok(filename,'.');
if isempty(ext) || isequal(ext,'.')
    ext = '.mat'; filename = [name ext];
end

try
    save([pathname filename],'X','Y','-mat');
catch ME  %#ok<NASGU>
    errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
end

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function demo_FUN(hObject,eventdata,handles,numDEM) %#ok<INUSL>

% Default Demo Parameters.
%-------------------------
LowInter = 0; UppInter =  1;
TransVAL =  1; NoiseVAL =  0; TrianVAL = 0;
switch numDEM
    case 1 , 
        filename = 'ptpssin1';
        methode  = 'Polynomial'; PolDegree  = 3; Regularity = -1;
    case 2 , 
        filename = 'ptpssin1';
        methode  = 'Polynomial'; PolDegree  = 3; Regularity =  0;
    case 3 ,
        filename = 'ptpssin1';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = -1;
        TransVAL = 0;
    case 4 ,
        filename = 'ptpssin1';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
        TransVAL = 0;
    case 5 , 
        filename = 'ptpssin2';
        methode  = 'Polynomial'; PolDegree  = 3; Regularity = 0;
    case 6 , 
        filename = 'ptpssin2';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 7 , 
        filename = 'ptsine';
        methode  = 'Polynomial'; PolDegree  = 3; Regularity = 0;
        NoiseVAL =  1; TrianVAL = 1;        
    case 8 , 
        filename = 'ptsine';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
        NoiseVAL =  1; TrianVAL = 1;
    case 9 , 
        filename = 'ptsumsin';
        methode  = 'Polynomial'; PolDegree  = 3; Regularity = 0;
    case 10 , 
        filename = 'ptsumsin';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 11 , 
        filename = 'ptsinpol';
        methode  = 'Polynomial'; PolDegree  = 6; Regularity = 0;
        NoiseVAL = 1;
    case 12 , 
        filename = 'ptsinpol';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
        NoiseVAL = 1;
    case 13 , 
        filename = 'ptodtri';
        methode  = 'Polynomial'; PolDegree  = 5; Regularity = 0;
    case 14 , 
        filename = 'ptodtri';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 15 , 
        filename = 'pthaar';
        methode  = 'Polynomial'; PolDegree  = 5; Regularity = 0;
    case 16 , 
        filename = 'pthaar';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 17 , 
        filename = 'pthaar';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = -1;
    case 18 , 
        filename = 'ptodlin';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 19 , 
        filename = 'ptodpoly';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
        TransVAL = 0;
    case 20 , 
        filename = 'ptbumps';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 21 , 
        filename = 'ptbumps';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
        TransVAL = 0;
end

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing and loading file.
%--------------------------
filename = [filename '.mat'];
pathname = utguidiv('WTB_DemoPath',filename);
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
m_load = hdl_Menus.m_load;
Men_LoadPat_Callback(m_load,eventdata,handles,pathname,filename);

% Setting Method, PolDegree, Regularity.
%---------------------------------------
popHDL = handles.Pop_ApproxMeth;
switch methode
    case 'Polynomial' , popVAL = 1;
    case 'OrthConst'  , popVAL = 2;
end
set(popHDL,'Value',popVAL);
Pop_ApproxMeth_Callback(popHDL, eventdata, handles);
popHDL = handles.Pop_PolDegree;
set(popHDL,'Value',PolDegree);
popHDL = handles.Pop_BoundCond;
popVAL = Regularity + 2;
set(popHDL,'Value',popVAL);
set(handles.Edi_LowBound,'String',sprintf('%0.4g',LowInter));
set(handles.Edi_UppBound,'String',sprintf('%0.4g',UppInter));

% Setting Run Parameters.
%------------------------
set(handles.Rad_Trans,'Value',TransVAL);
set(handles.Rad_Super,'Value',1-TransVAL);
set(handles.Chk_Noise,'Value',NoiseVAL);
set(handles.Chk_Triangle,'Value',TrianVAL);

% Approximation and Run.
%-----------------------
Pus_Approximate_Callback(handles.Pus_Approximate, eventdata, handles)
Pus_Run_Callback(handles.Pus_Run, eventdata, handles)
%--------------------------------------------------------------------------
function Export_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

hFig = handles.output;
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitExport'));
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
Y = tool_PARAMS.PSI;
LowInter = tool_PARAMS.LowInter;
UppInter = tool_PARAMS.UppInter;
X = linspace(LowInter,UppInter,length(Y));
nwav_1D = struct('X',X,'Y',Y);
wtbxexport(nwav_1D,'name','nwav_1D','title', ...
    getWavMSG('Wavelet:divGUIRF:Str_AdapWav'));
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function close_FUN(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

Pus_CloseWin = handles.Pus_CloseWin;
Pus_CloseWin_Callback(Pus_CloseWin,eventdata,handles);
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles) %#ok<INUSL>

% WTBX -- Install DynVTool.
%--------------------------
dynvtool('Install_V3',hObject,handles);

% WTBX -- Initialize GUIDE Figure.
%---------------------------------
wfigmngr('beg_GUIDE_FIG',hObject);

% WTBX MENUS (Install)
%---------------------
hdl_Menus = Install_MENUS(hObject);
wtbxappdata('set',hObject,'hdl_Menus',hdl_Menus);

% Set Title in the pattern axes.
%-------------------------------
titleSTR = getWavMSG('Wavelet:divGUIRF:Ori_Pattern');
wguiutils('setAxesTitle',handles.Axe_Pattern,titleSTR,hObject);

% Set Title in the pattern and adapted wavelet axes.
%---------------------------------------------------
titleSTR = getWavMSG('Wavelet:divGUIRF:Pat_and_AdapWav');
wguiutils('setAxesTitle',handles.Axe_PatWav,titleSTR,hObject);

% Set Title in the running signal axes.
%--------------------------------------
titleSTR = 'F((x-20) / 8 + (x-48) / 4) + T + N';
wguiutils('setAxesTitle',handles.Axe_RunSig,titleSTR,hObject);

% Set Title in the pattern detection axes.
%-----------------------------------------
titleSTR = getWavMSG('Wavelet:divGUIRF:Pat_Detect');
wguiutils('setAxesTitle',handles.Axe_Detect,titleSTR,hObject);

% Initialize colorbar.
%---------------------
cmap = get(hObject,'Colormap');
axeCur = handles.Axe_ColBar;
image((1:size(cmap,1)),'Parent',axeCur)
set(axeCur,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
set(hObject,'Visible','Off')
dynvzaxe('exclude',hObject,axeCur)
ColorBarVisibility(axeCur,'Off');

% Save Tool Parameters.
%----------------------
hRunSig  =   [ ...
    handles.Fra_RunSignal, handles.Txt_RunSignal,   ...
    handles.Txt_TwoPatterns, handles.Txt_With,      ...
    handles.Rad_Trans, handles.Rad_Super,           ...
    handles.Chk_Noise, handles.Chk_Triangle,        ...
    handles.Pus_Run, handles.Pus_Compare            ...
    ];
tool_PARAMS.hRunSig = hRunSig;
wtbxappdata('set',hObject,'tool_PARAMS',tool_PARAMS);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',hObject,mfilename);

%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%
function cleanTOOL(handles)

hLINES  = findobj(handles,'Type','line');
hPATCH  = findobj(handles,'Type','patch');
hIMAGES  = findobj(handles,'Type','image');
delete(double([hLINES;hPATCH;hIMAGES]));

hg = wfindobj(handles);
ty = get(hg,'type');
idx = strcmp(ty,'contour');
delete(hg(idx))

set(handles,'Visible','off');
%--------------------------------------------------------------------------
function ColorBarVisibility(Axe_ColBar,status)

hIMAGES = wfindobj(Axe_ColBar,'Type','image');
set(Axe_ColBar,'Visible',status);
set(hIMAGES,'Visible',status);
%-------------------------------------------------------------------------
%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function [ApproxMeth,ApproxMethVal] = getApproxMeth(Pop_ApproxMeth)

ApproxMethVal = get(Pop_ApproxMeth,'Value');
switch ApproxMethVal
    case 1 , ApproxMeth = 'Polynomial';
    case 2 , ApproxMeth = 'OrthConst';
end
%-------------------------------------------------------------------------
function Regularity = getRegularity(Pop_BoundCond)

Regularity = get(Pop_BoundCond,'Value')-2;
%-------------------------------------------------------------------------
function hdl_Menus = Install_MENUS(hFig)

% Add UIMENUS.
%-------------
m_files = wfigmngr('getmenus',hFig,'file');
m_close = wfigmngr('getmenus',hFig,'close');
cb_close = [mfilename '(''close_FUN'',gcbo,[],guidata(gcbo));'];
set(m_close,'Callback',cb_close);

m_load  = uimenu(m_files,                   ...
    'Label',getWavMSG('Wavelet:divGUIRF:Load_Pattern'),  ...
    'Position',1,                           ...
    'Enable','On',                          ...
    'Callback',                             ...
    [mfilename '(''Men_LoadPat_Callback'',gcbo,[],guidata(gcbo));']  ...
    );

m_save  = uimenu(m_files,                   ...
    'Label',getWavMSG('Wavelet:divGUIRF:Sav_AdapWav'),        ...
    'Position',2,                           ...
    'Enable','Off',                         ...
    'Callback',                             ...
    [mfilename '(''Men_SaveWave_Callback'',gcbo,[],guidata(gcbo));']  ...
    );

m_demo = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Lab_Example'), ...
    'Tag','Examples', ...
    'Position',3,'Separator','Off');

uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:divGUIRF:Import_Pattern'), ...
    'Position',4,'Enable','On', ...
    'Separator','On',...
    'Tag','Import', ...
    'Callback',  ...    
    [mfilename '(''Men_LoadPat_Callback'',gcbo,[],guidata(gcbo),[],[],[]'');'] ...
    );
m_exp_wrks = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:divGUIRF:Export_AdapWav'),'Position',5, ...
    'Enable','Off','Separator','Off',...
    'Tag','Export', ...
    'Callback',[mfilename '(''Export_Callback'',gcbo,[],guidata(gcbo));'] ...
    );

demoSET = {...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_NCPol',1,3); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_CPol',1,3);  ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_NC_Ortho',1);  ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_C_Ortho',1); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_CPol',2,3);  ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_C_Ortho',2); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_CPol',3,3);  ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_C_Ortho',3); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_CPol',4,3);  ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_C_Ortho',4); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_CPol',5,6);  ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_C_Ortho',5); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_CPol',6,5);  ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_C_Ortho',6); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_CPol',7,5);  ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_C_Ortho',7); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_NC_Ortho',8); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_NC_Ortho',9); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_NC_Ortho',10); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_NC_Ortho',11); ...
    getWavMSG('Wavelet:divGUIRF:Example_Pat_NC_Ortho',12)  ...
};
nbDEM = size(demoSET,1);
sepSET = [5,9,13];
for k = 1:nbDEM
    strNUM = int2str(k);
    action = [mfilename '(''demo_FUN'',gcbo,[],guidata(gcbo),' strNUM ');'];
    if find(k==sepSET) , Sep = 'On'; else Sep = 'Off'; end
    uimenu(m_demo,'Label',[demoSET{k,1}],'Separator',Sep,'Callback',action);
end

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig, ...
    getWavMSG('Wavelet:divGUIRF:WM_Pus_NWAV'),'NWAV_GUI');

% Add Help Item.
%----------------
% wfighelp('addHelpItem',hFig,'Continuous Transform','CW_TRANSFORM');

% Menu handles.
%----------------
hdl_Menus = struct('m_files',m_files,'m_load',m_load,...
    'm_save',m_save,'m_exp_wrks',m_exp_wrks);
%-------------------------------------------------------------------------
function signalBASE = ...
    getSignal(typeSIG,FormeBASE,rapport,PONDERATIONS,nbFormeBASE)

Forme_1 = FormeBASE;
len_F1  = length(Forme_1);
x_new   = linspace(0,1,len_F1/rapport);
x_old   = linspace(0,1,len_F1);        
Forme_2 = (rapport^0.5)*interp1(x_old,Forme_1,x_new);
len_F2  = length(Forme_2);
Forme_1 = PONDERATIONS(1)*Forme_1;
Forme_2 = PONDERATIONS(2)*Forme_2;
signalBASE = zeros(1,nbFormeBASE*len_F1);
switch typeSIG
	case 'superpose'
        deb = floor(((nbFormeBASE-1)/2-1/4)*len_F1) + 1; fin = deb + len_F1-1;
        signalBASE(deb:fin) = Forme_1;
        deb = deb + floor((len_F1-len_F2)/2); fin = deb + len_F2-1;
        signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_2;

	case 'translate'
        deb = 2*len_F1; fin = deb + len_F1-1;
        signalBASE(deb:fin) = Forme_1;
        deb = floor(5*len_F1-len_F2/2); fin = deb + len_F2-1;        
        signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_2;
end
%-------------------------------------------------------------------------
function plotCONTOUR(C,scales,xvalSIG,Axe_Detect,Axe_ColBar)

% Compute and plot contours.
%---------------------------
maxi = max(max(abs(C))); 
D = abs(C)/maxi;
xval = (0.7:0.025:1); 
contour(xvalSIG,scales,D,xval,'Parent',Axe_Detect);

% Set Title in the pattern detection axes.
%-----------------------------------------
titleSTR = getWavMSG('Wavelet:divGUIRF:Pat_Detect');
wguiutils('setAxesTitle',Axe_Detect,titleSTR);
setAxesATTRB(scales,Axe_Detect);

% Set Contour Values.
%--------------------
nbTICS = 7;
xlim = get(Axe_ColBar,'XLim');
alfa = (xlim(2)-xlim(1))/(xval(end)-xval(1));
beta = xlim(1)-alfa*xval(1);
xCOL  = linspace(xval(1),xval(end),nbTICS);
xtics = alfa*xCOL + beta;
xlabs = num2str(xCOL(:),2);
set(Axe_ColBar, ...
        'XTick',xtics, ...
        'XTickLabel',xlabs ...
        );
%-------------------------------------------------------------------------
function setAxesATTRB(scales,axe)

nb_SCALES = length(scales);
nb    = ceil(nb_SCALES/20);
ytics = nb:nb:nb_SCALES;
tmp   = scales(nb:nb:nb*length(ytics));
ylabs = num2str(tmp(:));
set(axe, ...
        'YTick',ytics, ...
        'YTickLabel',ylabs, ...
        'YDir','normal', ...
        'Box','On' ...
        );
%-------------------------------------------------------------------------
function LocalGrid(Axe_Detect,RadTrans)

if RadTrans
    line([20 20],[0 8],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([0 20],[8 8],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([40 40],[0 4],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([0 40],[4 4],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line(20,8,'Color','k','Marker','*','Parent',Axe_Detect);
    line(40,4,'Color','k','Marker','*','Parent',Axe_Detect);
else
    line([40 40],[0 32],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([0 40],[32 32],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([40 40],[0 8],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([0 40],[8 8],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line(40,32,'Color','k','Marker','*','Parent',Axe_Detect);
    line(40,8,'Color','k','Marker','*','Parent',Axe_Detect);
end
%-------------------------------------------------------------------------
%*************************************************************************
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%



%=========================================================================%
%                      BEGIN Demo Utilities                               %
%                      ---------------------                              %
%=========================================================================%
function closeDEMO(hFig,eventdata,handles,varargin) %#ok<INUSD,DEFNU>

close(hFig);
%----------------------------------------------------------
function demoPROC(hFig,eventdata,handles,varargin) %#ok<DEFNU,INUSL>

% Initialization for next plot
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tool_PARAMS.demoMODE = 'on';
wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS );
set(hFig,'HandleVisibility','On')

handles  = guidata(hFig);
paramDEM = varargin{1};
typeDEM  = paramDEM{1,1};
hdl_WinCompWav = wtbxappdata('get',hFig,'hdl_WinCompWav');
switch typeDEM
    case 'run'
        numDEM = paramDEM{1,2};
        if ishandle(hdl_WinCompWav) , delete(hdl_WinCompWav); end
        demo_FUN(hFig,eventdata,handles,numDEM);

    case 'compare'
        if ishandle(hdl_WinCompWav) , delete(hdl_WinCompWav); end
        Pus_Compare = handles.Pus_Compare;
        OldFig = allchild(0);
        Pus_Compare_Callback(Pus_Compare,eventdata,handles);
        NewFig = allchild(0);
        hdl_WinCompWav = setdiff(NewFig,OldFig);
        wfigmngr('modify_FigChild',hFig,hdl_WinCompWav);
        wtbxappdata('set',hFig,'hdl_WinCompWav',hdl_WinCompWav);
        
    case 'compare_2'
        waveDEM = paramDEM{1,3};
        compwav('demoPROC',hdl_WinCompWav,[],[],waveDEM);
end
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%
