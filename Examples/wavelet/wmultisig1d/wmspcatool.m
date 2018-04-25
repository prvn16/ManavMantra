function varargout = wmspcatool(varargin)
%WMSPCATOOL Multisignal Principal Component Analysis GUI.
%   VARARGOUT = WMSPCATOOL(VARARGIN)

% Last Modified by GUIDE v2.5 04-Sep-2006 13:21:28
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2005.
%   Last Revision: 21-Jul-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $ $Date: 2013/08/23 23:46:02 $ 

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wmspcatool_OpeningFcn, ...
                   'gui_OutputFcn',  @wmspcatool_OutputFcn, ...
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
% --- Executes just before wmspcatool is made visible.                    %
%*************************************************************************%
function wmspcatool_OpeningFcn(hObject,eventdata,handles)
% This function has no output args, see OutputFcn.

% Choose default command line output for wmspcatool
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
function varargout = wmspcatool_OutputFcn(~,~,handles)
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
function Pus_CloseWin_Callback(hObject,eventdata,handles) %#ok<DEFNU>

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
if isequal(lower(ena_Save),'on')
    hFig = get(hObject,'Parent');
    status = wwaitans({hFig,getWavMSG('Wavelet:mdw1dRF:Multivar_PCA')},...
        getWavMSG('Wavelet:mdw1dRF:Save_Simple_QUEST'),2,'Cancel');
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
function Load_Sig_Callback(~,~,handles,varargin)

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
catch %#ok<CTCH>
    err = 1;
end
if err, return; end

data_INFO = struct(...
    'sig_ORI',sig_ORI,'dec_ORI',[],     ...
    'sig_SIM',[],'dec_SIM',[]          ...
    );
wtbxappdata('set',hFig,'data_INFO',data_INFO);

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
clean_TOOL(handles,'load',nbSIG);

% Set Axes.
%----------
Initialize_Axes(handles,nbSIG);
set(handles.Pan_BASE_ORI,'Visible','On');
axe_SIG   = handles.Axe_SIG;
axe_CFS   = handles.Axe_CFS;
axe_SIM   = handles.Axe_SIM;
lin_SIG   = NaN(1,nbSIG);
lin_SIM   = NaN(1,nbSIG);

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
    lin_SIM(k) = plot(sig_ORI(:,k),...
        'Color',denColor,'Visible','Off','LineWidth',2,'Parent',axeCur);
    set(axeCur,'YLim',Ylim(k,:));
end
set([axe_SIG,axe_CFS,axe_SIM],'XLim',[1,lenSIG]);
set(axe_SIG,'XtickMode','auto','YtickMode','auto');
title(getWavMSG('Wavelet:mdw1dRF:Str_Signals'),'Visible','On', ...
    'Parent',axe_SIG(1));
hdl_INFO = struct('lin_SIG',lin_SIG,'lin_SIM',lin_SIM);
wtbxappdata('set',hFig,'hdl_INFO',hdl_INFO);
axe_IND = [];
axe_CMD = [axe_SIG,axe_CFS,axe_SIM];
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
function Pus_Decompose_Callback(~,~,handles)

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
UIC_Ena_ON = clean_TOOL(handles,'beg_dec',level);

% Wavelet decomposition of columns of sig_ORI.
%--------------------------------------------
data_INFO = wtbxappdata('get',hFig,'data_INFO');
sig_ORI   = data_INFO.sig_ORI;
[data_INFO.dec_ORI,npc,PCA_Params] = ...
    wmspca('estimate',sig_ORI,level,wname,'mode',extMode,'none');
for k=1:level
    pop = findobj(handles.Pop_DET_NPC,'UserData',k);
    set(pop,'Value',npc(k)+1);
end
set(handles.Pop_APP_NPC,'Value',npc(end-1)+1)
set(handles.Pop_FIN_NPC,'Value',npc(end)+1);
wtbxappdata('set',hFig,'data_INFO',data_INFO);
wtbxappdata('set',hFig,'PCA_Params',PCA_Params);

% Plots Signals in Adapted Basis.
%--------------------------------
plot_Decomposition(handles,'ORI','ORI');

% End waiting.
%-------------
set(UIC_Ena_ON,'Enable','On')

wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pop_DEF_NPC_Callback(hObject,~,handles)

val = get(hObject,'Value');
old = get(hObject,'UserData');
if isequal(val,old) , return; end
set(hObject,'UserData',val);

hFig = handles.output;
PCA_Params = wtbxappdata('get',hFig,'PCA_Params');
nbVAL = length(PCA_Params);
npc = zeros(1,nbVAL);
level = nbVAL-2;
for k = 1:nbVAL
    variances = PCA_Params(k).variances;
    switch val
        case 1 , npc(k) = length(variances);                  % 'none'
        case 2 , npc(k) = sum(variances>mean(variances));     % 'kais' 
        case 3 , npc(k) = sum(variances>0.05*sum(variances)); % 'heur' 
        case 4 , % 'no DET'
          if k<=level , npc(k) = 0; else npc(k) = length(variances); end
    end
end
for k=1:level
    pop = findobj(handles.Pop_DET_NPC,'UserData',k);
    set(pop,'Value',npc(k)+1);
end
set(handles.Pop_APP_NPC,'Value',npc(end-1)+1)
set(handles.Pop_FIN_NPC,'Value',npc(end)+1);
%--------------------------------------------------------------------------
function Pus_Apply_Callback(hObject,eventdata,handles)

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
level = dec.level;

% Get Parameters.
%----------------
npc = zeros(1,level+2);
for k=1:level
    pop = findobj(handles.Pop_DET_NPC,'UserData',k);
    npc(k) = get(pop,'Value')-1;
end
npc(end-1) = get(handles.Pop_APP_NPC,'Value')-1;
npc(end)   = get(handles.Pop_FIN_NPC,'Value')-1;
[x_sim,~,~,dec_SIM,PCA_Params] = wmspca(dec,npc);
wtbxappdata('set',hFig,'PCA_Params',PCA_Params);
[lenSIG,nbSIG] = size(x_sim);
data_INFO.sig_SIM = x_sim;
data_INFO.dec_SIM = dec_SIM;
wtbxappdata('set',hFig,'data_INFO',data_INFO);

% Plot Simplified Signals.
%-------------------------
hdl_INFO = wtbxappdata('get',hFig,'hdl_INFO');
lin_SIM = hdl_INFO.lin_SIM;
[~,denColor] = wtbutils('colors','wmden');
dynvtool('get',hFig,0);
axe_SIG = handles.Axe_SIG;
axe_CFS = handles.Axe_CFS;
axe_SIM = handles.Axe_SIM;
for k = 1:nbSIG
    plot((1:lenSIG),x_sim(:,k),'Color',denColor,'Parent',axe_SIM(k));
    set(lin_SIM(k),'XData',(1:lenSIG),'YData',x_sim(:,k));
    set(axe_SIM(k),'XLim',[1,lenSIG],'XtickMode','auto','YtickMode','auto');
end
title(getWavMSG('Wavelet:mdw1dRF:Simp_Signals'), ...
    'Visible','On','Tag','Simp_Signals', ...
    'Parent',axe_SIM(1))
Rad_CFS_Callback(hFig,eventdata,handles,'apply')
axe_IND = [];
axe_CMD = [axe_SIG,axe_CFS,axe_SIM];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','','real');
hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
UIC_Ena_ON = [...
    hdl_Menus.m_save,hdl_Menus.m_exp_wrks, ...
    handles.Chk_Show_SIM,handles.Pus_Residuals, ...
    handles.Rad_CFS_ORI,handles.Rad_CFS_SIM ...
    ];
set(UIC_Ena_ON,'Enable','On');
Chk_Show_SIM_Callback(handles.Chk_Show_SIM,eventdata,handles)

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pus_Residuals_Callback(~,eventdata,handles,state) %#ok<DEFNU>

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
    handles.Pus_Decompose,handles.Pus_More_ADAP,handles.Pus_CloseWin ...
    ];

% Set Residuals on/off.
%----------------------
axe_SIG = handles.Axe_SIG;
axe_CFS = handles.Axe_CFS;
axe_SIM = handles.Axe_SIM;
switch state
    case 0
        obj_VIS = [handles.Pan_BASE_ORI,handles.Pan_SIM_PARAM,...
            handles.Pus_Residuals,...
            handles.Pus_Apply,handles.Chk_Show_SIM,...
            handles.Rad_CFS_ORI,handles.Rad_CFS_SIM, ...
            handles.Txt_CFS_LEV,handles.Pop_CFS_LEV, ...
            handles.Txt_APP_NPC,handles.Pop_APP_NPC, ...
            handles.Pop_FIN_NPC,  ...
            ];
        vis_IN_AXES = findobj([axe_SIG,axe_CFS,axe_SIM],'Visible','On');
        obj_VIS = [vis_IN_AXES;obj_VIS(:)];
        
    case 1
        RES_Params = wtbxappdata('get',hFig,'RES_Params');
end

switch state
    case 0
        OBJ_ena_VAL = 'Off';
        data_INFO = wtbxappdata('get',hFig,'data_INFO');
        sig_ORI = data_INFO.sig_ORI;
        sig_SIM = data_INFO.sig_SIM;
        sig_RES = sig_ORI-sig_SIM;
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
        axe_CMD = [axe_SIG,axe_CFS,axe_SIM];
        dynvtool('init',hFig,[],axe_CMD,[],[1 0],'','','','real');
        set(RES_Params.obj_VIS,'Visible','On');
end
set(OBJ_Ena_CHANGE,'Enable',OBJ_ena_VAL)
set(utanaparHDL,'Enable',OBJ_ena_VAL)
%--------------------------------------------------------------------------
function Chk_Show_SIM_Callback(hObject,~,~,val)

if nargin<4
    val = get(hObject,'Value');
else
    set(hObject,'Value',val);
end
hdl_INFO = wtbxappdata('get',hObject,'hdl_INFO');
lin_SIM = hdl_INFO.lin_SIM;
lin_SIM = lin_SIM(ishandle(lin_SIM));
if val==1 , vis_VAL = 'On'; else vis_VAL = 'Off'; end
set(lin_SIM,'Visible',vis_VAL)
%--------------------------------------------------------------------------
function Pop_SIG_NUM_Callback(hObject,~,handles,flag) %#ok<INUSD>

errtol    = 1.0E-10;
nb_bins   = 75;
numSIG    = get(hObject,'Value');
data_INFO = wtbxappdata('get',hObject,'data_INFO');
sig_ORI   = data_INFO.sig_ORI;
sig_SIM   = data_INFO.sig_SIM;
sig_RES   = sig_ORI-sig_SIM;
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
function Rad_CFS_Callback(~,~,handles,typeCALL)

rad = [handles.Rad_CFS_ORI , handles.Rad_CFS_SIM];
old_VAL = get(rad(1),'UserData');
if isequal(typeCALL,'apply')
    if isequal([1 0],old_VAL)
        return;  
    else
        old_VAL = []; typeCALL = 'den'; 
    end
end
switch lower(typeCALL)
    case {'ori','ini'} , val = [1 0];
    case 'den' ,         val = [0 1];
end
for k = 1:2 , set(rad(k),'Value',val(k)); end
set(rad,'UserData',val);
if isequal(old_VAL,val) || isequal(typeCALL,'ini'),   return; end

plot_Decomposition(handles,typeCALL)
%--------------------------------------------------------------------------
function Pus_More_PCA_Callback(hObject,~,handles) %#ok<DEFNU>

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
    fig = wmspcatoolmopc(hObject,PCA_Params);
end
if ishandle(hObject)
    set(hObject,'String',strPUS,'UserData',fig);
else
    WfigPROP = handles.WfigPROP;
    try delete(WfigPROP.FigChild); end %#ok<TRYNC>
end
%--------------------------------------------------------------------------
function Pus_More_ADAP_Callback(hObject,~,handles) %#ok<DEFNU>

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
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_More_ADAP');
    fig = [];
else
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_More_ADAP_Close');
    PCA_Params = wtbxappdata('get',hObject,'PCA_Params');
    fig = wmspcatoolmoab(hObject,PCA_Params);
end
if ishandle(hObject)
    set(hObject,'String',strPUS,'UserData',fig);
else
    WfigPROP = handles.WfigPROP;
    try delete(WfigPROP.FigChild); end %#ok<TRYNC>
end
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%=========================================================================%
function demo_FUN(hObject,eventdata,handles,numDEM)

DEF_NPC = 'manual';
wname   = 'sym4';
switch numDEM        
    case {1,2,3,4,5,6}
        fname = 'ex3mwden'; 
        if numDEM<4 ,level = 3; else level = 5; end
        ZDET    = zeros(1,level);
        switch numDEM
            case 1 , DEF_NPC = 'nodet';
            case 2 , npc = [ZDET,2,4];
            case 3 , npc = [ZDET,2,2];
            case 4 , npc = [ZDET,2,2];
            case 5 , DEF_NPC = 'kais';
            case 6 , DEF_NPC = 'heur';
        end
        
    case {7,8,9,10,11}
        fname = 'ex4mwden'; 
        if numDEM<10 ,level = 3; else level = 5; end
        ZDET    = zeros(1,level);
        switch numDEM
            case 7  , npc = [ZDET,4,4];
            case 8  , npc = [ZDET,2,4];
            case 9  , npc = [ZDET,2,2];
            case 10 , DEF_NPC = 'kais';
            case 11 , DEF_NPC = 'heur';                
        end

    case {12,13,14,15}
        level = 5; 
        ZDET  = zeros(1,level);
        npc   = [ZDET,1,1];
        switch numDEM
            case 12 , fname = 'ex1mdr'; 
            case 13 , fname = 'ex2mdr'; 
            case 14 , fname = 'ex3mdr'; 
            case 15 , fname = 'ex4mdr'; 
        end

    case {16,17,18,19}
        fname = 'ex5mwden';         
        wname = 'sym4'; level = 5;
        DEF_NPC = 'Manual';
        ZDET    = zeros(1,level);
        switch numDEM
            case 16 , npc = [ZDET,4,8];
            case 17 , npc = [ZDET,4,4];
            case 18 , DEF_NPC = 'kais';
            case 19 , DEF_NPC = 'heur';
        end

    case {20,21,22,23}
        fname = 'ex1mwden'; 
        if numDEM==21 ,level = 3; else level = 5; end
        switch numDEM
            case 20 , DEF_NPC = 'nodet';
            case 21 , DEF_NPC = 'nodet';
            case 22 , DEF_NPC = 'kais';
            case 23 , DEF_NPC = 'heur';
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

% Setting parameters - Decomposition and Simplifying.
%----------------------------------------------------
cbanapar('set',hFig,'wav',wname,'lev',level);
Pus_Decompose_Callback(handles.Pus_Decompose,eventdata,handles);
switch lower(DEF_NPC)
    case 'manual', val_DEF = 0;
    case 'none'  , val_DEF = 1;
    case 'kais'  , val_DEF = 2;
    case 'heur'  , val_DEF = 3;
    case 'nodet' , val_DEF = 4;  
end
if val_DEF>0
    Pop_DEF = handles.Pop_DEF_NPC;
    set(Pop_DEF,'Value',val_DEF);
    Pop_DEF_NPC_Callback(Pop_DEF,eventdata,handles)
else
    for k=1:level
        pop = findobj(handles.Pop_DET_NPC,'UserData',k);
        set(pop,'Value',npc(k)+1);
    end
    set(handles.Pop_APP_NPC,'Value',npc(end-1)+1)
    set(handles.Pop_FIN_NPC,'Value',npc(end)+1);
end

set(handles.Chk_Show_SIM,'Value',1)
Pus_Apply_Callback(handles.Pus_Apply,eventdata,handles);
%-------------------------------------------------------------------------%
function save_FUN(hObject,~,handles,typeSAV)

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing file.
%--------------
if nargin<4
    Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
    Str_No  = getWavMSG('Wavelet:commongui:Str_No');
    ButtonName = ...
        questdlg(getWavMSG('Wavelet:mdw1dRF:Save_Param_Sigs_QUEST'), ...
        getWavMSG('Wavelet:mdw1dRF:Save_Signals'), ...
        Str_Yes,Str_No,Str_No);
     if isequal(ButtonName,Str_Yes) , typeSAV = 1; else typeSAV = 0; end
end
switch typeSAV
    case 0 , figNAME = getWavMSG('Wavelet:mdw1dRF:Save_Simp_Sigs');
    case 1 , figNAME = getWavMSG('Wavelet:mdw1dRF:Save_Simp_SigsPar');
end
[filename,pathname,ok] = utguidiv('test_save',hFig,'*.mat',figNAME);
if ~ok, return; end

% Begin waiting.
%--------------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitSave'));

% Getting Synthesized Signal.
%---------------------------
data_INFO = wtbxappdata('get',hObject,'data_INFO');
x = data_INFO.sig_SIM; %#ok<NASGU>

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
            PCA_Params = wtbxappdata('get',hFig,'PCA_Params'); %#ok<NASGU>
            save([pathname filename],'x','PCA_Params');
    end
catch %#ok<CTCH>
    errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
end
%-------------------------------------------------------------------------%
function Export_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

data_INFO = wtbxappdata('get',hObject,'data_INFO');
x = data_INFO.sig_SIM;
wtbxexport(x,'name','msig_1D','title', ...
    getWavMSG('Wavelet:mdw1dRF:Synt_Signals'));
%-------------------------------------------------------------------------%
function Pop_CFS_LEV_Callback(~,~,handles) %#ok<DEFNU>

plot_Decomposition(handles,'Pop')
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%=========================================================================%
function Init_Tool(hObject,~,handles)

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
axe_SIM = handles.Axe_SIM;
axe_INI = [axe_SIG,axe_CFS,axe_SIM];
pos_axe_INI = get(axe_INI,'Position');
tool_hdl_AXES.axe_INI = axe_INI;
tool_hdl_AXES.pos_axe_INI = pos_axe_INI;
wtbxappdata('set',hObject,'tool_hdl_AXES',tool_hdl_AXES);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',hObject,mfilename);
set([handles.Txt_DET_NPC,handles.Txt_APP_NPC],'FontWeight','bold');
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

m_load = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:LoadSigs'),   ...
    'Position',1,              ...
    'Enable','On',             ...
    'Callback',                ...
    [mfilename '(''Load_Sig_Callback'',gcbo,[],guidata(gcbo));']  ...
    );
m_save = uimenu(m_files,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Save_Simple_Sigs'), ...
    'Position',2,'Enable','Off' ...
    );
m_demo = uimenu(m_files,'Label',getWavMSG('Wavelet:commongui:Str_Example'), ...
    'Tag','Examples','Position',3,'Separator','Off');
uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:Import_Sigs'),'Position',4, ...
    'Enable','On','Separator','On','Tag','Import', ...
    'Callback',  ...    
    [mfilename '(''Load_Sig_Callback'',gcbo,[],guidata(gcbo),''wrks'');'] ...
    );
m_exp_wrks = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:Export_Sigs'),'Position',5, ...
    'Enable','Off','Separator','Off','Tag','Export',...
    'Callback',[mfilename '(''Export_Callback'',gcbo,[],guidata(gcbo));'] ...
    );

uimenu(m_save,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Save_Simple_SigsOnly'), ...
    'Position',1,'Enable','On',       ...
    'Callback',[mfilename '(''save_FUN'',gcbo,[],guidata(gcbo),0);'] ...
    );
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:mdw1dRF:Save_Simple_SigsParam'), ...
    'Position',2,'Enable','On',       ...
    'Callback',[mfilename '(''save_FUN'',gcbo,[],guidata(gcbo),1);'] ...
    );

demoSET = {...
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L3',1,3,'''nodet'''); ... 
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L3',2,3,'[0,...,0,2,4]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L3',3,3,'[0,...,0,2,2]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',4,3,'[0,...,0,2,2]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',5,3,'''kais'''); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',6,3,'''heur'''); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L3',7,4,'[0,...,0,2,4]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L3',8,4,'[0,...,0,2,2]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',9,4,'[0,...,0,2,2]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',10,4,'''kais'''); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',11,4,'''heur'''); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',12,'R1','[0,...,0,1,1]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',13,'R2','[0,...,0,1,1]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',14,'R3','[0,...,0,1,1]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',15,'R4','[0,...,0,1,1]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',16,5,'[0,...,0,4,8]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',17,5,'[0,...,0,4,4]'); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',18,5,'''kais'''); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',19,5,'''heur'''); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',20,1,'''nodet'''); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L3',21,1,'''nodet'''); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L5',22,1,'''kais'''); ...          
        getWavMSG('Wavelet:mdw1dRF:WMSPCA_Demo_L3',23,1,'''heur'''); ...          
    };
nbDEM = size(demoSET,1);
sepSET = [7,12,16,20];
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
wfighelp('addHelpTool',hFig,getWavMSG('Wavelet:mdw1dRF:HLP_MSPCA'),'MULT_VAR_PCA');

% Add Help Item.
%----------------
wfighelp('addHelpItem',hFig,getWavMSG('Wavelet:mdw1dRF:HLP_PCA_PROC'),'PCA_PROC');

% Add ContextMenus
%-----------------
hdl_WAV = [handles.Txt_Wav,handles.Pop_Wav_Fam,handles.Pop_Wav_Num];
wfighelp('add_ContextMenu',hFig,hdl_WAV,'UT_WAVELET');
hdl_EXT = [handles.Txt_Ext_Mode,handles.Pop_Ext_Mode];
wfighelp('add_ContextMenu',hFig,hdl_EXT,'EXT_MODE');
hdl_DEN = [handles.Pus_Decompose,handles.Pus_More_ADAP];
wfighelp('add_ContextMenu',hFig,hdl_DEN,'DENO_BASIS');
hdl_PCA = [...
    handles.Pan_SIM_PARAM, ...
    handles.Txt_DEF_NPC,handles.Pop_DEF_NPC, ...
    handles.Txt_Nb_DEC_PC, ...
    handles.Txt_DET_NPC,handles.Pop_DET_NPC,   ...
    handles.Txt_APP_NPC,handles.Pop_APP_NPC,   ...
    handles.Txt_Nb_FIN_PC,handles.Pop_FIN_NPC, ...
    handles.Pus_More_PCA  ...
    ];
wfighelp('add_ContextMenu',hFig,hdl_PCA,'PCA_PCA');
%--------------------------------------------------------------------------
function Initialize_Axes(handles,nbAxes)

fig = handles.output;
[pos_axe_SIG,pos_axe_CFS,pos_axe_SIM] = getPosAxes('ini',fig,nbAxes);
tool_hdl_AXES = wtbxappdata('get',fig,'tool_hdl_AXES');

% For initial basis
axe_INI = tool_hdl_AXES.axe_INI;
set(axe_INI,'Visible','Off');
child = allchild(axe_INI);
child = cat(1,child{:});
delete(child)
axe_SIG = handles.Axe_SIG;
axe_CFS = handles.Axe_CFS;
axe_SIM = handles.Axe_SIM;
for k=1:nbAxes
    set(axe_SIG(k),'Position',pos_axe_SIG(k,:));
    set(axe_CFS(k),'Position',pos_axe_CFS(k,:));
    set(axe_SIM(k),'Position',pos_axe_SIM(k,:));
end
set([axe_SIG(1:nbAxes),axe_CFS(1:nbAxes),axe_SIM(1:nbAxes)],'Visible','On');
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
typeCALL = lower(typeCALL);
if isequal(typeCALL,'pop') , 
    typeCALL = get(handles.Rad_CFS_SIM,'Value');
end
data_INFO = wtbxappdata('get',hFig,'data_INFO');
[lenSIG,nbSIG] = size(data_INFO.sig_ORI);

switch typeCALL
    case {'ori',0} , dec = data_INFO.dec_ORI;
    case {'den',1} , dec = data_INFO.dec_SIM;
end

% Plot decomposition.
%--------------------
level_DEC = dec.level;
level = get(handles.Pop_CFS_LEV,'Value');
usr   = get(handles.Pop_CFS_LEV,'UserData');
switch ori_OR_adap
    case 'ori' 
        axe_CFS = handles.Axe_CFS;
        axe_CMD = [handles.Axe_SIG , axe_CFS , handles.Axe_SIM];
        idx = 1;
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
        coefs = [coefs ; cfs_det];         %#ok<AGROW>
        longs = [longs ; size(cfs_det,1)]; %#ok<AGROW>
    end
    longs = [longs ; lenSIG];    
end
dynvtool('get',hFig,0);
mdw1dstem(axe_CFS(1:nbSIG),coefs,longs);
set(axe_CFS,'XLim',[1,lenSIG],'XtickMode','auto');
title(getWavMSG('Wavelet:commongui:Str_Coefficients'), ...
    'Visible','On','Parent',axe_CFS(1));
dynvtool('init',hFig,[],axe_CMD,[],[1 0],'','','','real');
%--------------------------------------------------------------------------
function varargout = clean_TOOL(handles,typeCALL,varargin)

hFig = handles.output;
pop_NPC = [handles.Pop_DET_NPC,handles.Pop_APP_NPC,handles.Pop_FIN_NPC];
txt_NPC = [handles.Txt_DET_NPC,handles.Txt_APP_NPC];
hdl_NPC = [txt_NPC,pop_NPC];
switch typeCALL
    case 'load'
        nbSIG = varargin{1};
        hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
        m_save = hdl_Menus.m_save;
        m_exp_wrks = hdl_Menus.m_exp_wrks;
        UIC_Ena_OFF = [...
            m_save, m_exp_wrks, handles.Pus_Decompose,...
            handles.Txt_Nb_DEC_PC,handles.Txt_Nb_FIN_PC,hdl_NPC, ...
            handles.Txt_DEF_NPC,handles.Pop_DEF_NPC, ...
            handles.Pus_Apply,handles.Pus_Residuals,...
            handles.Pus_More_ADAP,handles.Pus_More_PCA,  ...
            handles.Chk_Show_SIM, ...           
            handles.Txt_CFS_LEV,handles.Pop_CFS_LEV,  ...
            handles.Rad_CFS_ORI,handles.Rad_CFS_SIM  ...
            ];
        title('','Parent',handles.Axe_SIG(1));
        title('','Parent',handles.Axe_CFS(1));
        title('','Parent',handles.Axe_SIM(1));
        Rad_CFS_Callback(hFig,[],handles,'ini')
        set(UIC_Ena_OFF,'Enable','Off')
        set(handles.Chk_Show_SIM,'Value',0);
        prop_POP = {'String',int2str((0:nbSIG)'),'Value',nbSIG+1};
        set(pop_NPC,prop_POP{:});
        t = get(handles.Axe_SIM,'title');
        delete(cat(1,t{:}));
        
    case 'beg_dec'
        level = varargin{1};
        axe_SIM = handles.Axe_SIM;
        child = allchild(axe_SIM);
        child = cat(1,child{:});
        delete(child)
        title('','Parent',handles.Axe_SIM(1));
        hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
        UIC_Ena_OF = [...
            hdl_Menus.m_save,hdl_Menus.m_exp_wrks ,...
            handles.Pus_Residuals, ...
            handles.Chk_Show_SIM,handles.Rad_CFS_ORI,handles.Rad_CFS_SIM];
        set(UIC_Ena_OF,'Enable','Off')
        usr = get(hdl_NPC,'UserData');
        usr = cat(1,usr{:});
        hdl_OF = hdl_NPC(usr>level);
        hdl_ON = hdl_NPC(usr<=level);
        set(hdl_OF,'Visible','Off');
        pop_LAST = findobj(hdl_NPC(usr==level),'Style','PopupMenu');
        pos_DET = get(pop_LAST,'Position');
        pos_APP_POP = get(handles.Pop_APP_NPC,'Position');
        pos_APP_TXT = get(handles.Txt_APP_NPC,'Position');
        pos_APP_POP(2) = pos_DET(2)-1.5*pos_APP_POP(4);
        pos_APP_TXT(2) = pos_APP_POP(2)-pos_APP_TXT(4)/12;
        set(handles.Pop_APP_NPC,'Position',pos_APP_POP);
        set(handles.Txt_APP_NPC,'Position',pos_APP_TXT,...
            'String',getWavMSG('Wavelet:mdw1dRF:Approximation',level));
        set(handles.Pop_DEF_NPC,'Value',1,'UserData',1);
        set(handles.Pop_CFS_LEV,'String',int2str((1:level)'), ...
            'Value',level,'UserData',[level level]);
        Chk_Show_SIM_Callback(handles.Chk_Show_SIM,[],handles,0)
        UIC_Ena_ON = [...
            handles.Pus_Decompose,hdl_ON, ...
            handles.Txt_Nb_DEC_PC,handles.Txt_Nb_FIN_PC,  ...
            handles.Txt_DEF_NPC,handles.Pop_DEF_NPC, ...
            handles.Pus_More_ADAP,handles.Pus_More_PCA, ...
            handles.Pus_Apply,  ...
            handles.Txt_CFS_LEV,handles.Pop_CFS_LEV  ...
            ];
        set(hdl_ON,'Visible','On');
        varargout{1} = UIC_Ena_ON;
end

%--------------------------------------------------------------------------
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
function demoPROC(hFig,eventdata,~,varargin) %#ok<DEFNU>

handles = guidata(hFig);
numDEM  = varargin{1};
demo_FUN(hFig,eventdata,handles,numDEM);
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%


