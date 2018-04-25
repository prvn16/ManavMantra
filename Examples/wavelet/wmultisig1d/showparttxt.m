function varargout = showparttxt(ARG,caller)
%SHOWPARTTXT Show partitions indices in text format.
%   SHOWPARTTXT(LNK_SIM_STRUCT) or 
%   FIG = SHOWPARTTXT(LNK_SIM_STRUCT)
%   LNK_SIM_STRUCT is a structure computed by PARTLINKANDSIM
%   which contains Links and Similarity indices.
%   See PARTLINKANDSIM. FIG is the handle of the produced
%   figure.

%   SHOWPARTTXT(FIG) is used by GUI (SHOWPARTSIMIDX.M).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2006.
%   Last Revision: 11-Jul-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $ $Date: 2013/08/23 23:46:00 $ 

narginchk(0,2);

% Callback for menu Save
%-----------------------
if nargin==0
    fig = gcbf;
    mask = {...
        '*.mat;*.txt','ASCII Text ( *.mat , *.txt )';
        '*.*','All Files (*.*)'};
    [filename,pathname,ok] = ...
        utguidiv('test_save',fig,mask,'Save Listbox String');
    if ok  % Save file.
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        lst_INFO = findobj(fig,'Style','listBox');
        name = get(lst_INFO,'String'); %#ok<NASGU>
        try
            save([pathname filename],'name');
        catch %#ok<CTCH>
            errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end
    end
    return
end
%--------------------------------------------------------------------
nbPART = Inf;
if nargin<2
    caller = 'IDX';
    if ~ishandle(ARG) , end
end
if ishandle(ARG)
    fig = ARG;
    tag = [mfilename ,handle2str(fig)];
    figTXT = wfindobj(0,'Type','figure','Tag',tag);
    if ~isempty(figTXT) , figure(figTXT); return; end
    callingFIG = wtbxappdata('get',fig,'callingFIG');
    TAB_Partitions = wtbxappdata('get',callingFIG,'TAB_Partitions');
    nbPART = length(TAB_Partitions);  
end

switch caller
    case 'IDX'
        if ishandle(ARG)
            LNK_SIM_STRUCT = wtbxappdata('get',callingFIG,'LNK_SIM_STRUCT');
        else
            LNK_SIM_STRUCT = ARG; 
        end
        figTitle = getWavMSG('Wavelet:mdw1dRF:ShowPartTxt_Name_Sim');
    
    case 'PERF'
        figTitle = getWavMSG('Wavelet:mdw1dRF:ShowPartTxt_Name_Qual');
end
wFIG = 0.6;
if     nbPART<3 , wFIG = 0.4; 
elseif nbPART<5 , wFIG = 0.5;
end
posFIG = [(1-wFIG)/2 0.1 wFIG 0.8];
fig = figure('NumberTitle','Off','Name',figTitle,'MenuBar','None',...
    'Units','normalized','Position',posFIG,'Tag',tag);
wfigmngr('extfig',fig,'ExtMainFig_WTBX')
menus = findobj(fig,'Type','uimenu','Parent',fig);
m_files = findobj(menus,'Tag','figMenuFile');
m_first = findobj(m_files,'Position',1);
uimenu(m_files,...
    'Label',' Save Listbox String','Position',1,...
    'Enable','On','Callback',mfilename);
set(m_first,'Separator','On');

lst_INFO = uicontrol('Style','listbox',...
    'Units','normalized','Position',[1/6 0 4/6 1],...
    'Enable','Inactive','Max',2,...
    'BackgroundColor',[1 1 1], ...
    'FontName','FixedWidth','Visible','Off',...
    'Tag','lst_INFO');

switch caller
    case 'IDX'
        idx_Attrb = tplnksim;
        idx_Names = idx_Attrb(:,1);
        nbIDX = length(idx_Names);
        tabSize = size(LNK_SIM_STRUCT.(idx_Names{1}));
        tabIDX  = zeros(tabSize(1),tabSize(2),nbIDX);
        Lmax = 0;
        for k = 1:nbIDX
            fn = idx_Names{k};
            tabIDX(:,:,k) = LNK_SIM_STRUCT.(fn);
            if length(fn)>Lmax , Lmax = length(fn); end
        end
        Lmax = Lmax + 2;
        strTXT  = [];
        for k=1:nbIDX
            strTMP = formatTXT(tabIDX(:,:,k),idx_Names{k},Lmax);
            strTXT = char(strTXT,strTMP);
        end
        L  = size(strTXT,2);
        sep = '-';
        sep = sep(:,ones(1,L));
        strTXT =[strTXT ; sep];
        L  = size(strTXT,1);
        strTXT = [repmat('     |',L,1) , strTXT , repmat('|',L,1)];
        
    case 'PERF'
        cell_Names =  {...
            'stdQ1','stdQ2','glbSTD', ...
            'Inter/Intra','Inter/Intra (N)','logINTRA','logINTER', ...
            'MEAN Silh','MIN Silh','MAX Silh','STD Silh','PART Silh'
            };
        
        % Load signals and Partitions.
        %----------------------------
        usrVal_1 = wtbxappdata('get',callingFIG,'Std_Quality');
        usrVal_2 = wtbxappdata('get',callingFIG,'BetweenWithin');
        silh_VALUES = wtbxappdata('get',callingFIG,'silh_VALUES');
        if isempty(usrVal_1) || isempty(usrVal_2) ||isempty(silh_VALUES)
            filedataname = wtbxappdata('get',callingFIG,'filedataname');
            signals = msloadutl(filedataname);
            DirDEC  = wtbxappdata('get',callingFIG,'DirDEC');
            if isequal(lower(DirDEC(1)),'c') , signals = signals'; end
            TAB_Partitions = wtbxappdata('get',callingFIG,'TAB_Partitions');
        end
        
        % 'stdQ1','stdQ2','glbSTD'
        %------------------------
        if isempty(usrVal_1)
            [tabPERF{1},tabPERF{2},tabPERF{3}] = ...
                partstdqual(TAB_Partitions,signals);
            wtbxappdata('set',callingFIG,'Std_Quality',...
                    {tabPERF{1},tabPERF{2},tabPERF{3}});
        else
            [tabPERF{1},tabPERF{2},tabPERF{3}] = deal(usrVal_1{:});
        end
        
        % 'Inter/Intra','Inter/Intra (N)','logINTRA','logINTER'
        %------------------------------------------------------
        if isempty(usrVal_2)
            [tabPERF{4},tabPERF{5},tabPERF{6},tabPERF{7}] = ...
                partbetweenwithin(signals,TAB_Partitions);
            wtbxappdata('set',callingFIG,'BetweenWithin', ...
                {tabPERF{4},tabPERF{5},tabPERF{6},tabPERF{7}});
        else
            [tabPERF{4},tabPERF{5},tabPERF{6},tabPERF{7}] = deal(usrVal_2{:});
        end
        tabPERF{6} = log10(tabPERF{6});
        tabPERF{7} = log10(tabPERF{7});
        
        % 'MEAN Silh','MIN Silh','MAX Silh','STD Silh','PART Silh'
        %---------------------------------------------------------
        if isempty(silh_VALUES)
            h = waitbar(50,getWavMSG('Wavelet:moreMSGRF:Please_wait'));            
            [silh_VAL,silh_PART] = partsilh(signals,TAB_Partitions);
            wtbxappdata('set',callingFIG,'silh_VALUES',{silh_VAL,silh_PART});
            close(h)
            tabPERF{12} = silh_PART;
        else
            silh_VAL    = silh_VALUES{1};
            tabPERF{12} = silh_VALUES{2};
        end
        for j = 1:length(silh_VAL),
            tabPERF{8}{j}  = silh_VAL{j}(1,:);
            tabPERF{9}{j}  = silh_VAL{j}(2,:);
            tabPERF{10}{j} = silh_VAL{j}(3,:);
            tabPERF{11}{j} = silh_VAL{j}(4,:);
        end
        strTXT  = {};
        for k = [4 5 12 8 11 1:3 6:7 9:10]
            strTMP = formatTXT_PERF(tabPERF{k},cell_Names{k});
            strTXT = [strTXT,strTMP]; 
        end        
end

switch nbPART
    case {1} , Pos_LST = [1/4 0 1/2 1];
    case {2,3}   , Pos_LST = [1/6 0 4/6 1];
    case 4 , Pos_LST = [1/12 0 10/12 1];
    case 5 , Pos_LST = [1/10 0 8/10 1];
    case 6 , Pos_LST = [1/12 0 10/12 1];
    otherwise   ,  Pos_LST = [1/14 0 12/14 1];
end
set(lst_INFO,'String',strTXT,'Position',Pos_LST,'Visible','On','Value',[]);
if nargout==1 , varargout{1} = fig; end
%--------------------------------------------------------------------------
function strTXT = formatTXT(tabIDX,name,Lmax)

formatNUM = '%9.3f';
strTXT = num2str(tabIDX,formatNUM);
if ~isempty(name) , name = [name ' Index']; end
L1  = size(strTXT,2);
L2  = length(name);
L3 = max([L1,L2,Lmax]);
if L1<L3
    nbR = size(strTXT,1);
    nbC_beg = floor((L3-L1)/2);
    nbC_end = L3-L1-nbC_beg;
    strTXT = [repmat(' ',nbR,nbC_beg)  strTXT  repmat(' ',nbR,nbC_end)];
end
tmp = blanks(L3);
beg = 1 + floor((L3-L2)/2);
tmp(beg:beg+L2-1) = name;
sep = '-'; sep = sep(:,ones(1,L3));
strTXT = [sep ; tmp ; blanks(L3) ; strTXT ];
%--------------------------------------------------------------------------
function strTXT = formatTXT_PERF(tabIDX,name)

if iscell(tabIDX)    
    nbPART = length(tabIDX);
    maxCLU = 0;
    nbCLU = zeros(1,nbPART);
    for j=1:nbPART
        nbCLU(j) = length(tabIDX{j});
        if nbCLU(j)>maxCLU , maxCLU = nbCLU(j); end
    end
    strTXT = [];
    sepCOL = repmat(' | ',maxCLU,1);
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
        for k = nbCLU(j)+1:maxCLU
            srtTMP_P = [srtTMP_P ; blanks(L)];
        end
        if j>1 , strTXT = [strTXT , sepCOL]; end
        strTXT = [strTXT , srtTMP_P];
    end
else
    formatNUM = '%9.3f';
    strTXT = num2str(tabIDX,formatNUM);
end
if ~isempty(name) , name = [name ' Perf.']; end
L1 = size(strTXT,2);
L2 = length(name);
L3 = max([L1,L2]);
if L1<L2
    nbR = size(strTXT,1);
    nbC_beg = floor((L2-L1)/2);
    nbC_end = L2-L1-nbC_beg;
    strTXT = [repmat(' ',nbR,nbC_beg)  strTXT  repmat(' ',nbR,nbC_end)];
end
tmp = blanks(L3);
beg = 1 + floor((L3-L2)/2);
tmp(beg:beg+L2-1) = name;
strTXT = [...
  repmat('=',1,L3) ; tmp ; repmat('-',1,L3) ; strTXT  ; repmat('=',1,L3) ];
nbR = size(strTXT,1);
strTXT = [repmat('  |',nbR,1)  strTXT  repmat('|',nbR,1)];
nbC = size(strTXT,2);
strTXT = [strTXT ; blanks(nbC) ; blanks(nbC)];
%--------------------------------------------------------------------------
