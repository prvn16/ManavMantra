function varargout = mdw1dstat(varargin)
%MDW1DSTAT Discrete wavelet Multisignal 1D Analysis Tool.
%   VARARGOUT = MDW1DSTAT(VARARGIN)

% Last Modified by GUIDE v2.5 30-Aug-2006 18:06:55
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2005.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $ $Date: 2013/07/05 04:31:10 $ 

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mdw1dstat_OpeningFcn, ...
                   'gui_OutputFcn',  @mdw1dstat_OutputFcn, ...
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
% --- Executes just before mdw1dstat is made visible.                     %
%*************************************************************************%
function mdw1dstat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mdw1dstat (see VARARGIN)

% Choose default command line output for mdw1dstat
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
function varargout = mdw1dstat_OutputFcn(hObject,eventdata,handles) %#ok<*INUSL>
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
function Pus_Statistics_Callback(hObject,eventdata,handles) %#ok<*DEFNU>

% Get figure handle.
%-------------------
fig = handles.output;

% Cleaning.
%----------
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitClean'));

% Show Statistics.
%-----------------
blockdatamngr('set',fig,'tool_ATTR','State','STA_ON');
mdw1dafflst('STA',hObject,eventdata,handles,'init',[])
mdw1dmngr('set_Tool_View',handles,'STA','set_VIEW','LARGE')
mdw1dmisc('lst_DAT_SEL',handles,'Pus_STAT');

% End waiting.
%-------------
wwaiting('off',fig);
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%=========================================================================%
function varargout = Init_Tool(fig,eventdata,handles,varargin)

% Input Parameters.
%------------------
callingFIG = varargin{1};
Data_Name   = varargin{2};
tool_Name   = 'STA';
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
cb_close = 'mdw1dmngr(''Pus_CloseWin_Callback'',gcbo,[],guidata(gcbo),''STA'');';
set(m_close,'Callback',cb_close);
hdl_Menus = struct('m_files',m_files,'m_close',m_close);
wtbxappdata('set',fig,'hdl_Menus',hdl_Menus);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',fig,mfilename);

% Other Initializations.
%-----------------------
mdw1dmngr('init_TOOL',handles,Data_Name,tool_Name);
uic_STA_VAL = findobj(handles.Pan_STA_VAL,'Type','UiControl');
set(uic_STA_VAL,'Enable','Off');
callingFIG = blockdatamngr('get',fig,'fig_Storage','callingFIG');
calling_handles = guidata(callingFIG);
str_PopMode = get(calling_handles.Pop_VisPanMode,'String');
str_PopMode = [str_PopMode;...
    '--------------------';'Magnify Statistical Graphics'];
set(handles.Pop_VisPanMode,'String',str_PopMode,'Value',1)
set(handles.Pop_Show_Mode,'String',str_PopMode,'Value',1)

% Initializations of Type of plot .
%-----------------------------------
usr.nbSIG = 1;
usr.strPOP_ONE = {'Histogram','Cumulated Hist.',...
    'Autocorrelations','Spectrum','Boxplot'};
usr.strPOP_MUL = {'Boxplot','Covariance plot','Correlation plot',...
    'Covariance plot (abs)','Correlation plot (abs)'...
    };
usr.colors = mdw1dutils('colors');
set(handles.Pop_TYP_GRA,'UserData',usr);

% End of Initializations.
%------------------------
varargout{1} = fig;
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%--------------------------------------------------------------------------
function Pop_TYP_GRA_Callback(hObject,eventdata,handles,varargin)

%--------------------
% Histogram
% Cumulated Hist.
% Autocorrelations
% Spectrum
% Boxplot
% Cov. plot
% Corr. plot
% Cov. plot (abs)
% Corr. plot abs)
%--------------------
nbIN = length(varargin);
if nbIN && isequal(varargin{1},'INI')
    idxSEL   = varargin{2};
    curr_sig = varargin{3};
end
fig = handles.Current_Fig;
[dwtType,sigType] = mdw1dutils('get_Sig_IDENT',fig);
if isempty(dwtType) , return; end

val_POP = get(hObject,'Value');
cur_STR = get(hObject,'String');
firstITEM = cur_STR{1}(1);
usr = get(hObject,'UserData');
switch nbIN , 
    case 0 , nbSIG = usr.nbSIG;
    case 3 , nbSIG = 1; usr.nbSIG = nbSIG;
    case 4 , nbSIG = varargin{4}; usr.nbSIG = nbSIG;
end
if nbIN==3 || nbIN==4 ,  set(hObject,'UserData',usr); end
if nbSIG>1 && firstITEM=='H'       % H = Hist.
    if val_POP<5 , val_POP = 1; else val_POP = val_POP-4; end
    set(hObject,'Value',val_POP)
    set(hObject,'String',usr.strPOP_MUL)
elseif nbSIG<2 && firstITEM=='B'   % B = Box
    set(hObject,'String',usr.strPOP_ONE)
    if val_POP==1 , val_POP = 5; else val_POP = 1; end
    set(hObject,'Value',val_POP)
end
cur_STR = get(hObject,'String');
full_typePLOT = lower(cur_STR{val_POP});
typePLOT = full_typePLOT(1:3);
colors = usr.colors; 

if nbIN && isequal(varargin{1},'INI')
    switch lower(dwtType(1))
        case 's'
            switch lower(sigType(1))
                case 'o' , col_Name = 'sig';
                case 'c' , col_Name = 'cmp';
                case 'd' , col_Name = 'den';
                case 'r' , col_Name = 'res';
            end
        case 'a' , col_Name = 'app';
        case 'd' , col_Name = 'det';
    end
    curr_color = colors.(col_Name);
    usr = {idxSEL,curr_sig,curr_color};
    set(handles.Pan_VISU_STATS,'UserData',usr);
else
    usr = get(handles.Pan_VISU_STATS,'UserData');
    if isempty(usr) , return; end
    curr_color = usr{3};
end
idxSEL   = usr{1};
curr_sig = usr{2};
strTIT = getWavMSG('Wavelet:mdw1dRF:Selection_Num',idxSEL);
axe_Cur  = handles.Axe_STATS;

switch typePLOT
    case {'his','cum'}
        % Computing histogram.
        %----------------------
        nb_bins  = 50;
        his       = wgethist(curr_sig,nb_bins);
        [~,imod] = max(his(2,:));
        mode_val  = (his(1,imod)+his(1,imod+1))/2;
        his(2,:)  = his(2,:)/length(curr_sig);
        
        % Displaying histogram or cumulated histogram.
        %---------------------------------------------
        if isequal(typePLOT,'his')
            wplothis(axe_Cur,his,curr_color); 
        else
            for i=6:4:length(his(2,:));
                his(2,i)   = his(2,i)+his(2,i-4);
                his(2,i+1) = his(2,i);
            end
            wplothis(axe_Cur,[his(1,:);his(2,:)],curr_color);
        end
        strTIT = getWavMSG('Wavelet:mdw1dRF:Selection_Num_and_Mode',...
            idxSEL,num2str(mode_val,'%9.4f'));

    case 'aut'
        % Displaying Autocorrelations.
        %-----------------------------
        [corr,lags] = wautocor(curr_sig);
        lenLagsPos  = (length(lags)-1)/2;
        lenKeep     = min(200,lenLagsPos);
        first       = lenLagsPos+1-lenKeep;
        last        = lenLagsPos+1+lenKeep;
        Xval        = lags(first:last);
        Yval        = corr(first:last);
        plot(Xval,Yval,'Color',curr_color,'Parent',axe_Cur);
        set(axe_Cur, ...
            'XLim',[Xval(1) Xval(end)],'YLim',[min(0,1.1*min(Yval)) 1]);

    case 'spe'
        % Displaying Spectrum.
        %---------------------
        [sp,f]  = wspecfft(curr_sig);
        plot(f,sp,'Color',curr_color);
        xlimAX    = [min(f) max(f)];
        ext     = max([abs(max(sp) - min(sp))/100,1E-8]);
        ylimAX  = [min(sp)-ext max(sp)+ext];
        set(axe_Cur,'XLim',xlimAX,'YLim',ylimAX);
        strTIT = getWavMSG('Wavelet:mdw1dRF:NumberClasses',int2str(idxSEL));

    case {'box','cov','cor','cpc'}
        fig = handles.Current_Fig;
        idxSIG_Plot = wtbxappdata('get',fig,'idxSIG_Plot');
        NbPlot = length(idxSIG_Plot);
        if NbPlot>1
            maxNums = 4;
            last = min([NbPlot,maxNums]);
            idxP = idxSIG_Plot(1:last);
            if NbPlot<=maxNums
                strTIT = ...
                    getWavMSG('Wavelet:mdw1dRF:Selection_Num',int2str(idxP(:)'));
            else
                strTIT = ...
                    getWavMSG('Wavelet:mdw1dRF:Selection_NumETC',int2str(idxP(:)'));
            end
            data_SEL = mdw1dutils('data_INFO_MNGR','get',fig,'SEL');
            sig_SELECT = data_SEL.sel_DAT;
            if ~isequal(typePLOT,'box')
                idxSIG_Plot = flipud(idxSIG_Plot);
            end
            curr_sig = sig_SELECT(idxSIG_Plot,:);
        end

        switch typePLOT
            case 'box'
                colBox = repmat(colors.sig,nbSIG,1);
                % dwtType = flipud(dwtType);
                % sigType = flipud(sigType);
                idx = lower(dwtType)=='a';
                colBox(idx,:) = repmat(colors.app,sum(idx),1);
                idx = lower(dwtType)=='d';
                colBox(idx,:) = repmat(colors.det,sum(idx),1);
                idx = lower(dwtType)=='s' & (sigType=='d' | sigType=='c');
                colBox(idx,:) =  repmat(colors.d_OR_c,sum(idx),1);
                idx = lower(dwtType)=='s' & sigType=='r';
                colBox(idx,:) =  repmat(colors.res,sum(idx),1);
                axes(axe_Cur);
                hBox = wboxplot(curr_sig','labels',int2str(idxSIG_Plot(:)));
                if NbPlot>10 , set(axe_Cur,'XTick',[],'XTickLabel',''); end
                for k = 1:nbSIG , set(hBox(5,k),'Color',colBox(k,:));   end
                set(axe_Cur,'XGrid','On','YGrid','On')
                
            case {'cov','cor','cpc'}
                absMode = strfind(full_typePLOT,'abs');
                if isequal(typePLOT,'cov')
                    X = cov(curr_sig');      
                elseif isequal(full_typePLOT(1:5),'cpcov')
                    X = cov(curr_sig);
                else
                    if isequal(typePLOT,'cor')
                        X = corrcoef(curr_sig');
                    else
                        X = corrcoef(curr_sig);
                    end
                end
                if ~isempty(absMode) , X = abs(X); end
                colormap(cool(192));
                imagesc(X);
                pos = get(axe_Cur,'Position');
                dx  = 0.04;
                pos(1) = pos(1)+pos(3)+dx;
                pos(3) = (1 - pos(1))/3;
                cbar = colorbar('peer',axe_Cur,'EastOutside',...
                    'Box','on','FontSize',8,'Position',pos, ...
                    'YTick',[],'XLim',[-0.5 1.5]);
                title(cbar,getWavMSG('Wavelet:mdw1dRF:Str_Max'))
                xlabel(cbar,getWavMSG('Wavelet:mdw1dRF:Str_Min'))
        end
end
wtitle(strTIT,'Parent',axe_Cur);

% Compute and Statistics for first selected signal.
%--------------------------------------------------
pan_Status = get(handles.Pan_STA_VAL,'UserData');
if pan_Status==false || nbSIG>1
    uic_STA_VAL = findobj(handles.Pan_STA_VAL,'Type','Uicontrol');
    hdl_TXT = findobj(uic_STA_VAL,'Style','Text');
    hdl_EDI = findobj(uic_STA_VAL,'Style','Edit');
end
if nbSIG>1
    set([...
        handles.Edi_VAL_numsig, ...
        handles.Edi_VAL_min,handles.Edi_VAL_mean,handles.Edi_VAL_max, ...
        handles.Edi_VAL_range,handles.Edi_VAL_std,handles.Edi_VAL_med,...
        handles.Edi_VAL_abs_med_dev,handles.Edi_VAL_abs_mean_dev], ...
        'String','');
    set(hdl_TXT,'Enable','Off');
    set(hdl_EDI,'Enable','Off');
    set(handles.Pan_STA_VAL,'UserData',false);
    return;
end
if pan_Status==false
    set(hdl_TXT,'Enable','On');
    set(hdl_EDI,'Enable','Inactive');
    set(handles.Pan_STA_VAL,'UserData',true);
end
idxSEL    = idxSEL(1);
curr_sig  = curr_sig(1,:);
mean_VAL  = mean(curr_sig);
max_VAL   = max(curr_sig);
min_VAL   = min(curr_sig);
range_VAL = max_VAL-min_VAL;
std_VAL   = std(curr_sig);
med_VAL   = median(curr_sig);
med_abs_dev  = median(abs(curr_sig-med_VAL));
mean_abs_dev = mean(abs(curr_sig-mean_VAL));
formatNum = mdw1dutils('numFORMAT',max(abs(curr_sig)));
sig_num_STR = getWavMSG('Wavelet:mdw1dRF:Selection_Ind',idxSEL);
set(handles.Edi_VAL_numsig,'String',sig_num_STR);
set(handles.Edi_VAL_mean,'String',num2str(mean_VAL,formatNum));
set(handles.Edi_VAL_max,'String',num2str(max_VAL,formatNum));
set(handles.Edi_VAL_min,'String',num2str(min_VAL,formatNum));
set(handles.Edi_VAL_range,'String',num2str(range_VAL,formatNum));
set(handles.Edi_VAL_std,'String',num2str(std_VAL,formatNum))
set(handles.Edi_VAL_med,'String',num2str(med_VAL,formatNum))
set(handles.Edi_VAL_abs_med_dev,'String',num2str(med_abs_dev,formatNum))
set(handles.Edi_VAL_abs_mean_dev,'String',num2str(mean_abs_dev,formatNum))
%--------------------------------------------------------------------------
function [sp,f] = wspecfft(signal)
%WSPECFFT FFT spectrum of a signal.
%
% f is the frequency
% sp is the energy, the square of the FFT transform

% The input signal is empty.
%---------------------------
if isempty(signal) , sp = [];f =[]; return; end

% Compute the spectrum.
%----------------------
n   = length(signal);
XTF = fft(fftshift(signal));
m   = ceil(n/2) + 1;

% Compute the output values.
%---------------------------
f   = linspace(0,0.5,m);
sp  = (abs(XTF(1:m))).^2;
%--------------------------------------------------------------------------
function [c,lags] = wautocor(a,maxlag)
%WAUTOCOR Auto-correlation function estimates.
%   [C,LAGS] = WAUTOCOR(A,MAXLAG) computes the
%   autocorrelation function c of a one dimensional
%   signal a, for lags = [-maxlag:maxlag].
%   The autocorrelation c(maxlag+1) = 1.
%   If nargin==1, by default, maxlag = length(a)-1.

if nargin == 1, maxlag = size(a,2)-1;end
lags = -maxlag:maxlag;
if isempty(a) , c = []; return; end
epsi = sqrt(eps);
a    = a(:);
a    = a - mean(a);
nr   = length(a); 
if std(a)>epsi
    % Test of the variance.
    %----------------------
    mr     = 2 * maxlag + 1;
    nfft   = 2^nextpow2(mr);
    nsects = ceil(2*nr/nfft);
    if nsects>4 && nfft<64
        nfft = min(4096,max(64,2^nextpow2(nr/4)));
    end
    c      = zeros(nfft,1);
    minus1 = (-1).^(0:nfft-1)';
    af_old = zeros(nfft,1);
    n1     = 1;
    nfft2  = nfft/2;
    while (n1<nr)
       n2 = min( n1+nfft2-1, nr );
       af = fft(a(n1:n2,:), nfft);
       c  = c + af.* conj( af + af_old);
       n1 = n1 + nfft2;
       af_old = minus1.*af;
    end
    if n1==nr
        af = ones(nfft,1)*a(nr,:);
   	c  = c + af.* conj( af + af_old );
    end
    mxlp1 = maxlag+1;
    c = real(ifft(c));
    c = [ c(mxlp1:-1:2,:); c(1:mxlp1,1) ];

    % Compute the autocorrelation function.
    %-------------------------------------- 
    cdiv = c(mxlp1,1);
    c = c / cdiv;
else
    % If  the variance is too small.
    %-------------------------------
    c = ones(size(lags));
end
%--------------------------------------------------------------------------
