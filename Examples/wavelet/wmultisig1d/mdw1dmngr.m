function varargout = mdw1dmngr(option,varargin)
%MDW1DMNGR Multisignal analysis manager.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 25-Apr-2005.
%   Last Revision: 04-Jul-2013.
%   Copyright 1995-2014 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $ $Date: 2013/08/23 23:45:46 $

%=============================================================
% VALID OPTIONS:
%   'Chk_AFF_MUL_Callback'
%   'Chk_DEC_GRID_Callback'   or 'Chk_DEC_GRID_Func'
%   'Lst_SIG_or_CFS_Callback' or 'Lst_SIG_or_CFS_Func'
%   'Lst_SEL_DATA_Callback'
%   'Men_save_FUN'
%   'Pop_HIG_Callback'        or 'Pop_HIG_Func'
%   'Pop_DEC_Lev_Callback'
%   'Pus_CloseWin_Callback'
%   'Pus_IMPORT_Callback'
%   'Pus_PLOT_Callback'
%   'Pus_SORT_Callback'
%   'load_PART'
%-----------------------------------------------------------
%   'getDispMode'
%   'setDispMode'
%   'set_idxSIG_Plot'
%   'set_Tool_View'
%---------------------------------
%   'init_TOOL'
%====================================================================
% tool_ATTR = struct(...
%     'Name',tool_NAME,'State','INI','VisType','SIG',...
%     'plot_MODE','unique','First_Use',true);
%====================================================================
% fig_Storage = struct(...
%     'callingFIG',callingFIG,'fig_ORI',fig_ORI,...
%     'fig_DorC',fig_DorC,'fig_SEL',fig_SEL);
% wtbxappdata('set',fig,'fig_Storage',fig_Storage);
%
% data_ORI = struct(...
%     'siz_INI',[],'signal',[],'dir_DEC',[],'dwtDEC',[],...
%     'Energy',[],'tab_ENER',[], ...
%     'siz_ORI',[],'lenSIG',[],'nbSIG',[]);
% wtbxappdata('set',fig_ORI,'data_ORI',data_ORI);
%
% data_DorC = struct(...
%     'typ_DorC','','signal',[],'dir_DEC',[],'dwtDEC',[],...
%     'Energy',[],'tab_ENER',[],'threshold',[]);
% wtbxappdata('set',fig_DorC,'data_DorC',data_DorC);
%
% data_SEL = struct('sel_DAT',sel_DAT,'Attrb_SEL',[]);
% wtbxappdata('set',fig_SEL,'data_SEL',data_SEL);
%====================================================================
% typVAL_Num = zeros(nbSigInSEL,1);
%-----------------------------------
% typVAL = 's'  ==> typVAL_Num(idx) = 0;
% typVAL = 'a'  ==> typVAL_Num(idx) = 1;
% typVAL = 'd'  ==> typVAL_Num(idx) = 2;
% typVAL = 'ca' ==> typVAL_Num(idx) = 3;
% typVAL = 'cd' ==> typVAL_Num(idx) = 4;
%------------------------------------------
% typSIG_Num =  zeros(nbSigInSEL,1)
%-----------------------------------
% typSIG = 'ori' ==> typSIG_Num(idx) = 0;
% typSIG = 'den' ==> typSIG_Num(idx) = 1;
% typSIG = 'cmp' ==> typSIG_Num(idx) = 2;
% typSIG = 'res' ==> typSIG_Num(idx) = 3;
% Attrb_Lst_In_SEL = [num_SEL,num_SIG,typVAL_Num,levVAL,typSIG_Num];
%====================================================================

switch option
    case 'Chk_AFF_MUL_Callback'  , mdw1dmisc('chk_ONE_PLOT',varargin{3:end});  
    case 'Lst_SEL_DATA_Callback' , mdw1dmisc('lst_DAT_SEL',varargin{3:end});
    case 'Pus_PLOT_Callback'     , mdw1dmisc('plot',varargin{:});
    case 'set_idxSIG_Plot'       , set_idxSIG_Plot(varargin{:});
    case 'set_Tool_View'         , set_Tool_View(varargin{:});
    case 'init_TOOL'
        handles   = varargin{1};
        Data_Name = varargin{2};
        tool_NAME = varargin{3};
        fig       = handles.Current_Fig;
        %---------------------------------
        if isequal(tool_NAME,'PAR')           
            mdw1dmisc('plot',handles,[],'clean');
            mdw1dafflst('INI',handles.Lst_SEL_DATA,[],handles,'init','INI')
            % mdw1dutils('set_Lst_DATA',handles,'reset')            
            return
        end
        %---------------------------------
        if ~isequal(tool_NAME,'CLU') && ~isequal(tool_NAME,'PAR')
            init_Tool_View(handles,tool_NAME);
        end
        set([handles.Txt_LST_SIG,handles.Txt_LST_CFS,...
             handles.Lst_SIG_DATA,handles.Lst_CFS_DATA,...
             handles.Fra_SEL_DATA,handles.Txt_SEL_DATA,...
             handles.Lst_SEL_DATA],...
            'TooltipString',getWavMSG('Wavelet:mdw1dRF:Tip_SEL_DATA'));
        
        % Set Title Colors.
        %------------------
        lst_Colors = mdw1dutils('lst_Colors');
        sig_HDL = [handles.Txt_LST_SIG,handles.Lst_SIG_DATA,...
            handles.Edi_Selected_DATA];
        cfs_HDL = [handles.Txt_LST_CFS,handles.Lst_CFS_DATA];
        switch tool_NAME
            case 'STA', sig_HDL = [sig_HDL,handles.Edi_TIT_STA];
        end
        set(sig_HDL,'ForegroundColor',lst_Colors.sig)
        set(cfs_HDL,'ForegroundColor',lst_Colors.cfs)
        
        % Stop here if tool_NAME = 'ORI'.
        %--------------------------------
        if isequal(tool_NAME,'ORI') , return; end
        
        % Begin Cleaning.
        %----------------
        OBJ_Ena_ON = [...
            handles.Txt_SEL_DATA,handles.Lst_SEL_DATA,...
            handles.Pus_SORT_Dir,handles.Pus_SORT_Inv,handles.Pop_SORT,...
            handles.Pus_AFF_ALL,handles.Pus_AFF_NON,handles.Chk_AFF_MUL,...
            ];
        set(OBJ_Ena_ON,'Enable','On')
        mdw1dmisc('plot',handles,[],'clean');
        set(handles.Lst_CFS_DATA,'String','','Value',[]);
        set(handles.Lst_SIG_DATA,'Value',1);
        
        % Setting List of selected data.
        %-------------------------------
        mdw1dafflst('INI',handles.Lst_SEL_DATA,[],handles,'init','INI')

        % End Cleaning.
        %--------------
        mdw1dutils('set_Lst_DATA',handles,'reset')
        UIC_Ena_ON = [...
            handles.Fra_SEL_DATA, ...
            handles.Txt_SELECTED,...
            handles.Txt_LST_SIG,handles.Lst_SIG_DATA,...
            handles.Txt_LST_CFS,handles.Lst_CFS_DATA ...
            ];
        
        set(UIC_Ena_ON,'Enable','On')
        UIC_Ena_INA = ...
            [handles.Edi_TIT_SEL,handles.Edi_TIT_VISU,...
            handles.Edi_NB_SIG,handles.Txt_SORT];
        set(UIC_Ena_INA,'Enable','Inactive')

        % Data Initialization.
        %---------------------
        data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
        set(handles.Edi_Data_NS,'String',Data_Name);
        if ~isempty(data_ORI.dwtDEC)
            dir_DEC   = data_ORI.dir_DEC;
            wname = data_ORI.dwtDEC.wname;
            level = data_ORI.dwtDEC.level;
            dwtEXTM = data_ORI.dwtDEC.dwtEXTM;
            [wfam,wnum] = wavemngr('fam_num',wname);
            set(handles.Edi_Wav_Fam,'String',wfam);
            set(handles.Edi_Wav_Num,'String',wnum);
            set(handles.Edi_Ext_Mode,'String',dwtEXTM);
            set(handles.Edi_Lev,'String',int2str(level));
            switch dir_DEC(1)
                case 'c' , storeSTR = getWavMSG('Wavelet:LastMessages:columnwise');
                case 'r' , storeSTR = getWavMSG('Wavelet:LastMessages:rowwise');
            end
            set(handles.Edi_DIR,'String',storeSTR);
            switch tool_NAME
                case {'CLU','STA'}
                    fig_Storage = wtbxappdata('get',fig,'fig_Storage');
                    callingFIG = fig_Storage.callingFIG;
                    calling_handles = guidata(callingFIG);
                    str_SIG = get(calling_handles.Lst_SIG_DATA,'String');
                    set(handles.Lst_SIG_DATA,'String',str_SIG);
                    str_SIG = get(calling_handles.Lst_CFS_DATA,'String');
                    set(handles.Lst_CFS_DATA,'String',str_SIG);
                    
                case {'CMP','DEN'}
                    mdw1dafflst('DAT','ORI',level,handles.Lst_SIG_DATA,...
                        handles.Lst_CFS_DATA);
                    nbSIG = data_ORI.siz_ORI(1);
                    blockdatamngr('set',fig,'data_DorC',...
                        'threshold',zeros(nbSIG,level));
                    strPOP = num2cell(int2str((1:level)'));
                    strPOP = [getWavMSG('Wavelet:commongui:Str_All');strPOP];
                    set(handles.Pop_MAN_LEV,'String',strPOP,'Value',2)
                    set(handles.Edi_MAN_THR,'String','','UserData',NaN(1,level));
            end
            levSTR = getWavMSG('Wavelet:commongui:Str_level');
            strPOP = cell(level,1);
            for k = 1:level
                strPOP{k} = [levSTR ' ' int2str(k)];
            end
            set(handles.Pop_DEC_lev,'String',strPOP,'Value',level);
        else
            set(handles.Edi_Wav_Fam,'String','');
            set(handles.Edi_Wav_Num,'String','');
            set(handles.Edi_Ext_Mode,'String','');
            set(handles.Edi_Lev,'String','');
            set(handles.Edi_DIR,'String','');
            set(handles.Lst_SIG_DATA, ...
                'String',{getWavMSG('Wavelet:mdw1dRF:Orig_Signals')}, ...
                'Value',1)
        end
        
    case 'Pus_SORT_Callback'
        [hObject,eventdata,handles,direct] = deal(varargin{1:4});
        fig = handles.Current_Fig;
        tool_STATE = blockdatamngr('get',fig,'tool_ATTR','State');
        switch tool_STATE
            case 'ORI_ON' ,             aff_MODE = 'ORI';
            case {'CMP_ON','CMP_MAN'} , aff_MODE = 'CMP';
            case {'DEN_ON','DEN_MAN'} , aff_MODE = 'DEN';
            case 'STA_ON' ,             aff_MODE = 'STA';
            case 'CLU_ON' ,             aff_MODE = 'CLU';
            case 'PAR_ON' ,             aff_MODE = 'PAR';
            otherwise ,                 aff_MODE = 'INI';
        end
        mdw1dafflst(aff_MODE,hObject,eventdata,handles,'sort',direct);

    case 'Pop_DEC_Lev_Callback'
        handles = varargin{3};
        set(handles.Pop_HIG_DEC,'Value',1);
        mdw1dshow('Show_DEC_Fun',varargin{1:3},'Pop_DEC_lev')

    case {'Lst_SIG_or_CFS_Callback','Lst_SIG_or_CFS_Func'}
        [hObject,~,handles,typeOfData] = deal(varargin{1:4});
        fig = handles.Current_Fig;
        switch typeOfData
            case 'sig' , hdl_LST = handles.Lst_CFS_DATA;
            case 'cfs' , hdl_LST = handles.Lst_SIG_DATA;
        end
        set(hdl_LST,'Value',[]);
        idx = get(hObject,'Value');
        cur_SEL = get(handles.Edi_Selected_DATA,'UserData');
        new_SEL = {typeOfData,idx};
        if isequal(cur_SEL,new_SEL) , return; end
        set(handles.Edi_Selected_DATA,'UserData',new_SEL);
        
        % Begin waiting.
        %---------------
        mousefrm(fig,'watch');
        
        % Check Tool (Name and State).
        %-----------------------------
        [tool_NAME,tool_State] = blockdatamngr('get',fig, ...
            'tool_ATTR','Name','State');

        % Check input.
        %-------------
        if length(varargin)>4
            resetFLAG = varargin{5};
            switch resetFLAG
                case {'CMP','DEN','STA'}
                    blockdatamngr('set',fig,'tool_ATTR','State','INI');
            end
        else
            resetFLAG = 'INI';
        end
        
        % Read Data.
        %-----------
        [data_ORI,data_DorC,data_SEL] = ...
            mdw1dutils('data_INFO_MNGR','get',fig,'ORI','DorC','SEL');
        if ~isempty(data_ORI.dwtDEC)
            level = data_ORI.dwtDEC.level;
        else
            level = 0;
        end
        [DorC_FLAG,typVAL,levVAL,idx] = data_ID(hObject,typeOfData,level,idx);
        lenIDX = length(idx); 
        
        % Cleaning tool.
        %---------------
        if isequal(resetFLAG,'STA')
            uic_STA_VAL = findobj(handles.Pan_STA_VAL,'Type','Uicontrol');
            hdl_EDI = findobj(uic_STA_VAL,'Style','Edit');
            set(hdl_EDI,'String','');
            set(uic_STA_VAL,'Enable','Off');
            set(handles.Pan_STA_VAL,'UserData',false);
            set_Tool_View(handles,'STA','Close_DEC');
            
            dispMode_VIS = mdw1dmngr('getDispMode',handles.Pop_VisPanMode);
            if ~isequal(dispMode_VIS,'sup')
                set(handles.Pop_Show_Mode,'Value',1);
                mdw1dmngr('setDispMode',handles.Pop_Show_Mode,[],handles,'STA','DEC')
            end
             
        elseif ~isequal(tool_NAME,'CLU')
            set_Tool_View(handles,resetFLAG,'Reset','Lst_SIG_or_CFS')
        end        
        mdw1dmisc('plot',handles,[],'Lst');
        lst_Items = get(hObject,'String');
        switch lenIDX
            case 0 , item = '';
            case 1 ,
                item = lst_Items(idx,:);
                if iscell(item) , item = item{1}; end
                if isequal(typeOfData,'cfs')
                    item = [item '  (' getWavMSG('Wavelet:mdw1dRF:Str_Cfs') ')']; 
                end
            otherwise , item = getWavMSG('Wavelet:mdw1dRF:Many_selections');
        end
        mdw1dutils('set_Lst_DATA',handles,'select',item,hObject,tool_NAME)
        
        sel_DAT = cell(lenIDX,1);
        for k=1:lenIDX
            typDATA = typVAL{k};
            switch typDATA
                case 's'
                    if DorC_FLAG(k)
                        if isnan(levVAL(k))
                            sel_DAT{k} = ...
                                abs(data_ORI.signal-data_DorC.signal);
                        else
                            sel_DAT{k} = data_DorC.signal;
                        end
                    else
                        sel_DAT{k} = data_ORI.signal;
                    end

                case {'a','d','ca','cd'}
                    if DorC_FLAG(k)==0
                        sel_DAT{k} = ...
                            mdwtrec(data_ORI.dwtDEC,typDATA,levVAL(k));
                    else
                        sel_DAT{k} = ...
                            mdwtrec(data_DorC.dwtDEC,typDATA,levVAL(k));
                    end
            end
        end
        data_SEL.sel_DAT  = cat(1,sel_DAT{:});
        data_SEL.Attrb_SEL = {DorC_FLAG,typVAL,levVAL};
        mdw1dutils('data_INFO_MNGR','set',fig,'SEL',data_SEL);

        % List of selected signals.
        %--------------------------
        aff_MODE = 'INI';
        if isequal(typeOfData,'sig') && isequal(tool_State,'ORI_ON')
            selected = lst_Items(idx,:);
            findSIG = strfind(selected, ...
                getWavMSG('Wavelet:moreMSGRF:Orig_Signals'));
            if iscell(findSIG) , findSIG = cat(1,findSIG{:}); end
            flagSIG = size(selected,1)==length(findSIG);
            if flagSIG , aff_MODE = 'ORI'; end
        end
        if isequal(tool_NAME,'ORI')
            mdw1dmisc('clean',handles,'Pan_SEL_INFO','ini');
        end
        mdw1dafflst(aff_MODE,hObject,[],handles,'init',resetFLAG);

        % End waiting.
        %-------------
        mousefrm(fig,'arrow');
        
    case 'Pus_CloseWin_Callback'
        [~,eventdata,handles,tool] = deal(varargin{1:4});
        try
            fig = handles.output;
        catch ME    %#ok<NASGU>
            return; 
        end
        fig_Del_STATUS = wtbxappdata('get',fig,'fig_Del_STATUS');
        if ~isempty(fig_Del_STATUS) ,  return; end
        wtbxappdata('set',fig,'fig_Del_STATUS',1);
        
        fig_Storage = wtbxappdata('get',fig,'fig_Storage');
        callingFIG = fig_Storage.callingFIG;
        status = 0;
        switch tool
            case {'CMP','DEN'}
                hdl_Menus = wtbxappdata('get',fig,'hdl_Menus');
                m_save = hdl_Menus.m_save;
                ena_Save = get(m_save,'Enable');
                if isequal(lower(ena_Save),'on')
                    switch tool
                        case 'CMP' 
                            titSTR = getWavMSG('Wavelet:mdw1dRF:Multi_Compression');
                        case 'DEN'
                            titSTR = getWavMSG('Wavelet:mdw1dRF:Multi_Denoising');
                    end
                    status = wwaitans({fig,titSTR},...
                        getWavMSG('Wavelet:mdw1dRF:Update_Syn_Sig'),2,'Cancel');
                    if isequal(status,-1) , return; end
                end
                if status==1 ,
                    mdw1dutils('data_INFO_MNGR','save',fig);
                    calling_Handles = guidata(callingFIG);
                    str_LST = get(handles.Lst_SIG_DATA,'String');
                    set(calling_Handles.Lst_SIG_DATA,...
                        'String',str_LST,'Value',1);
                    str_LST = get(handles.Lst_CFS_DATA,'String');
                    set(calling_Handles.Lst_CFS_DATA,...
                        'String',str_LST,'Value',1);
                end

            case {'CLU','STA'}
                
        end
        mdw1dtool('Pus_ACTION_Callback',...
            callingFIG,eventdata,handles,tool,status,fig);
        delete(gcbf);
        
    case 'Men_save_FUN'
        [~,~,handles,type_SAVE] = deal(varargin{:});
        fig = handles.output;
        data_DorC = mdw1dutils('data_INFO_MNGR','get',fig,'DorC');
        typ_DorC  = upper(data_DorC.typ_DorC);
        if isempty(typ_DorC) || isequal(type_SAVE,'SYN_ORI_DEC')
            ST = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
        else
            ST = data_DorC;
        end
        
        SIG_or_DEC = type_SAVE(end-2:end);
        switch SIG_or_DEC
            case 'SIG' , X = ST.signal;   varName = 'X';
            case 'DEC' , dec = ST.dwtDEC; varName = 'dec';
        end
        dir_DEC = ST.dir_DEC;
        
        switch type_SAVE
            case 'SYN_ORI_SIG'
                titSTR = getWavMSG('Wavelet:mdw1dRF:Sav_Syn_Sig');
            case 'SYN_ORI_DEC'
                titSTR = getWavMSG('Wavelet:mdw1dRF:Sav_Decs');
            case 'CMP_SIG'
                titSTR = getWavMSG('Wavelet:mdw1dRF:Sav_Cmp_Sig');
            case 'DEN_SIG'
                titSTR = getWavMSG('Wavelet:mdw1dRF:Sav_Den_Sig');
            case 'CMP_DEC'
                titSTR = getWavMSG('Wavelet:mdw1dRF:Sav_Cmp_Decs');
            case 'DEN_DEC'
                titSTR = getWavMSG('Wavelet:mdw1dRF:Sav_Den_Decs');
        end

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',fig,'*.mat',titSTR);
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitSave'));

        % Getting Synthesized Signals.
        %-----------------------------
        if isequal(dir_DEC,'col')
            switch SIG_or_DEC
                case 'SIG' , X = X'; %#ok<NASGU>
                case 'DEC' , dec = mswdecfunc('transpose',dec); %#ok<NASGU>
            end
        end

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end

        % End waiting.
        %-------------
        wwaiting('off',fig);
        try
            save([pathname filename],varName);
        catch ME    %#ok<NASGU>
            errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end
  
    case {'Pop_HIG_Callback','Pop_HIG_Func'}
        [hObject,~,handles,tool_NAME,argMORE] = deal(varargin{1:5});
        fig = handles.Current_Fig;
        valPOP = get(hObject,'Value');
        strPOP = get(hObject,'String');
        if iscell(strPOP)
            strPOP = strPOP{valPOP};
        else
            strPOP = strPOP(valPOP,:);
        end
        idx = strfind(strPOP,'-') ;
        if ~isempty(idx) , strPOP = strPOP(1:idx-1); end
        strPOP(abs(strPOP)<48 | abs(strPOP)>57) = [];
        idxSEL = str2double(strPOP);
        sig_FLAG = isequal(hObject,handles.Pop_HIG_SIG);
        if sig_FLAG
            axeAct = handles.Axe_VISU;
            plotMode = 'VIS';
        elseif isequal(hObject,handles.Pop_HIG_DEC);
            axeAct = handles.Axe_VIS_DEC;
            plotMode = getDispMode(handles.Pop_Show_Mode);
        else
            axeAct = handles.Axe_CLU;
            plotMode = 'CLU';
        end
        old_LINE = findobj(axeAct,'Tag','Line_HIG');
        if ~isempty(old_LINE) , delete(old_LINE); end
        if ~isnan(idxSEL)
            toolCOL = mdw1dutils('colors');
            sig_COL = 0.8*toolCOL.sig; 
            syn_COL = 0.8*toolCOL.d_OR_c;
            app_COL = 0.5*toolCOL.app;
            det_COL = 0.6*toolCOL.det;
            % res_COL = 0.8*toolCOL.res;
            n0_COL  = 0.8*toolCOL.N0;
            l2_COL  = 0.8*toolCOL.L2;
            line_Attrb = {'LineWidth',2,'Tag','Line_HIG'};
            switch plotMode
                case 'VIS'  % Active AXES : Axe_VISU
                    if isfield(handles,'Rad_AFF_SIG')
                        val_RAD = get(handles.Rad_AFF_SIG,'Value');
                    else
                        val_RAD = 1;
                    end
                    if ~isequal(tool_NAME,'PAR')
                        signal = get_SIG_DEC('SIG',fig,idxSEL,val_RAD);
                    else
                        AllSig = blockdatamngr('get',fig,...
                                    'data_SEL','sel_DAT');
                        signal = AllSig(idxSEL,:);
                    end
                    linCOL = [0 0 0]; % Set Highlight to "black"
                    axes(axeAct); %#ok<*MAXES>
                    set(axeAct,'NextPlot','add');
                    hL = plot((1:length(signal)),...
                                signal,line_Attrb{:},'Color',linCOL);
                    set(axeAct,'NextPlot','replacechildren');        
                    mdw1dutils('line_Blink',hL);

                case 'dec'
                    lev_DEC = get(handles.Pop_DEC_lev,'Value');
                    [signal,approx,details] = ...
                        get_SIG_DEC('DEC',fig,idxSEL,lev_DEC);
                    lenSIG = length(signal);
                    axes(axeAct(1));
                    set(axeAct(1),'NextPlot','add');
                    hL(1) = plot(1:lenSIG,signal,line_Attrb{:},'Color',sig_COL);
                    next = 2;
                    set(axeAct(1),'NextPlot','replacechildren');
                    if ~ischar(approx)
                        axes(axeAct(2));
                        set(axeAct(2),'NextPlot','add');
                        hL(next) = ...
                            plot(1:lenSIG,approx,line_Attrb{:},'Color',app_COL);
                        next = next+1;
                        set(axeAct(2),'NextPlot','replacechildren');
                    end
                    if ~ischar(details)
                        nbDet = length(details);
                        for k=1:nbDet
                            axeCur = axeAct(2+k);
                            vis = get(axeCur,'Visible');
                            set(axeCur,'NextPlot','add');
                            hL(next) = ...
                                plot(1:lenSIG,details{nbDet-k+1},...
                                line_Attrb{:},'Color',det_COL,...
                                'Parent',axeCur,'Visible',vis); 
                            next = next+1;
                            set(axeCur,'NextPlot','replacechildren');
                        end
                    end
                    mdw1dutils('line_Blink',hL);

                case {'decCfs','lvlThr'}
                    lev_DEC = get(handles.Pop_DEC_lev,'Value');
                    [signal,approx,details] = ...
                        get_SIG_DEC('lvlThr',fig,idxSEL,lev_DEC);
                    lenSIG = length(signal);
                    axes(axeAct(1));
                    set(axeAct(1),'NextPlot','add');
                    hL(1) = plot(1:lenSIG,signal,line_Attrb{:},'Color',sig_COL);
                    next = 2;
                    set(axeAct(1),'NextPlot','replacechildren');
                    if ~ischar(approx)
                        axes(axeAct(2));
                        set(axeAct(2),'NextPlot','add');
                        hL(next) = ...
                            plot(1:lenSIG,approx,line_Attrb{:},'Color',app_COL);
                        next = next+1;
                        set(axeAct(2),'NextPlot','replacechildren');
                    end
                    if ~ischar(details)
                        nbDet = length(details);
                        for k=1:nbDet
                            axeCur = axeAct(2+k);
                            vis = get(axeCur,'Visible');
                            set(axeCur,'NextPlot','add');
                            hL(next) = ...                            
                                plot(1:lenSIG,details{nbDet-k+1},...
                                line_Attrb{:},'Color',det_COL, ...
                                'Visible',vis,'Parent',axeCur); %#ok<*AGROW>
                            next = next+1;
                            set(axeCur,'NextPlot','replacechildren');
                        end
                    end
                    if isequal(plotMode,'decCfs')
                        mdw1dutils('line_Blink',hL);
                    end
                    
                case 'tree'
                    lev_SEL = wtbxappdata('get',hObject,'Tree_LEV_SEL');
                    [signal,a_or_d,type_AD] = ...
                        get_SIG_DEC('TREE',fig,idxSEL,lev_SEL);
                    lenSIG = length(signal);
                    axes(axeAct(1));
                    set(axeAct(1),'NextPlot','add');
                    hL(1) = plot(1:lenSIG,signal,line_Attrb{:},'Color',sig_COL);
                    set(axeAct(1),'NextPlot','replacechildren');
                    switch type_AD
                        case 'NUL' , ad_COL = [];
                        case 'APP' , ad_COL = app_COL;
                        case 'DET' , ad_COL = det_COL;
                    end
                    if ~isempty(ad_COL)
                        axes(axeAct(2));
                        set(axeAct(2),'NextPlot','add');
                        hL(2) = plot(1:lenSIG,a_or_d,line_Attrb{:},'Color',ad_COL);
                        set(axeAct(2),'NextPlot','replacechildren');
                    end
                    mdw1dutils('line_Blink',hL);

                case {'glbThr','perfL2N0'}
                    [signal,sig_DorC] = get_SIG_DEC('glbThr',fig,idxSEL);
                    lenSIG = length(signal);
                    axes(axeAct(1));
                    set(axeAct(1),'NextPlot','add');
                    hL(1) = plot(1:lenSIG,signal,line_Attrb{:},'Color',sig_COL);
                    set(axeAct(1),'NextPlot','replacechildren');
                    if ~isempty(sig_DorC)
                        axes(axeAct(2));
                        set(axeAct(2),'NextPlot','add');
                        hL(2) = plot(1:lenSIG,sig_DorC,line_Attrb{:},'Color',syn_COL);
                        set(axeAct(2),'NextPlot','replacechildren');
                    end
                    
                    LinL2 = findobj(axeAct(3),'Tag','LinL2');
                    LinN0 = findobj(axeAct(3),'Tag','LinN0');
                    usr = get(LinL2,'UserData');
                    if iscell(usr) , usr = cat(1,usr{:}); end
                    if isequal(plotMode,'glbThr')
                        idxHDL_SEL = find(usr==argMORE);
                    else
                        argMORE = get(handles.Pop_HIG_DEC,'Value')-1;
                        idxHDL_SEL = find(usr==argMORE);
                    end
                    if ~isempty(idxHDL_SEL)
                        LinL2 = LinL2(idxHDL_SEL);
                        LinN0 = LinN0(idxHDL_SEL);
                        axes(axeAct(3));
                        set(axeAct(3),'NextPlot','add');
                        LinL2_Data = get(LinL2,{'XData','YData'});
                        hL(3) = plot(LinL2_Data{:},line_Attrb{:}, ...
                            'Color',l2_COL);
                        LinN0_Data = get(LinN0,{'XData','YData'});
                        hL(4) = plot(LinN0_Data{:},line_Attrb{:},...
                            'Color',n0_COL);                        
                    end
                    if isequal(plotMode,'perfL2N0')                        
                        mdw1dutils('line_Blink',hL);
                    end

                case 'sep'
                    axeAct = axeAct(1);
                    hdl_SIG = findobj(axeAct,'Type','line','UserData',idxSEL);
                    signal = get(hdl_SIG,'YData');
                    sig_COL = 0.8*get(hdl_SIG,'Color');
                    lenSIG = length(signal);
                    axes(axeAct);
                    set(axeAct,'NextPlot','add');
                    hL = plot(1:lenSIG,signal,line_Attrb{:},'Color',sig_COL);
                    set(axeAct,'NextPlot','replacechildren');
                    mdw1dutils('line_Blink',hL);
            end
        end
        
    case 'setDispMode'
        nbIN = length(varargin);
        [hdl_Pop,eventdata,handles,tool_NAME,typePop] = deal(varargin{1:5});
        if nbIN==6 , dispCUR = varargin{6}; else dispCUR = []; end
        dispName = getDispMode(hdl_Pop);
        if isequal(dispName,'sta')
            set_Tool_View(handles,'STA','set_VIEW',3)
            if isequal(hdl_Pop,handles.Pop_Show_Mode)
                setDispMode(handles.Pop_VisPanMode,dispName);
            end
            return;
        end
        
        switch typePop
            %### CORRECTION A FAIRE ###% 
            case 'VIS'
                old_Mode = get(hdl_Pop,'UserData');
                switch dispName
                    case 'sup'
                        if isequal(tool_NAME,'STA') && ...
                                ~isequal(old_Mode,'sup');
                            set_Tool_View(handles,'STA','set_VIEW',1)
                        end
                        return
                        
                    case 'none'
                        set(hdl_Pop,'Value',1); 
                        return
                        % set(hdl_Pop,'Value',old_Mode); 
                end
                setDispMode(handles.Pop_Show_Mode,dispName);
                end_OPT = tool_NAME;
                
            case {'DEC','MAN'}
                fig = handles.Current_Fig;
                old_Mode = get(hdl_Pop,'UserData');
                if length(varargin)>5
                    dispName = varargin{6};
                    setDispMode(hdl_Pop,dispName)
                end
                
                if isequal(dispName,'none')
                    setDispMode(hdl_Pop,old_Mode); 
                    return
                    
                elseif isequal(dispName,'sup') 
                    switch tool_NAME
                        case {'ORI','CMP','DEN','STA'}
                            set_Tool_View(handles,tool_NAME,...
                                'Reset','set_DispMode',typePop)

                        case 'CLU'
                            set(handles.Pop_VisPanMode,'Value',1)
                            mdw1dclus('Set_Pos_Pan',fig,[],handles,'Close_DEC')
                            
                        case 'PAR'
                            set(handles.Pop_VisPanMode,'Value',1)
                            
                        case 'PAN'
                    end
                    % ~isequal(tool_NAME,'PAR') && 
                    if ~isequal(tool_NAME,'PAN')
                        axe_IND = []; 
                        axe_CMD = handles.Axe_VISU;
                        axe_ACT = [];
                        dynvtool_ARGS = ...
                            {axe_IND,axe_CMD,axe_ACT,[1,0],'','','','real'};
                        if isequal(tool_NAME,'CLU')
                            vis = get(handles.Pan_View_PART,'Visible');
                            if strcmpi(vis,'On')
                                dynvtool_ARGS = ...
                                    wtbxappdata('get',fig,'dynvtool_ARGS');
                            end
                        end
                        dynvtool('init',fig,dynvtool_ARGS{:});
                    end
                    return
                end
                if isequal(tool_NAME,'CMP')
                    flag_MAN = get(handles.Pus_ENA_MAN,'UserData');
                    if flag_MAN
                        if isequal(dispName,'glbThr') || isequal(dispName,'lvlThr')
                            mdw1dcomp('Pop_MAN_TYP_THR_Callback',...
                                handles.Pop_MAN_TYP_THR,[],handles,dispName);
                        end
                    end
                end
                if isequal(dispName,old_Mode) , return; end
                toENA = [handles.Txt_HIG_DEC,handles.Pop_HIG_DEC];
                enaVAL = 'Off';
                switch dispName
                    case {'dec','decCfs','tree','sep',...
                          'glbThr','perfL2N0','lvlThr'}
                        if size(get(handles.Pop_HIG_DEC,'String'),1)>2
                            enaVAL = 'On';
                        end
                        if isequal(dispName,'tree')
                            wtbxappdata('set',hdl_Pop,'Tree_SEL',[]);
                        end
                    case {'stem','stemAbs','stemSqr','stemEner'}
                end
                set(toENA,'Enable',enaVAL,'Value',1);
                set(hdl_Pop,'UserData',dispName)
                end_OPT = 'Pop_Show_DEC'; 
        end
        if isequal(dispName,'sep') || isequal(dispName,'glbThr') || ...
           isequal(dispName,'glbThr_END') || isequal(dispName,'perfL2N0')
            set(handles.Edi_TIT_VISU_DEC, ...
                'String',getWavMSG('Wavelet:mdw1dRF:Visu_Select'))
            set(handles.Pop_DEC_lev,'Visible','Off')
            set(handles.Chk_DEC_GRID,'Visible','On');
            mdw1dmngr('Chk_DEC_GRID_Func',handles.Chk_DEC_GRID,dispName);
        else
            set(handles.Edi_TIT_VISU_DEC,...
                'String',getWavMSG('Wavelet:mdw1dRF:Visu_Decomp'))
            set(handles.Chk_DEC_GRID,'Visible','Off');
            set(handles.Pop_DEC_lev,'Visible','On')
            set(handles.Axe_VIS_DEC,'XGrid','Off','YGrid','Off')
        end
        mdw1dshow('Show_DEC_Fun',hdl_Pop,eventdata,handles,end_OPT,dispCUR)
              
    case 'Pus_IMPORT_Callback'
        % [hObject,eventdata,handles] = varargin{1:3};
        partsetmngr('import_PART',varargin{3})
        
    case {'Chk_DEC_GRID_Callback','Chk_DEC_GRID_Func'}
        hObject = varargin{1};
        handles = guidata(hObject);
        val = get(hObject,'Value');
        if length(varargin)>1
            dispName = varargin{2};
        else
            dispName = getDispMode(handles.Pop_Show_Mode);
        end
        switch dispName
            case 'sep'    , numAxe = 1;
            case {'glbThr','glbThr_END','perfL2N0'} , numAxe = 3;
        end
        switch val
            case 0 , visVAL = 'Off';
            case 1 , visVAL = 'On';
        end
        
        set(handles.Axe_VIS_DEC(numAxe),...
            'GridLineStyle',':','GridColor','k', ...
            'XGrid',visVAL,'YGrid',visVAL)       
        
    case 'getDispMode'
         Pop_Show_Mode = varargin{1};
         varargout{1} = getDispMode(Pop_Show_Mode);
end
%=========================================================================%
        


%=========================================================================%
%                       BEGIN Local Tool Utilities                        %
%                       --------------------------                        %
%=========================================================================%
%====================================================================
% typVAL_Num = zeros(nbSigInSEL,1);
%-----------------------------------
% typVAL = 's'  ==> typVAL_Num(idx) = 0;
% typVAL = 'a'  ==> typVAL_Num(idx) = 1;
% typVAL = 'd'  ==> typVAL_Num(idx) = 2;
% typVAL = 'ca' ==> typVAL_Num(idx) = 3;
% typVAL = 'cd' ==> typVAL_Num(idx) = 4;
%------------------------------------------
% typSIG_Num =  zeros(nbSigInSEL,1)
%-----------------------------------
% typSIG = 'ori' ==> typSIG_Num(idx) = 0;
% typSIG = 'den' ==> typSIG_Num(idx) = 1;
% typSIG = 'cmp' ==> typSIG_Num(idx) = 2;
% typSIG = 'res' ==> typSIG_Num(idx) = 3;
% Attrb_Lst_In_SEL = [num_SEL,num_SIG,typVAL_Num,levVAL,typSIG_Num];
%====================================================================
function [signal,varargout] = get_SIG_DEC(caller,fig,idxSEL,varargin)

Attrb_Lst_In_SEL = wtbxappdata('get',fig,'Attrb_Lst_In_SEL');
Attrb_SIG   = Attrb_Lst_In_SEL(idxSEL,:);
idx_SIG = Attrb_SIG(2);
typ_VAL = Attrb_SIG(3);
typ_SIG = Attrb_SIG(5);
switch typ_SIG
    case {0,1,2}
        if typ_SIG==0 , str_TYPE = 'ORI'; else str_TYPE = 'DorC'; end
        switch caller
            case 'SIG'
                val_RAD = varargin{1};
                switch val_RAD
                    case 0
                        sig_CLU = wtbxappdata('get',fig,'data_To_Clust');
                        signal  = sig_CLU(idxSEL,:);
                    case 1
                        data_SEL = mdw1dutils('data_INFO_MNGR','get',fig,'SEL');
                        signal = data_SEL.sel_DAT(idxSEL,:);
                end                
                switch typ_SIG
                    case 0     , type_S = 'ORI';
                    case {1,2} , type_S = 'DorC';
                end                
                switch typ_VAL
                    case 0 ,     type_V = 'SIG';
                    case {1,3} , type_V = 'APP';
                    case {2,4} , type_V = 'DET';
                end
                varargout = {type_S,type_V};

            case 'DEC'
                lev_DEC = varargin{1};
                data = mdw1dutils('data_INFO_MNGR','get',fig,str_TYPE);                
                signal = data.signal(idx_SIG,:);
                approx = mdwtrec(data.dwtDEC,'a',lev_DEC,idx_SIG);
                details = cell(1,lev_DEC);
                for k=1:lev_DEC
                    details{k} = mdwtrec(data.dwtDEC,'d',k,idx_SIG);
                end
                varargout = {approx,details};
                
            case {'decCfs','lvlThr'}
                lev_DEC = varargin{1};
                data = mdw1dutils('data_INFO_MNGR','get',fig,str_TYPE);                
                signal = data.signal(idx_SIG,:);
                lenSIG = size(signal,2);
                approx = mdwtrec(data.dwtDEC,'ca',lev_DEC,idx_SIG);
                lenAPP = size(approx,2);
                idxAPP = sort(repmat((1:lenAPP),1,2^lev_DEC));
                approx = wkeep(approx(1,idxAPP),[1,lenSIG]);
                details = cell(1,lev_DEC);
                for k=1:lev_DEC
                    details{k} = mdwtrec(data.dwtDEC,'cd',k,idx_SIG);
                    lenDET = size(details{k},2);
                    idxDET = sort(repmat((1:lenDET),1,2^k));
                    details{k} = wkeep(details{k}(1,idxDET),[1,lenSIG]);
                end
                varargout = {approx,details};

            case {'glbThr','perfL2N0'}
                data = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
                signal = data.signal(idx_SIG,:);
                data = mdw1dutils('data_INFO_MNGR','get',fig,'DorC');
                sigDorC = data.signal(idx_SIG,:);
                varargout = {sigDorC,idx_SIG};
                
            case 'TREE'
                lev_DEC = varargin{1};
                data = mdw1dutils('data_INFO_MNGR','get',fig,str_TYPE);
                signal = data.signal(idx_SIG,:);                
                typSIG = wtbxappdata('get',fig,'Tree_SEL');
                if ~isempty(typSIG)
                    if isequal(typSIG,'a')
                        a_or_d = mdwtrec(data.dwtDEC,'a',lev_DEC,idx_SIG);
                        type_V = 'APP';
                    else
                        type_V = 'DET';
                        a_or_d = mdwtrec(data.dwtDEC,'d',lev_DEC,idx_SIG);
                    end
                else
                    a_or_d = [];
                    type_V = 'NUL';
                end
                varargout = {a_or_d,type_V};
        end
        
    case 3
        [data_ORI,data_DorC] = ...
            mdw1dutils('data_INFO_MNGR','get',fig,'ORI','DorC');
        sig_ORI  = data_ORI.signal;
        sig_DorC = data_DorC.signal;
        signal   = sig_ORI(idx_SIG,:) - sig_DorC(idx_SIG,:);
        varargout = {'RES','SIG'};
end
%--------------------------------------------------------------------------
function [DorC_FLAG,typVAL,levVAL,idx] = data_ID(Lst,typeOfData,level,idx)

if level==0
    DorC_FLAG = false; typVAL = {'s'}; levVAL = 0; return
end
if isempty(idx)
    idx = get(Lst,'UserData');
    if isempty(idx) , idx = 1; end
end

switch typeOfData
    case 'cfs'
        S = get(Lst,'String');
        S = S(idx);
        T = char(S);
        absT = abs(T);
        idxNUM = str2num(T((absT>47 & absT<58))); %#ok<ST2NM>
        N = hist(idxNUM,(0.5:level+0.5));
        [nbSEL,idxMaxi] = max(N);
        idxKept = (idxNUM==idxMaxi);
        idx     = idx(idxKept);
        S_Kept = S(idxKept,:);
        DorC_FLAG = strncmp(S_Kept,'DEN',3) | strncmp(S_Kept,'CMP',3);
        DorC_FLAG = DorC_FLAG(:)';
        levVAL    = repmat(idxMaxi,nbSEL,1);
        typVAL    = cell(1,nbSEL);
        for k = 1:nbSEL
            if strfind(S_Kept{k},'APP')
                typVAL{k} = 'ca';
            else
                typVAL{k} = 'cd';
            end
        end
 
    case 'sig'
        maxVAL = 2*level+1;
        lenIDX = length(idx);
        DorC_FLAG = (idx>maxVAL);
        idxVAL = idx-1;
        typVAL = cell(1,lenIDX);
        idxVAL(DorC_FLAG) = idxVAL(DorC_FLAG)-maxVAL;
        levVAL = rem(idxVAL,level);
        levVAL(levVAL==0) = level;
        typDAT = fix((idxVAL-1)/level);
        typVAL(typDAT==0) = {'a'};
        typVAL(typDAT==1) = {'d'};
        typVAL(idxVAL==0) = {'s'};
        levVAL(idxVAL==0) = 0;
        idxRES = find(idx>(4*level+2));
        if ~isempty(idxRES)
            levVAL(idxRES) = NaN;
            typVAL{idxRES} = 's';
            DorC_FLAG(idxRES) = 1;
        end
end
set(Lst,'Value',idx,'UserData',idx);
%--------------------------------------------------------------------------
function set_idxSIG_Plot(fig,handles,idxSIG_Plot)

wtbxappdata('set',fig,'idxSIG_Plot',idxSIG_Plot);
tool_NAME = blockdatamngr('get',fig,'tool_ATTR','Name');
% if isequal(tool_NAME,'PAR')
% %     Attrb_Lst_In_SEL = [num_SEL,num_SIG,typVAL_Num,levVAL,typSIG_Num];
% %     wtbxappdata('set',fig,'Attrb_Lst_In_SEL',Attrb_Lst_In_SEL);
%     return;
% end
if ~isempty(idxSIG_Plot)
    if ~isequal(tool_NAME,'PAR')
        Attrb_Lst_In_SEL = wtbxappdata('get',fig,'Attrb_Lst_In_SEL');
        num_InBlocs = Attrb_Lst_In_SEL(idxSIG_Plot,2);
        idxSIG_SEL  = unique(num_InBlocs);
    else
        idxSIG_SEL = idxSIG_Plot;
    end
else
    idxSIG_SEL = [];
end
wtbxappdata('set',fig,'idxSIG_SEL',idxSIG_SEL);

if length(idxSIG_Plot)<1   % < 2
    ena_SIG = 'Off'; ena_DEC = 'Off'; 
else
    ena_SIG = 'On';
    dispName = getDispMode(handles.Pop_Show_Mode);
    switch dispName
        case {'sup','sta'} , ena_DEC = get(handles.Pop_HIG_DEC,'Enable');
        case {'dec','tree','glbThr','perfL2N0','sep','lvlThr','decCfs'} ,
            ena_DEC = 'On';
        case {'stem','stemAbs','stemSqr','stemEner'} , ena_DEC = 'Off';
    end
end
set([handles.Pus_AFF_NON,handles.Pop_HIG_SIG,handles.Txt_HIG_SIG],...
    'Enable',ena_SIG);
set([handles.Pop_HIG_DEC,handles.Txt_HIG_DEC],'Enable',ena_DEC);
strPOP = num2cell(int2str(idxSIG_Plot(:)),2)';
strPOP = ['none',strPOP];
set([handles.Pop_HIG_SIG,handles.Pop_HIG_DEC],'String',strPOP,'Value',1);
[tool_NAME,tool_STATE] = ...
    blockdatamngr('get',fig,'tool_ATTR','Name','State');
if ~isequal(tool_STATE,'INI') && ...
        (isequal(tool_NAME,'CMP') || isequal(tool_NAME,'DEN'))
end
%--------------------------------------------------------------------------
function dispName = getDispMode(Pop_Show_Mode)

% tool_ATTR = blockdatamngr('get',get(Pop_Show_Mode,'Parent'),'tool_ATTR');
% dispMode  = blockdatamngr('get',get(Pop_Show_Mode,'Parent'),'tool_ATTR','dispMode');
% [A,B] = blockdatamngr('get',get(Pop_Show_Mode,'Parent'), ...
%     'tool_ATTR','Name','dispMode');

num = get(Pop_Show_Mode,'Value');
lst = get(Pop_Show_Mode,'String');
nam = lower(lst{num});
switch nam(1)
    case 't' , dispName = 'tree';
    case 'l' , dispName = 'perfL2N0';
    case 'g' , dispName = 'glbThr';
    case 'b' , dispName = 'lvlThr';
    case 'f'
        if length(nam)<14 , dispName = 'dec';
        else dispName = 'decCfs';
        end
    case 'm'
        if isequal(nam(1:3),'mag') ,  % Magnify ...
            dispName = 'sta';
        elseif isequal(nam(1:3),'man')
            if ~isempty(strfind(nam,'lvl'))
                dispName = 'lvlThr';
            else
                dispName = 'glbThr';
            end
        end
    case 's'
        if     isequal(nam(1:3),'sep') , dispName = 'sep';
        elseif isequal(nam(1:3),'sup') , dispName = 'sup';
        else        % if isequal(nam(1:9),'stem mode')
            if length(nam)<12 , dispName = 'stem';
            elseif isequal(nam(12:14),'abs') , dispName = 'stemAbs';
            elseif isequal(nam(12:14),'squ') , dispName = 'stemSqr';
            elseif isequal(nam(12:14),'ene') , dispName = 'stemEner';
            else   dispName = 'stem';
            end
        end
    otherwise , dispName = 'none';
end
%--------------------------------------------------------------------------
function setDispMode(Pop_Show_Mode,dispName)

% tool_ATTR = blockdatamngr('get',get(Pop_Show_Mode,'Parent'),'tool_ATTR');

lst = get(Pop_Show_Mode,'String');
lastITEM_Flag = isequal(lst{end}(1:3),'Man');
nam = lower(lst);
switch dispName
    case 'sep' ,      idx = strncmpi(nam,'sep',3);
    case 'sup' ,      idx = strncmpi(nam,'sup',3);
    case 'sta' ,      idx = strncmpi(nam,'mag',3);
    case 'decCfs' ,   idx = strncmpi(nam,'full dec mode (cfs)',19);
    case 'dec' ,      idx = find(strcmp('full dec mode',nam));
    case 'stemAbs' ,  idx = strncmpi(nam,'stem mode (abs)',15);
    case 'stemSqr' ,  idx = strncmpi(nam,'stem mode (squa',15);
    case 'stemEner' , idx = strncmpi(nam,'stem mode (ener',15);
    case 'stem' ,     idx = find(strcmp('stem mode',nam));
    case 'tree' ,     idx = strncmpi(nam,'tr',2);
    case {'glbThr','glbThr_END'} , idx = NaN;  
    case {'lvlThr','lvlThr_END'} , idx = NaN;
    case 'perfL2N0' , idx = strncmpi(nam,'l',1);
    case 'none',      idx = strncmpi(nam,'-',1);
end

if ~isnan(idx)
    if ~(isequal(dispName,'dec') || isequal(dispName,'stem'))
        num = find(idx);
    else
        num = idx;
    end
    set(Pop_Show_Mode,'Value',num,'Enable','On');
    if lastITEM_Flag , set(Pop_Show_Mode,'String',lst(1:end-1)); end
else
    num = [];
    typeSTR = upper(dispName(1:3));
    switch dispName
        case {'glbThr','lvlThr'}
            switch  typeSTR
                case 'LVL' , lastITEM_Str = 'Man. Thr. Tuning (LVL)';
                case 'GLB' , lastITEM_Str = 'Man. Thr. Tuning (GLB)';
            end
            if ~lastITEM_Flag
                lst = [lst ; lastITEM_Str];
            else
                lst{end} = lastITEM_Str;
            end;
            set(Pop_Show_Mode,'String',lst,'Value',length(lst),'Enable','Off'); 
            
        case {'glbThr_END','lvlThr_END'}
            switch typeSTR
                case 'LVL' , num = 5;
                case 'GLB' , num = 12;
            end
            if lastITEM_Flag , lst = lst(1:end-1); end
            set(Pop_Show_Mode,'Value',num,'String',lst,'Enable','On');
    end
end
%--------------------------------------------------------------------------
function set_Tool_View(handles,tool_NAME,typeCALL,num_VIEW,ARG) %#ok<INUSD>

view_ATTRB = get(handles.Pan_Selected_DATA,'UserData');
%-------------------------------------------
% view_ATTRB.Curr - Num of Current View
% view_ATTRB.Prev - Num of Previous View
% view_ATTRB.Hndl - Handles
% view_ATTRB.Pos  - Different Positions
%-------------------------------------------
if isequal(typeCALL,'Reset')
    init_OPT = num_VIEW;
    switch tool_NAME
        case 'ORI'
            str_PopMode = get(handles.Pop_VisPanMode,'String');
            nbMode = length(str_PopMode);
            str_PopMode = '';
            if nbMode<=2 && isequal(init_OPT,'DEC')
                str_PopMode = {'Superimpose Mode','Separate Mode',...
                    '-------------------',...
                    'Full Dec Mode','Full Dec Mode (Cfs)',...
                    'Stem Mode','Stem Mode (Abs)','Stem Mode (Squared)',...
                    'Stem Mode (Energy Ratio)','Tree Mode'};
            elseif nbMode>2 && isequal(init_OPT,'LOAD')
                str_PopMode = {'Superimpose Mode','Separate Mode'};
            end
            if ~isempty(str_PopMode)
                set(handles.Pop_VisPanMode,'String',str_PopMode);
                set(handles.Pop_Show_Mode,'String',str_PopMode);
            end
            if nargin<5
                set(handles.Lst_SIG_DATA,...
                    'String',{getWavMSG('Wavelet:mdw1dRF:Orig_Signals')}, ...
                    'Value',1)
            end
    end
    set(handles.Pop_VisPanMode,'Value',1);
    set(handles.Pop_Show_Mode,'Value',1);
    set(handles.Pan_VISU_DEC,'Visible','Off')
    set(handles.Pan_VISU_SIG,'Visible','On')
    typeCALL = 'Force';
    num_VIEW = 1;
end
switch tool_NAME
    case 'STA' , largeVIEW = [1,3,5];
    otherwise  , largeVIEW = 1;
end
cur_VIEW = view_ATTRB.Curr;
flag_VIEW = false;
switch typeCALL
    case 'Force'
        flag_VIEW = true;
        
    case 'Show_DEC'
        if ismember(cur_VIEW,largeVIEW)
            flag_VIEW = true;
            num_VIEW = 2; 
        end
       
    case 'Close_DEC'
        if ~ismember(cur_VIEW,largeVIEW)
            flag_VIEW = true;
            num_VIEW  = 1;
        end

    case 'set_VIEW'
        flag_VIEW = true;
        switch num_VIEW
            case 'LARGE' , num_VIEW = 1;
            case 'INIT'  , num_VIEW = 2;
        end
        if isequal(num_VIEW,view_ATTRB.Curr) , return; end
        if ismember(num_VIEW,largeVIEW)
            vis = get(handles.Pan_VISU_DEC,'Visible');
            if isequal(lower(vis),'on')
                fig = handles.Current_Fig;
                switch tool_NAME
                    case {'ORI','CMP','DEN','STA'}
                        set_Tool_View(handles,tool_NAME,'Reset','Recursion')
                        dynvtool('get',fig,0');
                        axe_IND = [];
                        axe_CMD = handles.Axe_VISU;
                        axe_ACT = [];
                        dynvtool('init',fig,axe_IND,...
                            axe_CMD,axe_ACT,[1 0],'','','','real');

                    case 'CLU'
                        set(handles.Pop_VisPanMode,'Value',1)
                        mdw1dclus('Set_Pos_Pan',fig,[],handles,'Close_DEC')
                end
            elseif isequal(tool_NAME,'STA')
                if (cur_VIEW==3) && (num_VIEW==1)
                    set(handles.Pop_VisPanMode,'Value',1)
                end
            end
        else
            view_ATTRB.Prev = cur_VIEW;
        end
        view_ATTRB.Curr = num_VIEW;
        set(handles.Pan_Selected_DATA,'UserData',view_ATTRB);
end

if flag_VIEW
    pos_PAN = view_ATTRB.Pos{num_VIEW};
    for k = 1:size(pos_PAN,1)
        set(view_ATTRB.Hndl(k),'Position',pos_PAN(k,:));
    end
    if isequal(tool_NAME,'STA')
        cbar = findobj(handles.Pan_VISU_STATS,'Tag','CBAR_InStatPAN');
        delete(cbar)
    end
    view_ATTRB.Prev = view_ATTRB.Curr;
    view_ATTRB.Curr = num_VIEW;
    set(handles.Pan_Selected_DATA,'UserData',view_ATTRB);
end
%--------------------------------------------------------------------------
function  view_ATTRB = init_Tool_View(handles,tool_NAME)

hdl_Names = {...
    'Pan_VISU_SIG' ,      'Pan_VISU_DEC' , 'Pan_MAN_THR'  , ...
    'Pan_Selected_DATA' , 'Edi_TIT_SEL'  , 'Fra_SEL_DATA' , ...
    'Txt_SEL_DATA' ,      'Lst_SEL_DATA' ,  ...
    'Edi_NB_SIG' ,        'Pan_SORT'     ,  ...
    'Pus_AFF_ALL' ,       'Pus_AFF_NON'  , 'Pus_IMPORT'   ...
    };
switch tool_NAME
    case 'ORI' , hdl_Names{3} = 'Pan_SEL_INFO';
    case {'CMP','DEN','CLU'} ,
    case 'STA' ,
        hdl_Names{3}  = 'Pan_VISU_STATS';
        hdl_Names{14} = 'Edi_TIT_STA';
        hdl_Names{15} = 'Pop_TYP_GRA';
        hdl_Names{16} = 'Axe_STATS';
end
nbFields = length(hdl_Names);
Hndl = zeros(nbFields,1);
pos_VIEW = cell(1,7);
pos_VIEW{1} = zeros(nbFields,4);
for k = 1:nbFields
    Hndl(k) = handles.(hdl_Names{k});
    pos_VIEW{1}(k,1:4) = get(handles.(hdl_Names{k}),'Position');
end
%------------------------------------------------
pos_VIEW{2} = pos_VIEW{1};
pos_VIEW{2}(4,2)= pos_VIEW{1}(2,2);
DEN_or_CMP = isequal(tool_NAME,'DEN') || isequal(tool_NAME,'CMP');
if ~DEN_or_CMP
    pos_VIEW{2}(3,2)= pos_VIEW{1}(1,2)+pos_VIEW{1}(1,4)-pos_VIEW{1}(3,4);
end
pos_VIEW{2}(4,1)= pos_VIEW{1}(1,1);
width   = pos_VIEW{1}(4,1) - pos_VIEW{1}(1,1) + pos_VIEW{1}(4,3);
rapport = width/pos_VIEW{1}(4,3);
pos_VIEW{2}(4,3) = width;
pos_VIEW{2}([6 7 8],1)  = pos_VIEW{1}([6 7 8],1)/rapport;
pos_VIEW{2}([6 7 8],3)  = 1-2*pos_VIEW{2}([6 7 8],1);
pos_VIEW{2}([5 9 10 11 12 13],3) = pos_VIEW{1}([5 9 10 11 12 13],3)/rapport;
pos_VIEW{2}([5 10],1) = 0.45*(1-pos_VIEW{2}([5 10],3));
pos_VIEW{2}(9,3) = 0.8*pos_VIEW{2}(9,3);
deltaW = pos_VIEW{2}(10,1)-pos_VIEW{2}(8,1)-pos_VIEW{2}(9,3);
pos_VIEW{2}(9,1) = pos_VIEW{2}(8,1)+0.5*deltaW;
xleft = pos_VIEW{2}(10,1)+pos_VIEW{2}(10,3);
remain = (1-xleft-pos_VIEW{2}(11,3)-pos_VIEW{2}(12,3)-pos_VIEW{2}(13,3))/2;
pos_VIEW{2}(11,1) = xleft+remain;
pos_VIEW{2}(12,1) = pos_VIEW{2}(11,1)+pos_VIEW{2}(11,3);
pos_VIEW{2}(13,1) = pos_VIEW{2}(12,1)+pos_VIEW{2}(12,3);
deltaH = pos_VIEW{1}(8,2)-pos_VIEW{1}(10,4);
yLOW   = 0.2*pos_VIEW{1}(10,2);
deltaH = deltaH-2*yLOW;
pos_VIEW{2}(10,2) = yLOW;
pos_VIEW{2}(8,[2,4]) = pos_VIEW{2}(8,[2,4]) + 1*deltaH*[-1 1];
pos_VIEW{2}([9 11 12 13],2) = yLOW + ...
    (pos_VIEW{2}(10,4)-pos_VIEW{2}([9 11 12 13],4))/2;
%------------------------------------------------
pos_VIEW{3} = pos_VIEW{1};
pos_VIEW{3}(4,2)= pos_VIEW{1}(2,2);
if ~DEN_or_CMP
    pos_VIEW{3}(3,2)= pos_VIEW{1}(1,2)+pos_VIEW{1}(1,4)-pos_VIEW{1}(3,4);
end
%--------------------------------------------------------------

switch tool_NAME
    case 'ORI'
        pos_VIEW = pos_VIEW([2 3 1]);
        
    case {'DEN','CMP'}
        pos_VIEW{4} = pos_VIEW{1};
        pos_VIEW{4}(4,[2,4]) = pos_VIEW{1}(2,[2,4]);
        ratio = pos_VIEW{1}(4,4)/pos_VIEW{1}(2,4);
        toREDIM = [5:7,9:13];
        pos_VIEW{4}(toREDIM,4) = ratio*pos_VIEW{1}(toREDIM,4);
        pos_VIEW{4}([9,10],2) = pos_VIEW{1}([9,10],2)*ratio;
        pos_VIEW{4}(6,2) = pos_VIEW{4}(5,2)-1.1*pos_VIEW{4}(6,4);
        pos_VIEW{4}(7,2) = pos_VIEW{4}(6,2)+ ...
            0.5*(pos_VIEW{4}(6,4)-pos_VIEW{4}(7,4));
        pos_VIEW{4}(8,2) = pos_VIEW{4}(9,2)+1.1*pos_VIEW{4}(9,4);
        pos_VIEW{4}(8,4) = 0.995*(pos_VIEW{4}(6,2)-pos_VIEW{4}(8,2));
        pos_VIEW = pos_VIEW([2 4 3 1]);
        
    case 'CLU'
        
    case 'STA'
        pos_VIEW{4} = pos_VIEW{1};
        pos_VIEW{4}(3,[1,3]) = pos_VIEW{1}(1,[1,3]);
        pos_VIEW{4}(3,4) = pos_VIEW{1}(4,4);
        rapport = pos_VIEW{4}(3,4)/pos_VIEW{1}(3,4);
        pos_VIEW{4}(14,4) = pos_VIEW{4}(14,4)/rapport;
        pos_VIEW{4}(14,2) = 1-pos_VIEW{4}(14,4)/2;
        pos_VIEW{4}(15,[2 4]) = pos_VIEW{4}(15,[2 4])/rapport;
        pos_VIEW{4}(16,2) = 0.125;
        pos_VIEW{4}(16,4) = 0.775;
        %------------------------------------
        pos_VIEW{5} = pos_VIEW{1};
        idx_SAME_4 = [3,14,15,16];
        pos_VIEW{5}(idx_SAME_4,:) = pos_VIEW{4}(idx_SAME_4,:);
        idx_SAME_3 = 4;
        pos_VIEW{5}(idx_SAME_3,:) = pos_VIEW{3}(idx_SAME_3,:);
        %------------------------------------
        pos_VIEW = pos_VIEW([2 3 5 1 4]);
end
%--------------------------------------------------------
view_ATTRB.Curr = 1; % Num of Current View
view_ATTRB.Prev = 1; % Num of Previous View
view_ATTRB.Hndl = Hndl;
view_ATTRB.Pos  = pos_VIEW;
def_num_VIEW = 1;
set(handles.Pan_Selected_DATA,'UserData',view_ATTRB);
set_Tool_View(handles,tool_NAME,'Force',def_num_VIEW)
%=========================================================================%
%                        END Local Tool Utilities                         %
%=========================================================================%
