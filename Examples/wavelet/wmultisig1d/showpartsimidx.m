function varargout = showpartsimidx(varargin)
% SHOWPARTSIMIDX MATLAB file for showpartsimidx.fig

% Last Modified by GUIDE v2.5 16-Feb-2006 08:56:22
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Jan-2006.
%   Last Revision 11-Jul-2013.
%   Copyright 1995-2013 The MathWorks, Inc.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @showpartsimidx_OpeningFcn, ...
                   'gui_OutputFcn',  @showpartsimidx_OutputFcn, ...
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

% --- Executes just before showpartsimidx is made visible.
function showpartsimidx_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for showpartsimidx
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION %
%%!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles,varargin{:})

% --- Outputs from this function are returned to the command line.
function varargout = showpartsimidx_OutputFcn(hObject,eventdata,handles)  %#ok<*INUSL>
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;
%--------------------------------------------------------------------------
function Pus_Close_Callback(hObject,eventdata,handles) %#ok<*DEFNU>

fig = handles.output;
callingFIG = wtbxappdata('get',fig,'callingFIG');
if ishandle(callingFIG)
    showparttool('Pus_ALL_IDX_Callback',fig,[],handles)
else
    delete(fig);
end
%--------------------------------------------------------------------------
function Pop_INDICES_Callback(hObject,eventdata,handles)

fig = handles.output;
formatNUM = '%9.3f';
numIDX = get(hObject,'Value');
callingFIG = wtbxappdata('get',fig,'callingFIG');
if ishandle(callingFIG)
    figBUFFER = callingFIG;
else
    figBUFFER = fig;
end
LNK_SIM_STRUCT = wtbxappdata('get',figBUFFER,'LNK_SIM_STRUCT');
idx_Names = fieldnames(LNK_SIM_STRUCT);
idx_Names(1) = [];
fn = idx_Names{numIDX};
tabIDX = LNK_SIM_STRUCT.(fn);
% set(handles.Edi_TIT_GRA_SIM,'String',[fn ' Index']);
set(handles.Pan_GRA_SIM,'Title',['   ' fn ' Index   .']);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
txt_HDL = wtbxappdata('get',fig,'txt_HDL');
txt_IDX = txt_HDL{1};
nbPART = size(tabIDX,1);
for j=1:nbPART
    for k=1:nbPART
        strTXT = num2str(tabIDX(j,k),formatNUM);
        set(txt_IDX(j,k),'String',strTXT);
    end
end
set(handles.Axe_INDICES,'YLim',[1-0.01,nbPART+0.01])
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
        lin_IDX(j) = plot(1:nbPART,tabIDX(j,:),'Color',col_LIN,...
            'LineWidth',2,'Marker','s','MarkerSize',8,...
            'MarkerFaceColor',col_LIN, ...
            'Visible',visAXE,'Parent',axeCUR);
    end
    xlab = 'P';
    xlab = [xlab(ones(1,nbPART),:), int2str((1:nbPART)')];
    set(axeCUR,...
        'XTick',(1:nbPART),'XTickLabel',xlab,...
        'XLim',[1 nbPART],'YLim',[ymin ymax]);
    legendSTR = get(handles.Pop_SEL_PART,'String');
    Leg_HDL = legend(axeCUR,legendSTR{2:end},'Location','EastOutside','AutoUpdate','off');
    wtbxappdata('set',fig,'Leg_lin_IDX',{lin_IDX,Leg_HDL});
else
    [lin_IDX,Leg_HDL] = deal(Leg_lin_IDX{:});
    for j=1:nbPART , set(lin_IDX(j),'YData',tabIDX(j,:)); end
    set(axeCUR,'XLim',[1 nbPART],'YLim',[ymin ymax]);
end
set(Leg_HDL,'Visible',visAXE);
val = get(handles.Pop_SEL_PART,'Value')-1;
set_Title(handles,val)
Chk_GRID_Callback(handles.Chk_GRID,eventdata,handles)
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
strTXT = num2str(tabIDX,formatNUM);
L1  = size(strTXT,2);
sep = '-'; sep = sep(:,ones(1,L1));
strTXT = [blanks(L1);blanks(L1);sep;strTXT;sep];
set(handles.Txt_SIM_VAL,'String',strTXT)
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
Leg_HDL = stored{2};
hdl_IN_GRA = [findobj(handles.Axe_GRAPHIC);Leg_HDL; handles.Pan_GRA];
switch val
    case {1,2,3}
        txt_HDL = wtbxappdata('get',fig,'txt_HDL');
        txt_IDX = txt_HDL{1};
        nbPART  = size(txt_IDX,1);
        switch val
            case 1
                txt_VIS = txt_IDX(:)'; txt_InVIS = [];
            
            case 2
                txt_InVIS = [];
                for k = 1:nbPART , 
                    txt_InVIS = [txt_InVIS , txt_IDX(k+1:end,k)']; %#ok<*AGROW>
                end
                txt_VIS = setdiff(txt_IDX(:)' , txt_InVIS);
            
            case 3
                txt_InVIS = [];
                for k = 1:nbPART , 
                    txt_InVIS = [txt_InVIS , txt_IDX(k,k+1:end)];
                end
                txt_VIS = setdiff(txt_IDX(:)' , txt_InVIS);
        end
        txt_HDL{2} = txt_VIS;
        txt_HDL{3} = txt_InVIS;
        wtbxappdata('set',fig,'txt_HDL',txt_HDL);        
        if ~isequal(posLocFig{2},0) , set(fig,'Position',posLocFig{1}); end
        set(hdl_IN_TXT,'Visible','On')
        hdl_NotVIS = [...
            handles.Txt_SIM_VAL,handles.Axe_INDICES, ...
            txt_InVIS,hdl_IN_GRA(:)'];
        set(hdl_NotVIS,'Visible','Off')
        
    case 4
        if ~isequal(posLocFig{2},0) , set(fig,'Position',posLocFig{1}); end
        set(handles.Pop_SEL_PART,'Value',1);
        set(handles.Pop_HIG_PART,'Value',1);
        set([hdl_IN_TXT(:)',handles.Txt_SIM_VAL],'Visible','Off')
        set_Title(handles,0)
        set(hdl_IN_GRA,'Visible','On')
        Pop_COL_MAP_Callback(handles.Pop_COL_MAP,eventdata,handles)

    case 5
        set([hdl_IN_TXT(:)',hdl_IN_GRA(:)'],'Visible','Off')
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
function Pus_ALL_Callback(hObject,eventdata,handles)

fig = handles.output;
showparttxt(fig,'IDX');
%--------------------------------------------------------------------------
function Chk_GRID_Callback(hObject,eventdata,handles)

val = get(hObject,'Value');
switch val,
    case 0 , vis = 'Off';
    case 1 , vis = 'On';
end
set(handles.Axe_GRAPHIC,'XGrid',vis,'YGrid',vis);
%--------------------------------------------------------------------------
function Pop_SEL_PART_Callback(hObject,eventdata,handles)

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
function Pop_HIG_PART_Callback(hObject,eventdata,handles)

val = get(hObject,'Value')-1;
stored = wtbxappdata('get',hObject,'Leg_lin_IDX');
lin_IDX = stored{1};
set(lin_IDX,'LineWidth',2);
usr = get(hObject,'UserData');
if ~isempty(usr)
    try set(usr{1},'Color',usr{2},'MarkerFaceColor',usr{3}); end %#ok<TRYNC>
end
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
if get(handles.Pop_SEL_PART,'Value')==1 , set_Title(handles,val); end
%--------------------------------------------------------------------------
function Pop_COL_MAP_Callback(hObject,eventdata,handles)

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
function Init_Tool(fig,eventdata,handles,varargin)

wtranslate(mfilename,fig)
posLocFig  = get(fig,'Position');
if ishandle(varargin{1})
    pus_SHOW   = varargin{1};
    callingFIG = gcbf;
    wtbxappdata('set',fig,'callingFIG',callingFIG);
    posCaller  = get(callingFIG,'Position');
    posLocFig(1) = posCaller(1) + 0.025;
    posLocFig(2) = posCaller(2)+(posCaller(4) - posLocFig(4))/2;
    set(fig,'Position',posLocFig,'UserData',pus_SHOW);
    TAB_Partitions = wtbxappdata('get',callingFIG,'TAB_Partitions');
    nbPART = length(TAB_Partitions);
else
    opt = varargin{1};
    switch opt
        case 'part'
            [~,LNK_SIM_STRUCT] = partlnkandsim(varargin{2});
        case 'sim'
            LNK_SIM_STRUCT = varargin{2};
    end
    nbPART = size(LNK_SIM_STRUCT.Rand,2);
    wtbxappdata('set',fig,'LNK_SIM_STRUCT',LNK_SIM_STRUCT);
end

idx_Attrb = tplnksim;
idx_Names = idx_Attrb(:,1);
set(handles.Pop_INDICES,'String',idx_Names,'Value',1);
num_STR = int2str((1:nbPART)');
Items = 'P';
Items = [Items(ones(nbPART,1),:) num_STR];
Items = num2cell(Items,2);
Items = [getWavMSG('Wavelet:commongui:Str_All') ; Items];
set(handles.Pop_SEL_PART,'String',Items,'Value',1);
Items{1} = 'None';
set(handles.Pop_HIG_PART,'String',Items,'Value',1);

tickLAB = ' ';
tickLAB = tickLAB(ones(nbPART,1),:);
axeCUR = handles.Axe_INDICES;
set(axeCUR,...
    'XLim',[1,nbPART],'YLim',[1,nbPART],   ...
    'XTick',(1:nbPART),'YTick',(1:nbPART), ...
    'XTickLabel',tickLAB,'YTickLabel',tickLAB,'Visible','Off');
cba_TEXT = '';
propTEXT = {...
    'Parent',axeCUR,'Color','k',...
    'FontSize',8,'FontWeight','bold',...
    'HorizontalAlignment','Center','ButtonDownFcn',cba_TEXT ...
    };
oldUnits = get(axeCUR,'Units');
set(axeCUR,'Units','Pixels')
pos = get(axeCUR,'Position');
pixXY = (nbPART-1)./ pos(3:4);
set(axeCUR,'Units',oldUnits)
xINI = 1-50*pixXY(1);
yINI = 1-50*pixXY(2);
pTXT_NUM = [propTEXT , 'EdgeColor','k','BackgroundColor',[1 1 0.7]];
for j=1:nbPART
    text(xINI,j,[' P' int2str(j)],pTXT_NUM{:});
    text(j,yINI,[' P' int2str(j)],pTXT_NUM{:});
end
pTXT_V = [propTEXT , 'EdgeColor','r','BackgroundColor',[1 0.8 1]];
pTXT_D = [propTEXT , 'EdgeColor','b','BackgroundColor',[0.8 0.8 1]];
txt_IDX = zeros(nbPART,nbPART);
Col_LIN_V = [0.6 0.6 1];
Col_LIN_H = [1 0.6 0.6];
LW = 2;
txt_LIN_V = zeros(1,nbPART);
txt_LIN_H = zeros(1,nbPART);
for j=1:nbPART
    txt_LIN_V(j) = line('XData',[j,j],'YData',[1,nbPART],...
        'LineWidth',LW,'Color',Col_LIN_V,'Parent',axeCUR);
    txt_LIN_H(j) = line('YData',[j,j],'XData',[1,nbPART],...
        'LineWidth',LW,'Color',Col_LIN_H,'Parent',axeCUR);
end
for j=1:nbPART
    for k=1:nbPART
        if j~=k
            txt_IDX(j,k) = text(j,k,'      ',pTXT_V{:});
        else
            txt_IDX(j,k) = text(j,k,'      ',pTXT_D{:});
        end
    end
end
wtbxappdata('set',fig,'txt_HDL',{txt_IDX,txt_IDX,[],txt_LIN_V,txt_LIN_H});
wtbxappdata('set',fig,'posLocFig',{posLocFig,0});
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

title(strTITLE ,'Parent',handles.Axe_GRAPHIC,'FontSize',10,'FontWeight','bold');
%--------------------------------------------------------------------------
