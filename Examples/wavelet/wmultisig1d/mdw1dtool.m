function varargout = mdw1dtool(varargin)
%MDW1DTOOL Discrete wavelet Multisignal 1D Analysis Tool.
%   VARARGOUT = MDW1DTOOL(VARARGIN)

% Last Modified by GUIDE v2.5 12-Feb-2006 18:25:28
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2005.
%   Last Revision: 23-Oct-2014.
%   Copyright 1995-2014 The MathWorks, Inc.
%   $Revision: 1.1.6.18 $ $Date: 2013/08/23 23:45:51 $


%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mdw1dtool_OpeningFcn, ...
                   'gui_OutputFcn',  @mdw1dtool_OutputFcn, ...
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
% ---    Executes just before mdw1dtool is made visible.                  %
%*************************************************************************%
function mdw1dtool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for mdw1dtool
handles.output = hObject;

% Update handles structure
guidata(hObject,handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manualy in the automatic generated code  %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles,varargin{:});
if ~isempty(varargin)
    Load_Callback(hObject,eventdata,handles,varargin{:})
end
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%

%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = mdw1dtool_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
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
function Pop_DIR_Callback(hObject,eventdata,handles,varargin) %#ok<VANUS,DEFNU>

valPOP = get(hObject,'Value');
usrPOP = get(hObject,'UserData');
if isequal(valPOP,usrPOP) , return; end
set(hObject,'UserData',valPOP);
fig = handles.Current_Fig;
data_ORI = blockdatamngr('get',fig,'data_ORI');
if isempty(data_ORI.siz_INI) , return; end

% Cleaning and Setting GUI.
%--------------------------
CleanTOOL('load',eventdata,handles,'pop_dir',data_ORI);
%--------------------------------------------------------------------------
function Pus_ACTION_Callback(hObject,eventdata,handles,tool,varargin) %#ok<DEFNU>

flag_RETURN = (nargin>4);
if ~flag_RETURN , fig = handles.output; else fig = hObject; end

% Begin waiting.
%---------------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitCompute'));

Stats_TBX_Flag = wtbxappdata('get',hObject,'Stats_TBX_Flag');
if ~flag_RETURN
    % Call Tool : De-noising, Compression, Stats, Clustering.
    %--------------------------------------------------------
    Data_Name = get(handles.Edi_Data_NS,'String');
    switch tool
        case 'CLU'
            if ~Stats_TBX_Flag
                WarnStr = isstatstbxinstalled('msg');
                uiwait(msgbox(WarnStr,...
                    getWavMSG('Wavelet:mdw1dRF:Warn_UsingCLU'),'warn','modal'));
                set(handles.Pus_CLU_TOOLS,'Enable','Off');
                wtbxappdata('set',fig,'Cluster_Tool_Flag',true);
                wwaiting('off',fig);
                return
            end
            figACT = mdw1dclus(fig,Data_Name);
        case 'CMP' , figACT = mdw1dcomp(fig,Data_Name);
        case 'DEN' , figACT = mdw1ddeno(fig,Data_Name);
        case 'STA' , figACT = mdw1dstat(fig,Data_Name);            
    end
    pus_IMPORT_ACT = findobj(figACT,'Tag','Pus_IMPORT');
    set(pus_IMPORT_ACT,'Enable',get(handles.Pus_IMPORT,'Enable'))
    ena_Pus_STA = 'Off'; 
    ena_Pus_CLU = 'Off'; 
    ena_DEN_CMP = 'Off';
    ena_SAVE = get(handles.Pus_Compress,'Enable');
    set(handles.Pus_Compress,'UserData',ena_SAVE);
else
    handles = guidata(fig);
    switch tool
        case 'CLU'
        case 'STA'
        case {'CMP','DEN'}
            status_D_or_C = varargin{1};
            if status_D_or_C==1
                % fig_D_or_C = varargin{2};
                hdl_Menus = wtbxappdata('get',fig,'hdl_Menus');
                set([hdl_Menus.m_save,hdl_Menus.m_exp_wrks],'Enable','On');
                hM  = hdl_Menus.m_save_SYN;
                switch tool
                    case 'CMP' , 
                        lab_hM = getWavMSG('Wavelet:mdw1dRF:CompSig');
                    case 'DEN' , 
                        lab_hM = getWavMSG('Wavelet:mdw1dRF:DenoSig');
                end
                set(hM,'Label',lab_hM,'Enable','On');
                
            end
    end
    ena_Pus_STA = 'On';
    if Stats_TBX_Flag , ena_Pus_CLU = 'On'; else ena_Pus_CLU = 'Off'; end
    ena_DEN_CMP = get(handles.Pus_Compress,'UserData');
    tool_STATE = blockdatamngr('get',fig,'tool_ATTR','State');
    switch tool_STATE
        case 'INI' , aff_MODE = 'INI'; 
        otherwise  , aff_MODE = 'ORI';
    end
    mdw1dafflst(aff_MODE,hObject,eventdata,handles,'init',[])
end
set(handles.Pus_Stats,'Enable',ena_Pus_STA);
set(handles.Pus_CLU_TOOLS,'Enable',ena_Pus_CLU);
set([handles.Pus_Compress,handles.Pus_Denoise],'Enable',ena_DEN_CMP);

% End waiting.
%-------------
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Pus_CloseWin_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_save_SYN = hdl_Menus.m_save_SYN;
ena_Save = get(m_save_SYN,'Enable');
if isequal(lower(ena_Save),'on')
    fig = get(hObject,'Parent');
    status = wwaitans({fig,getWavMSG('Wavelet:mdw1dRF:Nam_MDW1D')},...
        getWavMSG('Wavelet:mdw1dRF:Save_MSig_Quest'),2,'Cancel');
    switch status
        case -1 , return;
        case  1
            wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitCompute'));
            mdw1dmngr('Men_save_FUN',hObject,[],handles,'SYN_ORI_DEC');
            wwaiting('off',fig);
        otherwise
    end
end
close(gcbf)
%--------------------------------------------------------------------------
function Load_Callback(hObject,eventdata,handles,varargin)

% Get figure handle.
%-------------------
fig = handles.output;

% Testing and loading file.
%--------------------------
makeDEC = false;
flagSIG = true;
flagLOAD = true;
if nargin<4 ,varargin{1} = 'sig'; end  
switch varargin{1}
    case 'sig'          % LOAD SIGNALS
    case 'dec'          % LOAD DECOMPOSITIONS
        flagSIG = false;
        makeDEC = true;

    case 'demo'         % DEMO SIG
        flagLOAD = false;
        [pathstr,shortname,ext] = fileparts(varargin{2}); %#ok<ASGLU>
        if isempty(ext)
            filename = [shortname,'.mat'];
        else
            filename = [shortname,ext];
        end
        fullName = filename;
        makeDEC  = varargin{3};
        
    case 'sig_wrks'   % IMPORT SIGNALS
        [input_VAL,sigNAM,ok] = wtbximport('mdw1d');
        if ~ok  , return; end
        flagSIG  = ~isstruct(input_VAL);
        makeDEC  = ~flagSIG;
        flagLOAD = false;

    case 'dec_wrks'   % IMPORT DECOMPOSITIONS
        [ok,input_VAL,sigNAM] = wtbximport('mdec1d');
        if ~ok  , return; end
        flagSIG = false;
        makeDEC  = true;
        flagLOAD = false;
        
    otherwise
        error('Wavelet:FunctionArgVal:Invalid_ArgVal', ...
             getWavMSG('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

if flagLOAD
    mask = {...
        '*.mat;*.ms1', 'ALL 1D Files (*.mat, *.ms1)'; ...
        '*.*','All Files (*.*)'
        };
    [filename,pathname] = uigetfile(mask, ...
        getWavMSG('Wavelet:divGUIRF:Pick_a_file'));
    if ~isequal(filename,0) && ~isequal(pathname,0)
        fullName = fullfile(pathname,filename);
    else
        return
    end
end
flagNot_WRKS_Var = ~isequal(varargin{1},'sig_wrks') && ...
    ~isequal(varargin{1},'dec_wrks');

if flagNot_WRKS_Var
    try
        err = 0;
        dataInfo = whos('-file',fullName);
        dataInfoCell = struct2cell(dataInfo);
        if flagSIG  % Signals
            minSizeSIG = min(cat(1,dataInfo(:).size),[],2);
            dataInfoCell(:,minSizeSIG<2) = [];
            idx = find(strcmp(dataInfoCell(1,:),'x'));
            if isempty(idx)
                idx = find(strcmp(dataInfoCell(1,:),'X'));
                if isempty(idx) ,
                    idx = find(strcmp(dataInfoCell(1,:),'sigDATA'));
                    if isempty(idx) ,
                        idx = find(strcmp(dataInfoCell(1,:),'signals'));
                        if isempty(idx) , idx = 1; end
                    end
                end
            end
        else    % decompositions
            idx = find(strcmp(dataInfoCell(1,:),'dec'));
            if isempty(idx)
                idx = find(strcmp(dataInfoCell(1,:),'DEC'));
                if isempty(idx) ,
                    idx = find(strcmp(dataInfoCell(1,:),'sigDEC'));
                    if isempty(idx) , idx = 1; end
                end
            end
        end
        varNam  = dataInfoCell{1,idx};
        siz_INPUT = dataInfoCell{2,idx};
        data      = load(fullName,'-mat');
        input_VAL = data.(varNam);
        if ~flagSIG
            err = ~isstruct(input_VAL);
            if ~err
                FN    = fieldnames(input_VAL);
                FNdec = {...
                    'dirDec';'level';'wname';'dwtFilters';'dwtEXTM'; ...
                    'dwtShift';'dataSize';'ca';'cd'};
                err = ~isequal(FN,FNdec);
            end;
        else
            input_VAL = double(input_VAL);
        end
    catch %#ok<CTCH>
        err = 1;
    end
else
    siz_INPUT = size(input_VAL);
    err = 0;
end

if err
    wwarndlg(...
        getWavMSG('Wavelet:mdw1dRF:Warn_Data_MDW1D'),...
        getWavMSG('Wavelet:mdw1dRF:Warn_Data_Title'),'modal');
    return
end
if flagNot_WRKS_Var
    [pathstr,sigNAM] = fileparts(filename); %#ok<ASGLU>
end

% Cleaning and Setting GUI.
%--------------------------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitClean'));

if ~flagSIG
    % Setting Analysis parameters.
    %-----------------------------
    wname  = input_VAL.wname;
    level  = input_VAL.level;
    dirDec = input_VAL.dirDec;
    switch dirDec
        case 'r' , valPOP_DIR = 2;
        case 'c' , valPOP_DIR = 1;
    end
    cbanapar('set',fig,'wav',wname,'lev',level);
    set(handles.Pop_DIR,'Value',valPOP_DIR,'UserData',valPOP_DIR);
    input_VAL = mdwtrec(input_VAL);
    siz_INPUT = size(input_VAL);
end
n_s = [sigNAM ' (' , int2str(siz_INPUT(1)) 'x' int2str(siz_INPUT(2)) ')'];

% Cleaning and Setting GUI.
%--------------------------
CleanTOOL('load',eventdata,handles,'menu',input_VAL);
set(handles.Edi_Data_NS,'String',n_s);
partsetmngr('Set_Pus_IMPORT',fig,'Off')

% Initialize DYNVTOOL.
%---------------------
axe_IND = [];
axe_CMD = [handles.Axe_VISU];
axe_ACT = [];
dynvtool('init',fig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','','real');

% End of loading.
%----------------
hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_load_PART = hdl_Menus.m_load_PART;
m_imp_PART  = hdl_Menus.m_imp_PART;
m_clear_PART = hdl_Menus.m_clear_PART;
m_PART = get(m_load_PART,'Parent');
set([m_PART,m_load_PART,m_imp_PART,m_clear_PART],'Enable','On');
set(m_clear_PART,'Enable','Off'); 
set(handles.Lst_SEL_DATA,'Value',1);

% Make decomposition.
%--------------------
if makeDEC
    Pus_Decompose_Callback(handles.Pus_Decompose,eventdata,handles,'load');
else
    mdw1dmisc('lst_DAT_SEL',handles,'load');
end

% End waiting.
%-------------
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Pop_Ext_Mode_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

%--------------------------------------------------------------------------
function Pus_Decompose_Callback(hObject,eventdata,handles,varargin)

%  if ~isempty(varargin)
%      mdw1dmisc('lst_DAT_SEL',handles,'load');  %####
%  end

% Get figure handle.
%-------------------
fig = handles.output;

% Cleaning.
%----------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitClean'));

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
UIC_Ena_OFF = [hdl_Menus.m_save,hdl_Menus.m_exp_wrks];
set(UIC_Ena_OFF,'Enable','Off')
mdw1dmngr('set_Tool_View',handles,'ORI','Reset','DEC')

% Wavelet decomposition of sig_ORI.
%----------------------------------
[wname,level] = cbanapar('get',fig,'wav','lev');
popMode  = handles.Pop_Ext_Mode;
lst = get(popMode,'String');
extMode = lst{get(popMode,'Value')};
sig_ORI = blockdatamngr('get',fig,'data_ORI','signal');
dec_ORI = mdwtdec('row',sig_ORI,level,wname,'mode',extMode);
[Energy,tab_ENER,longs,percentENER,idx_PerSORTED] = ...
                                wdecenergy(dec_ORI,'sort');

% Prepare Pan_SEL_INFO. 
%----------------------
mdw1dmisc('clean',handles,'Pan_SEL_INFO','dec',level);

% Show Selection Info: Compute_ENERGY.
%-------------------------------------
mdw1dutils('data_INFO_MNGR','reset',fig,dec_ORI,Energy,tab_ENER);
wtbxappdata('set',fig,'Energy_Info',{longs,percentENER,idx_PerSORTED});
blockdatamngr('set',fig,'tool_ATTR','State','ORI_ON');
mdw1dmngr('set_Tool_View',handles,'ORI','set_VIEW','LARGE')
mdw1dmngr('set_idxSIG_Plot',fig,handles,[]);
mdw1dafflst('ORI',hObject,eventdata,handles,'init',[]);

% Reset Decomposition Parameters and Axes. 
%-----------------------------------------
set(handles.Pop_Show_Mode,'Value',1,'UserData',[]);
strPOP = cell(level,1);
levSTR = getWavMSG('Wavelet:commongui:Str_Level');
for k = 1:level
    strPOP{k} = [levSTR ' ' int2str(k)];
end
set(handles.Pan_VISU_DEC,'Title', ...
    formatPanTitle(getWavMSG('Wavelet:mdw1dRF:View_Decompositions')));
set(handles.Chk_DEC_GRID,'Visible','Off');
set(handles.Pop_DEC_lev,'Visible','On')
set(handles.Axe_VIS_DEC,'XGrid','Off','YGrid','Off')
set(handles.Pop_DEC_lev,'String',strPOP,'Value',level);
mdw1dshow('set_Axe_DEC_Pos','sep',fig,handles,level);
mdw1dafflst('DAT','ORI',level,handles.Lst_SIG_DATA,handles.Lst_CFS_DATA);

% Reset Plot.
%------------
% mdw1dmisc('plot',handles,[],'clean');       %####
axe_IND = [];
axe_CMD = [handles.Axe_VISU];
axe_ACT = [];
dynvtool('init',fig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','','real');
set(handles.Lst_SEL_DATA,'Value',1);
mdw1dmisc('lst_DAT_SEL',handles,'load');    %####

UIC_Ena_ON = [...
    handles.Pus_Decompose,...
    hdl_Menus.m_save,hdl_Menus.m_exp_wrks,hdl_Menus.m_save_DEC, ...
    handles.Txt_LST_CFS,handles.Lst_CFS_DATA, ...
    handles.Pus_Stats,handles.Pus_Denoise,handles.Pus_Compress  ...
    ];
set(UIC_Ena_ON,'Enable','On')
set_Pus_CLU_TOOLS(handles)

% End waiting.
%-------------
wwaiting('off',fig);
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%=========================================================================%
function demo_FUN(hObject,eventdata,handles,numDEM)

demo_CELL_data = {...
    's3p3_30' ,   'db1'  , 5 , 'row';
    'ex_c5_100' , 'db1'  , 5 , 'row';
    'ex_c6_50' ,  'db1'  , 5 , 'row';
    'exvlachos' , 'sym4' , 6 , 'row';
    'ex1mwden' ,  'db1'  , 4 , 'col';
    'ex2mwden' ,  'db1'  , 4 , 'col';
    'ex3mwden' ,  'db1'  , 4 , 'col';
    'ex4mwden' ,  'db1'  , 4 , 'col';
    'ex5mwden' ,  'db1'  , 4 , 'col';
    'ex1mdr'      'sym4' , 5 , 'col';
    'ex2mdr'  ,   'sym4' , 5 , 'col';
    'ex3mdr' ,    'sym4' , 5 , 'col';
    'ex4mdr'  ,   'sym4' , 5 , 'col';
    'exrealdata' ,'sym4' , 6 , 'col';
    'elecsig10' , 'db1'  , 5 , 'row';
    'elecsig100', 'db1'  , 5 , 'row';
    'noiswom' ,   'sym4' , 4 , 'row';
    'noiswom' ,   'sym4' , 4 , 'col';
    'jellyfish'  ,'db1'  , 5 , 'row';
    'jellyfish'  ,'db1'  , 5 , 'col';
    'thinker'    ,'db2'  , 4 , 'row' ...
    };
fname  = demo_CELL_data{numDEM,1}; 
wname  = demo_CELL_data{numDEM,2}; 
level  = demo_CELL_data{numDEM,3}; 
direct = demo_CELL_data{numDEM,4}; 

% Get figure handle.
%-------------------
fig = handles.Current_Fig;

% Cleaning.
%----------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitClean'));

% Loading Signals and Setting GUI.
%--------------------------------
Pop_DIR = handles.Pop_DIR;
switch direct
    case 'row' , valPOP = 2;
    case 'col' , valPOP = 1;
end
% valPOP = get(Pop_DIR,'Value');
% LstSTR = get(Pop_DIR,'String');
% dir_DEC = LstSTR{valPOP}(1:3);
% if ~isequal(dir_DEC,direct)
%     valPOP = 3-valPOP;
    set(Pop_DIR,'Value',valPOP,'UserData',valPOP);
% end
cbanapar('set',fig,'wav',wname,'lev',level);
makeDEC = numDEM>0;
Load_Callback(hObject,eventdata,handles,'demo',fname,makeDEC);
%-------------------------------------------------------------------------%
function Export_Callback(hObject,eventdata,handles,type) %#ok<INUSL,DEFNU>

fig = handles.output;
data_DorC = mdw1dutils('data_INFO_MNGR','get',fig,'DorC');
typ_DorC  = upper(data_DorC.typ_DorC);
if isempty(typ_DorC)
    ST = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
else
    ST = data_DorC;
end
   
% if isempty(typ_DorC) || isequal(type,'SYN_ORI_DEC')
%     ST = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
% else
%     ST = data_DorC;
% end

switch type
    case 'sig'
        X = ST.signal;
        wtbxexport(X,'name','msig_1D', ...
            'title',getWavMSG('Wavelet:mdw1dRF:SyntSig'));
        
    case 'dec'
        dec = ST.dwtDEC; 
        wtbxexport(dec,'name','mdec_1D', ...
            'title',getWavMSG('Wavelet:mdw1dRF:MultiSig_Dec'));
end
%-------------------------------------------------------------------------%
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%=========================================================================%
function CleanTOOL(option,eventdata,handles,varargin)

fig = handles.Current_Fig;
switch option
    case 'load'
        % Begin Cleaning.
        %----------------
        [First_Use,State] = blockdatamngr('get',fig,...
            'tool_ATTR','First_Use','State');
        if First_Use
            OBJ_Ena_ON = [...
                handles.Txt_SEL_DATA,handles.Lst_SEL_DATA,...
                handles.Txt_SORT,handles.Pus_SORT_Dir,...
                handles.Pus_SORT_Inv,handles.Pop_SORT,...
                handles.Pus_AFF_ALL,handles.Pus_AFF_NON,handles.Chk_AFF_MUL,...
                handles.Pus_Stats, ...
                handles.Txt_Min,handles.Txt_Mean,handles.Txt_Max, ...
                handles.Pop_VisPanMode ...
                ];
            set(OBJ_Ena_ON,'Enable','On')
            set_Pus_CLU_TOOLS(handles)
            blockdatamngr('set',fig,'tool_ATTR','First_Use',false);
            hdl_InPan = allchild(handles.Pan_DAT_WAV);
            set(hdl_InPan,'Enable','On')
            set(handles.Edi_Data_NS,'Enable','Inactive')
        else
            if ~isequal(State,'INI')        % None
                lst_SIG = get(handles.Lst_SIG_DATA,'UserData');
                set(handles.Lst_SIG_DATA,'String',lst_SIG,'Value',1);
            end
            str_PopSort = {...
                getWavMSG('Wavelet:mdw1dRF:Idx_Sel'), ...    
                getWavMSG('Wavelet:mdw1dRF:Idx_Sig'), ...    
                getWavMSG('Wavelet:mdw1dRF:Dwt_Attr'), ...    
                getWavMSG('Wavelet:mdw1dRF:Level_L'), ...    
                getWavMSG('Wavelet:mdw1dRF:Type_Sig')  ... 
                };
            set(handles.Pop_SORT,'String',str_PopSort,'Value',1);
        end
        blockdatamngr('set',fig,'tool_ATTR','State','INI');
        wtbxappdata('set',fig,'SET_of_Partitions',[]);
        mdw1dmngr('set_Tool_View',handles,'ORI','set_VIEW','LARGE')
        
        % Clean Pan_SEL_INFO.
        %--------------------
        mdw1dmisc('clean',handles,'Pan_SEL_INFO','load')        
        titleSTR = formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Info_SelData'));
        set(handles.Pan_SEL_INFO,'Title',titleSTR);
        mdw1dmngr('set_Tool_View',handles,'ORI','Reset','LOAD')
        mdw1dmisc('plot',handles,[],'clean');
        hdl_Menus = wtbxappdata('get',fig,'hdl_Menus');
        UIC_Ena_OFF = [...
            hdl_Menus.m_save,hdl_Menus.m_exp_wrks , ...
            hdl_Menus.m_save_SYN,hdl_Menus.m_save_DEC,...
            handles.Pus_Decompose, ...
            handles.Txt_LST_CFS,handles.Lst_CFS_DATA, ...
            handles.Pus_Denoise,handles.Pus_Compress  ...
            ];
        set(hdl_Menus.m_save_SYN, ...
            'Label',getWavMSG('Wavelet:mdw1dRF:SyntSig'));
        set(UIC_Ena_OFF,'Enable','Off')
        set(handles.Lst_CFS_DATA,'String','','Value',[])
        mdw1dmngr('set_idxSIG_Plot',fig,handles,[]);
        
        % Setting Data Structures.
        %-------------------------
        Pop_DIR = handles.Pop_DIR;
        valPOP  = get(Pop_DIR,'Value');
        switch valPOP
            case 1 , dir_DEC = 'col';
            case 2 , dir_DEC = 'row';
        end
        set(Pop_DIR,'UserData',valPOP);
        switch varargin{1}
            case 'menu'
                sig_ORI = varargin{2};
                siz_INI = size(sig_ORI);
                flag_TRANS = isequal(dir_DEC,'col');
            case 'pop_dir'
                siz_INI = varargin{2}.siz_INI;
                sig_ORI = varargin{2}.signal;
                flag_TRANS = true;
        end
        lenSIG = mdw1dutils('data_INFO_MNGR','init',...
                        fig,siz_INI,sig_ORI,dir_DEC,flag_TRANS);
        
        % Setting GUI values and Analysis parameters.
        %--------------------------------------------
        max_lev_anal = 12;
        levm   = wmaxlev(lenSIG,'haar');
        levmax = min(levm,max_lev_anal);
        [curlev,curlevMAX] = cbanapar('get',fig,'lev','levmax');
        if levmax~=curlevMAX
            str_LEV = int2str((1:levmax)');
            val_LEV = min(levmax,curlev);
            cbanapar('set',fig,'lev',{'String',str_LEV,'Value',val_LEV});
        end
        
        % Setting List of selected data.
        %-------------------------------
        mdw1dafflst('INI',fig,eventdata,handles,'init','INI')

        % End Cleaning.
        %--------------
        mdw1dutils('set_Lst_DATA',handles,'init')
        UIC_Ena_ON = [...
            handles.Fra_SEL_DATA, ...
            handles.Txt_LST_SIG,handles.Lst_SIG_DATA,handles.Txt_SELECTED, ...
            handles.Pus_Decompose ...
            ];
        set(UIC_Ena_ON,'Enable','On')       
        UIC_Ena_INA = ...
            [handles.Txt_SORT,...
             handles.Edi_TIT_PAN_INFO, handles.Edi_NB_SIG, ...
             handles.Edi_Min,handles.Edi_Mean,handles.Edi_Max];
        % handles.Edi_TIT_SEL,handles.Edi_TIT_VISU,
        set(UIC_Ena_INA,'Enable','Inactive')
end
%=========================================================================%
%                      END CleanTOOL function                             %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%=========================================================================%
function Init_Tool(fig,eventdata,handles,varargin) %#ok<VANUS,INUSL>

% Begin initialization.
%----------------------
tool_Name = 'ORI';
set(fig,'Visible','off');

% WTBX -- Install DynVTool
%-------------------------
dynvtool('Install_V3',fig,handles);

% WTBX -- Initialize GUIDE Figure.
%---------------------------------
wfigmngr('beg_GUIDE_FIG',fig);

% WTBX -- Install ANAPAR FRAME
%-----------------------------
wnameDEF  = 'db1';
maxlevDEF = 12;
levDEF    = 5;
utanapar('Install_V3_CB',fig,'maxlev',maxlevDEF,'deflev',levDEF);
cbanapar('set',fig,'wav',wnameDEF,'lev',levDEF);

% UIMENU INSTALLATION
%--------------------
hdl_Menus = Install_MENUS(fig,tool_Name);
wtbxappdata('set',fig,'hdl_Menus',hdl_Menus);

% Help and ContextMenus INSTALLATION
%------------------------------------
Install_HELP_and_CtxtMenu(fig,handles);

% Data Initialization.
%---------------------
mdw1dutils('data_INFO_MNGR','create',fig,tool_Name,fig);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',fig,mfilename);

% Other Initializations.
%-----------------------
mdw1dmngr('init_TOOL',handles,'',tool_Name);
set(allchild(handles.Pan_DAT_WAV),'Enable','Off')
lst_Colors =  mdw1dutils('lst_Colors');
edi_TIT_HDL = [...
     handles.Edi_TIT_PAN_INFO
    ];
% handles.Edi_TIT_SEL,handles.Edi_TIT_VISU,handles.Edi_TIT_VISU_DEC,
set(edi_TIT_HDL,'Enable','Off','ForegroundColor',lst_Colors.sig)
Init_Pan_SEL_INFO(handles)

% Test Statistics and Machine Learning Toolbox intallation.
%-------------------------------------
% [Stats_TBX_Flag,WarnStr,errID] = isstatstbxinstalled;
% errID_for_TEST = 1;   % No license 
% errID_for_TEST = 2;   % Not in path
% errID = errID_for_TEST;
% switch errID
%     case 0
%     case {1,2}
%         uiwait(msgbox(WarnStr,'Using clustering tools','warn','modal'));
%         set(handles.Pus_CLU_TOOLS,'TooltipString','Not available')
% end
Stats_TBX_Flag = isstatstbxinstalled;
% Stats_TBX_Flag = false; % Uncomment this line to make tests.
wtbxappdata('set',fig,'Stats_TBX_Flag',Stats_TBX_Flag);
wtbxappdata('set',fig,'Cluster_Tool_Flag',false);
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%=========================================================================%
function hdl_Menus = Install_MENUS(fig,tool_Name)

m_files = wfigmngr('getmenus',fig,'file');
m_close = wfigmngr('getmenus',fig,'close');
cb_close = [mfilename '(''Pus_CloseWin_Callback'',gcbo,[],guidata(gcbo));'];
set(m_close,'Callback',cb_close);

m_load = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Str_Load'), ...
    'Tag','Men_Load','Position',1,'Enable','On');  
m_save = uimenu(m_files,'Label', ...
    getWavMSG('Wavelet:commongui:Str_Save'),'Position',2,'Enable','Off');
m_demo = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Str_Example'), ...
    'Tag','Examples','Position',3,'Separator','Off');
m_imp_wrks = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Lab_Import'), ...
    'Position',4,'Enable','On','Separator','On' ...
    );
m_exp_wrks = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Lab_Export'),'Position',5, ...
    'Enable','Off','Separator','Off'...
    );
m_PART = uimenu(m_files,'Label',getWavMSG('Wavelet:mdw1dRF:Str_Partitions'),...
    'Position',6,'Enable','Off','Separator','On');

m_Load_Sig  = uimenu(m_load, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:Str_Signals'), ...
    'Position',1,'Enable','On',   ...
    'Tag','Load_Sig', ...
    'Callback',  ...
    [mfilename '(''Load_Callback'',gcbo,[],guidata(gcbo));']  ...
    );
uimenu(m_load, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:Str_Decompositions'), ...
    'Position',2,'Enable','On',   ...
    'Tag','Load_Dec', ...    
    'Callback',  ...
    [mfilename '(''Load_Callback'',gcbo,[],guidata(gcbo),''dec'');'] ...
    );
cb_save = ...
    'mdw1dmngr(''Men_save_FUN'',gcbo,[],guidata(gcbo),''SYN_ORI_SIG'');';
m_save_SYN = uimenu(m_save,...
    'Label',getWavMSG('Wavelet:mdw1dRF:SyntSig'),...
    'Position',1,'Enable','Off','Callback',cb_save);
cb_save = ...
    'mdw1dmngr(''Men_save_FUN'',gcbo,[],guidata(gcbo),''SYN_ORI_DEC'');';
m_save_DEC = uimenu(m_save,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Str_Decompositions'),...
    'Position',2,'Enable','On','Callback',cb_save);

tab = char(9);
demoSET = {...
        ['Ex1 : '  tab ' 3 shapes - 3 Periods'  tab]; ...
        ['Ex2 : '  tab ' 5 clusters of 100 signals' tab]; ...
        ['Ex3 : '  tab ' 6 clusters of 50 signals'  tab];   ...
        ['Ex4 : '  tab ' 10 clusters of 10 synthesized signal' tab]; ...
        ['Ex5 : '  tab ' 4 noisy signals (1)'  tab]; ...
        ['Ex6 : '  tab ' 4 noisy signals (2)'  tab]; ...
        ['Ex7 : '  tab ' 4 noisy signals (3)'  tab]; ...
        ['Ex8 : '  tab ' 4 noisy signals (4)'  tab]; ...
        ['Ex9 : '  tab ' 8 noisy signals'  tab]; ...
        ['Ex10 : ' tab ' Real noisy signals (1)' tab]; ...
        ['Ex11 : ' tab ' Real noisy signals (2)'  tab]; ...
        ['Ex12 : ' tab ' Real noisy signals (3)'  tab]; ...
        ['Ex13 : ' tab ' Real noisy signals (4)'  tab]; ...
        ['Ex14 : ' tab ' Real noisy signals (all)'  tab]; ...
        ['Ex15 : ' tab ' 7 clusters of 10 electrical signals'  tab];...
        ['Ex16 : ' tab ' 7 clusters of 100 electrical signals' tab];...
        ['Ex17 : ' tab ' Noisy Woman (rows)' tab]; ...
        ['Ex18 : ' tab ' Noisy Woman (col.)' tab]; ...
        ['Ex19 : ' tab ' Jelly Fish (rows)'  tab]; ...
        ['Ex20 : ' tab ' Jelly Fish (col.)'  tab]; ... 
        ['Ex21 : ' tab ' Thinker (rows)'  tab] ... 
    };

nbDEM = size(demoSET,1);
sepSET = [5,10,15,17,19,21];
for k = 1:nbDEM
    strNUM = int2str(k);
    action = [mfilename '(''demo_FUN'',gcbo,[],guidata(gcbo),' strNUM ');'];
    if find(k==sepSET) , Sep = 'On'; else Sep = 'Off'; end
    uimenu(m_demo,'Label',[demoSET{k,1}],'Separator',Sep,'Callback',action);
end


cb_load_PART = ['partsetmngr(''load_PART'',''' , tool_Name ''',gcbf);'];
m_load_PART = uimenu(m_PART,'Label', ...
    getWavMSG('Wavelet:mdw1dRF:Load_FromDisk')  ,...
    'Position',1,'Enable','On','Callback',cb_load_PART);
cb_load_PART = ['partsetmngr(''load_PART'',''' , tool_Name ''',gcbf,''wrks'');'];
m_imp_PART = uimenu(m_PART,'Label', ...
    getWavMSG('Wavelet:commongui:Lab_Import'),...
    'Position',2,'Enable','On','Callback',cb_load_PART);
cb_clear_PART = ['partsetmngr(''clear_PART'',''' , tool_Name ''',gcbf);'];
m_clear_PART = uimenu(m_PART, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:Clear_Partition') ,...
    'Position',3,'Enable','Off','Separator','On','Callback',cb_clear_PART);

uimenu(m_imp_wrks,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Import_Signals'),...
    'Tag','Import_Sig', ...
    'Callback',  ...    
    [mfilename '(''Load_Callback'',gcbo,[],guidata(gcbo),''sig_wrks'');'] ...
    );
uimenu(m_imp_wrks,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Import_Decompositions'), ...
    'Tag','Import_Dec', ...
    'Callback',  ...        
    [mfilename '(''Load_Callback'',gcbo,[],guidata(gcbo),''dec_wrks'');'] ...
    );

uimenu(m_exp_wrks,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Export_Signals'), ...
    'Tag','Export_Sig', ...    
    'Callback',  ...    
    [mfilename '(''Export_Callback'',gcbo,[],guidata(gcbo),''sig'');'] ...    
    );
uimenu(m_exp_wrks,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Export_Decompositions'), ...
    'Tag','Export_Dec', ...        
    'Callback',  ...    
    [mfilename '(''Export_Callback'',gcbo,[],guidata(gcbo),''dec'');'] ...        
    );

hdl_Menus = struct(...
    'm_files',m_files,'m_close',m_close,'m_Load_Sig',m_Load_Sig,...
    'm_save',m_save,'m_save_SYN',m_save_SYN,'m_save_DEC',m_save_DEC, ...
    'm_demo',m_demo,'m_exp_wrks',m_exp_wrks,'m_PART',m_PART,...
    'm_load_PART',m_load_PART,'m_imp_PART',m_imp_PART, ...
    'm_clear_PART',m_clear_PART);
%--------------------------------------------------------------------------
%=========================================================================%
%                  END Tool Initialization                                %
%=========================================================================%

%=========================================================================%
function Install_HELP_and_CtxtMenu(fig,handles)

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',fig, ...
    getWavMSG('Wavelet:mdw1dRF:HLP_MutiSig1D'),'MULT_ANA_1D');

% Add Help Item.
%----------------
% wfighelp('addHelpItem',fig,...
%     '&Multisignal 1D - Wavelet Decomposition (1)','');

% Add ContextMenus
%-----------------
hdl_WAV = [handles.Txt_Wav,handles.Pop_Wav_Fam,handles.Pop_Wav_Num];
wfighelp('add_ContextMenu',fig,hdl_WAV,'UT_WAVELET');
hdl_EXT = [handles.Txt_Ext_Mode,handles.Pop_Ext_Mode];
wfighelp('add_ContextMenu',fig,hdl_EXT,'EXT_MODE');
%=========================================================================%


%=========================================================================%
%                   Begin Internal Functions                              %
%=========================================================================%
function Init_Pan_SEL_INFO(handles)

% Prepare Pan_SEL_INFO.
%----------------------
hdl_L2A = [...
    handles.Txt_Energy;handles.Edi_Energy; ...
    handles.Txt_PER_A;handles.Edi_PER_A];
pos_L2A = get(hdl_L2A,'Position');
pos_L2A = cat(1,pos_L2A{:});
Edi_D = findobj(handles.Edi_PER_D);
usr_Edi_D = get(Edi_D,'UserData');
[usr_Edi_D,idx] = sort(cat(1,usr_Edi_D{:})); %#ok<ASGLU>
Edi_D = Edi_D(idx);
pos_Edi = get(Edi_D,'Position');
pos_Edi = cat(1,pos_Edi{:});
Txt_D = findobj(handles.Txt_PER_D);
usr_Txt_D = get(Txt_D,'UserData');
[usr_Txt_D,idx] = sort(cat(1,usr_Txt_D{:})); %#ok<ASGLU>
Txt_D = Txt_D(idx);
pos_Txt = get(Txt_D,'Position');
pos_Txt = cat(1,pos_Txt{:});

% Initialize Positions.
%----------------------
pos_L2A_Store = repmat(pos_L2A,[1,1,4]);
pos_Edi_Store = repmat(pos_Edi,[1,1,4]);
pos_Txt_Store = repmat(pos_Txt,[1,1,4]);

% Positions: 1<=level<=3.
%------------------------
dy = 0.1;
pos_L2A_Store(:,2,1)   = pos_L2A_Store(:,2,1)-dy;
pos_Edi_Store(1:3,2,1) = pos_Edi_Store(1:3,2,1)-2*dy;
pos_Txt_Store(1:3,2,1) = pos_Txt_Store(1:3,2,1)-2*dy;

% Positions: 4<=level<=6.
%------------------------
dy = 0.09;
pos_L2A_Store(:,2,2)   = pos_L2A_Store(:,2,2)-dy;
pos_Edi_Store(1:3,2,2) = pos_Edi_Store(1:3,2,2)-2*dy;
pos_Txt_Store(1:3,2,2) = pos_Txt_Store(1:3,2,2)-2*dy;
pos_Edi_Store(4:6,2,2) = pos_Edi_Store(4:6,2,2)-3*dy;
pos_Txt_Store(4:6,2,2) = pos_Txt_Store(4:6,2,2)-3*dy;

% Positions: 7<=level<=9.
%-------------------------
dy = 0.06;
pos_Edi_Store(1:3,2,3) = pos_Edi_Store(1:3,2,3)-dy;
pos_Txt_Store(1:3,2,3) = pos_Txt_Store(1:3,2,3)-dy;
pos_Edi_Store(4:6,2,3) = pos_Edi_Store(4:6,2,3)-2*dy;
pos_Txt_Store(4:6,2,3) = pos_Txt_Store(4:6,2,3)-2*dy;
pos_Edi_Store(7:9,2,3) = pos_Edi_Store(7:9,2,3)-3*dy;
pos_Txt_Store(7:9,2,3) = pos_Txt_Store(7:9,2,3)-3*dy;

% Store handles and Positions.
%-----------------------------
usr = {Edi_D,pos_Edi_Store,Txt_D,pos_Txt_Store,hdl_L2A,pos_L2A_Store};
set(handles.Pan_ENERGY,'UserData',usr);

% Reset FontWeight.
%------------------
set([handles.Txt_PER_A,handles.Txt_PER_D],'FontWeight','bold');
%=========================================================================%
%                                 END Internal Functions                  %
%=========================================================================%
 

%=========================================================================%
%                   Begin External-Internal Functions                     %
%=========================================================================%
function show_Sig_Info(hObject,eventdata,handles,currNum,currSig,nbSIG) %#ok<INUSL>

fig = handles.Current_Fig;
[formatNum,formatPER,formatNum_Ener] = ...
        mdw1dutils('numFORMAT',max(abs(currSig)));
    
[Energy,tab_ENER] = blockdatamngr('get',...
    fig,'data_ORI','Energy','tab_ENER');
decomposeFLAG = ~isempty(Energy);
if nbSIG>1
    [data_ORI,~,data_DorC] = ...
        mdw1dutils('data_INFO_MNGR','get',fig,'ORI','SEL','DorC'); %#ok<NASGU>
    [numSIG,dwtType,sigType] = mdw1dutils('get_Sig_IDENT',fig); %#ok<ASGLU>
    idx_ORI  = unique(numSIG(sigType=='o'));
    idx_DorC = unique(numSIG(sigType=='d' | sigType=='c'));
    if decomposeFLAG
        set(handles.Chk_A_Ener,'Visible','On',...
            'UserData',{currNum,currSig,nbSIG})
        valAPP = get(handles.Chk_A_Ener,'Value');
        % Energy = Energy(idx_ORI);
        boxTAB = tab_ENER(idx_ORI,:);
        level = size(boxTAB,2)-1;
        if valAPP==0 , boxTAB(:,1) = []; end
        if ~isempty(idx_DorC)
            [L2_More,tab_More] = blockdatamngr('get',...
                fig,'data_DorC','Energy','tab_ENER');
            if valAPP==0 , tab_More(:,1) = []; end
            if ~isempty(L2_More)
                % Energy = [Energy ; L2_More(idx_DorC)];
                boxTAB = [boxTAB ; tab_More(idx_DorC,:)];
            end
        end
        nbSig_2 = size(boxTAB,1);
        boxTAB  = fliplr(boxTAB);
        if nbSig_2<2 , boxTAB = repmat(boxTAB,2,1); end
        if valAPP==1
            labels = {['A' int2str(level)]}; 
        else
            labels = {};
        end
        for k = level:-1:1 , labels = [['D' int2str(k)] , labels]; end %#ok<AGROW>
        xlabSTR = getWavMSG('Wavelet:mdw1dRF:Per_Of_Ener');
        ylabSTR = '';
        titleSTR = getWavMSG('Wavelet:mdw1dRF:Wavedec_Energy');
    else
        set(handles.Chk_A_Ener,'Visible','Off')
        currSig = data_ORI.signal(idx_ORI,:);
        boxTAB  = [min(currSig,[],2),mean(currSig,2),max(currSig,[],2)];
        labels ={...
            getWavMSG('Wavelet:mdw1dRF:Str_Minimum'), ...
            getWavMSG('Wavelet:mdw1dRF:Str_Mean'), ...
            getWavMSG('Wavelet:mdw1dRF:Str_Max')};
        xlabSTR = '';
        ylabSTR = '';
        titleSTR = getWavMSG('Wavelet:mdw1dRF:Info_Sel_Data');
    end
    mdw1dmisc('clean',handles,'Pan_SEL_INFO','many_sig')
    axe_Cur = handles.Axe_INFO_VAL;
    delete(allchild(axe_Cur));
    axes(axe_Cur)
    hBox = wboxplot(boxTAB,'labels',labels,'widths',0.65);
    
    set(axe_Cur,'XGrid','On','YGrid','Off')
    if decomposeFLAG
        toolCOL = mdw1dutils('colors');
        if valAPP==1
            set(hBox(5,1:end-1),'Color',0.8*toolCOL.det)       
            set(hBox(5,end),'Color',toolCOL.app)
        else
            set(hBox(5,:),'Color',0.8*toolCOL.det)   
        end
    else
        colBOX  = [0.7 0.7 0.2];
        set(hBox(5,:),'Color',colBOX)
    end
    xlabel(xlabSTR,'HorizontalAlignment','Right','Parent',axe_Cur)
    ylabel(ylabSTR,'Parent',axe_Cur);
    set(handles.Edi_TIT_PAN_INFO,'String',titleSTR);
else
    set(handles.Chk_A_Ener,'Visible','Off')
    mean_VAL = mean(currSig);
    max_VAL  = max(currSig);
    min_VAL  = min(currSig);
    [numSIG,dwtType,sigType,levVAL] = mdw1dutils('get_Sig_IDENT',fig,currNum);
    mdw1dmisc('clean',handles,'Pan_SEL_INFO','one_sig')
    if isequal(numSIG,currNum)
        titleSTR = getWavMSG('Wavelet:mdw1dRF:Info_On_Selection',currNum);
    else
        titleSTR = ...
            getWavMSG('Wavelet:mdw1dRF:Selection_Signal',currNum,numSIG);
    end
    set(handles.Edi_Min,'String',num2str(min_VAL,formatNum))
    set(handles.Edi_Mean,'String',num2str(mean_VAL,formatNum))
    set(handles.Edi_Max,'String',num2str(max_VAL,formatNum))
    set(handles.Edi_TIT_PAN_INFO,'String',titleSTR);
    switch sigType
        case 'o'
            if isempty(Energy) , return; end
            Energy = Energy(numSIG); tab_ENER = tab_ENER(numSIG,:);
            pan_Title = getWavMSG('Wavelet:mdw1dRF:Ener_EnerRatS',numSIG);

        case {'d','c'}
            [Energy,tab_ENER] = blockdatamngr('get',...
                fig,'data_DorC','Energy','tab_ENER');
            Energy = Energy(numSIG); tab_ENER = tab_ENER(numSIG,:);
            pan_Title = getWavMSG('Wavelet:mdw1dRF:Ener_EnerRatDS',numSIG);

        case 'r'
            dec_ORI  = blockdatamngr('get',fig,'data_ORI','dwtDEC');
            dec_DorC = blockdatamngr('get',fig,'data_DorC','dwtDEC');
            dec_ORI.ca = dec_ORI.ca - dec_DorC.ca;
            for k =1:length(dec_ORI.level)
                dec_ORI.cd{k} = dec_ORI.cd{k}-dec_DorC.cd{k};
            end
            [Energy,tab_ENER] = wdecenergy(dec_ORI,'cfs',numSIG);
            pan_Title = getWavMSG('Wavelet:mdw1dRF:Ener_EnerRatRS',numSIG);
    end
    set(handles.Pan_ENERGY,'Title',formatPanTitle(pan_Title));
    
    hdl_A = handles.Edi_PER_A;
    hdl_PER_D = handles.Edi_PER_D;
    nb_DET = size(tab_ENER,2)-1;
    hdl_D = zeros(1,nb_DET);
    for k = 1:nb_DET , hdl_D(k) = findobj(hdl_PER_D,'UserData',k); end
    set(handles.Edi_Energy,'String',num2str(Energy,formatNum_Ener))
    set(hdl_A,'String',num2str(tab_ENER(1),formatPER))
    for k = 1:nb_DET
        %-------------------------------------------------------------
        % Direct Text Dj order (Uncomment if YES).
        % set(hdl_D(k),'String',num2str(tab_ENER(end-k+1),formatPER));
        %-------------------------------------------------------------
        % Reverse Text Dj order (Comment if NOT).
        set(hdl_D(k),'String',num2str(tab_ENER(k+1),formatPER));
    end
    set([hdl_A,hdl_D],'ForegroundColor','k');
    if isequal(lower(dwtType),'d')
        txt = findobj(handles.Txt_PER_D);
        detCOL = get(txt(1),'ForegroundColor');
        %-------------------------------------------------------------
        % Direct Text Dj order (Uncomment if YES).
        % set(hdl_D(levVAL),'ForegroundColor',detCOL);
        %-------------------------------------------------------------
        % Reverse Text Dj order (Comment if NOT).
        set(hdl_D(end-levVAL+1),'ForegroundColor',detCOL);
    elseif isequal(lower(dwtType),'a') && levVAL==nb_DET
        appCOL = mdw1dutils('colors','app');
        set(hdl_A,'ForegroundColor',appCOL);
    end
end
%--------------------------------------------------------------------------
function Chk_A_Ener_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

usr = get(hObject,'UserData'); % usr = {currNum,currSig,nbSIG};
show_Sig_Info(hObject,[],handles,usr{:})
%--------------------------------------------------------------------------
function set_Pus_CLU_TOOLS(handles)

fig = handles.output;
Cluster_Tool_Flag = wtbxappdata('get',fig,'Cluster_Tool_Flag');
if Cluster_Tool_Flag , enaCLU = 'Off'; else enaCLU = 'On'; end
set(handles.Pus_CLU_TOOLS,'Enable',enaCLU);
%--------------------------------------------------------------------------
function S = formatPanTitle(S)

S = ['   ' S '   .'];
%--------------------------------------------------------------------------
%=========================================================================%
%                     END External-Internal Functions                     %
%=========================================================================%


%=========================================================================%
%                      BEGIN Demo Utilities                               %
%                      ---------------------                              %
%=========================================================================%
function closeDEMO(hFig,eventdata,handles,varargin) %#ok<VANUS,INUSD,DEFNU>

close(hFig);
%----------------------------------------------------------
function demoPROC(hFig,eventdata,handles,varargin) %#ok<INUSL,DEFNU>

handles = guidata(hFig);
numDEM  = varargin{1};
demo_FUN(hFig,eventdata,handles,numDEM);
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%




