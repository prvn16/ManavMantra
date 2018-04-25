function mdw1dmisc(option,varargin)
%MDW1DMISC Discrete wavelet Multisignal 1D Utilities.
%   VARARGOUT = MDW1DMISC(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-Jun-2005.
%   Last Revision 29-Apr-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

handles = varargin{1};
switch option
    case 'clean'
        caller = varargin{2};
        switch caller
            case 'Pan_SEL_INFO' , Pan_SEL_INFO(varargin{3:end});
        end

    case 'show'
        caller = varargin{2};
        switch caller
            case 'MAN_THR'  , show_MAN_THR(varargin{3:end})
            case 'SIG_INFO' , show_SIG_INF(varargin{3:end})
        end

    case 'plot'
        plot_MNGR(varargin{2:end})

    case 'lst_DAT_SEL'
        lst_DAT_SEL(varargin{2:end})

    case 'chk_ONE_PLOT'
        chk_ONE_PLOT(varargin{2:end})

end
%--------------------------------------------------------------------------
    function Pan_SEL_INFO(step,varargin)
        edi_STAT = [handles.Edi_Min,handles.Edi_Mean,handles.Edi_Max];
        txt_STAT = [handles.Txt_Min,handles.Txt_Mean,handles.Txt_Max];
        edi_ENER = [handles.Edi_Energy,handles.Edi_PER_A,handles.Edi_PER_D];
        txt_ENER = [handles.Txt_Energy,handles.Txt_PER_A,handles.Txt_PER_D];
        switch step
            case {'ini','load'}
                set([edi_STAT,edi_ENER],'String','')
                delete(allchild(handles.Axe_INFO_VAL))
                set(handles.Axe_INFO_VAL,'Visible','Off')
                set(handles.Pan_ENERGY,'Visible','Off')
                set([txt_STAT,edi_STAT],'Visible','On')

            case 'dec'
                level = varargin{1};
                usr = get(handles.Pan_ENERGY,'UserData');
                Edi_D = usr{1}; pos_Edi = usr{2};
                Txt_D = usr{3}; pos_Txt = usr{4};
                h_L2A = usr{5}; pos_L2A = usr{6};
                % Handles in h_L2A:
                %    [Txt_Energy,Edi_Energy,Txt_PER_A,Edi_PER_A]
                numPos = fix((level+2)/3);
                pos_Edi = pos_Edi(:,:,numPos);
                pos_Txt = pos_Txt(:,:,numPos);
                pos_L2A = pos_L2A(:,:,numPos);

                set([edi_STAT,edi_ENER],'String','')
                delete(allchild(handles.Axe_INFO_VAL))
                set(handles.Axe_INFO_VAL,'Visible','Off')
                set(handles.Pan_ENERGY,'Visible','Off')
                set([txt_ENER,edi_ENER],'Visible','Off');
                set([txt_STAT,edi_STAT],'Visible','On')

                for k = 1:4 , set(h_L2A(k),'Position',pos_L2A(k,:)); end
                for k = 1:level
                    set(Edi_D(k),'Position',pos_Edi(k,:));
                    set(Txt_D(k),'Position',pos_Txt(k,:));
                end
                set(handles.Txt_PER_A,'String',['A' int2str(level)]);

                % Reverse Text Dj order (comment if NOT).
                %----------------------------------------
                for k = 1:level
                    j = level-k+1;
                    set(Txt_D(j),'String',['D' int2str(k)]);
                end
                %--------------------------------------------

                set([h_L2A ; Edi_D(1:level) ; Txt_D(1:level)],'Visible','On');
                set(handles.Pan_ENERGY,'Visible','On')

            case 'many_sig'
                set([txt_STAT,edi_STAT,handles.Pan_ENERGY],'Visible','Off');
                set(handles.Axe_INFO_VAL,'Visible','On')

            case 'one_sig'
                fig = handles.output;
                tool_State = blockdatamngr('get',fig,'tool_ATTR','State');
                delete(allchild(handles.Axe_INFO_VAL))
                set(handles.Axe_INFO_VAL,'Visible','Off')
                if isequal(tool_State,'ORI_ON') , vis = 'On'; else vis  = 'Off'; end
                set([txt_STAT,edi_STAT],'Visible','On')
                set(handles.Pan_ENERGY,'Visible',vis);
        end
    end
%--------------------------------------------------------------------------
    function show_MAN_THR(typeCALL,varargin)

        fig = handles.output;
        idxSIG_SEL = wtbxappdata('get',fig,'idxSIG_SEL');
        nbSigInSEL = length(idxSIG_SEL);
        if nbSigInSEL<1 , return; end

        switch typeCALL
            case {'INI','INI_GLB'}
                threshold = blockdatamngr('get',fig,...
                    'data_DorC','threshold');
                tab_THR = threshold(sort(idxSIG_SEL),:);
                strPOP = num2cell(int2str(idxSIG_SEL(:)),2);
                strPOP = [getWavMSG('Wavelet:commongui:Str_All');strPOP];
                nbSTR = length(strPOP);
                if nbSTR>1 , valPOP = 2; else valPOP = 1; end
                set(handles.Pop_MAN_SIG,'String',strPOP,'Value',valPOP);
                set(handles.Pop_MAN_LEV,'Value',2);
                set(handles.Edi_MAN_THR,'String',num2str(tab_THR(1,1)));
                % cmp_SCORES = wtbxappdata('get',fig,'cmp_SCORES');
                % if ~isempty(cmp_SCORES)
                    % thresVALUES = cmp_SCORES{1};
                    % thrMAXI = thresVALUES(:,end);
                    % L2SCR = cmp_SCORES{2};
                    % N0SCR = cmp_SCORES{3};
                % end
                strPOP = num2cell(int2str(idxSIG_SEL(:)),2);
                strPOP = ['none';strPOP];
                set([handles.Pop_HIG_SIG,handles.Pop_HIG_DEC],...
                    'String',strPOP,'Value',1);

            case {'LIN_GLB','EDI_GLB','EDI_L2','EDI_N0'}
                input_VAL = varargin{end};
                tab_THR = get(handles.Pan_MAN_THR,'UserData');
                axeAct = handles.Axe_VIS_DEC;
                LinL2 = findobj(axeAct,'Tag','LinL2');
                % LinN0 = findobj(axeAct,'Tag','LinN0');
                LinTHR = findobj(axeAct,'Tag','LinTHR');
                cmp_SCORES = wtbxappdata('get',fig,'cmp_SCORES');
                thresVALUES = cmp_SCORES{1}; % {thresVALUES,L2SCR,n0SCR,idx_SORT});
                thrMAXI = thresVALUES(:,end);
                L2SCR = cmp_SCORES{2};
                N0SCR = cmp_SCORES{3};
                flag_SIG_SEL = isequal(oneSEL(handles.Pop_MAN_SIG),true);
                if flag_SIG_SEL
                    idxTAB = get(handles.Pop_MAN_SIG,'Value')-1;
                    % idxSIG = idxSIG_SEL(idxTAB);
                    LinL2 = findobj(LinL2,'UserData',idxTAB);
                    % LinN0 = findobj(LinN0,'UserData',idxTAB);
                    LinTHR = findobj(LinTHR,'UserData',idxTAB);
                    thrMAXI = thrMAXI(idxTAB);
                    L2SCR = L2SCR(idxTAB,:);
                    N0SCR = N0SCR(idxTAB,:);
                else
                    % idxSIG = idxSIG_SEL;
                end
                if isequal(typeCALL,'EDI_GLB')
                    Xdata = get(LinL2,'XData');
                    if iscell(Xdata) , Xdata = cat(1,Xdata{:}); end
                    thr_MAX = max(Xdata,[],2);
                    input_VAL = min(thr_MAX,input_VAL);
                    nbLinTHR = length(LinTHR);
                    idxMIN = zeros(1,nbLinTHR);
                    for k = 1:nbLinTHR
                        [~,idxMIN(k)] = min(abs(Xdata(k,:)-input_VAL(k)),[],2);
                        thrVAL =  input_VAL(k);
                        set(LinTHR(k),'XData', [input_VAL(k),input_VAL(k)]);
                        tab_THR(k,:) = input_VAL(k);
                    end
                    if flag_SIG_SEL
                        L2SCR = L2SCR(idxMIN); 
                        N0SCR = N0SCR(idxMIN);
                        show_THR_PERF(thrVAL,L2SCR,N0SCR);
                    end

                elseif isequal(typeCALL,'EDI_L2') || isequal(typeCALL,'EDI_N0')
                    switch typeCALL
                        case 'EDI_L2' , val_PERF = L2SCR;
                        case 'EDI_N0' , val_PERF = N0SCR;
                    end
                    [~,idxMIN] = min(abs(val_PERF-input_VAL),[],2);
                    for k = 1:length(LinTHR)
                        thrVAL = thresVALUES(k,idxMIN(k));
                        set(LinTHR(k),'XData', [thrVAL,thrVAL]);
                        tab_THR(k,:) = thrVAL;
                    end
                    if flag_SIG_SEL
                        L2SCR = L2SCR(idxMIN);
                        N0SCR = N0SCR(idxMIN);
                        show_THR_PERF(thrVAL,L2SCR,N0SCR);
                    end

                elseif isequal(typeCALL,'LIN_GLB')
                    thrVAL = min(thrMAXI,input_VAL);
                    nbLIN = length(LinTHR);
                    if ~flag_SIG_SEL
                        for k = 1:nbLIN
                            j = get(LinTHR(k),'UserData');
                            thr = thrVAL(j);
                            set(LinTHR(k),'XData',[thr,thr]);
                            tab_THR(j,:) = thr;
                        end
                    else
                        set(LinTHR,'XData',[thrVAL,thrVAL]);
                        tab_THR(idxTAB,:) = thrVAL;
                    end
                end

            case {'LIN','EDI'}
                thr_NEW = varargin{end};
                tab_THR = get(handles.Pan_MAN_THR,'UserData');
                level_DEC    = size(tab_THR,2);
                flag_SIG_SEL = isequal(oneSEL(handles.Pop_MAN_SIG),true);
                % flag_LEV_SEL = isequal(oneSEL(handles.Pop_MAN_LEV),true);
                level = get(handles.Pop_MAN_LEV,'Value')-1;
                if level>0
                    levSTR = int2str(level);
                    LU = findobj(handles.Axe_VIS_DEC,'Tag',['LU',levSTR]);
                    LD = findobj(handles.Axe_VIS_DEC,'Tag',['LD',levSTR]);
                else
                    hLINE = findobj(handles.Axe_VIS_DEC,'Type','line');
                    tag   = get(hLINE,'Tag');
                    idxL  = strncmp(tag,'LU',2);
                    LU    = hLINE(idxL);
                    idxL  = strncmp(tag,'LD',2);
                    LD    = hLINE(idxL);
                    level = 1:level_DEC;
                end
                if flag_SIG_SEL
                    idxTAB = get(handles.Pop_MAN_SIG,'Value')-1;
                    LU = findobj(LU,'UserData',idxTAB);
                    LD = findobj(LD,'UserData',idxTAB);
                    idxSIG = idxSIG_SEL(idxTAB);
                else
                    idxSIG = idxSIG_SEL;
                end

                if isequal(typeCALL,'EDI')
                    data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
                    signals  = data_ORI.signal(idxSIG,:);
                    yMini = min(min(signals));
                    yMaxi = max(max(signals));
                    yAbsMAX = max([abs(yMini),yMaxi]);
                    if thr_NEW>yAbsMAX , thr_NEW = yAbsMAX; end
                    set(LU,'YData', [thr_NEW,thr_NEW]);
                    set(LD,'YData',-[thr_NEW,thr_NEW]);
                end
                if flag_SIG_SEL
                    idxTAB = get(handles.Pop_MAN_SIG,'Value')-1;
                    tab_THR(idxTAB,level) = thr_NEW;
                else
                    tab_THR(:,level) = thr_NEW;
                end
        end
        set(handles.Pan_MAN_THR,'UserData',tab_THR);

        if ~isempty(varargin) && isequal(varargin{1},'LST') , return;  end
        tool_NAME = blockdatamngr('get',fig,'tool_ATTR','Name');
        if isequal(tool_NAME,'DEN') || isequal(tool_NAME,'CMP')
            threshold = blockdatamngr('get',fig,'data_DorC','threshold');
            threshold(idxSIG_SEL,:) = tab_THR;
            blockdatamngr('set',fig,'data_DorC','threshold',threshold);
            mdw1dafflst('DEN',[],[],handles,'init')
            set(handles.Lst_SEL_DATA,'Value',idxSIG_SEL)
        end

% Not used in the present version
%------------------------------------------------------------------------
%         switch typeCALL
%             case {'LIN','LIN_GLB'}
%                 if flag_SIG_SEL
%                     Val_Lst_MAN = varargin{end-1};
%                 else
%                     Val_Lst_MAN = (1:nbSigInSEL)';
%                 end
%             otherwise , Val_Lst_MAN = 1;
%         end
%         dispMode = mdw1dmngr('getDispMode',handles.Pop_Show_Mode);
% 
% 
%         if isequal(dispMode,'glbThr')
%             % Get Compression Parameters.
%             %--------------------------
%             val_S_or_H = get(handles.Rad_SOFT,'Value');
%             switch val_S_or_H
%                 case 0 , S_or_H = 'h';
%                 case 1 , S_or_H = 's';
%             end
%             field = 'Rad_YES';
%             if isfield(handles,field)
%                 keepAPP = logical(get(handles.(field),'Value'));
%             else
%                 keepAPP = 1;
%             end
% 
%             % Compressing or de-noising.
%             %---------------------------
%             data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
%             dwtDEC   = data_ORI.dwtDEC;
%             sig_CMP  = mswcmp('cmp',data_ORI.dwtDEC,...
%                 'man_thr',tab_THR,S_or_H,keepAPP,idxSIG_SEL);
%             [nbSIG,lenSIG] = size(sig_CMP);
% 
%             axeAct = handles.Axe_VIS_DEC(2);
%             if isequal(typeCALL,'INI_GLB')
%                 delete(findobj(axeAct,'Type','line'))
%                 axes(axeAct); hold on
%                 for k = 1:nbSIG
%                     plot(1:lenSIG,sig_CMP(k,:),...
%                                 'Color','m','UserData',idxSIG_SEL(k));
%                 end
%                 yMini = min(min(sig_CMP));
%                 yMaxi = max(max(sig_CMP));
%                 prec = 1.E-3;
%                 dY   = (yMaxi-yMini+prec)*0.05;
%                 yLIM = [yMini-dY,yMaxi+dY];
%                 set(axeAct,'YLim',yLIM);
%             else
%                 hdl_CMP = findobj(axeAct,'Type','line');
%                 nbSIG = length(idxSIG_SEL);
%                 for k = 1:nbSIG
%                     linCMP = findobj(hdl_CMP,'UserData',idxSIG_SEL(k));
%                     set(linCMP,'YData',sig_CMP(k,:));
%                 end
%             end
%             set(axeAct,'XLim',get(handles.Axe_VIS_DEC(1),'XLim'));
%         end
%------------------------------------------------------------------------

    end
%--------------------------------------------------------------------------
    function show_SIG_INF(typeCALL,inputVAL,hdl_POP)

        display_Mode = mdw1dmngr('getDispMode',handles.Pop_Show_Mode);
        if ~isequal(display_Mode,'glbThr') , return; end
        flag_MAN = get(handles.Pus_ENA_MAN,'UserData');
        if isequal(flag_MAN,true) , return; end
        
        switch typeCALL
            case 'POP'
                contents = get(hdl_POP,'String');
                currNum  = str2double(contents{inputVAL});
            case 'LST'
                currNum = inputVAL;
        end
        if isnan(currNum) , return; end  % All SIG

        fig = handles.output;
        idxSIG_Plot = wtbxappdata('get',fig,'idxSIG_Plot');
        idxTAB = find(idxSIG_Plot==currNum);
        cmp_SCORES = wtbxappdata('get',fig,'cmp_SCORES');
        % thresVALUES = cmp_SCORES{1};
        L2SCR = cmp_SCORES{2};
        N0SCR = cmp_SCORES{3};
        axeAct = handles.Axe_VIS_DEC;
        LinL2_TMP  = findobj(axeAct,'Tag','LinL2');
        LinTHR_TMP = findobj(axeAct,'Tag','LinTHR');
        nb_LIN  = length(LinTHR_TMP);
        if nb_LIN==0 , return; end

        if nb_LIN>1
            usr = get(LinL2_TMP,'UserData');
            if iscell(usr) , usr = cat(1,usr{:}); end
            [~,idxSORT] = sort(usr);
            LinL2_TMP = LinL2_TMP(idxSORT);
            LinTHR_TMP = LinTHR_TMP(idxSORT);
        end
        idx_TMP = zeros(1,nb_LIN);
        L2_TMP  = zeros(1,nb_LIN);
        N0_TMP  = zeros(1,nb_LIN);
        thr_TMP = zeros(nb_LIN,2);
        for k =1:nb_LIN
            thr_TMP(k,1:2) = get(LinTHR_TMP(k),'XData');
            [~,idx_TMP(k)] = ...
                min(abs(get(LinL2_TMP(k),'XData')-thr_TMP(k,1)));
            L2_TMP(k) = L2SCR(k,idx_TMP(k));
            N0_TMP(k) = N0SCR(k,idx_TMP(k));
        end
        show_THR_PERF(thr_TMP(idxTAB,1),L2_TMP(idxTAB),N0_TMP(idxTAB));
    end
%--------------------------------------------------------------------------
    function show_THR_PERF(val_THR,val_L2,val_N0)
        set(handles.Edi_MAN_GLB_THR,'String',num2str(val_THR(1),'%10.5f'))
        set(handles.Edi_L2_PERF,'String',num2str(val_L2,'%10.2f'))
        set(handles.Edi_N0_PERF,'String',num2str(val_N0,'%10.2f'))
    end
%--------------------------------------------------------------------------
    function plot_MNGR(typePLOT,varargin)

        if ~isequal(typePLOT,'all')
            typePLOT = 'none';
            fig = handles.output;
            tool_NAME = blockdatamngr('get',fig,'tool_ATTR','Name');
            if isequal(tool_NAME,'ORI') , Pan_SEL_INFO('ini'); end
        end

        hdl_LINES = findobj(handles.Axe_VISU,'Type','Line');
        delete(hdl_LINES)
        title(handles.Axe_VISU,'');
        dispName    = mdw1dmngr('getDispMode',handles.Pop_Show_Mode);
        axesToClean = handles.Axe_VIS_DEC;
        if isequal(dispName,'sep')
            if isequal(typePLOT,'none')
                set(axesToClean,'YTick',[]);
            end        
        elseif isequal(dispName,'tree')
            axesToClean(3) = []; 
        end
        child = allchild(axesToClean);
        if iscell(child) , child = cat(1,child{:}); end
        delete(child)
        field = 'Axe_STATS';
        if isfield(handles,field)
            delete(allchild(handles.(field)))
            title(handles.(field),'');
        end
        lst_DAT_SEL(typePLOT,varargin{:});
    end
%--------------------------------------------------------------------------
    function lst_DAT_SEL(varargin)
        fig = handles.Current_Fig;
        tool_NAME = ...
            blockdatamngr('get',fig,'tool_ATTR','Name');
        hdl_LST = handles.Lst_SEL_DATA;
        mousefrm(fig,'watch'); drawnow
        plot_MODE = blockdatamngr('get',fig,'tool_ATTR','plot_MODE');
        plot_MODE_AFF = '';
        idxSIG_Plot = wtbxappdata('get',fig,'idxSIG_Plot');
        nbin = length(varargin);
        
        % Appel par un clic sur une ligne de la liste
        if nbin<1 || isequal(varargin{1},'load')
            idxSIG = mdw1dafflst('get_idxSEL',hdl_LST,'index');
            switch plot_MODE
                case 'all_SIG'
                    chk_ONE_PLOT;

                case 'unique'
                    idxSIG_Plot = idxSIG;

                case 'multi'
                    reset_Flag = ~isempty(varargin) && ...
                            isequal(varargin{1},'Pus_STAT');
                    if ~reset_Flag
                        idxSIG_Plot = setxor(idxSIG_Plot,idxSIG(:));
                    end
                    idxSIG_Plot = idxSIG_Plot(:)';
                    mdw1dafflst('MARK',hdl_LST,idxSIG_Plot);
            end
            mdw1dmngr('set_idxSIG_Plot',fig,handles,idxSIG_Plot)
            %== A VOIR
            if isempty(idxSIG_Plot)
                plot_MNGR('none','clean');
                chk_ONE_PLOT
                return;
            end
            %== A VOIR
        else
            typePLOT = varargin{1};
            switch typePLOT
                case 'all'
                    idxSIG_Plot = mdw1dafflst('get_idxSEL',hdl_LST);
                    mdw1dmngr('set_idxSIG_Plot',fig,handles,idxSIG_Plot)
                    if isempty(idxSIG_Plot) , return; end
                    val_CHK = get(handles.Chk_AFF_MUL,'Value');
                    if val_CHK==0
                        set(hdl_LST,'Value',1:length(idxSIG_Plot));
                    else
                        set(hdl_LST,'Value',1);
                        mdw1dafflst('MARK',hdl_LST,idxSIG_Plot);
                    end
                    plot_MODE_AFF = 'all_SIG';

                case 'none'
                    idxSIG_Plot = [];
                    mdw1dmngr('set_idxSIG_Plot',fig,handles,idxSIG_Plot)
                    chk_ONE_PLOT;
                    mdw1dafflst('MARK',hdl_LST,[]);
                    mousefrm(fig,'arrow');
                    return;
            end
        end
        data_SEL = mdw1dutils('data_INFO_MNGR','get',fig,'SEL');
        if isfield(handles,'Rad_AFF_SIG')
            val_AFF = get(handles.Rad_AFF_SIG,'Value');
        else
            val_AFF = 1;
        end
        switch val_AFF
            case 0 , Signaux_Traites = wtbxappdata('get',fig,'data_To_Clust');
            case 1 , Signaux_Traites = data_SEL.sel_DAT;
        end
        if isequal(tool_NAME,'PAR')
            Signaux_Traites = blockdatamngr('get',fig,'data_SEL','sel_DAT');
        end
        if isempty(Signaux_Traites) , return; end
        
        NbPts = size(Signaux_Traites,2);
        nbSIG = length(idxSIG_Plot);
        tmpIDX = idxSIG_Plot(:)';
        if nbSIG<1
            strTIT = '';
        elseif nbSIG<2
            strTIT = ...
                getWavMSG('Wavelet:mdw1dRF:Selection_Ind',int2str(tmpIDX));
        elseif nbSIG<8
            strTIT = ...
                getWavMSG('Wavelet:mdw1dRF:Selection_IndS',int2str(tmpIDX));
        elseif nbSIG<Inf
            tmpSTR = int2str(tmpIDX(1:nbSIG));
            Len = length(tmpSTR);
            k = 1;
            while (Len>39) && (k<nbSIG)
                tmpSTR = int2str(tmpIDX(1:nbSIG-k));
                Len = length(tmpSTR);
                k = k+1;
            end
            if k>1 , tmpSTR = [tmpSTR , ' ...']; end
            strTIT = getWavMSG('Wavelet:mdw1dRF:Selection_IndS',tmpSTR);
        end
        if isequal(plot_MODE_AFF,'all_SIG')
            strTIT = getWavMSG('Wavelet:mdw1dRF:All_Signals');
            type_AFF_ALL = wtbxappdata('get',fig,'type_AFF_ALL');
            type_AFF_Name = type_AFF_ALL{1};
            type_AFF_Para = type_AFF_ALL{2};
            switch type_AFF_Name
                case 'init'
                case 'clu_SEL'
                    if type_AFF_Para>0
                        str_NUMCLA = '[ ';
                        for k = 1:2
                            num = type_AFF_Para(k);
                            if isinf(num)
                                sTMP = '(=>12)';
                            else
                                sTMP = int2str(num);
                            end
                            if k==2 , str_NUMCLA = [str_NUMCLA ' ,']; end %#ok<AGROW>
                            str_NUMCLA = [str_NUMCLA ' ' sTMP]; %#ok<AGROW>
                        end
                        str_NUMCLA = [str_NUMCLA , ' ]'];
                        strTIT = ...
                            getWavMSG('Wavelet:mdw1dRF:Selection_CLAS',str_NUMCLA);
                    end
                case 'links'
                    strTIT = getWavMSG('Wavelet:mdw1dRF:Selection_LINKS');
                case 'dendro_all'
                    strTIT = getWavMSG('Wavelet:mdw1dRF:Selection_FDendro');
                case 'dendro_res'
                    strTIT = getWavMSG('Wavelet:mdw1dRF:Selection_RDendro');
                case 'kmeans'
                    strTIT = getWavMSG('Wavelet:mdw1dRF:Selection_Kmeans');
                otherwise
            end
            strTIT = [strTIT ' - ' get(handles.Edi_NB_SIG,'String')];
        end

        dynvtool('get',fig,0'); mngmbtn('delLines',fig,'All');
        axeAct = handles.Axe_VISU;
        % axes(axeAct);
        
        if nbSIG>0
            %### CORRECTION A FAIRE ###% 
            % POUR VOIR LES SIGNAUX COMPRESSES
            toolCOL = mdw1dutils('colors');
            sigCOL = toolCOL.sig; d_OR_c_sigCOL = toolCOL.d_OR_c;
            appCOL = toolCOL.app; d_OR_c_appCOL = 0.7*appCOL;
            detCOL = toolCOL.det; d_OR_c_detCOL = 0.65*detCOL;
            resCOL = toolCOL.res;
            %==========================================================
            % sigType = {'o','d','c','r'};
            % dwtType = {'S','A','D','a','d'};
            %==========================================================
            if ~isequal(tool_NAME,'PAR')
                [dwtType,sigType] = ...
                    mdw1dutils('get_Sig_IDENT',fig,idxSIG_Plot);
                id_SIG = dwtType=='S';
                id_APP = dwtType=='A' | dwtType=='a';
                id_DET = dwtType=='D' | dwtType=='d';
                id_ORI = sigType=='o';
                id_CoD = (sigType=='c' | sigType=='d');
            else
                id_SIG  = ones(nbSIG,1); id_ORI = id_SIG;
                id_SIG  = 1; id_APP = 0; id_DET = 0; id_CoD = 0;
                sigType = 'o';
            end
            id_SIG_ORI = id_SIG & id_ORI;
            id_APP_ORI = id_APP & id_ORI;
            id_DET_ORI = id_DET & id_ORI;
            id_SIG_CoD = id_SIG & id_CoD;
            id_APP_CoD = id_APP & id_CoD;
            id_DET_CoD = id_DET & id_CoD;
            id_SIG_RES = id_SIG & sigType=='r';
            if isequal(plot_MODE,'multi')
                firstPlot = true;
                nextp = get(axeAct,'NextPlot');
                set(axeAct,'NextPlot','ReplaceChildren');
                if any(id_SIG_ORI)
                    plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_SIG_ORI),:)',...
                        'Color',sigCOL);
                    firstPlot = false;
                end
                if any(id_SIG_CoD)
                    if firstPlot
                        set(axeAct,'NextPlot','ReplaceChildren');
                    else
                        set(axeAct,'NextPlot','Add');
                    end
                    plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_SIG_CoD),:)', ...
                        'Color',d_OR_c_sigCOL,'Parent',axeAct);
                    firstPlot = false;
                end
                if any(id_SIG_RES)
                    if firstPlot
                        set(axeAct,'NextPlot','ReplaceChildren');
                    else
                        set(axeAct,'NextPlot','Add');
                    end
                    plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_SIG_RES),:)',...
                        'Color',resCOL,'Parent',axeAct);
                    firstPlot = false;
                end
                if any(id_APP)
                    if firstPlot
                        set(axeAct,'NextPlot','ReplaceChildren');
                    else
                        set(axeAct,'NextPlot','Add');
                    end
                    plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_APP),:)',...
                        'Color',appCOL,'Parent',axeAct);
                    firstPlot = false;
                end
                set(axeAct,'NextPlot',nextp);
                if any(id_DET)
                    if firstPlot
                        set(axeAct,'NextPlot','ReplaceChildren');
                    else
                        set(axeAct,'NextPlot','Add');
                    end
                    plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_DET),:)',...
                        'Color',detCOL,'Parent',axeAct);
                end
                set(axeAct,'NextPlot',nextp);
            else
                firstPlot = true;
                nextp = get(axeAct,'NextPlot');
                set(axeAct,'NextPlot','ReplaceChildren');
                if any(id_SIG)
                    if any(id_SIG_ORI)
                        plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_SIG_ORI),:)',...
                            'Color',sigCOL,'Parent',axeAct);
                        firstPlot = false;
                    end
                    if any(id_SIG_CoD)
                        if firstPlot
                            set(axeAct,'NextPlot','ReplaceChildren');
                        else
                            set(axeAct,'NextPlot','Add');
                        end
                        plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_SIG_CoD),:)',...
                            'Color',d_OR_c_sigCOL,'Parent',axeAct);
                        firstPlot = false;
                    end
                    if any(id_SIG_RES)
                        if firstPlot
                            set(axeAct,'NextPlot','ReplaceChildren');
                        else
                            set(axeAct,'NextPlot','Add');
                        end
                        plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_SIG_RES),:)',...
                            'Color',resCOL,'Parent',axeAct);
                        firstPlot = false;
                    end
                end
                if any(id_APP)
                    if any(id_APP_ORI)
                        if firstPlot
                            set(axeAct,'NextPlot','ReplaceChildren');
                        else
                            set(axeAct,'NextPlot','Add');
                        end
                        plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_APP_ORI),:)',...
                            'Color',appCOL,'Parent',axeAct);
                        firstPlot = false;
                    end
                    if any(id_APP_CoD)
                        if firstPlot
                            set(axeAct,'NextPlot','ReplaceChildren');
                        else
                            set(axeAct,'NextPlot','Add');
                        end
                        plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_APP_CoD),:)',...
                            'Color',d_OR_c_appCOL,'Parent',axeAct);
                        firstPlot = false;
                    end
                end
                if any(id_DET)
                    if any(id_DET_ORI)
                        if firstPlot
                            set(axeAct,'NextPlot','ReplaceChildren');
                        else
                            set(axeAct,'NextPlot','Add');
                        end
                        plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_DET_ORI),:)',...
                            'Color',detCOL);
                        firstPlot = false;
                    end
                    if any(id_DET_CoD)
                        if firstPlot
                            set(axeAct,'NextPlot','ReplaceChildren');
                        else
                            set(axeAct,'NextPlot','Add');
                        end
                        plot(1:NbPts,Signaux_Traites(idxSIG_Plot(id_DET_CoD),:)',...
                            'Color',d_OR_c_detCOL,'Parent',axeAct);
                    end
                end
                set(axeAct,'NextPlot',nextp);
            end
            yMini = min(min(Signaux_Traites(idxSIG_Plot,:)));
            yMaxi = max(max(Signaux_Traites(idxSIG_Plot,:)));
            dY   = (yMaxi-yMini+1.E-3)*0.05;
            set(axeAct,'YLim',[yMini-dY,yMaxi+dY]);
            % data_ORI = mdw1dutils('data_INFO_MNGR','get',fig,'ORI');
        else
            hdl_LINES = findobj(axeAct,'Type','Line');
            delete(hdl_LINES)
            % ENA_and_VIS = 'Off';
        end
        if NbPts>1 , set(axeAct,'XLim',[1 NbPts]); end
        title(handles.Axe_VISU,strTIT);
        wtbxappdata('set',fig,'Index_SIG_LST',idxSIG_Plot);
        tool_NAME = blockdatamngr('get',fig,'tool_ATTR','Name');
        axe_IND = []; axe_CMD = handles.Axe_VISU; axe_ACT = [];
        dynvtool_ARGS = {axe_IND,axe_CMD,axe_ACT,[1,0],'','','','real'};
        switch tool_NAME
            case 'CLU'
                vis = get(handles.Pan_View_PART,'Visible');
                if strcmpi(vis,'On')
                    dynvtool_ARGS = wtbxappdata('get',fig,'dynvtool_ARGS');
                end
            case 'PAR'
            otherwise , dynvtool_ARGS{1} = handles.Axe_VIS_DEC;
        end
        dynvtool('init',fig,dynvtool_ARGS{:});
        if isequal(get(handles.Pan_VISU_DEC,'Visible'),'on')
            mdw1dshow('Show_DEC_Fun',fig,[],handles,'LST',tool_NAME);
        end
        
        if ~isempty(idxSIG_Plot)
            currNUM = idxSIG_Plot(1);
            currSIG = Signaux_Traites(currNUM,:);
            switch tool_NAME
                case 'ORI'
                    mdw1dtool('show_Sig_Info',hdl_LST,[],handles,...
                        currNUM,currSIG,nbSIG);

                case 'STA'
                    mdw1dstat('Pop_TYP_GRA_Callback',handles.Pop_TYP_GRA,...
                        [],handles,'INI',currNUM,currSIG,nbSIG);

                case {'CMP','DEN'}
                    tool_STATE = blockdatamngr('get',fig,'tool_ATTR','State');
                    show_SIG_INF('LST',currNUM)
                    if ~isequal(tool_STATE,'INI')
                        show_MAN_THR('INI_GLB','LST')
                    end
            end
        end
        mousefrm(fig,'arrow')
    end
%--------------------------------------------------------------------------
    function chk_ONE_PLOT(varargin)

        fig = handles.Current_Fig;
        old_plot_MODE = blockdatamngr('get',fig,...
            'tool_ATTR','plot_MODE');
        val_CHK = get(handles.Chk_AFF_MUL,'Value');
        switch val_CHK
            case 0 , modeVAL = 'unique'; maxVAL = 2; val_LST = [];
            case 1 , modeVAL = 'multi';  maxVAL = 1; val_LST = 1;
        end
        if ~isequal(modeVAL,old_plot_MODE)
            switch val_CHK
                case 0 , modeVAL = 'unique'; maxVAL = 2; val_LST = [];
                case 1 , modeVAL = 'multi';  maxVAL = 1; val_LST = 1;
            end
            blockdatamngr('set',fig,...
                'tool_ATTR','plot_MODE',modeVAL);
            hdl_LINES = findobj(handles.Axe_VISU,'Type','Line');
            delete(hdl_LINES)
            title(handles.Axe_VISU,'');
            field = 'Axe_STATS';
            if isfield(handles,field)
                delete(allchild(handles.(field)))
                title(handles.(field),'');
            end
            mdw1dafflst('MARK',handles.Lst_SEL_DATA,[]);
            mdw1dmngr('set_idxSIG_Plot',fig,handles,[])
            set(handles.Lst_SEL_DATA,'Value',1);
            set(handles.Lst_SEL_DATA,'Value',val_LST,'Max',maxVAL);
        else
            set(handles.Lst_SEL_DATA,'Value',val_LST);
        end
    end
%--------------------------------------------------------------------------
    function okONE = oneSEL(pop)

        strPOP = get(pop,'String');
        item   = lower(strPOP{get(pop,'Value')});
        okONE  = ~isequal(item,'all');
    end
%--------------------------------------------------------------------------

end % END of MAIN FUNCTION
