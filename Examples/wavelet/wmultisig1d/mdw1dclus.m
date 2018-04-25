function varargout = mdw1dclus(varargin)
%MDW1DCLUS Discrete wavelet Multisignal 1D Analysis Tool.
%   VARARGOUT = MDW1DCLUS(VARARGIN)

% Last Modified by GUIDE v2.5 17-Aug-2012 15:34:03
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2005.
%   Last Revision: 11-Jul-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $ $Date: 2013/08/23 23:45:43 $

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mdw1dclus_OpeningFcn, ...
    'gui_OutputFcn',  @mdw1dclus_OutputFcn, ...
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
% --- Executes just before mdw1dclus is made visible.                     %
%*************************************************************************%
function mdw1dclus_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for mdw1dclus
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
function varargout = mdw1dclus_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;
%*************************************************************************%
%                END Output Function                                      %
%*************************************************************************%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%=========================================================================%
function Men_save_FUN(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

fig = handles.Current_Fig;
mdw1dpartmngr('SaveCUR',fig);
%-------------------------------------------------------------------------%
function Export_PART_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

fig = handles.output;
current_PART = wtbxappdata('get',fig,'current_PART');
namePART = get(current_PART,'Name');
wtbxexport(current_PART,'name',namePART, ...
    'title',getWavMSG('Wavelet:mdw1dRF:Current_Part'));
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%=========================================================================%
function Init_Tool(fig,eventdata,handles,varargin)

% Input Parameters.
%------------------
callingFIG = varargin{1};
Data_Name  = varargin{2};
tool_Name  = 'CLU';
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
cb_close = 'mdw1dmngr(''Pus_CloseWin_Callback'',gcbo,[],guidata(gcbo),''CLU'');';
set(m_close,'Callback',cb_close);

m_PART = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:Str_Partitions'), ...
    'Position',1,'Enable','On');
cb_load_PART = ['partsetmngr(''load_PART'',''' , tool_Name ''',gcbf);'];
m_load_PART = uimenu(m_PART, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:Load_from_Disk'),...
    'Position',1,'Enable','On','Callback',cb_load_PART);
cb_load_PART = ['partsetmngr(''load_PART'',''' , tool_Name ''',gcbf,''wrks'');'];
m_imp_PART = uimenu(m_PART,...
    'Label',getWavMSG('Wavelet:commongui:Lab_Import'),...
    'Position',2,'Enable','On','Callback',cb_load_PART);
cb_clear_PART = ['partsetmngr(''clear_PART'',''' , tool_Name ''',gcbf);'];
m_clear_PART = uimenu(m_PART, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:Clear_Partition'),...
    'Position',3,'Enable','Off','Separator','On','Callback',cb_clear_PART);
m_save_PART  = uimenu(m_PART, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:Save_Cur_Part'), ...
    'Position',4,'Enable','Off','Separator','On',  ...
    'Callback',[mfilename '(''Men_save_FUN'',gcbo,[],guidata(gcbo));']);
m_exp_PART  = uimenu(m_PART, ...
    'Label',getWavMSG('Wavelet:mdw1dRF:EXPORT_Cur_Part'), ...
    'Position',5,'Enable','Off','Separator','Off',  ...
    'Callback', [mfilename '(''Export_PART_Callback'',gcbo,[],guidata(gcbo));']);

hdl_Menus = struct(...
    'm_files',m_files,'m_close',m_close,'m_PART',m_PART,...
    'm_load_PART',m_load_PART,'m_imp_PART',m_imp_PART,...
    'm_clear_PART',m_clear_PART,'m_save_PART',m_save_PART,...
    'm_exp_PART',m_exp_PART);
wtbxappdata('set',fig,'hdl_Menus',hdl_Menus);

% Help and ContextMenus INSTALLATION
%------------------------------------
Install_HELP_and_CtxtMenu(fig,handles);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',fig,mfilename);

% Other Initializations.
%-----------------------
mdw1dmngr('init_TOOL',handles,Data_Name,tool_Name);
callingFIG = blockdatamngr('get',fig,'fig_Storage','callingFIG');
calling_handles = guidata(callingFIG);
str_PopMode = get(calling_handles.Pop_VisPanMode,'String');
set(handles.Pop_VisPanMode,'String',str_PopMode,'Value',1)
set(handles.Pop_Show_Mode,'String',str_PopMode,'Value',1)
Pan_CLU = [handles.Pan_CLU_Params,handles.Pan_Dendro_VISU];

% Set Title Colors.
%------------------
lst_Colors = mdw1dutils('lst_Colors');
sig_HDL = [handles.Edi_TIT_Dendro_Graph,handles.Edi_TIT_VM];
set(sig_HDL,'ForegroundColor',lst_Colors.sig)
% cfs_HDL = [handles.Txt_LST_CFS,handles.Lst_CFS_DATA];
% set(cfs_HDL,'ForegroundColor',lst_Colors.cfs)

% Other Initializations.
%-----------------------
set(handles.Lst_SIG_DATA,'Value',1);
mdw1dmngr('Lst_SIG_or_CFS_Func',handles.Lst_SIG_DATA,[],handles,'sig')
blockdatamngr('set',fig,'tool_ATTR','State','CLU_VIEW');
vis_Pan_CLU = 'On';
vis_uic_CMD = 'Off';
uic_CMD = handles.Pan_LST_DATA;
Set_Pos_Pan(fig,eventdata,handles,'Open_CLU');


lst_SIG = get(handles.Lst_SIG_DATA,'String');
if ~iscell(lst_SIG) , lst_SIG = {lst_SIG}; end
set(handles.Lst_SIG_DATA,'UserData',lst_SIG);

set(handles.Lst_Dendro_LINK,'String','')
active_ou_non_TOUT(handles,'Init_clu_TOOL');
set(Pan_CLU,'Visible',vis_Pan_CLU);
set(uic_CMD,'Visible',vis_uic_CMD);

data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
dwtDEC = data_ORI.dwtDEC;
if isempty(dwtDEC) , level = 0; else level = dwtDEC.level; end
clear data_ORI dwtDEC
data_DorC = mdw1dutils('data_INFO_MNGR','get',fig,'DorC');
typ_DorC = data_DorC.typ_DorC;
dwtDEC = data_DorC.dwtDEC;
DorCFLAG = ~isempty(dwtDEC);
clear data_DorC dwtDEC

switch typ_DorC
    case 'cmp' , str_DORC = getWavMSG('Wavelet:mdw1dRF:Str_Compressed');
    case 'den' , str_DORC = getWavMSG('Wavelet:mdw1dRF:Str_Denoised');
    otherwise  , str_DORC = getWavMSG('Wavelet:mdw1dRF:Str_Den_OR_Cmp');
end
set(handles.Rad_DorC_CLU,'String',str_DORC)

numCHK = str2double(get(handles.Chk_DET_CLU,'String'));
[~,idxCHK] = sort(numCHK);
handles.Chk_DET_CLU = handles.Chk_DET_CLU(idxCHK);
hTYP_CLU = [ ...
    handles.Rad_Ori_CLU,handles.Rad_DorC_CLU,handles.Rad_Res_CLU,...
    handles.Fra_O_DorC_R_CLU];
hSRC_CLU = [...
    handles.Rad_Sig_CLU,handles.Rad_Rec_CLU,handles.Rad_Cfs_CLU,...
    handles.Fra_SRC_CLU];
hAPP_CLU = [handles.Pop_APP_CLU,handles.Txt_APP_CLU];
hDET_CLU = [handles.Chk_DET_CLU,...
    handles.Pus_DET_CLU_All_None,...
    handles.Fra_DET_CLU,handles.Txt_DET_CLU ...
    ];
Chk_DET = handles.Chk_DET_CLU;
Sdet = str2double(get(Chk_DET,'String'));
set(Chk_DET(Sdet>level),'Visible','Off')

Str_APP_CLU = cell(1,level+1);
Str_APP_CLU{1} = getWavMSG('Wavelet:commongui:Str_None');
for k=1:level
    Str_APP_CLU{k+1} = int2str(k);
end
set(handles.Pop_APP_CLU,'Value',1,'String',Str_APP_CLU)

set(handles.Pan_DAT_to_CLU,'UserData',...
    {level,DorCFLAG,hTYP_CLU,hSRC_CLU,hAPP_CLU,hDET_CLU})
if level~=0
    set([hAPP_CLU,hDET_CLU],'Enable','Off')
    if ~DorCFLAG , set(hTYP_CLU(2:3),'Enable','Off'); end
else
    set([hTYP_CLU(2:3),hSRC_CLU(2:3),hAPP_CLU,hDET_CLU],'Enable','Off')
end

SET_of_Partitions = wtbxappdata('get',callingFIG,'SET_of_Partitions');
nbPART = length(SET_of_Partitions);
if nbPART>0 , ena_VAL = 'On'; else ena_VAL = 'Off'; end

% Empty current Partition Structure.
wtbxappdata('set',fig,'current_PART',[]);
set([handles.Pus_PART_MNGR,handles.Pus_PART_MORE],'Enable',ena_VAL);
%--------------------------------------------------------------------------
function Install_HELP_and_CtxtMenu(hFig,handles)

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig, ...
    getWavMSG('Wavelet:mdw1dRF:HLP_Multi_Cluster'),'MULT_CLUS_1D');

% Add Help Item.
%----------------

% Add ContextMenus
%-----------------
hdl_WAV = [handles.Txt_Wav,handles.Edi_Wav_Fam,handles.Edi_Wav_Num];
wfighelp('add_ContextMenu',hFig,hdl_WAV,'UT_WAVELET');
hdl_EXT = [handles.Txt_Ext_Mode,handles.Edi_Ext_Mode];
wfighelp('add_ContextMenu',hFig,hdl_EXT,'EXT_MODE');
%--------------------------------------------------------------------------
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Functions                                 %
%                ------------------------                                 %
%=========================================================================%
%--------------------------------------------------------------------------
function Pus_PART_STORE_Callback(hObject,eventdata,handles,varargin) %#ok<INUSL,DEFNU>

flagSTORE = partsetmngr('store_PART',handles,varargin{:});
if flagSTORE
    hdl_DEL = [handles.Pus_ALL_DEL,handles.Pus_CUR_DEL,handles.Txt_DEL_PART];
    set(hdl_DEL,'Enable','On')
end
%--------------------------------------------------------------------------
function Pus_CLU_SHOW_Callback(hObject,eventdata,handles,varargin) %#ok<INUSD,DEFNU>

typeCALL = get(hObject,'Type');
switch typeCALL
    case 'figure'
        fig = hObject;
        struct_CALL = wtbxappdata('get',fig,'struct_CALL');
        hObject = struct_CALL.Obj;
        
    otherwise
        fig = get(hObject,'UserData');
end
closeWIN = ~isempty(fig);
if closeWIN
    if ishandle(fig) , delete(fig); end
    strPUS = getWavMSG('Wavelet:mdw1dRF:Show_Clusters');
    fig = [];
else
    strPUS = getWavMSG('Wavelet:mdw1dRF:Show_Clusters_CLOSE');
    fig = showclusters(mfilename,'CLU');
end
set(hObject,'String',strPUS,'UserData',fig);
%--------------------------------------------------------------------------
function Pop_CLU_LINK_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

num = get(hObject,'Value');
usr = get(hObject,'UserData');
if ~isequal(num,usr) , set(hObject,'UserData',num); end
%--------------------------------------------------------------------------
function thr_DENDRO_Func(handles,thr_DENDRO)

fig = handles.output;
Edi = handles.Edi_Nb_CLU;
if nargin<2
    usr = get(Edi,'UserData');
    if isempty(usr) , usr = [6 , 0.7]; end
    thr_DENDRO = usr(2);
end
delta_THR = 1E-6;
thr_DENDRO = max([delta_THR,thr_DENDRO]);
thr_DENDRO = min([thr_DENDRO,1-delta_THR]);
usr(2) = thr_DENDRO;
current_PART = wtbxappdata('get',fig,'current_PART');
Links = get(current_PART,'Links');
if ~isempty(Links)
    NbCLU = length(find(Links(:,3)>=thr_DENDRO)) + 1;
    usr(1) = NbCLU;
    set(Edi,'String',int2str(NbCLU));
else
    usr(1) = NaN;
end
set(Edi,'UserData',usr);
set(handles.Edi_THR_COL,'String',num2str(thr_DENDRO,'%1.4f'));
%--------------------------------------------------------------------------
function Edi_THR_COL_Callback(hObject,eventdata,handles,thr_DENDRO) %#ok<DEFNU>

fig = handles.output;
if nargin<4
    seuilPARAM = get(hObject,'UserData');
    if isempty(seuilPARAM)
        seuilPARAM = 0.7;
        set(hObject,'UserData',seuilPARAM);
    end
    strEDI = get(hObject,'String');
    thr_DENDRO = str2double(strEDI);
end
delta_THR = 1E-6;
thr_DENDRO = max([delta_THR,thr_DENDRO]);
thr_DENDRO = min([thr_DENDRO,1-delta_THR]);
set(hObject,'String',num2str(thr_DENDRO,'%1.4f'),'UserData',thr_DENDRO);
current_PART = wtbxappdata('get',fig,'current_PART');
Links = get(current_PART,'Links');
if isempty(Links) , return; end
NbCLU = length(find(Links(:,3)>=thr_DENDRO)) + 1;
set(handles.Edi_Nb_CLU,'String',int2str(NbCLU),'UserData',NbCLU);
Pus_Cluster_Callback(handles.Pus_Cluster,eventdata,handles,'EDI')
%--------------------------------------------------------------------------
function Pop_Dendro_SORT_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

%--------------------------------------------------------------------------
function Pus_Dendro_SORT_Callback(hObject,eventdata,handles,direct) %#ok<INUSL,DEFNU>

fig = handles.output;
numCOL = get(handles.Pop_Dendro_SORT,'Value');
current_PART = wtbxappdata('get',fig,'current_PART');
Links = get(current_PART,'Links');
nbLIENS = size(Links,1);
numLIEN = (1:nbLIENS)';
switch numCOL
    case 1 ,       idxSORT = numLIEN;
    case {2,3,4} ,[~,idxSORT] = sort(Links(:,numCOL-1));
end
if direct==-1 , idxSORT = flipud(idxSORT); end
blanc = ' ';
blanc = blanc(ones(nbLIENS,1),:);
sep = ' | ';
sep = sep(ones(nbLIENS,1),:);
STR_VAL = [blanc , ...
    num2str(numLIEN(idxSORT),'%4.0f') , sep , ...
    num2str(Links(idxSORT,1),'%4.0f') , sep , ...
    num2str(Links(idxSORT,2),'%4.0f') , sep , ...
    num2str(Links(idxSORT,3),'%1.4f') , sep];
if nbLIENS==1 , STR_VAL = {STR_VAL}; end
set(handles.Lst_Dendro_LINK,'Value',1,'String',STR_VAL);
%--------------------------------------------------------------------------
function Lst_Dendro_LINK_Callback(hObject,eventdata,handles) %#ok<DEFNU>

contents = get(hObject,'String');
item = contents(get(hObject,'Value'),:);
if isempty(item) , return; end

fig = handles.Current_Fig;
mousefrm(fig,'watch'); drawnow
val_AFF = get(handles.Rad_AFF_SIG,'Value');
switch val_AFF
    case 0 , Signaux_Traites = wtbxappdata('get',fig,'data_To_Clust');
    case 1
        data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
        Signaux_Traites = data_ORI.signal;
end
nbSIG = size(Signaux_Traites,1);
current_PART = wtbxappdata('get',fig,'current_PART');
Links = get(current_PART,'Links');
idxSep = strfind(item,'|');
% idxLIEN   = str2double(item(1:idxSep(1)-1));
idxNoeud1 = str2double(item(idxSep(1)+1:idxSep(2)-1));
idxNoeud2 = str2double(item(idxSep(2)+1:idxSep(3)-1));
% dist_N1N2 = str2double(item(idxSep(3)+1:idxSep(4)-1));
idxSIG = [];
idxNEW = [idxNoeud1,idxNoeud2];
continu = true;
while continu
    locSUP = (idxNEW>nbSIG);
    idxSUP = idxNEW(locSUP);
    idxSIG = [idxSIG ,idxNEW(~locSUP)]; %#ok<AGROW>
    continu = ~isempty(idxSUP);
    if continu
        idx_IN_Links = idxSUP-nbSIG;
        idxNEW = Links(idx_IN_Links,1:2);
        idxNEW = idxNEW(:)';
    end
end
mdw1dafflst('CLU',hObject,eventdata,handles,'links',idxSIG)
mdw1dmisc('plot',handles,'all','links')
%--------------------------------------------------------------------------
function Pus_Cluster_Callback(hObject,eventdata,handles,varargin) %#ok<INUSL>

fig = handles.Current_Fig;
mousefrm(fig,'watch'); drawnow
blockdatamngr('set',fig,'tool_ATTR','State','CLU_ON');

% Désactiver l'affichage.
%------------------------
[typSIG,DorC_FLAG,resFLAG,numAPP,idxDET] = get_sig2CLU(handles);
switch DorC_FLAG
    case 0 , strTYPE = 'ORI';
    case 1 , strTYPE = 'DorC';
end
data_CUR = mdw1dutils('data_INFO_MNGR','get',fig,strTYPE);
if resFLAG
    data_CUR_DorC   = mdw1dutils('data_INFO_MNGR','get',fig,'DorC');
    data_CUR.signal = data_CUR.signal-data_CUR_DorC.signal;
    data_To_Clust   = data_CUR.signal;
else
    if numAPP==0 && isempty(idxDET)
        data_To_Clust = data_CUR.signal;
    else
        data_To_Clust = [];
        if numAPP~=0
            typeREC = [typSIG,'a'];
            tmp =  mdwtrec(data_CUR.dwtDEC,typeREC,numAPP);
            data_To_Clust = [data_To_Clust , tmp];
        end
        if ~isempty(idxDET)
            typeREC = [typSIG,'d'];
            for k = 1:length(idxDET)
                tmp =  mdwtrec(data_CUR.dwtDEC,typeREC,idxDET(k));
                data_To_Clust = [data_To_Clust , tmp]; %#ok<AGROW>
            end
        end
    end
end
wtbxappdata('set',fig,'data_To_Clust',data_To_Clust);
clu_METH = get(handles.Pop_CLU_METH,'Value');
switch clu_METH
    case 1
        lstDIST = wtranslate('ORI_ahc_dist');
        lstLINK = wtranslate('ORI_ahc_link');
    otherwise
        lstDIST = wtranslate('ORI_kmeans_dist');
        lstLINK = wtranslate('ORI_kmeans_link');
end
distance = lstDIST{get(handles.Pop_CLU_DIST,'Value')};
l_OR_s_METH = lstLINK{get(handles.Pop_CLU_LINK,'Value')};
NbCLU = str2double(get(handles.Edi_Nb_CLU,'String'));

if ismember(clu_METH,(2:4))
    kmeans_PAR = {...
        'distance',distance,...
        'start',l_OR_s_METH, ...
        'EmptyAction','singleton',    ...
        'Replicates',1,'Maxiter',100  ...
        };
end

switch clu_METH
    case 1 , % Hierarchical Cluster Tree
        part_METH = 'HT';
        distPARAM = get(handles.Edi_CLU_DIST,'UserData');
        %++++++++++++++++ Get distance and distance parameters ++++++++++
        switch lower(distance)
            case 'minkowski'
                power = distPARAM.power;
                distanceARG = {distance,power};
                
            case {'wenergy','wenergyper'}
                valPOP    = get(handles.Edi_CLU_DIST,'Value');
                contents  = get(handles.Edi_CLU_DIST,'String');
                param     = contents{valPOP};
                distanceARG = {'euclide'};
                if isequal(typSIG,'s')
                    Energy   = data_CUR.Energy;
                    tab_ENER = data_CUR.tab_ENER;
                    if isequal(distance,'wenergy') && ~isequal(param,'L2')
                        tab_ENER = ...
                            tab_ENER.*Energy(:,ones(1,size(tab_ENER,2)));
                    end
                    switch param
                        case 'L2'  , data_To_Clust = Energy;
                        case 'Det' , data_To_Clust = tab_ENER(:,2:end);
                        otherwise
                            typePAR = lower(param(1));
                            numLEV  = str2double(param(2:end));
                            if typePAR=='a'
                                data_To_Clust = tab_ENER(:,1);
                            else
                                data_To_Clust = tab_ENER(:,end+1-numLEV);
                            end
                    end
                end
                
            case 'userdef'
                userDistance = distPARAM.userDistance;
                distanceARG = {str2func(userDistance)};
                
            otherwise
                distanceARG = {distance};
        end
        
        % Compute Link Distance and Links (normalized).
        %----------------------------------------------
        switch lower(distance)
            case 'userdef'
                Y = feval(userDistance);
            otherwise
                Y = pdist(data_To_Clust,distanceARG{:});
        end
        
        Links = linkage(Y,l_OR_s_METH);
        maxi = max(abs(Links(:,3)));
        Links(:,3 ) = Links(:,3)/maxi;
        
        % Compute Cluster Numbers.
        %--------------------------
        IdxCLU = wtbxcluster(Links,NbCLU);
        NbCLU  = max(IdxCLU);
        
        % Partition parameters.
        %----------------------
        part_PAR = struct('distance',distance,'distPARAM',distPARAM,...
            'link_METH',l_OR_s_METH);
        part_VAR = struct('Links',Links);
        
    case 2 , % Kmeans
        part_METH = 'KM';
        data_To_Clust = wtbxappdata('get',fig,'data_To_Clust');
        warning('off','stats:kmeans:EmptyCluster')
        [IdxCLU,Centers,SUMD,D] = kmeans(data_To_Clust,NbCLU,kmeans_PAR{:});
        warning('on','stats:kmeans:EmptyCluster')
        if ~isequal(max(IdxCLU),NbCLU) , NbCLU = max(IdxCLU); end
        part_PAR = struct('distance',distance,'start',l_OR_s_METH);
        part_VAR = struct('Centers',Centers,'D',D,'SUMD',SUMD);
        
end
clu_INFO = tab2part(IdxCLU);
part_INFO = struct(...
    'method',part_METH,'NbCLU',NbCLU,...
    'part_PAR',part_PAR,'part_VAR',part_VAR);
current_PART = set(wpartobj,...
    'Name',getWavMSG('Wavelet:moreMSGRF:Curr_Part'), ...
    'part_INFO',part_INFO,'clu_INFO',clu_INFO);
wtbxappdata('set',fig,'current_PART',current_PART);

% Delete old partition and plot new partition.
%---------------------------------------------
plot_Partition(part_METH,handles)

% Activer l'affichage.
%---------------------
active_ou_non_TOUT(handles,'On')
set(handles.Pus_PART_MNGR,'Enable','On');
set(handles.Pus_PART_MORE,'Enable','On');
hdl_Menus = wtbxappdata('get',fig,'hdl_Menus');
m_save_PART = hdl_Menus.m_save_PART;
m_exp_PART = hdl_Menus.m_exp_PART;
set([m_save_PART,m_exp_PART],'Enable','On');
mousefrm(fig,'arrow');
%--------------------------------------------------------------------------
function plot_Kmeans(option,handles)
% Reset last warn
lastwarn('');
mdsError = false;
fig = handles.output;
act_PART = mdw1dutils('get_actPART',fig);
if nargin<3
    clu_METH  = get(act_PART,'Method');
    if ~isequal(clu_METH,'KM') , return; end
end
[NbCLU,IdxCLU,Centers,D] = blockdatamngr('get',act_PART,...
    'NbCLU','IdxCLU','Centers','D');
if isempty(Centers) , return; end

set(handles.Pop_SEL_VM,'Enable','On')
set(handles.Edi_TIT_VM, ...
    'String',getWavMSG('Wavelet:mdw1dRF:KM_Representations'));
opt_VM = get(handles.Pop_SEL_VM,'Value');
usr_VM = get(handles.Pop_SEL_VM,'UserData');
nbSIG = length(IdxCLU);
P = tab2part(IdxCLU);
if isequal(option,'new') , usr_VM = [];  end
if isempty(usr_VM)
    usr_VM = {opt_VM,{[],[],[]}};
else
    usr_VM{1} = opt_VM;
end
switch opt_VM
    case 1 ,
        axeVIS_ON = handles.Axe_VM_IMG; axeVIS_OF = handles.Axe_VM_DAT;
    case {2,3} ,
        axeVIS_ON = handles.Axe_VM_DAT; axeVIS_OF = handles.Axe_VM_IMG;
end
VM = usr_VM{2}{opt_VM};
switch opt_VM
    case {2,3}
        hdl_OF = findobj(axeVIS_OF);
        VM_OF = usr_VM{2}{1};
        if ~isempty(VM_OF) && ishandle(VM_OF.cBAR)
            hdl_OF = [hdl_OF ; VM_OF.cBAR];
        end
        set(hdl_OF,'Visible','Off')
        set(findobj(axeVIS_ON),'Visible','On')
        
        if isempty(VM)
            circleFLAG = [true,false];
            if opt_VM==2
                dissimilarities = pdist(Centers);
            else
                data_To_Clust = wtbxappdata('get',fig,'data_To_Clust');
                dissimilarities = pdist([data_To_Clust;Centers]);
            end
            try
                
                Y = mdscale(dissimilarities,2);
                if ~isempty(lastwarn)
                    uiwait(warndlg(lastwarn,getWavMSG('Wavelet:mdw1dRF:MDSScaleWarn')));
                end
            catch ME;
                mdsError = true;
                Y = NaN(NbCLU+nbSIG,2);
                
                %return;
            end
            
            
            ptnCENT = zeros(1,NbCLU);
            ptnSIG  = -ones(1,NbCLU);
            txtCENT = zeros(1,NbCLU);
            cirCENT = -ones(1,NbCLU);
            if any(circleFLAG)
                maxDIST = zeros(1,NbCLU);
                meanDIST = zeros(1,NbCLU);
                maxmaxDIST = max(max(D));
                for k = 1:NbCLU
                    maxDIST(k)  = max(D(IdxCLU==k));
                    meanDIST(k) = max(D(IdxCLU==k));
                end
                MaxDISSIM = max(max(dissimilarities));
                rho = MaxDISSIM*meanDIST/maxmaxDIST;
                tC = 2*pi*linspace(0,1,100);
            end
            
            toDEL = allchild(axeVIS_ON);
            if nargin>1
                switch opt_VM
                    case 2 , idxOF = 3;
                    case 3 , idxOF = 2;
                end
                VM_OF = usr_VM{2}{idxOF};
                if ~isempty(VM_OF)
                    hdl_OF = [VM_OF.ptnCENT,VM_OF.txtCENT,...
                        VM_OF.ptnSIG,VM_OF.cirCENT];
                    hdl_OF = hdl_OF(ishandle(hdl_OF));
                    toDEL = setdiff(toDEL,hdl_OF);
                    set(hdl_OF,'Visible','Off');
                end
            end
            axes(axeVIS_ON); %#ok<*MAXES>
            delete(toDEL)
            colorORD = getscaledmap(axeVIS_ON,NbCLU,false);
            if opt_VM==2
                for k=1:NbCLU
                    colorCENT = colorORD(k,:);
                    if circleFLAG(1)
                        cirCENT(k) = plot(Y(k,1)+ rho(k)*cos(tC),...
                            Y(k,2) + rho(k)*sin(tC),':',...
                            'Color',colorCENT,'visible','off');
                    end
                    hold on
                    ptnCENT(k) = plot(Y(k,1),Y(k,2),...
                        '.','MarkerSize',9,'Color',colorCENT, ...
                        'MarkerEdgeColor',colorCENT,...
                        'MarkerFaceColor',colorCENT,...
                        'visible','off');
                end
                for k=1:NbCLU
                    txtCENT(k) = text(Y(k,1),Y(k,2),int2str(k),...
                        'BackgroundColor',colorORD(k,:),...
                        'FontWeight','bold','UserData',k,'visible','off');
                end
                if ~mdsError
                    if circleFLAG(1)
                    set(cirCENT,'visible','on');
                    end
                    set(ptnCENT,'visible','on');
                    set(txtCENT,'visible','on');
                end
                
            else
                % Add error dialog to catch any exceptions
                
                
                for k=1:NbCLU
                    idxY = nbSIG + k;
                    idxSIM = P.IdxInCLU{k};
                    colorCENT = colorORD(k,:);
                    if circleFLAG(2)
                        cirCENT(k) = plot(Y(idxY,1)+ rho(k)*cos(tC),...
                            Y(idxY,2) + rho(k)*sin(tC),':', ...
                            'Color',colorCENT,'visible','off');
                    end
                    hold on
                    ptnSIG(k) = plot(Y(idxSIM,1),Y(idxSIM,2),...
                        '.','MarkerSize',10,'Color',colorCENT,'visible','off');
                    ptnCENT(k) = plot(Y(idxY,1),Y(idxY,2),...
                        'x','MarkerSize',9,'Color',colorCENT, ...
                        'MarkerEdgeColor',colorCENT,...
                        'MarkerFaceColor',colorCENT,...
                        'visible','off');
                end
                for k=1:NbCLU
                    idxY = nbSIG + k;
                    txtCENT(k) = text(Y(idxY,1),Y(idxY,2),int2str(k),...
                        'BackgroundColor',colorORD(k,:),...
                        'FontWeight','bold','UserData',k,'visible','off');
                end
                if ~mdsError
                    
                    if circleFLAG(2)
                        set(cirCENT,'visible','on');
                    end
                    set(ptnSIG,'visible','on');
                    set(ptnCENT,'visible','on');
                    set(txtCENT,'visible','on');
                
                end
                if mdsError
                    uiwait(errordlg(ME.message,getWavMSG('Wavelet:mdw1dRF:MDSScaleError')));
                end
                
            end
            
            
            VM = struct(...
                'ptnCENT',ptnCENT,'txtCENT',txtCENT, ...
                'ptnSIG',ptnSIG,'cirCENT',cirCENT);
            usr_VM{2}{opt_VM} = VM;
            cbTxtCENT = [mfilename '(''cbTxtCENT'',gco,[],[]);'];
            set(txtCENT,'ButtonDownFcn',cbTxtCENT);
        else
            switch opt_VM
                case 2
                    hdl_VIS_ON = [VM.ptnCENT,VM.txtCENT,VM.cirCENT];
                    hdl_VIS_OF = VM.ptnSIG;
                case 3
                    hdl_VIS_ON = [VM.ptnCENT,VM.txtCENT,VM.ptnSIG];
                    hdl_VIS_OF = [VM.cirCENT];
            end
            hdl_VIS_OF = hdl_VIS_OF(ishandle(hdl_VIS_OF));
            set(hdl_VIS_OF,'Visible','Off');
            set(hdl_VIS_ON,'Visible','On');
        end
        
    case 1
        set(findobj(axeVIS_OF),'Visible','Off')
        set(findobj(axeVIS_ON),'Visible','On')
        if isempty(VM)
            ZZ = ones(nbSIG,nbSIG);
            for k=1:NbCLU
                idxSIM = P.IdxInCLU{k};
                ZZ(idxSIM,idxSIM) = 1+k;
            end
            axes(axeVIS_ON);
            delete(allchild(axeVIS_ON))
            map = getscaledmap(axeVIS_ON,NbCLU+1,true);
            imgSIG = image(ZZ);
            colormap(map)
            dy   = NbCLU/(NbCLU+1);
            ytick = (1 + 0.5*dy:dy:(NbCLU+1));
            ytickLAB = {' None'};
            for k = 1:NbCLU
                ytickLAB = [ytickLAB , [' C' int2str(k)]]; %#ok<AGROW>
            end
            cBAR = colorbar('peer',handles.Axe_VM_IMG,...
                'location','EastOutside',  ...
                'YTick',ytick,'YTickLabel',ytickLAB);
            title(getWavMSG('Wavelet:mdw1dRF:Str_Cluster'),'Parent',cBAR)
            cbImgSIG = [mfilename '(''cbImgSIG'',gco,[],[]);'];
            set([imgSIG,cBAR],'ButtonDownFcn',cbImgSIG);
            VM = struct('imgSIG',imgSIG,'cBAR',cBAR);
            usr_VM{2}{opt_VM} = VM;
        end
end
switch opt_VM
    case 1 , strTIT = getWavMSG('Wavelet:mdw1dRF:Opt_VM_1');
    case 2 , strTIT = getWavMSG('Wavelet:mdw1dRF:Opt_VM_2');
    case 3 , strTIT = getWavMSG('Wavelet:mdw1dRF:Opt_VM_3');
end
title(strTIT,'Parent',axeVIS_ON);
set(handles.Pop_SEL_VM,'UserData',usr_VM);
%%%%%%%%%%%%%%%%%%% A VOIR SI UTILE ET QUAND %%%%%%%%%%%%%%%%%%%%
if isequal(option,'new')
    mdw1dafflst('CLU',fig,[],handles,'init')
end
%%%%%%%%%%%%%%%%%%% A VOIR SI UTILE ET QUAND %%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function plot_NONE(option,handles)

fig = handles.output;
act_PART = mdw1dutils('get_actPART',fig);
[NbCLU,IdxCLU] = blockdatamngr('get',act_PART,'NbCLU','IdxCLU');
set(handles.Pop_SEL_VM,'Value',1,'Enable','Off')
usr_VM = get(handles.Pop_SEL_VM,'UserData');
nbSIG = length(IdxCLU);
P = tab2part(IdxCLU);
if isequal(option,'new') , usr_VM = [];  end
if isempty(usr_VM)
    usr_VM = {1,{[],[],[]}};
else
    usr_VM{1} = 1;
end

axeVIS_ON = handles.Axe_VM_IMG;
axeVIS_OF = handles.Axe_VM_DAT;
VM = usr_VM{2}{1};
set(findobj(axeVIS_OF),'Visible','Off')
set(findobj(axeVIS_ON),'Visible','On')
if isempty(VM)
    ZZ = ones(nbSIG,nbSIG);
    for k=1:NbCLU
        idxSIM = P.IdxInCLU{k};
        ZZ(idxSIM,idxSIM) = 1+k;
    end
    axes(axeVIS_ON);
    delete(allchild(axeVIS_ON))
    map = getscaledmap(axeVIS_ON,NbCLU+1,true);
    imgSIG = image(ZZ);
    colormap(map)
    dy   = NbCLU/(NbCLU+1);
    ytick = (1 + 0.5*dy:dy:(NbCLU+1));
    ytickLAB = {' None'};
    for k = 1:NbCLU
        ytickLAB = [ytickLAB , [' C' int2str(k)]]; %#ok<AGROW>
    end
    cBAR = colorbar('peer',handles.Axe_VM_IMG,...
        'location','EastOutside',  ...
        'YTick',ytick,'YTickLabel',ytickLAB);
    title(getWavMSG('Wavelet:mdw1dRF:Str_Cluster'),'Parent',cBAR)
    cbImgSIG = [mfilename '(''cbImgSIG'',gco,[],[]);'];
    set([imgSIG,cBAR],'ButtonDownFcn',cbImgSIG);
    VM = struct('imgSIG',imgSIG,'cBAR',cBAR);
    usr_VM{2}{1} = VM;
end
set(handles.Edi_TIT_VM, ...
    'String',getWavMSG('Wavelet:mdw1dRF:Loaded_Partition'));
strTIT = getWavMSG('Wavelet:mdw1dRF:Opt_VM_1');
title(strTIT,'Parent',axeVIS_ON);
set(handles.Pop_SEL_VM,'UserData',usr_VM);
%---------------------------------------------------------------------
function cbTxtCENT(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

numCLASSE = get(hObject,'UserData');
handles = guidata(hObject);
axe = handles.Axe_VM_DAT;
mdw1dafflst('CLU',axe,eventdata,handles,'kmeans','cent',numCLASSE)
mdw1dmisc('plot',handles,'all','Dendro','res')
%---------------------------------------------------------------------
function cbImgSIG(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

handles = guidata(hObject);
fig = handles.output;
act_PART = mdw1dutils('get_actPART',fig);
IdxCLU = blockdatamngr('get',act_PART,'IdxCLU');

type = lower(get(hObject,'Type'));
type = type(1);
switch type
    case 'i' , axe = get(hObject,'Parent');
    case 'a' , axe = hObject;
    case 'c' ,  % Colorbar
end
if ~isequal(type,'c')
    cp = get(axe,'CurrentPoint');
else
    
end
switch type
    case 'i'
        x  = round(cp(1,1));
        y  = round(cp(1,2));
        XD = get(hObject,'XData');
        YD = get(hObject,'YData');
        if  XD(1)<= x && x<=XD(2) && YD(1)<= y && x<=YD(2)
            numCLASSE_X = IdxCLU(x);
            % numCLASSE_Y = IdxCLU(y);
            
            xI = x;
            while IdxCLU(xI)==IdxCLU(x) && xI>1 , xI = xI-1; end
            if IdxCLU(xI)~=IdxCLU(x) , xI = xI+1; end
            xS = x;
            while IdxCLU(xS)==IdxCLU(x) && xS<XD(2) , xS = xS+1; end
            if IdxCLU(xS)~=IdxCLU(x) , xS = xS-1; end
            yI = y;
            while IdxCLU(yI)==IdxCLU(y) && yI>1 , yI = yI-1; end
            if IdxCLU(yI)~=IdxCLU(y) , yI = yI+1; end
            yS = y;
            while IdxCLU(yS)==IdxCLU(y) && yS<YD(2) , yS = yS+1; end
            if IdxCLU(yS)~=IdxCLU(x) , yS = yS-1; end %#ok<NASGU>
            if xI~=yI
                mdw1dafflst('CLU',axe,eventdata,handles,...
                    'kmeans','cent',numCLASSE_X,IdxCLU)
            else
                mdw1dafflst('CLU',axe,eventdata,handles,...
                    'kmeans','sig',xI:xS,IdxCLU)
            end
            mdw1dmisc('plot',handles,'all','Dendro','res')
            
        end
        
    case 'a'
        yl = get(hObject,'YLim');
        dy  = (yl(2)-yl(1))/yl(2);
        numCLASSE = floor((cp(1,2)-1)/dy);
        mdw1dafflst('CLU',axe,eventdata,handles,...
            'kmeans','cent',numCLASSE,IdxCLU);
        mdw1dmisc('plot',handles,'all','Dendro','res');
        
    case 'c'
        yl = get(hObject,'YLim');
        dy  = (yl(2)-yl(1))/yl(2);
        % numCLASSE = floor((cp(1,2)-1)/dy);
        stop = 555;
        
end
wwaiting('off',fig);
%---------------------------------------------------------------------
function active_ou_non_TOUT(handles,enaVAL)

option = lower(enaVAL);
ena_IMPORT = get(handles.Pus_IMPORT,'Enable');
switch option
    case {'init','off','init_clu_tool'}
        if ~isequal(option,'off')
            set(handles.Lst_SIG_DATA,'Value',[],'String','');
        end
        delete(allchild(handles.Axe_DEN_ALL))
        delete(allchild(handles.Axe_DEN_RES))
        mdw1dmisc('plot',handles,[],option);
        enaVAL = 'off';
end
hdl_To_ENA = [...
    findobj(handles.Pan_Dendro_LINK,'Type','uicontrol');   ...
    findobj(handles.Pan_Dendro_VISU,'Type','uicontrol');   ...
    handles.Pus_CLU_SHOW;handles.Pus_PART_STORE(:) ...
    ];
if ~isequal(option,'init_clu_tool')
    hdl_To_ENA = [hdl_To_ENA;...
        findobj(handles.Pan_VISU_SIG,'Type','uicontrol');  ...
        findobj(handles.Pan_Selected_DATA,'Type','uicontrol')];
end
set(hdl_To_ENA,'Enable',enaVAL)
if isequal(option,'on')
    set([...
        handles.Edi_TIT_VISU,handles.Edi_TIT_VISU_DEC,...
        handles.Edi_TIT_SEL,...
        handles.Edi_TIT_Dendro_Graph,handles.Edi_TIT_Dendro_Link],...
        'Enable','Inactive')
    set(handles.Pus_IMPORT,'Enable',ena_IMPORT)
end
%---------------------------------------------------------------------
function IdxCLU = plot_Dendrogram(option,handles,varargin)

fig = handles.output;
[act_PART,act_PART_FLAG] = mdw1dutils('get_actPART',fig);
linFlag = false;
Par_DENDRO = 0;
switch option
    case 'init'
        [Links,NbCLU] = get(act_PART,'Links','NbCLU');
        thr_DENDRO = get_thr_DENDRO(Links,NbCLU);
        set(handles.Edi_THR_COL,'String',num2str(thr_DENDRO,'%1.4f'));
        
    case 'line'
        thr_DENDRO = varargin{1};
        thr_DENDRO_Func(handles,thr_DENDRO)
        Links = get(act_PART,'Links');
        NbCLU = length(find(Links(:,3)>=thr_DENDRO)) + 1;
        linFlag = true;
        
    case 'edi'
        [Links,NbCLU] = deal(varargin{1:2});
        thr_DENDRO = get_thr_DENDRO(Links,NbCLU);
        
    case {'restore','sel'}
        [Links,NbCLU] = get(act_PART,'Links','NbCLU');
        thr_DENDRO = get_thr_DENDRO(Links,NbCLU);
end
set(handles.Edi_Nb_CLU,'String',int2str(NbCLU),'Enable','On');
set(handles.Edi_THR_COL,'String',num2str(thr_DENDRO,'%1.4f'));

% Begin waiting.
%---------------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitCompute'));

%+++++++++++++++++++++++++++++++++++++++++++++++++++
Axe_DEN_RES = handles.Axe_DEN_RES;
axes(Axe_DEN_RES);
[Hs,IdxCLU,PERMs] = wtbxdendrogram(Links,NbCLU);
set(Axe_DEN_RES,'Box','On')
xlabel(getWavMSG('Wavelet:mdw1dRF:Restricted_Dendrogram'), ...
    'FontSize',6,'Parent',Axe_DEN_RES);
xt = get(Axe_DEN_RES,'XTick');
if length(xt)>18 , set(Axe_DEN_RES,'XTick',[]); end
cba_LINE = [mfilename '(''Line_Down_DENDRO_RES'',' ...
    num2mstr(Axe_DEN_RES) , ',[],[]);'];
set(Hs,'ButtonDownFcn',cba_LINE);
cba_AXE_DEN = [mfilename '(''Axe_DEN_BtnDown'','...
    num2mstr(Axe_DEN_RES) , ',[],[],[' int2str(PERMs) ']);'];
set(Axe_DEN_RES,'ButtonDownFcn',cba_AXE_DEN);
%+++++++++++++++++++++++++++++++++++++++++++++++++++
Axe_DEN_ALL = handles.Axe_DEN_ALL;
axes(Axe_DEN_ALL);
[Hc,Tc,PERMc,theGroups] = ...
    wtbxdendrogram(Links,Par_DENDRO,'COLORTHRESHOLD',thr_DENDRO);
set(Axe_DEN_ALL,'XTick',[],'XTickLabel',[],'Box','On')
title(getWavMSG('Wavelet:mdw1dRF:NumberClasses',int2str(NbCLU)))
cba_LINE = [mfilename '(''Line_Down_DENDRO'',' ...
    num2mstr(Axe_DEN_ALL) , ',[],[]);'];
set(Hc,'ButtonDownFcn',cba_LINE);
if ~act_PART_FLAG ,lin_COL = [1 0 0]; else lin_COL = [1 0.7 0.7]; end
hdl_LINE = line(...
    'XData',get(Axe_DEN_ALL,'XLim'),'YData',[thr_DENDRO,thr_DENDRO],...
    'Color',lin_COL,'LineWidth',2,'Tag','Line_DEN_SEL');
set(Axe_DEN_ALL,'XTick',[],'YLim',[-0.00 1.05]);
if ~act_PART_FLAG
    hdl_str = num2mstr([Axe_DEN_ALL ; hdl_LINE]);
    cba_LINE = [mfilename '(''Line_Down_GRAPH'',' ...
        num2mstr(fig) , ',[],[],' hdl_str ');'];
    set(hdl_LINE,'ButtonDownFcn',cba_LINE);
    setappdata(hdl_LINE,'selectPointer','H')
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++
wtbxappdata('set',fig,'Den_Res_Data',{Hs,IdxCLU,PERMs});
wtbxappdata('set',fig,'Den_All_Data',{Hc,Tc,PERMc,theGroups});
clu_INFO = tab2part(IdxCLU);
switch option
    case {'init','line','edi','restore'}
        setARG = {'NbCLU',NbCLU,'clu_INFO',clu_INFO};
        if ~isequal(option,'restore')
            setARG = ['Name',getWavMSG('Wavelet:moreMSGRF:Curr_Part'),setARG];
        end
        blockdatamngr('set',fig,'current_PART',setARG{:});
        
    case 'sel'
        blockdatamngr('set',fig,'active_PART',...
            'NbCLU',NbCLU,'clu_INFO',clu_INFO);
end
%%%%%%%%%%%%%%%%%%%%% A VOIR SI UTILE ET QUAND %%%%%%%%%%%%%%%%%%%%%%%%
switch option
    case {'init','restore'} , mdw1dafflst('CLU',fig,[],handles,'init')
    case {'line','edi'} , mdw1dafflst('CLU',fig,[],handles,'init')
    case 'sel'
end
%%%%%%%%%%%%%%%%%%%%% A VOIR SI UTILE ET QUAND %%%%%%%%%%%%%%%%%%%%%%%%
if ~linFlag
    nbLinks = size(Links,1);
    blanc = ' ';
    blanc = blanc(ones(nbLinks,1),:);
    sep = ' | ';
    sep = sep(ones(nbLinks,1),:);
    STR_VAL = [blanc , ...
        num2str((1:nbLinks)','%4.0f') , sep , ...
        num2str(Links(:,1),'%4.0f') , sep , ...
        num2str(Links(:,2),'%4.0f') , sep , ...
        num2str(Links(:,3),'%1.4f') , sep];
    if nbLinks==1 , STR_VAL = {STR_VAL}; end
    set(handles.Lst_Dendro_LINK,'Value',1,'String',STR_VAL);
end

% End waiting.
%-------------
wwaiting('off',fig);
%---------------------------------------------------------------------
function Line_Down_DENDRO_RES(hAXE,eventdata,handles,varargin) %#ok<INUSL,INUSD,DEFNU>

[hObject,fig] = gcbo;

% Begin waiting.
%---------------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitCompute'));
mousefrm(fig,'watch'); drawnow

Den_Data = wtbxappdata('get',fig,'Den_Res_Data');
[H,~,PERM] = deal(Den_Data{1:3});
idx  = find(H==hObject);
xd   = get(H(idx),'XData');
yd   = get(H(idx),'YData');
yd   = yd([1,4]);
xd   = xd([1,4]);
set(H,'Color','b');
xLines = get(H,'XData');
yLines = get(H,'YData');
if iscell(xLines)
    xLines = cat(1,xLines{:});
    yLines = cat(1,yLines{:});
end
xIND = [];
idx_LIN = idx;
xNEW = xd;
yNEW = yd;
continu = true;
while continu
    locPOS = (yNEW>0);
    yPOS   = yNEW(locPOS);
    xIND   = [xIND , xNEW(xNEW==fix(xNEW))]; %#ok<AGROW>
    continu = ~isempty(yPOS);
    if continu
        idx_Lines = [];
        for k = 1:length(yPOS)
            yP = yPOS(k);
            idx_ADD = find(yLines(:,2)==yP | yLines(:,3)==yP);
            idx_Lines = [idx_Lines ,idx_ADD(:)']; %#ok<AGROW>
        end
        idx_Lines = only_ONE(idx_Lines);
        idx_Lines = idx_Lines(:)';
        yNEW = yLines(idx_Lines,[1,4]);
        yNEW = yNEW(:)';
        yNEW = only_ONE(yNEW);
        xNEW = xLines(idx_Lines,[1,4]);
        xNEW = xNEW(:)';
        xNEW = only_ONE(xNEW);
        idx_LIN = [idx_LIN , idx_Lines]; %#ok<AGROW>
    end
end
numCLASSES = unique(PERM(xIND));
set(H(idx_LIN),'Color','r');
handles = guidata(fig);
mdw1dafflst('CLU',hObject,eventdata,handles,'dendro','res',numCLASSES)
mdw1dmisc('plot',handles,'all','Dendro','res')
mousefrm(fig,'arrow');

% End waiting.
%-------------
wwaiting('off',fig);
%---------------------------------------------------------------------
function Axe_DEN_BtnDown(hAXE,eventdata,handles,clu) %#ok<INUSL,DEFNU>

[axe,fig] = gcbo;
yl = get(axe,'YLim');
cp = get(axe,'CurrentPoint');
x = cp(1,1);
y = cp(1,2);
xr = 1:length(clu);
[ecx,idx] = min(abs(x-xr));
if (y<=yl(1)+eps) && (ecx<0.15)
    blink_COL = [1 0.5 0.2];
    numCLASSE = clu(idx);
    handles = guidata(fig);
    ypos = yl(1) + (yl(2)-yl(1))/4;
    t = text(x,ypos,['Class ' int2str(numCLASSE)],'Color','r');
    ext = get(t,'Extent');
    set(t,'Position',[x-ext(3)/2,ypos]);
    Den_Res_Data = wtbxappdata('get',fig,'Den_Res_Data');
    HLines = Den_Res_Data{1};
    set(HLines,'Color','b');
    Den_All_Data = wtbxappdata('get',fig,'Den_All_Data');
    Hc = Den_All_Data{1};
    theGroups = Den_All_Data{4};
    part = handles.current_PART;
    IdxCLU = get(part,'IdxCLU')';
    act_PART = mdw1dutils('get_actPART',fig);
    Links = get(act_PART,'Links');
    BBB = [Links(:,1)' ; theGroups'];
    nbSIG = size(BBB,2)+1;
    BBB(:,BBB(1,:)>nbSIG) = [];
    BBB(1,:) = IdxCLU(BBB(1,:));
    BBB = unique(sortrows(BBB',1),'rows');
    numGROUP = BBB(numCLASSE,2);
    idxIN = find(theGroups==numGROUP);
    SaveCOL = get(Hc(idxIN(1)),'Color');
    for k = 1:3
        set(Hc(idxIN),'Color',blink_COL,'LineWidth',2)
        pause(0.25);
        set(Hc(idxIN),'Color',SaveCOL,'LineWidth',1)
        pause(0.25);
    end
    
    mdw1dafflst('CLU',axe,eventdata,handles,'dendro','res',numCLASSE)
    mdw1dmisc('plot',handles,'all','Dendro','res')
    pause(0.25)
    delete(t)
end
%---------------------------------------------------------------------
function Line_Down_DENDRO(hAXE,eventdata,handles,varargin) %#ok<INUSD,DEFNU>

[hObject,fig] = gcbo;

% Begin waiting.
%---------------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitCompute'));
mousefrm(fig,'watch'); drawnow
blink_COL = [1 0.5 0.2];

handles = guidata(fig);
Den_Data = wtbxappdata('get',fig,'Den_Res_Data');
set(Den_Data{1},'Color','b');
if isequal(hAXE,handles.Axe_DEN_RES)
    option = 'res';
else
    option = 'all';
    Den_Data = wtbxappdata('get',fig,'Den_All_Data');
end

[H,~,PERM] = deal(Den_Data{1:3});
idx  = find(H==hObject);
xd   = get(H(idx),'XData');
yd   = get(H(idx),'YData');
yd   = yd([1,4]);
xd   = xd([1,4]);
xLines = get(H,'XData');
yLines = get(H,'YData');
if iscell(xLines)
    xLines = cat(1,xLines{:});
    yLines = cat(1,yLines{:});
end
xIND = [];
idx_LIN = idx;
xNEW = xd;
yNEW = yd;
continu = true;
while continu
    locPOS = (yNEW>0);
    yPOS   = yNEW(locPOS);
    xIND   = [xIND , xNEW(xNEW==fix(xNEW))]; %#ok<AGROW>
    continu = ~isempty(yPOS);
    if continu
        idx_Lines = [];
        for k = 1:length(yPOS)
            yP = yPOS(k);
            idx_ADD = find(yLines(:,2)==yP | yLines(:,3)==yP);
            idx_Lines = [idx_Lines ,idx_ADD(:)']; %#ok<AGROW>
        end
        idx_Lines = only_ONE(idx_Lines);
        idx_Lines = idx_Lines(:)';
        yNEW = yLines(idx_Lines,[1,4]);
        yNEW = yNEW(:)';
        yNEW = only_ONE(yNEW);
        xNEW = xLines(idx_Lines,[1,4]);
        xNEW = xNEW(:)';
        xNEW = only_ONE(xNEW);
        idx_LIN = [idx_LIN , idx_Lines]; %#ok<AGROW>
    end
end
numCLASSES = unique(PERM(xIND));
if isequal(option,'all')
    SaveCOL = get(H(idx_LIN),'Color');
    if ~iscell(SaveCOL), SaveCOL = {SaveCOL}; end
    for j = 1:2
        set(H(idx_LIN),'Color',blink_COL,'LineWidth',2);
        pause(0.5)
        for k = 1:length(idx_LIN)
            set(H(idx_LIN(k)),'Color',SaveCOL{k},'LineWidth',1);
        end
        pause(0.5)
    end
else
    set(H(idx_LIN),'Color','r');
end
mdw1dafflst('CLU',hObject,eventdata,handles,'dendro',option,numCLASSES)
mdw1dmisc('plot',handles,'all','Dendro',option)
mousefrm(fig,'arrow');

% End waiting.
%-------------
wwaiting('off',fig);
%---------------------------------------------------------------------
function Line_Down_GRAPH(fig,eventdata,handles,varargin) %#ok<INUSL,DEFNU>

hdl   = varargin{1};
lin   = hdl(2);
set(lin,'Color','g');
drawnow
hdl_str  = num2mstr(hdl);
cba_move = ...
    [mfilename '(''Line_Move_GRAPH'',' num2mstr(fig) ',[],[],' hdl_str ');'];
cba_up   = ...
    [mfilename '(''Line_Up_GRAPH'',' num2mstr(fig) ',[],[],' hdl_str ');'];
wtbxappdata('new',fig,...
    'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);
setptr(fig,'uddrag');
%---------------------------------------------------------------------
function Line_Move_GRAPH(fig,eventdata,handles,hdl) %#ok<INUSL,DEFNU>

handles = guidata(fig);
axe = hdl(1);
lin = hdl(2);
p   = get(axe,'CurrentPoint');
new_thresh = p(1,2);
yold = get(lin,'YData');
if isequal(yold(1),new_thresh) , return; end
delta_THR = 1E-6;
yLIM = get(axe,'YLim');
yLIM = [yLIM(1) 1] + delta_THR*[1 -1];
if new_thresh<yLIM(1);
    new_thresh = yLIM(1);
elseif new_thresh>yLIM(2)
    new_thresh = yLIM(2);
end
ynew = [new_thresh new_thresh];
set(lin,'YData',ynew);
thr_DENDRO_Func(handles,ynew(1))
%---------------------------------------------------------------------
function Line_Up_GRAPH(fig,eventdata,handles,hdl) %#ok<INUSL,DEFNU>

handles = guidata(fig);
axe = hdl(1);
lin = hdl(2);
yd = get(lin,'YData');
if isnan(yd(1)) || length(yd)<2
    delta_THR = 1E-6;
    yLIM = get(axe,'YLim');
    yLIM = [yLIM(1) 1] + delta_THR*[1 -1];
    yd = [yLIM(1) yLIM(1)];
end
save_WindowButtonUpFcn = wtbxappdata('del',fig,'save_WindowButtonUpFcn');
set(fig,'WindowButtonMotionFcn','', ...
    'WindowButtonUpFcn',save_WindowButtonUpFcn);
set(lin,'YData',yd,'Color','r');
thr_DENDRO = yd(1);
setptr(fig,'arrow');
drawnow;

% New dendrogam plot.
%--------------------
plot_Dendrogram('line',handles,thr_DENDRO);
set(handles.Pus_PART_STORE,'Enable','On')
%---------------------------------------------------------------------
function Edi_Nb_CLU_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

strEDI = get(hObject,'String');
if strncmpi(strEDI,'auto',1)
    set(hObject,'String','auto')
    return
end
NbCLU = str2double(strEDI);
NbCLU = fix(NbCLU);
if isnan(NbCLU) || (NbCLU<2)
    NbClust_DEF = get(hObject,'UserData');
    NbCLU = NbClust_DEF(1);
end
set(hObject,'String',int2str(NbCLU));

%%%%%%%%%%% To Activate the Edit Change the edi_ACTIVE flag %%%%%%%%%%
edi_ACTIVE = false;
if edi_ACTIVE
    fig = handles.Current_Fig; %#ok<UNRCH>
    current_PART = wtbxappdata('get',fig,'current_PART');
    clu_METH = get(current_PART,'Method');
    if ~isequal(clu_METH,'HT') , return; end  %%% A VOIR
    
    Links = get(current_PART,'Links');
    nbLinks = length(Links);
    if nbLinks>0
        thr_DENDRO = get_thr_DENDRO(Links,NbCLU);
    else
        data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
        Signaux_Traites = data_ORI.signal;
        nbLinks = size(Signaux_Traites,1)-1;
        thr_DENDRO = NaN;
    end
    if (NbCLU>(nbLinks+1)) , NbCLU = nbLinks; end
    set(hObject,'String',int2str(NbCLU),'UserData',[NbCLU,thr_DENDRO]);
    if ~isempty(Links)
        plot_Dendrogram('edi',handles,Links,NbCLU);
    end
end
%------------------------------------------------------------------------
function Rad_AFF_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

userdata = get(handles.Rad_AFF_SIG,'UserData');
if (hObject==handles.Rad_AFF_SIG)
    newdata = [1,0];
else
    newdata = [0,1];
end
set(handles.Rad_AFF_SIG,'Value',newdata(1))
set(handles.Rad_AFF_DAT,'Value',newdata(2))
if isequal(newdata,userdata) , return; end
set(handles.Rad_AFF_SIG,'UserData',newdata);
mdw1dmisc('plot',handles,[],'RadBTN');
%------------------------------------------------------------------------
function Pop_CLU_DIST_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

num = get(hObject,'Value');
usr = get(hObject,'UserData');
if ~isequal(num,usr)
    if isequal(num,12) % Separator
        set(hObject,'Value',usr);
        return;
    end
    set(hObject,'UserData',num);
end
style_EDI = get(handles.Edi_CLU_DIST,'Style');
if ~isequal(style_EDI,'edit')
    set(handles.Edi_CLU_DIST,'Style','Edit');
end
switch num
    case 5   % Minkowski
        distPARAM = get(handles.Edi_CLU_DIST,'UserData');
        if ~isempty(distPARAM) && ~isempty(distPARAM.power)
            strEDI = num2str(distPARAM.power);
        else
            strEDI = '2';
            distPARAM = struct('power',2,'userDistance','');
            set(handles.Edi_CLU_DIST,'UserData',distPARAM);
        end
        set(handles.Edi_CLU_DIST,'String',strEDI,'Visible','On');
        
    case 13  % Energy
        strEDI = {'L2'};
        typSIG = get_sig2CLU(handles);
        if isequal(typSIG,'s')
            fig = handles.output;
            data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
            level = data_ORI.dwtDEC.level;
            strEDI = [strEDI , ['A',int2str(level)]];
            for k=level:-1:1
                strEDI = [strEDI , ['D' int2str(k)]]; %#ok<AGROW>
            end
            strEDI = [strEDI , 'Det'];
        end
        set(handles.Edi_CLU_DIST,'Style','Popup',...
            'String',strEDI,'Value',1,'Visible','On');
        
    case 14  % Energy Percentage
        strEDI = {'L2'};
        typSIG = get_sig2CLU(handles);
        if isequal(typSIG,'s')
            fig = handles.output;
            data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
            level = data_ORI.dwtDEC.level;
            strEDI = [strEDI , ['A',int2str(level)]];
            for k=level:-1:1
                strEDI = [strEDI , ['D' int2str(k)]]; %#ok<AGROW>
            end
            strEDI = [strEDI , 'Det'];
        end
        set(handles.Edi_CLU_DIST,'Style','Popup',...
            'String',strEDI,'Value',1,'Visible','On');
        
    case 15  % UserDEF
        distPARAM = get(handles.Edi_CLU_DIST,'UserData');
        if ~isempty(distPARAM) && ~isempty(distPARAM.userDistance)
            strEDI = num2str(distPARAM.userDistance);
        else
            strEDI = '';
        end
        set(handles.Edi_CLU_DIST,'String',strEDI,'Visible','On');
        
    otherwise
        set(handles.Edi_CLU_DIST,'Visible','Off');
end
%------------------------------------------------------------------------
function Edi_CLU_DIST_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

num = get(handles.Pop_CLU_DIST,'Value');
distPARAM = get(hObject,'UserData');
if isempty(distPARAM)
    distPARAM = struct('power',2,'userDistance','');
    set(hObject,'UserData',distPARAM);
end
strEDI = get(hObject,'String');
if num==5        % Minkowski
    power = str2double(strEDI);
    if isnan(power) || power<1 || power>1E3
        power = 2;
        set(hObject,'String',int2str(power));
    end
    distPARAM.power = power;
    
elseif num==13   % Energy
    
elseif num==14   % Energy Percentage
    
elseif num==15   % Userdef
    distPARAM.userDistance = strEDI;
end
set(hObject,'UserData',distPARAM)
%------------------------------------------------------------------------
function B = only_ONE(A)

LA = length(A);
[~,I] = unique(A(end:-1:1));
I = LA+1-I;
B = A(sort(I));
%------------------------------------------------------------------------
function [typSIG,DorC_FLAG,res_FLAG,numAPP,idxDET] = ...
    get_sig2CLU(handles)

%-----------------------------------------------
% hTYP_CLU = [ ...
%     handles.Rad_Ori_CLU,handles.Rad_DorC_CLU,handles.Rad_Res_CLU,...
%     handles.Fra_O_DorC_R_CLU];
% hSRC_CLU = [...
%     handles.Rad_Sig_CLU,handles.Rad_Rec_CLU,handles.Rad_Cfs_CLU,...
%     handles.Fra_SRC_CLU];
% hAPP_CLU = [handles.Pop_APP_CLU , handles.Txt_APP_CLU];
% hDET_CLU = [handles.Chk_DET_CLU,...
%             handles.Pus_DET_CLU_All_None,...
%             handles.Fra_DET_CLU,handles.Txt_DET_CLU ...
%             ];
%-----------------------------------------------
infoCLU = get(handles.Pan_DAT_to_CLU,'UserData');
[level,~,hTYP_CLU,hSRC_CLU,hAPP_CLU,hDET_CLU] = deal(infoCLU{:});

valTYP = get(hTYP_CLU(1:3),'Value');
valTYP = cat(1,valTYP{:});
valSRC = get(hSRC_CLU(1:3),'Value');
valSRC = cat(1,valSRC{:});
idxTYP = find(valTYP==1);
idxSRC = find(valSRC==1);
DorC_FLAG = idxTYP==2;
res_FLAG = false;
idxDET = [];
numAPP = 0;

switch idxTYP
    % 'Orig. Signals' and 'Compressed' or 'De-noised'
    case {1,2} , if idxSRC==1 , typSIG = 's'; return; end
        
        % 'Residuals'
    case 3 , typSIG = 's'; res_FLAG = true; return;
end
if level==0 ,  return; end

numAPP = get(hAPP_CLU(1),'Value')-1;
valDET = get(hDET_CLU(1:level),'Value');
valDET = cat(1,valDET{:});
idxDET = find(valDET==1);

% Coefficients or Signals
if idxSRC==2 , typSIG = '' ; else typSIG = 'c'; end

% Approximations or Details
if numAPP==0 && isempty(idxDET)
    Rad_Sig_Rec_Cfs_CB(handles.Rad_Sig_CLU,[],handles);
    typSIG = 's';
end
%------------------------------------------------------------------------
function distNAME = get_distNAME(Pop,valPOP) %#ok<DEFNU>

contents = get(Pop,'String');
if nargin<2 , valPOP = get(Pop,'Value'); end
distNAME = contents{valPOP};
%--------------------------------------------------------------------------
function Pus_YScale_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

current = get(hObject,'UserData');
switch current
    case 'linear' , new = 'log';     pointerTYPE = '';
    case 'log'    , new = 'linear';  pointerTYPE = 'H';
end
strPUS = ['Yscale ' current];
set(hObject,'String',strPUS,'UserData',new);
set(handles.Axe_DEN_ALL,'Yscale',new);
Line_SEL = findobj(handles.Axe_DEN_ALL,'Type','line','Tag','Line_DEN_SEL');
if ~isempty(Line_SEL)
    setappdata(Line_SEL,'selectPointer',pointerTYPE)
end
if isequal(new,'linear')
    xLim_ORI = get(handles.Sli_XScale,'UserData');
    if ~isempty(xLim_ORI)
        set(handles.Axe_DEN_ALL,'XLim',xLim_ORI);
        set([handles.Sli_XScale,handles.Sli_XPos],'Value',0);
    end
end
%--------------------------------------------------------------------------
function Sli_XScale_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

linInAxe = findobj(handles.Axe_DEN_ALL,'Type','line');
if isempty(linInAxe) , set(hObject,'Value',0); return; end

dilFACT = 20;
sli_VAL = get(hObject,'Value');
xLim_ORI = get(hObject,'UserData');
if isempty(xLim_ORI)
    xLim_ORI = get(handles.Axe_DEN_ALL,'XLim');
    set(hObject,'UserData',xLim_ORI);
    xLim_Cur = xLim_ORI;
else
    xLim_Cur = get(handles.Axe_DEN_ALL,'XLim');
end
xLim_New = xLim_Cur(1) + xLim_ORI/(1+dilFACT*sli_VAL);
set(handles.Axe_DEN_ALL,'XLim',xLim_New);
%--------------------------------------------------------------------------
function Sli_XPos_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

linInAxe = findobj(handles.Axe_DEN_ALL,'Type','line');
if isempty(linInAxe) , set(hObject,'Value',0); return; end

sli_VAL = get(hObject,'Value');
xLim_Cur = get(handles.Axe_DEN_ALL,'XLim');
xLim_Ori = get(handles.Sli_XScale,'UserData');
if isempty(xLim_Ori)
    xLim_Ori = get(handles.Axe_DEN_ALL,'XLim');
    set(handles.Sli_XScale,'UserData',xLim_Ori);
end
rangeVAL = (xLim_Cur(2)-xLim_Cur(1));
xLim_New(1) = xLim_Ori(1)+(xLim_Ori(2)-xLim_Ori(1))*sli_VAL;
xLim_New(2) = xLim_New(1)+rangeVAL;
extra_Lim   = xLim_New(2)-xLim_Ori(2);
if extra_Lim>0 , xLim_New = xLim_New-extra_Lim; end
set(handles.Axe_DEN_ALL,'XLim',xLim_New);
%--------------------------------------------------------------------------
function pos_PAN = Set_Pos_Pan(hObject,eventdata,handles,typeCALL) %#ok<INUSL>

usr = get(handles.Pan_VISU_SIG,'UserData');
if isempty(usr)
    hdl_Names = {...
        'Pan_VISU_SIG' ,      'Pan_VISU_DEC' ,    ...
        'Pan_Dendro_VISU' ,   'Pan_Dendro_LINK' , ...
        'Pan_Selected_DATA' , 'Pan_View_METH',    ...
        'Pan_View_PART' ...
        };
    nbFields  = length(hdl_Names);
    hdl_PAN   = zeros(nbFields,1);
    pos_CLOSE = zeros(nbFields,4);
    for k = 1:nbFields
        hdl_PAN(k) = handles.(hdl_Names{k});
        pos_CLOSE(k,1:4) = get(hdl_PAN(k),'Position');
    end
    pos_OPEN      = pos_CLOSE;
    pos_OPEN(1,2) = pos_CLOSE(2,2);
    pos_OPEN(4,2) = pos_OPEN(1,2);
    pos_OPEN(5,1) = pos_CLOSE(2,1);
    pos_OPEN_NEW = pos_CLOSE;
    pos_OPEN_NEW(3,1) = pos_OPEN(1,1);
    pos_OPEN_NEW(3,2) = pos_OPEN(2,2);
    set(handles.Pan_VISU_SIG,'UserData',...
        {hdl_PAN,pos_CLOSE,pos_OPEN,pos_OPEN_NEW});
else
    hdl_PAN   = usr{1};
    pos_CLOSE = usr{2};
    pos_OPEN  = usr{3}; %#ok<NASGU>
    pos_OPEN_NEW = usr{4};
end

switch typeCALL
    case 'Show_DEC'  ,
        pos_PAN = pos_CLOSE;
        vis_Dendro_VISU = 'Off';
        vis_View_METH   = 'Off';
        vis_View_PART   = 'Off';
        
    case {'Close_DEC','Open_CLU'}
        fig = handles.Current_Fig;
        tool_STATE = blockdatamngr('get',fig,'tool_ATTR','State');
        if isequal(tool_STATE,'INI')
            pos_PAN = pos_CLOSE;
            vis_Dendro_VISU = 'Off';
            vis_View_METH   = 'Off';
            vis_View_PART   = 'Off';
        else
            % pos_PAN = pos_OPEN;
            pos_PAN = pos_OPEN_NEW;
            vis_Compare = lower(get(handles.Pan_PART_MNGR,'Visible'));
            if isequal(vis_Compare,'off')
                numMETH = get(handles.Pop_CLU_METH,'Value');
                if isequal(numMETH,1)
                    vis_Dendro_VISU = 'On';
                    vis_View_METH   = 'Off';
                    vis_View_PART   = 'Off';
                else
                    vis_Dendro_VISU = 'Off';
                    vis_View_METH   = 'On';
                    vis_View_PART   = 'Off';
                end
            else
                vis_Dendro_VISU = 'Off';
                vis_View_METH   = 'Off';
                vis_View_PART   = 'On';
            end
        end
        set(handles.Pan_VISU_DEC,'Visible','Off')
        set(handles.Pan_VISU_SIG,'Visible','On')
end
for k=1:length(hdl_PAN) , set(hdl_PAN(k),'Position',pos_PAN(k,:)); end
set(handles.Pan_Dendro_VISU,'Visible',vis_Dendro_VISU);
set(handles.Pan_View_METH,'Visible',vis_View_METH);
set(handles.Pan_View_PART,'Visible',vis_View_PART);
%--------------------------------------------------------------------------
function Rad_Ori_DorC_Res_CB(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

usr = get(hObject,'UserData');
rad = [handles.Rad_Ori_CLU , handles.Rad_DorC_CLU , handles.Rad_Res_CLU];
idx = find(rad==hObject);
val = zeros(1,3);
val(idx) = 1;
for k = 1:3 , set(rad(k),'Value',val(k)); end
if isequal(usr,val) , return; end
set(rad,'UserData',val);
flagENA_1 = 0;
flagENA_2 = 0;
if idx~=3
    if ~isempty(usr) , idx_OLD = find(usr); else idx_OLD = 1; end
    if idx_OLD==3
        flagENA_1 = 1;
        flagENA_2 = get(handles.Rad_Sig_CLU,'Value')==0;
        if flagENA_1 , enaVAL = 'On'; end
    end
else
    flagENA_1 = 1; flagENA_2 = 1; enaVAL = 'Off';
end
if flagENA_1
    toENA_1 = [...
        handles.Rad_Sig_CLU,handles.Rad_Rec_CLU,handles.Rad_Cfs_CLU];
    toENA_2 = [...
        handles.Txt_APP_CLU,handles.Pop_APP_CLU,...
        handles.Fra_DET_CLU,handles.Txt_DET_CLU,handles.Chk_DET_CLU,...
        handles.Pus_DET_CLU_All_None];
    set(toENA_1,'Enable',enaVAL);
    if flagENA_2 , set(toENA_2,'Enable',enaVAL); end
end
%--------------------------------------------------------------------------
function Rad_Sig_Rec_Cfs_CB(hObject,eventdata,handles) %#ok<INUSL>

usr = get(hObject,'UserData');
rad = [handles.Rad_Sig_CLU , handles.Rad_Rec_CLU , handles.Rad_Cfs_CLU];
idx = find(rad==hObject);
val = zeros(1,3);
val(idx) = 1;
for k = 1:3 , set(rad(k),'Value',val(k)); end
if isequal(usr,val) , return; end
set(rad,'UserData',val);

% Keep used Chk_DET
level = str2double(get(handles.Edi_Lev,'String'));
num_Chk_DET_CLU = str2double(get(handles.Chk_DET_CLU,'String'));
handles.Chk_DET_CLU(num_Chk_DET_CLU>level) = [];

flagENA = 0;
if idx~=1
    if ~isempty(usr) , idx_OLD = find(usr); else idx_OLD = 1; end
    if idx_OLD==1 , flagENA = 1; enaVAL = 'On'; end
else
    flagENA = 1; enaVAL = 'Off';
end
if flagENA
    toENA = [...
        handles.Txt_APP_CLU,handles.Pop_APP_CLU,...
        handles.Fra_DET_CLU,handles.Txt_DET_CLU,handles.Chk_DET_CLU,...
        handles.Pus_DET_CLU_All_None];
    set(toENA,'Enable',enaVAL);
end
%--------------------------------------------------------------------------
function Pop_APP_CLU_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

%--------------------------------------------------------------------------
function Chk_DET_CLU_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

%--------------------------------------------------------------------------
function Pus_DET_All_None_CB(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

% Keep used Chk_DET
level = str2double(get(handles.Edi_Lev,'String'));
num_Chk_DET_CLU = str2double(get(handles.Chk_DET_CLU,'String'));
handles.Chk_DET_CLU(num_Chk_DET_CLU>level) = [];
udVAL = get(hObject,'UserData');
if isempty(udVAL) , udVAL = 0; end
valCHK = 1-udVAL;
switch valCHK
    case 0 , newSTR = 'All';
    case 1 , newSTR = 'None';
end
set(hObject,'UserData',valCHK);
% pusSTR = lower(get(hObject,'String'));
% switch pusSTR
%     case 'all'  , valCHK = 1; newSTR = 'None';
%     case 'none' , valCHK = 0; newSTR = 'All';
% end
set(handles.Chk_DET_CLU,'Value',valCHK);
set(hObject,'String',newSTR)
%--------------------------------------------------------------------------
function Pus_PART_MNGR_Callback(hObject,eventdata,handles,varargin)

usr = get(hObject,'UserData');
if isempty(usr) || isequal(usr{1},'to_open')
    option = 'to_open';
else
    option = 'to_close';
end
fig = handles.Current_Fig;
callingFIG = blockdatamngr('get',fig,'fig_Storage','callingFIG');
SET_of_Partitions = wtbxappdata('get',callingFIG,'SET_of_Partitions');
curPART_notStored = ...
    isequal(lower(get(handles.Pus_PART_STORE(1),'Enable')),'on');
hdl_Menus = wtbxappdata('get',fig,'hdl_Menus');
m_PART_1 = hdl_Menus.m_PART;
hdl_Menus = wtbxappdata('get',callingFIG,'hdl_Menus');
m_PART_2 = hdl_Menus.m_PART;
v_ON_OFF = [handles.Pan_CLU_Params,handles.Pus_PART_STORE(1)];
switch option
    case 'to_open'
        map = get(fig,'Colormap');
        wtbxappdata('set',callingFIG,'Saved_Color_MAP',map);
        ena_DEL = 'On';
        if curPART_notStored
            current_PART = wtbxappdata('get',fig,'current_PART');
            nbPART = length(SET_of_Partitions);
            if nbPART>0
                SET_of_Partitions(nbPART+1) = current_PART;
            else
                SET_of_Partitions = current_PART;
                ena_DEL = 'Off';
            end
            wtbxappdata('set',callingFIG,'SET_of_Partitions',SET_of_Partitions);
        end
        active_PART = SET_of_Partitions(1);
        wtbxappdata('set',fig,'active_PART',active_PART);
        names = getpartnames(SET_of_Partitions);
        set(handles.Lst_LST_PART,'Value',[],'String',names);
        pan_HDL = [...
            handles.Pan_Dendro_VISU, ...
            handles.Pan_Dendro_LINK, ...
            handles.Pan_LST_DATA,    ...
            handles.Pan_View_PART,   ...
            handles.Pan_View_METH,   ...
            handles.Pan_DAT_to_CLU   ...
            ];
        vis_PAN = get(pan_HDL,'Visible');
        uic_DAT = findobj(handles.Pan_DAT_to_CLU,'Enable','On');
        uic_DAT = uic_DAT(:)';
        to_ENA  = [handles.Pus_CloseWin,uic_DAT,m_PART_1,m_PART_2];
        pos_Pan_PART_MNGR = get(handles.Pan_PART_MNGR,'Position');
        pos_PART_MNGR  = get(handles.Pus_PART_MNGR,'Position');
        pos_NEW = pos_PART_MNGR;
        pos_NEW(2) = pos_Pan_PART_MNGR(2)-1.5*pos_PART_MNGR(4);
        set(handles.Pus_PART_MNGR,...
            'Position',pos_NEW,...
            'String',getWavMSG('Wavelet:mdw1dRF:Close_PART_MNGR'), ...
            'UserData',{'to_close',pan_HDL,vis_PAN,uic_DAT})
        set([pan_HDL,v_ON_OFF],'Visible','Off');
        Set_ena_hdl_SAV_MORE(handles,'On')
        hdl_DEL = ...
            [handles.Pus_ALL_DEL,handles.Pus_CUR_DEL,handles.Txt_DEL_PART];
        set(hdl_DEL,'Enable',ena_DEL)
        set(handles.Pan_PART_MNGR,'Visible','On')
        set(to_ENA,'Enable','Off')
        
    case 'to_close'
        mngmbtn('delLines',fig,'All');
        map = wtbxappdata('get',callingFIG,'Saved_Color_MAP');
        wtbxappdata('set',fig,'active_PART',[]);
        pos_PART_STORE = get(handles.Pus_PART_STORE(1),'Position');
        pos_PART_MNGR  = get(handles.Pus_PART_MNGR,'Position');
        pos_NEW = pos_PART_STORE;
        pos_NEW(2) = pos_NEW(2)-pos_PART_MNGR(4);
        set(handles.Pus_PART_MNGR,...
            'Position',pos_NEW, ...
            'String',getWavMSG('Wavelet:mdw1dRF:Open_PART_MNGR'));
        pan_HDL = usr{2};
        vis_PAN = usr{3};
        uic_DAT = usr{4};
        usr{1}  = 'to_open';
        set(handles.Pus_PART_MNGR,'UserData',usr)
        to_ENA  = [handles.Pus_CloseWin,uic_DAT,m_PART_1,m_PART_2];
        set(handles.Pan_PART_MNGR,'Visible','Off')
        for k = 1:length(pan_HDL)
            set(pan_HDL(k),'Visible',vis_PAN{k});
        end
        colormap(map)
        drawnow
        set(v_ON_OFF,'Visible','On');
        set(to_ENA,'Enable','On')
        nbPART = length(SET_of_Partitions);
        current_PART = wtbxappdata('get',fig,'current_PART');
        if nbPART>0 && ~isempty(current_PART)
            mdw1dafflst('CLU',hObject,eventdata,handles,'part_CLU_B',nbPART)
            part_METH = get(SET_of_Partitions(nbPART),'Method');
            plot_Partition(part_METH,handles);
        end
        
        if curPART_notStored
            if ~isempty(SET_of_Partitions)
                partNAMES = getpartnames(SET_of_Partitions);
                idxCUR = find(strcmp(partNAMES,getWavMSG('Wavelet:moreMSGRF:Curr_Part')),1);
                if ~isempty(idxCUR)
                    SET_of_Partitions(idxCUR) = [];
                    wtbxappdata('set',callingFIG, ...
                        'SET_of_Partitions',SET_of_Partitions);
                end
            end
        end
        axe_CMD = handles.Axe_VISU;
        dynvtool('init',fig,[],axe_CMD,[],[1 0],'','','','real');
        if isempty(current_PART)
            ena_CUR = 'Off';
            set(handles.Pus_PART_STORE,'Enable',ena_CUR)
        end
        if ~isempty(SET_of_Partitions)
            set(hObject,'Enable','On');
        elseif isempty(current_PART)
            set(hObject,'Enable','Off');
        end
end
%--------------------------------------------------------------------------
function Lst_LST_PART_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

%--------------------------------------------------------------------------
function Pus_PART_SEL_Callback(hObject,eventdata,handles,typeSEL) %#ok<DEFNU>

fig = handles.Current_Fig;
callingFIG = blockdatamngr('get',fig,'fig_Storage','callingFIG');
SET_of_Partitions = wtbxappdata('get',callingFIG,'SET_of_Partitions');
nbPART = length(SET_of_Partitions);
switch lower(typeSEL)
    case 'all'
        num = 1:nbPART;
        set(handles.Lst_LST_PART,'Value',num);
        manyAFF = true;
    case 'sel'
        num = get(handles.Lst_LST_PART,'Value');
        manyAFF = length(num)>1;
end
set(handles.Pus_CUR_SEL,'UserData',num);
if isempty(num) , return; end

dispMode_VIS = mdw1dmngr('getDispMode',handles.Pop_VisPanMode);
if ~isequal(dispMode_VIS,'sup')
    set(handles.Pop_Show_Mode,'Value',1);
    mdw1dmngr('setDispMode',handles.Pop_Show_Mode,[],handles,'CLU','DEC')
end

mdw1dafflst('CLU',hObject,eventdata,handles,'partition',num)
if ~manyAFF
    active_PART = wtbxappdata('get',fig,'active_PART');
    if ~isempty(active_PART)
        wtbxappdata('set',fig,'active_PART',SET_of_Partitions(num));
    else
        error('Wavelet:FunctionToVerify:ActPart', ...
            '*** TO VERIFY: Active Part ***')
    end
    set(handles.Pan_View_PART,'Visible','Off')
    clu_METH = get(SET_of_Partitions(num),'Method');
    switch clu_METH
        case 'HT'
            V_HT = 'On'; V_KM = 'Off';
            plot_Dendrogram('sel',handles);
        case 'KM'
            V_HT = 'Off'; V_KM = 'On';
            plot_Kmeans('new',handles);
        case 'none'
            V_HT = 'Off'; V_KM = 'On';
            plot_NONE('new',handles);
    end
    set(handles.Pan_View_METH,'Visible',V_KM);
    set(handles.Pan_Dendro_VISU,'Visible',V_HT)
    axe_CMD = handles.Axe_VISU;
    dynvtool('init',fig,[],axe_CMD,[],[1 0],'','','','real');
    
else
    set(handles.Pan_Dendro_VISU,'Visible','Off')
    set(handles.Pan_View_METH,'Visible','Off');
    strPOP = get(handles.Lst_LST_PART,'String');
    strPOP = strPOP(num);
    set(handles.Pop_SORT_IDX,'Value',1,'String',strPOP)
    set(handles.Pan_View_PART,'Visible','On')
    nbToSHOW = length(num);
    nbSIG = length(get(SET_of_Partitions(1),'IdxCLU'));
    IdxCLU = zeros(nbSIG,nbToSHOW);
    for k = 1:nbToSHOW
        IdxCLU(:,k) = get(SET_of_Partitions(num(k)),'IdxCLU');
    end
    set(handles.Pop_SORT_IDX,'UserData',{nbPART,IdxCLU,num})
    plot_IDX_CLU(handles,nbPART,IdxCLU,num,1,true)
end
%--------------------------------------------------------------------------
function plot_IDX_CLU(handles,nbPART,IdxCLU,num,idxSEL,flagCBAR)

fig = handles.Current_Fig;
[IdxCLU,idxSORT] = sortrows(IdxCLU,idxSEL);
maxNUM   = max(max(IdxCLU));
nbToSHOW = length(num);
if nbToSHOW<2 , flagCBAR = false; end
axeCUR = handles.Axe_View_PART;
axes(axeCUR);
children = allchild(axeCUR);
if ~flagCBAR
    tag = get(children,'Tag');
    not2del = ~strcmpi(tag,'');
    children(not2del) = [];
end
delete(children);
map = getscaledmap(axeCUR,nbPART,false);
colormap(map);
hold on
for k = 1:nbToSHOW
    plot(IdxCLU(:,k),'.-','Color',map(num(k),:),'MarkerSize',16);
end
hold off
set(axeCUR,...
    'XLim',[1 length(IdxCLU)],'YLim',[1 maxNUM], ...
    'XTick',[],'XTickLabel','', ...
    'YTick',(1:maxNUM),'XTickLabel',int2str((1:maxNUM)') ...
    );
grid on
xlabel({' ',getWavMSG('Wavelet:mdw1dRF:Sorted_IDX',idxSEL)});
ylabel(getWavMSG('Wavelet:mdw1dRF:Str_Clusters'));
title(getWavMSG('Wavelet:mdw1dRF:Selected_PART'))

axe_CMD = handles.Axe_VISU;
dynvtool('init',fig,axe_CMD,axeCUR,[],[1 0],'','','mdw1dclustcoor',idxSORT);
wtbxappdata('set',fig,'dynvtool_ARGS', ...
    {axe_CMD,axeCUR,[],[1 0],'','','mdw1dclustcoor',idxSORT});

if flagCBAR
    legSTR = {};
    for k = 1:nbPART
        legSTR = [legSTR , ['P',int2str(k)]]; %#ok<AGROW>
    end
    xtick = (1 + 0.5:1:(nbPART+1));
    hBAR = colorbar('location','SouthOutside');
    posBAR = get(hBAR,'Position');
    posBAR(3) = 2*posBAR(3)/3;
    posBAR(1) = posBAR(1)+posBAR(3)/3;
    posBAR(4) = posBAR(4)/2;
    posBAR(2) = 2*posBAR(4);
    set(hBAR,'Position',posBAR);
    ud = get(hBAR,'UserData');
    ud.dynvzaxe.enable = 'Off';
    set(hBAR,'XAxisLocation','bottom',...
        'XTick',xtick,'XTickLabel',legSTR,'UserData',ud);
end
%--------------------------------------------------------------------------
function Pop_SORT_IDX_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

idxSEL = get(hObject,'Value');
usr = get(hObject,'UserData');
[nbPART,IdxCLU,num] = deal(usr{:});
plot_IDX_CLU(handles,nbPART,IdxCLU,num,idxSEL,false)
%--------------------------------------------------------------------------
function Pus_PART_DEL_Callback(hObject,eventdata,handles,typeDEL) %#ok<INUSL,DEFNU>

fig = handles.Current_Fig;
titSTR  = getWavMSG('Wavelet:mdw1dRF:Clear_PART');
Lst_STR = get(handles.Lst_LST_PART,'String');
switch lower(typeDEL)
    case 'all'
        msgSTR = getWavMSG('Wavelet:mdw1dRF:CAUTION_Clear');
        num = (1:length(Lst_STR));
        
    case 'sel'
        num = get(handles.Lst_LST_PART,'Value');
        if isempty(num) , return; end
        msgSTR = getWavMSG('Wavelet:mdw1dRF:Clear_Sel_Part');
end
currFLAG = isequal(Lst_STR{num(end)},'Current Part.');
if currFLAG ,num(end) = []; end
if isempty(num) , return; end
status = wwaitans({fig,titSTR},msgSTR,2,'Cancel');
if ~isequal(status,1) , return; end

Lst_STR(num) = [];
set(handles.Lst_LST_PART,'Value',[],'String',Lst_STR);
noPART = partsetmngr('clear_PART','PUS',fig,num);
if noPART
    h2EnaOFF = [...
        handles.Txt_DEL_PART,...
        handles.Pus_CUR_DEL,handles.Pus_ALL_DEL, ...
        handles.Txt_SEL_PART, ...
        handles.Pus_CUR_SEL,handles.Pus_ALL_SEL, ...
        handles.Txt_REN_CLU,handles.Pus_REN_CLU, ...
        handles.Pus_PART_STORE, ...
        handles.Pus_PART_SAVE,handles.Pus_PART_MORE];
    set(h2EnaOFF,'Enable','Off')
    pause(0.5);
    Pus_PART_MNGR_Callback(handles.Pus_PART_MNGR,eventdata,handles);
end
%--------------------------------------------------------------------------
function Pus_PART_SAVE_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

fig = handles.Current_Fig;
mdw1dpartmngr('Save',fig);
%--------------------------------------------------------------------------
function Pus_REN_CLU_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

fig = handles.Current_Fig;
numPART = get(handles.Lst_LST_PART,'Value');

callingFIG = blockdatamngr('get',fig,'fig_Storage','callingFIG');
SET_of_Partitions = wtbxappdata('get',callingFIG,'SET_of_Partitions');
nbPART = length(SET_of_Partitions);
nbDAT = length(get(SET_of_Partitions(1),'IdxCLU'));
tab_CLU = zeros(nbDAT,nbPART);
numORD = (1:nbPART);
numORD(numPART)= [];
numORD = [numPART numORD];
for k = 1:nbPART
    num = numORD(k);
    tab_CLU(:,k) = get(SET_of_Partitions(num),'IdxCLU');
end
Part = renumpart('col',tab_CLU);
for k = 1:nbPART
    num = numORD(k);
    SET_of_Partitions(num) = set(SET_of_Partitions(num),'clu_INFO',Part(k));
end
wtbxappdata('set',callingFIG,'SET_of_Partitions',SET_of_Partitions);
partNAMES = getpartnames(SET_of_Partitions);
current_PART = wtbxappdata('get',fig,'current_PART');
active_PART  = wtbxappdata('get',fig,'active_PART');
curName = get(current_PART,'Name');
actName = get(active_PART,'Name');
idxCUR = find(strcmp(partNAMES,curName),1);
idxACT = find(strcmp(partNAMES,actName),1);
wtbxappdata('set',fig,'current_PART',SET_of_Partitions(idxCUR));
wtbxappdata('set',fig,'active_PART',SET_of_Partitions(idxACT));
%--------------------------------------------------------------------------
function Pus_PART_MORE_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

typeCALL = get(hObject,'Type');
switch typeCALL
    case 'figure'
        fig = hObject;
        struct_CALL = wtbxappdata('get',fig,'struct_CALL');
        hObject = struct_CALL.Obj;
        
    otherwise
        fig = get(hObject,'UserData');
end
closeWIN = ~isempty(fig);
if closeWIN
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_PART_MORE');
    if ishandle(fig) , delete(fig); end
    fig = [];
else
    strPUS = getWavMSG('Wavelet:mdw1dRF:Close_Pus_PART_MORE');
    mousefrm(0,'watch');
    flagCUR = isequal(get(handles.Pus_PART_STORE(1),'Enable'),'on');
    fig = showparttool(mfilename,flagCUR);
    mousefrm(0,'arrow');
end
set(hObject,'String',strPUS,'UserData',fig);
%--------------------------------------------------------------------------
function Pop_CLU_METH_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

val = get(hObject,'Value');
usr = get(hObject,'UserData');
if isequal(val,usr) , return; end
set(hObject,'UserData',val)
if isempty(usr) && val==1 , return; end
get(handles.Pop_CLU_DIST,'String');
switch val
    case 1
        set(handles.Pan_View_METH,'Visible','Off');
        set(handles.Pan_Dendro_VISU,'Visible','On');
        StrDIST = wtranslate('ahc_dist');
        StrLINK = wtranslate('ahc_link');
        set(handles.Pop_CLU_DIST,'String',StrDIST,'Value',1);
        set(handles.Txt_CLU_LINK,'String',...
            getWavMSG('Wavelet:moreMSGRF:Linkage'));
        set(handles.Pop_CLU_LINK,'String',StrLINK,'Value',7);
        
    case {2,3,4}
        set(handles.Pan_Dendro_VISU,'Visible','Off');
        set(handles.Pan_View_METH,'Visible','On');
        set(handles.Pop_SEL_VM,'Value',1);
        StrDIST = wtranslate('kmeans_dist');
        StrLINK = wtranslate('kmeans_link');
        set(handles.Pop_CLU_DIST,'Value',1,'String',StrDIST);
        set(handles.Txt_CLU_LINK,'String', ...
            getWavMSG('Wavelet:moreMSGRF:Start'));
        set(handles.Pop_CLU_LINK,'String',StrLINK,'Value',1);
end
%--------------------------------------------------------------------------
function Pop_SEL_VM_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

opt_VM = get(hObject,'Value');
usr_VM = get(hObject,'UserData');
plotEXIST = ~isempty(usr_VM);
if plotEXIST
    struct_VM = usr_VM{2}{opt_VM};
    plotEXIST = ~isempty(struct_VM);
end
if plotEXIST
    switch opt_VM
        case 1
            set(findobj(handles.Axe_VM_DAT),'Visible','Off')
            set(findobj(handles.Axe_VM_IMG),'Visible','On')
            set(struct_VM.cBAR,'Visible','On')
            strTIT = getWavMSG('Wavelet:mdw1dRF:Part_IMG_Represent');
            
        case {2,3}
            vOF = findobj(handles.Axe_VM_IMG);
            vOF = vOF(:)';
            img_ATTR = usr_VM{2}{1};
            if ~isempty(img_ATTR) , vOF = [vOF , img_ATTR.cBAR]; end
            if opt_VM==2 ,
                idxOF = 3;
                strTIT = getWavMSG('Wavelet:mdw1dRF:Part_CLA_Represent');
            else
                idxOF = 2;
                strTIT = getWavMSG('Wavelet:mdw1dRF:Part_DAT_Represent');
            end
            hdl_OF = usr_VM{2}{idxOF};
            % G1492521 -- Obtain only handles from each of the structure array fields
            % concatenate with matlab graphics group handles in vOF.
            if ~isempty(hdl_OF)
                vOF = [vOF,...
                    hdl_OF.ptnCENT(ishandle(hdl_OF.ptnCENT)), ...
                    hdl_OF.txtCENT(ishandle(hdl_OF.txtCENT)),...
                    hdl_OF.ptnSIG(ishandle(hdl_OF.ptnSIG)),...
                    hdl_OF.cirCENT(ishandle(hdl_OF.cirCENT)) ];
                
            end
            vOF = vOF(ishandle(vOF));
            inAXE = findobj(handles.Axe_VM_DAT);
            vON = setdiff(inAXE,vOF);
            set(vOF,'Visible','Off');
            set(vON,'Visible','On')
    end
    title(strTIT,'Parent',handles.Axe_VM_DAT);
else
    plot_Kmeans('load',handles);
end

%--------------------------------------------------------------------------
function Set_ena_hdl_SAV_MORE(handles,ena)

hdl_S_M = [...
    handles.Txt_SEL_PART, ...
    handles.Pus_ALL_SEL,handles.Pus_CUR_SEL,    ...
    handles.Txt_REN_CLU,handles.Pus_REN_CLU, ...
    handles.Pus_PART_SAVE,handles.Pus_PART_MORE ...
    ];
set(hdl_S_M,'Enable',ena)
%--------------------------------------------------------------------------
function thr_DENDRO = get_thr_DENDRO(Links,NbCLU)

nbLinks = size(Links,1);
first = nbLinks-NbCLU+1;
last  = first+1;
if first>0
    thr_DENDRO = 0.5*(Links(first,3)+Links(last,3));
else
    thr_DENDRO = 0.5*Links(last,3);
end
%--------------------------------------------------------------------------
function plot_Partition(part_METH,handles)

% Delete old partition and plot new partition.
switch part_METH
    case 'HT'
        child = allchild([handles.Axe_VM_IMG,handles.Axe_VM_DAT]);
        delete(cat(1,child{:}));
        plot_Dendrogram('init',handles);
        
    case 'KM'
        child = allchild([handles.Axe_DEN_RES,handles.Axe_DEN_ALL]);
        delete(cat(1,child{:}));
        plot_Kmeans('new',handles)
end
%--------------------------------------------------------------------------
