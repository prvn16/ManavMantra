function varargout = mdw1ddeno(varargin)
%MDW1DDENO Discrete wavelet Multisignal 1D Analysis Tool.
%   VARARGOUT = MDW1DDENO(VARARGIN)

% Last Modified by GUIDE v2.5 30-Aug-2006 18:04:31
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2005.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2013/07/05 04:31:06 $

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mdw1ddeno_OpeningFcn, ...
                   'gui_OutputFcn',  @mdw1ddeno_OutputFcn, ...
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
%*************************************************************************%
%                END initialization code - DO NOT EDIT                    %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Opening Function                                   %
%                ----------------------                                   %
% --- Executes just before mdw1ddeno is made visible.                      %
%*************************************************************************%
function mdw1ddeno_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mdw1ddeno (see VARARGIN)

% Choose default command line output for mdw1ddeno
handles.output = hObject;

% Update handles structure
guidata(hObject,handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manualy in the automatic generated code  %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles,varargin{:});
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = mdw1ddeno_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Manual CALLBACKS: Begin %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Pus_ENA_MAN_Callback(hObject,eventdata,handles) %#ok<DEFNU>

fig = handles.Current_Fig;
flag_MAN = get(hObject,'UserData');
if isempty(flag_MAN) , flag_MAN = true; else flag_MAN = ~flag_MAN; end

to_HIDE = [handles.Pan_LST_DATA, ...
    handles.Pus_Compute_ALL,handles.Pus_Compute_RESET];
to_ENA = [...
    handles.Pus_Denoise, ...
    handles.Txt_APP_KEEP,handles.Rad_YES,handles.Rad_NO, ...
    handles.Txt_THR_TYPE,handles.Rad_SOFT,handles.Rad_HARD, ...    
    handles.Pus_CloseWin ...
    ];
if flag_MAN 
    tool_STATE = 'DEN_MAN';
    blockdatamngr('set',fig,'tool_ATTR','State',tool_STATE);
    wtbxappdata('set',fig,'flag_modify_THR',false);
    data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
    level    = wgfields(data_ORI,'level');
    set(handles.Edi_MAN_THR,'UserData',NaN(1,level));
    idxSIG_SEL = wtbxappdata('get',fig,'idxSIG_SEL');
    if isempty(idxSIG_SEL)
        idxSIG_SEL = 1;
        wtbxappdata('set',fig,'idxSIG_SEL',idxSIG_SEL);
    end
    threshold = blockdatamngr('get',fig,'data_DorC','threshold');
    wtbxappdata('set',fig,'SAVED_threshold',threshold);    
    thrTMP = threshold(idxSIG_SEL,:);
    set(handles.Pop_MAN_SIG,'UserData',thrTMP);
    strPOP = num2cell(int2str(idxSIG_SEL(:)),2);
    strPOP = [getWavMSG('Wavelet:commongui:Str_All');strPOP];
    nbSTR = length(strPOP);
    if nbSTR>1 , valPOP = 2; else valPOP = 1; end
    set(handles.Pop_MAN_SIG,'String',strPOP,'Value',valPOP);
    set(handles.Edi_Selected_DATA,'Enable','On')
    set(to_ENA,'Enable','Off')
    set(to_HIDE,'Visible','Off')
    mdw1dafflst('DEN',[],eventdata,handles,'init');
    %-------------------------------------------------------------------
    strPUS = getWavMSG('Wavelet:mdw1dRF:Disable_MAN_THR');
    set(hObject,'String',strPUS,'UserData',flag_MAN);
    blockdatamngr('set',fig,'tool_ATTR','State',tool_STATE);
    %-------------------------------------------------------------------
    mdw1dmngr('setDispMode',handles.Pop_Show_Mode,eventdata,handles,...
          'DEN','MAN','lvlThr');
    mdw1dmisc('show',handles,'MAN_THR','INI')
    set(handles.Pan_MAN_THR,'Visible','On');
else
    modify_THR = wtbxappdata('get',fig,'flag_modify_THR');
    if modify_THR
        msg = getWavMSG('Wavelet:mdw1dRF:Keep_THR_VAL');
        Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
        Str_No  = getWavMSG('Wavelet:commongui:Str_No');  ...
        Str_Cancel = getWavMSG('Wavelet:commongui:Str_Cancel');        
        BtnName = questdlg(msg,getWavMSG('Wavelet:mdw1dRF:Modif_THR_VAL'), ...
            Str_Yes,Str_No,Str_Cancel,Str_Yes);
        switch BtnName
            case Str_Cancel , return;
            case Str_Yes
            case Str_No
                threshold = wtbxappdata('get',fig,'SAVED_threshold');
                blockdatamngr('set',fig,'data_DorC',...
                    'threshold',threshold);
                mdw1dafflst('DEN',[],[],handles,'init')
        end
        wtbxappdata('set',fig,'flag_modify_THR',false);
    end
    tool_STATE = 'DEN_ON';
    blockdatamngr('set',fig,'tool_ATTR','State',tool_STATE);
    set(handles.Pan_MAN_THR,'Visible','Off');
    set(handles.Edi_MAN_THR,'String','');
    set(handles.Edi_Selected_DATA,'Enable','Inactive')
    set(to_ENA,'Enable','On')
    set(to_HIDE,'Visible','On')
    %-------------------------------------------------------------------
    strPUS = getWavMSG('Wavelet:mdw1dRF:Enable_MAN_THR');
    set(hObject,'String',strPUS,'UserData',flag_MAN);
    blockdatamngr('set',fig,'tool_ATTR','State',tool_STATE);
    %-------------------------------------------------------------------    
    mdw1dmngr('setDispMode',handles.Pop_Show_Mode,eventdata,handles,...
          'DEN','MAN','lvlThr_END');    
end
%--------------------------------------------------------------------------
function ENA_MAN_Func(handles)

Pus_MAN = handles.Pus_ENA_MAN;
flag_MAN = get(Pus_MAN,'UserData');
if isempty(flag_MAN) || ~flag_MAN , return; end

fig = handles.Current_Fig;
to_HIDE = [handles.Pan_LST_DATA, ...
    handles.Pus_Compute_ALL,handles.Pus_Compute_RESET];
to_ENA = [...
    handles.Pus_Denoise,handles.Txt_THR_TYPE,...
    handles.Rad_SOFT,handles.Rad_HARD,handles.Pus_CloseWin ...
    ];
tool_STATE = 'DEN_MAN';
strPUS = getWavMSG('Wavelet:mdw1dRF:Disable_MAN_THR');
data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
level    = wgfields(data_ORI,'level');
set(handles.Edi_MAN_THR,'UserData',NaN(1,level));
idxSIG_SEL = wtbxappdata('get',fig,'idxSIG_SEL');
if isempty(idxSIG_SEL)
    idxSIG_SEL = 1;
    wtbxappdata('set',fig,'idxSIG_SEL',idxSIG_SEL);
end
threshold = blockdatamngr('get',fig,'data_DorC','threshold');
thrTMP = threshold(idxSIG_SEL,:);
set(handles.Pop_MAN_SIG,'UserData',thrTMP);
strPOP = num2cell(int2str(idxSIG_SEL(:)),2);
strPOP = [getWavMSG('Wavelet:commongui:Str_All');strPOP];
nbSTR = length(strPOP);
if nbSTR>1 , valPOP = 2; else valPOP = 1; end
set(handles.Pop_MAN_SIG,'String',strPOP,'Value',valPOP);
mdw1dmisc('show',handles,'MAN_THR','INI')
set(handles.Edi_Selected_DATA,'Enable','On')
set(Pus_MAN,'String',strPUS);
set(to_ENA,'Enable','Off')
set(to_HIDE,'Visible','Off')
blockdatamngr('set',fig,'tool_ATTR','State',tool_STATE);
mdw1dshow('Show_DEC_Fun',fig,[],handles,'DEN')
set(handles.Pan_MAN_THR,'Visible','On');
%--------------------------------------------------------------------------
function Pop_MAN_SIG_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

%--------------------------------------------------------------------------
function Edi_MAN_THR_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

val_THR = str2double(get(hObject,'String'));
if isnan(val_THR) , set(hObject,'String',''); return; end
fig = handles.Current_Fig;
wtbxappdata('set',fig,'flag_modify_THR',true);
mdw1dmisc('show',handles,'MAN_THR','EDI',val_THR)
%--------------------------------------------------------------------------
function Pop_MAN_LEV_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

%--------------------------------------------------------------------------
function Pus_MAN_Valid_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

fig = handles.output;
flagMODIFIED = wtbxappdata('get',fig,'flag_modify_THR');
if ~flagMODIFIED , return; end

msg = getWavMSG('Wavelet:mdw1dRF:Update_THR_VAL');
Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
Str_Cancel = getWavMSG('Wavelet:commongui:Str_Cancel');
BtnName = questdlg(msg, ...
    getWavMSG('Wavelet:mdw1dRF:Modif_THR_VAL'),Str_Yes,Str_Cancel,Str_Yes);
switch BtnName
    case Str_Cancel, return;
    case Str_Yes
end
threshold = blockdatamngr('get',fig,'data_DorC','threshold');
wtbxappdata('set',fig,'SAVED_threshold',threshold);
wtbxappdata('set',fig,'flag_modify_THR',false);
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Manual CALLBACKS: END   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function Pus_Compute_THR_Callback(hObject,eventdata,handles,varargin) %#ok<DEFNU>

% Get figure handle.
%-------------------
fig = handles.output;

% Get Parameters.
%----------------
type_COMP = varargin{1};
if ~isequal(type_COMP,'RESET')
    
    % Computing.
    %----------
    wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitCompute'));

    % Get Wavelet Decomposition.
    %---------------------------
    data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
    dec_ORI  = data_ORI.dwtDEC;

    % Get Denoising Parameters.
    %--------------------------
    val_typeTHR = get(handles.Pop_THR_METH,'Value');
    switch val_typeTHR
        case 1 , typeTHR = 'sqtwolog';
        case 2 , typeTHR = 'minimaxi';
        case 3 , typeTHR = 'rigrsure';
        case 4 , typeTHR = 'heursure';
        case 6 , typeTHR = 'penalhi';
        case 7 , typeTHR = 'penalme';
        case 8 , typeTHR = 'penallo';
        case 9 , typeTHR = 'penal';    
    end
    switch val_typeTHR
        case {1,2,3,4}
            val_typeNOI = get(handles.Pop_NOI_Struct,'Value');
            switch val_typeNOI
                case 1 , parMETH = 'one';
                case 2 , parMETH = 'sln';
                case 3 , parMETH = 'mln';
            end
        case {6,7,8,9}
            numMETH = val_typeTHR-5;
            usr = get(handles.Sli_Penal,'UserData');
            parMETH = usr(numMETH,2);
    end
end

% Computing and Storing
%----------------------
switch type_COMP
    case 'ALL'
        threshold = mswden('thr',dec_ORI,typeTHR,parMETH);
        change_THR = true;
        
    case 'SEL'
        idxSIG = wtbxappdata('get',fig,'idxSIG_SEL');
        thrSIG = mswden('thr',dec_ORI,typeTHR,parMETH,idxSIG);
        threshold = blockdatamngr('get',fig,'data_DorC','threshold');
        threshold(idxSIG,:) = thrSIG;        
        flag_MAN = get(handles.Pus_ENA_MAN,'UserData');
        if isequal(flag_MAN,true)
            wtbxappdata('set',fig,'flag_modify_THR',true);
        end
        change_THR = true;
        
    case 'RESET'
        threshold = ...
            blockdatamngr('get',fig,'data_DorC','threshold');
        reset_FLAG = any(threshold(:));
        change_THR = false;
        if reset_FLAG
            msg = getWavMSG('Wavelet:mdw1dRF:Quest_ResetThrValue');
            Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
            Str_No  = getWavMSG('Wavelet:commongui:Str_No');  ...
            Str_Cancel = getWavMSG('Wavelet:commongui:Str_Cancel');
            BtnName = questdlg(msg, ...
                getWavMSG('Wavelet:mdw1dRF:Quest_ResetThrValue'), ...
                Str_Yes,Str_No,Str_Cancel,Str_Yes);
            switch BtnName
                case Str_Yes , threshold(:) = 0; change_THR = true;
                case Str_No
                case Str_Cancel , return;
            end
        end
end
if change_THR
    blockdatamngr('set',fig,'data_DorC','threshold',threshold);
end

% Show Thresholds.
%-----------------
blockdatamngr('set',fig,'tool_ATTR','State','DEN_ON');
mdw1dafflst('DEN',hObject,eventdata,handles,'init','KeepSelected')
if isequal(type_COMP,'SEL') , ENA_MAN_Func(handles); end

% End waiting.
%-------------
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Pus_Denoise_Callback(hObject,eventdata,handles) %#ok<DEFNU>

% Get figure handle.
%-------------------
fig = handles.output;

% Get Selected Data Type.
%------------------------
[dwtType,sigType] = mdw1dutils('get_Sig_IDENT',fig,'lst');
ori_sig_FLAG = all(dwtType=='S') & all(sigType=='o');
if ~ori_sig_FLAG
    msg = getWavMSG('Wavelet:mdw1dRF:Quest_DenoSig');
    Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
    Str_No  = getWavMSG('Wavelet:commongui:Str_No');  ...
    BtnName = questdlg(msg,getWavMSG('Wavelet:mdw1dRF:Denoising_signals'), ...
        Str_Yes,Str_No,Str_Yes);
    switch BtnName
        case Str_Yes
        case Str_No , return;
    end
end

% Cleaning.
%----------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitClean'));

% Get Wavelet Decomposition.
%---------------------------
data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');

% Get Denoising Parameters.
%--------------------------
val_S_or_H = get(handles.Rad_SOFT,'Value');
switch val_S_or_H
    case 0 , S_or_H = 'h';
    case 1 , S_or_H = 's';
end
keepAPP = logical(get(handles.Rad_YES,'Value'));

% Denoising and Storing
%----------------------
threshold = blockdatamngr('get',fig,'data_DorC','threshold');
[sig_DorC,dec_DorC] = ...
    mswden('den',data_ORI.dwtDEC,'man_thr',threshold,S_or_H,keepAPP);
[Energy,tab_ENER] = wdecenergy(dec_DorC);
blockdatamngr('set',fig,'data_DorC',...
        'signal',sig_DorC,'dwtDEC',dec_DorC,...
        'Energy',Energy,'tab_ENER',tab_ENER);

% Setting GUI.
%-------------
level = dec_DorC.level;
mdw1dafflst('DAT','DEN',level,handles.Lst_SIG_DATA,handles.Lst_CFS_DATA);
hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
set(hdl_Menus.m_save,'Enable','On');

% Show Thresholds.
%-----------------
blockdatamngr('set',fig,'tool_ATTR','State','DEN_ON');
mdw1dafflst('DEN',hObject,eventdata,handles,'init','KeepSelected')
flag_MAN = get(handles.Pus_ENA_MAN,'UserData');
if isequal(flag_MAN,true)
    blockdatamngr('set',fig,'tool_ATTR','State','DEN_MAN');
end

% End waiting.
%-------------
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Pop_THR_METH_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

val = get(hObject,'Value');
usr = get(hObject,'UserData');
if val==5
    if isempty(usr) , val = 1; else val = usr; end
    set(hObject,'Value',val,'UserData',val);
    return
end
set(hObject,'UserData',val);
if ~isempty(usr) &&  isequal(usr,val) , return; end

switch val
    case {1,2,3,4}
        hdl_OFF = [handles.Txt_Penal,handles.Sli_Penal,handles.Edi_Penal];
        hdl_ON  = handles.Pop_NOI_Struct; 
        str_TxtPAR = getWavMSG('Wavelet:commongui:Str_NoiStruc');
        
    case {6,7,8,9} 
        hdl_ON  = [handles.Txt_Penal,handles.Sli_Penal,handles.Edi_Penal];
        hdl_OFF = handles.Pop_NOI_Struct;         
        str_TxtPAR = getWavMSG('Wavelet:mdw1dRF:Select_SCA_VAL');
        penalize_FUN('pop',handles)
end

set(handles.Txt_PAR_METH,'String',str_TxtPAR);
set(hdl_OFF,'Visible','Off');
set(hdl_ON,'Visible','On');
%--------------------------------------------------------------------------
function Rad_APP_Callback(hObject,eventdata,handles,typeCALL) %#ok<INUSL,DEFNU>

switch typeCALL
    case 'YES' , newdata = [1,0];
    case 'NO'  , newdata = [0,1];
end
set(handles.Rad_YES,'Value',newdata(1))
set(handles.Rad_NO,'Value',newdata(2))
%--------------------------------------------------------------------------
function Rad_THR_Callback(hObject,eventdata,handles,typeCALL) %#ok<INUSL,DEFNU>

switch typeCALL
    case 'SOFT' , newdata = [1,0];
    case 'HARD' , newdata = [0,1];
end
set(handles.Rad_SOFT,'Value',newdata(1))
set(handles.Rad_HARD,'Value',newdata(2))
%--------------------------------------------------------------------------
function Sli_Penal_Callback(hObject,eventdata,handles) %#ok<INUSL>

penalize_FUN('sli',handles)
%--------------------------------------------------------------------------
function Edi_Penal_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

penalize_FUN('edi',handles)
%--------------------------------------------------------------------------
function penalize_FUN(caller,handles)

switch caller
    case 'sli' , val_SLI = get(handles.Sli_Penal,'Value');
    case 'edi' , curScaleVAL = str2double(get(handles.Edi_Penal,'String'));
end
TabVAL = get(handles.Sli_Penal,'UserData');
if isempty(TabVAL)
    TabVAL = [0 , 5 , 5 , 10 ; 0 2.5 2.5 5 ; 0 1 1 2.5 ; 0 0 1 100];
    val_SLI = 0;
    numMETH = 1;
    set(handles.Sli_Penal,'Value',val_SLI,'UserData',TabVAL);
else
    numMETH = get(handles.Pop_THR_METH,'Value')-5;
end
minScaleVAL = TabVAL(numMETH,3);
maxScaleVAL = TabVAL(numMETH,4);

switch caller
    case 'pop' , val_SLI = TabVAL(numMETH,1);
    case 'sli' , if isequal(TabVAL(numMETH,1),val_SLI) , return; end
    case 'edi'
        if isnan(curScaleVAL) || isempty(curScaleVAL)
            val_SLI = TabVAL(numMETH,1);
        elseif curScaleVAL<minScaleVAL , val_SLI = 0;
        elseif curScaleVAL>maxScaleVAL , val_SLI = 1;
        else val_SLI = (curScaleVAL-minScaleVAL)/(maxScaleVAL-minScaleVAL);
        end
end
curScaleVAL = minScaleVAL + val_SLI*(maxScaleVAL-minScaleVAL);
TabVAL(numMETH,1) = val_SLI;
TabVAL(numMETH,2) = curScaleVAL;
set(handles.Sli_Penal,'Value',val_SLI,'UserData',TabVAL);
set(handles.Edi_Penal,'String',num2str(curScaleVAL,'%8.3f'));
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%

%=========================================================================%
%                BEGIN Tool Initialization                                %
%=========================================================================%
function Init_Tool(fig,eventdata,handles,varargin)

% Input Parameters.
%------------------
callingFIG = varargin{1};
Data_Name  = varargin{2};
tool_Name  = 'DEN';
mdw1dutils('data_INFO_MNGR','create',fig,tool_Name,callingFIG);

% Begin initialization.
%----------------------
set(fig,'Visible','off');

% WTBX -- Install DynVTool
%-------------------------
dynvtool('Install_V3',fig,handles);

% WTBX -- Initialize GUIDE Figure.
%---------------------------------
wfigmngr('beg_GUIDE_FIG',fig);

% UIMENU Installation.
%---------------------
m_files = wfigmngr('getmenus',fig,'file');
m_close = wfigmngr('getmenus',fig,'close');
cb_close = 'mdw1dmngr(''Pus_CloseWin_Callback'',gcbo,[],guidata(gcbo),''DEN'');';
set(m_close,'Callback',cb_close);
m_save  = uimenu(m_files,...
    'Label',getWavMSG('Wavelet:commongui:Str_Save'), ...
    'Position',2,'Enable','Off','Separator','On');
cb_save = 'mdw1dmngr(''Men_save_FUN'',gcbo,[],guidata(gcbo),''DEN_SIG'');';
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Save_DEN_SIG'),...
    'Position',1,'Enable','On','Callback',cb_save);
cb_save = 'mdw1dmngr(''Men_save_FUN'',gcbo,[],guidata(gcbo),''DEN_DEC'');';
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Save_DEN_DEC'),...
    'Position',2,'Enable','On','Callback',cb_save);
hdl_Menus = struct('m_files',m_files,'m_close',m_close,'m_save',m_save);
wtbxappdata('set',fig,'hdl_Menus',hdl_Menus);

% Help and ContextMenus INSTALLATION
%------------------------------------
Install_HELP_and_CtxtMenu(fig,handles);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',fig,mfilename);
lst_Colors =  mdw1dutils('lst_Colors');
edi_TIT_HDL = [...
    handles.Edi_TIT_VISU,handles.Edi_TIT_SEL,handles.Edi_TIT_VISU_DEC ...
    ];
set(edi_TIT_HDL,'ForegroundColor',lst_Colors.sig)
set(handles.Fra_MET_DEN,'ForegroundColor',[0.85 0.85 0.85])

% Other Initializations.
%-----------------------
mdw1dmngr('init_TOOL',handles,Data_Name,tool_Name);
Sli_Penal_Callback(handles.Sli_Penal,eventdata,handles);
%--------------------------------------------------------------------------
function Install_HELP_and_CtxtMenu(hFig,handles)

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig, ...
    getWavMSG('Wavelet:mdw1dRF:HLP_MultiSig_DEN'),'MULT_DENO_1D');

% Add Help Item.
%----------------
wfighelp('addHelpItem',hFig, ...
    getWavMSG('Wavelet:commongui:HLP_DenoProc'),'DENO_PROCEDURE');
wfighelp('addHelpItem',hFig, ...
    getWavMSG('Wavelet:commongui:HLP_AvailMeth'),'COMP_DENO_METHODS');

% Add ContextMenus
%-----------------
hdl_WAV = [handles.Txt_Wav,handles.Edi_Wav_Fam,handles.Edi_Wav_Num];
wfighelp('add_ContextMenu',hFig,hdl_WAV,'UT_WAVELET');
hdl_EXT = [handles.Txt_Ext_Mode,handles.Edi_Ext_Mode];
wfighelp('add_ContextMenu',hFig,hdl_EXT,'EXT_MODE');
hdl_TMP = [handles.Pop_THR_METH,handles.Edi_Penal,handles.Sli_Penal];
wfighelp('add_ContextMenu',hFig,hdl_TMP,'COMP_DENO_STRA');
hdl_TMP = [handles.Rad_SOFT,handles.Rad_HARD];
wfighelp('add_ContextMenu',hFig,hdl_TMP,'DENO_SOFTHARD');
hdl_TMP = [handles.Txt_PAR_METH,handles.Pop_NOI_Struct];
wfighelp('add_ContextMenu',hFig,hdl_TMP,'DENO_NOISSTRUCT');
%--------------------------------------------------------------------------
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%
