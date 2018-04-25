function varargout = showpartperf(varargin)
% SHOWPARTPERF MATLAB file for showpartperf.fig

% Last Modified by GUIDE v2.5 16-Feb-2006 10:43:02
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Jan-2006.
%   Last Revision 11-Jul-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $ $Date: 2013/08/23 23:45:55 $ 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @showpartperf_OpeningFcn, ...
                   'gui_OutputFcn',  @showpartperf_OutputFcn, ...
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
% End initialization code - DO NOT EDIT

%--------------------------------------------------------------------------
function showpartperf_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for showpartperf
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION %
%%!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles,varargin{:})
%--------------------------------------------------------------------------
function varargout = showpartperf_OutputFcn(~,~,handles) 
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;
%--------------------------------------------------------------------------
function Pus_Close_Callback(~,~,handles) %#ok<*DEFNU>

fig = handles.output;
callingFIG = wtbxappdata('get',fig,'callingFIG');
if ishandle(callingFIG)
    showparttool('Pus_PART_PERF_Callback',fig,[],handles)
else
    delete(fig);
end
%--------------------------------------------------------------------------
function Pop_INDICES_Callback(hObject,eventdata,handles)

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
numIDX = get(hObject,'Value');
Tab_idxID = get(hObject,'String');
idxID = Tab_idxID{numIDX};
if isequal(idxID(1),'-')
    usr = get(hObject,'UserData');
    set(hObject,'Value',usr);
    return
end
set(hObject,'UserData',numIDX);
names = get(hObject,'String');
idxNAME = names{numIDX};
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
formatNUM = '%9.3f';
fig = handles.output;
callingFIG = wtbxappdata('get',fig,'callingFIG');
TAB_Partitions = wtbxappdata('get',callingFIG,'TAB_Partitions');
signals = blockdatamngr('get',callingFIG,'data_SEL','sel_DAT');
nbPART = length(TAB_Partitions);
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++
nbCLU = wtbxappdata('get',fig,'nbCLU');
NbCLU_MAX = max(nbCLU);
switch idxID
    case {'stdQ1','stdQ2','glbSTD'}
        usr = wtbxappdata('get',callingFIG,'Std_Quality');
        if isempty(usr)
            [stdQ1,stdQ2,glbSTD] = partstdqual(TAB_Partitions,signals);
            wtbxappdata('set',callingFIG,'Std_Quality',{stdQ1,stdQ2,glbSTD});
        else
            [stdQ1,stdQ2,glbSTD] = deal(usr{:});
        end
        switch idxID
            case 'stdQ1'  , tabIDX = stdQ1;
            case 'stdQ2'  , tabIDX = stdQ2;    
            case 'glbSTD' , tabIDX = glbSTD;
        end
        flagONE = false;
        
    case {'Inter/Intra','Inter/Intra (N)','logINTRA','logINTER'}
        usr = wtbxappdata('get',callingFIG,'BetweenWithin');
        if isempty(usr)
            [inter_SUR_intra,inter_SUR_intra_N,inter,intra] = ...
                partbetweenwithin(signals,TAB_Partitions);
            wtbxappdata('set',callingFIG,'BetweenWithin', ...
                {inter_SUR_intra,inter_SUR_intra_N,inter,intra});
        else
            [inter_SUR_intra,inter_SUR_intra_N,inter,intra] = deal(usr{:});
        end
        switch idxID
            case 'Inter/Intra'     , tabIDX = inter_SUR_intra;
            case 'Inter/Intra (N)' , tabIDX = inter_SUR_intra_N;
            case 'logINTRA'        , tabIDX = log10(intra);
            case 'logINTER'        , tabIDX = log10(inter);
        end
        flagONE = true;
        
    case {'MEAN Silh','MIN Silh','MAX Silh','STD Silh','PART Silh'}
        silh_VALUES = wtbxappdata('get',callingFIG,'silh_VALUES');
        if isempty(silh_VALUES)
            h = waitbar(50,getWavMSG('Wavelet:moreMSGRF:Please_wait'));
            [silh_VAL,silh_PART] = partsilh(signals,TAB_Partitions);
            silh_VALUES = {silh_VAL,silh_PART};
            wtbxappdata('set',callingFIG,'silh_VALUES',silh_VALUES);
            close(h)
        end
        if ~isequal(idxID,'PART Silh')
            silh_VAL = silh_VALUES{1};
            switch idxID
                case 'MEAN Silh' , idxK = 1;
                case 'MIN Silh'  , idxK = 2;
                case 'MAX Silh'  , idxK = 3;
                case 'STD Silh'  , idxK = 4;
            end
            for j = 1:length(silh_VAL), silh_VAL{j} = silh_VAL{j}(idxK,:);end
            tabIDX = silh_VAL;
            flagONE = false;
        else
            tabIDX  = silh_VALUES{2};
            flagONE = true;        
        end
end
set(handles.Pan_GRA_SIM,'Title',['   ' idxNAME '   .'])
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
val_DISP = get(handles.Pop_FRM_DISP,'Value');
switch val_DISP
    case 1    , vis_IDX = 'On';
    otherwise , vis_IDX = 'Off';
end
txt_HDL = wtbxappdata('get',fig,'txt_HDL');
[txt_IDX,txt_C,~,txt_VIS,txt_NotVIS,...
    txt_LIN_V,txt_LIN_H] = deal(txt_HDL{:});
if iscell(tabIDX)    
    for j=1:nbPART
        for k=1:nbCLU(j)
            strTXT = num2str(tabIDX{j}(k),formatNUM);
            set(txt_IDX(j,k),'String',strTXT);
        end
    end
else
    for j=1:nbPART
        strTXT = num2str(tabIDX(j),formatNUM);
        set(txt_IDX(j,:),'String',strTXT);
    end    
end
hdl_CHANGE = [txt_C(:);txt_LIN_V(:);txt_LIN_H(:)];
if flagONE
    hdl_TMP   = txt_IDX(:,2:end);
    HDL_inVIS = [hdl_TMP(:);hdl_CHANGE];
    HDL_inVIS = HDL_inVIS(ishandle(HDL_inVIS));    
    set(HDL_inVIS,'Visible','Off');
else
    HDL_VIS = [txt_VIS(:);hdl_CHANGE];
    set(txt_NotVIS,'Visible','Off');
    HDL_VIS = HDL_VIS(ishandle(HDL_VIS));
    set(HDL_VIS,'Visible',vis_IDX);
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if iscell(tabIDX)
    strTXT = [];
    sepCOL = repmat(' | ',NbCLU_MAX,1);
    for j=1:nbPART
        maxVAL = max(abs(tabIDX{j}));
        nbdigit = max([round(log10(maxVAL)),0]) + 6;
        formatNUM = ['% ' int2str(nbdigit) '.3f'];
        srtTMP_P = [];
        for k=1:nbCLU(j)
            strTMP = sprintf(formatNUM,tabIDX{j}(k));
            srtTMP_P = [srtTMP_P ; strTMP]; %#ok<*AGROW>
        end
        L = size(srtTMP_P,2);
        for k = nbCLU(j)+1:NbCLU_MAX
            srtTMP_P = [srtTMP_P ; blanks(L)];
        end
        if j>1 , strTXT = [strTXT , sepCOL]; end
        strTXT = [strTXT , srtTMP_P];
    end
    sepCOL = repmat('|',NbCLU_MAX,1);
    strTXT = [sepCOL , strTXT sepCOL];
else
    formatNUM = '%9.3f';
    strTXT = num2str(tabIDX,formatNUM);
end
L1  = size(strTXT,2);
sep = '-'; 
sep = sep(:,ones(1,L1));
strTXT = [blanks(L1) ; blanks(L1) ; sep ; strTXT ; sep];
set(handles.Txt_SIM_VAL,'String',strTXT)
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if ~flagONE
    tabIDX_TMP = NaN(nbPART,NbCLU_MAX);
    for j=1:nbPART
        if iscell(tabIDX)
            tabIDX_TMP(j,1:nbCLU(j)) = tabIDX{j}; 
        else
            tabIDX_TMP(j,1:nbCLU(j)) = tabIDX; 
        end
    end
    tabIDX = tabIDX_TMP;
else
    tabIDX = tabIDX';
    tabIDX = tabIDX(:,ones(1,NbCLU_MAX));
    for j=1:nbPART , tabIDX(j,nbCLU(j)+1:end) = NaN; end   
end
ymax = max(max(tabIDX));
ymin = min(min(tabIDX));
ymax = ymax + 0.01*abs(ymax);
ymin = ymin - 0.01*abs(ymin);
axeCUR = handles.Axe_GRAPHIC;
visAXE = get(axeCUR,'Visible');
Leg_lin_IDX = wtbxappdata('get',fig,'Leg_lin_IDX');
if isempty(Leg_lin_IDX)
    delete(allchild(axeCUR))
    set(axeCUR,'NextPlot','Add')
    map = hsv(64);
    lin_IDX = zeros(1,nbPART);
    for j=1:nbPART
        col_LIN = map(j,:);
        lin_IDX(j) = plot(1:NbCLU_MAX,tabIDX(j,:),'Color',col_LIN,...
            'LineWidth',2,'Marker','s','MarkerSize',8,...
            'MarkerFaceColor',col_LIN, ...
            'Visible',visAXE,'Parent',axeCUR);
    end
    xlab = 'C';
    xlab = [xlab(ones(1,NbCLU_MAX),:), int2str((1:NbCLU_MAX)')];
    set(axeCUR,...
        'XTick',(1:NbCLU_MAX),'XTickLabel',xlab,...
        'XLim',[1 NbCLU_MAX],'YLim',[ymin ymax]);
    legendSTR = get(handles.Pop_HIG_PART,'String');
    Leg_HDL = legend(axeCUR,legendSTR{2:end},...
        'Location','EastOutside','AutoUpdate','off');
    wtbxappdata('set',fig,'Leg_lin_IDX',{lin_IDX,Leg_HDL});
else
    [lin_IDX,Leg_HDL] = deal(Leg_lin_IDX{:});
    for j=1:nbPART , set(lin_IDX(j),'YData',tabIDX(j,:)); end
    set(axeCUR,'XLim',[1 NbCLU_MAX],'YLim',[ymin ymax]);
end
set(Leg_HDL,'Visible',visAXE);
val = get(handles.Pop_SEL_PART,'Value')-1;
set_Title(handles,val)
Chk_GRID_Callback(handles.Chk_GRID,eventdata,handles)
%--------------------------------------------------------------------------
function Pop_FRM_DISP_Callback(hObject,eventdata,handles)

val = get(hObject,'Value');
usr = get(hObject,'UserData');
if isequal(val,usr) , return; end
set(hObject,'UserData',val);

fig = get(hObject,'Parent');
posLocFig = wtbxappdata('get',fig,'posLocFig');
hdl_IN_TXT = findobj(handles.Axe_INDICES);
stored  = wtbxappdata('get',fig,'Leg_lin_IDX');
if ~isempty(stored) , Leg_HDL = stored{2}; else Leg_HDL = []; end
hdl_IN_GRA = [findobj(handles.Axe_GRAPHIC);Leg_HDL; handles.Pan_GRA];

switch val
    case 1 % Table
        if ~isequal(posLocFig{2},0) , set(fig,'Position',posLocFig{1}); end
        txt_HDL = wtbxappdata('get',fig,'txt_HDL');
        txt_NotVIS = txt_HDL{5};
        set(handles.Txt_SIM_VAL,'Visible','Off')
        set(hdl_IN_GRA,'Visible','Off')
        set(hdl_IN_TXT,'Visible','On')
        set([handles.Axe_INDICES,txt_NotVIS],'Visible','Off')

    case 2 % Graphic
        if ~isequal(posLocFig{2},0) , set(fig,'Position',posLocFig{1}); end
        set(handles.Pop_SEL_PART,'Value',1);
        set(handles.Pop_HIG_PART,'Value',1);
        set([hdl_IN_TXT(:)',handles.Txt_SIM_VAL],'Visible','Off')
        set_Title(handles,0)
        set(hdl_IN_GRA,'Visible','On')
        Pop_COL_MAP_Callback(handles.Pop_COL_MAP,eventdata,handles)
        
    case 3 % Text
        set(hdl_IN_GRA,'Visible','Off')
        set(hdl_IN_TXT,'Visible','Off')
        pos = [0 0 1 1];
        set(handles.Txt_SIM_VAL,'Position',pos,'Visible','On')
        ext = get(handles.Txt_SIM_VAL,'Extent');
        if ext(3)>1
            if isequal(posLocFig{2},0)
                pos = get(fig,'Position');
                pos(3) = 1.2*pos(3)*ext(3);
                posLocFig{2} = pos;
                wtbxappdata('set',fig,'posLocFig',posLocFig);
            end
            set(fig,'Position',posLocFig{2});
        end
end
%--------------------------------------------------------------------------
function Pus_ALL_Callback(~,~,handles)

fig = handles.output;
showparttxt(fig,'PERF');
%--------------------------------------------------------------------------
function Chk_GRID_Callback(hObject,~,handles)

val = get(hObject,'Value');
switch val,
    case 0 , vis = 'Off';
    case 1 , vis = 'On';
end
set(handles.Axe_GRAPHIC,'XGrid',vis,'YGrid',vis);
%--------------------------------------------------------------------------
function Pop_COL_MAP_Callback(hObject,~,handles)

stored = wtbxappdata('get',hObject,'Leg_lin_IDX');
lin_IDX = stored{1};
nb_LIN  = length(lin_IDX);
val = get(hObject,'Value');
if val>1
    lst = get(hObject,'String');
    mapName = lst{val};
    map = feval(mapName,255);
    map = map(10:10:end,:);
else
    map = getscaledmap(get(lin_IDX(1),'Parent'),nb_LIN);
end
for j=1:length(lin_IDX)
    col_LIN = map(j,:);
    set(lin_IDX(j),'Color',col_LIN,'MarkerFaceColor',col_LIN);
end
usr = get(handles.Pop_HIG_PART,'UserData');
if ~isempty(usr)
    col_SEL = get(usr{1},'Color');
    set(usr{1},'Color','k','MarkerFaceColor','k');
    set(handles.Pop_HIG_PART,'UserData',{usr{1},col_SEL,col_SEL});
end
%--------------------------------------------------------------------------
function Pop_SEL_PART_Callback(hObject,~,handles)

val = get(hObject,'Value')-1;
stored = wtbxappdata('get',hObject,'Leg_lin_IDX');
lin_IDX = stored{1};
leg_HDL = stored{2};
if val==0
    set(lin_IDX,'Visible','On');
    set(leg_HDL,'Visible','On')
    val = get(handles.Pop_HIG_PART,'Value')-1;
else
    set(lin_IDX,'Visible','Off');
    set(lin_IDX(val),'Visible','On'); 
end
set_Title(handles,val);
%--------------------------------------------------------------------------
function Pop_HIG_PART_Callback(hObject,~,handles)

val = get(hObject,'Value')-1;
stored = wtbxappdata('get',hObject,'Leg_lin_IDX');
lin_IDX = stored{1};
set(lin_IDX,'LineWidth',2);
usr = get(hObject,'UserData');
if ~isempty(usr)
    try set(usr{1},'Color',usr{2},'MarkerFaceColor',usr{3}); end %#ok<*TRYNC>
end
if get(handles.Pop_SEL_PART,'Value')==1 , set_Title(handles,val); end
if val~=0
    lin_SEL = lin_IDX(val);
    col_SEL = get(lin_SEL,'Color');
    col_MAR = get(lin_SEL,'MarkerFaceColor');
    set(hObject,'UserData',{lin_SEL,col_SEL,col_MAR});
    for k=1:4
        set(lin_SEL,'LineWidth',2,...
            'Color',col_SEL,'MarkerFaceColor',col_MAR);
        pause(0.2)
        set(lin_SEL,'LineWidth',3,'Color','k','MarkerFaceColor','k');
        pause(0.3)
    end
end
%--------------------------------------------------------------------------
function Init_Tool(fig,eventdata,handles,varargin)

wtranslate(mfilename,fig)
callingFIG = gcbf;
wtbxappdata('set',fig,'callingFIG',callingFIG);
pus_SHOW   = varargin{1};
posCaller  = get(callingFIG,'Position');
posLocFig  = get(fig,'Position');
posLocFig(1) = posCaller(1) + 0.025;
posLocFig(2) = posCaller(2)+(posCaller(4) - posLocFig(4))/2;
set(fig,'Position',posLocFig,'UserData',pus_SHOW);

sep = '-------------------';
Tab_idxID  = {...
    'stdQ1','Inter/Intra (N)','MEAN Silh',sep,...
    'stdQ2','glbSTD',sep,            ...
    'Inter/Intra','logINTRA','logINTER',sep  ...
    'MIN Silh','MAX Silh','STD Silh','PART Silh' ...
    };
set(handles.Pop_INDICES,'String',Tab_idxID,'Value',1);
TAB_Partitions = wtbxappdata('get',callingFIG,'TAB_Partitions');
nbPART = length(TAB_Partitions);

num_STR = int2str((1:nbPART)');
Items = 'P';
Items = [Items(ones(nbPART,1),:) num_STR];
Items = num2cell(Items,2);
Items = [getWavMSG('Wavelet:commongui:Str_All') ; Items];
set(handles.Pop_SEL_PART,'String',Items,'Value',1);
Items{1} = 'None';
set(handles.Pop_HIG_PART,'String',Items,'Value',1);

NbCLU_MAX = 0;
nbCLU = zeros(1,nbPART);
for k = 1:nbPART
    nbCLU(k) = TAB_Partitions(k).NbCLU;
    if nbCLU(k)>NbCLU_MAX , NbCLU_MAX = nbCLU(k); end
end
strPOP = get(handles.Pop_FRM_DISP,'String');
set(handles.Pop_FRM_DISP,'String',strPOP);

axeCUR = handles.Axe_INDICES;
xlim = [1,nbPART];
if nbPART<2 , xlim = xlim + [-0.5 0.5]; end
set(axeCUR,...
    'XLim',xlim,'YLim',[1,NbCLU_MAX],   ...
    'XTick',(1:nbPART),'YTick',(1:NbCLU_MAX), ...
    'XTickLabel','','YTickLabel','','Visible','Off');
cba_TEXT = '';
propTEXT = {...
    'Parent',axeCUR,...
    'Color','k','FontSize',8,'FontWeight','bold',...
    'HorizontalAlignment','Center','ButtonDownFcn',cba_TEXT ...
    };
oldUnits = get(axeCUR,'Units');
set(axeCUR,'Units','Pixels')
pos = get(axeCUR,'Position');
pixX  = (nbPART-1)/pos(3);
pixY  = (NbCLU_MAX-1)/pos(4);
set(axeCUR,'Units',oldUnits)
xINI = 1-50*pixX;
yINI = 1-40*pixY;
pTXT_NUM = [propTEXT , 'EdgeColor','k','BackgroundColor',[1 1 0.7]];
txt_C = zeros(1,NbCLU_MAX);
for j=1:NbCLU_MAX
    txt_C(j) = text(xINI,j,[' C' int2str(j)],pTXT_NUM{:});
end
txt_P = zeros(1,nbPART);
for j=1:nbPART
    txt_P(j) = text(j,yINI,[' P' int2str(j)],pTXT_NUM{:});
end
pTXT_V = [propTEXT , {'EdgeColor','r','BackgroundColor',[1 0.8 1]}];
txt_IDX = zeros(nbPART,NbCLU_MAX);

Col_LIN_V = [0.6 0.6 1];
Col_LIN_H = [1 0.6 0.6];
LW = 2;
txt_LIN_V = zeros(1,nbPART);
for j=1:nbPART
    txt_LIN_V(j) = line('XData',[j,j],'YData',[1,NbCLU_MAX],...
        'LineWidth',LW,'Color',Col_LIN_V,'Parent',axeCUR);
end
txt_LIN_H = zeros(1,NbCLU_MAX);
if nbPART>1
    for j=1:NbCLU_MAX
        txt_LIN_H(j) = line('YData',[j,j],'XData',[1,nbPART],...
            'LineWidth',LW,'LineStyle',':','Color',Col_LIN_H, ...
            'Parent',axeCUR);
    end
end
for j=1:nbPART
    for k=1:NbCLU_MAX
        txt_IDX(j,k) = text(j,k,'      ',pTXT_V{:});
    end
end
txt_VIS = [];
for j =1:nbPART
    txt_VIS = [txt_VIS , txt_IDX(j,1:nbCLU(j))];
    set(txt_IDX(j,1:nbCLU(j)),'Visible','On');
    if nbCLU(j)<NbCLU_MAX
        set(txt_IDX(j,1+nbCLU(j):NbCLU_MAX),'Visible','Off');
    end
end
txt_NotVIS = setdiff(txt_IDX(:)',txt_VIS);
wtbxappdata('set',fig,'txt_HDL',...
    {txt_IDX,txt_C,txt_P,txt_VIS,txt_NotVIS,txt_LIN_V,txt_LIN_H});
wtbxappdata('set',fig,'posLocFig',{posLocFig,0});
wtbxappdata('set',fig,'nbCLU',nbCLU);

%%% BUG VISIBLE
set(gca,'YLim',[0.99 , NbCLU_MAX+0.01])
Pop_INDICES_Callback(handles.Pop_INDICES,eventdata,handles);
%--------------------------------------------------------------------------
function set_Title(handles,val)

valIDX = get(handles.Pop_INDICES,'Value');
strIDX = get(handles.Pop_INDICES,'String');
nameIDX = strIDX{valIDX};
if val>0
    strTITLE = getWavMSG('Wavelet:mdw1dRF:ShowOnePart',val,nameIDX);
else
    strTITLE = getWavMSG('Wavelet:mdw1dRF:ShowAllParts',nameIDX);
end
title(strTITLE ,'Parent',handles.Axe_GRAPHIC, ...
    'FontSize',10,'FontWeight','bold');
%--------------------------------------------------------------------------
