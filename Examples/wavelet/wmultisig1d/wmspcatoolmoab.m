function varargout = wmspcatoolmoab(varargin)
% WMSPCATOOLMOAB MATLAB file for wmspcatoolmoab.fig
%	Called by WMSPCATOOL (More On Adapted Basis).

% Last Modified by GUIDE v2.5 11-Jul-2013 17:59:49
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Jan-2006.
%   Last Revision: 25-Jan-2012.
%   Copyright 1995-2012 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2013/08/23 23:46:04 $ 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wmspcatoolmoab_OpeningFcn, ...
                   'gui_OutputFcn',  @wmspcatoolmoab_OutputFcn, ...
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
function wmspcatoolmoab_OpeningFcn(hObject,~,handles,varargin)

% Choose default command line output for wmspcatoolmoab
handles.output = hObject;

% Update handles structure
guidata(hObject,handles);

%%!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION %
%%!!!!!!!!!!!!!!!!!!!!%
callingFIG = gcbf;
wfigmngr('init_called_FIG',hObject);
set(hObject,'Name',getWavMSG('Wavelet:mdw1dRF:Pus_More_ADAP'));
uic = wfindobj(hObject,'Type','uicontrol');
txt = wfindobj(uic,'Tag','Txt_Eig_VAL');
set(txt,'String',getWavMSG('Wavelet:mdw1dRF:Eigenvalues'));
txt = wfindobj(uic,'Tag','Txt_Eig_VECT');
set(txt,'String',getWavMSG('Wavelet:mdw1dRF:Eigenvectors'));
txt = wfindobj(uic,'Tag','Pus_Close');
set(txt,'String',getWavMSG('Wavelet:commongui:Str_Close'));
pus_MORE = varargin{1};
PCA_Params = varargin{2};
nbVAL = length(PCA_Params);
level = nbVAL-2;
strPOP = [getWavMSG('Wavelet:commongui:Str_Details') ' '];
strPOP = [strPOP(ones(nbVAL,1),:) , int2str((1:nbVAL)')];
strPOP = num2cell(strPOP,2);
strPOP{end-1} = [getWavMSG('Wavelet:commongui:Approximations')  ...
    ' ' int2str(level)];
strPOP{end} = getWavMSG('Wavelet:mdw1dRF:Final_PCA');

set(handles.Pop_COMP,'String',strPOP,'Value',1,'UserData',PCA_Params);
posCaller = get(callingFIG,'Position');
posLocFig = get(hObject,'Position');
posLocFig(1) = posCaller(1) + 0.025;
posLocFig(2) = posCaller(2)+(posCaller(4) - posLocFig(4))/2;
set(hObject,'Position',posLocFig,'UserData',pus_MORE);
set(handles.Axe_ALL,'XTick',[],'YTick',[],'Visible','On')
load('wmuldenpcamoab_img')
image(Xeigenv,'Parent',handles.Axe_EigenV);
image(Xlambda,'Parent',handles.Axe_Lambda);
set([handles.Axe_EigenV,handles.Axe_Lambda],...
    'XTick',[],'YTick',[],'Visible','Off')
showVALUES(handles,1)
%--------------------------------------------------------------------------
function varargout = wmspcatoolmoab_OutputFcn(~,~,handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;
%--------------------------------------------------------------------------
function Pus_Close_Callback(~,~,handles) %#ok<*DEFNU>

fig = handles.output;
wmspcatool('Pus_More_ADAP_Callback',fig,[],handles)
%--------------------------------------------------------------------------
function Pop_COMP_Callback(hObject,~,handles)

val = get(hObject,'Value');
showVALUES(handles,val)
%--------------------------------------------------------------------------
function showVALUES(handles,num)

PCA_Params = get(handles.Pop_COMP,'UserData');
TMP = struct2cell(PCA_Params(num));
[pc,variances] = deal(TMP{1:2});
nbVAL = length(variances);
switch nbVAL
    case 5       , FontSize = 10;
    case {6,7,8} , FontSize = 8;
    otherwise    , FontSize = 10;
end
formatNUM = '%9.4f';
set(handles.Txt_EigVAL_VAL,'FontSize',FontSize,...
        'String',num2str(variances,formatNUM));
set(handles.Txt_EIGVect_VAL,'FontSize',FontSize,...
        'String',num2str(pc,formatNUM));
%--------------------------------------------------------------------------
