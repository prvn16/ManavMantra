function varargout = partsetmngr(option,varargin)
% PARTSETMNGR Partition set manager.
%
%   VARARGOUT = PARTSETMNGR(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Sep-2006.
%   Last Revision 29-Apr-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

%=============================================================
% VALID OPTIONS:
%---------------
%	'load_PART'
%   'clear_PART'
%   'store_PART'
%   'import_PART'
%   'Set_Pus_IMPORT'
%=============================================================

varargout = {};
switch option
    case 'load_PART'
        tool   = varargin{1};
        caller = varargin{2};
        switch tool
            case 'ORI' , fig = caller;
            case 'CLU' ,
                fig = blockdatamngr('get',caller,'fig_Storage','callingFIG');
        end
        if length(varargin)<3
            [filename,pathname] = uigetfile(...
                {'*.mat;*.par;*.clu', 'ALL 1D Files (*.mat, *.par, *.clu)'},...
                getWavMSG('Wavelet:mdw1dRF:Load_Partition'));
            if ~isequal(filename,0) && ~isequal(pathname,0)
                fullName = fullfile(pathname,filename);
            else
                return
            end
        else
            fullName = varargin{3};
        end
        if ~isequal(fullName,'wrks')
            try
                err = 0;
                dataInfo = whos('-file',fullName);
                dataInfoCell = struct2cell(dataInfo);
                admissible_VAR_Names = ...
                    {'IdxCLU','tab_IdxCLU','clusters','clusterset','numSIG'};
                nb_Admis = length(admissible_VAR_Names);
                for k = 1:nb_Admis
                    varNam = admissible_VAR_Names{k};
                    idx = find(strcmp(dataInfoCell(1,:),varNam));
                    if ~isempty(idx) , break; end
                end
                if isempty(idx)
                    if nargin==4 , return; end
                    idx = 1;
                end
                varNam = dataInfoCell{1,idx};
                data   = load(fullName,'-mat');
                IdxCLU = data.(varNam);
            catch %#ok<*CTCH>
                err = 1;
            end
            if err, return; end
        else
            [IdxCLU,fullName,ok] = wtbximport('part');
            if ~ok , return; end
        end
        
        if isa(IdxCLU,'wpartobj')
            flgOBJ = true;
            nbLoaded = length(IdxCLU);
            nbSIG_LOAD = length(get(IdxCLU(1),'IdxCLU'));
        else
            flgOBJ = false;
            nbLoaded = size(IdxCLU,2);
            nbSIG_LOAD = size(IdxCLU,1);
        end
        data_ORI = wtbxappdata('get',fig,'data_ORI');
        nbSIG_ORI = data_ORI.nbSIG;
        if ~isequal(nbSIG_LOAD,nbSIG_ORI)
            WarnStr = getWavMSG('Wavelet:mdw1dRF:Invalid_Sig_Number');
            uiwait(msgbox(WarnStr, ...
                getWavMSG('Wavelet:mdw1dRF:Loading_Partitions'), ...
                'warn','modal'));
            return
        end
        [~,filename] = fileparts(fullName);
        SET_of_Partitions = wtbxappdata('get',fig,'SET_of_Partitions');
        namePartINI = [filename ' - Loaded'];
        OK = true(1,nbLoaded);
        
        for k = nbLoaded:-1:1
            if nbLoaded>1
                namePart = [namePartINI '(' int2str(k) ')'];
            else
                namePart = namePartINI;
            end
            if ~isempty(SET_of_Partitions)
                names = getpartnames(SET_of_Partitions);
                idx = find(strcmp(namePart,names));
                if ~isempty(idx)
                    quest = getWavMSG('Wavelet:mdw1dRF:Replace_Part',names{idx});
                    Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
                    Str_No  = getWavMSG('Wavelet:commongui:Str_No');
                    answer = questdlg(quest, ...
                        getWavMSG('Wavelet:mdw1dRF:Load_Partition'), ...
                        Str_Yes,Str_No,Str_No);
                    switch answer
                        case Str_Yes , OK(k) = true; SET_of_Partitions(idx) = [];
                        case Str_No ,  OK(k) = false;
                    end
                end
            end
            
            if OK(k)
                if flgOBJ
                    newPART = IdxCLU(k);
                    newPART = set(newPART,'Name',namePart);
                else
                    loaded_clu_INFO = tab2part(IdxCLU(:,k));
                    newPART = wpartobj('Name',namePart,'Method','none', ...
                        'clu_INFO',loaded_clu_INFO);
                end                
                nbPART = length(SET_of_Partitions);
                if nbPART>0
                    SET_of_Partitions(nbPART+1) = newPART;
                    SET_of_Partitions = SET_of_Partitions([end,1:nbPART]);
                else
                    SET_of_Partitions = newPART;
                end
                
            end
        end
        
        if any(OK)
            wtbxappdata('set',fig,'SET_of_Partitions',SET_of_Partitions);
            Set_Clear_PART_Menu(caller,'On')
            Set_Pus_IMPORT(fig,'On')
            Set_MoreOn_PART_BTN(caller,'On')
            str1 = getWavMSG('Wavelet:mdw1dRF:Msg_StorePart_1',filename);
            str2 = getWavMSG('Wavelet:mdw1dRF:Msg_StorePart_2');
            WarnStr = {str1 str2};
            uiwait(msgbox(WarnStr,getWavMSG('Wavelet:mdw1dRF:Load_Partition'), ...
                'warn','modal'));
        end

    case 'clear_PART'
        typeCALL = varargin{1};
        caller = varargin{2};
        if isequal(typeCALL,'ORI')
            fig = caller;
        else
            fig = blockdatamngr('get',caller,'fig_Storage','callingFIG');
        end
        switch typeCALL
            case {'ORI','CLU'}
                idxPART = mdw1dpartmngr('clear',fig);
                if isempty(idxPART) || isequal(idxPART,0) , return; end
                msgSTR = getWavMSG('Wavelet:mdw1dRF:Clear_PART');
                titSTR = getWavMSG('Wavelet:mdw1dRF:Clear_Sel_Part');
                Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
                Str_No  = getWavMSG('Wavelet:commongui:Str_No');
                answer = questdlg(titSTR ,msgSTR,Str_Yes,Str_No,Str_No);
                switch answer
                    case Str_Yes
                    case Str_No  , return
                end
                
            case 'PUS'
                idxPART = varargin{3};
        end
        reset_IMPORT(fig,idxPART);
        SET_of_Partitions = wtbxappdata('get',fig,'SET_of_Partitions');
%         % Do not clear the current partition.
%         partNAMES = getpartnames(SET_of_Partitions);
%         partNAMES = partNAMES(idxPART);
%         idxCUR = find(strcmp(partNAMES, ...
%               getWavMSG('Wavelet:moreMSGRF:Curr_Part')),1);
%         if ~isempty(idxCUR) , idxPART(idxCUR) = []; end
        SET_of_Partitions(idxPART) = [];
        wtbxappdata('set',fig,'SET_of_Partitions',SET_of_Partitions);
        noPART_Flag = isempty(SET_of_Partitions);
        
        if noPART_Flag
            Set_Pus_IMPORT(fig,'Off');
            Set_Clear_PART_Menu(fig,'Off')
            Set_MoreOn_PART_BTN(caller,'Off')
            if ~isequal(typeCALL,'ORI')
                current_PART = wtbxappdata('get',caller,'current_PART');
                if ~isempty(current_PART)
                    current_PART = set(current_PART, ...
                        'Name',getWavMSG('Wavelet:moreMSGRF:Curr_Part'));
                end
                wtbxappdata('set',caller,'current_PART',current_PART);
            end
        end
        varargout{1} = noPART_Flag;
                
    case 'store_PART'
        handles = varargin{1};
        visPAN = get(handles.Pan_PART_MNGR,'Visible');
        typeSTO = isequal(lower(visPAN(1:2)),'on');
        fig = handles.Current_Fig;
        prompt = {getWavMSG('Wavelet:mdw1dRF:Enter_Nam_Part')};
        name   = getWavMSG('Wavelet:mdw1dRF:Store_A_Partition');        
        numlines = 1;
        callingFIG = blockdatamngr('get',fig,'fig_Storage','callingFIG');
        SET_of_Partitions = wtbxappdata('get',callingFIG,'SET_of_Partitions');
        nbPART = length(SET_of_Partitions);
        if nbPART==0 && typeSTO==0
            clear SET_of_Partitions;
            defaultanswer = {'Part. #1'};
        else
            names = getpartnames(SET_of_Partitions);
            new_NUM = [];
            for k = 1:nbPART
                idx = find(strcmp(['Part. #' int2str(k)],names));
                if isempty(idx) , new_NUM = k; break; end
            end
            if isempty(new_NUM) ,  new_NUM = nbPART + 1; end
            defaultanswer = {['Part. #' int2str(new_NUM)]};
        end
        answer = inputdlg(prompt,name,numlines,defaultanswer,'on');
        varargout{1} = 0;
        
        if ~isempty(answer)
            item = answer{1};
            if nbPART>typeSTO
                idx = find(strcmp(item,names));
            end
            if nbPART==typeSTO || isempty(idx)
                newPart = true;
                nbPART = nbPART+1-typeSTO;
                idx = nbPART;
            else
                titSTR = getWavMSG('Wavelet:mdw1dRF:Store_Partition');
                partNAME = get(SET_of_Partitions(idx),'Name');
                msgSTR = [partNAME ' exists.'];
                status = wwaitans({fig,titSTR},msgSTR,2,'Cancel');
                switch status
                    case -1 , return;
                    case  0 , return;
                    case  1 , newPart = false;
                end
            end

            if typeSTO==0
                current_PART = wtbxappdata('get',fig,'current_PART');
                current_PART = set(current_PART,'Name',answer{1});
                SET_of_Partitions(idx) = current_PART;
            else
                SET_of_Partitions(nbPART) = ...
                    set(SET_of_Partitions(nbPART),'Name',item);
                if ~newPart
                    part_NAME = get(SET_of_Partitions(idx),'Name');
                    SET_of_Partitions(nbPART) = ...
                        set(SET_of_Partitions(nbPART),'Name',part_NAME);
                    SET_of_Partitions(idx) = SET_of_Partitions(nbPART);
                    SET_of_Partitions(end) = [];
                    nbPART = nbPART-1;
                end
                current_PART = SET_of_Partitions(idx);
            end
            wtbxappdata('set',fig,'current_PART',current_PART);
            wtbxappdata('set',callingFIG,'SET_of_Partitions',SET_of_Partitions);
            if  typeSTO==1
                part_NAMES = cell(nbPART,1);
                for k = 1:nbPART
                    part_NAMES(k) = {get(SET_of_Partitions(k),'Name')};
                end
                set(handles.Lst_LST_PART,'String',part_NAMES);
            end
            set(handles.Pus_PART_STORE,'Enable','Off');
            Set_Clear_PART_Menu(fig,'On')
            Set_Pus_IMPORT(fig,'On')
            varargout{1} = 1; 
        end
        
    case 'import_PART'
        handles = varargin{1};
        fig = handles.Current_Fig;
        
        PART_Import_ATTR = wtbxappdata('get',fig,'PART_Import_ATTR');
        idxPART_Import = idx_IMPORT_PART(fig);
        idxPART_Import = mdw1dpartmngr('import',fig,idxPART_Import);
        switch idxPART_Import
            case -1
                exitFLAG = false; PART_Import_ATTR = []; idxPART_Import = [];
            case 0 
                exitFLAG = true;  PART_Import_ATTR = []; idxPART_Import = [];
            otherwise
                exitFLAG = false;
                callingFIG = ...
                    blockdatamngr('get',fig,'fig_Storage','callingFIG');
                SET_of_Partitions = ...
                    wtbxappdata('get',callingFIG,'SET_of_Partitions');
                names = getpartnames(SET_of_Partitions);
                PART_Import_ATTR.name = names{idxPART_Import};
        end
        if exitFLAG , return; end 
        wtbxappdata('set',fig,'PART_Import_ATTR',PART_Import_ATTR);
        tool_NAME = blockdatamngr('get',fig,'tool_ATTR','Name');
        tool_STATE = blockdatamngr('get',fig,'tool_ATTR','State');
        hOBJ = handles.Pus_IMPORT;
        if ~isequal(tool_STATE,'INI')
            argCELL = {hOBJ,[],handles,'importCLU',idxPART_Import};
            switch tool_NAME
                case {'ORI','CMP','DEN','STA','CLU'}
                    mdw1dafflst(tool_NAME,argCELL{:});
            end
        else
            mdw1dafflst('INI',hOBJ,[],handles,'init','not_INI')
        end
        
    case 'Set_Pus_IMPORT'
        Set_Pus_IMPORT(varargin{:})
        
    case 'idx_IMPORT_PART'
        [A,B] = idx_IMPORT_PART(varargin{1});
        varargout = {A,B};
end
%=========================================================================%



%=========================================================================%
%                       BEGIN Local Tool Utilities                        %
%                       --------------------------                        %
%=========================================================================%
function reset_IMPORT(fig,idxPART)

H = guidata(fig);
WfigPROP  = H.WfigPROP;
tool_Name = H.tool_ATTR.Name;
if ~isequal(tool_Name,'ORI')
    fig = WfigPROP.FigParent;
    H = guidata(fig);
    WfigPROP  = H.WfigPROP;
end    
tool_STATE = blockdatamngr('get',fig,'tool_ATTR','State');
idx_IMPORT = idx_IMPORT_PART(fig);
if ~isempty(idx_IMPORT) && ismember(idx_IMPORT,idxPART)
    wtbxappdata('set',fig,'PART_Import_ATTR',[]);
    hOBJ = H.Pus_IMPORT;
    if ~isequal(tool_STATE,'INI')
        mdw1dafflst('ORI',hOBJ,[],H,'importCLU',[]);
    else
        mdw1dafflst('INI',hOBJ,[],H,'init','not_INI')
    end
end
FigChild = WfigPROP.FigChild;
if ~isempty(FigChild)
    for k = 1:length(FigChild)
        child = FigChild(k);
        if ishandle(child)
            H = guidata(child);
            if isfield(H,'Pus_IMPORT')
                tool_NAME = blockdatamngr('get',child,'tool_ATTR','Name');
                tool_STATE = blockdatamngr('get',child,'tool_ATTR','State');
                idx_IMPORT = idx_IMPORT_PART(child);
                if ~isempty(idx_IMPORT) && ismember(idx_IMPORT,idxPART)
                    wtbxappdata('set',child,'PART_Import_ATTR',[]);
                    hOBJ = H.Pus_IMPORT;
                    if ~isequal(tool_STATE,'INI')
                        mdw1dafflst(tool_NAME,hOBJ,[],H,'importCLU',[]);
                    else
                        mdw1dafflst('INI',hOBJ,[],H,'init','not_INI')
                    end
                end
            end
        end
    end
end
%--------------------------------------------------------------------------
function [idx_IMPORT,Part] = idx_IMPORT_PART(fig)

PART_Import_ATTR = wtbxappdata('get',fig,'PART_Import_ATTR');
if ~isempty(PART_Import_ATTR)
    namePART_Import = PART_Import_ATTR.name;
    mainFIG = blockdatamngr('get',fig,'fig_Storage','callingFIG');
    SET_of_Partitions = ...
        wtbxappdata('get',mainFIG,'SET_of_Partitions');
    names = getpartnames(SET_of_Partitions);
    idx_IMPORT = find(strcmp(namePART_Import,names));
    if ~isempty(idx_IMPORT)
        Part = SET_of_Partitions(idx_IMPORT);
    else
        Part = [];
    end
else
    idx_IMPORT = [];
    Part = [];
end
%--------------------------------------------------------------------------
function Set_Pus_IMPORT(fig,enaVAL)

H = guidata(fig);
WfigPROP  = H.WfigPROP;
tool_Name = H.tool_ATTR.Name;
if ~isequal(tool_Name,'ORI')
    fig = WfigPROP.FigParent;
    H = guidata(fig);
    WfigPROP = H.WfigPROP;
end    
Pus_IMPORT = H.Pus_IMPORT;
if  strcmpi(enaVAL,'Off')
    % wtbxappdata('set',fig,'PART_Import_ATTR',[]);
end
FigChild = WfigPROP.FigChild;
if ~isempty(FigChild)
    for k = 1:length(FigChild)
        child = FigChild(k);
        if ishandle(child)
            H = guidata(child);
            if isfield(H,'Pus_IMPORT')
                Pus_IMPORT = [Pus_IMPORT ,  H.Pus_IMPORT]; %#ok<AGROW>
                if  strcmpi(enaVAL,'Off')
                    % wtbxappdata('set',child,'PART_Import_ATTR',[]);
                end
            end
        end
    end
end
set(Pus_IMPORT,'Enable',enaVAL)
%--------------------------------------------------------------------------
function Set_MoreOn_PART_BTN(fig,enaVAL)

H = guidata(fig);
WfigPROP  = H.WfigPROP;
tool_Name = H.tool_ATTR.Name;
switch tool_Name
    case 'ORI'
        FigChild  = WfigPROP.FigChild;
        OKFig = [];
        if ~isempty(FigChild)
            for k = 1:length(FigChild)
                child = FigChild(k);
                if ishandle(child)
                    H = guidata(child);
                    if isequal(H.tool_ATTR.Name,'CLU');
                        OKFig = child; break
                    end
                end
            end
        end
        
    case 'CLU'
        OKFig = 1;
end
if ~isempty(OKFig) , set(H.Pus_PART_MNGR,'Enable',enaVAL); end
%--------------------------------------------------------------------------
function Set_Clear_PART_Menu(fig,enaVAL)

H = guidata(fig);
WfigPROP  = H.WfigPROP;
tool_Name = H.tool_ATTR.Name;
hdl_Menus = wtbxappdata('get',fig,'hdl_Menus');
m_clear_PART = hdl_Menus.m_clear_PART;
switch tool_Name
    case 'ORI'
        FigChild  = WfigPROP.FigChild;
        OtherFig = [];
        if ~isempty(FigChild)
            for k = 1:length(FigChild)
                child = FigChild(k);
                if ishandle(child)
                    H = guidata(child);
                    if isequal(H.tool_ATTR.Name,'CLU');
                        OtherFig = child; break
                    end
                end
            end
        end
        
    case 'CLU'
        OtherFig = WfigPROP.FigParent;
end
if ~isempty(OtherFig)
    hdl_Menus = wtbxappdata('get',OtherFig,'hdl_Menus');
    m_clear_PART = [m_clear_PART , hdl_Menus.m_clear_PART];
end
set(m_clear_PART,'Enable',enaVAL)
%=========================================================================%
