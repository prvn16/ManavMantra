function varargout = mdw1dutils(option,varargin)
%MDW1DUTILS Discrete wavelet Multisignal 1D Utilities.
%   VARARGOUT = MDW1DUTILS(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 25-Jun-2005.
%   Last Revision: 26-Sep-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

%----------------------------------------------------
% OPTION Values:
%---------------
% 'data_INFO_MNGR'
% 'get_Sig_IDENT'
% 'set_Lst_DATA'
% 'lst_Colors'
% 'line_Blink'
% 'colors'
% 'numFORMAT'
% 'get_actPART'
%----------------------------------------------------
switch option
    case 'data_INFO_MNGR'
        optMNGR   = varargin{1};
        fig       = varargin{2};
        switch optMNGR
            case 'create'
                tool_NAME  = varargin{3};
                callingFIG = varargin{4};
                
                % Creating tool_ATTRB.
                %---------------------
                h = guihandles(fig);
                if isfield(h,'Pop_Show_Mode')
                    popMode = h.Pop_Show_Mode;
                    numMode = get(popMode,'Value');
                    nbMode = length(get(popMode,'String'));
                else
                    numMode = 0; nbMode = 0;
                end
                
                tool_ATTR = struct(...
                    'Name',tool_NAME,'State','INI','VisType','SIG',...
                    'plot_MODE','unique','First_Use',true,...
                    'dispMode',[numMode nbMode] ...
                    );
                wtbxappdata('set',fig,'tool_ATTR',tool_ATTR);
                
                % Creating Part IMPORT ATTR.
                %--------------------------
                wtbxappdata('set',fig,'PART_Import_ATTR',[]);
                if isequal(tool_NAME,'ORI')
                    wtbxappdata('set',fig,'SET_of_Partitions',[]);
                end

                % Creating Info Storage.
                %-----------------------                
                switch tool_NAME
                    case 'ORI'
                        fig_ORI  = fig; create_ORI  = true;
                        fig_DorC = fig; create_DorC = true;
                        
                    case {'CMP','DEN'}
                        fig_ORI  = callingFIG; create_ORI  = false;
                        fig_DorC = fig;         create_DorC = true;
                        
                    case {'STA','CLU'}
                        fig_ORI  = callingFIG; create_ORI  = false;
                        fig_DorC = callingFIG; create_DorC = false;
                        
                    case 'PAR'
                        fig_ORI  = callingFIG; create_ORI  = true;
                        fig_DorC = callingFIG; create_DorC = false;                        
                end
                fig_SEL = fig; create_SEL = true;
                fig_Storage = struct(...
                    'callingFIG',callingFIG,'fig_ORI',fig_ORI,...
                    'fig_DorC',fig_DorC,'fig_SEL',fig_SEL);
                wtbxappdata('set',fig,'fig_Storage',fig_Storage);
                
                % Creating Data Storage.
                %-----------------------                                
                if create_ORI
                    varargout{1} = struct(...
                        'siz_INI',[],'signal',[],'dir_DEC',[],'dwtDEC',[],...
                        'Energy',[],'tab_ENER',[],...
                        'siz_ORI',[],'lenSIG',[],'nbSIG',[]);
                    wtbxappdata('set',fig_ORI,'data_ORI',varargout{1});
                end
                if create_DorC
                    if create_ORI
                        varargout{2} = struct(...
                         'typ_DorC','','signal',[],'dir_DEC',[],'dwtDEC',[],...
                         'Energy',[],'tab_ENER',[],'threshold',[]);
                    else
                        data_ORI = wtbxappdata('get',fig_ORI,'data_ORI');
                        level = data_ORI.dwtDEC.level;
                        varargout{2} = struct(...
                            'typ_DorC',lower(tool_NAME),  ...
                            'signal',data_ORI.signal,     ...
                            'dir_DEC',data_ORI.dir_DEC,   ...
                            'dwtDEC',data_ORI.dwtDEC,     ...
                            'Energy',data_ORI.Energy,   ...
                            'tab_ENER',data_ORI.tab_ENER, ...
                            'threshold',zeros(data_ORI.siz_ORI(2),level));
                    end
                    wtbxappdata('set',fig_DorC,'data_DorC',varargout{2});
                end
                if create_SEL
                    if ~create_ORI
                        data_ORI = wtbxappdata('get',callingFIG,'data_ORI');
                        sel_DAT  = data_ORI.signal;
                    else
                        sel_DAT = [];
                    end
                    varargout{3} = struct('sel_DAT',sel_DAT,'Attrb_SEL',[]);
                    wtbxappdata('set',fig_SEL,'data_SEL',varargout{3});
                end
                
            case 'init'
                siz_INI    = varargin{3};
                sig_ORI    = varargin{4};
                dir_DEC    = varargin{5};
                flag_TRANS = varargin{6};
                if flag_TRANS , sig_ORI = sig_ORI'; end
                siz_ORI = size(sig_ORI);
                [nbSIG,lenSIG]= size(sig_ORI);
                data_ORI = struct(...
                    'siz_INI',siz_INI,...
                    'signal',sig_ORI,'dir_DEC',dir_DEC,'dwtDEC',[],...
                    'Energy',[],'tab_ENER',[],...
                    'siz_ORI',siz_ORI,'lenSIG',lenSIG,'nbSIG',nbSIG);
                data_DorC = struct('typ_DorC','',...
                    'signal',[],'dir_DEC',dir_DEC,'dwtDEC',[],...
                    'Energy',[],'tab_ENER',[],'threshold',[]);
                data_SEL  = struct('sel_DAT',sig_ORI,'Attrb_SEL',[]);
                mdw1dutils('data_INFO_MNGR','set',fig,...
                    'ORI',data_ORI,'DorC',data_DorC,'SEL',data_SEL);
                varargout{1} = lenSIG;
                
            case 'reset'
                data_ORI = wtbxappdata('get',fig,'data_ORI');
                data_ORI.dwtDEC = varargin{3};
                data_ORI.Energy = varargin{4};
                data_ORI.tab_ENER = varargin{5};
                data_DorC = struct('typ_DorC','',...
                    'signal',[],'dir_DEC',data_ORI.dir_DEC,'dwtDEC',[],...
                    'Energy',[],'tab_ENER',[],'threshold',[]);
                data_SEL = struct('sel_DAT',data_ORI.signal,'Attrb_SEL',[]);
                mdw1dutils('data_INFO_MNGR','set',fig,...
                    'ORI',data_ORI,'DorC',data_DorC,'SEL',data_SEL);
                
            case 'get'
                fig_Storage = wtbxappdata('get',fig,'fig_Storage');
                nbIN   = length(varargin);
                idxOUT = 1;
                varargout = cell(1,nbIN-2);
                for k = 3:nbIN
                    strARG = varargin{k};
                    f_data = fig_Storage.(['fig_' strARG]);
                    n_data = ['data_' strARG];
                    varargout{idxOUT} = wtbxappdata('get',f_data,n_data);
                    idxOUT = idxOUT + 1;
                end

            case 'set'
                fig_Storage = wtbxappdata('get',fig,'fig_Storage');
                nbIN   = length(varargin);
                for k = 3:2:nbIN
                    strARG = varargin{k};
                    f_data = fig_Storage.(['fig_' strARG]);
                    n_data = ['data_' strARG];
                    wtbxappdata('set',f_data,n_data,varargin{k+1});
                end
            
            case 'save'
                fig_Storage = wtbxappdata('get',fig,'fig_Storage');
                callingFIG = fig_Storage.callingFIG;
                f_data = fig_Storage.fig_DorC;
                n_data = 'data_DorC';
                data_DorC = wtbxappdata('get',f_data,n_data);
                wtbxappdata('set',callingFIG,n_data,data_DorC);
        end
        
    case 'get_Sig_IDENT' 
        % typVAL and typVAL_Num
        %----------------------
        % 's' = 0; 'a' = 1; 'd' = 2; 'ca' = 3; 'cd' = 4;
        %---------------------------------------------------
        % typSIG and typSIG_Num 
        %----------------------
        % 'ori' = 0; 'den' = 1; 'cmp' = 2; 'res' = 3;
        %------------------------------------------------------------------
        % Attrb_Lst_In_SEL = [num_SEL,num_SIG,typVAL_Num,levVAL,typSIG_Num];
        %------------------------------------------------------------------
        fig = varargin{1};
        Attrb_Lst_In_SEL = wtbxappdata('get',fig,'Attrb_Lst_In_SEL');
        if length(varargin)<2
            idxSEL = wtbxappdata('get',fig,'idxSIG_Plot');
        elseif isnumeric(varargin{2})
            idxSEL = varargin{2};
        else
            idxSEL = 1:size(Attrb_Lst_In_SEL,1);
        end
        nbSEL  = length(idxSEL);
        Attrb_Lst = Attrb_Lst_In_SEL(idxSEL,:);        
        numDwtType = Attrb_Lst(:,3);
        numSigType = Attrb_Lst(:,5);
        typeSIG = {'o','d','c','r'};
        typeDWT = {'S','A','D','a','d'};
                
        sigType = repmat(typeSIG{1},nbSEL,1);        
        for k = 1:3
            idx = numSigType==k;
            if any(idx) , sigType(idx,:) = typeSIG{k+1}; end
        end

        dwtType = repmat(typeDWT{1},nbSEL,1);        
        for k = 1:4
            idx = numDwtType==k;
            if any(idx) , dwtType(idx,:) = typeDWT{k+1}; end
        end
        
        switch nargout
            case 1
                varargout{1} = [Attrb_Lst(:,2),dwtType,sigType,Attrb_Lst(:,4)];
            case 2
                varargout = {dwtType,sigType};
            otherwise
                varargout = {Attrb_Lst(:,2),dwtType,sigType,Attrb_Lst(:,4)};

        end
        
    case 'set_Lst_DATA'
        handles = varargin{1};
        mode    = varargin{2};
        switch mode
            case 'init'
                item = getWavMSG('Wavelet:mdw1dRF:Orig_Signals');
            case 'reset'  , 
                item = getWavMSG('Wavelet:mdw1dRF:Orig_Signals');
                lst = handles.Lst_SIG_DATA; tool = 'NON';
            case 'select' , 
                [item,lst,tool] = deal(varargin{3:5});
        end        
        set(handles.Edi_Selected_DATA,'String',{item});
        
        switch mode
            case 'init'
                set(handles.Lst_SIG_DATA,'Value',1)

            case {'reset','select'}
                Edi_FCol = get(lst,'ForegroundColor');
                h2Color = [...
                    handles.Edi_Selected_DATA,handles.Edi_TIT_VISU_DEC,...
                    handles.Edi_TIT_SEL,handles.Edi_TIT_VISU];
                switch tool
                    case 'ORI' , h2Color = [h2Color , handles.Edi_TIT_PAN_INFO];
                    case 'STA' , h2Color = [h2Color , handles.Edi_TIT_STA];
                end
                set(h2Color,'ForegroundColor',Edi_FCol);
        end

    case 'lst_Colors'
        varargout{1} = struct('sig',[170 100 20]/255,'cfs',[15 130 130]/255);
        
    case 'line_Blink'
        hLine = varargin{1};
        try %#ok<*TRYNC>
            for k = 1:2
                set(hLine,'Visible','Off'); pause(0.15);
                set(hLine,'Visible','On');  pause(0.20);
            end
        end
        
    case 'colors'
        % syn_COL = [1 0.9 0]/1.075;     
        syn_COL = [1 0 1]/1.05;
        res_COL = [1 0.70 0.28]/1.1;
        % thr_COL = 0.3*[1 1 1];
        thr_COL = [128 64 0]/255;
        
        varargout{1} = struct(...
            'sig',[1 0 0],'app',[0 0 1],'det',[0 1 0],    ...
            'den',syn_COL,'cmp',syn_COL,'d_OR_c',syn_COL, ...
            'res',res_COL,'thr',thr_COL,'tLD',[1 0 0],   ...
            'N0',[1 0 0.8]/1.2,'L2',[0 0 1]/1.2);
        if isempty(varargin) , return; end
        type = varargin{1};
        if isequal(type,'all')
            tmp = struct2cell(varargout{1});
            varargout{1} = cat(1,tmp{:});
        else
            varargout{1} = varargout{1}.(type);
        end
        if length(varargin)>1 , varargout{1} = 0.8*varargout{1}; end

    case 'LinW'
        LinW.N0 = 1;
        LinW.L2 = 1;
        LinW.THR = 2;
        varargout = {LinW};
        
    case 'numFORMAT'
        nbIN = length(varargin);
        formatNum_Ener = '%0.4g';
        formatPER = '%6.2f%%';
        switch nbIN
            case 0
                intFormat = '%3.0f';
                formatNum = '%8.3f';
                formatSTR = '%4.0f';
                varargout = ...
                    {formatNum,formatPER,formatNum_Ener,...
                     intFormat,formatSTR};

            case 1
                if isnumeric(varargin{1});
                    maxVAL = double(varargin{1});
                    if maxVAL>0
                        nb_digit = ceil(log10(maxVAL));
                    else
                        nb_digit = 3;
                    end
                    if nb_digit<=-1 , nb_digit = -1; end
                    switch nb_digit
                        case {-1,0,1,2} , formatNum = '%9.3f';    
                        case 3 ,       formatNum = '%9.3f';
                        case 4 ,       formatNum = '%9.3f';
                        otherwise ,    formatNum = formatNum_Ener;
                    end
                    varargout = {formatNum,formatPER,formatNum_Ener};
                else % Scientific format
                    varargout = {formatNum_Ener};
                end
        end

    case 'get_actPART'
        fig = varargin{1};
        act_PART = wtbxappdata('get',fig,'active_PART');
        act_PART_FLAG = ~isempty(act_PART);
        if ~act_PART_FLAG
            act_PART = blockdatamngr('get',fig,'current_PART');
        end
        varargout = {act_PART,act_PART_FLAG};
end
