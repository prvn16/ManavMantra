function varargout = wfbmtool(varargin)
%WFBMTOOL Fractional Brownian motion generation tool.
%   VARARGOUT = WFBMTOOL(VARARGIN)

% WFBMTOOL MATLAB file for wfbmtool.fig
%      WFBMTOOL, by itself, creates a new WFBMTOOL or raises the existing
%      singleton*.
%
%      H = WFBMTOOL returns the handle to a new WFBMTOOL or the handle to
%      the existing singleton*.
%
%      WFBMTOOL('Property','Value',...) creates a new WFBMTOOL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to wfbmtool_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      WFBMTOOL('CALLBACK') and WFBMTOOL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in WFBMTOOL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 13-Apr-2006 18:55:26
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Last Revision: 02-Aug-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $  $Date: 2013/08/23 23:45:20 $ 


%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wfbmtool_OpeningFcn, ...
                   'gui_OutputFcn',  @wfbmtool_OutputFcn, ...
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
% --- Executes just before wfbmtool is made visible.                      %
%*************************************************************************%
function wfbmtool_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for wfbmtool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wfbmtool wait for user response (see UIRESUME)
% uiwait(handles.wfbmtool_Win);

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
function varargout = wfbmtool_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
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
%--------------------------------------------------------------------------
function Edi_Length_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

FieldDefault ='1000';
Val_Length = str2double(get(hObject,'String'));
if ~isequal(Val_Length,fix(Val_Length)) || ...
    Val_Length < 100 || isnan(Val_Length)
    set(hObject,'String',FieldDefault);
end
%--------------------------------------------------------------------------
function Sli_Fractal_Index_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

Val_Index = get(hObject,'Value');
set(handles.Edi_Fractal_Index,'String',Val_Index);
%--------------------------------------------------------------------------
function Edi_Fractal_Index_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

FieldDefault ='0.6';
Val_Index = str2double(get(hObject,'String'));
if Val_Index < 0 || Val_Index > 1 || isnan(Val_Index)
    set(hObject,'String',FieldDefault);
    set(handles.Sli_Fractal_Index,'Value',str2double(FieldDefault));
else
    set(handles.Sli_Fractal_Index,'Value',Val_Index);
end
%--------------------------------------------------------------------------
function Rad_Random_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

set(hObject,'Value',1);
set(handles.Rad_Value,'Value',0);
set(handles.Edi_Value,'Enable','off');
%--------------------------------------------------------------------------
function Rad_Value_Callback(hObject,eventdata,handles) %#ok<INUSL>

set(hObject,'Value',1);
set(handles.Rad_Random,'Value',0);
set(handles.Edi_Value,'Enable','on');
%--------------------------------------------------------------------------
function Edi_Value_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

FieldDefault ='1';
Val_Value = str2double(get(hObject,'String'));
if ~isequal(Val_Value,fix(Val_Value)) || Val_Value < 0 || isnan(Val_Value)
    set(hObject,'String',FieldDefault);
end
%--------------------------------------------------------------------------
function Pus_Generate_Callback(hObject,eventdata,handles) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
cleanTOOL(handles);

% Computing.
%-----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));

% Get all the parameter settings.
%--------------------------------
% Wavelet used
Wav = cbanapar('get',hFig,'wav');                           
% Signal length (string)
Val_Length_Str = get(handles.Edi_Length,'String');                     
% Signal length (numeric)
Val_Length_Num = str2double(Val_Length_Str);                           
% Fractal index (string)
H = get(handles.Edi_Fractal_Index,'String');              
% Fractal index (numeric)
Val_Index = str2double(H);                                        
% Matrix of Refinement values
Val_Refinement = str2double(get(handles.Pop_Refinement,'String'));     
% Current Refinement value
Val_Refinement = Val_Refinement(get(handles.Pop_Refinement,'Value'));  
% Check if a value is used for seed
if get(handles.Rad_Value,'Value')                                       
    % Seed a new generator with this value and save the old default
    randNUM = str2double(get(handles.Edi_Value,'String'));  
    stream = RandStream('shr3cong','seed',randNUM);
else
    stream = RandStream.getGlobalStream;
end

FBM_PARAMS.SEED = struct('Type',{stream.Type},'State',{stream.State});

% Compute Fractional Brownian Motion signal.
%-------------------------------------------
savedDfltStream = RandStream.setGlobalStream(stream);
FBM = wfbm(Val_Index,Val_Length_Num,Val_Refinement,Wav);
RandStream.setGlobalStream(savedDfltStream);

% Synthesized Fractional Brownian Motion axes display.
%-----------------------------------------------------
TFBM = 0:length(FBM)-1;
ext  = abs(max(FBM) - min(FBM)) / 100;
Ylim = [min(FBM)-ext max(FBM)+ext];
Xlim = [TFBM(1) TFBM(end)];
Lin_FBM(1) = line(TFBM,FBM,'Color','r','Visible','Off',...
    'Parent',handles.Axe_FBM);
set(handles.Axe_FBM,'XLim',Xlim,'YLim',Ylim);
FBM_title = getWavMSG('Wavelet:divGUIRF:FBM_Synt_Par',num2str(H),Wav);
wguiutils('setAxesTitle',handles.Axe_FBM,FBM_title,'On');

% First order increments axes display.
%-------------------------------------
FBM1Dif = diff(FBM);
Lin_FBM(2) = line(0:length(FBM1Dif)-1,FBM1Dif,'Color','g', ...
    'Visible','Off','Parent',handles.Axe_1Dif);
ext = abs(max(FBM1Dif) - min(FBM1Dif)) / 100;
Ylim = [min(FBM1Dif)-ext max(FBM1Dif)+ext];
set(handles.Axe_1Dif,'XLim',Xlim,'YLim',Ylim);
set(get(handles.Axe_1Dif,'Title'),'Visible','On');

% Set the axes visible.
%----------------------
set([handles.Axe_FBM,handles.Axe_1Dif,Lin_FBM],'Visible','on');

% Enable the Statistics Push_Button.
%-----------------------------------
set(handles.Pus_Statistics,'Enable','on');

% get Menu Handles.
%------------------
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');

% Enable the Save synthesized signal Menu item.
%----------------------------------------------
set([hdl_Menus.m_save,hdl_Menus.m_exp_sig],'Enable','on');

% Update Generated FBM Parameters.
%---------------------------------
FBM_PARAMS.FBM          = FBM;
FBM_PARAMS.Wav          = Wav;
FBM_PARAMS.Length       = Val_Length_Num;
FBM_PARAMS.H            = Val_Index;
FBM_PARAMS.Refinement   = Val_Refinement;
wtbxappdata('set',hFig,'FBM_PARAMS',FBM_PARAMS);

% Init DynVTool.
%---------------
axe_IND = [];
axe_CMD = [...
        handles.Axe_FBM , ...
        handles.Axe_1Dif ...
    ];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pus_Statistics_Callback(hObject,eventdata,handles) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% get Tool Parameters.
%---------------------
FBM_PARAMS = wtbxappdata('get',hFig,'FBM_PARAMS');

% Call the wfbmstat figure and pass the FBM_PARAMS structure.
%------------------------------------------------------------
wfbmstat('WfbmtoolCall_Callback',hFig,[],handles,FBM_PARAMS);
%--------------------------------------------------------------------------
function Pus_CloseWin_Callback(hObject,eventdata,handles) %#ok<DEFNU>

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
if isequal(lower(ena_Save),'on')
    hFig = get(hObject,'Parent');
    status = wwaitans({hFig,getWavMSG('Wavelet:divGUIRF:FBM_Name')},...
        getWavMSG('Wavelet:commongui:SaveSS'),2,'Cancel');
    switch status
        case -1 , return;
        case  1
            Men_SavSynthSig_Callback(m_save, eventdata, handles)
        otherwise
    end
end
close(gcbf)
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%
function Men_SavSynthSig_Callback(hObject,eventdata,handles) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Begin waiting.
%---------------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitSave'));

% Update Tool Parameters.
%------------------------
FBM_PARAMS = wtbxappdata('get',hFig,'FBM_PARAMS');

% Testing file.
%--------------
[filename,pathname,ok] = utguidiv('test_save',hFig, ...
    '*.mat',getWavMSG('Wavelet:commongui:SaveSS'));
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
    try
        eval([name ' = FBM_PARAMS.FBM;']);
    catch %#ok<*CTCH>
        x = FBM_PARAMS.FBM; %#ok<NASGU>
        name = 'x';
    end
    FBM_PARAMS = rmfield(FBM_PARAMS,'FBM'); %#ok<NASGU>
    save([pathname filename],name,'FBM_PARAMS','-mat');
catch          
    errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
end

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Export_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

hFig = handles.output;
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitExport'));
FBM_PARAMS = wtbxappdata('get',hFig,'FBM_PARAMS');
fBM_sig = FBM_PARAMS.FBM;
wtbxexport(fBM_sig,'name','fBM_sig',...
    'title',getWavMSG('Wavelet:divGUIRF:FBM_Signal'));
wwaiting('off',hFig);
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

% WTBX -- Install ANAPAR FRAME.
%------------------------------
wnameDEF = 'db10';
utanapar('Install_V3_CB',hObject,'wtype','owt');
cbanapar('set',hObject,'wav',wnameDEF);

% Set colors and fontes for the figure.
%---------------------------------------
wfigmngr('set_FigATTRB',hObject,mfilename);

% Set Title in the FBM axes (first time).
%----------------------------------------
title = getWavMSG('Wavelet:divGUIRF:FBM_Synt');
wguiutils('setAxesTitle',handles.Axe_FBM,title,hObject,'Off');

% Set Title in the 1Dif axes (first time).
%-----------------------------------------
title = getWavMSG('Wavelet:divGUIRF:First_OrdInc');
wguiutils('setAxesTitle',handles.Axe_1Dif,title,hObject,'Off');

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

hAXES = [handles.Axe_FBM, handles.Axe_1Dif];
hLINES = findobj(hAXES,'Type','line');
set(hAXES,'Visible','off');
delete(hLINES);
set(handles.Pus_Statistics,'Enable','off');
%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function hdl_Menus = Install_MENUS(hFig)

% Add UIMENUS.
%-------------
m_files  = wfigmngr('getmenus',hFig,'file');
m_close  = wfigmngr('getmenus',hFig,'close');
cb_close = [mfilename '(''Pus_CloseWin_Callback'',gcbo,[],guidata(gcbo));'];
set(m_close,'Callback',cb_close);
m_demo   = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Lab_Example'),    ...
    'Position',1, ...
    'Enable','On', ...
    'Tag','Examples'   ...
    );
uimenu(m_demo, ...
    'Label',getWavMSG('Wavelet:divGUIRF:FBM_Ex1'),    ...
    'Position',1,        ...
    'Enable','On',       ...
    'Callback',          ...
    [mfilename '(''Men_Example_Callback'',gcbo,[],guidata(gcbo));']  ...    
    );
uimenu(m_demo, ...
    'Label',getWavMSG('Wavelet:divGUIRF:FBM_Ex2'),    ...
    'Position',2,          ...
    'Enable','On',       ...
    'Callback',          ...
    [mfilename '(''Men_Example_Callback'',gcbo,[],guidata(gcbo));']  ...    
    );
uimenu(m_demo, ...
    'Label',getWavMSG('Wavelet:divGUIRF:FBM_Ex3'),    ...
    'Position',3,          ...
    'Enable','On',       ...
    'Callback',          ...
    [mfilename '(''Men_Example_Callback'',gcbo,[],guidata(gcbo));']  ...    
    );

m_save   = uimenu(m_files,                  ...
    'Label',getWavMSG('Wavelet:commongui:SaveSS'),     ...
    'Position',2,                           ...
    'Enable','Off',                         ...
    'Separator', 'On',                      ...
    'Callback',                             ...
    [mfilename '(''Men_SavSynthSig_Callback'',gcbo,[],guidata(gcbo));']  ...
    );
m_exp_sig = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Lab_Export'),'Position',3, ...
    'Enable','Off','Separator','Off','Tag','Export',...
    'Callback',[mfilename '(''Export_Callback'',gcbo,[],guidata(gcbo));']...
    );

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig,getWavMSG('Wavelet:divGUIRF:FBM_HLP'),'WFBM_GUI');

% Menu handles.
%----------------
hdl_Menus = struct('m_files',m_files,'m_save',m_save, ...
    'm_close',m_close,'m_exp_sig',m_exp_sig);
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
function demoPROC(hFig,eventdata,handles,varargin) %#ok<INUSL,DEFNU>

% Initialization for next plot
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tool_PARAMS.demoMODE = 'on';
wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS );
set(hFig,'HandleVisibility','On')

handles  = guidata(hFig);
paramDEM = varargin{1};
hFbmVal = paramDEM{1,1};
typeDEM = paramDEM{1,2};
hdl_WinFbmStat = wtbxappdata('get',hFig,'hdl_WinFbmStat');
if ishandle(hdl_WinFbmStat) , delete(hdl_WinFbmStat); end
switch typeDEM
    case 'generate'
        Pus_Generate = handles.Pus_Generate;
        Edi_Fractal_Index = handles.Edi_Fractal_Index;
        Sli_Fractal_Index = handles.Sli_Fractal_Index;
        set(Sli_Fractal_Index,'Value',hFbmVal);
        set(Edi_Fractal_Index,'String',num2str(hFbmVal));
        Pus_Generate_Callback(Pus_Generate,eventdata,handles);

    case 'statistics'
        Pus_Statistics = handles.Pus_Statistics;
        OldFig = allchild(0);
        Pus_Statistics_Callback(Pus_Statistics,eventdata,handles);
        NewFig = allchild(0);
        hdl_WinFbmStat = setdiff(NewFig,OldFig);
        wfigmngr('modify_FigChild',hFig,hdl_WinFbmStat);
        wtbxappdata('set',hFig,'hdl_WinFbmStat',hdl_WinFbmStat);
end
set(hFig,'HandleVisibility','Callback')
%----------------------------------------------------------
function Men_Example_Callback(hObject,eventdata,handles,varargin) %#ok<DEFNU>

numEX = get(hObject,'Position');
switch numEX
    case 1 , hFbmVal = 0.2;
    case 2 , hFbmVal = 0.5;
    case 3 , hFbmVal = 0.9;
end
hdl_WinFbmStat = wtbxappdata('get',hObject,'hdl_WinFbmStat');
if ishandle(hdl_WinFbmStat) , delete(hdl_WinFbmStat); end

% Create a random number stream using the specified seed, save the old default
% stream, and make the new stream the default
Rad_Value = handles.Rad_Value;
Edi_Value = handles.Edi_Value;
Rad_Value_Callback(Rad_Value,eventdata,handles);
randNUM = numEX;
set(Edi_Value,'String',int2str(randNUM));
stream = RandStream('shr3cong','seed',randNUM);
savedDfltStream = RandStream.setGlobalStream(stream);


% Generate FBM.
Pus_Generate = handles.Pus_Generate;
Edi_Fractal_Index = handles.Edi_Fractal_Index;
Sli_Fractal_Index = handles.Sli_Fractal_Index;
set(Sli_Fractal_Index,'Value',hFbmVal);
set(Edi_Fractal_Index,'String',num2str(hFbmVal));
Pus_Generate_Callback(Pus_Generate,eventdata,handles);

% Restore the default stream
RandStream.setGlobalStream(savedDfltStream)


%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%
