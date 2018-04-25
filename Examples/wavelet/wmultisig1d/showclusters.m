function varargout = showclusters(varargin)
%SHOWCLUSTERS Show clusters tool (Multisignal 1D).
%   VARARGOUT = SHOWCLUSTERS(VARARGIN)

% Last Modified by GUIDE v2.5 05-Jul-2013 09:45:35
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-May-2005.
%   Last Revision 11-Jul-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2013/08/23 23:45:53 $ 

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @showclusters_OpeningFcn, ...
                   'gui_OutputFcn',  @showclusters_OutputFcn, ...
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
% --- Executes just before showclusters is made visible.                  %
%*************************************************************************%
function showclusters_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for showclusters
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
function varargout = showclusters_OutputFcn(~,~,handles)
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;
%*************************************************************************%
%                END Output Function                                      %
%*************************************************************************%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%=========================================================================%
function Init_Tool(fig,~,handles,varargin)

% Check input Parameters.
%------------------------
nbIN = length(varargin);
switch nbIN
    case 2
        callingFILE = varargin{1};
        caller = varargin{2};
        [callingOBJ,callingFIG] = gcbo;
        toolMode = 'client';
        fig_PAR  = callingFIG;
         
        fig_PAR_INFO = guidata(fig_PAR);
        fig_Storage  = fig_PAR_INFO.fig_Storage;
        % fig_Storage is a structure:
        %    [callingFIG , fig_ORI , fig_DorC , fig_SEL <=== fig_PAR]
        fig_INI      = fig_Storage.callingFIG;
        fig_INI_INFO = guidata(fig_INI);
        DirDEC = fig_INI_INFO.data_ORI.dir_DEC;
        SET_of_Partitions = wtbxappdata('get',fig_INI,'SET_of_Partitions');
        nbPART  = length(SET_of_Partitions);
        if nbPART>0
            nbSIG  = length(get(SET_of_Partitions(1),'IdxCLU'));
            TAB_Partitions = zeros(nbSIG,nbPART);
            for k = 1:nbPART
                TAB_Partitions(:,k) = get(SET_of_Partitions(k),'IdxCLU');
            end
            part_NAMES = getpartnames(SET_of_Partitions);
        else
            part_NAMES = {};
            TAB_Partitions = [];
        end
        switch caller
            case 'CLU'
                set([handles.Pop_PART_SEL,handles.Txt_PART_SEL],...
                    'Visible','Off');
            case 'PAR'
        end
        referFIG = fig_INI;
        Data_Name = get(fig_INI_INFO.Edi_Data_NS,'String');
        tool_Name = caller;
        
    case 3
        callingFILE = []; callingOBJ = []; callingFIG = [];
        toolMode = 'auto';
        [Data_Name,TAB_Partitions,DirDEC] = deal(varargin{:});
        tool_Name = 'PAR';
        referFIG = fig;        
end
if ~isempty(TAB_Partitions)
    TAB_Partitions = tab2part(TAB_Partitions);
end
nbPART = length(TAB_Partitions);

% Begin initialization.
%----------------------
set(fig,'Visible','off');
mdw1dutils('data_INFO_MNGR','create',fig,tool_Name,referFIG);

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
cb_close = ...
    [mfilename '(''Pus_CloseWin_Callback'',gcbo,[],guidata(gcbo));'];
set(m_close,'Callback',cb_close);
hdl_Menus = struct('m_files',m_files,'m_close',m_close);
wtbxappdata('set',fig,'hdl_Menus',hdl_Menus);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',fig,mfilename);

% Other Initializations.
%-----------------------
switch toolMode
    case 'auto'
        signals = msloadutl(Data_Name);
        if isequal(lower(DirDEC(1)),'c') , signals = signals'; end
        sizSIG = size(signals);
        data_SEL.sel_DAT = signals;
        data_SEL.Attrb_SEL = {0,0,0};
        mdw1dutils('data_INFO_MNGR','set',fig,'SEL',data_SEL);
        [~,name,ext] = fileparts(Data_Name);
        if isequal(ext,'.mat') , ext = ''; end
        nbSTR = int2str(sizSIG(1));
        strNAM = [name , ext , '  (' nbSTR 'x' int2str(sizSIG(2)) ...
            ') - ' nbSTR ' sig.'];
        numPART = 1:nbPART;
        part_NAMES = [repmat('Part ',nbPART,1) , int2str(numPART')];
        part_NAMES = num2cell(part_NAMES,2);

    case 'client'
        strNAM = Data_Name;
        switch caller
            case 'CLU'
                clu_INFO = ...
                    blockdatamngr('get',callingFIG,'current_PART','clu_INFO');
                nbSIG = length(clu_INFO.IdxCLU);
                TAB_Partitions = [clu_INFO , TAB_Partitions];
                part_NAMES = [getWavMSG('Wavelet:moreMSGRF:Curr_Part') ; ...
                    part_NAMES];
                data_To_Clust = wtbxappdata('get',fig_PAR,'data_To_Clust');
                wtbxappdata('set',fig,'data_To_Clust',data_To_Clust);
                set(handles.Pan_PLOT_SELECT,'Visible','On')
                nbSTR = int2str(nbSIG);
                strNAM = [strNAM , ' - ' nbSTR ' sig.'];
                
            case 'PAR'
                fig_PAR_INFO.data_SEL.sel_DAT;
                data_SEL.sel_DAT = fig_PAR_INFO.data_SEL.sel_DAT;
                data_SEL.Attrb_SEL = {0,0,0};
                mdw1dutils('data_INFO_MNGR','set',fig,'SEL',data_SEL);
        end
end

set(handles.Edi_Data_NS,'String',strNAM);
set(handles.Pop_PART_SEL,'String',part_NAMES,'Value',1);
set([handles.Pus_MEAN_MED,handles.Pus_glb_STD,handles.Pus_loc_STD], ...
    'FontWeight','bold');
TAB_Partitions = renumpart('col',TAB_Partitions);
clusters_INFO  = tab2part(TAB_Partitions(:,1));
Keep_DynV_Enabled = get(handles.Pan_ON_OFF,'Children');
struct_CALL = struct('Fig',callingFIG,'Obj',callingOBJ,'File',callingFILE);
wtbxappdata('set',fig,'struct_CALL',struct_CALL);
wtbxappdata('set',fig,'TAB_Partitions',TAB_Partitions);
wtbxappdata('set',fig,'clusters_INFO',clusters_INFO);
wtbxappdata('set',fig,'Keep_DynV_Enabled',Keep_DynV_Enabled);

showClust_FUNC(handles)
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function showClust_FUNC(handles,varargin)

nb_GRA_Max = 12;
fig = handles.Current_Fig;

% Begin waiting.
%---------------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitCompute'));

numPART = get(handles.Pop_PART_SEL,'Value');
TAB_Partitions = wtbxappdata('get',fig,'TAB_Partitions');
PART     = TAB_Partitions(numPART);
NbCLU    = PART.NbCLU;
IdxCLU   = PART.IdxCLU;
NbInCLU  = PART.NbInCLU;
IdxInCLU = PART.IdxInCLU;
Nb_AXE = min([NbCLU,nb_GRA_Max]);
Axe_CLU = handles.Axe_CLU;
set(Axe_CLU,'Visible','Off')
child = allchild(Axe_CLU);
child = cat(1,child{:});
delete(child);

if nargin<2
    usr = get(handles.Pan_Show_CLU,'UserData');
    if isempty(usr)
        pos_Axe = get(Axe_CLU,'Position');
        pos_Axe = cat(1,pos_Axe{:});
        [pos_Axe,idx] = sortrows(pos_Axe,[-2,1]);
        Axe_CLU = Axe_CLU(idx);
        set(handles.Pan_Show_CLU,'UserData',{Axe_CLU,pos_Axe});
    else
        Axe_CLU = usr{1};
        pos_Axe = usr{2};
    end
    switch Nb_AXE
        case 1
        case {2,3,4,5,6,7,8,9}
            if Nb_AXE<9 , nbX = 2; else nbX = 3; end
            nbY = ceil(Nb_AXE/nbX);
            dx  = 1/12;
            dxEnd = 1/20; 
            wA  = (1-nbX*dx-dxEnd)/nbX;
            dy1 = 1/10;  
            dy2 = 1/10; 
            dy3 = 1/16; 
            hA  = (1-dy1-(nbY-1)*dy2-dy3)/nbY; 
            yA = 1-dy1-hA;
            for k = 1:nbX:Nb_AXE
                for j = 1:nbX
                    xA = dx+(j-1)*(wA+dx);
                    set(Axe_CLU(k+j-1),'Position',[xA,yA,wA,hA]);
                end
                yA = yA-dy2-hA;
            end
            
        case {10,11,12}
            for k = 1:Nb_AXE , set(Axe_CLU(k),'Position',pos_Axe(k,:)); end
    end
    set(Axe_CLU(1:Nb_AXE),'Visible','On')
else
    usr = get(handles.Pan_Show_CLU,'UserData');
    Axe_CLU = usr{1};
end
Signaux_Traites = blockdatamngr('get',fig,'data_SEL','sel_DAT');
sig_COL = [1 0.5 0.5]; 
clu_COL = [0.4 0.6 1];
mean_COL   = [200 30 30]/255;
median_COL = mean_COL;
loc_COL    = [0.15 0.15 0.95];
gbl_COL    = [80 220  40]/255;
LW_Med     = 2;
sig_FLAG   = get(handles.Rad_SEE_CLU_SIG,'Value');
switch sig_FLAG
    case 0
        Signaux_Traites = wtbxappdata('get',fig,'data_To_Clust');
        disp_COL = clu_COL;
    case 1
        data_SEL = mdw1dutils('data_INFO_MNGR','get',fig,'SEL');
        Signaux_Traites = data_SEL.sel_DAT;
        disp_COL = sig_COL;
end
[NbSIG,NbPts] = size(Signaux_Traites);
[sdtQ1,sdtQ2,glb_STD,meanVAL,medianVAL,loc_STD] = ...
    partstdqual(PART,Signaux_Traites,1);

sigSTR = 'Sig. ';
sep    = ' - ';
cluSTR = 'Clu. ';
oneIDX = ones(NbSIG,1);
sigSTR = [sigSTR(oneIDX,:) num2str((1:NbSIG)','%4.0f') ...
    sep(oneIDX,:)  cluSTR(oneIDX,:) num2str(IdxCLU(:),'%3.0f')];
sigSTR = num2cell(sigSTR,2);
strPOP  = ['none' ; sigSTR];
set(handles.Pop_HIG_CLU,'String',strPOP,'Value',1)
set([handles.Txt_HIG_CLU,handles.Pop_HIG_CLU],'Enable','On');
title_STR = getWavMSG('Wavelet:mdw1dRF:Edi_TIT_Show_CLU',numPART,NbCLU);
set(handles.Pan_Show_CLU,'title',formatPanTitle(title_STR));

if NbCLU<=nb_GRA_Max
    idx_CLA = (1:NbCLU);
    last = NbCLU;
else
    [~,idx_CLA] = sort(NbInCLU,'descend');
    last = nb_GRA_Max-1;
end
meanFLAG = get(handles.Pus_MEAN_MED,'UserData');
vis_MEAN = 'Off'; vis_MED = 'Off';
vis_SIG  = get(handles.Pus_SIG_OnOff,'UserData');
if isempty(vis_SIG) , vis_SIG  = 'On'; end
if meanFLAG
    view_MEAN_MED = get(handles.Rad_MEAN,'UserData');
    switch view_MEAN_MED
        case 1 , vis_MEAN = 'On';
        case 2 , vis_MED  = 'On';
    end
end
loc_stdFLAG = get(handles.Pus_loc_STD,'UserData');
switch loc_stdFLAG
    case 0 , vis_loc_STD = 'Off';
    case 1 , vis_loc_STD = 'On';
end
glb_stdFLAG = get(handles.Pus_glb_STD,'UserData');
switch glb_stdFLAG
    case 0 , vis_glb_STD = 'Off';
    case 1 , vis_glb_STD = 'On';
end
nbSTD = get(handles.Rad_loc_STD(1),'UserData');

p_lin_LOC_STD = {...
    'LineWidth',2,'Color',loc_COL,'LineStyle','-',...
    'Visible',vis_loc_STD,'Tag','lin_LOC_STD'};
p_lin_GLB_STD = {...
    'LineWidth',2,'Color',gbl_COL,'LineStyle','-',...
    'Visible',vis_glb_STD,'Tag','lin_GLB_STD'};

set(fig,'HandleVisibility','On')
formatPER = '%5.2f';
for k = 1:last
    num = idx_CLA(k);
    nbIN = NbInCLU(num);
    strPER = [num2str(100*nbIN/NbSIG,formatPER) '%'];
    strT1 = ['Class ' int2str(num) '  -  Nb ' int2str(nbIN) '  -  ' strPER];
    strT1 = [strT1 '  --  D = ' num2str(glb_STD(num),'%9.3f')]; %#ok<*AGROW>
    strT2 = ['Q1 = 1 - D / max = ' num2str(sdtQ1(num),'%6.3f')];
    if last<9
        strT2 = [strT2, ...
            '  --  Q2 = D / (max-min) = ' num2str(sdtQ2(num),'%6.3f') , '' ];
    end
    strTIT = {strT1 , strT2};
      
    axe = Axe_CLU(k);
    set(axe,'Visible','On');
    axes(axe) %#ok<*LAXES>
    sigToPLOT = Signaux_Traites(IdxInCLU{num},:);
    plot((1:NbPts),sigToPLOT','Color',disp_COL,...
        'Visible',vis_SIG,'Tag','Signals');
    if NbPts>1 , xlim = [1 NbPts]; else xlim = [0.99 1.01]; end
    set(axe,'XLim',xlim);
    title(axe,strTIT);
    old = get(axe,'NextPlot');
    % Ylim = get(axe,'YLim');
    set(axe,'NextPlot','add');
    plot((1:NbPts),meanVAL(num,:)+nbSTD*loc_STD(num,:),p_lin_LOC_STD{:});
    plot((1:NbPts),meanVAL(num,:)-nbSTD*loc_STD(num,:),p_lin_LOC_STD{:});
    plot((1:NbPts),meanVAL(num,:)+nbSTD*glb_STD(num),p_lin_GLB_STD{:});
    plot((1:NbPts),meanVAL(num,:)-nbSTD*glb_STD(num),p_lin_GLB_STD{:});
    plot((1:NbPts),meanVAL(num,:),'LineWidth',LW_Med,'Color',mean_COL,...
          'Visible',vis_MEAN,'Tag','lin_MEAN',...
          'UserData',{loc_STD(num,:),glb_STD(num)});
    plot((1:NbPts),medianVAL(num,:),'LineWidth',LW_Med,...
         'Color',median_COL ,'Visible',vis_MED,'Tag','lin_MED');    
    set(axe,'NextPlot',old);
    sigToPLOT = [...
        sigToPLOT ; ...
        meanVAL(num,:)+2*glb_STD(num); ...
        meanVAL(num,:)-2*glb_STD(num)];    
    [yMini,yMaxi] = getMinMax(sigToPLOT,0,0.01);
    set(axe,'YLim',[yMini,yMaxi]);
end

if last<NbCLU
    indices = idx_CLA(nb_GRA_Max:NbCLU) ;
    idxToPlot = cat(1,IdxInCLU{indices});
    eff     = length(idxToPlot);
    strPER = [num2str(100*eff/NbSIG,formatPER) '%'];
    strTIT  = getWavMSG('Wavelet:mdw1dRF:Tit_Remaining_Classes', ...
        NbCLU-last,eff,strPER);    
    axe = Axe_CLU(nb_GRA_Max);
    set(axe,'Visible','On');
    axes(axe) %#ok<*MAXES>
    plot((1:NbPts),Signaux_Traites(idxToPlot,:)','Color',disp_COL);
    set(axe,'XLim',[1 NbPts]);
    title(axe,strTIT,'Color','r');
end

dynvtool('get',fig,0);
axe_IND = [];
axe_CMD = Axe_CLU;
axe_ACT = [];
dynvtool('init',fig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','','real');
set(handles.Pan_Show_CLU,'Visible','On')
set(fig,'HandleVisibility','Callback')

% End waiting.
%-------------
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Pus_SIG_OnOff_Callback(hObject,eventdata,handles) %#ok<*INUSL,*DEFNU>

Axe_CLU = handles.Axe_CLU;
lin_SIG = findobj(Axe_CLU,'Type','line','Tag','Signals');
vis = get(lin_SIG(1),'Visible');
switch lower(vis)
    case 'on'  
        vis = 'Off'; strPUS = getWavMSG('Wavelet:mdw1dRF:Signals_ON');
    case 'off'
        vis = 'On';  strPUS = getWavMSG('Wavelet:mdw1dRF:Signals_OFF');
end
set(lin_SIG,'Visible',vis);
set(hObject,'String',strPUS,'UserData',vis);
%--------------------------------------------------------------------------
function Pop_PART_SEL_Callback(hObject,eventdata,handles)

val = get(hObject,'Value');
usr = get(hObject,'UserData');
if isequal(val,usr), return; end
set(hObject,'UserData',val);

TAB_Partitions = wtbxappdata('get',hObject,'TAB_Partitions');
wtbxappdata('set',hObject,'clusters_INFO',TAB_Partitions(val));
showClust_FUNC(handles)
%--------------------------------------------------------------------------
function Pus_MEAN_MED_Callback(hObject,eventdata,handles)

meanFLAG = get(hObject,'UserData');
meanFLAG = 1-meanFLAG;
vis_MEAN = 'Off'; 
vis_MED  = 'Off';
switch meanFLAG
    case 0
        ena = 'Off'; str_PUS = getWavMSG('Wavelet:mdw1dRF:Str_ON');
    case 1 
        ena = 'On';  str_PUS = getWavMSG('Wavelet:mdw1dRF:Str_OFF');
        view_MEAN_MED = get(handles.Rad_MEAN,'UserData');
        switch view_MEAN_MED
            case 1 , vis_MEAN = 'On';
            case 2 , vis_MED  = 'On';
        end        
end
set([handles.Rad_MEAN,handles.Rad_MED],'Enable',ena);
set(hObject,'UserData',meanFLAG,'String',str_PUS);
Axe_CLU = handles.Axe_CLU;
LMean = findobj(Axe_CLU,'Type','line','Tag','lin_MEAN');
LMed  = findobj(Axe_CLU,'Type','line','Tag','lin_MED');
lin_ON_OFF(LMean,vis_MEAN)
lin_ON_OFF(LMed,vis_MED)
%--------------------------------------------------------------------------
function Rad_MEAN_MED_Callback(hObject,eventdata,handles)

Rad = [handles.Rad_MEAN,handles.Rad_MED];
view_MEAN_MED = find(Rad==hObject);
old_VIEW = get(Rad(1),'UserData');
set(Rad,'Value',0,'UserData',view_MEAN_MED);
set(hObject,'Value',1);
if isequal(view_MEAN_MED,old_VIEW)
    return;
end

switch view_MEAN_MED
    case 1 , vis_MEAN = 'On'; vis_MED  = 'Off';
    case 2 , vis_MED  = 'On'; vis_MEAN = 'Off'; 
end
Axe_CLU = handles.Axe_CLU;
LMean = findobj(Axe_CLU,'Type','line','Tag','lin_MEAN');
LMed  = findobj(Axe_CLU,'Type','line','Tag','lin_MED');
lin_ON_OFF(LMean,vis_MEAN)
lin_ON_OFF(LMed,vis_MED)
strGLB = get(handles.Txt_glb_STD,'String');
strLOC = get(handles.Txt_loc_STD,'String');
switch view_MEAN_MED
    case 1 , addSTR = getWavMSG('Wavelet:mdw1dRF:Str_Mean');
    case 2 , addSTR = getWavMSG('Wavelet:mdw1dRF:Str_Med');
end
strGLB{1} = [addSTR '  +  n * D'];
strLOC{1} = [addSTR '  +  n * P'];
set(handles.Txt_glb_STD,'String',strGLB);
set(handles.Txt_loc_STD,'String',strLOC);
glb_stdFLAG = get(handles.Pus_glb_STD,'UserData');
if glb_stdFLAG
    Rad = handles.Rad_glb_STD;
    valRad = get(Rad,'Value');
    Rad = Rad(cat(1,valRad{:})>0);
    Rad_glb_STD_Callback(Rad,eventdata,handles)
end
loc_stdFLAG = get(handles.Pus_loc_STD,'UserData');
if loc_stdFLAG
    Rad = handles.Rad_loc_STD;
    valRad = get(Rad,'Value');
    Rad = Rad(cat(1,valRad{:})>0);
    Rad_loc_STD_Callback(Rad,eventdata,handles)    
end
%--------------------------------------------------------------------------
function Pus_loc_STD_Callback(hObject,eventdata,handles)

loc_stdFLAG = get(hObject,'UserData');
loc_stdFLAG = 1-loc_stdFLAG;
switch loc_stdFLAG
    case 0 , vis = 'Off'; str_PUS = getWavMSG('Wavelet:mdw1dRF:Str_ON');
    case 1 , vis = 'On';  str_PUS = getWavMSG('Wavelet:mdw1dRF:Str_OFF');
end
set(hObject,'UserData',loc_stdFLAG,'String',str_PUS);
Rad = handles.Rad_loc_STD;
set(Rad,'Enable',vis);
Axe_CLU = handles.Axe_CLU;
L = findobj(Axe_CLU,'Type','line','Tag','lin_LOC_STD');
if isempty(L) , return; end
lin_ON_OFF(L,vis)
%--------------------------------------------------------------------------
function Rad_loc_STD_Callback(hObject,eventdata,handles)

S = get(hObject,'String'); S(S>'9') = [];
num = str2double(S);
Rad = handles.Rad_loc_STD;
set(Rad,'Value',0,'UserData',num);
set(hObject,'Value',1);
val_MEAN_MED = get(handles.Rad_MEAN,'Value');
switch val_MEAN_MED
    case 0 , TagSTR = 'lin_MED';
    case 1 , TagSTR = 'lin_MEAN';
end
Axe_CLU = handles.Axe_CLU;
LM = findobj(Axe_CLU,'Type','line','Tag',TagSTR);
LM_Std = findobj(Axe_CLU,'Type','line','Tag','lin_MEAN');
if isempty(LM) , return; end
for k = 1:length(LM)
    axe = get(LM(k),'Parent');
    Ylim = get(axe,'YLim');
    LS = findobj(axe,'Type','line','Tag','lin_LOC_STD');
    mean_OR_med_VAL = get(LM(k),'YData');
    usr = get(LM_Std(k),'UserData');
    std_VAL = usr{1};
    set(LS(1),'YData',mean_OR_med_VAL - num*std_VAL);
    set(LS(2),'YData',mean_OR_med_VAL + num*std_VAL);
    set(axe,'YLim',Ylim);
end
%--------------------------------------------------------------------------
function Pus_glb_STD_Callback(hObject,eventdata,handles)

glb_stdFLAG = get(hObject,'UserData');
glb_stdFLAG = 1-glb_stdFLAG;
switch glb_stdFLAG
    case 0 , vis = 'Off'; str_PUS = getWavMSG('Wavelet:mdw1dRF:Str_ON');
    case 1 , vis = 'On';  str_PUS = getWavMSG('Wavelet:mdw1dRF:Str_OFF');
end
set(hObject,'UserData',glb_stdFLAG,'String',str_PUS);
Rad = handles.Rad_glb_STD;
set(Rad,'Enable',vis);
Axe_CLU = handles.Axe_CLU;
L = findobj(Axe_CLU,'Type','line','Tag','lin_GLB_STD');
if isempty(L) , return; end
for k = 1:length(L)
    axe = get(L(k),'Parent');
    YLim = get(axe,'YLim');
    set(L(k),'Visible',vis);
    set(axe,'YLim',YLim);
end
%--------------------------------------------------------------------------
function Rad_glb_STD_Callback(hObject,eventdata,handles)

S = get(hObject,'String'); S(S>'9') = [];
num = str2double(S);
Rad = handles.Rad_glb_STD;
set(Rad,'Value',0,'UserData',num);
set(hObject,'Value',1);
val_MEAN_MED = get(handles.Rad_MEAN,'Value');
switch val_MEAN_MED
    case 0 , TagSTR = 'lin_MED';
    case 1 , TagSTR = 'lin_MEAN';
end
Axe_CLU = handles.Axe_CLU;
LM = findobj(Axe_CLU,'Type','line','Tag',TagSTR);
LM_Std = findobj(Axe_CLU,'Type','line','Tag','lin_MEAN');
if isempty(LM_Std) , return; end
for k = 1:length(LM)
    axe = get(LM(k),'Parent');
    Ylim = get(axe,'YLim');
    LS = findobj(axe,'Type','line','Tag','lin_GLB_STD');
    mean_OR_med_VAL = get(LM(k),'YData');
    usr = get(LM_Std(k),'UserData');
    std_VAL = usr{2};
    set(LS(1),'YData',mean_OR_med_VAL-num*std_VAL);
    set(LS(2),'YData',mean_OR_med_VAL+num*std_VAL);
    set(axe,'YLim',Ylim);
end
%--------------------------------------------------------------------------
function lin_ON_OFF(L,vis)

for k = 1:length(L)
    axe = get(L(k),'Parent');
    YLim = get(axe,'YLim');
    set(L(k),'Visible',vis);
    set(axe,'YLim',YLim);
end
%--------------------------------------------------------------------------
function Pus_CloseWin_Callback(hObject,eventdata,handles)

fig = handles.output;
struct_CALL = wtbxappdata('get',fig,'struct_CALL');
if ishandle(struct_CALL.Fig)
    feval(struct_CALL.File,'Pus_CLU_SHOW_Callback',fig,[],handles);
else
    delete(fig);
end
%--------------------------------------------------------------------------
function Pop_HIG_Callback(hObject,eventdata,handles)

fig = handles.Current_Fig;
valPOP = get(hObject,'Value');
strPOP = get(hObject,'String');
strPOP = strPOP{valPOP};
idx = strfind(strPOP,'-');
if ~isempty(idx) , strPOP = strPOP(1:idx-1); end
strPOP(abs(strPOP)<48 | abs(strPOP)>57) = [];
idxSEL = str2double(strPOP);
axeAct = handles.Axe_CLU;
old_LINE = findobj(axeAct,'Tag','Line_HIG');
if ~isempty(old_LINE) , delete(old_LINE); end
if ~isnan(idxSEL)
    line_Attrb = {'LineWidth',2,'Tag','Line_HIG'};
    usr = get(handles.Pan_Show_CLU,'UserData');
    Axe_CLU = usr{1};
    axeAct = Axe_CLU;
    [NbCLU,IdxCLU,NbInCLU] = ...
        blockdatamngr('get',fig,'clusters_INFO','NbCLU','IdxCLU','NbInCLU');
    IdxCLU_SEL = IdxCLU(idxSEL);
    if NbCLU<13
        axeCLA = axeAct(IdxCLU_SEL);
    else
        numCLU = (1:NbCLU)';
        [~,idxSORT] = sort(NbInCLU,'descend');
        numCLU = numCLU(idxSORT);
        idxAXE = find(numCLU==IdxCLU_SEL);
        if idxAXE>12 , idxAXE = 12; end
        axeCLA = axeAct(idxAXE);
    end
    sig_FLAG = get(handles.Rad_SEE_CLU_SIG,'Value');
    switch sig_FLAG
        case 0 ,
            sigDisp = wtbxappdata('get',fig,'data_To_Clust');
        case 1
            data_SEL = mdw1dutils('data_INFO_MNGR','get',fig,'SEL');
            sigDisp = data_SEL.sel_DAT;
    end
    hig_COL = 'k';
    sigDisp = sigDisp(idxSEL,:);
    lenSIG = length(sigDisp);
    axes(axeCLA);
    set(axeCLA,'NextPlot','add');
    hL = plot(1:lenSIG,sigDisp,line_Attrb{:},'Color',hig_COL);
    set(axeCLA,'NextPlot','replacechildren');
    mdw1dutils('line_Blink',hL);
end
%--------------------------------------------------------------------------
function Rad_SEE_SIG_Callback(hObject,eventdata,handles)

userdata = get(handles.Rad_SEE_CLU_SIG,'UserData');
if (hObject==handles.Rad_SEE_CLU_SIG)
    newdata = [1,0];
else
    newdata = [0,1];
end
set(handles.Rad_SEE_CLU_SIG,'Value',newdata(1))
set(handles.Rad_SEE_CLU_DAT,'Value',newdata(2))
if isequal(newdata,userdata) , return; end
set(handles.Rad_SEE_CLU_SIG,'UserData',newdata)
showClust_FUNC(handles,'Rad_SEE')
%--------------------------------------------------------------------------
function [mini,maxi] = getMinMax(val,dim,percent)

switch dim
    case {1,2}
        mini  = min(val,[],dim);
        maxi  = max(val,[],dim);
    otherwise
        mini  = min(min(val));
        maxi  = max(max(val));
end
delta = maxi-mini;
if (delta<eps) , delta = sqrt(eps); end
mini  = mini-percent*delta;
maxi  = maxi+percent*delta;
%--------------------------------------------------------------------------
function S = formatPanTitle(S)

S = ['   ' S '   .'];
%--------------------------------------------------------------------------
