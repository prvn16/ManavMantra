function varargout = wmspcatoolmopc(varargin)
% WMSPCATOOLMOPC MATLAB file for wmspcatoolmopc.fig 
%	Called by WMSPCATOOL (More On Principal Component Analysis).

% Last Modified by GUIDE v2.5 23-Jan-2006 17:06:52
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Jan-2006.
%   Last Revision: 18-Jun-2012.
%   Copyright 1995-2012 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2013/08/23 23:46:06 $ 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wmspcatoolmopc_OpeningFcn, ...
                   'gui_OutputFcn',  @wmspcatoolmopc_OutputFcn, ...
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
function wmspcatoolmopc_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for wmspcatoolmopc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION %
%%!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles,varargin{:})
%--------------------------------------------------------------------------
function varargout = wmspcatoolmopc_OutputFcn(hObject,eventdata,handles)  %#ok<*INUSL>

% Get default command line output from handles structure
varargout{1} = handles.output;
%--------------------------------------------------------------------------
function Pus_Close_Callback(hObject,eventdata,handles) %#ok<DEFNU>

fig = handles.output;
wmspcatool('Pus_More_PCA_Callback',fig,[],handles)
%--------------------------------------------------------------------------
function Pop_Typ_Comp_Callback(hObject,eventdata,handles) %#ok<DEFNU>

val = get(hObject,'Value');
old = get(hObject,'UserData');
if isequal(val,old) , return; end
set(hObject,'UserData',val);

usr = get(handles.Pan_APP_PCA,'UserData');
[x,tab_perVAL,tab_cumVAL,npc] = deal(usr{2:5});
toDEL = allchild([handles.Axe_A_D_PER,handles.Axe_A_D_CUM]);
toDEL = cat(1,toDEL{:});
delete(toDEL)
plot_PER_CUM(handles.Axe_A_D_PER,'per',x,tab_perVAL,val);
plot_PER_CUM(handles.Axe_A_D_CUM,'cum',x,tab_cumVAL,val,npc(val));
%--------------------------------------------------------------------------
function WinBtnMotionFcn(hObject,eventdata,handles) %#ok<*INUSD,DEFNU>

handles = guidata(hObject);
curPTS = get(hObject,'CurrentPoint');
usr = get(handles.Pan_APP_PCA,'UserData');
% usr = {rect,x,tab_perVAL,tab_cumVAL,npc,level}
rect = usr{1};
rectAXE = rect(3:end,:);
visAXE = lower(get(handles.Axe_FIN_PER,'Visible'));
if isequal(visAXE,'off') , rectAXE(3:end,:) = []; end
iAXE = 0;
for k=1:size(rectAXE,1)
    bool = pinrect(curPTS,rectAXE(k,:));
    if bool , iAXE = k; break; end
end
ok = false;
if iAXE>0
    npc   = usr{5};
    level = usr{6};
    switch iAXE
        case 1
            axeCUR = handles.Axe_A_D_PER; idxUSR = 3; 
            idxVAL = get(handles.Pop_Typ_Comp,'Value');
        case 2
            axeCUR = handles.Axe_A_D_CUM; idxUSR = 4; 
            idxVAL = get(handles.Pop_Typ_Comp,'Value');
        case 3
            axeCUR = handles.Axe_FIN_PER; idxUSR = 3; idxVAL = level+2;
        case 4 
            axeCUR = handles.Axe_FIN_CUM; idxUSR = 4; idxVAL = level+2;
    end
    xlim = get(axeCUR,'XLim');
    ylim = get(axeCUR,'YLim');
    xaxe = (curPTS(1)-rectAXE(iAXE,1))/(rectAXE(iAXE,3)-rectAXE(iAXE,1));
    yaxe = (curPTS(2)-rectAXE(iAXE,2))/(rectAXE(iAXE,4)-rectAXE(iAXE,2));
    xPts = xlim(1) + (xlim(2)-xlim(1))*xaxe;
    yPts = ylim(1) + (ylim(2)-ylim(1))*yaxe;
    x = usr{2};
    y = usr{idxUSR}(:,idxVAL);
    minX = min(abs(x-xPts));
    if minX<0.1
        [mini,idxPts] = min(abs(x-xPts)+ abs(y-yPts));
        if mini<2
            xSEL = x(idxPts);
            ySEL = y(idxPts);
            ok = true;
            BkCOL = [1 1 0.7];
            if (iAXE==2 && xSEL==npc(idxVAL)) || (iAXE==4 && xSEL==npc(idxVAL))
                BkCOL = [1 0.8 0.8];
            end
            text(xSEL,ySEL+5,[num2str(ySEL,'%5.2f') ' %'],...
                'Parent',axeCUR,'FontSize',10,'FontWeight','bold',...
                'EdgeColor','k','BackgroundColor',BkCOL,...
                'HorizontalAlignment','Center','Tag','Percent_TXT');
            pause(0.01)
        end
    end
end
if ~ok
    delete(findobj(hObject,'Type','text','Tag','Percent_TXT'))
end
%--------------------------------------------------------------------------
function bool = pinrect(pts,rect)

bool = (pts(1)>=rect(1)) && (pts(1)<=rect(3)) && ...
       (pts(2)>=rect(2)) && (pts(2)<=rect(4));
%--------------------------------------------------------------------------

%=========================================================================%
%                BEGIN Tool Initialization                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles,varargin)

callingFIG = gcbf;
wfigmngr('set_FigATTRB',hObject,'nulle');
wfigmngr('init_called_FIG',hObject);
set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Pus_More_PCA'));
uic = wfindobj(hObject,'Type','uicontrol');
pus = wfindobj(uic,'Tag','Pus_Close');
set(pus,'String',getWavMSG('Wavelet:commongui:Str_Close'));
pus_MORE   = varargin{1};
PCA_Params = varargin{2};
posCaller  = get(callingFIG,'Position');
posLocFig  = get(hObject,'Position');
posLocFig(1) = posCaller(1) + 0.025;
posLocFig(2) = posCaller(2)+(posCaller(4) - posLocFig(4))/2;
set(hObject,'Position',posLocFig,'UserData',pus_MORE);
axeInFIG = [...
    handles.Axe_A_D_PER,handles.Axe_A_D_CUM, ...
    handles.Axe_FIN_PER,handles.Axe_FIN_CUM  ...    
    ];
level = length(PCA_Params)-2;
nbSIG = length(PCA_Params(1).variances);
x     = (1:nbSIG)';
tab_perVAL = zeros(nbSIG,level+2);
npc = zeros(1,level+2);
for k = 1:level+2
    vp = PCA_Params(k).variances;
    tab_perVAL(:,k) = 100*vp/sum(vp);
    tab_cumVAL = cumsum(tab_perVAL);
    npc(k) = PCA_Params(k).npc;
end

strPOP = [getWavMSG('Wavelet:commongui:Str_Details') ' '];
strPOP = [strPOP(ones(level+1,1),:) , int2str((1:level+1)')];
strPOP = num2cell(strPOP,2);
strPOP{end} = [getWavMSG('Wavelet:commongui:Approximations')  ...
    ' ' int2str(level)];
LP1 = level+1;
LP2 = level+2;
set(handles.Pop_Typ_Comp,'String',strPOP,'Value',LP1,'UserData',LP1);
plot_PER_CUM(handles.Axe_A_D_PER,'per',x,tab_perVAL,LP1)
plot_PER_CUM(handles.Axe_A_D_CUM,'cum',x,tab_cumVAL,LP1,npc(LP1))
plot_PER_CUM(handles.Axe_FIN_PER,'per',x,tab_perVAL,LP2)
plot_PER_CUM(handles.Axe_FIN_CUM,'cum',x,tab_cumVAL,level+2,npc(LP2))
HDL = [hObject,handles.Pan_APP_PCA,handles.Pan_FIN_PCA,axeInFIG ];
set(HDL,'Units','Pixels');
posHDL = get(HDL,'Position');
posHDL = cat(1,posHDL{:});
set(HDL,'Units','Normalized');
for k=1:2
    posHDL(4:5,k) = posHDL(4:5,k) + posHDL(2,k);
    posHDL(6:7,k) = posHDL(6:7,k) + posHDL(3,k);
end
posHDL(2:end,[1,3]) = posHDL(2:end,[1,3])/posHDL(1,3);
posHDL(2:end,[2,4]) = posHDL(2:end,[2,4])/posHDL(1,4);
rect = posHDL(2:end,:);
rect(:,[3 4]) = rect(:,[3 4])+rect(:,[1 2]);
set(handles.Pan_APP_PCA,'UserData',{rect,x,tab_perVAL,tab_cumVAL,npc,level});
set(hObject,'WindowButtonMotionFcn',...
    [mfilename '(''WinBtnMotionFcn'',' num2mstr(hObject) ',[],[])']);
wtranslate(mfilename,hObject)
%----------------------------------------------------------------------
function plot_PER_CUM(axeCUR,typePLOT,x,tab_VAL,k,npc)

yVAL  = tab_VAL(:,k);
switch typePLOT
    case 'per'
        xlab  = getWavMSG('Wavelet:mdw1dRF:PercentExplain');
        npcFLAG = false;
    case 'cum'
        xlab  = getWavMSG('Wavelet:mdw1dRF:CumPercent');
        npcFLAG = true;
end
nbSIG = size(tab_VAL,1);
stem(axeCUR,x,yVAL,'filled');
if nbSIG<1
    ytick    = sort(yVAL);
    yticklab = num2str(ytick,'%5.2f');
    set(axeCUR,'YTick',ytick,'YTickLabel',yticklab);
end
xlabel(xlab,'Parent',axeCUR);
if npcFLAG && npc>0
    hold on
    stem(axeCUR,x(npc),tab_VAL(npc,k),'filled','Color','r')    
end
pause(0.01)
set(axeCUR,'XTick',x,'XLim',[0.5 nbSIG+0.5],'YGrid','On','XGrid','On');
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%
