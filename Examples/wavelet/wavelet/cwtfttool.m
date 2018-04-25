function varargout = cwtfttool(varargin)
%CWTFTTOOL Continuous wavelet transform tool using FFT.
%

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jul-2010.
%   Copyright 1995-2015 The MathWorks, Inc.



%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cwtfttool_OpeningFcn, ...
                   'gui_OutputFcn',  @cwtfttool_OutputFcn, ...
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
% --- Executes just before cwtfttool is made visible.                     %
%*************************************************************************%
function cwtfttool_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for cwtfttool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cwtfttool wait for user response (see UIRESUME)
% uiwait(handles.wfbmtool_Win);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALIZATION Introduced manually in the automatic generated code %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
hFig = handles.output;
tagFig = get(hFig,'Tag');
LstFig = wfindobj(0,'Type','Figure','Tag',tagFig);
Init_Tool(hObject,eventdata,handles);
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = cwtfttool_OutputFcn(hObject,eventdata,handles) 
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
function DEL_Win_Callback(hObject,eventdata,handles,arg)

hFig = handles.output;
nameFig = get(hFig,'Name');
LstFig = wfindobj(0,'Type','Figure','Name',nameFig);
delete(gcbf)
%--------------------------------------------------------------------------
function Pus_CloseWin_Callback(hObject,eventdata,handles) 

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
if isequal(lower(ena_Save),'on')
    fig = get(hObject,'Parent');
    status = wwaitans({fig,getWavMSG('Wavelet:cwtfttool:CWTFFT')},...
        getWavMSG('Wavelet:cwtfttool:SaveSynthesizedSignal'),2,'Cancel');
    switch status
        case -1 , return;
        case  1 , Men_SavRecSig_Callback(m_save,eventdata,handles,4)
        otherwise
    end
    wtbxappdata('set',hObject,'status_SAVE',1);
end
DEL_Win_Callback(hObject,eventdata,handles)
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%
function Men_SavRecSig_Callback(hObject,eventdata,handles,numSub) 

% Get figure handle.
%-------------------
fig = handles.output;
if nargin<4 , numSub = 0; end

% Begin waiting.
%---------------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitSave'));

% Update Tool Parameters.
%------------------------

% Testing file.
%--------------
[filename,pathname,ok] = utguidiv('test_save',fig, ...
    '*.mat',getWavMSG('Wavelet:cwtfttool:SaveSynthesizedSignal'));
if ~ok,
    wwaiting('off',fig);   % End waiting.
    return; 
end

% Saving file.
%-------------
[name,ext] = strtok(filename,'.');
if isempty(ext) || isequal(ext,'.')
    ext = '.mat'; filename = [name ext];
end

ax = handles.Axe_SIG_L;
switch numSub
    case 1 , Tag = 'RecSIG';        
    case 2 , Tag = 'RecLST';        
    case 3 , Tag = 'RecMAN';
    case 4 , Tag = 'RecSIG'; % Close tool
end
hInv = wfindobj(ax,'Tag',Tag);
Y = get(hInv,'Ydata');  
if isempty(Y) && ((numSub==1) || (numSub==4)) ;
    CWTS = wtbxappdata('get',fig,'CWTStruct');
    Y = icwt_SYNTHESIS(handles,CWTS);  %#ok<NASGU>
end

try
    save([pathname filename],'Y','-mat');
catch          
    errargt(mfilename,getWavMSG('Wavelet:cwtfttool:SaveFailed'),'msg');
end

% End waiting.
%-------------
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Men_SavDEC_Callback(hObject,eventdata,handles) 

% Get figure handle.
%-------------------
fig = handles.output;

% Begin waiting.
%---------------
wwaiting('msg',fig,getWavMSG('Wavelet:cwtfttool:WaitSaving'));

% Testing file.
%--------------
[filename,pathname,ok] = utguidiv('test_save',fig, ...
    '*.mat',getWavMSG('Wavelet:cwtfttool:SaveDecomp'));
if ~ok,
    wwaiting('off',fig);   % End waiting.
    return; 
end

% Saving file.
%-------------
[name,ext] = strtok(filename,'.');
if isempty(ext) || isequal(ext,'.')
    ext = '.mat'; filename = [name ext];
end
CWTS = wtbxappdata('get',fig,'CWTStruct');  %#ok<NASGU>
try
    save([pathname filename],'CWTS','-mat');
catch          
    errargt(mfilename,getWavMSG('Wavelet:cwtfttool:SaveFailed'),'msg');
end

% End waiting.
%-------------
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Export_Callback(hObject,eventdata,handles,option) 

fig = handles.output;
wwaiting('msg',fig,getWavMSG('Wavelet:cwtfttool:WaitExport'));
switch option
    case 'sig'
        ax = handles.Axe_SIG_L;
        hInv = findobj(ax,'Tag','RecLST');
        if isempty(hInv)
            hInv = findobj(ax,'Tag','RecSIG');
        end
        if isempty(hInv)
            CWTS = wtbxappdata('get',gcbf,'CWTStruct');
            Y = icwt_SYNTHESIS(handles,CWTS);
        else
            Y = get(hInv,'Ydata');
        end
        wtbxexport(Y,'name','Y','title',getWavMSG('Wavelet:cwtfttool:label_SynthesizedSignal'));
        
    case 'ana'
        CWTS = wtbxappdata('get',fig,'CWTStruct');
        wtbxexport(CWTS,'name','CWTS','title',...
            getWavMSG('Wavelet:cwtfttool:CWTStructure'));
end
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Pus_ANAL_Callback(hObject,eventdata,handles)  

fig = gcbf;

wwaiting('msg',fig,getWavMSG('Wavelet:cwtfttool:WaitCompute'));
X = wtbxappdata('get',fig,'Sig_ANAL');
Edi_SAMP = handles.Edi_SAMP;
dt = str2double(get(Edi_SAMP,'String'));
nbSamp = length(X);
posval = dt*(0:nbSamp-1);

% Get wavelet for analysis.
WNam = get(handles.Pop_WAV_NAM,{'Value','String'});
WPar = get(handles.Pop_WAV_PAR,{'Value','String'});
wname = WNam{2}{WNam{1}};
if iscell(WPar{2})
    wpara = str2double(WPar{2}{WPar{1}});
    if isnan(wpara) , wpara = eval(WPar{2}{WPar{1}}); end
else
    wpara = [];
end
WAV = {wname,wpara};
AP = wtbxappdata('get',fig,'Pow_Anal_Params');
AP.WAV = WAV;
AP.sampPer = dt;
wtbxappdata('set',fig,'Pow_Anal_Params',AP);
resetSamplingPeriod(handles)

OPT = get(handles.Pop_DEF_SCA,'Value');
switch OPT
    case 1
        CWTStruct = cwtft({X,dt},'wavelet',WAV);
        scales = CWTStruct.scales;
        ScType = getScType(scales);
        set(handles.Pop_METH_SYNT,'Value',1);
        
    case 2
        if strcmpi(WAV{1},'bump')
            scales = 2:0.1:400;
        else
            AP = wtbxappdata('get',fig,'Linear_Anal_Params');
            scales = AP.scales;
        end
        CWTStruct = cwtft({X,dt},'wavelet',WAV,'scales',scales);
        ScType = getScType(scales);
        set(handles.Pop_METH_SYNT,'Value',2);
        
    case 3
        % Get scales for analysis.
        scales = AP.scales;
        ScType = getScType(scales);
        CWTStruct = cwtft({X,dt},'wavelet',AP.WAV,'scales',scales);
end
wtbxappdata('set',fig,'CWTStruct',CWTStruct);
wtbxappdata('set',fig,'Scales_INI',scales);
Lst_Scales_INI(fig,handles)
cwtcfs = CWTStruct.cfs;
decale = 0;
cleanTOOL('anal_beg',fig,handles) 
switch ScType
    case 'lin' , ylabSTR = getWavMSG('Wavelet:cwtfttool:label_Scales');
    case 'pow' , ylabSTR = getWavMSG('Wavelet:cwtfttool:label_ScalePower');
    otherwise  , ylabSTR = getWavMSG('Wavelet:cwtfttool:label_Scales');
end

realCFS = isreal(cwtcfs);
FlagReal = wtbxappdata('get',fig,'FlagReal');
resetAXES =  ~isequal(FlagReal,realCFS) || realCFS==1;
if resetAXES
    wtbxappdata('set',fig,'FlagReal',realCFS);
    if realCFS
        strPOP = {getWavMSG('Wavelet:cwtfttool:title_Modulus'),...
            getWavMSG('Wavelet:cwtfttool:title_RealPart')};
        colPOS = 4;
        vis = 'Off';
    else
        strPOP = {getWavMSG('Wavelet:cwtfttool:title_Modulus'),...
            getWavMSG('Wavelet:cwtfttool:title_Angle'),...
            getWavMSG('Wavelet:cwtfttool:title_RealPart'),...
            getWavMSG('Wavelet:cwtfttool:title_ImaginaryPart')};
        colPOS = 3;
        vis = 'On';
    end
    set(handles.Pop_AXE_MAN,'Value',1,'String',strPOP);
    axe_STORAGE = wtbxappdata('get',hObject,'axe_STORAGE');
    idx = find(strcmp(axe_STORAGE(:,1),'Axe_SIG_L'));
    set(axe_STORAGE{idx,2},'Position',axe_STORAGE{idx,colPOS});
    Txt_Xlab_AL = handles.Txt_Xlab_AL;
    posTXT = get(Txt_Xlab_AL(1),'Userdata');
    if realCFS
        posAXE = axe_STORAGE{idx,colPOS};
        mid = posAXE(1)+0.5*posAXE(3);        
        for k = 1:3
            pos = posTXT{k};
            pos(1) = mid-pos(3)/2;
            set(Txt_Xlab_AL(k),'Position',pos)
        end
    else
        for k = 1:3
            set(Txt_Xlab_AL(k),'Position',posTXT{k})
        end
    end
    set(findall(handles.Axe_SIG_R),'Visible',vis);    
    idx = find(strcmp(axe_STORAGE(:,1),'Axe_MOD'));
    set(axe_STORAGE{idx,2},'Position',axe_STORAGE{idx,colPOS});
    idx = find(strcmp(axe_STORAGE(:,1),'Axe_REAL'));
    set(axe_STORAGE{idx,2},'Position',axe_STORAGE{idx,colPOS});
end

if realCFS , vis = 'Off'; else vis = 'On'; end
set(findall(handles.Axe_SIG_R),'Visible',vis);
    
ax = handles.Axe_MOD;
titleSTR = getWavMSG('Wavelet:cwtfttool:title_Modulus');
plotIMAGE(handles,ax,posval,scales,...
    abs(cwtcfs),ScType,titleSTR,decale,realCFS);
wylabel(ylabSTR,'Parent',ax);

ax = handles.Axe_REAL;
titleSTR = getWavMSG('Wavelet:cwtfttool:title_RealPart');
plotIMAGE(handles,ax,posval,scales,...
    real(cwtcfs),ScType,titleSTR,decale,realCFS);
if realCFS , labY = ylabSTR; else labY = ''; end
wylabel(labY,'Parent',ax);

ax = handles.Axe_ANG;
titleSTR = getWavMSG('Wavelet:cwtfttool:title_Angle');
hC = plotIMAGE(handles,ax,posval,scales,...
    angle(cwtcfs),ScType,titleSTR,decale,realCFS);
wylabel(ylabSTR,'Parent',ax);
if resetAXES
    if realCFS , vis = 'Off'; else vis = 'On'; end
    set(findall([ax;hC]),'Visible',vis);
end

ax = handles.Axe_IMAG;
titleSTR = getWavMSG('Wavelet:cwtfttool:title_ImaginaryPart');
hC = plotIMAGE(handles,ax,posval,scales,...
    imag(cwtcfs),ScType,titleSTR,decale,realCFS);
if resetAXES
    if realCFS , vis = 'Off'; else vis = 'On'; end
    set(findall([ax;hC]),'Visible',vis);
end

% Initialization of AxeMAN
Pop_AXE_MAN_Callback(handles.Pop_AXE_MAN,eventdata,handles,'init')

hdl_Menus = wtbxappdata('get',fig,'hdl_Menus');
m_save = hdl_Menus.m_save;
m_exp_data = hdl_Menus.m_exp_data;

SavMenOnOff(fig,'0.1','On')
set([handles.CHK_LST_REC;handles.CHK_MAN_REC],'Enable','Off')
Hdl_to_Enable = [...
    m_save; ...
    handles.Txt_METH_SYNT;handles.Pop_METH_SYNT; ...
    handles.Txt_SHO_REC;handles.CHK_ORI_REC;handles.Pus_SEL_REC;...
    handles.Txt_METH_SYNT;handles.Pop_METH_SYNT; ...
    handles.Pus_LST_SEL;handles.Pus_MAN_OPEN;m_exp_data];
set(Hdl_to_Enable,'Enable','On');

axHdl = [...
    handles.Axe_SIG_L,handles.Axe_SIG_R, ...
    handles.Axe_MOD,handles.Axe_REAL,handles.Axe_ANG,handles.Axe_IMAG];
dynvtool('init',fig,[],axHdl,[],[1 0],'','','');
set([handles.Axe_SIG_L,handles.Axe_SIG_R,handles.Axe_SIG_S],'Box','On');
showDistances(1,fig)

wwaiting('off',fig);
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles) 

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

% WTBX -- Install COLORMAP FRAME
%-------------------------------
utcolmap('Install_V3',hObject,'Enable','On');
default_nbcolors = 128;
cbcolmap('set',hObject,'pal',{'jet',default_nbcolors})

% Set colors and fontes for the figure.
%---------------------------------------
FigColor = get(hObject,'Color');
BkColor  = get(handles.Pan_MAN_SEL,'BackgroundColor');

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',hObject,mfilename);
set(handles.Txt_BigTitle,...
    'BackgroundColor',FigColor,'ForegroundColor',[0 0 1],...
    'FontSize',12,'FontWeight','Bold')
set(handles.Edi_MAN_TIT,'FontSize',10,...
    'ForegroundColor',[0 0 0.9],'BackgroundColor',BkColor)

% Store Axes Positions
%---------------------
hAXES = findobj(hObject,'Type','Axes');
axe_STORAGE = cell(8,4);
axe_STORAGE(:,1) = get(hAXES,'Tag');
axe_STORAGE(:,2) = num2cell(findobj(hObject,'Type','Axes'));
axe_STORAGE(:,3) = get(hAXES,'Position');
axe_STORAGE(:,4) = axe_STORAGE(:,3);
pL = get(axe_STORAGE{6,2},'Position');
pR = get(axe_STORAGE{5,2},'Position');
pMOD = get(axe_STORAGE{4,2},'Position');
pMOD(3) = pR(1)+pR(3)-pL(1);
axe_STORAGE{4,4} = pMOD;
pREA = get(axe_STORAGE{3,2},'Position');
pANG = get(axe_STORAGE{2,2},'Position');
pREA([1 3]) = pMOD([1 3]);
pREA(2) = pANG(2);
axe_STORAGE{3,4} = pREA;
pL(3) = pMOD(3);
axe_STORAGE{6,4} = pL;
wtbxappdata('set',hObject,'axe_STORAGE',axe_STORAGE);
wtbxappdata('set',hObject,'FlagReal',0);

% Initialize Synthesized Status.
%-------------------------------
hdl_CHK =[handles.CHK_ORI_REC ; handles.CHK_LST_REC ; handles.CHK_MAN_REC];
% For each BOX n°J, Tab_Synt_Status(J,:) = [handle value ErrMAX ErrL2];
Tab_Synt_Status = [double(hdl_CHK) , zeros(3,3)];
wtbxappdata('set',hObject,'Tab_Synt_Status',Tab_Synt_Status);

% Adding the bump wavelet to the Pop_WAV_NAM button.
%--------------------------------------------------
TMP = [get(handles.Pop_WAV_NAM,'String');{'bump'}];
set(handles.Pop_WAV_NAM,'String',TMP);

% Initialize TooltipStrings.
%---------------------------
set([handles.Txt_SAMP;handles.Edi_SAMP],'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_DefineSamplingPeriodForContinuousAnalysis'));
set([handles.Txt_WAV_NAM;handles.Pop_WAV_NAM; ...
    handles.Txt_WAV_PAR;handles.Pop_WAV_PAR],'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_SelectWaveletAndWaveletParametersForContinuousAnalysis'));
set(handles.Pus_ANAL,'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_LaunchCWTFTForTheSignal'));
set([handles.Txt_DEF_SCA;handles.Pop_DEF_SCA; ...
    handles.Pus_DEF_MAN;],'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_DefineScalesForContinuousAnalysis'));
set(handles.Lst_SEL_SC,'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_SelectScalesUsingMousenCTRLMAJAndArrowKeys'));
set(handles.Pus_SEL_REC,'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_SynthesizeTheSignalUsingInverseFunction'));
set(handles.Pus_SEL_ALL,'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_SelectAllScalesForReconstruction'));
set(handles.Pus_MAN_DEL,'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_DeleteAllCoefficientBoxes'));
set(handles.Pus_MAN_REC,'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_SynthesizeASignalFromSelected'));
set([handles.CHK_ORI_REC;handles.CHK_LST_REC;...
    handles.CHK_MAN_REC;handles.Txt_SHO_REC],'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_ShowOrHideTheSynthesizedSignals'));
set(handles.Pus_LST_SEL,'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_ListSelectionToolForScales'));
set(handles.Pus_MAN_OPEN,'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_ManualSelectionToolForCoefficients'));
set(handles.Pop_AXE_MAN,'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_SelectTheAxesForCoefficientsSelection'));

% Add Context Sensitive Help (CSHelp).
%-------------------------------------
CTXT_HDL = [...
    handles.Pus_HLP;handles.Pop_AXE_MAN; ...
    handles.Pus_MAN_DEL; handles.Axe_MAN_SEL; ...
    handles.Pus_MAN_OPEN;handles.Pus_MAN_REC  ...
    ];
wfighelp('add_ContextMenu',hObject,CTXT_HDL,'CWTFTTOOL_HLP');

% Initialize Analysis Parameters.
%--------------------------------
% --- Sampling period
AP.sampPer = 1; 
% --- Wavelet 
WAV.name =  'morl'; WAV.param = 6;
AP.WAV = WAV;
% --- Scales
nbSamp = 1000;
SCA.s0 = 2*AP.sampPer; SCA.ds = 0.4875; 
SCA.nb = fix(log2(nbSamp*AP.sampPer/SCA.s0)/SCA.ds);
SCA.type = 'pow'; SCA.pow = 2;
AP.SCA = SCA;
AP.scales = (SCA.s0) * (SCA.pow).^((0:(SCA.nb)-1)*(SCA.ds));
wtbxappdata('set',hObject,'Pow_Anal_Params',AP);
wtbxappdata('set',hObject,'Default_Pow_Anal_Params',AP);
% ---------
AP.sampPer = 1; 
SCA.s0 = 2*AP.sampPer; SCA.ds = SCA.s0; 
SCA.nb = (nbSamp/2*AP.sampPer-AP.sampPer); 
SCA.type = 'lin';
AP.SCA = SCA;
AP.scales = SCA.s0:SCA.ds:SCA.nb;
wtbxappdata('set',hObject,'Linear_Anal_Params',AP);
wtbxappdata('set',hObject,'Default_Linear_Anal_Params',AP);
%---------------------------------------------
% X = imread('help24x24_questmark.jpg');
% set(handles.Pus_HLP,'Cdata',X,'String','');

% Initialize texts for xlabels.
%------------------------------
set(handles.Txt_Xlab_AL,'BackgroundColor',FigColor);
posINI = get(handles.Txt_Xlab_AL,'Position');
set(handles.Txt_Xlab_AL,'Userdata',posINI);
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%
function cleanTOOL(option,fig,handles,typeLOAD) 

switch option
    case {'load_beg','anal_beg'}
        if strcmpi(get(handles.Pan_MAN_SEL,'Visible'),'on')
            Pus_MAN_CLOSE_Callback(handles.Pus_MAN_CLOSE,[],handles)
        end
        if strcmpi(get(handles.Pan_SEL_SC,'Visible'),'on')
            Pus_LST_SEL_Callback(handles.Pus_LST_SEL,[],handles)
        end
        
        hdl_Axe_SIG  = [handles.Axe_SIG_L ; handles.Axe_SIG_R]; 
        hdl_Axe_ANAL = [...
            handles.Axe_MOD ; handles.Axe_ANG; ...
            handles.Axe_REAL; handles.Axe_IMAG];
        axCB = wfindobj(fig,'Tag','Colorbar');
        hdl_Axe_MAN = [handles.Axe_SIG_S ; handles.Axe_MAN_SEL];
        axL = handles.Axe_SIG_L;
        axS = handles.Axe_SIG_S;
        switch option
            case 'load_beg'
                vis = 'off';
                hdl_AXE_Child = allchild(...
                    [hdl_Axe_SIG ; hdl_Axe_ANAL ; hdl_Axe_MAN]);
                toDEL = cat(1,hdl_AXE_Child{:});
                hdl_VIS_OnOff = hdl_Axe_SIG;
                
            case 'anal_beg' 
                vis = 'on';
                hdl_Inv = [...
                    findobj(axL,'Tag','RecSIG') ; ...
                    findobj(axS,'Tag','RecSIG') ; ...
                    findobj(axL,'Tag','RecLST') ; ...
                    findobj(axS,'Tag','RecLST');  ...
                    findobj(axL,'Tag','RecMAN') ; ...
                    findobj(axS,'Tag','RecMAN')];
                R = wfindobj(handles.Axe_MAN_SEL,'Type','patch');
                L = wfindobj(handles.Axe_MAN_SEL,'Type','line');
                hdl_AXE_Child = allchild(hdl_Axe_ANAL);
                toDEL = [hdl_Inv ; R ; L ; cat(1,hdl_AXE_Child{:})];
                hdl_VIS_OnOff = [];
        end
        delete(toDEL);
        delete(axCB(ishandle(axCB)));
        SavMenOnOff(fig,'allMenAndSub','Off')
        CHK_REC = [handles.CHK_ORI_REC;handles.CHK_LST_REC; ...
            handles.CHK_MAN_REC];
        set(CHK_REC,'Value',0);
        set([handles.Txt_SHO_REC;CHK_REC],'Enable','Off');
        Tab_Synt_Status = [double(CHK_REC) , zeros(3,3)];
        wtbxappdata('set',fig,'Tab_Synt_Status',Tab_Synt_Status);
        hdl_VIS_OnOff = [hdl_VIS_OnOff;...
            handles.Txt_BigTitle ; hdl_Axe_ANAL];
        hdl_VIS_OnOff = hdl_VIS_OnOff(ishandle(hdl_VIS_OnOff));
        wtbxappdata('set',fig,'Sel_Box_CFS',[]);
        CHK_REC_Callback(handles.CHK_ORI_REC,[],handles,vis,0)
        set(hdl_VIS_OnOff,'Visible',vis);
        if isequal(option,'load_beg')
            AP = wtbxappdata('get',fig,'Default_Pow_Anal_Params');
            set(handles.Edi_SAMP,'String',sprintf('%1.1f',AP.sampPer));
            if ~isequal(typeLOAD,'demo')
                set(handles.Pop_WAV_NAM,'Value',1) % Morlet
                set(handles.Pop_WAV_PAR,'Value',6)
                Pop_WAV_NAM_Callback(fig,[],handles)
            end
            set(handles.Pop_DEF_SCA,'Value',1)
            Pop_DEF_SCA_Callback(handles.Pop_DEF_SCA,[],handles)
        end
end
%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function hdl_Menus = Install_MENUS(fig)

% Add UIMENUS.
%-------------
m_files  = wfigmngr('getmenus',fig,'file');
m_close  = wfigmngr('getmenus',fig,'close');
cb_close = [mfilename '(''Pus_CloseWin_Callback'',gcbo,[],guidata(gcbo));'];
set(m_close,'Callback',cb_close);

m_Load_Data = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:cwtfttool:label_LoadData'), ...
    'Position',1,'Enable','On','Tag','Load',  ...
    'Callback',                ...
    [mfilename '(''Load_Data_Callback'',gcbo,[],guidata(gcbo),''load'');']  ...
    );
m_save = uimenu(m_files,...
    'Label',getWavMSG('Wavelet:cwtfttool:label_Save'),'Position',2, 'Enable','Off'  ...
    );

m_savsig = uimenu(m_save,...
    'Label',getWavMSG('Wavelet:cwtfttool:label_SynthesizedSignal'), ...
    'Position',1,'Enable','Off','Tag','SavSIG_Men');
cb_Men = [mfilename '(''save_FUN'',gcbo,[],guidata(gcbo),''rec'');'];
uimenu(m_savsig,'Label',getWavMSG('Wavelet:cwtfttool:label_FromInitialScales'), ...
    'Enable','Off','Position',1,'Tag','FromInitSca','Callback',cb_Men);
uimenu(m_savsig,'Label', getWavMSG('Wavelet:cwtfttool:label_FromListOfScales'), ...
    'Enable','Off','Position',2,'Tag','FromListSca','Callback',cb_Men);
uimenu(m_savsig,'Label',getWavMSG('Wavelet:cwtfttool:label_FromManualSelection'), ...
    'Enable','Off','Position',3,'Tag','FromManSel','Callback',cb_Men); 

uimenu(m_save,...
    'Label',getWavMSG('Wavelet:cwtfttool:label_Decomposition'), ...
    'Position',2, 'Enable','On','Tag','Decomposition',  ...
    'Callback',[mfilename '(''save_FUN'',gcbo,[],guidata(gcbo),''dec'');'] ...
    );

m_demo = uimenu(m_files,'Label',getWavMSG('Wavelet:cwtfttool:label_ExampleAnalysis'),...
    'Position',3,'Separator','Off');
m_demo_1 = uimenu(m_demo,'Label',getWavMSG('Wavelet:cwtfttool:label_ExamplesI'),...
    'Tag','ExamplesI','Position',1,'Separator','Off');
m_demo_2 = uimenu(m_demo,'Label',getWavMSG('Wavelet:cwtfttool:label_ExamplesII'),...
    'Tag','ExamplesII','Position',2,'Separator','Off');
uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:cwtfttool:label_ImportData'), ...
    'Position',4,'Enable','On' ,'Separator','On',  ...
    'Tag','Import', ...
    'Callback',                ...
    [mfilename '(''Load_Data_Callback'',gcbo,[],guidata(gcbo),''import'');']  ...
    );

m_exp_data = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:cwtfttool:label_ExportData'),'Position',5, ...
    'Tag','Export_Data','Enable','Off','Separator','Off'  ...
    );
uimenu(m_exp_data, ...
    'Label',getWavMSG('Wavelet:cwtfttool:label_ExportSynthesizedSignalToWorkspace'),'Position',1, ...
    'Enable','On','Separator','Off','Tag','Export_SS',...
    'Callback',...
    [mfilename '(''Export_Callback'',gcbo,[],guidata(gcbo),''sig'');']...
    );
uimenu(m_exp_data, ...
    'Label',getWavMSG('Wavelet:cwtfttool:label_ExportCWTFTStructToWorkspace'),'Position',2, ...
    'Enable','On','Separator','Off','Tag','Export_CWTFT',...
    'Callback',...
    [mfilename '(''Export_Callback'',gcbo,[],guidata(gcbo),''ana'');']  ...
    );

sigDESC = {...
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_CuspSig');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_sumsin');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_freqbrk');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_wstep');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_nearbrk');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_scddvbrk');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_whitnois');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_warma');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_noissin');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_noispol');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_wnoislop');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_cnoislop');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NHeavySin');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBlocks');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBumps');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NDoppler');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NQdchirp');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_Nmishmash');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_trsin');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_wntrsin');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_leleccum');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_wcantor');
    getWavMSG('Wavelet:moreMSGRF:EX1D_Name_vonkoch')
    };

nbSIG_PLUS = 35;
sigDESC_PLUS = cell(1,nbSIG_PLUS);
for k = 1:nbSIG_PLUS
    r = rem(k,4);
    if k<33
        num_SIG = floor(k/4);
        if r>0 , num_SIG = 1+num_SIG; end
    else
        num_SIG = floor(k/4)+r;
    end    
    sigDESC_PLUS{k} = ...
        getWavMSG(['Wavelet:moreMSGRF:CWTFT_Ex' int2str(k)],num_SIG);
end

nbSIG = length(sigDESC);
for k = 1:nbSIG
    uimenu(m_demo_1, ...
        'Label',getWavMSG('Wavelet:moreMSGRF:Num_EX_CWTFT',k,sigDESC{k}),   ...
        'Position',k,     ...
        'Enable','On',    ...
        'Callback',       ...
        [mfilename '(''Men_Example_Callback'',gcbo,[],guidata(gcbo),1);'] ...
        );
end

for k = 1:nbSIG_PLUS
    if ismember(k,(5:4:33)) , sep = 'on'; else sep = 'off';end    
    uimenu(m_demo_2, ...
        'Label',sigDESC_PLUS{k},    ...
        'Position',k,     ...
        'Enable','On',    ...
        'Separator',sep,  ...        
        'Callback',       ...
        [mfilename '(''Men_Example_Callback'',gcbo,[],guidata(gcbo),2);'] ...
        );
end

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',fig, ...
    getWavMSG('Wavelet:divGUIRF:HLP_CWTFT'),'CWTFT_GUI');

% Menu handles.
%----------------
hdl_Menus = struct('m_files',m_files,'m_close',m_close,...
    'm_Load_Data',m_Load_Data,...
    'm_save',m_save,'m_demo',m_demo,'m_exp_data',m_exp_data);
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%



%=========================================================================%
%                      BEGIN Demo Utilities                               %
%                      ---------------------                              %
%=========================================================================%
function closeDEMO(fig,eventdata,handles,varargin) 

close(fig);
%----------------------------------------------------------
function demoPROC(fig,eventdata,handles,varargin) 

% Initialization for next plot
tool_PARAMS = wtbxappdata('get',fig,'tool_PARAMS');
tool_PARAMS.demoMODE = 'on';
wtbxappdata('set',fig,'tool_PARAMS',tool_PARAMS );
set(fig,'HandleVisibility','Callback')
%----------------------------------------------------------
function Men_Example_Callback(hObject,eventdata,handles,varargin) %#ok<*INUSD>

optDEM = varargin{1};
numDEM = get(hObject,'Position');
switch optDEM
    case 1
        filename = { ...
            'cuspamax' ; ...
            'sumsin'   ; 'freqbrk'  ; 'wstep' ;    ...
            'nearbrk'  ; 'scddvbrk' ; 'whitnois' ; ...
            'warma'    ; 'noissin'  ; 'noispol'  ; ...
            'wnoislop' ; 'cnoislop' ; 'heavysin' ; ...
            'noisbloc' ; 'noisbump' ; 'noisdopp' ; ...
            'noischir' ; 'noismima' ; ...
            'trsin'    ; 'wntrsin'  ; 'leleccum' ; ...
            'wcantor'  ; 'vonkoch'  ...
            };
        fileOPT = 'load';  demoPAR = filename{numDEM};
    case 2
        fileOPT = 'built'; demoPAR = numDEM;
end
Load_Data_Callback(hObject,eventdata,handles,'demo',fileOPT,demoPAR);
%--------------------------------------------------------------------------
function Y = getDemoSIG(num_SIG,N)

if nargin<2 , N = 1024; end
switch num_SIG
    case 1 , t = linspace(0,1,N); Y = sin(4*pi*t);
    case 2 , t = linspace(0,1,N); Y = (t>0.25).*(t<0.75).*sin(4*pi*t);
    case {3,4}
        t = linspace(0,1,N);
        Y = sin(8*pi*t).*(t<=0.5) + sin(16*pi*t).*(t>0.5);
        if isequal(num_SIG,4) , Y = Y + 0.2*randn(size(Y)); end
    case 5
        t = linspace(1,1/N,N);
        x = 4*sin(4*pi*t);
        Y = x - sign(t - .3) - sign(.72 - t);
    case 6  , Y = wnoise('bumps',fix(log2(N)));
    case {7,8} ,
        t = linspace(0,1,N);
        if isequal(num_SIG,7) ,
            Y = sin(4*pi*t)+ sin(8*pi*t);
        else
            Y = sin(8*pi*t)+ sin(16*pi*t)+ sin(32*pi*t);
        end
    case 9 , Y = rand(1,N);
    case 10 , Y = randn(1,N);
    case 11 , Y = zeros(1,N); Y(fix(N/2)) = 1;
end
%-------------------------------------------------------------------------%
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%


%--------------------------------------------------------------------------
function Load_Data_Callback(hObject,eventdata,handles,varargin) %#ok<*INUSL>

% Get figure handle.
%-------------------
fig = handles.output;

typeLOAD = varargin{1};
switch typeLOAD
    case 'load'
        [filename,pathname] = uigetfile( ...
            {'*.mat','MAT-files (*.mat)'; ...
            '*.*',  'All Files (*.*)'}, ...
            getWavMSG('Wavelet:divGUIRF:Pick_a_file'), ...
            'Untitled.mat');
        ok = ~isequal(filename,0);
        if ~ok, return; end
        err = 0;
        try
            Data = whos('-file',[pathname filename]);
            nbData = length(Data);
            Okdata = false(1,nbData);
            [~,fname] = fileparts([pathname filename]);
            idxVar = find(strcmp(fname,{Data(:).name}));
            if isempty(idxVar)
                idxVar = 0;
                for k = 1:nbData
                    DS = Data(k).size;
                    nbdim = length(DS);
                    if nbdim==2
                        Okdata(k) = 1;
                        idxVar = k;
                    end
                    if Okdata(k) , NameVar = Data(k).name; break; end
                end
            else
                NameVar = Data(idxVar).name;
            end            
            if idxVar>0
                S = load([pathname filename]);
            else
                err = 1;
            end
        catch  %#ok<*CTCH>
            err = 1;
        end
        if ~err && isfield(S,NameVar)
            X = S.(NameVar);
            X = squeeze(X);
            if min(size(X))<0 , err = 1; end
        else
            err = 1;
        end
        if err
            uiwait(warndlg(getWavMSG('Wavelet:cwtfttool:dlg_Invalid1DData')),...
                getWavMSG('Wavelet:cwtfttool:dlg_Loading1DData'),'modal')
            return;
        end
        [~,Data_Name] = fileparts([pathname filename]);
        
    case 'import'
        [dataInfos,X,ok] = wtbximport('1d');
        if ~ok, return; end
        Data_Name = dataInfos.name;

    case 'demo'
        fileOPT = varargin{2};
        demoPAR = varargin{3};
        switch fileOPT
            case 'load'
                filename = demoPAR;
                S  = load(filename);
                fn = fieldnames(S);
                if isfield(S,'X') , X = S.('X'); else X = S.(fn{1}); end
                [~,Data_Name] = fileparts(filename);
                
            case 'built'
                if demoPAR<33
                    num_SIG = floor(demoPAR/4);
                    r = rem(demoPAR,4);
                    if r>0 , num_SIG = 1+num_SIG; end
                    switch r
                        case 0 , valWAV = 6; valPAR = 1;
                        case 1 , valWAV = 1; valPAR = 6;
                        case 2 , valWAV = 4; valPAR = 1;
                        case 3 , valWAV = 5; valPAR = 2;
                    end
                    set(handles.Pop_WAV_NAM,'Value',valWAV);
                    Pop_WAV_NAM_Callback(handles.Pop_WAV_NAM,...
                        eventdata,handles);
                    set(handles.Pop_WAV_PAR,'Value',valPAR);
                else
                    r = rem(demoPAR,4);
                    num_SIG = floor(demoPAR/4)+r;
                end
                X = getDemoSIG(num_SIG,1024);
                Data_Name = ['Example ' int2str(num_SIG)];
        end
        
end
nbSamp = length(X);
wtbxappdata('set',fig,'Sig_ANAL',X);

% Cleaning.
%----------
wwaiting('msg',fig,getWavMSG('Wavelet:cwtfttool:WaitClean'));

% Clean Axes.
%------------
cleanTOOL('load_beg',fig,handles,typeLOAD);

% Clean UIC.
%------------
hdl_Menus = wtbxappdata('get',fig,'hdl_Menus');
m_save = hdl_Menus.m_save;
m_exp_data = hdl_Menus.m_exp_data;
Hdl_to_Disable = [...
    m_save,m_exp_data,  ...
    handles.Pus_SEL_REC,handles.Pus_LST_SEL,handles.Pus_MAN_OPEN ...
    ];
Hdl_to_Enable = [...
    handles.Edi_SAMP,    ...
    handles.Pop_WAV_NAM,handles.Pop_WAV_PAR,...
    handles.Pop_DEF_SCA,handles.Pus_ANAL     ...
    ];
set([Hdl_to_Disable,Hdl_to_Enable],'Enable','Off');

% Setting GUI values and Analysis parameters.
%--------------------------------------------
n_s = [Data_Name '  (' , int2str(length(X)) ')'];
set(handles.Edi_Data_NS,'String',n_s);

% Display the original data.
%---------------------------
LW = 1.5;
Edi_SAMP = handles.Edi_SAMP;
dt = str2double(get(Edi_SAMP,'String'));
Axe_SIG_L = handles.Axe_SIG_L;
Axe_SIG_R = handles.Axe_SIG_R;
Axe_SIG_S = handles.Axe_SIG_S;
set(wfindobj(Axe_SIG_L),'Visible','On');
set(Axe_SIG_R,'Visible','Off');
titleSTR = getWavMSG('Wavelet:cwtfttool:title_AnalyzedSignal');
posval = dt*(0:nbSamp-1);
plot(posval,X,'r','Tag','SIG','Linewidth',LW,'Parent',Axe_SIG_L); 
wtitle(titleSTR,'Parent',Axe_SIG_L)
plot(posval,X,'r','Tag','SIG',...
    'Linewidth',LW,'Visible','Off','Parent',Axe_SIG_R); 
wtitle(titleSTR,'Parent',Axe_SIG_R)
plot(posval,X,'r','Tag','SIG','Linewidth',LW,'Parent',Axe_SIG_S); 
wtitle(titleSTR,'Parent',Axe_SIG_S)
set([Axe_SIG_L,Axe_SIG_R,Axe_SIG_S],...
    'Xlim',[posval(1),posval(end)],...
    'Ylim',[min(X),max(X)],'Box','On');

% Clean Tool.
%------------
set(Hdl_to_Enable,'Enable','On');

% End waiting.
%-------------
wwaiting('off',fig);

% Demo case.
%-----------
if isequal(typeLOAD,'demo')
     Pus_ANAL_Callback(handles.Pus_ANAL,eventdata,handles);
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function hC = plotIMAGE(handles,ax,posval,SCA,...
    CFS,ScType,titleSTR,decale,realCFS)

if nargin<7 , decale = 0; end
if abs(decale)>0
    pos = get(ax,'Position');
    pos(2) = pos(2)- decale;
    set(ax,'Position',pos);
end
NbSc = size(CFS,1);
if isequal(ScType,'pow')
    mul = 200;
    NbSCA = SCA'/SCA(1);
    NbSCA = round(mul*NbSCA/sum(NbSCA));
    NbSCA_TOT = sum(NbSCA);    
    C = zeros(NbSCA_TOT,size(CFS,2));
    first = 1;
    for k = 1:NbSc
        last = first+NbSCA(k)-1;
        C(first:last,:) = repmat(CFS(k,:),NbSCA(k),1);
        first = last+1;
    end
else
    C = CFS;
end
imagesc(posval,SCA,C,'Parent',ax);
hC = Add_ColorBar(ax);
wxlabel(titleSTR,'Parent',ax);
set(ax,'YDir','normal')
if isequal(ScType,'pow')
    set(ax,'NextPlot','add');
    yt = zeros(1,NbSc-1);
    for k = 1:NbSc-1 , yt(k)  = 0.5*(SCA(k)+SCA(k+1)); end
    for k = 1:NbSc-1
        hold on
        plot(posval,yt(k)*ones(1,length(posval)),':k','Parent',ax);
    end
    nb = min([10,NbSc-2]);
    YTaff = yt(end-nb:end);
    maxYT = max(YTaff);
    set(ax,'YTick',YTaff,'FontSize',9);
    if maxYT>0.05
        if maxYT<0.1     , precFormat = '%0.4f';
        elseif maxYT<10  , precFormat = '%0.3f';
        elseif maxYT<100 , precFormat = '%0.2f';
        else               precFormat = '%0.1f';
        end
        YTlab = num2str(SCA(end-nb:end)',precFormat);
        set(ax,'YTickLabel',YTlab);
    end
    set(ax,'NextPlot','replacechildren');
elseif isequal(ScType,'lin')
    % G714785 fix
    if length(SCA)<2 , SCA = [SCA-0.01 , SCA+0.01]; end
    YTaff = linspace(SCA(1),SCA(end),10);
    YTlab = num2str(YTaff','%2.1f');
    set(ax,'YTick',YTaff,'YTickLabel',YTlab,'FontSize',9);
else  % G714785 fix
    YTaff = SCA;
    YTlab = num2str(YTaff','%2.1f');
    set(ax,'YTick',YTaff,'YTickLabel',YTlab,'FontSize',9);    
end
set(ax,'XLim',[posval(1),posval(end)],'YLim',[SCA(1),SCA(end)])
%--------------------------------------------------------------------------
function hC = Add_ColorBar(hA)

pA = get(hA,'Position');
hC = colorbar('peer',hA,'EastOutside');
set(hA,'Position',pA);
pC = get(hC,'Position');
set(hC,'Position',[pA(1)+pA(3)+0.01  pC(2)+pC(4)/15 pC(3)/2 4*pC(4)/5])
ud.dynvzaxe.enable = 'Off';
ud.Parent = hA;
set(hC,'UserData',ud);
%-----------------------------------------------------------------------
function SavMenOnOff(fig,num,ena)

SavSIG_Men = wfindobj(fig,'Type','uimenu','Tag','SavSIG_Men');
switch num
    case {1,2,3}
        M = wfindobj(fig,'Type','uimenu', ...
            'Parent',SavSIG_Men,'Position',num);
        
    case '0.1'
        M = wfindobj(fig,'Type','uimenu', ...
            'Parent',SavSIG_Men,'Position',1);
        M = [SavSIG_Men;M];
        
    case 'all'
        M = wfindobj(fig,'Type','uimenu','Parent',SavSIG_Men);
        
    case 'allMenAndSub'
        M = wfindobj(fig,'Type','uimenu','Parent',SavSIG_Men);
        M = [SavSIG_Men;M];
end
set(M,'Enable',ena);
%-----------------------------------------------------------------------


%=========================================================================%
%                BEGIN UICONTROL CALLBACKS FUNCTIONS                      %
%                -----------------------------------                      %
%=========================================================================%
%--------------------------------------------------------------------------
function Edi_SAMP_Callback(hObject,eventdata,handles)

val = str2double(get(hObject,'String'));
notOK = isnan(val) || val<=0 || ~isfinite(val);
if notOK
    usr = get(hObject,'Userdata');
    set(hObject,'String',num2str(usr));
    return
end
set(hObject,'Userdata',val);
%--------------------------------------------------------------------------
function resetSamplingPeriod(handles)

val = str2double(get(handles.Edi_SAMP,'String'));
ax_L = handles.Axe_SIG_L;
h_L  = findobj(ax_L,'Tag','SIG');
if isempty(h_L) , return; end
ax_R = handles.Axe_SIG_R;
ax_S = handles.Axe_SIG_S;
h_R = findobj(ax_R,'Tag','SIG');
h_S = findobj(ax_S,'Tag','SIG');
h_LRec = findobj(ax_L,'Tag','RecSIG');
ax_S   = handles.Axe_SIG_S;
h_SRec = findobj(ax_S,'Tag','RecSIG');
h_IL = findobj(ax_L,'Tag','RecLST');
h_IS = findobj(ax_S,'Tag','RecLST');
% ax_IMG = [handles.Axe_IMAG;handles.Axe_ANG;handles.Axe_REAL; ...
%     handles.Axe_MOD;handles.Axe_MAN_SEL];
% img = wfindobj(ax_IMG,'Type','image');
img = []; ax_IMG = [];
nbSamp = length(get(h_L,'XData'));
xd = val*(0:nbSamp-1);
set([h_L;h_R;h_S;h_LRec;h_SRec;h_IL;h_IS;img],'XData',xd)
set([ax_L;ax_R;ax_S;ax_IMG],'XLim',[0,xd(end)]);
%--------------------------------------------------------------------------
function Pop_METH_SYNT_Callback(hObject,eventdata,handles)

%--------------------------------------------------------------------------
function CHK_REC_Callback(hObject,eventdata,handles,ena,val)

if nargin>4 , set(hObject,'value',val); end   % For cleaning purpose.
Tag = get(hObject,'Tag');
ORIflag = 0;
switch Tag
    case 'CHK_ORI_REC' , TagSIG = 'RecSIG'; ORIflag = 1;
    case 'CHK_LST_REC' , TagSIG = 'RecLST';
    case 'CHK_MAN_REC' , TagSIG = 'RecMAN';
end
[~,fig] = gcbo;
vRad = get(hObject,{'value','Userdata'});
if isequal(vRad{1},1) , showREC = true; else showREC = false; end

Tab_Synt_Status = wtbxappdata('get',fig,'Tab_Synt_Status');
idx_CHK = find((Tab_Synt_Status(:,1)==hObject));
Tab_Synt_Status(idx_CHK,2) = vRad{1};

ax  = handles.Axe_SIG_L;
axS = handles.Axe_SIG_S;
hRS = findobj(axS,'Tag',TagSIG); 
hR = findobj(ax,'Tag',TagSIG); 
h  = findobj(ax,'Tag','SIG');
Y  = get(h,'YData');
if showREC
    CWTS = wtbxappdata('get',fig,'CWTStruct');
    YRec = icwt_SYNTHESIS(handles,CWTS);
    v = 'on';
    if isempty(hR) && ORIflag
        LW = 1.5;
        xd = get(h,'XData');
        errMAX = max(abs(Y(:)-YRec(:)))/max(abs(Y(:)));
        errL2  = norm(Y(:)-YRec(:))/norm(Y(:));
        Tab_Synt_Status(idx_CHK,[3,4]) = [errMAX,errL2];
        hold on ;
        line('XData',xd,'YData',YRec,'Color','b', ...
            'Tag','RecSIG','Linewidth',LW,'Parent',ax);
        line('XData',xd,'YData',YRec,'Color','b', ...
            'Tag','RecSIG','Linewidth',LW,'Parent',axS);
    end    
    set([ax,axS],'Ylim',[ min([Y,YRec]),max([Y,YRec]) ])
else
    v = 'off';
    if ~isempty(Y)
        set([ax,axS],'YLim',[min(Y),max(Y)]);
    end
end
wtbxappdata('set',fig,'Tab_Synt_Status',Tab_Synt_Status);        
showDistances(idx_CHK,fig)
set([hRS;hR],'Visible',v);
if nargin>4 , set(hObject,'Enable',ena); end   % For cleaning purpose.
%--------------------------------------------------------------------------
function Pus_SEL_REC_Callback(hObject,eventdata,handles)

[~,fig] = gcbo;
CWTS = wtbxappdata('get',fig,'CWTStruct');
NbSc = size(CWTS.cfs,1);
LstSC = handles.Lst_SEL_SC;
IdxSEL = get(LstSC,'Value');
discardScales = setdiff(1:NbSc,IdxSEL);
CWTS.cfs(discardScales,:) = 0;
YRec = icwt_SYNTHESIS(handles,CWTS);

ax = handles.Axe_SIG_L;
axS = handles.Axe_SIG_S;
hInv = findobj(ax,'Tag','RecLST');
hInvS = findobj(axS,'Tag','RecLST');
h  = findobj(ax,'Tag','SIG');
Y  = get(h,'YData');
if isempty(hInv)
    RecCOL = [200 0 200]/255;
    LW = 1.5;
    xd = get(h,'XData');
    line('XData',xd,'YData',YRec,'Color',RecCOL,'Linewidth',LW,...
        'Tag','RecLST','Parent',ax);
    line('XData',xd,'YData',YRec,'Color',RecCOL,'Linewidth',LW,...
        'Tag','RecLST','Parent',axS);     
else
    set([hInv,hInvS],'YData',YRec)
end
set([ax,axS],'Ylim',[min([Y,YRec]),max([Y,YRec])])
errMAX = max(abs(Y(:)-YRec(:)))/max(abs(Y(:)));
errL2  = norm(Y(:)-YRec(:))/norm(Y(:));
Tab_Synt_Status = wtbxappdata('get',fig,'Tab_Synt_Status');
Tab_Synt_Status(2,[2 3 4]) = [1 errMAX,errL2];
wtbxappdata('set',fig,'Tab_Synt_Status',Tab_Synt_Status);
showDistances(2,fig);
SavMenOnOff(fig,2,'On');
%--------------------------------------------------------------------------
function Pus_LST_SEL_Callback(hObject,eventdata,handles)

PanSC = handles.Pan_SEL_SC;
ax = handles.Axe_SIG_L;
axS = handles.Axe_SIG_S;
hInv = findobj(ax,'Tag','RecLST');
hInvS = findobj(axS,'Tag','RecLST');
v = lower(get(PanSC,'Visible'));
if isequal(v,'on')
    v = 'off'; w = 'on';   
else
    v = 'on';  w = 'off';  
end
set(handles.Pus_ANAL,'Visible',w);
set([...
    handles.Txt_SAMP;handles.Edi_SAMP; ...
    handles.Txt_WAV_NAM;handles.Pop_WAV_NAM; ...
    handles.Txt_WAV_PAR;handles.Pop_WAV_PAR; ...
    handles.Txt_DEF_SCA;handles.Pop_DEF_SCA  ...
	],'Enable',w);

set([handles.Pus_LST_SEL;handles.Pus_MAN_OPEN],'Visible',w); ...
set([PanSC;hInv;hInvS],'Visible',v);
if isequal(v,'on') && ~isempty(hInv) , nb = 1; else nb = 0; end
set_TITLES(ax,axS,nb)
%--------------------------------------------------------------------------
function Pus_MAN_OPEN_Callback(hObject,eventdata,handles) %#ok<*DEFNU>

fig = gcbf;
set([hObject;handles.Pus_LST_SEL; ...
    handles.Pop_METH_SYNT;handles.Txt_METH_SYNT],'Enable','Off');
Pan_MAN_SEL = handles.Pan_MAN_SEL;

axInFig = wfindobj(fig,'Type','axes');
axeCB = wfindobj(fig,'tag','Colorbar');
axeCB_child = allchild(axeCB);
axeCB_child = cat(1,axeCB_child{:});

StoreState = cell(length(axInFig),3);
StoreState(:,1) = num2cell(axInFig);
StoreState(:,2) = get(axInFig,'Tag');
StoreState(:,3) = get(axInFig,'Visible');
wtbxappdata('set',fig,'MAN_StoreState',StoreState);
Save_WindowButtonDownFcn = get(fig,'WindowButtonDownFcn');
wtbxappdata('set',fig,...
    'Save_WindowButtonDownFcn',Save_WindowButtonDownFcn);
set(fig,'WindowButtonDownFcn',cwtselect(handles.Axe_MAN_SEL));
Pop_AXE_MAN_Callback(handles.Pop_AXE_MAN,eventdata,handles)

ax = handles.Axe_SIG_L;
hInv = findobj(ax,'Tag','RecMAN');
set([...
    handles.Pus_ANAL;...
    handles.Txt_SAMP;handles.Edi_SAMP; ...
    handles.Txt_WAV_NAM;handles.Pop_WAV_NAM; ...
    handles.Txt_WAV_PAR;handles.Pop_WAV_PAR; ...
    handles.Txt_DEF_SCA;handles.Pop_DEF_SCA; ...
    handles.Pus_DEF_MAN],'Enable','Off');
Txt_Xlab = handles.Txt_Xlab_AL;
ChgVIS = [...
    handles.Txt_BigTitle; axeCB ; axeCB_child; ...
    handles.Axe_SIG_L ; handles.Axe_SIG_R; Txt_Xlab(:) ; ...
    handles.Axe_MOD   ; handles.Axe_ANG; ...
    handles.Axe_REAL  ; handles.Axe_IMAG];
set(ChgVIS,'Visible','Off');
hInvS = findobj(handles.Axe_SIG_S,'Tag','RecMAN');
if isempty(hInvS) , recVAL = 0; else recVAL = 1; end 
set(handles.CHK_MAN_REC,'Value',recVAL);
Tab_Synt_Status = wtbxappdata('get',fig,'Tab_Synt_Status');
Tab_Synt_Status(3,2) = recVAL;
wtbxappdata('set',fig,'Tab_Synt_Status',Tab_Synt_Status);        
showDistances(3,fig)
set(hInvS,'Visible','on');
set([Pan_MAN_SEL,hInv],'Visible','on');
set(handles.Rad_ON,'Enable','on','Value',0)
Rad_ON_Callback(handles.Rad_ON,[],handles,'open_manual')
cwtftbtn('setbox',fig,'ini',handles);
%--------------------------------------------------------------------------
function Pus_MAN_CLOSE_Callback(hObject,eventdata,handles)

fig = gcbf;
Pan_MAN_SEL = handles.Pan_MAN_SEL;
axeCB = wfindobj(fig,'tag','Colorbar');
axeCB_child = allchild(axeCB);
axeCB_child = cat(1,axeCB_child{:});

v = 'off';
Save_WindowButtonDownFcn = wtbxappdata('get',fig,...
    'Save_WindowButtonDownFcn');
set(fig,'WindowButtonDownFcn',Save_WindowButtonDownFcn);
StoreState = wtbxappdata('get',fig,'MAN_StoreState');

ax = handles.Axe_SIG_L;
hInv = findobj(ax,'Tag','RecMAN');
set([...
    handles.Pus_ANAL;...
    handles.Txt_SAMP;handles.Edi_SAMP; ...
    handles.Txt_WAV_NAM;handles.Pop_WAV_NAM; ...
    handles.Txt_WAV_PAR;handles.Pop_WAV_PAR; ...
    handles.Txt_DEF_SCA;handles.Pop_DEF_SCA; ...
    handles.Pus_DEF_MAN],'Enable','On');
Txt_Xlab = handles.Txt_Xlab_AL;
ChgVIS = [...
    handles.Txt_BigTitle; axeCB ; axeCB_child; ...
    handles.Axe_SIG_L ; handles.Axe_SIG_R; Txt_Xlab(:); ...
    handles.Axe_MOD   ; handles.Axe_ANG; ...
    handles.Axe_REAL  ; handles.Axe_IMAG];
idxAxeVIS = strcmp(StoreState(:,3),'off');
AxeVIS = cat( 1,StoreState{idxAxeVIS,1});
set(ChgVIS,'Visible','On');
set(findall(AxeVIS),'Visible',v)
set(handles.CHK_MAN_REC,'Value',0);
set([Pan_MAN_SEL,hInv],'Visible','Off');
set(handles.Rad_ON,'Enable','off','Value',1)
Rad_ON_Callback(handles.Rad_ON,[],handles,'close_manual')
set([handles.Pus_LST_SEL,handles.Pus_MAN_OPEN, ...
     handles.Pop_METH_SYNT,handles.Txt_METH_SYNT],'Enable','On');
set([handles.Pus_LST_SEL;handles.Pus_MAN_OPEN],'Visible','On'); ...

Tab_Synt_Status = wtbxappdata('get',fig,'Tab_Synt_Status');
Tab_Synt_Status(3,2) = 0;
wtbxappdata('set',fig,'Tab_Synt_Status',Tab_Synt_Status);        
showDistances(3,fig)
%--------------------------------------------------------------------------
function Rad_ON_Callback(hObject,eventdata,handles,arg)

fig = gcbf;
MemDynV = dynvtool('rmb',fig);
hDynV   = dynvtool('handles',fig,'lst');
mngmbtn('delLines',fig,'All');
if nargin>3
    switch lower(arg)
        case 'open_manual'
            wtbxappdata('set',fig,'Input_MemDynV',MemDynV);
            axHdl = [handles.Axe_SIG_S,handles.Axe_MAN_SEL];
            dynvtool('init',fig,[],axHdl,[],[1 0],'','','');
        case 'close_manual'
            dynvtool('get',fig,0);
            MemDynV = wtbxappdata('get',fig,'Input_MemDynV');
            dynvtool('wmb',fig,MemDynV);
    end
end
val = get(hObject,'Value');
switch val
    case 0 , radCOL = [0.8 0 0]; ena_DynV = 'off';
    case 1 , radCOL = [0 0.8 0]; ena_DynV = 'on';
end
set(handles.Rad_ON,'ForegroundColor',radCOL,'String',getWavMSG('Wavelet:cwtfttool:DynVisu'));
set(hDynV(2:end-1),'Enable', ena_DynV);
switch val
    case 0
        set(fig,'WindowButtonDownFcn',cwtselect(handles.Axe_MAN_SEL));
    case 1
        DynV_WindowButtonDownFcn = wtbxappdata('get',fig,...
                        'Save_WindowButtonDownFcn');
        set(fig,'WindowButtonDownFcn',DynV_WindowButtonDownFcn);
end
%--------------------------------------------------------------------------
function Lst_SEL_SC_Callback(hObject,eventdata,handles)
%--------------------------------------------------------------------------
function Pus_SEL_ALL_Callback(hObject,eventdata,handles)

LstSC = handles.Lst_SEL_SC;
set(LstSC,'Value',1:size(get(LstSC,'String'),1))
%--------------------------------------------------------------------------
function Pus_SEL_NON_Callback(hObject,eventdata,handles)

LstSC = handles.Lst_SEL_SC;
set(LstSC,'Value',[])
%--------------------------------------------------------------------------
function Pus_SEL_CLOSE_Callback(hObject,eventdata,handles)

PanSC = handles.Pan_SEL_SC;
v = lower(get(PanSC,'Visible'));
if isequal(v,'on')
    v = 'off'; w = 'on';   
else
    v = 'on';  w = 'off';  
end
hInv = findobj(handles.Axe_SIG_L,'Tag','RecLST');
hInvS = findobj(handles.Axe_SIG_S,'Tag','RecLST');
set([...
    handles.Pus_LST_SEL; ...
    handles.Txt_SAMP;handles.Edi_SAMP; ...
    handles.Txt_WAV_NAM;handles.Pop_WAV_NAM;   ...
    handles.Txt_WAV_PAR;handles.Pop_WAV_PAR;   ...
    handles.Txt_DEF_SCA;handles.Pop_DEF_SCA; ...
    handles.Pus_DEF_MAN],'Enable',w);
set([handles.Pus_LST_SEL;handles.Pus_MAN_OPEN],'Visible',w); ...
NbSC = length(get(handles.Lst_SEL_SC,'Value'));
if NbSC>0 , ena_CHK = 'On'; else ena_CHK = 'Off'; end
set(handles.CHK_LST_REC,'Enable',ena_CHK,'Value',0);
set(handles.Pus_ANAL,'Visible',w);
set([PanSC,hInv,hInvS],'Visible',v);

fig = gcbf;
Tab_Synt_Status = wtbxappdata('get',fig,'Tab_Synt_Status');
Tab_Synt_Status(2,2) = 0;
wtbxappdata('set',fig,'Tab_Synt_Status',Tab_Synt_Status);        
showDistances(2,fig)
%--------------------------------------------------------------------------
function Lst_Scales_INI(fig,handles)

scales_INI = wtbxappdata('get',fig,'Scales_INI');
Lst_SC = handles.Lst_SEL_SC;
NbSc = length(scales_INI);
Lst = [repmat(' ',NbSc,1) num2str((1:NbSc)','%4.0f') ...
    repmat('  |  ',NbSc,1) num2str(scales_INI','%4.4f') ...
    ];    %    repmat('  |',NbSc,1)
set(Lst_SC,'String',Lst,'Value',[],'ListboxTop',1);
%--------------------------------------------------------------------------
function Pop_AXE_MAN_Callback(hObject,eventdata,handles,varargin)

fig = gcbf;
v = get(hObject,{'Value','UserData','String'});
if isequal(v{1},v{2}) && nargin<4 , return; end
set(hObject,'UserData',v{1});
if length(v{3})==4
    switch v{1}
        case 1 , axe2COPY = handles.Axe_MOD;
        case 2 , axe2COPY = handles.Axe_ANG;
        case 3 , axe2COPY = handles.Axe_REAL;
        case 4 , axe2COPY = handles.Axe_IMAG;
    end
else
    switch v{1}
        case 1 , axe2COPY = handles.Axe_MOD;
        case 2 , axe2COPY = handles.Axe_REAL;
    end
end
cwtftbtn('setbox',fig,'ini',handles);
Lst_Sel_Box = wtbxappdata('get',fig,'Sel_Box_CFS');
nbBOX = length(Lst_Sel_Box);
XD = cell(1,nbBOX);
YD = cell(1,nbBOX);
for k=1:nbBOX
    SB = Lst_Sel_Box{k}(1);
    XD{k} = get(SB,'XData');
    YD{k} = get(SB,'YData');
end
axe_MAN = handles.Axe_MAN_SEL;
axe_MAN_child = allchild(axe_MAN);
toDel = axe_MAN_child;
delete(toDel)

img = wfindobj(axe2COPY,'Type','image');
axePAR = get(axe2COPY,{'XLim','YLim'});
imgPAR = get(img,{'XData','YData','CData'});
imagesc('XData',imgPAR{1},'YData',imgPAR{2},'CData',imgPAR{3}, ...
    'Parent',axe_MAN);
set(axe_MAN,'XLim',axePAR{1},'YLim',axePAR{2},'YDir','normal','Box','On')
hold on

LW = 2;
Cell_Of_COLOR = cwtftboxfun;
if ~isempty(varargin) , first = 2; else first = 1; end
% first = 1;
for k=first:nbBOX
    Sel_Status = Lst_Sel_Box{k}(2);
    switch Sel_Status
        case -1 , idx = 1;
        case  0 , idx = 2;
        case  1 , idx = 3;
    end
    FColor = Cell_Of_COLOR{idx,1}; 
    FAlpha = Cell_Of_COLOR{idx,2}; 
    EdgeColor = Cell_Of_COLOR{idx,3}; 
    SB = line(...
        'Color',EdgeColor,'LineStyle','-','LineWidth',LW, ...
        'XData',XD{k},'YData',YD{k}  ...
        );
    SF = fill(XD{k},YD{k},FColor,...
        'FaceAlpha',FAlpha,'EdgeColor',EdgeColor,'Parent',axe_MAN);
    cwtftbtn('attach',fig,SF,LW);
    Lst_Sel_Box{k}(1) = SB;
    Lst_Sel_Box{k}(3) = SF;
end
wtbxappdata('set',fig,'Sel_Box_CFS',Lst_Sel_Box);
%--------------------------------------------------------------------------
function attach_CtxtMenu(SB,LW)

hcmenu = uicontextmenu('Userdata',SB);
set(SB,'LineWidth',LW,'UIContextMenu',hcmenu)
uimenu(hcmenu,'Label',getWavMSG('Wavelet:cwtfttool:label_Select'),'Callback','cwtftboxfun(1)');
uimenu(hcmenu,'Label',getWavMSG('Wavelet:cwtfttool:label_UnSelect'),'Callback','cwtftboxfun(2)');
uimenu(hcmenu,'Separator','On','Label',getWavMSG('Wavelet:cwtfttool:label_Delete'),'Callback','cwtftboxfun(3)');
%--------------------------------------------------------------------------
function Pop_WAV_PAR_Callback(hObject,eventdata,handles)

cwtftcbpop('defString',hObject,'par')
%--------------------------------------------------------------------------
function Pop_WAV_NAM_Callback(hObject,eventdata,handles)

WNam = get(handles.Pop_WAV_NAM,{'Value','String'});
wname = WNam{2}{WNam{1}};
set(handles.Pop_WAV_PAR,'Visible','off');
switch wname
    case {'morl','morlex','morl0'}
        STR = [num2cell(int2str((1:10)'),2); '**'];
        val = 6; vis = 'on';
    case 'mexh'
        set(handles.Pop_WAV_PAR,'Visible','off');
        val = 1; STR = ' ';
        vis = 'off';
    case 'dog'
        STR = [num2cell(int2str((2:2:10)'),2); '**'];
        val = 1; vis = 'on';
    case 'paul'
        STR = [num2cell(int2str((4:1:10)'),2); '**'];
        val = 1; vis = 'on';
    case 'bump'
     STR = {'[5 0.6]';'[5 1]';'[6 0.5]';'[6 0.8]'; '[6 1]';'[4 1]'; '**'};
     val = 1; vis = 'on';
end
set(handles.Pop_WAV_PAR,'String',STR,'Value',val,'Visible',vis);
%--------------------------------------------------------------------------
function Pus_MAN_REC_Callback(hObject,eventdata,handles)

fig = gcbf;
Lst_Sel_Box = wtbxappdata('get',fig,'Sel_Box_CFS');
if isempty(Lst_Sel_Box) , beep; return; end
TAB = cat(1,Lst_Sel_Box{:});
toKeep = ishandle(TAB(:,1));
Lst_Sel_Box = Lst_Sel_Box(toKeep);
wtbxappdata('set',fig,'Sel_Box_CFS',Lst_Sel_Box);
CWTS = wtbxappdata('get',fig,'CWTStruct');
cfs  = zeros(size(CWTS.cfs));
scales = CWTS.scales;
nbSamp = size(cfs,2);
Edi_SAMP = handles.Edi_SAMP;
dt = str2double(get(Edi_SAMP,'String'));
xval = dt*(0:nbSamp-1);
for k = 1:length(Lst_Sel_Box)
    XY = get(Lst_Sel_Box{k}(1),{'XData','YData'});
    xmin = ceil(min(XY{1})); xmax = round(max(XY{1}));
    ymin = min(XY{2}); ymax = max(XY{2});
    switch Lst_Sel_Box{k}(2)
        case 0
        case 1
            IdxSC  = find(ymin<=scales & scales<=ymax);
            IdxVAL = find(xmin<=xval & xval<=xmax);
            cfs(IdxSC,IdxVAL) = CWTS.cfs(IdxSC,IdxVAL);
        case -1
            IdxSC  = ymin<=scales & scales<=ymax;
            IdxVAL = xmin<=xval & xval<=xmax;
            cfs(IdxSC,IdxVAL) = 0;
    end
end
CWTS.cfs = cfs;
YRec = icwt_SYNTHESIS(handles,CWTS);

ax = handles.Axe_SIG_L;
axS = handles.Axe_SIG_S;
h  = findobj(ax,'Tag','SIG');
hInv = findobj(ax,'Tag','RecMAN');
hInvS = findobj(axS,'Tag','RecMAN');
Y  = get(h,'YData');
if isempty(hInv)
    LW = 1.5;
    xd = get(h,'XData');
    line('XData',xd,'YData',YRec,'Color',[0 0.8 0],'Linewidth',LW,...
        'Tag','RecMAN','Parent',ax);
    line('XData',xd,'YData',YRec,'Color',[0 0.8 0],'Linewidth',LW,...
        'Tag','RecMAN','Parent',axS);     
else
    set([hInv,hInvS],'YData',YRec,'Visible','On')
end
errMAX = max(abs(Y(:)-YRec(:)))/max(abs(Y(:)));
errL2  = norm(Y(:)-YRec(:))/norm(Y(:));
Tab_Synt_Status = wtbxappdata('get',fig,'Tab_Synt_Status');
Tab_Synt_Status(3,2:4) = [1,errMAX,errL2];
wtbxappdata('set',fig,'Tab_Synt_Status',Tab_Synt_Status);
set(handles.CHK_MAN_REC,'Enable','On','Value',1);
YY = [Y,YRec];
set([ax,axS],'Ylim',[min(YY),max(YY)])
showDistances(3,fig);
SavMenOnOff(fig,3,'On')
%--------------------------------------------------------------------------
function SEL_or_UNSEL_or_DEL_BOX(hObject,eventdata,handles,val,usr)

fig = gcbf;
Lst_Sel_Box = wtbxappdata('get',fig,'Sel_Box_CFS');
if isempty(Lst_Sel_Box) , return; end
nbBOX  = length(Lst_Sel_Box);
if nargin<5  % Select all coefficients
    numBOX = 1;
else
    numBOX = cwtftbtn('getbox',fig,usr);
end    
if nbBOX<numBOX , numBOX = nbBOX; end
Sel_Box = Lst_Sel_Box{numBOX}(1);
if ~ishandle(Sel_Box) , return; end
Sel_Status = Lst_Sel_Box{numBOX}(2);
Sel_Fill   = Lst_Sel_Box{numBOX}(3);
switch val
    case {0,'del'}
        Lst_Sel_Box(numBOX) = [];
        wtbxappdata('set',fig,'Sel_Box_CFS',Lst_Sel_Box);
        toDEL = [Sel_Box ,Sel_Fill];
        delete(toDEL(ishandle(toDEL)))
        return;

    otherwise
        if isequal(Sel_Status,val) , return; end
        Cell_Of_COLOR = cwtftboxfun;

        switch val
            case  1 , idx = 3;                
            case -1 , idx = 1;
        end
        FaceColor = Cell_Of_COLOR{idx,1}; FaceAlpha = Cell_Of_COLOR{idx,2};
        EdgeColor = Cell_Of_COLOR{idx,3}; 
end
XD = get(Sel_Box,'XData');
YD = get(Sel_Box,'YData');
axPAR = get(Sel_Box,'Parent');
XYlim = get(axPAR,{'XLim','YLim'});
set(axPAR,'NextPlot','add');
if ~ishandle(Sel_Fill)
    Sel_Fill = fill(XD,YD,FaceColor,'Parent',axPAR);
end
set(Sel_Fill,'FaceColor',FaceColor,'EdgeColor',EdgeColor,...
    'AlphaDataMapping','scaled','FaceAlpha',FaceAlpha)
set(Sel_Box,'Color',EdgeColor);
set(axPAR,'NextPlot','replacechildren');
set(axPAR,'XLim',XYlim{1},'YLim',XYlim{2});
Lst_Sel_Box{numBOX} = [Sel_Box val Sel_Fill];
wtbxappdata('set',fig,'Sel_Box_CFS',Lst_Sel_Box);
set(handles.Pus_MAN_REC,'Enable','on');
%--------------------------------------------------------------------------
function Pus_MAN_DEL_Callback(hObject,eventdata,handles)

fig = gcbf;
Lst_Sel_Box = wtbxappdata('get',fig,'Sel_Box_CFS');
wtbxappdata('set',fig,'Sel_Box_CFS',Lst_Sel_Box(1));
if ~isempty(Lst_Sel_Box)
    TAB = cat(1,Lst_Sel_Box{2:end});
    if ~isempty(TAB)
        TAB = TAB(ishandle(TAB(:,1)),1);
        delete(TAB);
    end
end
R = wfindobj(handles.Axe_MAN_SEL,'Type','patch');
InitBOX = Lst_Sel_Box{1}(3);
R = setdiff(R,InitBOX);
delete(R)
set([handles.Pus_MAN_REC ; handles.Pus_MAN_DEL],'Enable','on');
ax = handles.Axe_SIG_L;
axS = handles.Axe_SIG_S;
hInv = findobj(ax,'Tag','RecMAN');
hInvS = findobj(axS,'Tag','RecMAN');
delete([hInv;hInvS])
set(handles.CHK_MAN_REC,'Value',0,'Enable','Off');

Tab_Synt_Status = wtbxappdata('get',fig,'Tab_Synt_Status');
Tab_Synt_Status(3,2) = 0;
wtbxappdata('set',fig,'Tab_Synt_Status',Tab_Synt_Status);        
showDistances(3,fig)
%--------------------------------------------------------------------------
function Pop_DEF_SCA_Callback(hObject,eventdata,handles)

val = get(hObject,'Value');
old = get(hObject,'Userdata');
set(hObject,'Userdata',val);
switch val
    case 1 , vis = 'off';
    case 2
        vis = 'off';
        AP = wtbxappdata('get',hObject,'Linear_Anal_Params');
        sampSTR = sprintf('%0.2f',AP.sampPer);
        set(handles.Edi_SAMP,'String',sampSTR)
        Edi_SAMP_Callback(handles.Edi_SAMP,eventdata,handles)
    case 3 , vis = 'on';
end
if ~isequal(old,val)
    newpos = false;
    p = get(hObject,'Position');
    if ((old==1 || old==2) && val==3)
        p(3) = p(3)/1.5; newpos = true;
    elseif old==3
        p(3) = 1.5*p(3); newpos = true;
    end
    if newpos , set(hObject,'Position',p); end
end
set(handles.Pus_DEF_MAN,'Visible',vis);
%--------------------------------------------------------------------------
function Pus_DEF_MAN_Callback(hObject,eventdata,handles)

fig = gcbf;
Change_Enabled = wfindobj(fig,'Enable','on');
kept_Enabled = allchild(handles.Pan_DEF_SC);
Change_Enabled = setdiff(Change_Enabled,kept_Enabled);
wtbxappdata('set',fig,'Pus_DEF_MAN_Ena',Change_Enabled);
set(Change_Enabled,'Enable','off');
set([handles.Pus_ANAL;handles.Pan_REC],'Visible','off');
set(handles.Pan_DEF_SC,'Visible','on');
%--------------------------------------------------------------------------
function Pop_SCA_TYPE_Callback(hObject,eventdata,handles)

val = get(hObject,'Value');
group1 = [...
    handles.Txt_SCA_INI;handles.Edi_SCA_INI; ...
    handles.Txt_SCA_SPA;handles.Edi_SCA_SPA; ...
    handles.Txt_SCA_NB; handles.Edi_SCA_NB ...    
    ];
switch val
    case 1  % Type = Power
        HdL_VIS = [group1; handles.Pop_SCA_POW;handles.Pus_DEF_Def];
        HdL_InVIS = [handles.Edi_SCA_MAN];
        
    case 2  % Type = Linear
        HdL_VIS = [group1;handles.Pus_DEF_Def];
        HdL_InVIS = [handles.Pop_SCA_POW;handles.Edi_SCA_MAN];
       
    case 3  % Type = Manual
        HdL_VIS = [handles.Edi_SCA_MAN;handles.Pus_DEF_Def];
        HdL_InVIS = [group1; handles.Pop_SCA_POW];
end
set(HdL_InVIS,'Visible','off');
set(HdL_VIS,'Visible','on');
%--------------------------------------------------------------------------
function Edi_SCA_INI_Callback(hObject,eventdata,handles)
%--------------------------------------------------------------------------
function Edi_SCA_SPA_Callback(hObject,eventdata,handles)
%--------------------------------------------------------------------------
function Edi_SCA_NB_Callback(hObject,eventdata,handles)
%--------------------------------------------------------------------------
function Edi_SCA_MAN_Callback(hObject,eventdata,handles)
%--------------------------------------------------------------------------
function Pop_SCA_POW_Callback(hObject,eventdata,handles)

cwtftcbpop('defString',hObject,'pow')
%--------------------------------------------------------------------------
function Pus_DEF_APPLY_Callback(hObject,eventdata,handles)

fig = gcbf;
AP = wtbxappdata('get',fig,'Pow_Anal_Params');
valType = get(handles.Pop_SCA_TYPE,'value');
switch valType
    case {1,2}   % Type = Power and Type = Linear
        err = 0;
        s0 = str2double(get(handles.Edi_SCA_INI,'String'));
        if isempty(s0) || isnan(s0) || (s0<=1E-9)
            set(handles.Edi_SCA_INI,'String','1');
            err = 1;
        end
        SCA.s0 = s0;
        ds = str2double(get(handles.Edi_SCA_SPA,'String'));
        SCA.ds = ds;
        if isempty(ds) || isnan(ds) || (ds<=1E-9)
            set(handles.Edi_SCA_SPA,'String','2');
            err = 1;
        end
        nb = str2double(get(handles.Edi_SCA_NB,'String'));
        if isempty(nb) || isnan(nb) || (nb<1)
            set(handles.Edi_SCA_NB,'String','16');
            err = 1;
        end
        if err
            beep; return;
        end
        SCA.nb = nb;
        if valType==1
            SCA.type = 'pow';
            Lst = get(handles.Pop_SCA_POW,'String');
            idx = get(handles.Pop_SCA_POW,'value');
            pow = str2double(Lst{idx});
            SCA.pow = pow;
            scales = (SCA.s0) * (SCA.pow).^((0:(SCA.nb)-1)*(SCA.ds));
        else
            SCA.type = 'lin';
            scales = SCA.s0:SCA.ds:SCA.nb;
        end
        set(handles.Pop_METH_SYNT,'Value',valType);
        
    case 3   % Type = Manual
        SCA = [];
        scales = eval(get(handles.Edi_SCA_MAN,'String'));
        ScType = getScType(scales);
        switch ScType
            case 'pow' , set(handles.Pop_METH_SYNT,'Value',1);
            case 'lin' , set(handles.Pop_METH_SYNT,'Value',2);
        end
end
AP.SCA = SCA;
AP.scales = scales;
wtbxappdata('set',fig,'Pow_Anal_Params',AP)

Change_Enabled = wtbxappdata('get',fig,'Pus_DEF_MAN_Ena');
set(handles.Pan_DEF_SC,'Visible','off')
set([handles.Pus_ANAL,handles.Pan_REC],'Visible','on');
set(Change_Enabled,'Enable','on');
%--------------------------------------------------------------------------
function Pus_DEF_CANCEL_Callback(hObject,eventdata,handles)

fig = gcbf;
Change_Enabled = wtbxappdata('get',fig,'Pus_DEF_MAN_Ena');
set(handles.Pan_DEF_SC,'Visible','off')
set([handles.Pus_ANAL,handles.Pan_REC],'Visible','on');
set(Change_Enabled,'Enable','on');
%--------------------------------------------------------------------------
function Pus_DEF_Def_Callback(hObject,eventdata,handles)

Edi_INI = handles.Edi_SCA_INI;
Edi_SPA = handles.Edi_SCA_SPA;
Edi_NBS = handles.Edi_SCA_NB;
TMP = get(handles.Pop_WAV_NAM,{'Value','String'});
wname = TMP{2}{TMP{1}};
TMP = get(handles.Pop_WAV_PAR,{'Value','String'});
param = TMP{2}{TMP{1}};
typeMAN = get(handles.Pop_SCA_TYPE,'Value');
dt  = str2double(get(handles.Edi_SAMP,'String'));
nbSamp = length(wtbxappdata('get',gcbf,'Sig_ANAL'));

switch typeMAN
    case 1  % Power
        [s0,ds,NbSc] = getDefaultAnalParams({wname,param},nbSamp,dt);
        
    case 2  % Linear
        maxsca = dt*fix(5*nbSamp/3);
        s0 = 2*dt; ds = 10*dt; NbSc = length(s0:ds:maxsca);
        
    case 3  % Manual
        s0 = 2*dt; ds = 5*dt;   
        maxsca = dt*nbSamp/2;
        NbSc = length(s0:ds:maxsca);
        maxsca = s0+ds*(NbSc-1);
end
prec_s0 = nbdigit(s0);
prec_ds = nbdigit(ds);
frm_s0_STR = ['%'  '1.' int2str(prec_s0) 'f'];
frm_ds_STR = ['%'  '1.' int2str(prec_ds) 'f'];
s0STR = num2str(s0,frm_s0_STR);
dsSTR = num2str(ds,frm_ds_STR);
if ~isequal(typeMAN,3)
    set(Edi_INI,'String',s0STR)
    set(Edi_SPA,'String',dsSTR)
    set(Edi_NBS,'String',int2str(NbSc))
else
    prec_maxsca = nbdigit(maxsca);
    frm_maxscaSTR = ['%'  '1.' int2str(prec_maxsca) 'f'];
    maxscaSTR = num2str(maxsca,frm_maxscaSTR);
    strDEF = ['[' s0STR ' : ' dsSTR ' : ' maxscaSTR ']'];
    set(handles.Edi_SCA_MAN,'String',strDEF);
end
%----------------------------------
function prec = nbdigit(x)

mul = 0.1;
continu = true;
while continu
    mul = 10*mul;
    d = mul*x - floor(mul*x);
    continu = ~isequal(d,0);
end
prec = log10(mul);
%--------------------------------------------------------------------------
function [s0,ds,NbSc,scales] = getDefaultAnalParams(WAV,nbSamp,dt)

wname = WAV{1};
switch wname
    case {'morl','morlex','morl0'} 
        s0 = 2*dt; ds = 0.4875; NbSc = fix(log2(nbSamp*dt/s0)/ds);
        scales = s0*2.^((0:NbSc-1)*ds);
       
    case {'mexh','dog'}
        s0 = 2*dt; ds = 0.4875; NbSc = fix(log2(nbSamp*dt/s0)/ds);
        scales = s0*2.^((0:NbSc-1)*ds);
        
    case 'paul'
        s0 = 2*dt; ds = 0.4875; NbSc = fix(log2(nbSamp*dt/s0)/ds);
        scales = s0*2.^((0:NbSc-1)*ds);
    
    case 'bump'
        s0 = 2*dt; ds = 1/10; NbSc = fix(log2(nbSamp*dt/s0)/ds);
        scales = s0*2.^((0:NbSc-1)*ds);
        
end
%--------------------------------------------------------------------------
%=========================================================================%
%                END OF UICONTROL CALLBACKS FUNCTIONS                     %
%=========================================================================%

%--------------------------------------------------------------------------
function Pus_HLP_Callback(hObject,eventdata,handles)

tag = 'CWTFT_GUI_HelpBTN';
wfighelp('launch_Help',gcbf,tag);
%--------------------------------------------------------------------------
function save_FUN(hObject,eventdata,handles,option)

switch option
    case 'rec'
        hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
        m_save = hdl_Menus.m_save;
        numSub = get(hObject,'Position');
        Men_SavRecSig_Callback(m_save,eventdata,handles,numSub)
        
    case 'dec'
        Men_SavDEC_Callback([],eventdata,handles)
end
%--------------------------------------------------------------------------
function ScType = getScType(scales)

DF2 = sum(diff(scales,2));
if abs(DF2)<sqrt(eps)
    ScType = 'lin';
else
    B = log(scales/scales(1));
    if abs(B/B(2)-round(B/B(2))) < sqrt(eps)
        ScType = 'pow'; 
    else
        ScType = 'man'; 
    end
end
%--------------------------------------------------------------------------
function showDistances(option,fig)

handles = guihandles(fig);
%------------------------------------
Txt_AM = handles.Txt_Xlab_AM;
pos = get(Txt_AM,'Position');
pos = cat(1,pos{:}); pos = pos(:,2);
[~,IdxM] = sort(pos,'descend');
set(Txt_AM,'String','');
%------------------------------------
Txt_AL = handles.Txt_Xlab_AL;
pos = get(Txt_AL,'Position');
pos = cat(1,pos{:}); pos = pos(:,2);
[~,IdxL] = sort(pos,'descend');
set(Txt_AL,'String','');
%-------------------------------------

ax  = handles.Axe_SIG_L;
axS = handles.Axe_SIG_S;
Tab_Synt_Status = wtbxappdata('get',fig,'Tab_Synt_Status');
nb = 0;
LabSTR = '';
if option>0
    FGColor = {[0 0 1] , [200 0 200]/255 , [0 127 0]/255};
    for j = 1:3
        if Tab_Synt_Status(j,2)~=0
            nb = nb+1;
            errMAX = 100*Tab_Synt_Status(j,3);
            errL2  = 100*Tab_Synt_Status(j,4);
            V1 = [sprintf('%3.2f',errMAX) '%'];
            V2 = [sprintf('%3.2f',errL2) '%'];
            switch j
                case 1
                    Msg_Id = 'Wavelet:cwtfttool:RelErrFromInitialScales';
                case 2
                    Msg_Id = 'Wavelet:cwtfttool:RelErrFromListOfScales';
                case 3
                    Msg_Id = 'Wavelet:cwtfttool:RelErrFromManualSelection';
            end
            SS = getWavMSG(Msg_Id,V1,V2);

            if isempty(LabSTR)
                LabSTR = SS;
            else
                LabSTR = char(LabSTR,SS);
            end
            numM = IdxM(nb);
            numL = IdxL(nb);
            set([Txt_AM(numM);Txt_AL(numL)],...
                'HorizontalAlignment','Left',...
                'String',SS,'ForegroundColor',FGColor{j});
        end
    end
end
set_TITLES(ax,axS,nb)
%--------------------------------------------------------------------------
function set_TITLES(ax,axS,nb)

if nb>0,
    titleSTR = getWavMSG('Wavelet:cwtfttool:title_AnalyzedAndSynthesizedSignals');
else
    titleSTR = getWavMSG('Wavelet:cwtfttool:title_AnalyzedSignal');    
end
wtitle(titleSTR,'Parent',ax);
wtitle(titleSTR,'Parent',axS);
%--------------------------------------------------------------------------
function Y = icwt_SYNTHESIS(handles,CWTS)

num_METH = get(handles.Pop_METH_SYNT,'Value');
switch num_METH
    case 1 , Y = icwtft(CWTS);
    case 2 , Y = icwtlin(CWTS);
end
%--------------------------------------------------------------------------
