function varargout = mdw1dafflst(option,varargin)
%MDW1DAFFLST Discrete wavelet Multisignal 1D Utilities.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 27-Jun-2005.
%   Last Revision 11-Jul-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $ $Date: 2013/08/23 23:45:41 $

% Dispatch Main Options.
%=======================
% Valid options:
%---------------
%   'INI','ORI','CMP','DEN','STA','CLU'
%   'DAT'
%   'get_idxSEL'
%=======================================

blanc = ' '; mark  = '*';
nbMaxCLU_AFF = 12;

switch option
    case {'INI','ORI','CMP','DEN','STA','CLU','PAR'}

        % Check input.
        %-------------
        [hObject,eventdata,handles,aff_OPT] = deal(varargin{1:4});
        fig = handles.Current_Fig;

        % String utilities.
        %-----------------
        sep   = ' | ';    sep2  = ' || ';
        star  = ' |> ';   star2 = ' ||> ';
        
        
        % Numeric format utilities.
        %-------------------------
        [formatNum,formatPER,formatNum_Ener,intFormat,formatSTR] = ...
            mdw1dutils('numFORMAT');

        % Begin waiting.
        %---------------
        wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitCompute'));

        nbIN = length(varargin);
        if ~isequal(aff_OPT,'sort')
            asc_SORT = 1;
            col_SORT = 1;
            nextArg  = 5;
        else
            asc_SORT = varargin{5};
            col_SORT = get(handles.Pop_SORT,'Value');
            nextArg  = 6;
        end
        flag_ONE = get(handles.Chk_AFF_MUL,'Value');
        if ~isequal(option,'PAR')
            [data_ORI,data_SEL,data_DorC] = ...
                mdw1dutils('data_INFO_MNGR','get',fig,'ORI','SEL','DorC');
        else
            [data_ORI,data_SEL] = ...
                mdw1dutils('data_INFO_MNGR','get',fig,'ORI','SEL');
        end
        nbSigInSEL = size(data_SEL.sel_DAT,1);

        switch option
            case 'INI' , aff_LST_INI(varargin{nextArg:end});
            case 'ORI' , aff_LST_ORI;
            case 'CMP' , aff_LST_CMP(varargin{nextArg:end});
            case 'DEN' , aff_LST_DEN(varargin{nextArg:end});
            case 'STA' , aff_LST_STA;
            case 'CLU' , aff_LST_CLU(varargin{nextArg:end},option);
            case 'PAR' , aff_LST_CLU(varargin{nextArg:end},option);
        end
        if ~isequal(option,'CLU') || ~isequal(option,'STA') || ...
           ~isequal(option,'PAR')
            if flag_ONE
                STR_VAL = set_LST_MARK(STR_VAL);
                max_LST = 1; val_LST = 1;
            else
                max_LST = 2;
                if ~isequal(aff_OPT,'sort') && nextArg<=nbIN && ...
                    isequal(varargin{nextArg},'KeepSelected')
                    val_LST = get(handles.Lst_SEL_DATA,'Value');
                else
                    val_LST = [];
                end
            end
            
            %%% A VOIR DEB %%%
            if exist('STR_VAL','var') && ~isempty(STR_VAL)
                set(handles.Lst_SEL_DATA,'Max',max_LST,'Value',val_LST,...
                    'String',STR_VAL);
            end
            %%% A VOIR FIN %%%
            
        end

        % End waiting.
        %-------------
        wwaiting('off',fig);

    case 'DAT' ,        aff_LST_DAT(varargin{:});
    case 'MARK',        aff_LST_MARK(varargin{:});
    case 'get_idxSEL' , varargout{1} = get_idxSEL(varargin{:});
end
%--------------------------------------------------------------------------
    function aff_LST_INI(varargin)

        switch aff_OPT
            case 'init'
                wtbxappdata('set',fig,'type_AFF_ALL',{'init',0});
                returnFLAG = true;

            case 'sort'
                returnFLAG = false;
        end
        flag_CLU_Import = 0;

        if nbSigInSEL>0
            [num_SEL,num_SIG,typVAL,typVAL_Num,levVAL,typSIG,typSIG_Num,...
                IdxCLU] = get_Attrb_Lst_In_SEL;
            
            flag_CLU_Import = ~(isempty(IdxCLU) || isequal(IdxCLU,0));
            if flag_CLU_Import
                tab_INFO = ...
                    [num_SEL ,num_SIG ,IdxCLU, typVAL_Num,levVAL,typSIG_Num];
                last = 3;
            else
                tab_INFO = [num_SEL ,num_SIG ,typVAL_Num,levVAL,typSIG_Num];
                last = 2;
            end
            [tab_INFO,idxSORT] = sortDATA(tab_INFO,col_SORT,asc_SORT);
            typVAL = typVAL(idxSORT,:);
            typSIG = typSIG(idxSORT,:);
            blanc  = blanc(ones(nbSigInSEL,1),:);
            sep = sep(ones(nbSigInSEL,1),:);
            STR_VAL = blanc;
            for k = 1:last
                STR_VAL = [STR_VAL , num2str(tab_INFO(:,k),formatSTR)]; 
                if k==3 && flag_CLU_Import 
                    STR_VAL = [STR_VAL , sep2(ones(nbSigInSEL,1),:);]; 
                else
                    STR_VAL = [STR_VAL , sep]; 
                end
                
            end            
            STR_VAL = [STR_VAL ,  ...
                typVAL                                  sep , ...
                num2str(tab_INFO(:,last+2),formatSTR),  sep , ...
                typSIG,                                 sep   ...
                ];
            if nbSigInSEL==1 , STR_VAL = {STR_VAL}; end
        else
            STR_VAL = {};
        end
        
        if returnFLAG || flag_CLU_Import
            str_DATA = 'Sel | Sig |';
            str_POP  = {getWavMSG('Wavelet:mdw1dRF:Idx_Sel'); ...
                getWavMSG('Wavelet:mdw1dRF:Idx_Sig')};
            if flag_CLU_Import
                str_DATA = [str_DATA ' Clu ||'];
                str_POP  = [str_POP;getWavMSG('Wavelet:mdw1dRF:Idx_Clu')];
            end
            str_DATA = [str_DATA , ' Dw | L | Typ |'];
            str_POP  = [str_POP ;  ...
                getWavMSG('Wavelet:mdw1dRF:Dwt_Attr'); ...
                getWavMSG('Wavelet:mdw1dRF:Level_L'); ...
                getWavMSG('Wavelet:mdw1dRF:Type_Sig')];
            set(handles.Txt_SEL_DATA,'String',str_DATA, ...
                'TooltipString',Make_ToolTipString(str_POP));
            set(handles.Pop_SORT,'String',str_POP,'Value',2)
            set(handles.Edi_NB_SIG,'ForegroundColor','k')
        end
        if ~isequal(aff_OPT,'sort')
            setStrNbSIG(handles.Edi_NB_SIG,nbSigInSEL)
        end
    end
%--------------------------------------------------------------------------
    function aff_LST_ORI

        [num_SEL,num_SIG,typVAL,typVAL_Num,levVAL,typSIG,typSIG_Num,IdxCLU] = ...
            get_Attrb_Lst_In_SEL;
        flag_CLU_Import = ~(isempty(IdxCLU) || isequal(IdxCLU,0));
        level = data_ORI.dwtDEC.level;
        nbINFO = level+2;
        sig_SELECT = data_SEL.sel_DAT;

        Attrb_SEL = data_SEL.Attrb_SEL;
        if isempty(Attrb_SEL) , Attrb_SEL = {0,{'s'},0}; end
        flag_SIG_SEL = ~isempty(Attrb_SEL);

        switch aff_OPT
            case {'init','importCLU'}
                wtbxappdata('set',fig,'type_AFF_ALL',{'init',0});
                str_DATA = 'Sel | Sig |';
                str_POP  = {getWavMSG('Wavelet:mdw1dRF:Idx_Sel');getWavMSG('Wavelet:mdw1dRF:Idx_Sig')};
                if flag_CLU_Import
                    str_DATA = [str_DATA , ' Clu ||'];
                    str_POP  = [str_POP ; getWavMSG('Wavelet:mdw1dRF:Idx_Clu')];
                end
                AppSTR = ['| EP A' int2str(level) ' |'];
                str_DATA = [str_DATA , ' Dw | L | Typ |' AppSTR];
                str_POP  = [str_POP;...
                    getWavMSG('Wavelet:mdw1dRF:Dwt_Attr'); ...
                    getWavMSG('Wavelet:mdw1dRF:Level_L'); ...
                    getWavMSG('Wavelet:mdw1dRF:Type_Sig'); ...
                    ['A' int2str(level) '-EnerPer']];
                if flag_SIG_SEL
                    for k=1:level
                        lev    = nbINFO-1-k;
                        levSTR = int2str(lev);
                        str_DATA = [str_DATA , ' EP D', levSTR ,  ' |']; 
                        str_POP  = [str_POP;['D' levSTR '-EnerPer']]; %#ok<*AGROW>
                    end
                    str_DATA = [str_DATA ,' Energy |'];
                    str_POP  = [str_POP ; ...
                        getWavMSG('Wavelet:mdw1dRF:Energy')];
                end
                val_POP = 2;

            case 'sort'
                val_POP = col_SORT;
        end
        nbINFO   = 0;
        Energy  = [];
        tab_ENER = [];
        if flag_SIG_SEL
            num_typeSIG = Attrb_SEL{1};
            typeSIG = Attrb_SEL{2};
            flagSIG = all(cat(2,typeSIG{:})=='s') && ...
                all(num_typeSIG==0 | num_typeSIG==1 | num_typeSIG==2) ;
            if flagSIG
                for k = 1:length(num_typeSIG)
                    if num_typeSIG(k)==0
                        callingFIG = blockdatamngr('get',fig, ...
                            'fig_Storage','callingFIG');
                        [Energy,tab_ENER] = blockdatamngr('get',...
                            callingFIG,'data_ORI','Energy','tab_ENER');
                    elseif num_typeSIG(k)==1 || num_typeSIG(k)==2
                        [L2_DorC,tab_ENER_DorC] = blockdatamngr('get',...
                            fig,'data_DorC','Energy','tab_ENER');
                        Energy  = [Energy  ; L2_DorC]; 
                        tab_ENER = [tab_ENER ; tab_ENER_DorC]; 
                    end
                end
                nbINFO = 1+size(tab_ENER,2);
            end
        end
        
        tab_INFO = [num_SEL , num_SIG];
        if flag_CLU_Import , tab_INFO = [tab_INFO , IdxCLU]; end
        lastINFO = size(tab_INFO,2);
        first = lastINFO+1;
        tab_INFO = [...
            tab_INFO , typVAL_Num , levVAL , typSIG_Num , tab_ENER , Energy];
        [tab_INFO,idxSORT] = sortDATA(tab_INFO,col_SORT,asc_SORT);

        oneIDX = ones(nbSigInSEL,1);
        blanc = blanc(oneIDX,:);
        sep   = sep(oneIDX,:);
        star  = star(oneIDX,:);
        STR_VAL = blanc;
        for k = 1:lastINFO-1
            STR_VAL = [STR_VAL  , num2str(tab_INFO(:,k),intFormat) , sep]; 
        end
        STR_VAL = [STR_VAL  , num2str(tab_INFO(:,lastINFO),intFormat)];
        if col_SORT~=first
            if ~flag_CLU_Import
                STR_VAL = [STR_VAL , sep];
            else
                STR_VAL = [STR_VAL , sep2(oneIDX,:)];
            end
        else
            STR_VAL = [STR_VAL , star2(oneIDX,:)];
        end
        if col_SORT~=first+1 ,
            STR_VAL = [STR_VAL , typVAL(idxSORT,:) , sep];
        else
            STR_VAL = [STR_VAL , typVAL(idxSORT,:) , star];
        end
        if col_SORT~=first+2
            STR_VAL = [STR_VAL , num2str(tab_INFO(:,first+1),intFormat) , sep];
        else
            STR_VAL = [STR_VAL , num2str(tab_INFO(:,first+1),intFormat) , star];
        end
        if col_SORT~=first+3
            STR_VAL = [STR_VAL , typSIG(idxSORT,:) , sep2(oneIDX,:)];
        else
            STR_VAL = [STR_VAL , typSIG(idxSORT,:) , star2(oneIDX,:)];
        end
        last = size(tab_INFO,2)-nbINFO ;
        for k = first+3:last
            if k~=col_SORT-1
                STR_VAL = [STR_VAL , num2str(tab_INFO(:,k),formatNum) , sep]; 
            else
                STR_VAL = [STR_VAL , num2str(tab_INFO(:,k),formatNum) , star]; 
            end
        end
        if nbINFO>0
            for k = last+1:size(tab_INFO,2)-1
                if k~=col_SORT-1
                    STR_VAL = [STR_VAL , num2str(tab_INFO(:,k),formatPER) , sep]; 
                else
                    STR_VAL = [STR_VAL , num2str(tab_INFO(:,k),formatPER) , star]; 
                end
            end
            formatNum_Ener = '%0.4g';
            STR_VAL = [STR_VAL , num2str(tab_INFO(:,end),formatNum_Ener) , sep];
        end
        if nbSigInSEL==1 , STR_VAL = {STR_VAL}; end
        
        if ~isequal(aff_OPT,'sort')
            setStrNbSIG(handles.Edi_NB_SIG,nbSigInSEL)
            set(handles.Txt_SEL_DATA,'String',str_DATA, ...
                'TooltipString',Make_ToolTipString(str_POP));
            set(handles.Pop_SORT,'String',str_POP,'Value',val_POP)
        end

        % Show information on first selection.
        %------------------------------------
        currNum = num_SEL(1);
        currSig = sig_SELECT(1,:);
        if nbINFO>0
            set(handles.Edi_TIT_PAN_INFO,'UserData',{Energy,tab_ENER});
        end
        mdw1dtool('show_Sig_Info',hObject,eventdata,handles,currNum,currSig,1)
    end
%--------------------------------------------------------------------------
    function aff_LST_CMP(varargin)

        data_SEL.sel_DAT = data_ORI.signal;
        data_SEL.Attrb_SEL = {false,{'s'},0};
        mdw1dutils('data_INFO_MNGR','set',fig,'SEL',data_SEL);        
        [num_SEL,IdxCLU] = get_Attrb_Lst_In_SEL;
        flag_CLU_Import = ~(isempty(IdxCLU) || isequal(IdxCLU,0));
        nbSigInSEL = size(data_SEL.sel_DAT,1);
        level = data_ORI.dwtDEC.level;
        thr_VAL = data_DorC.threshold;
        
        PERFO = wtbxappdata('get',fig,'cmp_PERF');
        [energyDEC_PERF,nb0_PERF] = deal(PERFO{1:2});

        switch aff_OPT
            case {'init','importCLU'}
                wtbxappdata('set',fig,'type_AFF_ALL',{'init',0});
                if flag_CLU_Import
                    str_DATA = ' Sig | Clu ||';
                    str_POP  = {getWavMSG('Wavelet:mdw1dRF:Idx_Sig'),getWavMSG('Wavelet:mdw1dRF:Idx_Clu')};
                else
                    str_DATA = ' Sig ||';
                    str_POP  = {getWavMSG('Wavelet:mdw1dRF:Idx_Sig')};
                end
                thrSTR = getWavMSG('Wavelet:mdw1dRF:Thr_Cd');
                for k=1:level
                    str_POP  = [str_POP ; thrSTR int2str(k)];
                    strTHR = ['ThrD' int2str(k)];
                    str_DATA = [str_DATA , [' ' strTHR ' |']]; 
                end
                str_DATA = [str_DATA , ' En. Rat.|' ,' NbZ Rat. |'];
                str_POP  = [ str_POP ;  ...
                    getWavMSG('Wavelet:mdw1dRF:Ener_Rat'); ...
                    getWavMSG('Wavelet:mdw1dRF:NbZero_Rat')];
                val_POP = 1;

            case 'sort'
                val_POP = col_SORT;
        end
        if flag_CLU_Import
            tab_INFO = [num_SEL , IdxCLU , thr_VAL];
        else
            tab_INFO = [num_SEL , thr_VAL];
        end
        tab_INFO = [tab_INFO , energyDEC_PERF , nb0_PERF];
        tab_INFO = sortDATA(tab_INFO,col_SORT,asc_SORT);
        nbINFO = size(tab_INFO,2);
        
        oneIDX = ones(nbSigInSEL,1);
        blanc = blanc(oneIDX,:);
        sep   = sep(oneIDX,:);
        star  = star(oneIDX,:);

        STR_VAL = [blanc , num2str(tab_INFO(:,1),intFormat)];
        if flag_CLU_Import
            first = 3;
            STR_VAL = [STR_VAL , sep , num2str(tab_INFO(:,2),intFormat)];
        else
            first = 2;
        end
        if col_SORT~=first
            STR_VAL = [STR_VAL , sep2(oneIDX,:)];
        else
            STR_VAL = [STR_VAL , star2(oneIDX,:)];
        end
        for k = first:nbINFO-2
            if k~=col_SORT-1
                STR_VAL = [STR_VAL , num2str(tab_INFO(:,k),formatNum) , sep]; 
            else
                STR_VAL = [STR_VAL , num2str(tab_INFO(:,k),formatNum) , star]; 
            end
        end
        for k = nbINFO-1:nbINFO
            if k~=col_SORT-1
                STR_VAL = ...
                    [STR_VAL , num2str(tab_INFO(:,k),formatPER) , sep]; 
            else
                STR_VAL = ...
                    [STR_VAL, num2str(tab_INFO(:,k),formatPER) , star]; 
            end
        end
        if nbSigInSEL==1 , STR_VAL = {STR_VAL}; end

        if ~isequal(aff_OPT,'sort')
            setStrNbSIG(handles.Edi_NB_SIG,nbSigInSEL)
            set(handles.Txt_SEL_DATA,'String',str_DATA, ...
                'TooltipString',Make_ToolTipString(str_POP));
            set(handles.Pop_SORT,'String',str_POP,'Value',val_POP)
        end
        mdw1dutils('set_Lst_DATA',handles,'reset')
    end
%--------------------------------------------------------------------------
    function aff_LST_DEN(varargin)

        data_SEL.sel_DAT = data_ORI.signal;
        data_SEL.Attrb_SEL = {false,{'s'},0};
        mdw1dutils('data_INFO_MNGR','set',fig,'SEL',data_SEL);        
        [num_SIG,IdxCLU] = get_Attrb_Lst_In_SEL;
        flag_CLU_Import = ~(isempty(IdxCLU) || isequal(IdxCLU,0));
        nbSigInSEL = size(data_SEL.sel_DAT,1);
        level = data_ORI.dwtDEC.level;
        thr_VAL = data_DorC.threshold;

        switch aff_OPT
            case {'init','importCLU'}
                wtbxappdata('set',fig,'type_AFF_ALL',{'init',0});
                if flag_CLU_Import
                    str_DATA = 'Sig | Clu ||';
                    str_POP  = {getWavMSG('Wavelet:mdw1dRF:Idx_Sig'),getWavMSG('Wavelet:mdw1dRF:Idx_Clu')};
                else
                    str_DATA = 'Sig ||';
                    str_POP  = {getWavMSG('Wavelet:mdw1dRF:Idx_Sig')};
                end
                
                thrSTR = getWavMSG('Wavelet:mdw1dRF:Thr_Cd');
                for k=1:level
                    str_POP  = [ str_POP , [thrSTR int2str(k)]];
                end
                if level<5
                    for k=1:level
                        strTHR =  getWavMSG('Wavelet:mdw1dRF:ThrD_Lev',k);
                        str_DATA = [str_DATA , [' ' strTHR ' |']]; 
                    end
                else
                    strTHR = getWavMSG('Wavelet:mdw1dRF:Thresholds_for',k);
                    str_DATA = [str_DATA , [' ' strTHR]]; 
                end
                val_POP = 1;

            case 'sort'
                val_POP  = col_SORT;
        end
        if flag_CLU_Import
            tab_INFO = [num_SIG , IdxCLU , thr_VAL];
        else
            tab_INFO = [num_SIG , thr_VAL];
        end
        tab_INFO = sortDATA(tab_INFO,col_SORT,asc_SORT);

        oneIDX = ones(nbSigInSEL,1);
        blanc = blanc(oneIDX,:);
        sep   = sep(oneIDX,:);
        star  = star(oneIDX,:);

        STR_VAL = [blanc , num2str(tab_INFO(:,1),intFormat)];
        if flag_CLU_Import
            first = 3;
            STR_VAL = [STR_VAL, sep(oneIDX,:) , num2str(tab_INFO(:,2),intFormat)];
        else
            first = 2;
        end
        if col_SORT~=first
            STR_VAL = [STR_VAL , sep2(oneIDX,:)];
        else
            STR_VAL = [STR_VAL , star2(oneIDX,:)];
        end
        for k = first:size(tab_INFO,2)
            if k~=col_SORT-1
                STR_VAL = [STR_VAL , num2str(tab_INFO(:,k),formatNum) , sep]; 
            else
                STR_VAL = [STR_VAL , num2str(tab_INFO(:,k),formatNum) , star]; 
            end
        end
        if nbSigInSEL==1 , STR_VAL = {STR_VAL}; end

        if ~isequal(aff_OPT,'sort')
            setStrNbSIG(handles.Edi_NB_SIG,nbSigInSEL)
            set(handles.Txt_SEL_DATA,'String',str_DATA, ...
                'TooltipString',Make_ToolTipString(str_POP));
            set(handles.Pop_SORT,'String',str_POP,'Value',val_POP)
        end
        mdw1dutils('set_Lst_DATA',handles,'reset')
    end
%--------------------------------------------------------------------------
    function aff_LST_STA
        
        [num_SEL,num_SIG,typVAL,typVAL_Num,levVAL,typSIG,typSIG_Num,IdxCLU] = ...
            get_Attrb_Lst_In_SEL;
        flag_CLU_Import = ~(isempty(IdxCLU) || isequal(IdxCLU,0));
        sig_SELECT = data_SEL.sel_DAT;
        switch aff_OPT
            case {'init','importCLU'}
                wtbxappdata('set',fig,'type_AFF_ALL',{'init',0});
                str_DATA = 'Sel | Sig |';
                str_POP  = {getWavMSG('Wavelet:mdw1dRF:Idx_Sel'),getWavMSG('Wavelet:mdw1dRF:Idx_Sig')};
                if flag_CLU_Import
                    str_DATA = [str_DATA , ' Clu |'];
                    str_POP  = [str_POP,getWavMSG('Wavelet:mdw1dRF:Idx_Clu')];
                end
                if flag_CLU_Import
                    str_DATA = [str_DATA , '| Dw | L | Typ ||' ...
                        ' mean | max | min | range | std | median |'...
                        ' MedAD | MeanAD |'];
                else
                    str_DATA = [str_DATA , '| Dw | L | Typ ||' ...
                        ' mean |  max  |  min  | range |  std  | median |'...
                        ' MedAD | MeanAD |'];
                end
                str_POP  = [str_POP,getWavMSG('Wavelet:mdw1dRF:Dwt_Attr'), ...
                    getWavMSG('Wavelet:mdw1dRF:Level_L'),...
                    getWavMSG('Wavelet:mdw1dRF:Type_Sig'),...
                    'mean','max','min','range','std','median',  ...
                    'MedAbsDev','MeanAbsDev'];
                val_POP  = 2;

            case 'sort'
                val_POP  = get(handles.Pop_SORT,'Value');
        end
        mean_VAL  = mean(sig_SELECT,2);
        max_VAL   = max(sig_SELECT,[],2);
        min_VAL   = min(sig_SELECT,[],2);
        range_VAL = max_VAL-min_VAL;
        std_VAL   = std(sig_SELECT,[],2);
        med_VAL   = median(sig_SELECT,2);
        len_SIG   = size(sig_SELECT,2);
        med_abs_dev  = median(abs(sig_SELECT-med_VAL(:,ones(1,len_SIG))),2);
        mean_abs_dev = mean(abs(sig_SELECT-mean_VAL(:,ones(1,len_SIG))),2);

        tab_INFO = [num_SEL , num_SIG];
        if flag_CLU_Import , tab_INFO = [tab_INFO , IdxCLU]; end
        lastINFO = size(tab_INFO,2);
        first = lastINFO+1;
        tab_INFO = [...
            tab_INFO , typVAL_Num , levVAL , typSIG_Num , ...
            mean_VAL , max_VAL , min_VAL , range_VAL , std_VAL , med_VAL , ...
            med_abs_dev  , mean_abs_dev];

        [~,idxSORT] = sortrows(tab_INFO,[col_SORT,1]);
        if asc_SORT==-1 , idxSORT = flipud(idxSORT); end
        tab_INFO = tab_INFO(idxSORT,:);
        oneIDX = ones(nbSigInSEL,1);
        blanc = blanc(oneIDX,:);
        sep   = sep(oneIDX,:);
        star  = star(oneIDX,:);
        STR_VAL = blanc;
        for k = 1:lastINFO-1
            STR_VAL = [STR_VAL  , num2str(tab_INFO(:,k),intFormat) , sep]; 
        end
        STR_VAL = [STR_VAL  , num2str(tab_INFO(:,lastINFO),intFormat)];
        if col_SORT~=first
            STR_VAL = [STR_VAL , sep2(oneIDX,:)];
        else
            STR_VAL = [STR_VAL , star2(oneIDX,:)];
        end
        if col_SORT~=first+1 ,
            STR_VAL = [STR_VAL , typVAL(idxSORT,:) , sep];
        else
            STR_VAL = [STR_VAL , typVAL(idxSORT,:) , star];
        end
        if col_SORT~=first+2 ,
            STR_VAL = [STR_VAL , num2str(tab_INFO(:,first+1),intFormat) , sep];
        else
            STR_VAL = [STR_VAL , num2str(tab_INFO(:,first+1),intFormat) , star];
        end
        if col_SORT~=first+3
            STR_VAL = [STR_VAL , typSIG(idxSORT,:) , sep2(oneIDX,:)];
        else
            STR_VAL = [STR_VAL , typSIG(idxSORT,:) , star2(oneIDX,:)];
        end
        for k = first+3:size(tab_INFO,2)
            formatNum = mdw1dutils('numFORMAT',max(abs(tab_INFO(:,k))));
            if k~=col_SORT-1
                STR_VAL = [STR_VAL , num2str(tab_INFO(:,k),formatNum) , sep]; 
            else
                STR_VAL = [STR_VAL , num2str(tab_INFO(:,k),formatNum) , star]; 
            end
        end
        if nbSigInSEL==1 , STR_VAL = {STR_VAL}; end
        
        if flag_ONE
            STR_VAL = set_LST_MARK(STR_VAL);
            max_LST = 1; val_LST = 1;
        else
            max_LST = 2; val_LST = [];
        end
        set(handles.Lst_SEL_DATA,'Max',max_LST,'Value',val_LST,...
            'String',STR_VAL);
        if ~isequal(aff_OPT,'sort')
            setStrNbSIG(handles.Edi_NB_SIG,nbSigInSEL)
            set(handles.Txt_SEL_DATA,'String',str_DATA, ...
                'TooltipString',Make_ToolTipString(str_POP));
            set(handles.Pop_SORT,'String',str_POP,'Value',val_POP)
        end
        mdw1dstat('Pop_TYP_GRA_Callback',handles.Pop_TYP_GRA,[],handles);
    end
%--------------------------------------------------------------------------
    function aff_LST_CLU(varargin)
        act_PART = mdw1dutils('get_actPART',fig,varargin{:});
        nbSIG_TOT = data_ORI.nbSIG;
        if isempty(nbSIG_TOT)
            nbSIG_TOT = length(get(handles.SET_of_Partitions(1),'IdxCLU'));
        end
        numSIG = (1:nbSIG_TOT)';
        if isequal(aff_OPT,'importCLU')
            [idxPART_Imp,PART_Imp] = partsetmngr('idx_IMPORT_PART',fig);
            if ~isempty(idxPART_Imp);
                IdxCLU = get(PART_Imp,'IdxCLU');
                nbSIG  = length(IdxCLU);
                idxSIG = 1:nbSIG;
            else
                mdw1dafflst('INI',handles.Lst_SEL_DATA,[],handles,'init','INI')
                return
            end
            
        elseif ~isequal(aff_OPT,'clu_SEL')
            if ~isequal(aff_OPT,'part_CLU') && ~isequal(aff_OPT,'part_CLU_B')
                IdxCLU = get(act_PART,'IdxCLU');
                nbSIG  = length(IdxCLU);
                idxSIG = 1:nbSIG;
                if ~isequal(nbSIG_TOT,nbSIG)
                    error('Wavelet:FunctionToVerify:NbSig', ...
                    '*** TO VERIFY: Number of Signals ***')
                end
            end
        end

        switch aff_OPT
            case {'init','importCLU'}
                wtbxappdata('set',fig,'type_AFF_ALL',{'init',0});

            case 'sort'
                type_AFF_ALL = wtbxappdata('get',fig,'type_AFF_ALL');
                if isequal(type_AFF_ALL{1},'clu_SEL')
                    [IdxCLU,idxSIG] = ...
                        find_tab_CLU(nbSIG_TOT,type_AFF_ALL{3},varargin{end});
                elseif isequal(type_AFF_ALL{1},'partition')
                    IdxCLU = type_AFF_ALL{2};
                    idxSIG = (1:size(IdxCLU,1))';
                else
                    idxSIG = mdw1dafflst('get_idxSEL',handles.Lst_SEL_DATA);
                    idxSIG = sort(idxSIG);
                end

            case 'clu_SEL'
                TypeSEL = varargin{1};
                [IdxCLU,idxSIG,numCLA] = ...
                    find_tab_CLU(nbSIG_TOT,TypeSEL,varargin{end});
                wtbxappdata('set',fig,'type_AFF_ALL',{'clu_SEL',numCLA,TypeSEL});
                
            case {'partition','part_CLU','part_CLU_B'}
                callingFIG = blockdatamngr('get',fig, ...
                    'fig_Storage','callingFIG');
                SET_of_Partitions = ...
                    wtbxappdata('get',callingFIG,'SET_of_Partitions');
                
                nbIN = length(varargin);
                if nbIN>0
                    idxPART = varargin{1}; 
                else
                    nbPART = length(SET_of_Partitions);
                    idxPART = (1:nbPART);
                end
                nbPART = length(idxPART);
                IdxCLU = zeros(nbSIG_TOT,nbPART);
                if ~isequal(idxPART,0)                    
                    for k = 1:nbPART
                        numPart = idxPART(k);
                        IdxCLU(:,k) = ...
                            get(SET_of_Partitions(numPart),'IdxCLU');
                    end
                end
                idxSIG = 1:nbSIG_TOT;
                wtbxappdata('set',fig,'type_AFF_ALL',{'partition',IdxCLU});
                
            case 'links'
                idxSIG = varargin{1};
                wtbxappdata('set',fig,'type_AFF_ALL',{'links',idxSIG});
                
            case 'dendro'
                type_CALL  = varargin{1};
                numCLASSES = varargin{2};
                wtbxappdata('set',fig,'type_AFF_ALL', ...
                    {[aff_OPT '_' type_CALL],numCLASSES});
                if ~isequal(type_CALL,'all')
                    idxSIG = ismember(IdxCLU,numCLASSES);
                else
                    idxSIG = ismember((1:nbSIG)',numCLASSES);
                end

            case 'kmeans'
                type_CALL  = varargin{1};
                numCLASSES = varargin{2};
                wtbxappdata('set',fig,'type_AFF_ALL', ...
                    {aff_OPT,numCLASSES});
                if ~isequal(type_CALL,'sig')
                    idxSIG = ismember(IdxCLU,numCLASSES);
                else
                    idxSIG = ismember((1:nbSIG)',numCLASSES);
                end
        end
        IdxCLU = IdxCLU(idxSIG,:);
        nb_COL_Ts = size(IdxCLU,2);
        numSIG = numSIG(idxSIG);
        nbSIG  = length(numSIG);
        switch col_SORT
            case 1 ,  idxSORT = (1:nbSIG)';
            otherwise , [~,idxSORT] = sortrows(IdxCLU,col_SORT-1);
        end
        if asc_SORT==-1 , idxSORT = flipud(idxSORT); end

        B1 = blanks(nbSIG)';
        sep = sep(ones(nbSIG,1),:);
        STR_VAL = [B1,B1, num2str(numSIG(idxSORT),'%3.0f') ,B1, sep];
        for k=1:nb_COL_Ts
            STR_VAL = [STR_VAL,num2str(IdxCLU(idxSORT,k),'%2.0f'),B1, sep]; 
        end
        if nbSIG==1 , STR_VAL = {STR_VAL}; end
        switch aff_OPT
            case 'sort'
                str_DATA = get(handles.Txt_SEL_DATA,'String');
                str_POP  = get(handles.Pop_SORT,'String');
                val_POP  = get(handles.Pop_SORT,'Value');

            case 'clu_SEL'
                str_DATA = ' Sig |';
                str_POP  = {getWavMSG('Wavelet:mdw1dRF:Idx_Sig')};
                nbSEL = 2;
                for k=1:nbSEL
                    str_DATA = [str_DATA  ' P' int2str(k) ' |']; 
                    str_POP  = [str_POP ; ['Part ' int2str(k)]];
                end
                val_POP = 2;

            case {'partition','part_CLU','part_CLU_B'}
                switch aff_OPT
                    case {'partition','part_CLU_B'}
                        lst = get(handles.Lst_LST_PART,'String');
                        
                    case {'part_CLU'}
                        lst = get(handles.Pop_SEL_1,'String');
                        aff_OPT = 'partition';
                end
                str_DATA = ' Sig  |';
                str_POP  = [getWavMSG('Wavelet:mdw1dRF:Idx_Sig');lst];
                if ~isequal(idxPART,0)  
                    str_POP  = {getWavMSG('Wavelet:mdw1dRF:Idx_Sig'),lst{idxPART}};
                end
                nbSEL = nbPART;
                for k=1:nbSEL
                    str_DATA = [str_DATA  ' P' int2str(k) ' |']; 
                end
                val_POP = 1;
                
            otherwise
                if isequal(aff_OPT,'importCLU')
                    str_DATA = ' Sig | Imp |';
                    str_POP  = {getWavMSG('Wavelet:mdw1dRF:Idx_Sig');'Idx Clu IMP.'};
                else
                    str_DATA = ' Sig | Clu |';
                    str_POP  = {getWavMSG('Wavelet:mdw1dRF:Idx_Sig'); ...
                        getWavMSG('Wavelet:mdw1dRF:Idx_Clu')};
                end
                val_POP  = 2;
        end
        set(handles.Txt_SEL_DATA,'String',str_DATA, ...
            'TooltipString',Make_ToolTipString(str_POP));
        set(handles.Pop_SORT,'String',str_POP,'Value',val_POP)
        set(handles.Lst_SEL_DATA,'Value',1,'String',STR_VAL);
        switch aff_OPT
            case 'init'    , FCol = 'k';
            case 'clu_SEL' , FCol = 'b';
            case 'clu_CUR' , FCol = [0 0.7 0];
            case 'clu_TWO' , FCol = [0.9 0.5 0];
            case 'dendro'  , FCol = 'r';
            case 'links'   , FCol = 'm';
            case {'partition','part_CLU','part_CLU_B'} , FCol = 'b';
            case 'kmeans'  , FCol = 'r';
            otherwise , FCol = 'k';
        end
        if ~isequal(aff_OPT,'sort')
            setStrNbSIG(handles.Edi_NB_SIG,nbSIG)
            set(handles.Edi_NB_SIG,'ForegroundColor',FCol);
        end
    end
%--------------------------------------------------------------------------
    function aff_LST_DAT(typ_SIG,level,Lst_SIG,Lst_CFS)
        
        Str_Lst_DATA = get(Lst_SIG,'String');
        len_LST = length(Str_Lst_DATA);
        switch typ_SIG
            case 'ORI'
                toDEL = {'CMP','DEN','RES','Com','De-','Res'};
                typ_STR = ''; max_SIG = 0; max_CFS = 0;
                first_SIG = getWavMSG('Wavelet:moreMSGRF:Orig_Signals');
                del_lst_END = true;
                add_APP_DET = true;                

            case {'CMP','DEN'}
                toDEL = {};
                typ_STR = [typ_SIG,'-'];
                max_SIG = 1+2*level; max_CFS = 2*level;
                if isequal(typ_SIG,'CMP')
                    first_SIG = getWavMSG('Wavelet:moreMSGRF:Compressed');
                else
                    first_SIG = getWavMSG('Wavelet:moreMSGRF:Denoised');
                end
                del_lst_END = false;
                add_APP_DET = (len_LST<=max_SIG);
        end
        
        % List of Signals.
        %-----------------        
        for k = 1:length(toDEL)
            Idx = strncmpi(toDEL(k),Str_Lst_DATA,3);
            Str_Lst_DATA(Idx) = [];
        end        
        len_LST = length(Str_Lst_DATA);
        if del_lst_END
            if max_SIG<len_LST
                Str_Lst_DATA(max_SIG+1:end) = [];
            elseif len_LST==0
                Str_Lst_DATA = {};
            end
        end
        if add_APP_DET
            Str_Lst_DATA = [Str_Lst_DATA ; first_SIG];
            for k=1:level
                Str_Lst_DATA = [Str_Lst_DATA;[typ_STR 'APP ' int2str(k)]];
            end
            for k=1:level
                Str_Lst_DATA = [Str_Lst_DATA;[typ_STR 'DET ' int2str(k)]];
            end
            if isequal(typ_SIG,'DEN') || isequal(typ_SIG,'CMP')
                Str_Lst_DATA = [Str_Lst_DATA; ...
                    getWavMSG('Wavelet:moreMSGRF:Residuals')];
            end
        end
        idxTOP = max_SIG+1;
        if idxTOP>length(Str_Lst_DATA) , idxTOP = 1; end
        set(Lst_SIG,'Value',1,'String',Str_Lst_DATA,'ListboxTop',idxTOP);

        % List of Coefficients.
        %----------------------
        Str_Lst_DATA = get(Lst_CFS,'String');
        len_LST = length(Str_Lst_DATA);
        if del_lst_END
            if max_CFS<length(Str_Lst_DATA)
                Str_Lst_DATA(max_CFS+1:end) = [];
            elseif len_LST==0
                Str_Lst_DATA = {};
            end
        end
        if add_APP_DET
            for k=1:level
                Str_Lst_DATA = [Str_Lst_DATA;[typ_STR 'APP ' int2str(k)]];
            end
            for k=1:level
                Str_Lst_DATA = [Str_Lst_DATA;[typ_STR 'DET ' int2str(k)]];
            end
        end
        set(Lst_CFS,'Value',[],'String',Str_Lst_DATA)
    end
%--------------------------------------------------------------------------
    function aff_LST_MARK(hdl_LST,IDX)

        lst_Items = get(hdl_LST,'String');
        if ~isempty(IDX)
            C1_STR = repmat(' ',size(lst_Items,1),1);
            III = get_idxSEL(hdl_LST);
            [~,LOC] = ismember(IDX,III);
            C1_STR(LOC,1)  = mark;
            lst_Items(:,1) = C1_STR;
        else
            if iscell(lst_Items) , lst_Items = lst_Items{1}; end
            lst_Items(:,1) = ' ';
        end
        set(hdl_LST,'String',lst_Items)
    end
%--------------------------------------------------------------------------
    function lst_Items = set_LST_MARK(lst_Items)
        
        idxSIG_Plot = wtbxappdata('get',fig,'idxSIG_Plot');
        if isempty(idxSIG_Plot) , return; end

        % Find ixdSEP
        item = lst_Items(1,:);
        if iscell(item) , item = item{1}; end
        ixdSEP = find(item(1,:)=='|',1,'first');

        % Get string of idx_SEL and then idx_SEL
        if size(lst_Items,1)==1 && iscell(lst_Items)
            lst_Items = lst_Items{1};
        end
        str_idx_SEL = lst_Items(:,1:ixdSEP-1);
        id_Mark = lst_Items(:,1)== mark;
        str_idx_SEL(id_Mark,1) = ' ';
        idx_SEL = str2num(str_idx_SEL); %#ok<ST2NM>
        [~,LOC] = ismember(idxSIG_Plot,idx_SEL);
        C1_STR = repmat(' ',size(lst_Items,1),1);
        C1_STR(LOC,1)  = mark;
        lst_Items(:,1) = C1_STR;
    end
%--------------------------------------------------------------------------
    function idx_SEL = get_idxSEL(hdl_LST,flagIND) %#ok<INUSD>
        
        lst_Items = get(hdl_LST,'String');
        if ~isempty(lst_Items)
            
            % Find ixdSEP
            item = lst_Items(1,:);
            if iscell(item) , item = item{1}; end
            ixdSEP = find(item(1,:)=='|',1,'first');
            
            % Get string of idx_SEL and then idx_SEL
            if nargin>1
                idx  = get(hdl_LST,'Value');
                lst_Items = lst_Items(idx,:);
            end
            if size(lst_Items,1)==1 && iscell(lst_Items)
                lst_Items = lst_Items{1};
            end
            str_idx_SEL = lst_Items(:,1:ixdSEP-1);
            id_Mark = lst_Items(:,1)== mark;
            str_idx_SEL(id_Mark,1) = ' ';  
            idx_SEL = str2num(str_idx_SEL); %#ok<ST2NM>
        else
            idx_SEL = [];
        end
    end
%--------------------------------------------------------------------------
    function varargout = get_Attrb_Lst_In_SEL
        
        typ_DorC = data_DorC.typ_DorC;
        nbSigInSEL = size(data_SEL.sel_DAT,1);
        Attrb_SEL  = data_SEL.Attrb_SEL;
        if isempty(Attrb_SEL) , Attrb_SEL = {false,{'s'},0}; end
        [DorC_FLAG,typVAL,levVAL] = deal(Attrb_SEL{:});

        nbBlocs      = length(DorC_FLAG);
        nbSigInBlocs = nbSigInSEL/nbBlocs;
        num_SEL = (1:nbSigInSEL)';
        num_SIG = repmat((1:nbSigInBlocs)',nbBlocs,1);
        typVAL = repmat(typVAL,nbSigInBlocs,1);
        typVAL = typVAL(:);
        typVAL = cat(1,typVAL{:});
        DorC_FLAG = repmat(DorC_FLAG(:)',nbSigInBlocs,1);
        DorC_FLAG = DorC_FLAG(:);
        levVAL = repmat(levVAL,nbSigInBlocs,1);
        levVAL = levVAL(:);
        typSIG = repmat({'ori'},nbSigInSEL,1);
        typSIG(DorC_FLAG) = {typ_DorC};
        idxRES = isnan(levVAL);
        if any(idxRES)
            levVAL(idxRES) = 0;
            typSIG(idxRES) = {'res'};
        end
        typSIG = cat(1,typSIG{:});

        typVAL_Num = zeros(nbSigInSEL,1);
        % idx = strncmp({'s'},typVAL,1); typVAL_Num(idx) = 0;
        idx = strncmp({'a'},typVAL,1);  typVAL_Num(idx) = 1;
        idx = strncmp({'d'},typVAL,1);  typVAL_Num(idx) = 2;
        idx = strncmp({'ca'},typVAL,2); typVAL_Num(idx) = 3;
        idx = strncmp({'cd'},typVAL,2); typVAL_Num(idx) = 4;
        
        typSIG_Num = zeros(nbSigInSEL,1);
        % idx = strncmp({'ori'},typSIG,3); typSIG_Num(idx) = 0;
        idx = strncmp({'den'},typSIG,3); typSIG_Num(idx) = 1;
        idx = strncmp({'cmp'},typSIG,3); typSIG_Num(idx) = 2;
        idx = strncmp({'res'},typSIG,3); typSIG_Num(idx) = 3;
        
        [idxPART_Imp,PART_Imp] = partsetmngr('idx_IMPORT_PART',fig);
        IdxCLU = [];
        if ~isempty(idxPART_Imp);
            IdxCLU = get(PART_Imp,'IdxCLU');
            IdxCLU = repmat(IdxCLU,nbBlocs,1);
        end
        Attrb_Lst_In_SEL = [num_SEL,num_SIG,typVAL_Num,levVAL,typSIG_Num];
        wtbxappdata('set',fig,'Attrb_Lst_In_SEL',Attrb_Lst_In_SEL);
        switch nargout
            case 1 , varargout = {Attrb_Lst_In_SEL};
            case 2 , varargout = {num_SEL,IdxCLU};
            case 8
                typVAL_Num = abs(typVAL(:,end));
                typSIG_Num = abs(typSIG(:,1));
                varargout = {num_SEL,num_SIG,...
                      typVAL,typVAL_Num,levVAL,typSIG,typSIG_Num,IdxCLU};
        end
    end
%------------------------------------------------------------------------
    function [IdxCLU,idxSIG,numCLA] = find_tab_CLU(nbSIG,TypeSEL,toolNAME)
        
        fig = handles.Current_Fig;
        callingFIG = blockdatamngr('get',fig,'fig_Storage','callingFIG');
        SET_of_Partitions = wtbxappdata('get',callingFIG,'SET_of_Partitions');

        numCLA = zeros(1,2);
        IdxCLU = NaN(nbSIG,2);
        bool   = zeros(nbSIG,2);

        Pop_SEL = [handles.Pop_SEL_1,handles.Pop_SEL_2];
        Pop_NUM = [handles.Pop_NUM_1,handles.Pop_NUM_2];
        cellSTR = get(Pop_NUM,'String');
         
        if isequal(toolNAME,'CLU') , deltaSEL = 1; else deltaSEL = 0; end
        for k = 1:2
            numPart = get(Pop_SEL(k),'Value')-deltaSEL;
            if numPart>0
                nbItems   = size(cellSTR{k},1); %#ok<NASGU>
                numCLA(k) = get(Pop_NUM(k),'Value')-1;
                [NbCLU,IdxCLU(:,k)] = ...
                    get(SET_of_Partitions(numPart),'NbCLU','IdxCLU');
                if numCLA(k)>NbCLU
                    bool(:,k) = IdxCLU(:,k)>=nbMaxCLU_AFF;
                    numCLA(k)=Inf;
                elseif numCLA(k)>0
                    bool(:,k) = IdxCLU(:,k)==numCLA(k);
                else
                    bool(:,k) = 1;
                end
            else
                numCLA(k)= NaN;
            end
        end
                
        switch TypeSEL
            case 'and' , bool_RES = bool(:,1)   &  bool(:,2);
            case 'or'  , bool_RES = bool(:,1)   |  bool(:,2);
            case 'xor' , bool_RES = ~(bool(:,1) &  bool(:,2));
            case '1-2' , bool_RES = bool(:,1)   &  ~bool(:,2);
            case '2-1' , bool_RES = ~bool(:,1)  &  bool(:,2);
        end
        idxSIG = find(bool_RES);        
    end
%--------------------------------------------------------------------------
    function [tab,idxSORT] = sortDATA(tab,col_SORT,asc_SORT)
        if asc_SORT==-1 , col_SORT = asc_SORT*col_SORT; end
        if ~ismember(1,col_SORT) , col_SORT = [col_SORT,1]; end
        [tab,idxSORT] = sortrows(tab,col_SORT);
    end
%--------------------------------------------------------------------------
    function StrOUT = Make_ToolTipString(StrIN)
        
        StrOUT = [];
        for k=1:length(StrIN)
            StrOUT = [StrOUT , StrIN{k} , '   |   ']; 
        end
    end
%--------------------------------------------------------------------------
    function setStrNbSIG(Edi_NB_SIG,nbSigInSEL)
        set(Edi_NB_SIG, ...
            'String',getWavMSG('Wavelet:mdw1dRF:Number_of_Sig',nbSigInSEL));
    end
%--------------------------------------------------------------------------

end % END of MAIN FUNCTION
