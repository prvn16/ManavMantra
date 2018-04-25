function mdw1dshow(option,varargin)
%MDW1DSHOW Multisignal show manager.
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-Jul-2005.
%   Last Revision: 11-Jul-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $ $Date: 2013/08/23 23:45:48 $

%------------------------------------------------------------
% case 'set_Axe_DEC_Pos'
% case 'Show_DEC_Fun'
% case 'btnTreeTxtFCN'
% case 'Line_Down_GRAPH'
% case 'Line_Move_GRAPH'
% case 'Line_Up_GRAPH'
% case 'L2_N0_SCR'
% case 'LD_THR'
% case 'LM_THR'
% case 'LU_THR'
%------------------------------------------------------------

switch option
    case 'set_Axe_DEC_Pos' , set_Axe_DEC_Pos(varargin{:});
        
    case 'Show_DEC_Fun'
        nbIN = length(varargin);
        [hObject,~,handles,caller] = deal(varargin{1:4});
        if nbIN==5
            dispCUR = varargin{5};
        else
            dispCUR = [];
        end
        not_LST_FLAG = ~isequal(caller,'LST');
        calling_UIC = get(gcbo,'Tag');
        fig = handles.Current_Fig;
        tool_STATE = blockdatamngr('get',fig,...
            'tool_ATTR','State');
        thr_MAN_MODE = isequal(tool_STATE,'DEN_MAN') || ... 
                       isequal(tool_STATE,'CMP_MAN');
                   
        mngmbtn('delLines',fig,'All');
        idxSIG_Plot = wtbxappdata('get',fig,'idxSIG_Plot');
        idxSIG_SEL  = wtbxappdata('get',fig,'idxSIG_SEL');
        
        if thr_MAN_MODE
            flag_MAN = get(handles.Pus_ENA_MAN,'UserData');
            if flag_MAN
                idxSIG_Plot = idxSIG_SEL;
                wtbxappdata('set',fig,'idxSIG_Plot',idxSIG_Plot);
            else
                %%% A VOIR - DEB %%%
                idxSIG_Plot = idxSIG_SEL;
                wtbxappdata('set',fig,'idxSIG_Plot',idxSIG_Plot);
                %%% A VOIR - FIN %%%
            end
        end
        
        if isempty(idxSIG_Plot)
            idxSIG_Plot = 1;
            wtbxappdata('set',fig,'idxSIG_Plot',idxSIG_Plot);
        end
        if isempty(idxSIG_SEL)
            idxSIG_SEL = 1;
            wtbxappdata('set',fig,'idxSIG_SEL',idxSIG_SEL);
        end
 
        switch caller
            case {'ORI','CLU','CMP','DEN','STA','PAR',...
                  'Pop_Show_DEC','LST','Pop_DEC_lev'}
                dispName = mdw1dmngr('getDispMode',handles.Pop_Show_Mode);                
        end
        
        if ~isequal(tool_STATE,'PAR_ON')
            Attrb_Lst_In_SEL = wtbxappdata('get',fig,'Attrb_Lst_In_SEL');
            %%% A VOIR - DEB %%%
            n1_InB = Attrb_Lst_In_SEL(idxSIG_SEL,2);
            t1_Num = Attrb_Lst_In_SEL(idxSIG_SEL,5);
            s1_NUMS = unique([n1_InB,t1_Num],'rows');
            i1_ORI  = s1_NUMS(s1_NUMS(:,2)==0 | s1_NUMS(:,2)==3,1);
            % i1_DorC = s1_NUMS(s1_NUMS(:,2)==1 | s1_NUMS(:,2)==2 | s1_NUMS(:,2)==3,1);
            
            num_InBlocs = Attrb_Lst_In_SEL(idxSIG_Plot,2);
            typSIG_Num  = Attrb_Lst_In_SEL(idxSIG_Plot,5);
            sig_NUMS     = unique([num_InBlocs,typSIG_Num],'rows');
            idx_Typ_ORI  = find(sig_NUMS(:,2)==0 | sig_NUMS(:,2)==3);
            idx_Typ_DorC = find(sig_NUMS(:,2)==1 | sig_NUMS(:,2)==2 | ...
                sig_NUMS(:,2)==3);
            %%% A VOIR - FIN %%%
            
            flag_ORI  = ~isempty(idx_Typ_ORI);
            flag_DorC = ~isempty(idx_Typ_DorC);
            if flag_ORI
                idx_ORI  = sig_NUMS(idx_Typ_ORI,1);
            else
                idx_ORI = [];
            end
            if flag_DorC
                idx_DorC = sig_NUMS(idx_Typ_DorC,1);
            else
                idx_DorC = [];
            end
            [data_ORI,data_DorC] = ...
                mdw1dutils('data_INFO_MNGR','get',fig,'ORI','DorC');
            sig_ORI  = data_ORI.signal;
            lenSIG   = size(sig_ORI,2);
            dec_ORI  = data_ORI.dwtDEC;
            dec_DorC = data_DorC.dwtDEC;
            sig_DorC = data_DorC.signal;
            if ~isempty(dec_ORI) , level = dec_ORI.level; end
        else
            %%% A VOIR - DEB %%%
            flag_ORI = 1;
            sig_ORI  = blockdatamngr('get',fig,'data_SEL','sel_DAT');
            %%% A VOIR - FIN %%%
        end
        Axe_DEC = handles.Axe_VIS_DEC;
        
        switch caller
            case {'ORI','CLU','CMP','DEN','STA','PAR',...
                  'Pop_Show_DEC','LST','Pop_DEC_lev'}

                % Select Show Decomposition Mode.
                %--------------------------------
                POP_DEC = handles.Pop_DEC_lev;
                level_DEC = get(POP_DEC,'Value');
                if isequal(caller,'Pop_DEC_lev')
                    usr = get(POP_DEC,'UserData');
                    if isequal(level_DEC,usr) , return; end
                    set(POP_DEC,'UserData',level_DEC);
                else
                    set(POP_DEC,'UserData',[]);
                end
                set(handles.Pop_Show_Mode,'UserData',dispName)
                
                % Cleaning Axes.
                %---------------
                child = wfindobj(Axe_DEC(:),'type','axes','-xor');
                delete(child);
                set(Axe_DEC,'YtickMode','auto','YTickLabelMode','auto');
                switch dispName
                    case {'dec','stem','stemAbs','stemSqr','stemEner', ...
                          'lvlThr','decCfs'}
                    otherwise
                        set(Axe_DEC,'XtickMode','auto','XTickLabelMode','auto')
                end

            case 'btnFCN'
                dispName = 'btnFCN';
                typSIG  = varargin{5};
                levVAL  = varargin{6};
                wtbxappdata('set',hObject,'Tree_SEL',typSIG);
                wtbxappdata('set',hObject,'Tree_LEV_SEL',levVAL);
        end
        
        toolCOL = mdw1dutils('colors');
        LinW = mdw1dutils('LinW');
        sigCOL = toolCOL.sig; d_OR_c_sigCOL = toolCOL.d_OR_c;
        appCOL = toolCOL.app; d_OR_c_appCOL = 0.7*appCOL;
        detCOL = toolCOL.det; d_OR_c_detCOL = 0.65*detCOL;
        resCOL = toolCOL.res;
        ln0COL = toolCOL.N0; ln2COL = toolCOL.L2;
        LEG = wfindobj(gcf,'Tag','legend');
        set(LEG,'Visible','Off');
        switch dispName
            case 'dec'
                if not_LST_FLAG
                    set_Axe_DEC_Pos('sup',fig,handles,level_DEC)
                end

                % Computing Signals, Approximations and Details.
                %------------------------------------------------
                if flag_ORI
                    sig_ORI = sig_ORI(idx_ORI,:);
                    app_ORI = mdwtrec(dec_ORI,'a',level_DEC,idx_ORI);
                    det_ORI = cell(1,level_DEC);
                    for k=1:level_DEC
                        det_ORI{k} = mdwtrec(dec_ORI,'d',k,idx_ORI); 
                    end
                else
                    sig_ORI = []; app_ORI = []; det_ORI = [];
                end
                if flag_DorC
                    sig_DorC = sig_DorC(idx_DorC,:);
                    app_DorC = mdwtrec(dec_DorC,'a',level_DEC,idx_DorC);
                    det_DorC = cell(1,level_DEC);
                    for k=1:level_DEC , 
                        det_DorC{k} = mdwtrec(dec_DorC,'d',k,idx_DorC);
                    end
                else
                    sig_DorC = []; app_DorC = []; det_DorC = [];
                end

                % Plot Signals.
                %--------------
                axe_Act = Axe_DEC(1);
                axes(axe_Act); hold on %#ok<*MAXES>
                if flag_ORI 
                    plot(1:lenSIG,sig_ORI','Color',sigCOL);
                end
                if flag_DorC
                    plot(1:lenSIG,sig_DorC','Color',d_OR_c_sigCOL);
                end
                tab_SIG = [sig_ORI;sig_DorC];
                yMini = min(min(tab_SIG));
                yMaxi = max(max(tab_SIG));
                set(axe_Act,'XTick',[],'YLim',getYlim(yMini,yMaxi));
                txtSTR = 's';
                [ftnS,txtP] = get_TxtInAxe_Attrb(txtSTR);
                txtinaxe('create',txtSTR,axe_Act,'l','on','bold',ftnS,txtP);
                titSTR = getWavMSG('Wavelet:mdw1dRF:Dec_At_Lev',level_DEC);
                title(titSTR,'Parent',axe_Act);

                % Plot Approximations.
                %---------------------
                axe_Act = Axe_DEC(2);
                axes(axe_Act); hold on
                if flag_ORI  , plot(1:lenSIG,app_ORI','Color',appCOL);   end
                if flag_DorC , plot(1:lenSIG,app_DorC','Color',d_OR_c_appCOL); end
                tab_SIG = [app_ORI;app_DorC];
                yMini = min(min(tab_SIG));
                yMaxi = max(max(tab_SIG));
                set(Axe_DEC(2),'XTick',[],'YLim',getYlim(yMini,yMaxi));
                txtSTR = ['a' int2str(level_DEC)];
                [ftnS,txtP] = get_TxtInAxe_Attrb(txtSTR);
                txtinaxe('create',txtSTR,axe_Act,'l','on','bold',ftnS,txtP);
                
                % Plot Details.
                %--------------
                idx_AXE = 3;
                for k=level_DEC:-1:1
                    axe_Act = Axe_DEC(idx_AXE);
                    axes(axe_Act); hold on 
                    tab_SIG = [];
                    if flag_ORI
                        tab_SIG = [tab_SIG;det_ORI{k}]; %#ok<AGROW>
                        plot(1:lenSIG,det_ORI{k}','Color',detCOL);
                    end
                    if flag_DorC
                        tab_SIG = [tab_SIG;det_DorC{k}]; %#ok<AGROW>
                        plot(1:lenSIG,det_DorC{k}','Color',d_OR_c_detCOL);
                    end
                    yMini = min(min(tab_SIG));
                    yMaxi = max(max(tab_SIG));
                    set(axe_Act,'YLim',getYlim(yMini,yMaxi),...
                        'XGrid','Off','YGrid','Off');
                    txtSTR = ['d' int2str(k)];
                    [ftnS,txtP] = get_TxtInAxe_Attrb(txtSTR);
                    txtinaxe('create',txtSTR,axe_Act,'l','on','bold',ftnS,txtP);
                    idx_AXE = idx_AXE+1;
                    if k>1
                        set(axe_Act,'XTick',[],'YTickLabelMode','auto'); 
                    else
                        set(axe_Act,'XTickLabelMode','auto','YTickLabelMode','auto');
                    end
                end

            case {'stem','stemAbs','stemSqr','stemEner'}
                maxSIG = 10;
                nb_ORI  = length(idx_ORI);
                nb_DorC = length(idx_DorC);
                if nb_ORI>maxSIG
                    idx_ORI(maxSIG+1:end) = [];  nb_ORI = maxSIG;
                end
                if nb_DorC>maxSIG
                    idx_DorC(maxSIG+1:end) = []; nb_DorC = maxSIG;
                end
                nb_SIG = nb_ORI + nb_DorC;
                if nb_SIG>maxSIG
                    while nb_SIG>maxSIG
                        if nb_ORI>0
                            idx_ORI(end) = []; nb_ORI = nb_ORI-1;
                        end
                        if nb_DorC>0
                            idx_DorC(end) = []; nb_DorC = nb_DorC-1;
                        end
                        nb_SIG = nb_ORI + nb_DorC;
                    end
                end
                % if not_LST_FLAG
                    set_Axe_DEC_Pos('stem',fig,handles,nb_SIG);
                % end
                switch dispName
                    case 'stem'     , absMode = 0; numTIT = 1;
                    case 'stemAbs'  , absMode = 1; numTIT = 2;
                    case 'stemSqr'  , absMode = 1; numTIT = 3;
                    case 'stemEner' , absMode = 1; numTIT = 4;
                end
                strTIT = ['MDW1D_AxeTitle_' int2str(numTIT)];
                strTIT = getWavMSG(['Wavelet:mdw1dRF:' strTIT]);
                
                % Plot decomposition.
                %--------------------
                stem_ATTRB = ...
                    {'mode',absMode,'viewapp',1,'colors','wtbx','yscale','eq'};
                if nb_ORI>0
                    if level==level_DEC
                        [cfs_ORI,longs] = wdec2cl(dec_ORI);
                        cfs_ORI = cfs_ORI(idx_ORI,:);
                    else
                        cfs_ORI = mdwtrec(dec_ORI,'ca',level_DEC,idx_ORI);
                        longs   = size(cfs_ORI,2);
                        for k = level_DEC:-1:1
                            cfs_det = mdwtrec(dec_ORI,'cd',k,idx_ORI);
                            cfs_ORI = [cfs_ORI ,cfs_det]; %#ok<AGROW>
                            longs = [longs , size(cfs_det,2)]; %#ok<AGROW>
                        end
                        longs = [longs , lenSIG];
                    end
                    
                    if isequal(dispName,'stemSqr') || isequal(dispName,'stemEner')
                        cfs_ORI = cfs_ORI.^2;
                        if isequal(dispName,'stemEner')
                            Energy  = sum(cfs_ORI,2);
                            cfs_ORI = cfs_ORI./repmat(Energy,1,size(cfs_ORI,2));
                            stem_ATTRB{end} = 'prop';
                            % stem_ATTRB{4} = 0;
                        end
                    end
                    txtInAttrb = {'l','on','bold','s',idx_ORI};
                    mdw1dstem(Axe_DEC(1:nb_ORI),...
                        cfs_ORI,longs,stem_ATTRB,txtInAttrb);
                end
                
                if nb_DorC>0
                    if any(sig_NUMS(:,2)==1)
                        D_or_C = 'D';
                    else
                        D_or_C = 'C';
                    end
                    if level==level_DEC
                        [cfs_DorC,longs] = wdec2cl(dec_DorC);
                        cfs_DorC = cfs_DorC(idx_DorC,:);
                    else
                        cfs_DorC = mdwtrec(dec_DorC,'ca',level_DEC,idx_DorC);
                        longs    = size(cfs_DorC,2);
                        for k = level_DEC:-1:1
                            cfs_det = mdwtrec(dec_DorC,'cd',k,idx_DorC);
                            cfs_DorC = [cfs_DorC ,cfs_det]; %#ok<AGROW>
                            longs = [longs , size(cfs_det,2)]; %#ok<AGROW>
                        end
                        longs = [longs , lenSIG];
                    end
                    txtInAttrb = {'l','on','bold',[D_or_C 's'],idx_DorC};
                    axeIDX = (1+nb_ORI:nb_DorC+nb_ORI);
                    mdw1dstem(Axe_DEC(axeIDX),...
                        cfs_DorC,longs,stem_ATTRB,txtInAttrb);                    
                end
                
                wguiutils('setAxesTitle',Axe_DEC(1),strTIT);
                set(Axe_DEC(1:nb_SIG-1),'XTick',[]); 
                set(Axe_DEC(nb_SIG),'XTickLabelMode','auto');                

            case 'tree'      % Tree Mode
                if not_LST_FLAG
                    set_Axe_DEC_Pos('tree',fig,handles,[]);
                end

                % Computing Signals, Approximations and Details.
                %------------------------------------------------
                if flag_ORI
                    sig_ORI = sig_ORI(idx_ORI,:);
                else sig_ORI = [];
                end
                if flag_DorC
                    sig_DorC = sig_DorC(idx_DorC,:);
                else
                    sig_DorC = [];
                end
                dy = 1/15;    dxL = 1/3;   dxR = 1/3;
                d_BEG = -1/7; d_END = +1/20;
                mSize = 25;   fontSize = 14;
                ey = (1-2*dy)/level_DEC;
                xBeg = dxL;
                xEnd = 1-dxR;
                yBeg = 1-dy;
                yEnd = yBeg-level_DEC*ey;
                xVAL = zeros(1,3*(level_DEC+1));
                yVAL = zeros(1,3*(level_DEC+1));
                xVAL(1:3) = [xBeg,xBeg,NaN];
                yVAL(1:3) = [yBeg,yEnd,NaN];
                yCur = yBeg;
                for k = 1:level_DEC
                    xVAL(3*k-2:3*k) = [xBeg,xEnd,NaN];
                    yVAL(3*k-2:3*k) = [yCur,yCur-ey,NaN];
                    yCur = yCur-ey;
                end
                xVAL(end-2:end) = xVAL(1);
                yVAL(end-2:end) = [yBeg yBeg-ey  yBeg-level_DEC*ey];
                
                % Plot Tree.
                %-----------
                axe_Act = Axe_DEC(3);
                axes(axe_Act)
                child = wfindobj(axe_Act,'type','axes','-xor');
                delete(child);
                set( axe_Act,...
                    'XlimMode','manual','YlimMode','manual',...
                    'XLim',[0 1],'YLim',[0 1],...
                    'XTickLabelMode','manual','YTickLabelMode','manual',...
                    'XTickLabel','','YTickLabel','',...
                    'XTick',[],'XTick',[],'Color','w',...
                    'XGrid','Off','YGrid','Off' ...
                    );
                drawnow
                hold on
                plot(xVAL,yVAL,'k','LineWidth',2,'Parent',axe_Act);
                xT1 = xBeg+d_BEG;
                xT2 = xEnd+d_END;
                yCur = yBeg;
                btnFCN = ...
                    [mfilename '(''btnTreeTxtFCN'',gcbo,[],guidata(gcbo));'];
                plot(xBeg,yCur,'Marker','.','MarkerSize',mSize,'Color','r',...
                    'UserData','s','ButtonDownFcn',btnFCN,'Parent',axe_Act);
                text(xT1,yCur,'s','FontSize',fontSize,...
                    'ButtonDownFcn',btnFCN,'Parent',axe_Act)
                for k = 1:level_DEC
                    kStr = int2str(k);
                    yCur = yCur-ey;
                    aStr = ['a',kStr];
                    plot(xBeg,yCur,'Marker','.','MarkerSize',mSize,'Color','b',...
                        'UserData',aStr,'ButtonDownFcn',btnFCN,'Parent',axe_Act);
                    text(xT1,yCur,aStr,'FontSize',fontSize, ...
                        'ButtonDownFcn',btnFCN,'Parent',axe_Act);
                    dStr = ['d',kStr];
                    plot(xEnd,yCur,'Marker','.','MarkerSize',mSize,'Color','g',...
                        'UserData',dStr,'ButtonDownFcn',btnFCN,'Parent',axe_Act);
                    text(xT2,yCur,dStr,'FontSize',fontSize,...
                        'ButtonDownFcn',btnFCN,'Parent',axe_Act);
                end
                xlabel(getWavMSG('Wavelet:mdw1dRF:Wavelet_Tree'), ...
                    'Parent',axe_Act);
                set(axe_Act,'XTick',[],'XTick',[]);

                % Plot Signals.
                %--------------
                axe_Act = Axe_DEC(1);
                axes(axe_Act); hold on
                if flag_ORI , plot(1:lenSIG,sig_ORI','Color',sigCOL);    end
                if flag_DorC , plot(1:lenSIG,sig_DorC','Color',d_OR_c_sigCOL); end
                tab_SIG = [sig_ORI;sig_DorC];
                yMini = min(min(tab_SIG));
                yMaxi = max(max(tab_SIG));
                set(axe_Act,'YLim',getYlim(yMini,yMaxi));
                title(getWavMSG('Wavelet:mdw1dRF:Str_Signals'));
                set(Axe_DEC(1:2),'XLim',[1,lenSIG]);
                
            case {'glbThr','perfL2N0'}
                if not_LST_FLAG
                    set_Axe_DEC_Pos('scrL2N0',fig,handles,[]);
                end
                
                % Computing Signals, Approximations and Details.
                %-----------------------------------------------
                if flag_ORI
                    sig_ORI = sig_ORI(idx_ORI,:);
                else
                    sig_ORI = [];
                end
                if ~isempty(dec_DorC)
                    sig_DorC = data_DorC.signal;
                    %### CORRECTION FAITE ###% 
                    %### POUR VOIR LES SIGNAUX COMPRESSES ###%
                    idx_DorC = idx_ORI;
                    sig_DorC = sig_DorC(idx_DorC,:);
                else
                    sig_DorC = [];
                end

                % Plot Signals.
                %--------------
                axe_Act = Axe_DEC(1);
                axes(axe_Act); hold on
                if flag_ORI
                    plot(1:lenSIG,sig_ORI','Color',sigCOL);
                    yMini = min(min(sig_ORI));
                    yMaxi = max(max(sig_ORI));
                    % set(axe_Act,'XLim',[1,lenSIG],'XTick',[],...
                    %     'YLim',getYlim(yMini,yMaxi));
                    set(axe_Act,'XLim',[1,lenSIG],'YLim',getYlim(yMini,yMaxi));
                    txtSTR = 's';
                    [ftnS,txtP] = get_TxtInAxe_Attrb(txtSTR);
                    txtinaxe('create',txtSTR,axe_Act,'l','on','bold',ftnS,txtP);
                end
                titSTR = getWavMSG('Wavelet:mdw1dRF:Selected_Signals');
                wguiutils('setAxesTitle',axe_Act,titSTR);

                if ~isempty(sig_DorC)
                    axe_Act = Axe_DEC(2);
                    axes(axe_Act); hold on
                    plot(1:lenSIG,sig_DorC','Color',d_OR_c_sigCOL);
                    yMini = min(min(sig_DorC));
                    yMaxi = max(max(sig_DorC));
                    % set(axe_Act,'XLim',[1,lenSIG],'XTick',[],...
                    %     'YLim',getYlim(yMini,yMaxi));
                    set(axe_Act,'XLim',[1,lenSIG],'YLim',getYlim(yMini,yMaxi));
                end                
                keepAPP = isequal(get(handles.Rad_YES,'Value'),1);
                titSTR = getWavMSG('Wavelet:mdw1dRF:CompSig');
                val_S_or_H = get(handles.Rad_SOFT,'Value');
                switch val_S_or_H
                    case 0 , S_or_H = 'h';
                    case 1 , S_or_H = 's';
                end

                [cfs,longs] = wdec2cl(dec_ORI,'all',i1_ORI);
                [thresVALUES,L2SCR,n0SCR,idx_SORT] = ...
                        mswcmpscr(cfs,longs,2,S_or_H,keepAPP);
                wtbxappdata('set',fig,'cmp_SCORES',...
                        {thresVALUES,L2SCR,n0SCR,idx_SORT});

                if thr_MAN_MODE
                    idxSIG_SEL = wtbxappdata('get',fig,'idxSIG_SEL');
                    uic_MAN = [...
                        NaN,NaN,handles.Pop_MAN_SIG, ...
                        handles.Edi_MAN_GLB_THR,handles.Edi_L2_PERF,... 
                        handles.Edi_N0_PERF];
                    nbIDX = size(idxSIG_SEL,1);
                    paramVAL = [nbIDX ; idxSIG_SEL(:) ; uic_MAN(:)];
                    paramSTR = num2mstr(paramVAL);
                else
                    paramSTR = '[]';
                end
                threshold = blockdatamngr('get',...
                    fig,'data_DorC','threshold');
                threshold_Mean = mean(threshold(idx_ORI,:),2);
                axe_Act = Axe_DEC(3);
                axes(axe_Act); hold on
                nb_ORI = length(i1_ORI);
                linTHR = zeros(1,nb_ORI);
                for k = 1:nb_ORI
                    numSIG = i1_ORI(k);
                    cba = [mfilename '(''L2_N0_SCR'',' ...
                        num2mstr(fig)  ',' int2str(numSIG) ',1);'];
                    plot(thresVALUES(k,:),L2SCR(k,:),...
                        'Color',ln2COL,'LineWidth',LinW.L2,...
                        'Marker','.','MarkerSize',15, ...
                        'Tag','LinL2','UserData',k,'ButtonDownFcn',cba);
                    cba = [mfilename '(''L2_N0_SCR'',' ...
                        num2mstr(fig)  ',' int2str(numSIG) ',0);'];
                    plot(thresVALUES(k,:),n0SCR(k,:),...
                        'Color',ln0COL,'LineWidth',LinW.N0,...
                        'Marker','.','MarkerSize',15, ...                        
                        'Tag','LinN0','UserData',k,'ButtonDownFcn',cba);
                    if thr_MAN_MODE
                        x = min([threshold_Mean(k),thresVALUES(k,end)]);
                        cba_LD_THR = [mfilename '(''LD_THR'',' num2mstr(fig)...
                            ',' int2str(numSIG) ','  int2str(k) ...
                            ',' num2mstr(x) ',' paramSTR ');'];
                        thrCOL = mdw1dutils('colors','thr');
                        linTHR(k) = plot([x,x],[0,100],...
                            'Color',thrCOL,'LineStyle','--','LineWidth',LinW.THR,...
                            'Tag','LinTHR','UserData',k,'ButtonDownFcn',cba_LD_THR);
                        setappdata(linTHR(k),'selectPointer','V');
                    end
                end
                xmax = max(max(thresVALUES,[],2));
                epsx = max(xmax/100,eps);
                epsy = 1;
                set(axe_Act,...
                    'XLim',[-epsx,max(max(thresVALUES,[],2))+epsx],...
                    'YLim',[-eps 100+epsy])
                wguiutils('setAxesTitle',Axe_DEC(2),titSTR);
                xlabSTR = getWavMSG('Wavelet:commongui:Str_Threshold'); 
                wguiutils('setAxesXlabel',Axe_DEC(3),xlabSTR);
                titSTR = getWavMSG('Wavelet:mdw1dRF:Ener_NbZ_Perf');
                wguiutils('setAxesTitle',Axe_DEC(3),titSTR);
                axe_LEG =  ...
                    legend(Axe_DEC(3),'Energy %','Nb Zeros %','Location','Best','AutoUpdate','off');
                ud = get(axe_LEG,'UserData');
                ud.dynvzaxe.enable = 'Off';
                set(axe_LEG,'UserData',ud);
                
            case {'decCfs','lvlThr'}      % Decomposition Mode
                thrMode = isequal(dispName,'lvlThr');
                % if not_LST_FLAG
                set_Axe_DEC_Pos('sup',fig,handles,level_DEC)
                % end
                
                % Computing Signals, Approximations and Details.
                %------------------------------------------------
                nb_ORI = length(idx_ORI);
                if flag_ORI
                    sig_ORI = sig_ORI(idx_ORI,:);
                    app_ORI = mdwtrec(dec_ORI,'ca',level_DEC,idx_ORI);
                    lenAPP = size(app_ORI,2);
                    idxAPP = sort(repmat((1:lenAPP),1,2^level_DEC));
                    app_ORI = wkeep(app_ORI(:,idxAPP),[nb_ORI,lenSIG]);
                    det_ORI = cell(1,level_DEC);
                    for k=1:level_DEC
                        TMP = mdwtrec(dec_ORI,'cd',k,idx_ORI);
                        lenDET = size(TMP,2);
                        idxDET = sort(repmat((1:lenDET),1,2^k));
                        det_ORI{k} = wkeep(TMP(:,idxDET),[nb_ORI,lenSIG]);
                    end
                else
                    sig_ORI = []; app_ORI = []; det_ORI = [];
                end
                nb_DorC = length(idx_DorC);
                if flag_DorC
                    sig_DorC = sig_DorC(idx_DorC,:);
                    app_DorC = mdwtrec(dec_DorC,'ca',level_DEC,idx_DorC);
                    lenAPP = size(app_DorC,2);
                    idxAPP = sort(repmat((1:lenAPP),1,2^level_DEC));
                    app_DorC = wkeep(app_DorC(:,idxAPP),[nb_DorC,lenSIG]);
                    det_DorC = cell(1,level_DEC);
                    for k=1:level_DEC
                        TMP = mdwtrec(dec_DorC,'cd',k,idx_DorC);
                        lenDET = size(TMP,2);
                        idxDET = sort(repmat((1:lenDET),1,2^k));
                        TMP = TMP(:,idxDET);
                        det_DorC{k} = wkeep(TMP(:,idxDET),[nb_DorC,lenSIG]);
                    end
                else
                    sig_DorC = []; app_DorC = []; det_DorC = [];
                end

                % Plot Signals.
                %--------------
                axe_Act = Axe_DEC(1);
                axes(axe_Act); hold on
                if flag_ORI  , plot(1:lenSIG,sig_ORI','Color',sigCOL);    end
                if flag_DorC , plot(1:lenSIG,sig_DorC','Color',d_OR_c_sigCOL); end
                tab_SIG = [sig_ORI;sig_DorC];
                yMini = min(min(tab_SIG));
                yMaxi = max(max(tab_SIG));
                set(axe_Act,'XTick',[],'YLim',getYlim(yMini,yMaxi));
                txtSTR = 's';
                [ftnS,txtP] = get_TxtInAxe_Attrb(txtSTR);
                txtinaxe('create',txtSTR,axe_Act,'l','on','bold',ftnS,txtP);
                titSTR = getWavMSG('Wavelet:mdw1dRF:Dec_At_Lev',level_DEC);
                title(titSTR,'Parent',axe_Act);

                % Plot Approximations.
                %---------------------
                axe_Act = Axe_DEC(2);
                axes(axe_Act); hold on
                if flag_ORI  , plot(1:lenSIG,app_ORI','Color',appCOL);   end
                if flag_DorC , plot(1:lenSIG,app_DorC','Color',d_OR_c_appCOL); end
                tab_SIG = [app_ORI;app_DorC];
                yMini = min(min(tab_SIG));
                yMaxi = max(max(tab_SIG));
                set(Axe_DEC(2),'XTick',[],'YLim',getYlim(yMini,yMaxi));
                txtSTR = ['ca' int2str(level_DEC)];
                [ftnS,txtP] = get_TxtInAxe_Attrb(txtSTR);
                txtinaxe('create',txtSTR,axe_Act,'l','on','bold',ftnS,txtP);

                if thrMode && thr_MAN_MODE
                    idxSIG_SEL = wtbxappdata('get',fig,'idxSIG_SEL');
                    threshold = data_DorC.threshold;
                    threshold = threshold(idxSIG_SEL,:);
                    uic_MAN = [...
                        NaN,NaN,double(handles.Pop_MAN_SIG), ...
                        double(handles.Pop_MAN_LEV),...
                        double(handles.Edi_MAN_THR)];
                    thrCOL = mdw1dutils('colors','thr');
                    lineATTRB = ...
                        {'Color',thrCOL,'LineWidth',2,'LineStyle','--'};
                end
                
                % Plot Details.
                %--------------
                idx_AXE = 3;
                for k=level_DEC:-1:1
                    axe_Act = Axe_DEC(idx_AXE);
                    axes(axe_Act); hold on %#ok<*LAXES>
                    tab_SIG = [];
                    if flag_ORI
                        tab_SIG = [tab_SIG;det_ORI{k}]; %#ok<AGROW>
                        plot(1:lenSIG,det_ORI{k}','Color',detCOL);
                    end
                    if flag_DorC
                        tab_SIG = [tab_SIG;det_DorC{k}]; %#ok<AGROW>
                        plot(1:lenSIG,det_DorC{k}','Color',d_OR_c_detCOL);
                    end
                    yMini = min(min(tab_SIG));
                    yMaxi = max(max(tab_SIG));
                    if thrMode && thr_MAN_MODE
                        yAbsMAX = max([abs(yMini),yMaxi]);
                        thrLEV  = threshold(:,k);
                        thrLEV(thrLEV>yAbsMAX) = yAbsMAX;
                        thrVAL = [thrLEV thrLEV];
                        yMaxi =  yAbsMAX;
                        yMini = -yAbsMAX;
                        
                        nbTHR = size(thrVAL,1);
                        LUp   = plot([1 lenSIG],thrVAL',lineATTRB{:});
                        LDown = plot([1 lenSIG],-thrVAL',lineATTRB{:});
                        paramVAL = [double(axe_Act) ; nbTHR ; idxSIG_SEL(:) ; ...
                            uic_MAN(:)];
                        paramSTR  = num2mstr(paramVAL);
                        hLinesSTR = num2mstr([LUp;LDown]);
                        levSTR = int2str(k);
                        for jj = 1:nbTHR
                            setappdata(LUp(jj),'selectPointer','H');
                            setappdata(LDown(jj),'selectPointer','H');
                            propVAL = {'UserData',jj,'ZData',[100 100]};
                            set(LUp(jj),'ZData',[-jj -jj],...
                                'Tag',['LU' levSTR],propVAL{:});
                            set(LDown(jj),'ZData',[-jj -jj],...
                                'Tag',['LD' levSTR],propVAL{:});
                        end
                        cba_LINE = [mfilename '(''Line_Down_GRAPH'',' ...
                            num2mstr(fig) , ',[],' hLinesSTR ',' ...
                            paramSTR ',' int2str(+k) ',' ...
                            num2str(yMaxi) ');'];
                        set(LUp,'ButtonDownFcn',cba_LINE);
                        cba_LINE = [mfilename '(''Line_Down_GRAPH'',' ...
                            num2mstr(fig) , ',[],' hLinesSTR ',' ...
                            paramSTR ',' int2str(-k) ',' ...
                            num2str(yMini) ');'];
                        set(LDown,'ButtonDownFcn',cba_LINE);
                    end
                    set(axe_Act,'YLim',getYlim(yMini,yMaxi),...
                        'XGrid','Off','YGrid','Off');
                    txtSTR = ['cd' int2str(k)];
                    [ftnS,txtP] = get_TxtInAxe_Attrb(txtSTR);
                    txtinaxe('create',txtSTR,axe_Act,'l','on','bold',ftnS,txtP);
                    idx_AXE = idx_AXE+1;
                    if k>1
                        set(axe_Act,'XTick',[],'YTickLabelMode','auto'); 
                    else
                        set(axe_Act,'XTickLabelMode','auto','YTickLabelMode','auto');
                    end
                end                    
                
            case 'sep'      % Separate
                if not_LST_FLAG
                    set_Axe_DEC_Pos('sep',fig,handles,[]);
                end
                data_SEL = mdw1dutils('data_INFO_MNGR','get',fig,'SEL');
                nb_SIG   = length(idxSIG_Plot);
                signals  = data_SEL.sel_DAT(idxSIG_Plot,:);
                minSIG   = min(signals,[],2);
                for k = 1:nb_SIG
                    signals(k,:) = (signals(k,:)-minSIG(k));
                end
                maxSIG    = max(signals,[],2);
                range_TOT = sum(maxSIG);
                if range_TOT<eps , range_TOT = 1; end
                signals   = signals/range_TOT;
                maxSIG    = maxSIG/range_TOT;
                lenSIG    = size(signals,2);
                
                % Plot Signals.
                %--------------
                %==========================================================
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
                %-----------------------------------
                % Attrb_Lst_In_SEL = ...
                %       [num_SEL,num_SIG,typVAL_Num,levVAL,typSIG_Num];
                %========================================================== 
                if ~isequal(caller,'PAR') && ~isequal(dispCUR,'PAR')
                    Attrb_SIG_SEL = Attrb_Lst_In_SEL(idxSIG_Plot,:);
                    typVAL_Num = Attrb_SIG_SEL(:,3);
                    typSIG_Num = Attrb_SIG_SEL(:,5);
                else
                    typVAL_Num = zeros(nb_SIG,1);
                    typSIG_Num = zeros(nb_SIG,1);
                end
                
                % Make tab of colors.
                tab_COLOR  = repmat(resCOL,nb_SIG,1);
                III = typVAL_Num==0 & typSIG_Num==0;
                tmp_COL = repmat(sigCOL,nb_SIG,1);
                tab_COLOR(III,:) = tmp_COL(III,:);
                III = typVAL_Num==0 & (typSIG_Num==1 | typSIG_Num==2);
                tmp_COL = repmat(d_OR_c_sigCOL,nb_SIG,1);
                tab_COLOR(III,:) = tmp_COL(III,:);
                III = (typVAL_Num==1 | typVAL_Num==3) & typSIG_Num==0;
                tmp_COL = repmat(appCOL,nb_SIG,1);
                tab_COLOR(III,:) = tmp_COL(III,:);
                III = (typVAL_Num==1 | typVAL_Num==3) & ...
                            (typSIG_Num==1 | typSIG_Num==2);
                tmp_COL = repmat(d_OR_c_appCOL,nb_SIG,1);
                tab_COLOR(III,:) = tmp_COL(III,:);
                III = (typVAL_Num==2 | typVAL_Num==4) & typSIG_Num==0;
                tmp_COL = repmat(detCOL,nb_SIG,1);
                tab_COLOR(III,:) = tmp_COL(III,:);
                III = (typVAL_Num==2 | typVAL_Num==4) & ...
                            (typSIG_Num==1 | typSIG_Num==2);
                tmp_COL = repmat(d_OR_c_detCOL,nb_SIG,1);
                tab_COLOR(III,:) = tmp_COL(III,:);
                
                axe_Act = Axe_DEC(1);
                axes(axe_Act); hold on
                ecy = 0.1;
                dy  = ecy;
                tabYtick      = zeros(nb_SIG,1);
                tabYtickLabel = cell(nb_SIG,1);
                for k = nb_SIG:-1:1
                    signals(k,:) = dy + signals(k,:);
                    tabYtick(nb_SIG-k+1) = signals(k,1);
                    tabYtickLabel{nb_SIG-k+1} = int2str(idxSIG_Plot(k));
                    plot(1:lenSIG,signals(k,:),'Color',tab_COLOR(k,:),...
                        'UserData',idxSIG_Plot(k));
                    dy = dy+maxSIG(k)+ecy;
                end
                set(axe_Act,'YLim',[0,1+(nb_SIG+1)*ecy],...
                    'YTick',tabYtick,'YTickLabel',tabYtickLabel);
                titSTR = getWavMSG('Wavelet:mdw1dRF:Selected_Signals');
                wguiutils('setAxesTitle',axe_Act,titSTR);
                
            case 'btnFCN'
                switch typSIG
                    case 's'
                        if flag_ORI
                            s_a_d_ORI = sig_ORI(idx_ORI,:);
                            col_ORI = sigCOL;
                        else
                            s_a_d_ORI = [];
                        end
                        if flag_DorC
                            s_a_d_DorC = sig_DorC(idx_DorC,:);
                            col_DorC = d_OR_c_sigCOL;
                        else
                            s_a_d_DorC = [];
                        end
                        strTIT = getWavMSG('Wavelet:mdw1dRF:Str_Signals');

                    case {'a','d'}
                        if flag_ORI ,
                            s_a_d_ORI = mdwtrec(dec_ORI,typSIG,levVAL,idx_ORI);
                        else
                            s_a_d_ORI = [];
                        end
                        if flag_DorC
                            s_a_d_DorC = mdwtrec(dec_DorC,typSIG,levVAL,idx_DorC);
                        else
                            s_a_d_DorC = [];
                        end
                        switch typSIG
                            case 'a'
                                strTIT = getWavMSG('Wavelet:mdw1dRF:App_At_Lev',levVAL);
                                if flag_ORI , col_ORI = appCOL;   end
                                if flag_DorC , col_DorC = d_OR_c_appCOL; end
                            case 'd'
                                strTIT = getWavMSG('Wavelet:mdw1dRF:Det_At_Lev',levVAL);
                                if flag_ORI , col_ORI = detCOL;    end
                                if flag_DorC , col_DorC = d_OR_c_detCOL; end
                        end
                end
                tab_SIG = [s_a_d_ORI;s_a_d_DorC];

                % Plot Signals.
                %--------------
                axe_Act = Axe_DEC(2);
                child = wfindobj(axe_Act,'type','axes','-xor');
                delete(child);
                axes(axe_Act); hold on
                if flag_ORI
                    plot(1:lenSIG,s_a_d_ORI','Color',col_ORI);
                end
                if flag_DorC
                    plot(1:lenSIG,s_a_d_DorC','Color',col_DorC);
                end
                yMini = min(min(tab_SIG));
                yMaxi = max(max(tab_SIG));
                set(axe_Act,'XtickMode','Auto','XTickLabelMode','Auto',...
                    'YLim',getYlim(yMini,yMaxi));
                title(strTIT);
        end

        dynvtool('get',fig,0'); mngmbtn('delLines',fig,'All');
        switch dispName
            case {'dec','decCfs','sep',...
                  'stem','stemAbs','stemSqr','stemEner','lvlThr'}
                set(Axe_DEC,'XLim',[1,lenSIG]);
                lastAxe = length(Axe_DEC);
            otherwise
                lastAxe = 2;
        end
        set(handles.Pan_VISU_SIG,'Visible','Off')
        if isequal(calling_UIC,'Pus_ENA_MAN') , caller = 'DorC'; end
        switch caller
            case 'CLU'
                mdw1dclus('Set_Pos_Pan',fig,[],handles,'Show_DEC');

            case {'ORI','CMP','DEN','STA','DorC'}
                mdw1dmngr('set_Tool_View',handles,caller,'Show_DEC');
        end
        set(handles.Pan_VISU_DEC,'Visible','On')
        %------------------------------------------------------------------
        %%% A VOIR: DEB %%%
        enaVAL = 'Off';
        switch dispName
            case {'dec','decCfs','sep','tree','btnFCN',...
                  'lvlThr','glbThr','perfL2N0'} 
                lstHIG = get(handles.Pop_HIG_DEC,'String');
                nbItem = length(lstHIG);
                if nbItem>1 , enaVAL = 'On'; end
            otherwise
        end
        set([handles.Txt_HIG_DEC,handles.Pop_HIG_DEC],'Enable',enaVAL);
        %%% A VOIR: FIN %%%
        %------------------------------------------------------------------
        axe_IND = handles.Axe_VISU;
        axe_CMD = handles.Axe_VIS_DEC(1:lastAxe);
        axe_ACT = [];
        dynvtool('init',fig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','','real');
        
    case 'btnTreeTxtFCN'
        [hObject,eventdata,handles] = deal(varargin{1:3});
        typeCALL = get(hObject,'Type');
        switch typeCALL
            case 'text' , strOBJ = get(hObject,'String');
            case 'line' , strOBJ = get(hObject,'UserData');
        end
        typSIG = strOBJ(1);
        switch strOBJ(1)
            case 's' , lev = 0;
            case {'a','d'} , lev = str2double(strOBJ(2:end));
        end
        mdw1dshow('Show_DEC_Fun',...
            hObject,eventdata,handles,'btnFCN',typSIG,lev);
        
    case 'Line_Down_GRAPH'
        [fig,~,hLines,paramVAL,direct,yLIM] = deal(varargin{:});
        handles = guidata(fig);
        linCUR  = double(gco);
        % hLines = [LUp ; LDown];
        % paramVAL = ...
        %    [axe_Act ; nbTHR ;  idxSIG_SEL(:) ; uic_MAN(:)]
        % uic_MAN = [...
        %     handles.Pop_MAN_SIG, ...
        %     handles.Pop_MAN_LEV, handles.Edi_MAN_THR,...
        nbLines = length(hLines);
        linUP   = hLines(1:nbLines/2);
        linDOWN = hLines(1+nbLines/2:end);
        
        axe     = paramVAL(1);
        nbTHR   = paramVAL(2); first = 3;  last = first+nbTHR-1;
        idxSIG_SEL = paramVAL(first:last); first = last+1;
        uic_MAN = paramVAL(first:end);
        Pop_MAN_SIG = uic_MAN(3);
        Pop_MAN_LEV = uic_MAN(4);
        Edi_MAN_THR = uic_MAN(5);
        
        wtbxappdata('set',fig,'flag_modify_THR',true);
        level = abs(direct);
        if direct>0
            idxCUR = find(linCUR==linUP);
            lin_D = linDOWN(idxCUR);
            lin_U = linCUR;
        else
            idxCUR = find(linCUR==linDOWN);
            lin_U = linUP(idxCUR);
            lin_D = linCUR;
        end
        tool_NAME = ...
            blockdatamngr('get',fig,'tool_ATTR','Name');
        
        flag_SIG_SEL = isequal(oneSEL(Pop_MAN_SIG),true);
        if flag_SIG_SEL , Pop_SIG_VAL = idxCUR+1; else Pop_SIG_VAL = 1; end
        flag_LEV_SEL = isequal(oneSEL(Pop_MAN_LEV),true);
        if ~flag_LEV_SEL
            hLINE  = findobj(handles.Axe_VIS_DEC,'Type','line');
            if flag_SIG_SEL
                usrCUR = get(linCUR,'UserData');
                hLINE  = findobj(hLINE,'UserData',usrCUR);
            end
            tag    = get(hLINE,'Tag');
            strTAG = 'LU';
            lenSTR = length(strTAG);
            idxL   = strncmp(tag,strTAG,lenSTR);
            linUP  = hLINE(idxL);
            % usr    = get(linUP,'UserData');
            strTAG = 'LD';
            idxL   = strncmp(tag,strTAG,lenSTR);
            linDOWN = hLINE(idxL);
            % usr    = get(linDOWN,'UserData');
            % level = 1:length(linUP);
        else
            set(Pop_MAN_LEV,'Value',level+1);
        end
        
        set(Pop_MAN_SIG,'Value',Pop_SIG_VAL);
        p = get(axe,'CurrentPoint');
        tLD_COL = mdw1dutils('colors','tLD');
        set([lin_U,lin_D],'Color',tLD_COL);
        if flag_SIG_SEL
            idxSIG  = idxSIG_SEL(get(linCUR,'UserData'));
            xLIM = get(axe,'XLim');
            propVAL = {int2str(idxSIG),'Parent',axe,'Color','r',...
                'EdgeColor','r','BackgroundColor',[1 1 0.5],...
                'FontSize',8,'FontWeight','bold','Tag','txtLIN'};
            txtLIN(1) = text(xLIM(2)-30,p(1,2),200,propVAL{:});
            txtLIN(2) = text(xLIM(2)-30,-p(1,2),200,propVAL{:});
            set(handles.Pop_HIG_DEC,'Value',Pop_SIG_VAL);
            mdw1dmngr('Pop_HIG_Func',handles.Pop_HIG_DEC,...
                [],handles,tool_NAME,'DEC')
        else
            txtLIN(1:2) = NaN;
        end
        drawnow
        
        paramSTR = ...
            num2mstr([paramVAL(1);lin_U;lin_D;paramVAL(2:end);double(txtLIN(:))]);
        cba_move = [mfilename '(''Line_Move_GRAPH'',''' tool_NAME  ''',' ...
            num2mstr(fig) ',' num2mstr(linCUR) ',' int2str(idxCUR) ',' ...
            num2mstr(linUP) ',' num2mstr(linDOWN) ',' paramSTR ',' ...
            int2str(direct) ',' num2str(yLIM) ');'];
        cba_up   = [mfilename '(''Line_Up_GRAPH'',''' tool_NAME ''','  ...
            num2mstr(fig) ',' num2mstr(linCUR) ',' int2str(idxCUR) ',' ...
            num2mstr(linUP) ',' num2mstr(linDOWN) ',' paramSTR ',' ...
            int2str(direct) ');'];
        wtbxappdata('new',fig,...
            'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
        set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);
        thrTAB = get(Edi_MAN_THR,'UserData');
        yd = get(lin_U,'YData');
        thrTAB(level) = yd(1);
        set(Edi_MAN_THR,'String',num2str(yd(1),'%10.5f'),'UserData',thrTAB)
        setptr(fig,'uddrag');

    case 'Line_Move_GRAPH'
        [~,~,linCUR,~,linUP,linDOWN,paramVAL,direct,yLIM] = ...
            deal(varargin{:});
        % paramVAL = [axe_Act ; lin_U ; lin_D ; nbTHR ; ...
        %             idxSIG_SEL(:) ; uic_MAN(:)]
        axe     = paramVAL(1);
        lin_U   = paramVAL(2);
        lin_D   = paramVAL(3);
        nbTHR   = paramVAL(4);
        first   = 5; 
        last = first+nbTHR-1;
        % idxSIG_SEL = paramVAL(first:last); 
        first   = last+1;
        uic_MAN = paramVAL(first:end-2);
        txtLIN  = paramVAL(end-1:end);
        Pop_MAN_SIG = uic_MAN(3);
        Pop_MAN_LEV = uic_MAN(4);
        Edi_MAN_THR = uic_MAN(5);
        p = get(axe,'CurrentPoint');
        delta_THR = 1E-6;
        if linCUR==lin_U
            if     p(1,2)<=0 ,  p(1,2) = 0; 
            elseif p(1,2)>yLIM, p(1,2)= yLIM+delta_THR; 
            end
        else
            if     p(1,2)>=0 ,  p(1,2) = 0; 
            elseif p(1,2)<yLIM, p(1,2) = yLIM-delta_THR;
            end
        end        
        new_thresh = abs(p(1,2)*sign(direct));
        yold = get(lin_U,'YData');
        if isequal(yold(1),new_thresh) , return; end
        ynew = [new_thresh new_thresh];
        if new_thresh<delta_THR , ynew(:) = delta_THR; end
        flag_SIG_SEL = isequal(oneSEL(Pop_MAN_SIG),true);
        flag_LEV_SEL = isequal(oneSEL(Pop_MAN_LEV),true);
        
        if flag_SIG_SEL && flag_LEV_SEL
            set(lin_U,'YData',ynew);
            set(lin_D,'YData',-ynew);
            pTXT = get(txtLIN(1),'Position');
            set(txtLIN(1),'Position',[pTXT(1) ,  ynew(1) , 200])
            set(txtLIN(2),'Position',[pTXT(1) , -ynew(1) , 200])
        else
            set(linUP,'YData',ynew);
            set(linDOWN,'YData',-ynew);            
        end
        set(Edi_MAN_THR,'String',num2str(new_thresh,'%10.5f'))

    case 'Line_Up_GRAPH'
        [tool_NAME,fig,~,idxCUR,~,~,paramVAL,direct] = ...
            deal(varargin{:});
        handles = guidata(fig);
        % paramVAL = [axe_Act ; lin_U ; lin_D ; nbTHR ; ...
        %             idxSIG_SEL(:) ; uic_MAN(:)]
        lin_U   = paramVAL(2);
        lin_D   = paramVAL(3);
        nbTHR   = paramVAL(4); first = 5; last = first+nbTHR-1;
        % idxSIG_SEL = paramVAL(first:last); 
        first = last+1;
        uic_MAN = paramVAL(first:end-2);
        % txtLIN  = paramVAL(end-1:end);
        Edi_MAN_THR = uic_MAN(5);
        yd = get(lin_U,'YData');
        if isnan(yd(1))
            delta_THR = 1E-6;
            yd = [delta_THR delta_THR];
        end
        save_WindowButtonUpFcn = ...
            wtbxappdata('del',fig,'save_WindowButtonUpFcn');
        set(fig,'WindowButtonMotionFcn','', ...
            'WindowButtonUpFcn',save_WindowButtonUpFcn);
        thrCOL = mdw1dutils('colors','thr');
        set(lin_U,'YData',yd,'Color',thrCOL);
        set(lin_D,'YData',-yd,'Color',thrCOL);
        
        axeAct = handles.Axe_VIS_DEC;
        old_LINE = findobj(axeAct,'Tag','Line_HIG');
        old_TXT  = findobj(axeAct,'Tag','txtLIN');
        if ~isempty(old_LINE) , delete(old_LINE); end
        if ~isempty(old_TXT)  , delete(old_TXT); end
        thr_NEW = yd(1);
        level = abs(direct);
        thrTAB = get(Edi_MAN_THR,'UserData');
        thrTAB(level) = thr_NEW;
        set(Edi_MAN_THR,...
            'String',num2str(thr_NEW,'%10.5f'),'UserData',thrTAB)
        setptr(fig,'arrow');
        drawnow;
        if isequal(tool_NAME,'CMP') || isequal(tool_NAME,'DEN')
            mdw1dmisc('show',handles,'MAN_THR','LIN',idxCUR,thr_NEW)
        end
        set(handles.Pop_HIG_DEC,'Value',1)

    case 'L2_N0_SCR'
        [~,numSIG,typeCALL] = deal(varargin{1:3});
        axe = gca;
        p = get(axe,'CurrentPoint');
        tag = ['txt_' int2str(typeCALL)];
        hTXT = findobj(axe,'Type','text','Tag',tag,'UserData',numSIG);
        if isempty(hTXT)
            switch typeCALL
                case 0 , FCOL = 'r'; BkCOL = [1   0.7 1]; % N0 score line
                case 1 , FCOL = 'b'; BkCOL = [0.7 0.7 1]; % L2 score line
            end
            propVAL = {int2str(numSIG),'Parent',axe,'Color',FCOL,...
                'EdgeColor',FCOL,'BackgroundColor',BkCOL,...
                'HorizontalAlignment','Center',...
                'FontSize',8,'FontWeight','bold',...
                'Tag',tag,'UserData',numSIG};
            text(p(1,1),p(1,2),200,propVAL{:});
        else
            set(hTXT,'Position',p(1,:))
        end

    case 'LD_THR'
        [fig,numSIG,idxCUR,~,param_1] = deal(varargin{1:5});
        handles = guidata(fig);
        axe    = gca;
        linCUR = gco;
        xd = get(linCUR,'XData');
        new_thresh = xd(1);
        
        nbIDX = param_1(1);
        % idxSIG_SEL = param_1(2:nbIDX+1);
        uic_MAN = param_1(nbIDX+2:end);
        Pop_MAN_SIG = uic_MAN(3);
        Edi_MAN_GLB_THR = uic_MAN(4);
        Edi_L2_PERF = uic_MAN(5);
        Edi_N0_PERF = uic_MAN(6);
        wtbxappdata('set',fig,'flag_modify_THR',true);
        flag_SIG_SEL = isequal(oneSEL(Pop_MAN_SIG),true);
        % sig_STR = int2str(numSIG);
        
        % Get cmp_SCORES values;
        cmp_SCORES = wtbxappdata('get',fig,'cmp_SCORES');
        thresVALUES = cmp_SCORES{1}; % {thresVALUES,L2SCR,n0SCR,idx_SORT});
        THR = thresVALUES(idxCUR,:);
        L2_Perf = cmp_SCORES{2}(idxCUR,:);
        N0_Perf = cmp_SCORES{3}(idxCUR,:);
        thrMAXI = THR(end);
        L2SCR_lin = L2_Perf(end);
        n0SCR_lin = N0_Perf(end);
 
%------------------- 
%%% A VOIR - DEB %%%
%--------------------
        NbPts  = 500;
        III = find(diff(THR)==0);
        THR(III+1) = []; L2_Perf(III+1) = []; N0_Perf(III+1) = [];
        THR_INT = interp1(THR,THR,linspace(0,thrMAXI,NbPts));
        L2_Perf = interp1(THR,L2_Perf,THR_INT);
        N0_Perf = interp1(THR,N0_Perf,THR_INT);
        [~,idxTHR] = min(abs(THR_INT-new_thresh));
        set(Edi_MAN_GLB_THR,'String',num2str(new_thresh,'%10.5f'));
        set(Edi_L2_PERF,'String',num2str(L2_Perf(idxTHR),'%10.2f'));
        set(Edi_N0_PERF,'String',num2str(N0_Perf(idxTHR),'%10.2f'));
%-------------------       
%%% A VOIR - FIN %%%
%-------------------        
        
        % N0 score line
        tag = 'txt_0';
        txtTMP = findobj(axe,'Type','text','Tag',tag);
        usr = get(txtTMP,'UserData');
        if iscell(usr) , usr = cat(1,usr{:});end
        hTXT = txtTMP(usr==numSIG);
        delete(txtTMP(usr~=numSIG));
        if isempty(hTXT)
            FCOL = 'r'; BkCOL = [1 0.7 1];
            propVAL = {int2str(numSIG),'Parent',axe,'Color',FCOL,...
                'EdgeColor',FCOL,'BackgroundColor',BkCOL,...
                'HorizontalAlignment','Center',...
                'FontSize',8,'FontWeight','bold',...
                'Tag',tag,'UserData',numSIG};
            text(thrMAXI,n0SCR_lin,200,propVAL{:});
        else
            set(hTXT,'Position',[thrMAXI,n0SCR_lin,200])
        end

        % L2 score line
        tag = 'txt_1';
        txtTMP = findobj(axe,'Type','text','Tag',tag);
        usr = get(txtTMP,'UserData');
        if iscell(usr) , usr = cat(1,usr{:});end
        hTXT = txtTMP(usr==numSIG);
        delete(txtTMP(usr~=numSIG));
        if isempty(hTXT)
            FCOL = 'b'; BkCOL = [0.7 0.7 1];
            propVAL = {int2str(numSIG),'Parent',axe,'Color',FCOL,...
                'EdgeColor',FCOL,'BackgroundColor',BkCOL,...
                'HorizontalAlignment','Center',...
                'FontSize',8,'FontWeight','bold',...
                'Tag',tag,'UserData',numSIG};
            text(thrMAXI,L2SCR_lin,200,propVAL{:});
        else
            set(hTXT,'Position',[thrMAXI,L2SCR_lin,200])
        end

        if flag_SIG_SEL , Pop_SIG_VAL = idxCUR+1; else Pop_SIG_VAL = 1; end
        set(Pop_MAN_SIG,'Value',Pop_SIG_VAL);

        tLD_COL = mdw1dutils('colors','tLD');
        set(linCUR,'Color',tLD_COL);
        p = get(axe,'CurrentPoint');
        p(:,2) = 106;
        
        tag = 'txt_THR';
        txtTMP = findobj(axe,'Type','text','Tag',tag);
        usr = get(txtTMP,'UserData');
        if iscell(usr) , usr = cat(1,usr{:});end
        hTXT = txtTMP(usr==numSIG);
        delete(txtTMP(usr~=numSIG));
        if isempty(hTXT)
            FCOL = 'r'; 
            BkCOL = [1 1 0.7];
            propVAL = {int2str(numSIG),'Parent',axe,'Color',FCOL,...
                'EdgeColor',FCOL,'BackgroundColor',BkCOL,...
                'HorizontalAlignment','Center',...
                'FontSize',8,'FontWeight','bold',...
                'Tag',tag,'UserData',numSIG};
            hTXT = text(p(1,1),p(1,2),200,propVAL{:});
        else
            set(hTXT,'String',int2str(numSIG),'Position',p(1,:))
        end
        
        if flag_SIG_SEL
            set(handles.Pop_HIG_DEC,'Value',Pop_SIG_VAL);
            tool_NAME = blockdatamngr('get',fig,'tool_ATTR','Name');            
            mdw1dmngr('Pop_HIG_Func',handles.Pop_HIG_DEC,...
                [],handles,tool_NAME,idxCUR)
        else
            set(hTXT,'String','All')
        end
        LinTHR  = findobj(axe,'Tag','LinTHR');
        param_2 = [numSIG;idxCUR;thrMAXI;axe;hTXT];        
        par_1_STR = num2mstr(param_1);
        par_2_STR = num2mstr(param_2);
        par_3_STR = num2mstr(LinTHR);
        param_STR = [num2mstr(fig) ',' num2mstr(linCUR) ',' ...
                     par_1_STR ',' par_2_STR ',' par_3_STR  ');'];
        cba_move = [mfilename '(''LM_THR'',' param_STR];
        cba_up   = [mfilename '(''LU_THR'',' param_STR];
        wtbxappdata('new',fig,...
            'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
        set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);
        setptr(fig,'lrdrag');
        LinL2N0 = [findobj(axe,'Tag','LinL2');findobj(axe,'Tag','LinN0')];
        usr = get(LinL2N0,'UserData');
        usr = cat(1,usr{:});
        idxLIN = usr==idxCUR;
        set(LinL2N0(~idxLIN),'LineWidth',0.5); drawnow
        set(LinL2N0(~idxLIN),'LineStyle',':'); drawnow
        set(LinL2N0(idxLIN),'LineWidth',2);
        % mdw1dmngr('LM_THR',fig,linCUR,param_1,param_2,LinTHR);
        
    case 'LM_THR'
        [fig,linCUR,param_1,param_2,LinTHR] = deal(varargin{:});
        nbIDX   = param_1(1); 
        % idxSIG_SEL = param_1(2:nbIDX+1);
        uic_MAN = param_1(nbIDX+2:end);
        % numSIG  = param_2(1);
        idxCUR  = param_2(2);
        thrMAXI = param_2(3);
        axe     = param_2(4);
        hTXT    = param_2(5);
        Pop_MAN_SIG = uic_MAN(3);
        Edi_MAN_GLB_THR = uic_MAN(4);
        Edi_L2_PERF = uic_MAN(5);
        Edi_N0_PERF = uic_MAN(6);
        flag_SIG_SEL = isequal(oneSEL(Pop_MAN_SIG),true);

        p = get(axe,'CurrentPoint');
        delta_THR = 1E-6;
        if     p(1,1)<=0 ,  p(1,:) = 0;
        elseif p(1,1)>thrMAXI, p(1,:)= thrMAXI;
        end
        new_thresh = p(1,1);
        if new_thresh<delta_THR , new_thresh = delta_THR; end
        xnew = [new_thresh new_thresh];
        if flag_SIG_SEL
            set(linCUR,'XData',xnew);
        else
            set(LinTHR,'XData',xnew);
        end
        pTXT = get(hTXT,'Position');
        set(hTXT,'Position',[xnew(1) , pTXT(2) ,  200])
        cmp_SCORES = wtbxappdata('get',fig,'cmp_SCORES');
        % cmp_SCORES : {thresVALUES,L2SCR,n0SCR,idx_SORT})
        thresVALUES = cmp_SCORES{1};
        L2_Perf = cmp_SCORES{2}(idxCUR,:);
        N0_Perf = cmp_SCORES{3}(idxCUR,:);
        THR = thresVALUES(idxCUR,:);

%%% A VOIR - DEB %%%
%--------------------
%         III = find(diff(THR)==0);
        %%% A VOIR %%%
        % THR(III+1) = THR(III+1)+10*eps*[1:length(III)];
        % Bug car THR contient des valeurs égales.
        % On essaye : 
%         THR(III+1) = []; L2_Perf(III+1) = []; N0_Perf(III+1) = [];
%       Problème : il faut la meme longueur pour: L2_Perf et N0_Perf
% Autre solution (peut être trop long ...)
%------------------------------------------
%          THR_INT = THR;
        NbPts  = 500;
        III = find(diff(THR)==0);
        THR(III+1) = []; L2_Perf(III+1) = []; N0_Perf(III+1) = [];
        THR_INT = interp1(THR,THR,linspace(0,thrMAXI,NbPts));
        L2_Perf = interp1(THR,L2_Perf,THR_INT);
        N0_Perf = interp1(THR,N0_Perf,THR_INT);
        [~,idxTHR] = min(abs(THR_INT-new_thresh));
        set(Edi_MAN_GLB_THR,'String',num2str(new_thresh,'%10.5f'));
        set(Edi_L2_PERF,'String',num2str(L2_Perf(idxTHR),'%10.2f'));
        set(Edi_N0_PERF,'String',num2str(N0_Perf(idxTHR),'%10.2f'));
%%% A VOIR - FIN %%%
%------------------- 
        
    case 'LU_THR'
        [fig,linCUR,param_1,param_2,LinTHR] = deal(varargin{:}); %#ok<NASGU>
        handles = guidata(fig);
        nbIDX   = param_1(1); 
        % idxSIG_SEL = param_1(2:nbIDX+1);
        uic_MAN = param_1(nbIDX+2:end);
        % numSIG  = param_2(1);
        idxCUR  = param_2(2);
        % thrMAXI = param_2(3);
        axe     = param_2(4);
        % hTXT    = param_2(5);
        % Pop_MAN_SIG = uic_MAN(3);
        Edi_MAN_GLB_THR = uic_MAN(4);
        % Edi_L2_PERF = uic_MAN(5);
        % Edi_N0_PERF = uic_MAN(6);

        % Delete N0 and L2 numsig text
        tag = 'txt_0';
        txtTMP = findobj(axe,'Type','text','Tag',tag);
        delete(txtTMP);
        tag = 'txt_1';
        txtTMP = findobj(axe,'Type','text','Tag',tag);
        delete(txtTMP);
        
        xd = get(linCUR,'XData');
        if isnan(xd(1))
            delta_THR = 1E-6;
            xd = [delta_THR delta_THR];
        end
        save_WindowButtonUpFcn = ...
            wtbxappdata('del',fig,'save_WindowButtonUpFcn');
        set(fig,'WindowButtonMotionFcn','', ...
            'WindowButtonUpFcn',save_WindowButtonUpFcn);
        
        thrCOL = mdw1dutils('colors','thr');
        set(linCUR,'XData',xd,'Color',thrCOL);
        axeAct = handles.Axe_VIS_DEC;
        old_LINE = findobj(axeAct,'Tag','Line_HIG');
        if ~isempty(old_LINE) , delete(old_LINE); end
        tag = 'txt_THR';
        txtTMP = findobj(axe,'Type','text','Tag',tag);
        if ~isempty(txtTMP)  , delete(txtTMP); end
        thr_NEW = xd(1);
        set(Edi_MAN_GLB_THR,'String',num2str(thr_NEW,'%10.5f'))
        thrTAB = get(Edi_MAN_GLB_THR,'UserData');
        thrTAB(:) = xd(1);
        set(Edi_MAN_GLB_THR,'String',num2str(xd(1),'%10.5f'),'UserData',thrTAB)
        LinL2N0 = [findobj(axe,'Tag','LinL2');findobj(axe,'Tag','LinN0')];
        LinW = mdw1dutils('LinW');
        set(LinL2N0,'LineWidth',LinW.N0,'LineStyle','-');
        setptr(fig,'arrow');
        drawnow;
        tool_NAME = ...
            blockdatamngr('get',fig,'tool_ATTR','Name');
        if isequal(tool_NAME,'CMP')
            mdw1dmisc('show',handles,'MAN_THR','LIN_GLB',idxCUR,thr_NEW);
        end
        set(handles.Pop_HIG_DEC,'Value',1)        
end
%--------------------------------------------------------------------------
function set_Axe_DEC_Pos(optMNGR,fig,handles,nbInput)

Axe_VIS_DEC = handles.Axe_VIS_DEC;
set(Axe_VIS_DEC,'Visible','Off');
pos_axes = wtbxappdata('get',fig,'Pos_Axe_VIS_DEC');
if isempty(pos_axes)
    pos_axes = get(Axe_VIS_DEC,'Position');
    pos_axes = cat(1,pos_axes{:});
    wtbxappdata('set',fig,'Pos_Axe_VIS_DEC',pos_axes);
end
switch optMNGR
    case 'sup'  ,    nbAxes = nbInput + 2; % nbInput = level
    case 'sep',      nbAxes = 1;
    case 'stem' ,    nbAxes = nbInput;     % nbInput = nb. signals
    case 'tree' ,    nbAxes = 4;           % Tree mode 3 axes
    case 'scrL2N0' , nbAxes = 4;           % Threshold mode 3 axes
end
nbMAX = length(Axe_VIS_DEC);
H = pos_axes(1,4);
yMIN  = min(pos_axes(1:nbMAX,2));
yMAX  = max(pos_axes(1:nbMAX,2)) + H;
dY = (yMAX-yMIN);
% if nbMAX>11 , nbMAX_Rat = 11; else nbMAX_Rat = nbMAX; end
nbMAX_Rat = nbMAX;
Ratio = (nbMAX_Rat/(nbMAX_Rat-1))*(dY/(nbMAX_Rat*H)-1);
xSIG = pos_axes(1,1);
wAXE = pos_axes(1,3);
yAXE = yMAX;
hAXE = dY/(nbAxes+(nbAxes-1)*Ratio);
dAXE = hAXE*Ratio;

p_axe = zeros(nbAxes,4);
if isequal(optMNGR,'tree')
    xA = xSIG/2;
    wA = wAXE+xA;
    hAXE_1_2 = hAXE;
    yAXE = yAXE - hAXE_1_2;
    p_axe(1,:) = [xA,yAXE,wA,hAXE_1_2];
    yAXE = yAXE-hAXE-2.3*dAXE;
    p_axe(2,:) = [xA,yAXE,wA,hAXE_1_2];
    hAXE_3 = 1.8*hAXE;
    ecar_3 = 2.1*dAXE;
    yAXE = yAXE - hAXE_3-ecar_3;
    p_axe(3,:) = [1/5,yAXE,3/5,hAXE_3];
    for k = 1:3
        set(Axe_VIS_DEC(k),'Position',p_axe(k,:),'Visible','On');
    end
    set(Axe_VIS_DEC(2),'XtickMode','auto','XTickLabelMode','auto');

elseif isequal(optMNGR,'scrL2N0')
    xA = xSIG/2;
    wA = wAXE+xA;
    hAXE = 0.9*hAXE;
    dAXE =  2*dAXE;
    
    yAXE = yAXE-hAXE;
    p_axe(1,:) = [xA,yAXE,wA,hAXE];
    yAXE = yAXE-hAXE-1.5*dAXE;
    p_axe(2,:) = [xA,yAXE,wA,hAXE];
    yAXE = yAXE-1.9*hAXE-1.5*dAXE;
    p_axe(3,:) = [xA,yAXE,wA,1.85*hAXE];
    for k = 1:3
        set(Axe_VIS_DEC(k),'Position',p_axe(k,:),'Visible','On');
    end
    set(Axe_VIS_DEC(2),'XtickMode','auto','XTickLabelMode','auto');

elseif isequal(optMNGR,'sep')
    xA = xSIG/2;
    wA = wAXE+xA;
    yAXE = yAXE-hAXE;
    p_axe(1,:) = [xA,yAXE,wA,hAXE];
    set(Axe_VIS_DEC(1),'Position',p_axe(1,:),'Visible','On',...
        'XtickMode','auto','XTickLabelMode','auto');

else
    for k=1:nbAxes
        yAXE = yAXE-hAXE;
        p_axe(k,:) = [xSIG,yAXE,wAXE,hAXE];
        yAXE = yAXE-dAXE;
        set(Axe_VIS_DEC(k),'Position',p_axe(k,:),'Visible','On');
    end
end
%--------------------------------------------------------------------------
function ylim = getYlim(yMini,yMaxi)

prec = 1.E-3;
dY   = (yMaxi-yMini+prec)*0.05;
ylim = [yMini-dY,yMaxi+dY];
%--------------------------------------------------------------------------
function [ftnSize,txtPos] = get_TxtInAxe_Attrb(S)

txtPos = 40;
lenSTR = length(S);
switch lenSTR
    case {1,2,3} , ftnSize = 12;
    case 4       , ftnSize = 11;
    case 5       , ftnSize = 10;
    otherwise    , ftnSize = 10;
end
%--------------------------------------------------------------------------
function okONE = oneSEL(pop)

strPOP = get(pop,'String');
item   = lower(strPOP{get(pop,'Value')});
okONE  = ~isequal(item,'all');
%=========================================================================%

