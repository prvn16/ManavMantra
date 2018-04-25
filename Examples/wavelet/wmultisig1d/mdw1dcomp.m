function varargout = mdw1dcomp(varargin)
%MDW1DCOMP Discrete wavelet Multisignal 1D Analysis Tool.
%   VARARGOUT = MDW1DCOMP(VARARGIN)

% Last Modified by GUIDE v2.5 30-Aug-2006 18:02:27
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2005.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $ $Date: 2013/07/05 04:31:04 $

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mdw1dcomp_OpeningFcn, ...
                   'gui_OutputFcn',  @mdw1dcomp_OutputFcn, ...
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
% --- Executes just before mdw1dcomp is made visible.                     %
%*************************************************************************%
function mdw1dcomp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for mdw1dcomp
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
function varargout = mdw1dcomp_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
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
%--------------------------------------------------------------------------
function Pus_ENA_MAN_Callback(hObject,eventdata,handles) %#ok<DEFNU>

fig = handles.Current_Fig;
flag_MAN = get(hObject,'UserData');
if isempty(flag_MAN) , flag_MAN = true; else flag_MAN = ~flag_MAN; end
to_HIDE = [handles.Pan_LST_DATA, ...
    handles.Pus_Compute_ALL,handles.Pus_Compute_RESET];
to_ENA = [...
    handles.Pus_Compress,...
    handles.Txt_APP_KEEP,handles.Rad_YES,handles.Rad_NO, ...
    handles.Txt_THR_TYPE,handles.Rad_SOFT,handles.Rad_HARD,...
    handles.Pus_CloseWin ...
    ];
if flag_MAN
    tool_STATE = 'CMP_MAN';
    wtbxappdata('set',fig,'flag_modify_THR',false);
    data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
    level    = wgfields(data_ORI,'level');
    set(handles.Edi_MAN_THR,'UserData',NaN(1,level));
    idxSIG_SEL = wtbxappdata('get',fig,'idxSIG_SEL');
    if isempty(idxSIG_SEL)
        idxSIG_SEL = 1;
        wtbxappdata('set',fig,'idxSIG_SEL',idxSIG_SEL);
    end
    threshold = ...
        blockdatamngr('get',fig,'data_DorC','threshold');
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
    mdw1dafflst('CMP',[],eventdata,handles,'init');
    valPOP = get(handles.Pop_MAN_TYP_THR,'Value');
    switch valPOP
        case 1 , Show_Mode = 'lvlThr';
        case 2 , Show_Mode = 'glbThr';
    end
    %-------------------------------------------------------------------
    strPUS = getWavMSG('Wavelet:mdw1dRF:Disable_MAN_THR');
    set(hObject,'String',strPUS,'UserData',flag_MAN);
    blockdatamngr('set',fig,'tool_ATTR','State',tool_STATE);
    %-------------------------------------------------------------------
    mdw1dmngr('setDispMode',handles.Pop_Show_Mode,eventdata,handles,...
          'CMP','MAN',Show_Mode);
    mdw1dmisc('show',handles,'MAN_THR','INI')
    set(handles.Pan_MAN_THR,'Visible','On');
else
    modify_THR = wtbxappdata('get',fig,'flag_modify_THR');
    if modify_THR
        msg = getWavMSG('Wavelet:mdw1dRF:Quest_KeepThrValue');
        Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
        Str_No  = getWavMSG('Wavelet:commongui:Str_No');  ...
        Str_Cancel = getWavMSG('Wavelet:commongui:Str_Cancel');
        BtnName = questdlg(msg,getWavMSG('Wavelet:mdw1dRF:Modif_THR_VAL'), ...
            Str_Yes,Str_No,Str_Cancel,Str_Yes); ...
        switch BtnName
            case Str_Cancel , return;
            case Str_Yes
            case Str_No
                threshold = wtbxappdata('get',fig,'SAVED_threshold');
                blockdatamngr('set',fig,'data_DorC',...
                    'threshold',threshold);
                mdw1dafflst('CMP',[],[],handles,'init')
        end
        wtbxappdata('set',fig,'flag_modify_THR',false);
    end    
    tool_STATE = 'CMP_ON';
    set(handles.Pan_MAN_THR,'Visible','Off');
    Edi_ToClean = [...
        handles.Edi_L2_PERF,handles.Edi_N0_PERF, ...
        handles.Edi_MAN_THR,handles.Edi_MAN_GLB_THR];
    set(Edi_ToClean,'String','');
    set(handles.Edi_Selected_DATA,'Enable','Inactive')
    set(to_ENA,'Enable','On')
    set(to_HIDE,'Visible','On')
    %-------------------------------------------------------------------
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_ENA_MAN');
    set(hObject,'String',strPUS,'UserData',flag_MAN);
    blockdatamngr('set',fig,'tool_ATTR','State',tool_STATE);
    %------------------------------------------------------------------- 
    MAN_TYP_THR = get(handles.Pop_MAN_TYP_THR,'Value');
    switch MAN_TYP_THR
        case 1 , endARG = 'lvlThr_END';
        case 2 , endARG = 'glbThr_END';
    end
    mdw1dmngr('setDispMode',handles.Pop_Show_Mode,eventdata,handles,...
        'CMP','MAN',endARG);
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
    handles.Pus_Compress,handles.Txt_THR_TYPE,...
    handles.Rad_SOFT,handles.Rad_HARD,handles.Pus_CloseWin ...
    ];

tool_STATE = 'CMP_MAN';
strPUS = getWavMSG('Wavelet:mdw1dRF:Disable_MAN_THR');
data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
level    = wgfields(data_ORI,'level');
set(handles.Edi_MAN_THR,'UserData',NaN(1,level));
idxSIG_SEL = wtbxappdata('get',fig,'idxSIG_SEL');
if isempty(idxSIG_SEL)
    idxSIG_SEL = 1;
    wtbxappdata('set',fig,'idxSIG_SEL',idxSIG_SEL);
end
threshold = ...
    blockdatamngr('get',fig,'data_DorC','threshold');
thrTMP = threshold(idxSIG_SEL,:);
set(handles.Pop_MAN_SIG,'UserData',thrTMP);
strPOP = num2cell(int2str(idxSIG_SEL(:)),2);
strPOP = [getWavMSG('Wavelet:commongui:Str_All');strPOP];
nbSTR = length(strPOP);
if nbSTR>1 , valPOP = 2; else valPOP = 1; end
set(handles.Pop_MAN_SIG,'String',strPOP,'Value',valPOP);

set(handles.Edi_Selected_DATA,'Enable','On')
set(Pus_MAN,'String',strPUS);
set(to_ENA,'Enable','Off')
set(to_HIDE,'Visible','Off')
% mdw1dmngr('setDispMode',handles.Pop_Show_Mode,[],handles,...
%     'CMP','MAN','lvlThr_END');
blockdatamngr('set',fig,'tool_ATTR','State',tool_STATE);
mdw1dshow('Show_DEC_Fun',fig,[],handles,'CMP')
set(handles.Pan_MAN_THR,'Visible','On');
valPOP = get(handles.Pop_MAN_TYP_THR,'Value');
if valPOP==2 , mdw1dmisc('show',handles,'MAN_THR','INI_GLB'); end
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
function Pus_MAN_Show_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

flag_SHOW = get(hObject,'UserData');
if isempty(flag_SHOW) , flag_SHOW = false; end
flag_SHOW = ~flag_SHOW;
set(hObject,'UserData',flag_SHOW);
uic_2 = [...
    handles.Rad_MAN_ALL,handles.Txt_MAN_SEL,...
    handles.Pop_MAN_TYP_THR,handles.Pop_MAN_SIG...
    ];
hdl_LVL = [...
    handles.Txt_MAN_LEV,handles.Pop_MAN_LEV,...
    handles.Txt_MAN_THR,handles.Edi_MAN_THR ...
    ];
hdl_GLB = [...
    handles.Txt_MAN_GLB_THR,handles.Edi_MAN_GLB_THR,...
    handles.Txt_L2_PERF,handles.Edi_L2_PERF,handles.Txt_Per_PerL2,...
    handles.Txt_N0_PERF,handles.Edi_N0_PERF,handles.Txt_Per_PerN0];
if flag_SHOW
    uic_ON = uic_1; uic_OF = [uic_2,hdl_LVL,hdl_GLB];
    strPUS = getWavMSG('Wavelet:mdw1dRF:Hide_Thresholds');
else
    valPOP = get(handles.Pop_MAN_TYP_THR,'Value');
    switch valPOP
        case 1 , uic_ON = [uic_2,hdl_LVL]; uic_OF = hdl_GLB;
        case 2 , uic_ON = [uic_2,hdl_GLB]; uic_OF = hdl_LVL;
    end
    strPUS = getWavMSG('Wavelet:mdw1dRF:Show_Thresholds');
end
set(uic_OF,'Visible','Off');
set(uic_ON,'Visible','On');
set(hObject,'String',strPUS);
%--------------------------------------------------------------------------
function Edi_MAN_GLB_THR_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

val_THR = str2double(get(hObject,'String'));
if isnan(val_THR) , set(hObject,'String',''); return; end
if val_THR<0
    val_THR = 0;  set(hObject,'String','0');
end
fig = handles.Current_Fig; 
wtbxappdata('set',fig,'flag_modify_THR',true);
mdw1dmisc('show',handles,'MAN_THR','EDI_GLB',val_THR)
%--------------------------------------------------------------------------
function Edi_L2_PERF_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

val_THR = str2double(get(hObject,'String'));
if isnan(val_THR) , set(hObject,'String',''); return; end
if val_THR<0
    val_THR = 0; set(hObject,'String','0');
elseif val_THR>100
    val_THR = 100; set(hObject,'String','100');
end
fig = handles.Current_Fig;
wtbxappdata('set',fig,'flag_modify_THR',true);
mdw1dmisc('show',handles,'MAN_THR','EDI_L2',val_THR)
%--------------------------------------------------------------------------
function Edi_N0_PERF_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

val_THR = str2double(get(hObject,'String'));
if isnan(val_THR) , set(hObject,'String',''); return; end
if val_THR<0
    val_THR = 0; set(hObject,'String','0');
elseif val_THR>100
    val_THR = 100; set(hObject,'String','100');
end
fig = handles.Current_Fig;
wtbxappdata('set',fig,'flag_modify_THR',true);
mdw1dmisc('show',handles,'MAN_THR','EDI_N0',val_THR)
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Manual CALLBACKS: END   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
function Pus_Compute_THR_Callback(hObject,eventdata,handles,typeCALL) %#ok<INUSL,DEFNU>

% Get figure handle.
%-------------------
fig = handles.output;

switch typeCALL
    case 'ALL' ,  idxSIG = getWavMSG('Wavelet:commongui:Str_All');
    case 'SEL' ,  idxSIG = wtbxappdata('get',fig,'idxSIG_SEL');
    case 'RESET', idxSIG = getWavMSG('Wavelet:commongui:Str_All'); % not used
end
if isempty(idxSIG) , return; end

% Get Wavelet Decomposition.
%---------------------------
data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
dec_ORI  = data_ORI.dwtDEC;
level    = dec_ORI.level;

% Compressing and Storing
%------------------------
threshold = blockdatamngr('get',fig,'data_DorC',...
    'threshold');
cmp_PERF = wtbxappdata('get',fig,'cmp_PERF');
L2_Perf = cmp_PERF{1};
N0_Perf = cmp_PERF{2};

% Get Compression Parameters.
%---------------------------
val_S_or_H = get(handles.Rad_SOFT,'Value');
switch val_S_or_H
    case 0 , S_or_H = 'h';
    case 1 , S_or_H = 's';
end
keepAPP = logical(get(handles.Rad_YES,'Value'));
nameMETH = get_parMETH(handles);

% Get Parameters.
%----------------
if ~isequal(typeCALL,'RESET')
    % Computing
    %----------
    wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitCompute'));
    
    switch nameMETH
        case {'rem_n0','bal_sn','sqrtbal_sn'}
            par_METH = {nameMETH,S_or_H,keepAPP}; 
            
        case {'L2_perf','N0_perf','glb_thr',...
              'scarcehi','scarceme','scarcelo','scarce'} 
            input_VAL = str2double(get(handles.Edi_GLB_PAR,'String'));
            par_METH  = {nameMETH,input_VAL,S_or_H,keepAPP}; 
            
        otherwise
            error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
                getWavMSG('Wavelet:FunctionArgVal:Invalid_ArgVal'))

    end
    [THR_VAL,L2_Perf_VAL,N0_Perf_VAL] = ...
            mswcmptp(dec_ORI,par_METH{:},idxSIG);
    if ischar(idxSIG) , idxSIG = 1:size(threshold,1); end
    switch nameMETH
        case {'rem_n0','bal_sn','sqrtbal_sn','L2_perf','N0_perf','glb_thr'}
            THR_VAL = THR_VAL(:,ones(1,level));
        case {'scarcehi','scarceme','scarcelo','scarce'}
    end
    threshold(idxSIG,:) = THR_VAL;
    L2_Perf(idxSIG) = L2_Perf_VAL;
    N0_Perf(idxSIG) = N0_Perf_VAL;
    set(handles.Edi_MAN_THR,'String',num2str(THR_VAL(1),'%10.5f'));
    set(handles.Edi_MAN_GLB_THR,'String',num2str(THR_VAL(1),'%10.5f'));
    set(handles.Edi_L2_PERF,'String',num2str(L2_Perf_VAL(1),'%10.2f'));
    set(handles.Edi_N0_PERF,'String',num2str(N0_Perf_VAL(1),'%10.2f'));
    change_THR = true;    
else
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
            case Str_Yes
                [THR_VAL,L2_Perf,N0_Perf] = ...
                    mswcmptp(data_ORI.dwtDEC,'L2_perf',100+eps);
                threshold = THR_VAL(:,ones(1,level));
                change_THR = true;
            case Str_No
            case Str_Cancel , return;
        end
    end
end

if change_THR
    cmp_PERF(1:2) = {L2_Perf,N0_Perf};
    wtbxappdata('set',fig,'cmp_PERF',cmp_PERF);
    blockdatamngr('set',fig,...
            'data_DorC','threshold',threshold);
    flag_MAN = get(handles.Pus_ENA_MAN,'UserData');
    if isequal(flag_MAN,true)
        wtbxappdata('set',fig,'flag_modify_THR',true);
    end
end

% Show Thresholds.
%-----------------
blockdatamngr('set',fig,'tool_ATTR','State','CMP_ON');
mdw1dafflst('CMP',[],eventdata,handles,'init',[])
if isequal(typeCALL,'SEL') , ENA_MAN_Func(handles); end

% End waiting.
%-------------
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Pus_Compress_Callback(hObject,eventdata,handles) %#ok<DEFNU>

% Get figure handle.
%-------------------
fig = handles.output;

% Get Selected Data Type.
%------------------------
[dwtType,sigType] = mdw1dutils('get_Sig_IDENT',fig,'lst');
ori_sig_FLAG = all(dwtType=='S') & all(sigType=='o');
if ~ori_sig_FLAG
    msg = getWavMSG('Wavelet:mdw1dRF:Quest_CompSig');
    Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
    Str_No  = getWavMSG('Wavelet:commongui:Str_No');  ...
    BtnName = questdlg(msg,getWavMSG('Wavelet:mdw1dRF:Compressing_signals'), ...
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

% Get Compression Parameters.
%--------------------------
val_S_or_H = get(handles.Rad_SOFT,'Value');
switch val_S_or_H
    case 0 , S_or_H = 'h';
    case 1 , S_or_H = 's';
end
keepAPP = logical(get(handles.Rad_YES,'Value'));

% Compressing and Storing
%------------------------
threshold = blockdatamngr('get',fig,'data_DorC','threshold');
[sig_DorC,dec_DorC,~,energyDEC_PERF,nb0_PERF] = ...
    mswcmp('cmp',data_ORI.dwtDEC,'man_thr',threshold,S_or_H,keepAPP);
[Energy,tab_ENER] = wdecenergy(dec_DorC);
blockdatamngr('set',fig,'data_DorC',...
        'signal',sig_DorC,'dwtDEC',dec_DorC,...
        'Energy',Energy,'tab_ENER',tab_ENER);
cmp_PERF = wtbxappdata('get',fig,'cmp_PERF');
cmp_PERF(1:2) = {energyDEC_PERF,nb0_PERF}; 
wtbxappdata('set',fig,'cmp_PERF',cmp_PERF);

% Setting GUI.
%-------------
level = dec_DorC.level;
mdw1dafflst('DAT','CMP',level,handles.Lst_SIG_DATA,handles.Lst_CFS_DATA);
hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
set(hdl_Menus.m_save,'Enable','On');

% Show Thresholds.
%-----------------
blockdatamngr('set',fig,'tool_ATTR','State','CMP_ON');
mdw1dafflst('CMP',hObject,eventdata,handles,'init',[])
flag_MAN = get(handles.Pus_ENA_MAN,'UserData');
if isequal(flag_MAN,1)
    blockdatamngr('set',fig,'tool_ATTR','State','CMP_MAN');
end

% End waiting.
%-------------
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Pop_THR_METH_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>
%==========================================
% 1) Remove near 0        
% 2) Balance sparsity-norm
% 3) Balance sparsity-norm (sqrt)
% --------------------------------
% 5) Global threshold
% 6) Energy ratio
% 7) Zero coefficients ratio    
% --------------------------------
% 9)  Scarce high
% 10) Scarce medium
% 11) Scarce low
% 12) Scarce
%==========================================
val = get(hObject,'Value');
usr = get(hObject,'UserData');
if val==4 || val==8
    if isempty(usr) , val = 1; else val = usr; end
    set(hObject,'Value',val,'UserData',val);
    return
end
set(hObject,'UserData',val);
if ~isempty(usr) && isequal(usr,val) , return; end

hdl_PAR = [handles.Txt_GLB_PAR,handles.Sli_GLB_PAR,handles.Edi_GLB_PAR];
if ismember(val,[1 2 3]) , ena_PAR = 'Off'; else ena_PAR = 'On'; end
switch val
    case {1,2,3} ,   str_TxtPAR = getWavMSG('Wavelet:moreMSGRF:Par_Selection'); 
    case 5 ,         str_TxtPAR = getWavMSG('Wavelet:moreMSGRF:Sel_GLB_THR');  
    case 6 ,         str_TxtPAR = getWavMSG('Wavelet:moreMSGRF:Sel_ENER_RAT');  
    case 7 ,         str_TxtPAR = getWavMSG('Wavelet:moreMSGRF:Sel_ZER_CFS');         
    case {9,10,11} , str_TxtPAR = getWavMSG('Wavelet:moreMSGRF:Sel_SCARCE_PAR');  
    case 12 ,        str_TxtPAR = getWavMSG('Wavelet:moreMSGRF:Sel_SCARCE_PAR');  
end
set(handles.Txt_GLB_PAR,'String',str_TxtPAR);
set(hdl_PAR,'Enable',ena_PAR);
nameMETH = get_parMETH(handles);
usr = get(handles.Sli_GLB_PAR,'UserData');
if isempty(usr)
    fig = handles.output;
    cmp_PERF = wtbxappdata('get',fig,'cmp_PERF');
    bound_METH = cmp_PERF{4};
else
    bound_METH = usr{2};
end
idx = strcmp(bound_METH(:,1),nameMETH);
numMETH = find(idx);
set(handles.Sli_GLB_PAR,'UserData',{numMETH,bound_METH});
if ~isempty(bound_METH{numMETH,2})
    if bound_METH{numMETH,4}<bound_METH{numMETH,2}
        bound_METH{numMETH,4} = bound_METH{numMETH,2};
    end
    set(handles.Sli_GLB_PAR,...
        'Min',bound_METH{numMETH,2},'Max',bound_METH{numMETH,3},...
        'Value',bound_METH{numMETH,4});
    set_Edi_GLB_PAR_String(handles.Edi_GLB_PAR,numMETH,bound_METH);
else
    set(handles.Edi_GLB_PAR,'String','');
end
%--------------------------------------------------------------------------
function Sli_GLB_PAR_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

val = get(hObject,'Value');
usr = get(hObject,'UserData');
numMETH = usr{1};
bound_METH = usr{2};
bound_METH{numMETH,4} = val;
set(hObject,'UserData',{numMETH,bound_METH});
set_Edi_GLB_PAR_String(handles.Edi_GLB_PAR,numMETH,bound_METH);
%--------------------------------------------------------------------------
function Edi_GLB_PAR_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

val = str2double(get(hObject,'String'));
usr = get(handles.Sli_GLB_PAR,'UserData');
numMETH = usr{1};
bound_METH = usr{2};
mini = bound_METH{numMETH,2};
maxi = bound_METH{numMETH,3};
if isnan(val) || isempty(val)
    val = bound_METH{numMETH,4};
elseif val<mini , val = mini;
elseif val>maxi , val = maxi;
end
bound_METH{numMETH,4} = val;
set(handles.Sli_GLB_PAR,'UserData',{numMETH,bound_METH});
set_Edi_GLB_PAR_String(handles.Edi_GLB_PAR,numMETH,bound_METH);
%--------------------------------------------------------------------------
function set_Edi_GLB_PAR_String(Edi,numMETH,bound_METH)

nameMETH = bound_METH{numMETH,1};
switch nameMETH
    case {'L2_perf','N0_perf'} , formatNum = '%8.2f';
    case {'glb_thr'} , formatNum = '%8.3f';
    case {'scarcehi','scarceme','scarcelo','scarce'} , formatNum = '%8.3f';
end
set(Edi,'String',num2str(bound_METH{numMETH,4},formatNum));
%--------------------------------------------------------------------------
function Pop_MAN_TYP_THR_Callback(hObject,eventdata,handles,dispName) %#ok<DEFNU>

if nargin>3
    switch dispName
        case 'lvlThr' , valPOP = 1;
        case 'glbThr' , valPOP = 2;
    end
    set(hObject,'Value',valPOP);
else
    valPOP = get(hObject,'Value');
end
usrPOP = get(hObject,'UserData');
set(hObject,'UserData',valPOP);
if isequal(valPOP,usrPOP) || (isempty(usrPOP) && valPOP==1), return; end

hdl_LVL = [...
    handles.Txt_MAN_LEV,handles.Pop_MAN_LEV,...
    handles.Txt_MAN_THR,handles.Edi_MAN_THR];
hdl_GLB = [...
    handles.Txt_MAN_GLB_THR,handles.Edi_MAN_GLB_THR,...
    handles.Txt_L2_PERF,handles.Edi_L2_PERF,handles.Txt_Per_PerL2,...
    handles.Txt_N0_PERF,handles.Edi_N0_PERF,handles.Txt_Per_PerN0];

switch valPOP
    case 1      % Manual by level
        hdl_ON = hdl_LVL; hdl_OFF = hdl_GLB; 
        Show_Mode = 'lvlThr';
    case 2      % Manual global
        hdl_ON = hdl_GLB; hdl_OFF = hdl_LVL;
        Show_Mode = 'glbThr';  
end
set(hdl_OFF,'Visible','Off');
set(hdl_ON,'Visible','On');
if nargin>3 , return; end
mdw1dmngr('setDispMode',handles.Pop_Show_Mode,eventdata,handles,...
          'CMP','MAN',Show_Mode);
%--------------------------------------------------------------------------
function Pus_MAN_Valid_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

fig = handles.output;
flagMODIFIED = wtbxappdata('get',fig,'flag_modify_THR');
if ~flagMODIFIED , return; end

msg = getWavMSG('Wavelet:mdw1dRF:Update_THR_VAL');
Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
Str_Cancel = getWavMSG('Wavelet:commongui:Str_Cancel');
BtnName = questdlg(msg,getWavMSG('Wavelet:mdw1dRF:Modif_THR_VAL'), ...
    Str_Yes,'Cancel',Str_Yes);
switch BtnName
    case Str_Cancel , return;
    case Str_Yes
end
threshold = blockdatamngr('get',fig,'data_DorC','threshold');
wtbxappdata('set',fig,'SAVED_threshold',threshold);
wtbxappdata('set',fig,'flag_modify_THR',false);
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%=========================================================================%
function Init_Tool(fig,eventdata,handles,varargin) %#ok<INUSL>

% Input Parameters.
%------------------
callingFIG = varargin{1};
Data_Name   = varargin{2};
tool_Name   = 'CMP';
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
cb_close = 'mdw1dmngr(''Pus_CloseWin_Callback'',gcbo,[],guidata(gcbo),''CMP'');';
set(m_close,'Callback',cb_close);
m_save  = uimenu(m_files,...
    'Label',getWavMSG('Wavelet:commongui:Str_Save'), ...
    'Position',2,'Enable','Off');
cb_save = 'mdw1dmngr(''Men_save_FUN'',gcbo,[],guidata(gcbo),''CMP_SIG'');';
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Save_CMP_SIG'),...
    'Position',1,'Enable','On','Callback',cb_save);
cb_save = 'mdw1dmngr(''Men_save_FUN'',gcbo,[],guidata(gcbo),''CMP_DEC'');';
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Save_CMP_DEC'),...
    'Position',2,'Enable','On','Callback',cb_save);
hdl_Menus = struct('m_files',m_files,'m_close',m_close,'m_save',m_save);
wtbxappdata('set',fig,'hdl_Menus',hdl_Menus);

% Help and ContextMenus INSTALLATION
%------------------------------------
Install_HELP_and_CtxtMenu(fig,handles);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',fig,mfilename);

% Other Initializations.
%-----------------------
set(handles.Fra_MET_CMP,'ForegroundColor',[0.85 0.85 0.85])
mdw1dmngr('init_TOOL',handles,Data_Name,tool_Name);
% set(handles.Edi_TIT_MAN,'Enable','Off');
data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
THR_MAXI = mswcmptp(data_ORI.dwtDEC,'L2_perf',0);
[~,L2_Perf,N0_Perf] = mswcmptp(data_ORI.dwtDEC,'L2_perf',150);
bound_METH = cell(10,4);
bound_METH(:,1) = ...
     {'rem_n0';'bal_sn';'sqrtbal_sn';...
      'glb_thr';'L2_perf';'N0_perf'; ...
      'scarcehi';'scarceme';'scarcelo';'scarce'};
bound_METH(4:6,2) = {0};
bound_METH(4,3)   = {max(THR_MAXI)};
bound_METH(5:6,3) = {100};
bound_METH(7,2)   = {2.5}; bound_METH(7,3)   = {10};
bound_METH(8,2)   = {1.5}; bound_METH(8,3)   = {2.5};
bound_METH(9,2)   = {1};   bound_METH(9,3)   = {2};
bound_METH(10,2)  = {0};   bound_METH(10,3)  = {100};
for k = 4:10 , bound_METH(k,4) =  bound_METH(k,2); end
wtbxappdata('set',fig,'cmp_PERF',{L2_Perf,N0_Perf,THR_MAXI,bound_METH});

%--------------------------------------------------------------------------
function Install_HELP_and_CtxtMenu(hFig,handles)

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig, ...
    getWavMSG('Wavelet:mdw1dRF:HLP_MultiSig_CMP'),'MULT_COMP_1D');

% Add Help Item.
%----------------
wfighelp('addHelpItem',hFig, ...
    getWavMSG('Wavelet:commongui:HLP_CompProc'),'COMP_PROCEDURE');
wfighelp('addHelpItem',hFig, ...
    getWavMSG('Wavelet:commongui:HLP_AvailMeth'),'COMP_DENO_METHODS');

% Add ContextMenus
%-----------------
hdl_WAV = [handles.Txt_Wav,handles.Edi_Wav_Fam,handles.Edi_Wav_Num];
wfighelp('add_ContextMenu',hFig,hdl_WAV,'UT_WAVELET');
hdl_EXT = [handles.Txt_Ext_Mode,handles.Edi_Ext_Mode];
wfighelp('add_ContextMenu',hFig,hdl_EXT,'EXT_MODE');
hdl_TMP = [handles.Txt_THR_METH,handles.Pop_THR_METH, ...
    handles.Txt_GLB_PAR,handles.Edi_GLB_PAR,handles.Sli_GLB_PAR];
wfighelp('add_ContextMenu',hFig,hdl_TMP,'COMP_DENO_STRA');
hdl_TMP = [handles.Rad_SOFT,handles.Rad_HARD];
wfighelp('add_ContextMenu',hFig,hdl_TMP,'DENO_SOFTHARD');
%--------------------------------------------------------------------------
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%

%--------------------------------------------------------------------------
function [nameMETH,parMETH] = get_parMETH(handles)

%==========================================
% 1) Remove near 0        
% 2) Balance sparsity-norm
% 3) Balance sparsity-norm (sqrt)
% --------------------------------
% 5) Global threshold
% 6) Energy ratio
% 7) Zero coefficients ratio    
% --------------------------------
% 9)  Scarce high
% 10) Scarce medium
% 11) Scarce low
% 12) Scarce
%==========================================
parMETH = [];
numMETH = get(handles.Pop_THR_METH,'Value');
switch numMETH
    case 1  , nameMETH = 'rem_n0';
    case 2  , nameMETH = 'bal_sn';
    case 3  , nameMETH = 'sqrtbal_sn';
    case 5  , nameMETH = 'glb_thr';   
    case 6  , nameMETH = 'L2_perf';  
    case 7  , nameMETH = 'N0_perf';
    case 9  , nameMETH = 'scarcehi';
    case 10 , nameMETH = 'scarceme';
    case 11 , nameMETH = 'scarcelo';
    case 12 , nameMETH = 'scarce';
    otherwise
        error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
            getWavMSG('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end
%--------------------------------------------------------------------------
