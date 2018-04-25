function varargout = showparttool(varargin)
%SHOWPARTTOOL Show partitions tool (Multisignal 1D).
%   VARARGOUT = SHOWPARTTOOL(VARARGIN)

% Last Modified by GUIDE v2.5 24-Sep-2006 15:31:20
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2005.
%   Last Revision: 12-Nov-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.10.4.1 $ $Date: 2014/01/04 07:40:10 $ 

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @showparttool_OpeningFcn, ...
                   'gui_OutputFcn',  @showparttool_OutputFcn, ...
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
end
%*************************************************************************%
%                END initialization code - DO NOT EDIT                    %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Opening Function                                   %
%                ----------------------                                   %
% --- Executes just before showparttool is made visible.                  %
%*************************************************************************%
function showparttool_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for showparttool
handles.output = hObject;

% Update handles structure
guidata(hObject,handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manualy in the automatic generated code  %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles,varargin{:});
end
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%

%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = showparttool_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;
end
%*************************************************************************%
%                END Output Function                                      %
%*************************************************************************%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%=========================================================================%
function Men_save_FUN(hObject,eventdata,handles,MODE) %#ok<INUSL>

% Get figure handle.
%-------------------
fig = handles.output;

% Testing file.
%--------------
TabPART = wtbxappdata('get',fig,'TAB_Partitions');
nbPART  = length(TabPART);
varName = {};
if isequal(MODE,0) || isequal(MODE,2)
    strDLG  = getWavMSG('Wavelet:mdw1dRF:Save_TabPART');
    Tab_IdxCLU = part2tab(TabPART); %#ok<NASGU>
    LNK_SIM = wtbxappdata('get',fig,'LNK_SIM_STRUCT'); %#ok<NASGU>
    varName = [varName ,'Tab_IdxCLU','LNK_SIM'];
end
if isequal(MODE,1) || isequal(MODE,2)
    strDLG = getWavMSG('Wavelet:mdw1dRF:Save_QualInd');
    signals = ...
        blockdatamngr('get',fig,'data_SEL','sel_DAT');
    Std_Quality = wtbxappdata('get',fig,'Std_Quality');
    if isempty(Std_Quality)
        [stdQ1,stdQ2,glbSTD] = partstdqual(TabPART,signals);
        Std_Quality = {stdQ1,stdQ2,glbSTD}; %#ok<NASGU>
        wtbxappdata('set',fig,'Std_Quality',{stdQ1,stdQ2,glbSTD});
    else
        [stdQ1,stdQ2,glbSTD] = deal(Std_Quality{:}); %#ok<ASGLU,NASGU>
    end
    varName = [varName,'stdQ1','stdQ2','glbSTD'];
    %--------------------------------------------------------------
    BetweenWithin = wtbxappdata('get',fig,'BetweenWithin');
    if isempty(BetweenWithin)
        [inter_SUR_intra,inter_SUR_intra_N,inter,intra] = ...
            partbetweenwithin(signals,TabPART);
        wtbxappdata('set',fig,'BetweenWithin',...
            {inter_SUR_intra,inter_SUR_intra_N,inter,intra});
    else
        [inter_SUR_intra,inter_SUR_intra_N,inter,intra] = ...
            deal(BetweenWithin{:}); %#ok<ASGLU,NASGU>
    end
    varName = [varName ,...
        'inter_SUR_intra','inter_SUR_intra_N','inter','intra'];
    %--------------------------------------------------------------
    silh_VALUES = wtbxappdata('get',fig,'silh_VALUES');
    if isempty(silh_VALUES)
        h = waitbar(50,getWavMSG('Wavelet:moreMSGRF:Please_wait'));
        [silh_VAL,silh_PART] = partsilh(signals,TabPART);
        wtbxappdata('set',fig,'silh_VALUES',{silh_VAL,silh_PART});
        close(h)
    else
        [silh_VAL,silh_PART] = deal(silh_VALUES{:}); %#ok<NASGU>
    end
    MEAN_Silh = cell(1,nbPART);
    MIN_Silh  = cell(1,nbPART);
    MAX_Silh  = cell(1,nbPART);
    STD_Silh  = cell(1,nbPART);    
    for j = 1:nbPART
        MEAN_Silh{j} = silh_VAL{j}(1,:);
        MIN_Silh{j}  = silh_VAL{j}(2,:);
        MAX_Silh{j}  = silh_VAL{j}(3,:);
        STD_Silh{j}  = silh_VAL{j}(4,:);
    end
    varName = [varName ,'MEAN_Silh','silh_PART',...
        'MIN_Silh','MAX_Silh','STD_Silh'];
end
[filename,pathname,ok] = utguidiv('test_save',fig, '*.mat',strDLG);
if ~ok, return; end

% Begin waiting.
%--------------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitCompute'));

% Getting Synthesized Signal.
%---------------------------

% Saving file.
%--------------
[name,ext] = strtok(filename,'.');
if isempty(ext) || isequal(ext,'.')
    ext = '.mat'; filename = [name ext];
end

wwaiting('off',fig);
try
    save([pathname filename],varName{:});
catch %#ok<CTCH>
    errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
end
end
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%=========================================================================%
function CleanTOOL(option,eventdata,handles,varargin) %#ok<INUSL>

switch option
    case 'clu_SEL'
        Pop_SEL = [handles.Pop_SEL_1,handles.Pop_SEL_2];
        Pop_NUM = [handles.Pop_NUM_1,handles.Pop_NUM_2];
        OBJ_to_Ena = ...
            [handles.Txt_SEL_1,handles.Txt_SEL_2,Pop_SEL,...
             handles.Txt_SEL_OPER, ...
             handles.Pus_Show_SEL_AND,handles.Pus_Show_SEL_OR, ...
             handles.Pus_Show_SEL_XOR,...
             handles.Pus_Show_SEL_1_2,handles.Pus_Show_SEL_2_1];
        ena_VAL = lower(varargin{1});
        switch ena_VAL
            case 'on'  , strPOP = ['None',varargin{2}];
            case 'off' , strPOP = {'None'};
        end
        set(Pop_SEL,'String',strPOP ,'Value',1);
        set(Pop_NUM,'Enable','Off','String',{' '},'Value',1);
        set(OBJ_to_Ena,'Enable',ena_VAL)
end
end
%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%=========================================================================%
function Init_Tool(fig,eventdata,handles,varargin)

% Input Parameters.
%------------------
nbIN = length(varargin);
switch nbIN
    case 1 %%% PROVISOIRE
        tab_IdxCLU = varargin{1}{1};
        Data_Name  = varargin{1}{2};
        DirDEC     = 'r';
        [TAB_Partitions,LNK_SIM_STRUCT] = partlnkandsim(tab_IdxCLU);
        callingFILE = []; callingOBJ = []; callingFIG = [];
        nbPART  = length(TAB_Partitions);
        numPART = 1:nbPART;
        PART_Names = [repmat('Part ',nbPART,1) , int2str(numPART')];
        PART_Names = num2cell(PART_Names,2);
        fileDataName = Data_Name;
        
    case 3
        tab_IdxCLU = varargin{1};
        Data_Name  = varargin{2};
        DirDEC     = varargin{3};
        [TAB_Partitions,LNK_SIM_STRUCT] = partlnkandsim(tab_IdxCLU);
        callingFILE = []; callingOBJ = []; callingFIG = [];
        nbPART  = length(TAB_Partitions);
        numPART = 1:nbPART;
        PART_Names = [repmat('Part ',nbPART,1) , int2str(numPART')];
        PART_Names = num2cell(PART_Names,2);
        
    case 2  % Multisignal Clustering Tool
        callingFILE = varargin{1};
        [callingOBJ,callingFIG] = gcbo;
        fig_ORI = blockdatamngr('get',callingFIG,'fig_Storage','callingFIG');
        SET_of_Partitions = wtbxappdata('get',fig_ORI,'SET_of_Partitions');
        if ~isempty(SET_of_Partitions)
            nbPART = length(SET_of_Partitions);
            nbSIG  = length(get(SET_of_Partitions(1),'IdxCLU'));
            tab_IdxCLU = zeros(nbSIG,nbPART);
            for k = 1:nbPART
                tab_IdxCLU(:,k) = get(SET_of_Partitions(k),'IdxCLU');
            end
            PART_Names = getpartnames(SET_of_Partitions);
            idx = find(strcmp(PART_Names,getWavMSG('Wavelet:moreMSGRF:Curr_Part')), 1);
            flagCUR = ~isempty(idx);
        else
            flagCUR = true;
            tab_IdxCLU = [];
            PART_Names = {};
        end
        clear SET_of_Partitions
        if flagCUR
            PART_Names = [getWavMSG('Wavelet:moreMSGRF:Curr_Part'), ...
                PART_Names];
            IdxCLU = blockdatamngr('get',callingFIG,'current_PART','IdxCLU');
            tab_IdxCLU = [IdxCLU,tab_IdxCLU];
        end
        [TAB_Partitions,LNK_SIM_STRUCT] = partlnkandsim(tab_IdxCLU);
        data_ORI = wtbxappdata('get',fig_ORI,'data_ORI');
        signals  = data_ORI.signal; %#ok<NASGU>
        DirDEC   = data_ORI.dir_DEC;
        Data_Name = [mfilename '_' handle2str(callingFIG) '_DATA.mat'];
        fileDataName = [pwd filesep Data_Name];
        save(fileDataName,'signals');
        
    case 4
        callingFILE = []; callingOBJ = []; callingFIG = [];
        [TAB_Partitions,LNK_SIM_STRUCT,Data_Name,DirDEC] = ...
            deal(varargin{:});
        nbPART  = length(TAB_Partitions);
        numPART = 1:nbPART;
        PART_Names = [repmat('Part ',nbPART,1) , int2str(numPART')];
        PART_Names = num2cell(PART_Names,2);
end
nbPART = length(TAB_Partitions);
% TAB_Partitions = renumpart('col',TAB_Partitions);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
P = wpartobj;
SET_of_Partitions(1:nbPART) = P;
for k = 1:nbPART
    SET_of_Partitions(k) = set(SET_of_Partitions(k),...
        'Name',PART_Names{k},'clu_INFO',TAB_Partitions(k));
end
wtbxappdata('set',fig,'SET_of_Partitions',SET_of_Partitions);
wtbxappdata('set',fig,'PART_Names_INI',PART_Names);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
struct_CALL = struct('Fig',callingFIG,'Obj',callingOBJ,'File',callingFILE);
wtbxappdata('set',fig,'TAB_Partitions',TAB_Partitions);
wtbxappdata('set',fig,'TAB_Partitions_INI',TAB_Partitions);
wtbxappdata('set',fig,'LNK_SIM_STRUCT',LNK_SIM_STRUCT);
wtbxappdata('set',fig,'filedataname',fileDataName);
wtbxappdata('set',fig,'DirDEC',DirDEC);
wtbxappdata('set',fig,'struct_CALL',struct_CALL);
wtbxappdata('set',fig,'Pus_PART_PERF_State','Show');
wtbxappdata('set',fig,'Pus_ALL_IDX_State','Show');

% Begin initialization.
%----------------------
set(fig,'Visible','off');
tool_Name  = 'PAR';
callingFIG = fig;              %%% A VOIR - PROVISOIRE
mdw1dutils('data_INFO_MNGR','create',fig,tool_Name,callingFIG);

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

m_save  = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Str_Save'), ...
    'Enable','On','Position',1);
cb_save = [mfilename '(''Men_save_FUN'',gcbo,[],guidata(gcbo),0);'];
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:moreMSGRF:PartSim_Ind'),...
    'Position',1,'Enable','On','Callback',cb_save);
cb_save =  [mfilename '(''Men_save_FUN'',gcbo,[],guidata(gcbo),1);'];
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:moreMSGRF:Qual_Ind'),...
    'Position',2,'Enable','On','Callback',cb_save);
cb_save =  [mfilename '(''Men_save_FUN'',gcbo,[],guidata(gcbo),2);'];
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:moreMSGRF:PartSimQual_Ind'),...
    'Position',3,'Enable','On','Callback',cb_save);
hdl_Menus = struct('m_files',m_files,'m_close',m_close,'m_save',m_save);
wtbxappdata('set',fig,'hdl_Menus',hdl_Menus);
pos = get(handles.Axe_View_PART,'Position');
wtbxappdata('set',fig,'Pos_Axe_View_PART',pos);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',fig,mfilename);

% Other Initializations.
%-----------------------
mdw1dmngr('init_TOOL',handles,Data_Name,tool_Name);
if ~isempty(Data_Name)
    signals = msloadutl(Data_Name);
    % if isequal(lower(DirDEC(1)),'c') ,  signals = signals'; end
    sizSIG = size(signals);
    data_SEL.sel_DAT = signals;
    data_SEL.Attrb_SEL = {0,0,0};
    mdw1dutils('data_INFO_MNGR','set',fig,'SEL',data_SEL);
    
    if ~isequal(nbIN,2)
        [~,name,ext] = fileparts(Data_Name);
        if isequal(ext,'.mat') , ext = ''; end
        
    else
        name = 'ClusTool Sig.'; ext = ''; 
    end
    nbSTR = int2str(sizSIG(1));
    strNAM = [name , ext ...
        '  (' nbSTR 'x' int2str(sizSIG(2)) ') - ' nbSTR ' sig.'];
    ena_HIG_SIG = 'On';
else
    strNAM = 'None';
    set(handles.Pus_CLU_SHOW,'Visible','Off');
    set(handles.Pus_PART_PERF,'Visible','Off');
    ena_HIG_SIG = 'Off';
end
nbSIG = length(TAB_Partitions(1).IdxCLU);
nbPAIRES = nbSIG*(nbSIG-1)/2;
clusters_INFO = struct('NbCLU',[],'IdxCLU',[],'NbInCLU',[],'IdxInCLU',[]);
wtbxappdata('set',fig,'clusters_INFO',clusters_INFO);
blockdatamngr('set',fig,'tool_ATTR','State','PAR_ON');
set(handles.Edi_NB_PAIRS,'String',int2str(nbPAIRES));
set(handles.Pop_VisPanMode,'Enable','Off')
set([handles.Pop_HIG_SIG,handles.Txt_HIG_SIG,handles.Chk_AFF_MUL],...
    'Enable',ena_HIG_SIG)
set(handles.Edi_Data_NS,'String',strNAM);
set([handles.Pop_SEL_1,handles.Pop_SEL_2],'String',PART_Names,'Value',1);
set_Selected_PART(handles.Pop_SEL_1,handles)
set_Selected_PART(handles.Pop_SEL_2,handles)
Pop_SEL_Callback(handles.Pop_SEL_1,eventdata,handles,false)

aff_SIM_IDX(handles,1,1);
if nbPART<2
    set([handles.Pus_ALL_IDX,handles.Pus_CON_PART],'Enable','Off');
end
set(handles.Pop_VisPanMode,'Enable','On')
end
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function setDispMode(hObject,eventdata,handles,varargin) 

val  = get(hObject,'Value');
option = lower(varargin{2});
switch option
    case 'vis'
        if isequal(val,1) , return; end
        vis_View_PART = 'Off';
        vis_DEC = 'On';
    case 'dec'
        if isequal(val,2) , return; end
        vis_View_PART = 'On'; 
        vis_DEC = 'Off';
end
set(handles.Pan_View_PART,'Visible',vis_View_PART);
mdw1dmngr('setDispMode',hObject,eventdata,handles,varargin{:});

if isequal(option,'dec')
    set(handles.Pan_VISU_SIG,'Visible',vis_View_PART);    
    set(handles.Pan_VISU_DEC,'Visible',vis_DEC);
end
end
%--------------------------------------------------------------------------
function Pop_SEL_Callback(hObject,eventdata,handles,flagSET)

if nargin<4 , flagSET = true; end
if flagSET , set_Selected_PART(hObject,handles); end

fig = handles.Current_Fig;
TAB_Partitions = wtbxappdata('get',fig,'TAB_Partitions');
numPART(1) = get(handles.Pop_SEL_1,'Value');
numPART(2) = get(handles.Pop_SEL_2,'Value');
wtbxappdata('set',fig,'clusters_INFO',TAB_Partitions(numPART(1)));
%%% A VOIR %%%
P = wpartobj;
P = set(P,'clu_INFO',TAB_Partitions(numPART(1)));
wtbxappdata('set',fig,'active_PART',P);
%---------------------------
% RenumVAL = 1 <==> 'none'
% RenumVAL = 2 <==> 'mat'
%---------------------------
RenumVAL = 1;
set(handles.Pop_Renum_PART,'Value',RenumVAL,'Enable','On');
Pop_Renum_PART_Callback(handles.Pop_Renum_PART,eventdata,handles,'flag')
aff_SIM_IDX(handles,numPART)
end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function set_Selected_PART(hObject,handles)

fig = handles.Current_Fig;
nbMaxCLU_AFF = 12;
if (hObject==handles.Pop_SEL_1) , 
    Pop_NUM = handles.Pop_NUM_1;
else
    Pop_NUM = handles.Pop_NUM_2;
end
val_SEL = get(hObject,'Value');
TAB_Partitions = wtbxappdata('get',fig,'TAB_Partitions');
NbCLU = TAB_Partitions(val_SEL).NbCLU;
nb_STR = num2cell(int2str((1:NbCLU)'),2);
pop_NUM_STR = ['All';nb_STR]; 
if NbCLU>nbMaxCLU_AFF , pop_NUM_STR = [pop_NUM_STR ; '=>12']; end
set(Pop_NUM,'Value',1,'String',pop_NUM_STR,'Enable','On')
end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%--------------------------------------------------------------------------
function Pop_Renum_PART_Callback(hObject,eventdata,handles,varargin) %#ok<INUSL>

valPOP = get(hObject,'Value');
switch valPOP
    case 1 , if nargin<4 , return; end; optRENUM = 'none';
    case 2 , optRENUM = 'mat';
    case 3 , optRENUM = 'col'; 
    case 4 , optRENUM = 'row';
    case 5 , optRENUM = 'col_mat';
    case 6 , optRENUM = 'row_mat';
end
flagRENUM = (valPOP>1);
fig = handles.Current_Fig;

%+++++++++++++++++++++++++++++++++ A MODIFIER +++++++++++++++++++++++++++
numPART(1) = get(handles.Pop_SEL_1,'Value');
numPART(2) = get(handles.Pop_SEL_2,'Value');
Lst = get(handles.Pop_SEL_1,'String');
Name{1} = Lst{numPART(1)};
Name{2} = Lst{numPART(2)};
TAB_Partitions = wtbxappdata('get',fig,'TAB_Partitions');
[Part,~,effectif] = renumpart(optRENUM,TAB_Partitions(numPART));
if flagRENUM
    for j = 1:2 , TAB_Partitions(numPART(j)) = Part(j); end
    wtbxappdata('set',fig,'TAB_Partitions',TAB_Partitions);
    SET_of_Partitions = wtbxappdata('get',fig,'SET_of_Partitions');
    for j = 1:2
        k = numPART(j);
        SET_of_Partitions(k) = set(SET_of_Partitions(k),'clu_INFO',Part(j));
    end
    wtbxappdata('set',fig,'SET_of_Partitions',SET_of_Partitions);
end
%+++++++++++++++++++++++++++++++++ A MODIFIER +++++++++++++++++++++++++++

wtbxappdata('set',fig,'Renum_PART_VAL',{effectif,Name,numPART});
plot_LinkPART(handles,effectif,Name,numPART);
end
%--------------------------------------------------------------------------
function plot_LinkPART(handles,effectif,Name,numPART)

nbIN = nargin;
fig = handles.output;
percentFLAG = get(handles.Pus_VAL_MOD,'UserData');
if nbIN<2    
    Renum_PART_VAL = wtbxappdata('get',fig,'Renum_PART_VAL');
    [effectif,Name,numPART] = deal(Renum_PART_VAL{:});
end

nbMaxCLU_AFF = 12;
[nbR,nbC] = size(effectif);
xyDIM = min([nbR,nbC],nbMaxCLU_AFF);
nbRR = xyDIM(1);
nbCC = xyDIM(2);
if nbCC<nbC
    effectif(:,nbCC) = sum(effectif(:,nbCC:nbC),2);
    effectif(:,nbCC+1:nbC) = [];
end
if nbRR<nbR
    effectif(nbRR,:) = sum(effectif(nbRR:nbR,:),1);
    effectif(nbRR+1:nbR,:) = [];
end
sumCOL = sum(effectif,1);
sumROW = sum(effectif,2);
nbSIG  = sum(sumROW);

axeCUR = handles.Axe_View_PART;
delete(allchild(axeCUR));
Pos_Axe_View_PART = wtbxappdata('get',fig,'Pos_Axe_View_PART');
pos = get(axeCUR,'Position');

if percentFLAG
    if nbIN<2
        pos(3) = 0.88*pos(3);
        set(axeCUR,'Position',pos);
    end
    WMUL = 48;
else
    if ~isequal(Pos_Axe_View_PART,pos)
        set(axeCUR,'Position',Pos_Axe_View_PART);
    end
    WMUL = 22;
end

xlab = int2str((1:nbCC)');
ylab = int2str((1:nbRR)');
if nbCC<nbC , xlab(end,:) = '++'; end
if nbRR<nbR , ylab(end,:) = '++'; end

set(axeCUR,...
    'XLim',[1 nbCC],'XTick',(1:nbCC),'XTickLabel',xlab,'XGrid','On', ...
    'YLim',[1 nbRR],'YTick',(1:nbRR),'YTickLabel',ylab,'YGrid','On'  ...
    );
xlabel(Name{1},'Parent',axeCUR,'Interpreter','None');
ylabel(Name{2},'Parent',axeCUR,'Interpreter','None');
cba_TEXT = [mfilename '(''Text_Link_Part'',' ...
    num2mstr(axeCUR) , ',[],[],' , num2mstr([numPART(1);numPART(2)]) , ',' ...
    num2mstr([nbC;nbR]) ');'];
propTEXT = {...
    'Parent',axeCUR,...
    'FontSize',8,'FontWeight','bold',...
    'HorizontalAlignment','Center','ButtonDownFcn',cba_TEXT ...
    };
nbMIN   = min([nbRR,nbCC]);
line('XData',[1 nbMIN],'YData',[1 nbMIN],...
    'LineWidth',1,'LineStyle',':','Color',[0,0.8,0],'Parent',axeCUR);
txtGRID = NaN(nbRR,nbCC);
for iR=1:nbRR
    for iC=1:nbCC
        nbVAL = effectif(iR,iC);
        if nbVAL>0
            strTXT = effectif_STR(effectif(iR,iC),nbSIG,percentFLAG);
            txtGRID(iR,iC) = text(iC,iR,strTXT,...
                'Color','b','EdgeColor','r','BackgroundColor',[1 1 0.8],...
                propTEXT{:},'UserData',[iC,iR]);
        end
    end
end
old_Units = get(axeCUR,'Units');
set(axeCUR,'Units','Pixels');
pos = get(axeCUR,'Position');
set(axeCUR,'Units',old_Units);
Wadd = WMUL*(nbCC-1)/pos(3);
Hadd = 22*(nbRR-1)/pos(4);

pMORE = {'Color','r','EdgeColor','r','BackgroundColor',[1 0.8 1]};
txtCOL = zeros(1,nbCC);
for k=1:nbCC
    strTXT = effectif_STR(sumCOL(k),nbSIG,percentFLAG);
    txtCOL(k) = text(k,nbRR+Hadd,strTXT,pMORE{:}, ...
        propTEXT{:},'UserData',[k,nbRR+1]);
end
txtROW = zeros(1,nbRR);
for k=1:nbRR
    strTXT = effectif_STR(sumROW(k),nbSIG,percentFLAG);    
    txtROW(k) = text(nbCC+Wadd,k,strTXT,pMORE{:}, ...
        propTEXT{:},'UserData',[nbCC+1,k]);
end
sumDIAG = 0;
for k = 1:min([nbRR,nbCC]) , sumDIAG = sumDIAG + effectif(k,k); end
strTXT = effectif_STR(sumDIAG,nbSIG,percentFLAG);
frCOL = [0.25 0.7 0.25];
bkCOL = [0.8 1 0.8];
text(nbCC+Wadd,nbRR+Hadd,strTXT,...
    'Color',frCOL,'EdgeColor',frCOL,'BackgroundColor',bkCOL,...
    propTEXT{:},'UserData',[nbCC+1,nbRR+1]);
end
%--------------------------------------------------------------------------
function strTXT = effectif_STR(nbVAL,nbSIG,percentFLAG)

formatNUM = '%5.2f';
if percentFLAG
    strTXT = [num2str(100*nbVAL/nbSIG,formatNUM) '%'];
else
    strTXT = int2str(nbVAL);
end
end
%--------------------------------------------------------------------------
function Text_Link_Part(hAXE,eventdata,handles,Part,nbCLU) %#ok<INUSL>

nbMaxCLU_AFF = 12;
handles = guidata(gcf);
usr = get(gco,'UserData');
C1 = usr(1);
C2 = usr(2);
if nbMaxCLU_AFF<nbCLU(1)
    if     C1<nbMaxCLU_AFF , pop_1_VAL = C1 + 1;
    elseif C1>nbMaxCLU_AFF , pop_1_VAL = 1;
    else   % C1 = nbMaxCLU_AFF
         pop_1_VAL = length(get(handles.Pop_NUM_1,'String'));
    end
else
     if C1>nbMaxCLU_AFF || C1>nbCLU(1) , pop_1_VAL = 1; 
     else pop_1_VAL = C1 + 1;
     end
end

if nbMaxCLU_AFF<nbCLU(2)
    if     C2<nbMaxCLU_AFF , pop_2_VAL = C2 + 1;
    elseif C2>nbMaxCLU_AFF , pop_2_VAL = 1;
    else   % C2 = nbMaxCLU_AFF
         pop_2_VAL = length(get(handles.Pop_NUM_2,'String'));
    end
else
     if C2>nbMaxCLU_AFF || C2>nbCLU(2), pop_2_VAL = 1;
     else pop_2_VAL = C2 + 1; 
     end
end

set(handles.Pop_NUM_1,'Value',pop_1_VAL);
set(handles.Pop_NUM_2,'Value',pop_2_VAL);
mdw1dafflst('PAR',gcf,eventdata,handles,'clu_SEL','and')
WBF = get(gcbf,'WindowButtonUpFcn');
if ~isempty(WBF) , set(gcbf,'WindowButtonUpFcn',''); end
mdw1dmngr('Pus_PLOT_Callback',handles,'all')
end
%--------------------------------------------------------------------------
function Pus_Show_SEL_Callback(hObject,eventdata,handles,TypeSEL) 

mdw1dafflst('PAR',hObject,eventdata,handles,'clu_SEL',TypeSEL)
mdw1dmisc('plot',handles,'all','clu_SEL')
set(gcbf,'Pointer','arrow');
end
%--------------------------------------------------------------------------
function Pus_PART_PERF_Callback(hObject,eventdata,handles) %#ok<INUSD>

typeCALL = get(hObject,'Type');
switch typeCALL
    case 'figure'
        fig     = hObject;
        hObject = get(fig,'UserData');

    otherwise
        fig = get(hObject,'UserData');
end
closeWIN = ~isempty(fig);
set_Show_State('PRF',hObject,closeWIN);
if closeWIN
    if ishandle(fig) , delete(fig); end
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_PART_PERF');
    fig = [];
    State = 'Show';
else
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_PART_PERF_Close');
    fig = showpartperf(hObject);
    State = 'Close';
end
wtbxappdata('set',hObject,'Pus_PART_PERF_State',State);
set(hObject,'String',strPUS,'UserData',fig);
end
%--------------------------------------------------------------------------
function Pus_ALL_IDX_Callback(hObject,eventdata,handles) %#ok<INUSD>

typeCALL = get(hObject,'Type');
switch typeCALL
    case 'figure'
        fig     = hObject;
        hObject = get(fig,'UserData');
    otherwise
        fig = get(hObject,'UserData');
end
closeWIN = ~isempty(fig);
set_Show_State('IDX',hObject,closeWIN);
if closeWIN    
    if ishandle(fig) , delete(fig); end
    strPUS = getWavMSG('Wavelet:mdw1dRF:Show_Sim_Ind');
    State = 'Show';
    fig = [];
else
    strPUS = getWavMSG('Wavelet:mdw1dRF:Show_Sim_Ind_Close');
    fig = showpartsimidx(hObject);
    State = 'Close';
end
wtbxappdata('set',hObject,'Pus_ALL_IDX_State',State);
set(hObject,'String',strPUS,'UserData',fig);
end
%--------------------------------------------------------------------------
function set_Show_State(caller,hObject,closeWIN) %#ok<INUSD>

H = guihandles(hObject);
State_IDX = wtbxappdata('get',hObject,'Pus_ALL_IDX_State');
State_PRF = wtbxappdata('get',hObject,'Pus_PART_PERF_State');
% strIDX = get(H.Pus_ALL_IDX,'String');
% strPRF = get(H.Pus_PART_PERF,'String');
strIDX = State_IDX(1);
strPRF = State_PRF(1);
switch caller
    case 'IDX'
        switch strPRF
            case 'S' , change = true;
            case 'C' , change = false;
        end
    case 'PRF'
        switch strIDX
            case 'S' , change = true;
            case 'C' , change = false;
        end
end
if ~change , return; end

Pus_SAV = H.Pus_CON_SAV;
Pus_DEL = H.Pus_CON_DEL;
Pus_EXE = H.Pus_CON_EXE;
Local_CON_ENA = wtbxappdata('get',hObject,'Local_CON_ENA');
if ~isempty(Local_CON_ENA)
    [ena_SAV , ena_DEL , ena_EXE ] = deal(Local_CON_ENA{:});
    Local_CON_ENA = [];
else
    ena_SAV = 'Off';  ena_DEL = 'Off'; ena_EXE = 'Off';
    Local_CON_ENA = {...
        get(Pus_SAV,'Enable') , ...
        get(Pus_DEL,'Enable') , ...
        get(Pus_EXE,'Enable')...
        };
end
wtbxappdata('set',hObject,'Local_CON_ENA',Local_CON_ENA);
set(Pus_SAV,'Enable',ena_SAV);
set(Pus_DEL,'Enable',ena_DEL);
set(Pus_EXE,'Enable',ena_EXE);

end
%--------------------------------------------------------------------------
function Pus_AFF_CLU_PART_Callback(hObject,eventdata,handles) 

fig = handles.Current_Fig;
callingFIG = blockdatamngr('get',fig,'fig_Storage','callingFIG');
SET_of_Partitions = wtbxappdata('get',callingFIG,'SET_of_Partitions');
nbPART = length(SET_of_Partitions);
mdw1dafflst('CLU',hObject,eventdata,handles,'part_CLU',1:nbPART)
return

% Not Used (for future release).
%-------------------------------
% switch lower(typeSEL)
%     case 'all'
%         num = 1:nbPART;
%         set(handles.Lst_LST_PART,'Value',num);
%         manyAFF = true;
%     case 'sel'
%         num = get(handles.Lst_LST_PART,'Value');
%         nbPART = length(num);
%         manyAFF = nbPART>1;
% end
% set(handles.Pus_CUR_SEL,'UserData',num);
% if isempty(num) , return; end
% mdw1dafflst('CLU',hObject,eventdata,handles,'partition',num)
% if ~manyAFF
%     set(handles.Pan_View_PART,'Visible','Off')
%     set(handles.Pan_Dendro_VISU,'Visible','On')
%     plot_Dendrogram('restore',handles,SET_of_Partitions(num))
% else
%     set(handles.Pan_Dendro_VISU,'Visible','Off')
%     set(handles.Pan_View_PART,'Visible','On')
%     axeCUR = handles.Axe_View_PART;
%     axes(axeCUR);
%     delete(allchild(axeCUR));
%     tabCOL = get(axeCUR,'ColorOrder');    
%     hold on
%     maxNUM = 0;
%     legSTR = {};
%     for k = num
%         IdxCLU = get(SET_of_Partitions(k),'IdxCLU');
%         maxi = max(IdxCLU);
%         if maxi>maxNUM , maxNUM = maxi; end
%         plot(IdxCLU,'.-','Color',tabCOL(k,:),'MarkerSize',16);
%         legSTR = {legSTR{:} , ['P',int2str(k)] };
%     end
%     hold off
%     set(axeCUR,'XLim',[1 length(IdxCLU)],'YLim',[1 maxNUM]);
%     grid on
%     xlabel('Indices');
%     ylabel('Clusters');
%     title('Selected Partitions')
%     hLeg = legend(legSTR{:},...
%         'Location','SouthOutside','Orientation','horizontal','AutoUpdate','off');
%     posLEG = get(hLeg,'Position');
%     posLEG(2) = posLEG(2)-2.2*posLEG(4);
%     set(hLeg,'Position',posLEG);
%     axe_IND = [];
%     axe_CMD = axeCUR;
%     axe_ACT = [];
%     dynvtool('init',fig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','','int');
% end
end
%--------------------------------------------------------------------------
function Pus_CLU_SHOW_Callback(hObject,eventdata,handles) %#ok<INUSD>

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
    fig = showclusters(mfilename,'PAR');
end
set(hObject,'String',strPUS,'UserData',fig);
end
%--------------------------------------------------------------------------
function Pus_CloseWin_Callback(hObject,eventdata,handles) %#ok<INUSL>

fig = handles.output;
try %#ok<*TRYNC>
    Data_Name = wtbxappdata('get',fig,'filedataname');
    idx = strfind(Data_Name,mfilename);
    if isequal(exist(Data_Name,'file'),2) && ~isempty(idx)
        delete(Data_Name);
    end
end
struct_CALL = wtbxappdata('get',fig,'struct_CALL');
if ishandle(struct_CALL.Fig)
    mdw1dclus('Pus_PART_MORE_Callback',fig,[],handles)
else
    delete(fig);
end

end
%--------------------------------------------------------------------------
function Pus_SORT_Callback(hObject,eventdata,handles,dir) %#ok<*DEFNU>

mdw1dmngr('Pus_SORT_Callback',hObject,eventdata,handles,dir)
end
%--------------------------------------------------------------------------
function Lst_SEL_DATA_Callback(hObject,eventdata,handles)

fig = handles.output;
filedataname = wtbxappdata('get',fig,'filedataname');
if isempty(filedataname) , return; end
lst = get(hObject,'String');
if isempty(lst) , return; end
mdw1dmngr('Lst_SEL_DATA_Callback',hObject,eventdata,handles)
end
%--------------------------------------------------------------------------
function Lst_SIM_IDX_Callback(hObject,eventdata,handles) %#ok<INUSD>
end
%--------------------------------------------------------------------------
function aff_SIM_IDX(handles,P1,P2)

formatNUM = '%9.3f';
formatPER = '%5.2f';
if nargin<3 , P2 = P1(2); P1 = P1(1); end
fig = handles.output;
IdxTAB = wtbxappdata('get',fig,'LNK_SIM_STRUCT');
Links = IdxTAB.Links(P1,P2,:); 
Links = Links(:);
Links = 100*Links/sum(Links); 
set(handles.Edi_PP,'String',[num2str(Links(1),formatPER),' %']);
set(handles.Edi_NN,'String',[num2str(Links(2),formatPER),' %']);
set(handles.Edi_PN,'String',[num2str(Links(3),formatPER),' %']);
set(handles.Edi_NP,'String',[num2str(Links(4),formatPER),' %']);
FN = fieldnames(IdxTAB);
FN(1) = [];
strVAL = {};
for k = 1:length(FN)
    strVAL = [strVAL, num2str(IdxTAB.(FN{k})(P1,P2),formatNUM)]; %#ok<*AGROW>
end
sep = '  =  ';
strINDEXS = [...
    char(FN{:}) , repmat(sep,length(strVAL),1) , char(strVAL{:})]; 
set(handles.Lst_SIM_IDX,'String',strINDEXS,'Value',[]);
end
%--------------------------------------------------------------------------
function Pus_VAL_MOD_Callback(hObject,eventdata,handles) %#ok<INUSL>

usr = get(hObject,'UserData');
if isempty(usr) , usr = 0; end
usr = 1-usr;
switch usr
    case 0 , strPOP = getWavMSG('Wavelet:mdw1dRF:Str_Percent');
    case 1 , strPOP = getWavMSG('Wavelet:commongui:Str_Number');
end
set(hObject,'String',strPOP,'UserData',usr);
plot_LinkPART(handles)
end
%--------------------------------------------------------------------------
function Pus_CON_PART_Callback(hObject,eventdata,handles) %#ok<INUSL>

visPAN = get(hObject,'UserData');
hdl_PAN = [...
    handles.Pan_VISU_SIG, ...
    handles.Pan_View_PART,...
    handles.Pan_Selected_DATA, ...
    handles.Pan_VISU_DEC
    ];
if isempty(visPAN)
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_CON_PART_Close');
    opt = 'open';
else
    strPUS = getWavMSG('Wavelet:mdw1dRF:Pus_CON_PART');
    opt = 'close';
end
switch opt
    case 'open'
        visPAN = get(hdl_PAN,'Visible');
        set(hdl_PAN,'Visible','Off')
        pause(0.1)
        set(handles.Pop_Nb_CON,'Value',1)
        set(handles.Pan_CON_PART,'Visible','On')
        
        % Initialize CON Pan
        %--------------------
        TAB_Partitions = wtbxappdata('get',hObject,'TAB_Partitions_INI');
        TAB_Partitions = part2tab(TAB_Partitions);
        woptpart(handles,TAB_Partitions,'InitVIEW');
       
    case 'close'
        idxVIS = strcmpi(visPAN,'On');
        set(handles.Pan_CON_PART,'Visible','Off')
        set(hdl_PAN(idxVIS),'Visible','On')
        visPAN = [];
        
end
set(hObject,'String',strPUS,'UserData',visPAN);

end
%--------------------------------------------------------------------------
function Pus_CON_EXE_Callback(hObject,eventdata,handles) %#ok<INUSL>

fig  = handles.output;
prop = get(handles.Pop_Nb_CON,{'String','Value'});
nb_CON = str2double(prop{1}(prop{2},:));
old_ENA = get(handles.Pus_CON_DEL,'Enable'); 
set([handles.Pus_CON_SAV,handles.Pus_CON_DEL],'Enable','Off'); 
TAB_Partitions = wtbxappdata('get',fig,'TAB_Partitions_INI');
TAB_Partitions = part2tab(TAB_Partitions);
valMTH = get(handles.Pop_CON_MTH,'Value');
switch valMTH
    case 1 , optMTH = 'jaccard';
    case 2 , optMTH = 'sim';
    case 3 , optMTH = 'jacsim';
    case 4 , optMTH = 'InterIntraN';
end

filedataname = wtbxappdata('get',fig,'filedataname');
signals = msloadutl(filedataname);
DirDEC  = wtbxappdata('get',fig,'DirDEC');
if isequal(lower(DirDEC(1)),'c') , signals = signals'; end

[optPART,Rupt_Weight] = ...
    woptpart(handles,TAB_Partitions,optMTH,nb_CON,signals);
set(handles.Pus_CON_EXE,'UserData',{optPART,Rupt_Weight});
set(handles.Pus_CON_SAV,'Enable','On');
set(handles.Pus_CON_DEL,'Enable',old_ENA); 
end
%--------------------------------------------------------------------------
function Pus_CON_SAV_Callback(hObject,eventdata,handles,flagSAVE) %#ok<INUSL>

fig  = handles.output;
if nargin<4 , flagSAVE = true; end
if flagSAVE
    usr = get(handles.Pus_CON_EXE,'UserData');
    [optPART,Rupt_Weigh] = deal(usr{:}); %#ok<NASGU>
    CON_Partitions = wtbxappdata('get',fig,'CON_Partitions');
    if ~isempty(CON_Partitions)
        CON_Partitions = [CON_Partitions , optPART];
    else
        CON_Partitions = optPART;
    end
    wtbxappdata('set',fig,'CON_Partitions',CON_Partitions);
    set(handles.Pus_CON_SAV,'Enable','Off');
    nb_CON = size(CON_Partitions,2);
    num_CON = 1:nb_CON;
    PART_Names_CON = ...
        num2cell([repmat('ConsP ',nb_CON,1) , int2str(num_CON')],2);
    set(handles.Pus_CON_DEL,'Enable','On'); 
else
    CON_Partitions = [];
    PART_Names_CON = {};
    wtbxappdata('set',fig,'CON_Partitions',[]);
    set(handles.Pus_CON_DEL,'Enable','Off'); 
end
set(handles.Pus_CON_SAV,'Enable','Off'); 
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PART_Names_INI = wtbxappdata('get',fig,'PART_Names_INI');
PART_Names = [PART_Names_INI;PART_Names_CON];
TAB_Partitions = wtbxappdata('get',fig,'TAB_Partitions_INI');
TAB_Partitions = part2tab(TAB_Partitions);
TAB_Partitions = [TAB_Partitions , CON_Partitions];
nbPART  = size(TAB_Partitions,2);
TAB_Partitions = renumpart('col',TAB_Partitions);
[~,LNK_SIM_STRUCT] = partlnkandsim(TAB_Partitions);
P = wpartobj;
SET_of_Partitions(1:nbPART) = P;
for k = 1:nbPART
    SET_of_Partitions(k) = set(SET_of_Partitions(k),...
        'Name',PART_Names{k},'clu_INFO',TAB_Partitions(k));
end
wtbxappdata('set',fig,'SET_of_Partitions',SET_of_Partitions);
wtbxappdata('set',fig,'TAB_Partitions',TAB_Partitions);
wtbxappdata('set',fig,'LNK_SIM_STRUCT',LNK_SIM_STRUCT);
wtbxappdata('set',fig,'Std_Quality',[]);
wtbxappdata('set',fig,'BetweenWithin',[]);
wtbxappdata('set',fig,'silh_VALUES',[]);
set([handles.Pop_SEL_1,handles.Pop_SEL_2],'String',PART_Names,'Value',1);
set_Selected_PART(handles.Pop_SEL_1,handles)
set_Selected_PART(handles.Pop_SEL_2,handles)
Pop_SEL_Callback(handles.Pop_SEL_1,eventdata,handles,false)

aff_SIM_IDX(handles,1,1);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
end
%--------------------------------------------------------------------------
function Pop_Nb_CON_Callback(hObject,eventdata,handles) %#ok<INUSD>
end
%----------------------------------------------------------
function Pop_CON_MTH_Callback(hObject,eventdata,handles) %#ok<INUSD>
end
%----------------------------------------------------------

%==========================================================================
