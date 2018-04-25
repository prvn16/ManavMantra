function varargout = wmuldentoolmopc(varargin)
% WMULDENTOOLMOPC MATLAB file for wmuldentoolmopc.fig 
%	Called by WMULDENTOOL (More On Principal Component Analysis).

% Last Modified by GUIDE v2.5 11-Jul-2013 09:14:36
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Jan-2006.
%   Last Revision: 11-Jul-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $ $Date: 2013/08/23 23:46:12 $ 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wmuldentoolmopc_OpeningFcn, ...
                   'gui_OutputFcn',  @wmuldentoolmopc_OutputFcn, ...
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
function wmuldentoolmopc_OpeningFcn(hObject,eventdata,handles,varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.

% Choose default command line output for wmuldentoolmopc
handles.output = hObject;

% Update handles structure
guidata(hObject,handles);

%%!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION %
%%!!!!!!!!!!!!!!!!!!!!%
callingFIG = gcbf;
wfigmngr('set_FigATTRB',hObject,'nulle');
wfigmngr('init_called_FIG',hObject);
set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Pus_More_PCA'));
uic = wfindobj(hObject,'Type','uicontrol');
pus = wfindobj(uic,'Tag','Pus_Close');
set(pus,'String',getWavMSG('Wavelet:commongui:Str_Close'));
pan = wfindobj(hObject,'type','uipanel');
set(pan(1),'Title', ...
    formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Nb_PC_DetOrApp')));
set(pan(2),'Title', ...
    formatPanTitle(getWavMSG('Wavelet:mdw1dRF:Nb_PC_FinalPCA')));
pus_MORE   = varargin{1};
PCA_Params = varargin{2};
posCaller = get(callingFIG,'Position');
posLocFig = get(hObject,'Position');
posLocFig(1) = posCaller(1) + 0.025;
posLocFig(2) = posCaller(2)+(posCaller(4) - posLocFig(4))/2;
set(hObject,'Position',posLocFig,'UserData',pus_MORE);
axeInFIG = [...
    handles.Axe_APP_PER,handles.Axe_APP_CUM, ...
    handles.Axe_FIN_PER,handles.Axe_FIN_CUM  ...    
    ];
maxForYTICK = 1;

nbAPP = PCA_Params.APP{3};
nbFIN = PCA_Params.FIN{3};
if isnan(nbFIN) , ena_vis = 'Off'; else ena_vis = 'On'; end
set(axeInFIG([3,4]),'Visible',ena_vis');    

vp = PCA_Params.APP{2};
nbSIG = length(vp);
x = (1:nbSIG)';
%-------------------------------------------------------
perEXP_APP = 100*vp/sum(vp);
axeCUR = handles.Axe_APP_PER;
stem(axeCUR,x,perEXP_APP,'filled');
if nbSIG<maxForYTICK
    ytick    = sort(perEXP_APP);
    yticklab = num2str(ytick,'%5.2f');
    set(axeCUR,'YTick',ytick,'YTickLabel',yticklab);
end
xlabel(getWavMSG('Wavelet:mdw1dRF:PercentExplain'),'Parent',axeCUR);
%-------------------------------------------------------
cumEXP_APP = cumsum(perEXP_APP);
axeCUR = handles.Axe_APP_CUM;
stem(axeCUR,x,cumEXP_APP,'filled')
if nbSIG<maxForYTICK
    ytick    = cumEXP_APP;
    yticklab = num2str(ytick,'%5.2f');
    set(axeCUR,'YTick',ytick,'YTickLabel',yticklab);
end
xlabel(getWavMSG('Wavelet:mdw1dRF:CumPercent'),'Parent',axeCUR);
%-------------------------------------------------------
if ~isnan(nbFIN)
    vp = PCA_Params.FIN{2};
    perEXP_FIN = 100*vp/sum(vp);
    axeCUR = handles.Axe_FIN_PER;
    stem(axeCUR,x,perEXP_FIN,'filled')
    if nbSIG<maxForYTICK
        ytick    = sort(perEXP_FIN);
        yticklab = num2str(ytick,'%5.2f');
        set(axeCUR,'YTick',ytick,'YTickLabel',yticklab);
    end
    xlabel(getWavMSG('Wavelet:mdw1dRF:PercentExplain'),'Parent',axeCUR);
    
    cumEXP_FIN = cumsum(perEXP_FIN);
    axeCUR = handles.Axe_FIN_CUM;
    stem(axeCUR,x,cumEXP_FIN,'filled')
    if nbSIG<maxForYTICK
        ytick    = cumEXP_FIN;
        yticklab = num2str(ytick,'%5.2f');
        set(axeCUR,'YTick',ytick,'YTickLabel',yticklab);
    end
    xlabel(getWavMSG('Wavelet:mdw1dRF:CumPercent'),'Parent',axeCUR);
    
    nbAPP = PCA_Params.APP{3};
    if nbAPP>0
        axeCUR = handles.Axe_APP_CUM;
        set(axeCUR,'NextPlot','Add')
        stem(axeCUR,x(nbAPP),cumEXP_APP(nbAPP),'filled','Color','r')
    end
    if nbFIN>0
        axeCUR = handles.Axe_FIN_CUM;        
        set(axeCUR,'NextPlot','Add')
        stem(axeCUR,x(nbFIN),cumEXP_FIN(nbFIN),'filled','Color','r')
    end
else
    perEXP_FIN = zeros(size(perEXP_APP));
    cumEXP_FIN = perEXP_FIN;
end
set(axeInFIG,'XTick',x,'XLim',[0.5 nbSIG+0.5],'YGrid','On','XGrid','On');

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
set(handles.Pan_APP_PCA,'UserData',...
    {rect,[perEXP_APP,cumEXP_APP,perEXP_FIN,cumEXP_FIN,x],[nbAPP,nbFIN]});
set(hObject,'WindowButtonMotionFcn',...
    [mfilename '(''WinBtnMotionFcn'',' num2mstr(hObject) ',[],[])']);
%--------------------------------------------------------------------------
function varargout = wmuldentoolmopc_OutputFcn(hObject,eventdata,handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;
%--------------------------------------------------------------------------
function Pus_Close_Callback(hObject,eventdata,handles) %#ok<DEFNU>

fig = handles.output;
wmuldentool('Pus_More_PCA_Callback',fig,[],handles)
%--------------------------------------------------------------------------
function WinBtnMotionFcn(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

handles = guidata(hObject);
curPTS = get(hObject,'CurrentPoint');
usr = get(handles.Pan_APP_PCA,'UserData');
% usr = ...
%  {rect,[perEXP_APP,cumEXP_APP,perEXP_FIN,cumEXP_FIN,x]},[nbAPP,nbFIN]);
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
    switch iAXE
        case 1 , axeCUR =handles.Axe_APP_PER; 
        case 2 , axeCUR =handles.Axe_APP_CUM; 
        case 3 , axeCUR =handles.Axe_FIN_PER; 
        case 4 , axeCUR =handles.Axe_FIN_CUM; 
    end
    xlim = get(axeCUR,'XLim');
    ylim = get(axeCUR,'YLim');
    xaxe = (curPTS(1)-rectAXE(iAXE,1))/(rectAXE(iAXE,3)-rectAXE(iAXE,1));
    yaxe = (curPTS(2)-rectAXE(iAXE,2))/(rectAXE(iAXE,4)-rectAXE(iAXE,2));
    xPts = xlim(1) + (xlim(2)-xlim(1))*xaxe;
    yPts = ylim(1) + (ylim(2)-ylim(1))*yaxe;
    x = usr{2}(:,5);
    y = usr{2}(:,iAXE);
    minX = min(abs(x-xPts));
    if minX<0.1
        [mini,idxPts] = min(abs(x-xPts)+ abs(y-yPts));
        if mini<2
            xSEL = x(idxPts);
            ySEL = y(idxPts);
            ok = true;
            BkCOL = [1 1 0.7];
            if (iAXE==2 && xSEL==usr{3}(1)) || (iAXE==4 && xSEL==usr{3}(2))
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
function S = formatPanTitle(S)

S = ['   ' S '   .'];
%--------------------------------------------------------------------------
