function varargout = wmuldentool(varargin)
%WMULDENTOOL Wavelet Multivariate Denoising GUI.
%   VARARGOUT = WMULDENTOOL(VARARGIN)

% Last Modified by GUIDE v2.5 04-Sep-2006 13:21:29
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2005.
%   Last Revision: 21-Jul-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $ $Date: 2013/08/23 23:46:08 $  

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wmuldentool_OpeningFcn, ...
                   'gui_OutputFcn',  @wmuldentool_OutputFcn, ...
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
% --- Executes just before wmuldentool is made visible.                   %
%*************************************************************************%
function wmuldentool_OpeningFcn(hObject,eventdata,handles)
% This function has no output args, see OutputFcn.

% Choose default command line output for wmuldentool
handles.output = hObject;

% Update handles structure
guidata(hObject,handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manually in the automatic generated code  %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles);
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%

%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = wmuldentool_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
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
function Pus_CloseWin_Callback(hObject,eventdata,handles) %#ok<DEFNU,INUSL>

hFig = handles.output;
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
if isequal(lower(ena_Save),'on')
    status = wwaitans({hFig,getWavMSG('Wavelet:divGUIRF:WM_Pus_MUL_DEN')},...
        getWavMSG('Wavelet:mdw1dRF:Save_Den_Sigs_QUEST'),2,'Cancel');
    switch status
        case -1 , return;
        case  1
            wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));
            save_FUN(m_save,eventdata,handles)
            wwaiting('off',hFig);
        otherwise
    end
end
close(gcbf)
%--------------------------------------------------------------------------
function Load_Sig_Callback(hObject,eventdata,handles,varargin) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing and loading file.
%--------------------------
if nargin<4     % DIRECT LOAD
    [filename,pathname] = uigetfile( ...
       {'*.mat',getWavMSG('Wavelet:moreMSGRF:LoadSave_MultiSig')'; ...
       '*.*', getWavMSG('Wavelet:moreMSGRF:Save_DLG_ALL')}, ...
       getWavMSG('Wavelet:mdw1dRF:LoadSigs'));
    if ~isequal(filename,0) && ~isequal(pathname,0)
        fullName = fullfile(pathname,filename);
    else
        return
    end
    okFile = true;
    
elseif isequal(varargin{1},'wrks') % LOAD from WORKSPACE
    [sig_ORI,sig_Name,ok] = wtbximport('wmul');
    if ~ok ,  return; end
    filename = sig_Name;
    fullName = '';
    varSize = size(sig_ORI);
    okFile = false;
    
else            % DEMO LOAD
    filename = [varargin{1},'.mat'];
    fullName = filename;
    okFile = true;    
end

try
    err = 0;
    if okFile
        dataInfo = whos('-file',fullName);
        dataInfoCell = struct2cell(dataInfo);
        idx = find(strcmp(dataInfoCell(1,:),'x'));
        if isempty(idx)
            idx = find(strcmp(dataInfoCell(1,:),'X'));
            if isempty(idx) , idx = 1; end
        end
        varNam  = dataInfoCell{1,idx};
        varSize = dataInfoCell{2,idx};
        data    = load(fullName,'-mat');
        sig_ORI = data.(varNam);
    end
    [nbSIG,direct] = min(varSize);
    if direct==1 , sig_ORI = sig_ORI'; end
    lenSIG = size(sig_ORI,1);
catch %#ok<*CTCH>
    err = 1;
end
if err, return; end

data_INFO = struct(...
    'sig_ORI',sig_ORI,'dec_ORI',[],     ...
    'sig_DEN',[],'dec_DEN',[],          ...
    'sig_ORI_ADAP',[],'dec_ORI_ADAP',[],...
    'sig_DEN_ADAP',[],'dec_DEN_ADAP',[] ...
    );
wtbxappdata('set',hFig,'data_INFO',data_INFO);

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
clean_TOOL(handles,'load',nbSIG)

% Set Axes.
%----------
Initialize_Axes(handles,nbSIG);
axe_SIG   = handles.Axe_SIG;
axe_CFS   = handles.Axe_CFS;
axe_DEN   = handles.Axe_DEN;
lin_SIG   = NaN(1,nbSIG);
lin_DEN   = NaN(1,nbSIG);
lin_SIG_A = NaN(1,nbSIG);
lin_DEN_A = NaN(1,nbSIG);

% Plots Signals.
%---------------
maxSIG = max(sig_ORI,[],1);
minSIG = min(sig_ORI,[],1);
maxSIG = maxSIG + 0.01*abs(maxSIG);
minSIG = minSIG - 0.01*abs(minSIG);
Ylim   = [minSIG;maxSIG]';
[sigColor,denColor] = wtbutils('colors','wmden');
for k = 1:nbSIG
    axeCur = axe_SIG(k);
    set(axeCur,'NextPlot','add');
    lin_SIG(k) = plot(sig_ORI(:,k),'Color',sigColor,'Parent',axeCur);
    txtinaxe('create',int2str(k),axeCur,'l','on','bold',12,30); 
    lin_DEN(k) = plot(sig_ORI(:,k),...
        'Color',denColor,'Visible','Off','LineWidth',2,'Parent',axeCur);
    set(axe_SIG(k),'YLim',Ylim(k,:));    
end
set([axe_SIG,axe_CFS,axe_DEN],'XLim',[1,lenSIG]);
set(axe_SIG,'XtickMode','auto','YtickMode','auto');
title(getWavMSG('Wavelet:mdw1dRF:Str_Signals'),...
    'Visible','On','Parent',axe_SIG(1))
hdl_INFO = struct(...
    'lin_SIG',lin_SIG,'lin_DEN',lin_DEN,...
    'lin_SIG_A',lin_SIG_A,'lin_DEN_A',lin_DEN_A);
wtbxappdata('set',hFig,'hdl_INFO',hdl_INFO);
axe_IND = [];
axe_CMD = [axe_SIG,axe_CFS,axe_DEN];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','','real');

% Setting GUI values and Analysis parameters.
%--------------------------------------------
max_lev_anal = 8;
levm   = wmaxlev(lenSIG,'haar');
levmax = min(levm,max_lev_anal);
[curlev,curlevMAX] = cbanapar('get',hFig,'lev','levmax');
if levmax<curlevMAX
    cbanapar('set',hFig, ...
        'lev',{'String',int2str((1:levmax)'),'Value',min(levmax,curlev)} ...
        );
end
n_s = [filename '  (' , int2str(lenSIG) 'x' int2str(nbSIG) ')'];
set(handles.Edi_Data_NS,'String',n_s);                
set(handles.Pus_Decompose,'Enable','On')

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pus_Decompose_Callback(hObject,eventdata,handles) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Wavelet decomposition Parameters.
%----------------------------------
[wname,level] = cbanapar('get',hFig,'wav','lev');
popMode  = handles.Pop_Ext_Mode;
lst = get(popMode,'String');
extMode = lst{get(popMode,'Value')};

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
clean_TOOL(handles,'beg_dec',level)

% Wavelet decomposition of columns of sig_ORI.
%--------------------------------------------
data_INFO = wtbxappdata('get',hFig,'data_INFO');
sig_ORI   = data_INFO.sig_ORI;
[data_INFO.dec_ORI,PCA_Params] = ...
    wmulden('estimate',sig_ORI,level,wname,'mode',extMode);
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
pc = PCA_Params.NEST{1};
sig_ORI_ADAP = sig_ORI*pc;
data_INFO.dec_ORI_ADAP = ...
    mdwtdec('col',sig_ORI_ADAP,level,wname,'mode',extMode);
data_INFO.sig_ORI_ADAP = sig_ORI_ADAP;
wtbxappdata('set',hFig,'data_INFO',data_INFO);
wtbxappdata('set',hFig,'PCA_Params',PCA_Params);
%.........................................................................

% Plots Signals in Adapted Basis.
%--------------------------------
[lenSIG,nbSIG] = size(sig_ORI);
axe_SIG = handles.Axe_SIG_ADAP;
axe_CFS = handles.Axe_CFS_ADAP;
axe_DEN = handles.Axe_DEN_ADAP;
hdl_INFO = wtbxappdata('get',hFig,'hdl_INFO');
lin_SIG = hdl_INFO.lin_SIG_A;
lin_DEN = hdl_INFO.lin_DEN_A;
[sigColor,denColor] = wtbutils('colors','wmden');
if ishandle(lin_SIG(1))
    for k = 1:nbSIG
        set([lin_SIG(k),lin_DEN(k)],'YData',sig_ORI_ADAP(:,k));
    end
else
    for k = 1:nbSIG
        axeCur = axe_SIG(k);
        set(axeCur,'NextPlot','add')
        lin_SIG(k) = ...
            plot(sig_ORI_ADAP(:,k),'Color',sigColor,'Parent',axeCur);
        lin_DEN(k) = plot(sig_ORI_ADAP(:,k),...
            'Color',denColor,'Visible','Off','LineWidth',2,'Parent',axeCur);
    end
end
set([axe_SIG,axe_CFS,axe_DEN],'XLim',[1,lenSIG]);
set(axe_SIG,'XtickMode','auto','YtickMode','auto');
title(getWavMSG('Wavelet:mdw1dRF:Str_Signals'),...
    'Visible','On','Parent',axe_SIG(1))
hdl_INFO.lin_SIG_A = lin_SIG;
hdl_INFO.lin_DEN_A = lin_DEN;
wtbxappdata('set',hFig,'hdl_INFO',hdl_INFO);
%.........................................................................
plot_Decomposition(handles,'ORI','ADAP');
plot_Decomposition(handles,'ORI','ORI');
%.........................................................................
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% End waiting.
%-------------
clean_TOOL(handles,'end_dec')
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Rad_THR_Callback(hObject,eventdata,handles) %#ok<INUSL>

Rad_SOFT = handles.Rad_SOFT;
Rad_HARD = handles.Rad_HARD;
if isequal(hObject,Rad_SOFT)
    set(Rad_SOFT,'Value',1,'UserData',1);
    set(Rad_HARD,'Value',0,'UserData',0);
else
    set(Rad_SOFT,'Value',0,'UserData',0);
    set(Rad_HARD,'Value',1,'UserData',1);    
end
%--------------------------------------------------------------------------
function Chk_PCA_Callback(hObject,eventdata,handles,val) %#ok<INUSL>

if nargin<4
    val = get(handles.Chk_PCA,'Value');
else
    set(handles.Chk_PCA,'Value',val);
end
if val==1 , ena_VAL = 'On'; else ena_VAL = 'Off'; end
UIC_to_Ena = [...
    handles.Pus_More_PCA, ...
    handles.Txt_NPC_APP,handles.Pop_NPC_APP, ...
    handles.Txt_NPC_FIN,handles.Pop_NPC_FIN ...        
    ];
set(UIC_to_Ena,'Enable',ena_VAL)
%--------------------------------------------------------------------------
function Pus_Denoise_Callback(hObject,eventdata,handles)

% Get figure handle.
%-------------------
hFig = handles.output;

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));

% Get Wavelet Decomposition.
%---------------------------
data_INFO = wtbxappdata('get',hFig,'data_INFO');
dec = data_INFO.dec_ORI;

% Get Denoising Parameters.
%--------------------------
val_typeTHR = get(handles.Pop_THR_Meth,'Value');
val_S_or_H  = get(handles.Rad_SOFT,'Value');
PCA_is_ON = logical(get(handles.Chk_PCA,'Value'));
switch val_typeTHR
    case 1 , typeTHR = 'sqtwolog';
    case 2 , typeTHR = 'minimaxi';
    case 3 , typeTHR = 'rigrsure';
    case 4 , typeTHR = 'heursure';
    %---------------------------------------------------        
    % sliBMVal = 1 ==> 5;
    % switch meth
    %   case 'penalhi' , alfa = 5*(3*sliBMVal+1)/8;
    %   case 'penalme' , alfa = (sliBMVal+5)/4;
    %   case 'penallo' , alfa = (sliBMVal+3)/4;
    % end
    % case 'penal' , alpha = scal;  typeNOI = 'sln';
    %---------------------------------------------------        
    case 5 , typeTHR = 'penalhi';
    case 6 , typeTHR = 'penalme';
    case 7 , typeTHR = 'penallo';
    otherwise
        error(getWavMSG('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
switch val_S_or_H
    case 0 , S_or_H = 'h';
    case 1 , S_or_H = 's';
end

% Denoising and Storing
%----------------------
PCA_Params = wtbxappdata('get',hObject,'PCA_Params');
if PCA_is_ON
    npc_app = get(handles.Pop_NPC_APP,'Value')-1;
    npc_fin = get(handles.Pop_NPC_FIN,'Value')-1;   
else
    npc_app = Inf; npc_fin = Inf;
end
[x_den,~,~,dec_DEN,PCA_Params,DEN_Params] = ...
    wmulden('exec',dec,npc_app,npc_fin,PCA_Params,typeTHR,S_or_H);
wtbxappdata('set',hFig,'PCA_Params',PCA_Params);
wtbxappdata('set',hFig,'DEN_Params',DEN_Params);
[lenSIG,nbSIG] = size(x_den);
data_INFO.sig_DEN = x_den;
data_INFO.dec_DEN = dec_DEN;
sig_DEN_ADAP = x_den*PCA_Params.NEST{1};
data_INFO.dec_DEN_ADAP = ...
    mdwtdec('col',sig_DEN_ADAP,dec.level,dec.wname,'mode',dec.dwtEXTM);
data_INFO.sig_DEN_ADAP = sig_DEN_ADAP;
wtbxappdata('set',hFig,'data_INFO',data_INFO);

% Plot Denoised Signals.
%-----------------------
hdl_INFO = wtbxappdata('get',hFig,'hdl_INFO');
lin_DEN = hdl_INFO.lin_DEN;
[~,denColor] = wtbutils('colors','wmden');
dynvtool('get',hFig,0);
axe_SIG = handles.Axe_SIG;
axe_CFS = handles.Axe_CFS;
axe_DEN = handles.Axe_DEN;
for k = 1:nbSIG
    axeCur = axe_DEN(k);
    plot(x_den(:,k),'Color',denColor,'Parent',axeCur);
    set(lin_DEN(k),'YData',x_den(:,k));
    set(axeCur,'XLim',[1,lenSIG],'XtickMode','auto','YtickMode','auto');
end
title(getWavMSG('Wavelet:mdw1dRF:DenoSig'),...
    'Visible','On','Parent',axe_DEN(1))

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Plot Adapted Basis Denoised Signals.
%--------------------------------------
lin_DEN = hdl_INFO.lin_DEN_A;
axe_DEN_A = handles.Axe_DEN_ADAP;
for k = 1:nbSIG
    axeCur = axe_DEN_A(k);
    plot(sig_DEN_ADAP(:,k),'Color',denColor,'Parent',axeCur);
    set(lin_DEN(k),'YData',sig_DEN_ADAP(:,k));
end
set(axe_DEN_A,'XLim',[1,lenSIG],'XtickMode','auto','YtickMode','auto');
title(getWavMSG('Wavelet:mdw1dRF:DenoSig'),...
    'Visible','On','Parent',axe_DEN_A(1))
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
axe_IND = [];
axe_CMD = [axe_SIG,axe_CFS,axe_DEN];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','','real');
hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
UIC_Ena_ON = [...
    hdl_Menus.m_save,hdl_Menus.m_exp_wrks, ...
    handles.Chk_Show_DEN,handles.Pus_Residuals, ...
    handles.Rad_CFS_ORI,handles.Rad_CFS_DEN ...
    ];
set(UIC_Ena_ON,'Enable','On');
Chk_Show_DEN_Callback(handles.Chk_Show_DEN,eventdata,handles)

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pus_Residuals_Callback(hObject,eventdata,handles,state) %#ok<DEFNU,INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Get UIC and MEN to Enable or to Deseable.
%------------------------------------------
utanaparHDL = findobj(handles.Pan_DAT_WAV,'Type','uicontrol');
utanaparHDL = setdiff(utanaparHDL,handles.Edi_Data_NS);
Pan_RES = handles.Pan_RESIDUALS;
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
OBJ_Ena_CHANGE = [...    
    hdl_Menus.m_load,hdl_Menus.m_demo, ...
    handles.Pus_Decompose,handles.Pus_More_ADAP,...
    handles.Rad_CFS_ORI,handles.Rad_CFS_DEN, ...
    handles.Txt_CFS_LEV,handles.Pop_CFS_LEV, ...    
    handles.Pus_CloseWin ...
    ];

% Set Residuals on/off.
%----------------------
axe_SIG = handles.Axe_SIG;
axe_CFS = handles.Axe_CFS;
axe_DEN = handles.Axe_DEN;
switch state
    case 0
        obj_VIS = [handles.Pan_DEN_PARAM,...
            handles.Rad_BASE_ORI,handles.Rad_BASE_ADAP, ...
            handles.Pus_More_ADAP, ...           
            handles.Pus_Residuals,handles.Pus_Denoise,...
            handles.Chk_Show_DEN,...
            handles.Rad_CFS_ORI,handles.Rad_CFS_DEN, ...
            handles.Txt_CFS_LEV,handles.Pop_CFS_LEV];
        visBASE = get(handles.Pan_BASE_ORI,'Visible');
        if strcmpi(visBASE,'on')
            plusVIS = [handles.Pan_BASE_ORI,handles.Pan_BASE_ADAP];
        else
            plusVIS = [handles.Pan_BASE_ADAP,handles.Pan_BASE_ORI];
        end
        obj_VIS = [obj_VIS , plusVIS];
        vis_IN_AXES = findobj([axe_SIG,axe_CFS,axe_DEN],'Visible','On');
        obj_VIS = [vis_IN_AXES;obj_VIS(:)];
        
    case 1
        RES_Params = wtbxappdata('get',hFig,'RES_Params');
end

switch state
    case 0
        OBJ_ena_VAL = 'Off';
        data_INFO = wtbxappdata('get',hFig,'data_INFO');
        sig_ORI = data_INFO.sig_ORI;
        sig_DEN = data_INFO.sig_DEN;
        sig_RES = sig_ORI-sig_DEN;
        [lenSIG,nbSIG] = size(sig_ORI);
        
        set(obj_VIS,'Visible','Off');
        dynvtool('get',hFig,0);
        set([Pan_RES,handles.Pan_RES_STATS],'Visible','On');
        set(handles.Pus_Close_RES,'Visible','On');
        set(handles.Pop_SIG_NUM,'String',int2str((1:nbSIG)'),'Value',1);
        Pop_SIG_NUM_Callback(handles.Pop_SIG_NUM,eventdata,handles,'init');

        % Displaying Residuals, Histograms & Cumulated Histograms.
        %---------------------------------------------------------
        nb_bins = 50;
        resColor = wtbutils('colors','res');
        [pos_axe_RES,pos_axe_HIS,pos_axe_CUM] = getPosAxes('res',hFig,nbSIG);
        axe_RES = zeros(1,nbSIG);
        axe_HIS = zeros(1,nbSIG);
        axe_CUM = zeros(1,nbSIG);
        txtAxeNum = zeros(1,nbSIG);
        for k = 1:nbSIG
            axe_RES(k) = axes('Parent',Pan_RES,'Position',pos_axe_RES(k,:)); %#ok<*LAXES>
            maxi = max(abs(sig_RES(:,k)));
            plot(sig_RES(:,k),'Color',resColor,'Parent',axe_RES(k))
            yLIM = 1.05*[-maxi,maxi];
            set(axe_RES(k),'YLim',yLIM,'YtickMode','auto');
            txtAxeNum(k) = txtinaxe('create',int2str(k),axe_RES(k), ...
                'l','on','bold',12,30);
            his       = wgethist(sig_RES(:,k),nb_bins);
            his(2,:)  = his(2,:)/lenSIG;
            axe_HIS(k) = axes('Parent',Pan_RES,'Position',pos_axe_HIS(k,:));
            wplothis(axe_HIS(k),his,resColor);
            for i=6:4:length(his(2,:));
                his(2,i)   = his(2,i)+his(2,i-4);
                his(2,i+1) = his(2,i);
            end
            axe_CUM(k) = axes('Parent',Pan_RES,'Position',pos_axe_CUM(k,:));
            wplothis(axe_CUM(k),[his(1,:);his(2,:)],resColor);
        end
        set(txtAxeNum(1),'Color','r')        
        set(axe_RES,'XLim',[1,lenSIG],'XtickMode','auto','YtickMode','auto');
        title(getWavMSG('Wavelet:commongui:Str_Residuals'),...
            'Visible','on','Tag','Residuals','Parent',axe_RES(1));
        title(getWavMSG('Wavelet:commongui:Str_HIST'),...
            'Visible','on','Tag','Histograms','Parent',axe_HIS(1));
        title(getWavMSG('Wavelet:commongui:Str_CumHistS'),...
            'Visible','on','Tag','CumHistograms','Parent',axe_CUM(1));
        
        RES_Params = struct('obj_VIS',obj_VIS,'axe_RES',axe_RES,...
            'axe_HIS',axe_HIS,'axe_CUM',axe_CUM,'txtAxeNum',txtAxeNum);
        wtbxappdata('set',hFig,'RES_Params',RES_Params);
        dynvtool('init',hFig,[],axe_RES,[],[1 0],'','','','real');
        
    case 1
        OBJ_ena_VAL = 'On';
        set([handles.Pan_RES_STATS,handles.Pan_RESIDUALS],'Visible','Off');
        delete([RES_Params.axe_RES,RES_Params.axe_HIS,RES_Params.axe_CUM]);
        axe_CMD = [axe_SIG,axe_CFS,axe_DEN];
        dynvtool('init',hFig,[],axe_CMD,[],[1 0],'','','','real');
        pause(0.2)
        set(RES_Params.obj_VIS(1:end-1),'Visible','On');
end
set(OBJ_Ena_CHANGE,'Enable',OBJ_ena_VAL)
set(utanaparHDL,'Enable',OBJ_ena_VAL)
%--------------------------------------------------------------------------
function Chk_Show_DEN_Callback(hObject,eventdata,handles,val) %#ok<INUSL>

if nargin<4
    val = get(hObject,'Value');
else
    set(hObject,'Value',val);
end
hdl_INFO = wtbxappdata('get',hObject,'hdl_INFO');
lin_DEN = [hdl_INFO.lin_DEN,hdl_INFO.lin_DEN_A];
lin_DEN = lin_DEN(ishandle(lin_DEN));
if val==1 , vis_VAL = 'On'; else vis_VAL = 'Off'; end
set(lin_DEN,'Visible',vis_VAL)
%--------------------------------------------------------------------------
function Pop_SIG_NUM_Callback(hObject,eventdata,handles,flag) %#ok<INUSD,INUSL>

errtol    = 1.0E-10;
nb_bins   = 75;
numSIG    = get(hObject,'Value');
data_INFO = wtbxappdata('get',hObject,'data_INFO');
sig_ORI = data_INFO.sig_ORI;
sig_DEN = data_INFO.sig_DEN;
sig_RES = sig_ORI-sig_DEN;
resVal    = sig_RES(:,numSIG);
mean_val  = mean(resVal);
max_val   = max(resVal);
min_val   = min(resVal);
range_val = max_val-min_val;
std_val   = std(resVal);
med_val   = median(resVal);
medDev_val = median(abs(resVal(:)-med_val));
if abs(medDev_val)<errtol , medDev_val = 0; end
meanDev_val = mean(abs(resVal(:)-mean_val));
if abs(meanDev_val)<errtol , meanDev_val = 0; end
his       = wgethist(resVal,nb_bins);
[~,imod] = max(his(2,:));
mode_val  = (his(1,imod)+his(1,imod+1))/2;

formNUM = '%7.4f';
set(handles.Edi_MEAN_DEV,'String',num2str(meanDev_val,formNUM));
set(handles.Edi_MAX,'String',num2str(max_val,formNUM));
set(handles.Edi_MIN,'String',num2str(min_val,formNUM));
set(handles.Edi_MODE,'String',num2str(mode_val,formNUM));
set(handles.Edi_MED,'String',num2str(med_val,formNUM));
set(handles.Edi_RANGE,'String',num2str(range_val,formNUM));
set(handles.Edi_STD,'String',num2str(std_val,formNUM));
set(handles.Edi_MED_DEV,'String',num2str(medDev_val,formNUM));
set(handles.Edi_MEAN,'String',num2str(mean_val,formNUM))
if nargin<4
    RES_Params = wtbxappdata('get',hObject,'RES_Params');
    txtAxeNum = RES_Params.txtAxeNum;
    set(txtAxeNum,'Color','k');
    set(txtAxeNum(numSIG),'Color','r');
end
%--------------------------------------------------------------------------
function Rad_BASIS_Callback(hObject,eventdata,handles,idx) %#ok<INUSL>

rad = [handles.Rad_BASE_ORI , handles.Rad_BASE_ADAP];
val = zeros(1,2);
old_VAL = get(rad(1),'UserData');
if nargin<4 , idx = 1; old_VAL = NaN; end
val(idx) = 1;
for k = 1:2 , set(rad(k),'Value',val(k)); end
if isequal(old_VAL,val) , return; end

set(rad,'UserData',val);
switch idx
    case 1 , Pan_ON = handles.Pan_BASE_ORI; Pan_OF = handles.Pan_BASE_ADAP;
    case 2 , Pan_OF = handles.Pan_BASE_ORI; Pan_ON = handles.Pan_BASE_ADAP;
end
usr = get(handles.Pop_CFS_LEV,'UserData');
set(Pan_OF,'Visible','Off');
set(Pan_ON,'Visible','On')
if ~isempty(usr) , set(handles.Pop_CFS_LEV,'Value',usr(idx)); end
%--------------------------------------------------------------------------
function Rad_CFS_Callback(hObject,eventdata,handles,typeCALL) %#ok<INUSL>

rad = [handles.Rad_CFS_ORI , handles.Rad_CFS_DEN];
switch lower(typeCALL)
    case {'ori','ini'} , val = [1 0];
    case 'den' ,         val = [0 1];      
end
for k = 1:2 , set(rad(k),'Value',val(k)); end
old_VAL = get(rad(1),'UserData');
set(rad,'UserData',val);
if isequal(old_VAL,val) || isequal(typeCALL,'ini'), return; end

plot_Decomposition(handles,typeCALL)
%--------------------------------------------------------------------------
function Pus_More_PCA_Callback(hObject,eventdata,handles) %#ok<DEFNU,INUSL>

typeCALL = get(hObject,'Type');
switch typeCALL
    case 'figure'
        fig     = hObject;
        hObject = get(fig,'UserData');
    otherwise
        fig = get(hObject,'UserData');
end
closeWIN = ~isempty(fig);
if closeWIN
    if ishandle(fig) , delete(fig); end
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_More_PCA');
    fig = [];
else
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_More_PCA_Close');
    PCA_Params = wtbxappdata('get',hObject,'PCA_Params');
    fig = wmuldentoolmopc(hObject,PCA_Params);
end
if ishandle(hObject)
    set(hObject,'String',strPUS,'UserData',fig);
else
    WfigPROP = handles.WfigPROP;
    try delete(WfigPROP.FigChild); end %#ok<*TRYNC>
end
%--------------------------------------------------------------------------
function Pus_More_ADAP_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

typeCALL = get(hObject,'Type');
switch typeCALL
    case 'figure'
        fig     = hObject;
        hObject = get(fig,'UserData');
    otherwise
        fig = get(hObject,'UserData');
end
closeWIN = ~isempty(fig);
if closeWIN
    if ishandle(fig) , delete(fig); end
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_More_Nois_ADAP');
    fig = [];
else
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_More_Nois_ADAP_Close');
    PCA_Params = wtbxappdata('get',hObject,'PCA_Params');
    fig = wmuldentoolmonab(hObject,PCA_Params.NEST);
end
if ishandle(hObject)
    set(hObject,'String',strPUS,'UserData',fig);
else
    WfigPROP = handles.WfigPROP;
    try delete(WfigPROP.FigChild); end
end
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%=========================================================================%
function demo_FUN(hObject,eventdata,handles,numDEM)

switch numDEM
    case {1,2}
        fname = 'ex1mwden'; 
        wname = 'sym4';
        if numDEM==1 ,level = 5; else level = 3; end
        npc_app = 4; npc_fin = 4;
        
    case {3,4}
        fname = 'ex2mwden'; 
        wname = 'sym4';
        if numDEM==3 ,level = 5; else level = 3; end
        npc_app = 4; npc_fin = 4;
        
    case {5,6,7,8}
        fname = 'ex3mwden'; 
        wname = 'sym4';
        if numDEM==8 ,level = 5; else level = 3; end
        switch numDEM
            case 5 , npc_app = 4; npc_fin = 4;
            case 6 , npc_app = 2; npc_fin = 4;
            case 7 , npc_app = 2; npc_fin = 2;
            case 8 , npc_app = 2; npc_fin = 2;
        end
        
    case {9,10,11}
        fname = 'ex4mwden'; 
        wname = 'sym4'; level = 3;
        switch numDEM
            case 9  , npc_app = 4; npc_fin = 4; 
            case 10 , npc_app = 2; npc_fin = 4; 
            case 11 , npc_app = 2; npc_fin = 2;
        end

    case {12,13,14,15}
        wname = 'sym4'; level = 5; npc_app = 1; npc_fin = 1;
        switch numDEM
            case 12 , fname = 'ex1mdr'; 
            case 13 , fname = 'ex2mdr'; 
            case 14 , fname = 'ex3mdr'; 
            case 15 , fname = 'ex4mdr'; 
        end

    case {16,17,18,19,20}
        fname = 'ex5mwden';         
        wname = 'sym4'; level = 5;
        switch numDEM
            case 16 , npc_app = 8; npc_fin = 8;
            case 17 , npc_app = 6; npc_fin = 6;
            case 18 , npc_app = 4; npc_fin = 4;
            case 19 , npc_app = 2; npc_fin = 2;
            case 20 , npc_app = 5; npc_fin = 5;
        end
end

% Get figure handle.
%-------------------
hFig = handles.output;

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));

% Loading Signals and Setting GUI.
%--------------------------------
Load_Sig_Callback(hObject,eventdata,handles,fname);

% Setting Analysis and Denoising parameters, Decomposition and Denoising.
%-----------------------------------------------------------------------
cbanapar('set',hFig,'wav',wname,'lev',level);
set(handles.Pop_THR_Meth,'Value',1);
Rad_THR_Callback(handles.Rad_SOFT,eventdata,handles)
Pus_Decompose_Callback(handles.Pus_Decompose,eventdata,handles);
Chk_PCA_Callback(hFig,eventdata,handles,1)
set(handles.Pop_NPC_APP,'Value',npc_app+1);
set(handles.Pop_NPC_FIN,'Value',npc_fin+1);
set(handles.Chk_Show_DEN,'Value',1)
Pus_Denoise_Callback(handles.Pus_Denoise,eventdata,handles);
%-------------------------------------------------------------------------%
function save_FUN(hObject,eventdata,handles,typeSAV) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing file.
%--------------
if nargin<4
    Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
    Str_No  = getWavMSG('Wavelet:commongui:Str_No');
    ButtonName = questdlg(getWavMSG('Wavelet:mdw1dRF:Save_Param_Sigs_QUEST'), ...
                       getWavMSG('Wavelet:mdw1dRF:Save_Signals'),...
                       Str_Yes,Str_No,Str_No);
     if isequal(ButtonName,Str_Yes) , typeSAV = 1; else typeSAV = 0; end
end
switch typeSAV
    case 0 , figNAME = getWavMSG('Wavelet:mdw1dRF:Save_Den_Sigs');
    case 1 , figNAME = getWavMSG('Wavelet:mdw1dRF:Save_Den_SigsParam');
end
[filename,pathname,ok] = utguidiv('test_save',hFig,'*.mat',figNAME);
if ~ok, return; end

% Begin waiting.
%--------------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitSave'));

% Getting Synthesized Signal.
%---------------------------
data_INFO = wtbxappdata('get',hObject,'data_INFO');
x = data_INFO.sig_DEN; %#ok<NASGU>

% Saving file.
%--------------
[name,ext] = strtok(filename,'.');
if isempty(ext) || isequal(ext,'.')
    ext = '.mat'; filename = [name ext];
end
wwaiting('off',hFig);
try
    switch typeSAV
        case 0
            save([pathname filename],'x');
        case 1
            DEN_Params = wtbxappdata('get',hFig,'DEN_Params'); %#ok<NASGU>
            PCA_Params = wtbxappdata('get',hFig,'PCA_Params'); %#ok<NASGU>
            save([pathname filename],'x','DEN_Params','PCA_Params');
    end
catch
    errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
end
%-------------------------------------------------------------------------%
function Export_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

data_INFO = wtbxappdata('get',hObject,'data_INFO');
x = data_INFO.sig_DEN;
wtbxexport(x,'name','msig_1D', ...
    'title',getWavMSG('Wavelet:mdw1dRF:SyntSig'));
%-------------------------------------------------------------------------%
function Pop_CFS_LEV_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

plot_Decomposition(handles,'Pop')
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles) %#ok<INUSL>

% Begin initialization.
%----------------------
set(hObject,'Visible','off');

% WTBX -- Install DynVTool
%-------------------------
dynvtool('Install_V3',hObject,handles);

% WTBX -- Initialize GUIDE Figure.
%---------------------------------
wfigmngr('beg_GUIDE_FIG',hObject);

% WTBX -- Install ANAPAR FRAME
%-----------------------------
wnameDEF  = 'sym4';
maxlevDEF = 10;
levDEF    = 5;
utanapar('Install_V3_CB',hObject,'maxlev',maxlevDEF,'deflev',levDEF);
cbanapar('set',hObject,'wav',wnameDEF,'lev',levDEF);

% UIMENU INSTALLATION
%--------------------
hdl_Menus = Install_MENUS(hObject);
wtbxappdata('set',hObject,'hdl_Menus',hdl_Menus);

% Help and ContextMenus INSTALLATION
%------------------------------------
Install_HELP_and_CtxtMenu(hObject,handles);

% Axes Installation
%------------------
axe_SIG = handles.Axe_SIG;
axe_CFS = handles.Axe_CFS;
axe_DEN = handles.Axe_DEN;
axe_INI = [axe_SIG,axe_CFS,axe_DEN];
pos_axe_INI = get(axe_INI,'Position');
axe_SIG_A = handles.Axe_SIG_ADAP;
axe_CFS_A = handles.Axe_CFS_ADAP;
axe_DEN_A = handles.Axe_DEN_ADAP;
axe_INI_A = [axe_SIG_A,axe_CFS_A,axe_DEN_A];
pos_axe_INI_A = get(axe_INI_A,'Position');
tool_hdl_AXES.axe_INI = axe_INI;
tool_hdl_AXES.pos_axe_INI = pos_axe_INI;
tool_hdl_AXES.axe_INI_A = axe_INI_A;
tool_hdl_AXES.pos_axe_INI_A = pos_axe_INI_A;
wtbxappdata('set',hObject,'tool_hdl_AXES',tool_hdl_AXES);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',hObject,mfilename);
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%=========================================================================%
function hdl_Menus = Install_MENUS(hFig)

m_files = wfigmngr('getmenus',hFig,'file');
m_close = wfigmngr('getmenus',hFig,'close');
cb_close = [mfilename '(''Pus_CloseWin_Callback'',gcbo,[],guidata(gcbo));'];
set(m_close,'Callback',cb_close);

m_load  = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:LoadSigs'),   ...
    'Position',1,              ...
    'Enable','On',             ...
    'Callback',                ...
    [mfilename '(''Load_Sig_Callback'',gcbo,[],guidata(gcbo));']  ...
    );
m_save  = uimenu(m_files,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Save_Den_Sigs'), ...
    'Position',2,'Enable','Off' ...
    );
m_demo  = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Str_Example'), ...
    'Tag','Examples','Position',3,'Separator','Off');
uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:Import_Sigs'),'Position',4, ...
    'Enable','On','Separator','On', ...
    'Callback',  ...    
    [mfilename '(''Load_Sig_Callback'',gcbo,[],guidata(gcbo),''wrks'');'] ...
    );
m_exp_wrks = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:Export_Sigs'),'Position',5, ...
    'Enable','Off','Separator','Off',...
    'Callback',[mfilename '(''Export_Callback'',gcbo,[],guidata(gcbo));'] ...
    );

uimenu(m_save,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Save_Den_SigsOnly'), ...
    'Position',1,'Enable','On',       ...
    'Callback',[mfilename '(''save_FUN'',gcbo,[],guidata(gcbo),0);'] ...
    );
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Save_Den_SigsParam'), ...
    'Position',2,'Enable','On',       ...
    'Callback',[mfilename '(''save_FUN'',gcbo,[],guidata(gcbo),1);'] ...
    );
demoSET = {...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',1,1,5,'''(4,4)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',2,1,3,'''(4,4)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',3,2,5,'''(4,4)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',4,2,3,'''(4,4)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',5,3,3,'''(4,4)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',6,3,3,'''(2,4)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',7,3,3,'''(2,2)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',8,3,5,'''(2,2)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',9,4,5,'''(4,4)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',10,4,5,'''(2,4)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',11,4,3,'''(2,2)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',12,'R1',5,'''(1,1)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',13,'R2',5,'''(1,1)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',14,'R3',5,'''(1,1)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',15,'R4',5,'''(1,1)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',16,5,5,'''(8,8)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',17,5,5,'''(6,6)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',18,5,5,'''(4,4)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',19,5,5,'''(2,2)'''); ...
    getWavMSG('Wavelet:mdw1dRF:WMULDEN_Demo',20,5,5,'''(5,5)''')  ...
    };
nbDEM = size(demoSET,1);
sepSET = [3,5,9,12,16];
for k = 1:nbDEM
    strNUM = int2str(k);
    action = [mfilename '(''demo_FUN'',gcbo,[],guidata(gcbo),' strNUM ');'];
    if find(k==sepSET) , Sep = 'On'; else Sep = 'Off'; end
    uimenu(m_demo,'Label',[demoSET{k,1}],'Separator',Sep,'Callback',action);
end
hdl_Menus = struct('m_files',m_files,'m_close',m_close,...
    'm_load',m_load,'m_save',m_save,'m_demo',m_demo,'m_exp_wrks',m_exp_wrks);

%--------------------------------------------------------------------------
function Install_HELP_and_CtxtMenu(hFig,handles)

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig, ...
    getWavMSG('Wavelet:divGUIRF:WM_Pus_MUL_DEN'),'MULT_VAR_DEN');

% Add Help Item.
%----------------
wfighelp('addHelpItem',hFig, ...
    getWavMSG('Wavelet:commongui:HLP_DenoProc'),'DENO_PROCEDURE');
wfighelp('addHelpItem',hFig, ...
    getWavMSG('Wavelet:commongui:HLP_AvailMeth'),'COMP_DENO_METHODS');

% Add ContextMenus
%-----------------
hdl_WAV = [handles.Txt_Wav,handles.Pop_Wav_Fam,handles.Pop_Wav_Num];
wfighelp('add_ContextMenu',hFig,hdl_WAV,'UT_WAVELET');
hdl_EXT = [handles.Txt_Ext_Mode,handles.Pop_Ext_Mode];
wfighelp('add_ContextMenu',hFig,hdl_EXT,'EXT_MODE');
hdl_DEN = [handles.Pus_Decompose,handles.Rad_BASE_ORI, ...
    handles.Rad_BASE_ADAP,handles.Pus_More_ADAP];
wfighelp('add_ContextMenu',hFig,hdl_DEN,'DENO_BASIS');
hdl_TMP = [handles.Txt_THR_Meth,handles.Pop_THR_Meth];
wfighelp('add_ContextMenu',hFig,hdl_TMP,'COMP_DENO_STRA');
hdl_TMP = [handles.Rad_SOFT,handles.Rad_HARD];
wfighelp('add_ContextMenu',hFig,hdl_TMP,'DENO_SOFTHARD');
hdl_PCA = [...
    handles.Pan_PCA, ...
    handles.Chk_PCA,handles.Pus_More_PCA,...
    handles.Txt_NPC_APP,handles.Pop_NPC_APP, ...
    handles.Txt_NPC_FIN,handles.Pop_NPC_FIN  ...    
    ];
wfighelp('add_ContextMenu',hFig,hdl_PCA,'MUL_PCA');
%--------------------------------------------------------------------------
function Initialize_Axes(handles,nbAxes)

fig = handles.output;
[pos_axe_SIG,pos_axe_CFS,pos_axe_DEN] = getPosAxes('ini',fig,nbAxes);
tool_hdl_AXES = wtbxappdata('get',fig,'tool_hdl_AXES');

% For initial basis
axe_INI = tool_hdl_AXES.axe_INI;
set(axe_INI,'Visible','Off');
child = allchild(axe_INI);
child = cat(1,child{:});
delete(child)
axe_SIG = handles.Axe_SIG;
axe_CFS = handles.Axe_CFS;
axe_DEN = handles.Axe_DEN;
for k=1:nbAxes
    set(axe_SIG(k),'Position',pos_axe_SIG(k,:));
    set(axe_CFS(k),'Position',pos_axe_CFS(k,:));
    set(axe_DEN(k),'Position',pos_axe_DEN(k,:));
end
set([axe_SIG(1:nbAxes),axe_CFS(1:nbAxes),axe_DEN(1:nbAxes)],'Visible','On');

% For adapted basis
axe_INI = tool_hdl_AXES.axe_INI_A;
set(axe_INI,'Visible','Off');
child = allchild(axe_INI);
child = cat(1,child{:});
delete(child)
axe_SIG = handles.Axe_SIG_ADAP;
axe_CFS = handles.Axe_CFS_ADAP;
axe_DEN = handles.Axe_DEN_ADAP;
for k=1:nbAxes
    set(axe_SIG(k),'Position',pos_axe_SIG(k,:));
    set(axe_CFS(k),'Position',pos_axe_CFS(k,:));
    set(axe_DEN(k),'Position',pos_axe_DEN(k,:));
end
set([axe_SIG(1:nbAxes),axe_CFS(1:nbAxes),axe_DEN(1:nbAxes)],'Visible','On');
%--------------------------------------------------------------------------
function [p_axe_1,p_axe_2,p_axe_3] = getPosAxes(option,fig,nbAxes)

tool_hdl_AXES = wtbxappdata('get',fig,'tool_hdl_AXES');
axe_INI = tool_hdl_AXES.axe_INI;
pos_axe_INI = tool_hdl_AXES.pos_axe_INI;
pos_axes = cat(1,pos_axe_INI{:});
nbMAX = length(axe_INI)/3;
H = pos_axes(1,4);
yMIN  = min(pos_axes(1:nbMAX,2));
yMAX  = max(pos_axes(1:nbMAX,2)) + H;
dY = (yMAX-yMIN);
Ratio = (nbMAX/(nbMAX-1))*(dY/(nbMAX*H)-1);
hAXE = dY/(nbAxes+(nbAxes-1)*Ratio);
dAXE = hAXE*Ratio;
xSIG = pos_axes(1,1);
xCFS = pos_axes(1+nbMAX,1);
xDEN = pos_axes(1+2*nbMAX,1);
wAXE = pos_axes(1,3);
yAXE = yMAX;
p_axe_1 = zeros(nbAxes,4);
p_axe_2 = zeros(nbAxes,4);
p_axe_3 = zeros(nbAxes,4);
switch option  
    case 'ini'
        wA = wAXE*ones(1,3);

    case 'res'
        new_DX  = (xCFS -(xSIG+wAXE))/1.5;
        wA = [wAXE/0.65 , 0.55*wAXE/0.65 , 0.55*wAXE/0.65];
        xCFS = xSIG + wA(1) + new_DX;
        xDEN = xCFS + wA(2) + new_DX;         
end
for k=1:nbAxes
    yAXE = yAXE-hAXE;
    p_axe_1(k,:) = [xSIG,yAXE,wA(1),hAXE];
    p_axe_2(k,:) = [xCFS,yAXE,wA(2),hAXE];
    p_axe_3(k,:) = [xDEN,yAXE,wA(3),hAXE];
    yAXE = yAXE-dAXE;
end
%--------------------------------------------------------------------------
function plot_Decomposition(handles,typeCALL,varargin)

hFig = handles.output;
if nargin<3
    vis = lower(get(handles.Pan_BASE_ORI,'Visible'));
    if isequal(vis,'on')
        ori_OR_adap = 'ori';
    else
        ori_OR_adap = 'adap';
    end
else
    ori_OR_adap = lower(varargin{1});
end
adapFLAG = isequal(ori_OR_adap,'adap');
typeCALL = lower(typeCALL);
if isequal(typeCALL,'pop') , 
    typeCALL = get(handles.Rad_CFS_DEN,'Value');
end
data_INFO = wtbxappdata('get',hFig,'data_INFO');
[lenSIG,nbSIG] = size(data_INFO.sig_ORI);

switch typeCALL
    case {'ori',0}
        if ~adapFLAG
            dec = data_INFO.dec_ORI;
        else
            dec = data_INFO.dec_ORI_ADAP;
        end
    case {'den',1}
        if ~adapFLAG
            dec = data_INFO.dec_DEN;
        else
            dec = data_INFO.dec_DEN_ADAP;
        end
end

% Plot decomposition.
%--------------------
level_DEC = dec.level;
level = get(handles.Pop_CFS_LEV,'Value');
usr   = get(handles.Pop_CFS_LEV,'UserData');
switch ori_OR_adap
    case 'ori' 
        axe_CFS = handles.Axe_CFS;
        axe_CMD = [handles.Axe_SIG , axe_CFS , handles.Axe_DEN];
        idx = 1;

    case 'adap'
        axe_CFS = handles.Axe_CFS_ADAP;
        axe_CMD = [handles.Axe_SIG_ADAP , axe_CFS , handles.Axe_DEN_ADAP];
        idx = 2;
end
usr(idx) = level;
set(handles.Pop_CFS_LEV,'UserData',usr);
if level==level_DEC
    [coefs,longs] = wdec2cl(dec);    
else
    coefs = mdwtrec(dec,'ca',level);
    longs = size(coefs,1);
    for k = level:-1:1
        cfs_det = mdwtrec(dec,'cd',k);
        coefs = [coefs ; cfs_det];           %#ok<AGROW>
        longs = [longs ; size(cfs_det,1)];   %#ok<AGROW>
    end
    longs = [longs ; lenSIG];    
end
dynvtool('get',hFig,0);
mdw1dstem(axe_CFS(1:nbSIG),coefs,longs);
set(axe_CFS,'XLim',[1,lenSIG],'XtickMode','auto');
title(getWavMSG('Wavelet:commongui:Str_Coefficients'),...
    'Visible','on','Parent',axe_CFS(1));

dynvtool('init',hFig,[],axe_CMD,[],[1 0],'','','','real');
%--------------------------------------------------------------------------
function clean_TOOL(handles,typeCALL,varargin)

hFig = handles.output;
switch typeCALL
    case 'load'
        nbSIG = varargin{1};
        hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
        m_save = hdl_Menus.m_save;
        m_exp_wrks = hdl_Menus.m_exp_wrks;        
        UIC_Ena_OFF = [...
            m_save, m_exp_wrks, handles.Pus_Decompose,...
            handles.Rad_BASE_ORI,handles.Rad_BASE_ADAP, ...
            handles.Pus_More_ADAP, ...            
            handles.Txt_THR_Meth,handles.Pop_THR_Meth, ...
            handles.Rad_SOFT,handles.Rad_HARD, ...
            handles.Pus_More_PCA,handles.Chk_PCA, ...
            handles.Txt_NPC_APP,handles.Pop_NPC_APP, ...
            handles.Txt_NPC_FIN,handles.Pop_NPC_FIN, ...
            handles.Pus_Denoise,handles.Pus_Residuals,...
            handles.Chk_Show_DEN, ...
            handles.Txt_CFS_LEV,handles.Pop_CFS_LEV,  ...
            handles.Rad_CFS_ORI,handles.Rad_CFS_DEN  ...
            ];
        Rad_BASIS_Callback(hFig,[],handles)
        Rad_CFS_Callback(hFig,[],handles,'ini')
        set(UIC_Ena_OFF,'Enable','Off')
        set(handles.Chk_Show_DEN,'Value',0);
        prop_POP = {'String',int2str((0:nbSIG)'),'Value',nbSIG+1};
        set([handles.Pop_NPC_APP,handles.Pop_NPC_FIN],prop_POP{:});
        axe_DEN = [handles.Axe_DEN,handles.Axe_DEN_ADAP];
        t = get(axe_DEN,'title');
        delete(cat(1,t{:}));
        title('','Parent',handles.Axe_SIG(1));
        title('','Parent',handles.Axe_CFS(1))        
        
    case 'beg_dec'
        level = varargin{1};
        axe_DEN = [handles.Axe_DEN,handles.Axe_DEN_ADAP];
        child = allchild(axe_DEN);
        child = cat(1,child{:});
        delete(child)
        title('','Parent',handles.Axe_DEN(1));
        title('','Parent',handles.Axe_DEN_ADAP(1));
        hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
        UIC_Ena_OFF = [...
            hdl_Menus.m_save,hdl_Menus.m_exp_wrks ,handles.Pus_Residuals];
        set(UIC_Ena_OFF,'Enable','Off')
        set(handles.Pop_CFS_LEV,'String',int2str((1:level)'), ...
            'Value',level,'UserData',[level level]);
        Chk_Show_DEN_Callback(handles.Chk_Show_DEN,[],handles,0)
        Chk_PCA_Callback(hFig,[],handles,1)
                
    case 'end_dec'
        UIC_Ena_ON = [...
            handles.Pus_Decompose,...
            handles.Rad_BASE_ORI,handles.Rad_BASE_ADAP, ...
            handles.Pus_More_ADAP, ...
            handles.Txt_THR_Meth,handles.Pop_THR_Meth, ...
            handles.Rad_SOFT,handles.Rad_HARD, ...
            handles.Chk_PCA, ...
            handles.Pus_Denoise ...
            handles.Rad_CFS_ORI, ...
            handles.Txt_CFS_LEV,handles.Pop_CFS_LEV  ...
            ];        
        UIC_Ena_OF = handles.Rad_CFS_DEN;
        set(UIC_Ena_OF,'Enable','Off')
        set(UIC_Ena_ON,'Enable','On')
end
%--------------------------------------------------------------------------
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%


%=========================================================================%
%                      BEGIN Demo Utilities                               %
%                      ---------------------                              %
%=========================================================================%
function closeDEMO(hFig,eventdata,handles,varargin)    %#ok<INUSD,DEFNU>

close(hFig);
%----------------------------------------------------------
function demoPROC(hFig,eventdata,handles,varargin)     %#ok<INUSL,DEFNU>

handles = guidata(hFig);
numDEM  = varargin{1};
demo_FUN(hFig,eventdata,handles,numDEM);
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%
