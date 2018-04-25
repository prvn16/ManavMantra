function varargout = wvdtool(option,varargin)
%WVDTOOL Wavelet display tool.
%   VARARGOUT = WVDTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 08-Jun-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% MemBloc1 of stored values.
%---------------------------
n_miscella     = 'WvDisp_Misc';
ind_graph_area = 1;
ind_wave_fam   = 2;
ind_wave_nam   = 3;
ind_refinement = 4;
nb1_stored     = 4;

% Tag property of objects.
%-------------------------
tag_prec_val  = 'Prec_Val';
tag_cmd_frame = 'Cmd_Frame';
tag_display   = 'Display';
tag_pus_inf1  = 'Pus_Inf1';
tag_pus_inf2  = 'Pus_Inf2';

switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,  ...
         X_Spacing,Y_Spacing,Def_FraBkColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width', ...
                'X_Spacing','Y_Spacing','Def_FraBkColor' ...
                );

        % Window initialization.
        %----------------------
        win_title = getWavMSG('Wavelet:divGUIRF:WVT_Name');
        [win_loctool,pos_win,win_units,str_numwin,...
                pos_frame0,Pos_Graphic_Area] = ...
                    wfigmngr('create',win_title,winAttrb,'ExtFig_WDisp',mfilename);
        if nargout>0 , varargout{1} = win_loctool; end
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_loctool, ...
            getWavMSG('Wavelet:divGUIRF:WVT_Name'),'WVDI_GUI');
		
		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_loctool, ...
            getWavMSG('Wavelet:divGUIRF:HLP_Wavelet'),'WVDI_FAMILIES');
		wfighelp('addHelpItem',win_loctool, ...
            getWavMSG('Wavelet:divGUIRF:HLP_WavFam'),'WVDI_ADVANCED');
		wfighelp('addHelpItem',win_loctool, ...
            getWavMSG('Wavelet:divGUIRF:PROP_WavFam'),'UT_WAVELET');
		wfighelp('addHelpItem',win_loctool, ...
            getWavMSG('Wavelet:divGUIRF:HLP_ADD_Wav'),'WVDI_NEWWAVE');		

        % Begin waiting.
        %---------------
        set(wfindobj('figure'),'Pointer','watch');

        % General parameters initialization.
        %-----------------------------------
        dx = X_Spacing;
        dy = Y_Spacing; dy2 = 2*dy;
        d_txt = (Def_Btn_Height-Def_Txt_Height);

        % Position property of objects.
        %------------------------------
        xlocINI      = pos_frame0([1 3]);
        ybottomINI   = pos_win(4)-1.5*Def_Btn_Height-dy2;
        y_low        = ybottomINI-2*Def_Btn_Height;
        x_left       = pos_frame0(1)+2*dx;
        pos_prec_txt = [x_left, y_low+d_txt/2, Def_Btn_Width, Def_Txt_Height];
        xleftB       = x_left+Def_Btn_Width+dx;
        pos_prec_val = [xleftB , y_low , Def_Btn_Width , Def_Btn_Height];
        wpop         = 3*(pos_frame0(3)-4*dx)/4;
		xborder      = (pos_frame0(3)-wpop)/2;
        xpop         = pos_frame0(1)+xborder;
        y_low        = pos_prec_txt(2)-5*Def_Btn_Height;
        pos_display  = [xpop, y_low, wpop, 2*Def_Btn_Height];
        y_low        = pos_display(2)-3*Def_Btn_Height;
        pos_inf_txt  = [x_left, y_low, 2.5*Def_Btn_Width, Def_Btn_Height];
        pos_pus_inf1    = pos_display;
		pos_pus_inf1(1) = pos_pus_inf1(1)-xborder/2;
		pos_pus_inf1(3) = pos_pus_inf1(3)+xborder;
        pos_pus_inf1(2) = pos_inf_txt(2)-2*Def_Btn_Height-dy;
        pos_pus_inf2    = pos_pus_inf1;
        pos_pus_inf2(2) = pos_pus_inf1(2)-3*Def_Btn_Height;

        % String property of objects.
        %----------------------------
        str_display  = getWavMSG('Wavelet:commongui:Str_Display');
        str_inf_txt  = getWavMSG('Wavelet:divGUIRF:StrInfo_On');
        str_inf1     = getWavMSG('Wavelet:divGUIRF:StrWavFAM','(HAAR)');
        str_inf2     = getWavMSG('Wavelet:divGUIRF:StrAllWavFAM');
        str_prec_txt = getWavMSG('Wavelet:divGUIRF:Str_Refinement');
        str_prec_val = ['5 ' ; '6 ' ; '7 ' ; '8 ' ; '9 ' ; '10' ; '11' ; '12' ];

        % Command part construction of the window.
        %-----------------------------------------
        utanapar('create',win_loctool, ...
                 'xloc',xlocINI,'bottom',ybottomINI,...
                 'datflag',0,'levflag',0,...
                 'wtype','all' ...
                 );

        comFigProp = {'Parent',win_loctool,'Units',win_units};
        comPopProp = [comFigProp,'Style','Popup'];
        comPusProp = [comFigProp,'Style','pushbutton'];
        comTxtProp = [comFigProp,'Style','Text', ...
           'HorizontalAlignment','left','BackgroundColor',Def_FraBkColor];

        Tooltip      = getWavMSG('Wavelet:divGUIRF:Tip_WV_Prec');
        txt_prec_txt = uicontrol(comTxtProp{:}, ...
            'Position',pos_prec_txt,...
            'String',str_prec_txt,...
            'TooltipString',Tooltip ...
            );
        pop_prec_val = uicontrol(comPopProp{:},...
            'Position',pos_prec_val,...
            'String',str_prec_val,...
            'Value',4,...
            'TooltipString',Tooltip,...
            'Tag',tag_prec_val...
            );
        pus_display  = uicontrol(comPusProp{:},...
            'Position',pos_display,...
            'String',str_display,...
            'Tag',tag_display...
            );
        uicontrol(comTxtProp{:}, ...
            'Position',pos_inf_txt,...
            'String',str_inf_txt...
            );
        pus_inf1     = uicontrol(comPusProp{:},...
            'Position',pos_pus_inf1,...
            'String',str_inf1,...
            'Max',2,...
            'Tag',tag_pus_inf1...
            );
        pus_inf2     = uicontrol(comPusProp{:},...
            'Position',pos_pus_inf2,...
            'String',str_inf2,...
            'Tag',tag_pus_inf2...
            );

        % Callbacks update.
        %------------------
        utanapar('set_cba_num',win_loctool,pus_display);
        [pop_fam,pop_num] = utanapar('handles',win_loctool,'fam','num');
        cb_fam = get(pop_fam,'Callback');
        cb_num = get(pop_num,'Callback');
        cba_upd_fam = [mfilename '(''upd_fam'',' str_numwin ');'];
        cba_update  = [mfilename '(''new'',' str_numwin ');'];
        cba_draw_1d = [mfilename '(''draw1d'',' str_numwin ');'];
        cba_inf1    = [mfilename '(''inf1'',' str_numwin ');'];
        cba_inf2    = [mfilename '(''inf2'',' str_numwin ');'];
        set(pop_fam,'Callback',[cb_fam , cba_upd_fam]);
        set(pop_num,'Callback',[cb_num , cba_update]);
        set(pop_prec_val,'Callback',cba_update);
        set(pus_display,'Callback',cba_draw_1d);
        set(pus_inf1,'Callback',cba_inf1);
        set(pus_inf2,'Callback',cba_inf2);

        % Setting units to normalized.
        %-----------------------------
        Pos_Graphic_Area = wfigmngr('normalize',win_loctool, ...
            Pos_Graphic_Area,'On');
        
		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_WVDI_GUI = [txt_prec_txt,pop_prec_val];
		wfighelp('add_ContextMenu',win_loctool,hdl_WVDI_GUI,'WVDI_GUI');
		%-------------------------------------

        % Memory for stored values.
        %--------------------------
        wmemtool('ini',win_loctool,n_miscella,nb1_stored);
        wmemtool('wmb',win_loctool,n_miscella,...
                       ind_graph_area,Pos_Graphic_Area,...
                       ind_wave_fam,'haar', ...
                       ind_wave_nam,'haar', ...
                       ind_refinement,0      ...
                       );

        % End waiting.
        %-------------
        set(wfindobj('figure'),'Pointer','arrow');

    case 'upd_fam'
        %**********************************************************%
        %** OPTION = 'upd_fam' -  UPDATE OF THE WAVELET FAMILY   **%
        %**********************************************************%
        win_loctool = varargin{1};
        new = wvdtool('new',win_loctool);
        if new==0 , return; end

        % Handles of tagged objects.
        %---------------------------
        pus_handles = findobj(win_loctool,'Style','pushbutton');
        pus_inf1    = findobj(pus_handles,'Tag',tag_pus_inf1);

        % Test family and Set visible on or off the wavelet number if exists.
        %--------------------------------------------------------------------
        wav_nam = cbanapar('get',win_loctool,'wav');
        [wav_fn,wav_fsn] = wavemngr('fields',wav_nam,'fn','fsn');
        strPush = ...
            getWavMSG('Wavelet:divGUIRF:PusNamWav',wav_fn,upper(wav_fsn));
        set(pus_inf1,'String',strPush);

    case 'inf1'
        %*****************************************%
        %** OPTION = 'inf1' - LOCAL INFORMATION **%
        %*****************************************%
        win_loctool = varargin{1};

        % Getting wavelet.
        %-----------------
        wav_nam = cbanapar('get',win_loctool,'wav');
        wav_fam = wavemngr('fam_num',wav_nam);
        infotxt = [deblankl(wav_fam) 'info.m'];
        [old_info,fig] = whelpfun('getflag');
        if ~isempty(old_info) && strcmp(infotxt,old_info)
            figure(fig); return;
        end

        % Waiting message.
        %-----------------
        wwaiting('msg',win_loctool,getWavMSG('Wavelet:commongui:WaitLoad'));

        [str_inf,fid] = wreadinf(infotxt,'noerror');
        if fid==-1
            msg =  getWavMSG('Wavelet:commongui:ErrLoadFile',infotxt);
            errargt(mfilename,msg,'msg');
            wwaiting('off',win_loctool);
            return
        else
            dim     = size(str_inf);
            rowfam  = str_inf(1,:);
            str_inf = str_inf(2:dim(1),:);
            col = 1;
            while all(str_inf(:,col)==' ') , col = col+1; end
            blk  = ' ' ;
            str_inf = [rowfam ; ...
                       str_inf(:,col:dim(2)) blk*ones(dim(1)-1,col-1) ];
        end
        ftnsize = wmachdep('FontSize','winfo');
        whelpfun('create',str_inf,infotxt,ftnsize);

        % End waiting.
        %-------------
        wwaiting('off',win_loctool);

    case 'inf2'
        %*****************************************%
        %** OPTION = 'inf2' - LOCAL INFORMATION **%
        %*****************************************%
        win_loctool = varargin{1};

        % Handles of tagged objects.
        %---------------------------
        infotxt        = 'infowave.m';
        [old_info,fig] = whelpfun('getflag');
        if ~isempty(old_info) && strcmp(infotxt,old_info)
            figure(fig); return;
        end

        % Waiting message.
        %-----------------
        wwaiting('msg',win_loctool,getWavMSG('Wavelet:commongui:WaitLoad'));

        [str_inf,fid]= wreadinf(infotxt,'noerror');
        if fid==-1
            msg = getWavMSG('Wavelet:commongui:ErrLoadFile',infotxt);
            errargt(mfilename,msg,'msg');
            wwaiting('off',win_loctool);
            return
        end
        ftnsize = wmachdep('FontSize','winfo');
        whelpfun('create',str_inf,infotxt,ftnsize);

        % End waiting.
        %-------------
        wwaiting('off',win_loctool);

    case 'draw1d'
        %************************************************%
        %** OPTION = 'draw1d' - DRAW AXES IN 1D        **%
        %************************************************%
        win_loctool = varargin{1};
        [new,Wave_Fam,Wave_Nam,prec_val] = wvdtool('new',win_loctool);
        if new==0 , return; end

        % Waiting message.
        %-----------------
        wwaiting('msg',win_loctool,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Handles of tagged objects.
        %---------------------------
        fra_handles = findobj(win_loctool,'Style','frame');
        hdl_frame0  = findobj(fra_handles,'Tag',tag_cmd_frame);

        % Update parameters selection before drawing.
        %-------------------------------------------
        wmemtool('wmb',win_loctool,n_miscella, ...
                       ind_wave_fam,Wave_Fam,  ...
                       ind_wave_nam,Wave_Nam,  ...
                       ind_refinement,prec_val  ...
                       );

        % General graphical parameters initialization.
        %--------------------------------------------
        pos_g_area     = wmemtool('rmb',win_loctool,n_miscella,ind_graph_area) ;
        pos_hdl_frame0 = get(hdl_frame0,'Position');
        win_units      = 'normalized';
        pos_win        = get(win_loctool,'Position');
        bdx            = 0.08*pos_win(3);
        bdy            = 0.09*pos_win(4);
        bdy_d          = bdy;
        bdy_u          = bdy;
        bdyl           = pos_g_area(2)+bdy_d;
        w_graph        = pos_hdl_frame0(1);
        h_graph        = pos_g_area(4);

        % Computing and displaying wavelets and filters.
        %-----------------------------------------------
        wtype = wavemngr('type',Wave_Nam);
        commonAxesProp = {...
           'Parent',win_loctool, ...
           'Units',win_units,    ...
           'Box','On'            ...
           };
        stemCOL = wtbutils('colors','stem_filters');
        switch wtype
            case 1
                str_wintitle = ...
                    getWavMSG('Wavelet:divGUIRF:NamWinWV',Wave_Fam,Wave_Nam);
                [phi,psi,xVal] = wavefun(Wave_Nam,prec_val);
                [Lo_D,Hi_D,Lo_R,Hi_R] = wfilters(Wave_Nam);
                xaxis_f = [0  length(Lo_D)-1];
                xVal_f  = xaxis_f(1):xaxis_f(2);
                xlim = xaxis_f + 0.01*[-1 1];
                nb      = 1;
                len     = length(xVal_f);
                while len>10
                    nb = 2*nb;
                    len = len/nb;
                end
                tics    = 0:nb:length(xVal_f);
                xlabs   = int2str(tics');
                yaxis_r = [min(min(Lo_R),min(Hi_R))   max(max(Lo_R),max(Hi_R))];
                yaxis_d = [min(min(Lo_D),min(Hi_D))   max(max(Lo_D),max(Hi_D))];
                h_axe_wave = (h_graph-2*bdy-bdy_d-bdy_u)/2;
                h_axe_filt = h_axe_wave/2;
                w_axe      = (w_graph-3*bdx)/2;
                pos_phi  = [ bdx,...
                             bdyl+2*bdy+2*h_axe_filt,...
                             w_axe,h_axe_wave ];
                pos_psi  = [ 2*bdx+w_axe,...
                             bdyl+2*bdy+2*h_axe_filt,...
                             w_axe,h_axe_wave ];
                pos_Lo_D = [ bdx,...
                             bdyl+bdy+h_axe_filt,...
                             w_axe,h_axe_filt ];
                pos_Lo_R = [ bdx,...
                              bdyl,w_axe,h_axe_filt ];
                pos_Hi_D = [ 2*bdx+w_axe,...
                             bdyl+bdy+h_axe_filt,...
                             w_axe,h_axe_filt ];
                pos_Hi_R = [ 2*bdx+w_axe,bdyl,w_axe,h_axe_filt ];

                axeProp  = [commonAxesProp,'Position',pos_phi];
                axeTitle = getWavMSG('Wavelet:divGUIRF:ScaFunPhi');
                axe_phi  = plotYval(xVal,phi,axeProp,'r',axeTitle);

                axeProp  = [commonAxesProp,'Position',pos_psi];
                axeTitle = getWavMSG('Wavelet:divGUIRF:WavFunPsi');
                axe_psi  = plotYval(xVal,psi,axeProp,'g',axeTitle);

                axe_Lo_D = axes(commonAxesProp{:},'Position',pos_Lo_D);
                wdstem(axe_Lo_D,xVal_f,Lo_D,stemCOL,1);
                set(axe_Lo_D,...
                    'YLim',yaxis_d,            ...
                    'XLim',xlim,               ...
                    'Box','On',                ...
                    'XTickLabelMode','manual', ...
                    'XTick',tics,              ...
                    'XTickLabel',xlabs         ...
                    );
                wtitle(getWavMSG('Wavelet:divGUIRF:Dec_LowFil'), ...
                    'Parent',axe_Lo_D);

                axe_Lo_R = axes(commonAxesProp{:},'Position',pos_Lo_R);
                wdstem(axe_Lo_R,xVal_f,Lo_R,stemCOL,1);
                set(axe_Lo_R,...
                    'YLim',yaxis_r,            ...
                    'XLim',xlim,               ...
                    'Box','On',                ...
                    'XTickLabelMode','manual', ...
                    'XTick',tics,              ...
                    'XTickLabel',xlabs         ...
                    );
                wtitle(getWavMSG('Wavelet:divGUIRF:Rec_LowFil'), ...
                    'Parent',axe_Lo_R);

                axe_Hi_D = axes(commonAxesProp{:},'Position',pos_Hi_D);
                wdstem(axe_Hi_D,xVal_f,Hi_D,stemCOL,1);
                set(axe_Hi_D,...
                    'YLim',yaxis_d,            ...
                    'XLim',xlim,               ...
                    'Box','On',                ...
                    'XTickLabelMode','manual', ...
                    'XTick',tics,              ...
                    'XTickLabel',xlabs         ...
                    );
                wtitle(getWavMSG('Wavelet:divGUIRF:Dec_HigFil'), ...
                    'Parent',axe_Hi_D);

                axe_Hi_R = axes(commonAxesProp{:},'Position',pos_Hi_R);
                wdstem(axe_Hi_R,xVal_f,Hi_R,stemCOL,1);
                set(axe_Hi_R,...
                    'YLim',yaxis_r,            ...
                    'XLim',xlim,               ...
                    'Box','On',                ...
                    'XTickLabelMode','manual', ...
                    'XTick',tics,              ...
                    'XTickLabel',xlabs         ...
                    );
                wtitle(getWavMSG('Wavelet:divGUIRF:Rec_HigFil'), ...
                    'Parent',axe_Hi_R);
                axe_cmd = [axe_phi axe_psi];
                axe_act = [axe_Lo_D axe_Hi_D axe_Lo_R axe_Hi_R];

            case 2
                [phi1,psi1,phi2,psi2,xVal] = wavefun(Wave_Nam,prec_val);
                [Lo_D,Hi_D,Lo_R,Hi_R]  = wfilters(Wave_Nam);
                xaxis_f = [0 length(Lo_D)-1];
                xVal_f  = 0:xaxis_f(2);
                xlim     = xaxis_f + 0.01*[-1 1];
                nb      = 1;
                len     = length(xVal_f);
                while len>10
                    nb = 2*nb;
                    len = len/nb;
                end
                tics    = 0:nb:length(xVal_f);
                xlabs   = int2str(tics');
                yaxis_r = [min(min(Lo_R),min(Hi_R)) max(max(Lo_R),max(Hi_R))];
                yaxis_d = [min(min(Lo_D),min(Hi_D)) max(max(Lo_D),max(Hi_D))];
                str_wintitle = getWavMSG('Wavelet:divGUIRF:Bior_WavNam',Wave_Nam);
                h_axe_wave = 2*(h_graph-3*bdy-bdy_d-bdy_u)/6;
                h_axe_filt = (h_graph-3*bdy-bdy_d-bdy_u)/6;
                w_axe      = (w_graph-3*bdx)/2;

                pos_phi1 = [ bdx,...
                             bdyl+3*bdy+2*h_axe_filt+h_axe_wave,...
                             w_axe,h_axe_wave];
                pos_phi2 = [ bdx,...
                             bdyl+bdy+h_axe_filt,...
                             w_axe,h_axe_wave];
                pos_psi1 = [ 2*bdx+w_axe,...
                             bdyl+3*bdy+2*h_axe_filt+h_axe_wave,...
                             w_axe,h_axe_wave];
                pos_psi2 = [ 2*bdx+w_axe,...
                             bdyl+bdy+h_axe_filt,...
                             w_axe,h_axe_wave];
                pos_Lo_D = [ bdx,...
                             bdyl+2*bdy+h_axe_filt+h_axe_wave,...
                             w_axe,h_axe_filt];
                pos_Lo_R = [ bdx,bdyl,w_axe,h_axe_filt];
                pos_Hi_D = [ 2*bdx+w_axe,...
                              bdyl+2*bdy+h_axe_filt+h_axe_wave,...
                              w_axe,h_axe_filt];
                pos_Hi_R = [ 2*bdx+w_axe,bdyl,w_axe,h_axe_filt];

                axeProp  = [commonAxesProp,'Position',pos_phi1];
                axeTitle = getWavMSG('Wavelet:divGUIRF:Dec_ScaFun');
                axe_phi1 = plotYval(xVal,phi1,axeProp,'r',axeTitle);

                axeProp  = [commonAxesProp,'Position',pos_phi2];
                axeTitle = getWavMSG('Wavelet:divGUIRF:Rec_ScaFun');
                axe_phi2 = plotYval(xVal,phi2,axeProp,'r',axeTitle);

                axeProp  = [commonAxesProp,'Position',pos_psi1];
                axeTitle = getWavMSG('Wavelet:divGUIRF:Dec_WavFun');
                axe_psi1 = plotYval(xVal,psi1,axeProp,'g',axeTitle);

                axeProp  = [commonAxesProp,'Position',pos_psi2];
                axeTitle = getWavMSG('Wavelet:divGUIRF:Rec_WavFun');
                axe_psi2 = plotYval(xVal,psi2,axeProp,'g',axeTitle);

                axe_Lo_D = axes(commonAxesProp{:},'Position',pos_Lo_D);
                wdstem(axe_Lo_D,xVal_f,Lo_D,stemCOL,1);
                set(axe_Lo_D,...
                    'YLim',yaxis_d,...
                    'XLim',xlim,...
                    'Box','On',...
                    'XTickLabelMode','manual',...
                    'XTick',tics,...
                    'XTickLabel',xlabs...
                    );
                wtitle(getWavMSG('Wavelet:divGUIRF:Dec_LowFil'), ...
                    'Parent',axe_Lo_D);

                axe_Lo_R = axes(commonAxesProp{:},'Position',pos_Lo_R);
                wdstem(axe_Lo_R,xVal_f,Lo_R,stemCOL,1);
                set(axe_Lo_R,...
                    'YLim',yaxis_r,...
                    'XLim',xlim,...
                    'Box','On',...
                    'XTickLabelMode','manual',...
                    'XTick',tics,...
                    'XTickLabel',xlabs...
                    );
                wtitle(getWavMSG('Wavelet:divGUIRF:Rec_LowFil'), ...
                    'Parent',axe_Lo_R);

                axe_Hi_D = axes(commonAxesProp{:},'Position',pos_Hi_D);
                wdstem(axe_Hi_D,xVal_f,Hi_D,stemCOL,1);
                set(axe_Hi_D,...
                    'YLim',yaxis_d,...
                    'XLim',xlim,...
                    'Box','On',...
                    'XTickLabelMode','manual',...
                    'XTick',tics,...
                    'XTickLabel',xlabs...
                    );
                wtitle(getWavMSG('Wavelet:divGUIRF:Dec_HigFil'), ...
                    'Parent',axe_Hi_D);

                axe_Hi_R = axes(commonAxesProp{:},'Position',pos_Hi_R);
                wdstem(axe_Hi_R,xVal_f,Hi_R,stemCOL,1);
                set(axe_Hi_R,...
                    'YLim',yaxis_r,...
                    'XLim',xlim,...
                    'Box','On',...
                    'XTickLabelMode','manual',...
                    'XTick',tics,...
                    'XTickLabel',xlabs...
                    );
                wtitle(getWavMSG('Wavelet:divGUIRF:Rec_HigFil'), ...
                    'Parent',axe_Hi_R);

                axe_cmd = [axe_phi1 axe_phi2 axe_psi1 axe_psi2];
                axe_act = [axe_Lo_D axe_Hi_D axe_Lo_R axe_Hi_R];

            case 3
                str_wintitle = ...
                    getWavMSG('Wavelet:divGUIRF:NamWinWV',Wave_Fam,Wave_Nam);
                [phi,psi,xVal] = wavefun(Wave_Nam,prec_val);
                h_axe   = h_graph-bdy_d-bdy_u;
                w_axe   = (w_graph-3*bdx)/2;
                pos_phi = [bdx,bdyl,w_axe,h_axe];
                pos_psi = [2*bdx+w_axe,bdyl,w_axe,h_axe];

                axeProp  = [commonAxesProp,'Position',pos_phi];
                axeTitle = getWavMSG('Wavelet:divGUIRF:ScaFunPhi');
                axe_phi  = plotYval(xVal,phi,axeProp,'r',axeTitle);

                axeProp  = [commonAxesProp,'Position',pos_psi];
                axeTitle = getWavMSG('Wavelet:divGUIRF:WavFunPsi');
                axe_psi  = plotYval(xVal,psi,axeProp,'g',axeTitle);

                axe_cmd = [axe_phi axe_psi];
                axe_act = [];

            case 4
                str_wintitle = ...
                    getWavMSG('Wavelet:divGUIRF:NamWinWV',Wave_Fam,Wave_Nam);
                [psi,xVal]   = wavefun(Wave_Nam,prec_val);
                h_axe   = h_graph-bdy_d-bdy_u;
                w_axe   = w_graph-2*bdx;
                pos_psi = [bdx,bdyl,w_axe,h_axe];

                axeProp  = [commonAxesProp,'Position',pos_psi];
                axeTitle = getWavMSG('Wavelet:divGUIRF:WavFunPsi');
                axe_psi  = plotYval(xVal,psi,axeProp,'g',axeTitle);

                axe_cmd = axe_psi;
                axe_act = [];

            case 5
                str_wintitle = ...
                    getWavMSG('Wavelet:divGUIRF:NamWinWV',Wave_Fam,Wave_Nam);
                [psi,xVal] = wavefun(Wave_Nam,prec_val);
                h_axe  = (h_graph-bdy_d-bdy_u-bdy)/2;
                w_axe  = (w_graph-3*bdx)/2;

                pos_abs = [bdx,bdyl,w_axe,h_axe];
                pos_ang = [2*bdx+w_axe,bdyl,w_axe,h_axe];
                y_axe   = bdyl+h_axe+bdy;
                pos_rea = [bdx,y_axe,w_axe,h_axe];
                pos_ima = [2*bdx+w_axe,y_axe,w_axe,h_axe];

                yVal     = real(psi);
                axeProp  = [commonAxesProp,'Position',pos_rea];
                axeTitle = getWavMSG('Wavelet:divGUIRF:ReaPartPsi');
                axe_rea  = plotYval(xVal,yVal,axeProp,'r',axeTitle);

                yVal     = imag(psi);
                axeProp  = [commonAxesProp,'Position',pos_ima];
                axeTitle = getWavMSG('Wavelet:divGUIRF:ImgPartPsi');
                axe_ima  = plotYval(xVal,yVal,axeProp,'g',axeTitle);

                yVal     = abs(psi);
                axeProp  = [commonAxesProp,'Position',pos_abs];
                axeTitle = getWavMSG('Wavelet:divGUIRF:ModPartPsi');
                axe_abs  = plotYval(xVal,yVal,axeProp,'r',axeTitle);

                yVal     = angle(psi);
                axeProp  = [commonAxesProp,'Position',pos_ang];
                axeTitle = getWavMSG('Wavelet:divGUIRF:AngPartPsi');
                axe_ang  = plotYval(xVal,yVal,axeProp,'g',axeTitle);
 
                axe_cmd = [axe_rea axe_ima axe_abs axe_ang];
                axe_act = [];
        end

        % Display status line.
        %---------------------
        wfigtitl('String',win_loctool,str_wintitle,'on');

        % Axes attachment.
        %-----------------
        dynvtool('init',win_loctool,[],axe_cmd,axe_act,[0 0]);

        % Setting units to normalized.
        %-----------------------------
        set(findobj(win_loctool,'Units','pixels'),'Units','normalized');

        % End waiting.
        %-------------
        wwaiting('off',win_loctool);

    case 'new'
        %*************************************************%
        %** OPTION = 'new' -  test drawing parameters   **%
        %*************************************************%
        win_loctool = varargin{1};

        % Handles of tagged objects.
        %---------------------------
        pop_handles  = findobj(win_loctool,'Style','popupmenu');
        pop_prec_val = findobj(pop_handles,'Tag',tag_prec_val);

        % Test Main parameters selection before drawing.
        %-----------------------------------------------
        Wave_Nam = cbanapar('get',win_loctool,'wav');
        Wave_Fam = wavemngr('fam_num',Wave_Nam);
        prec_val = get(pop_prec_val,'Value')+4;
        [wfam,wnam,raf] = wmemtool('rmb',win_loctool,n_miscella,...
                                ind_wave_fam,ind_wave_nam,ind_refinement);
        if raf~=prec_val || ~strcmp(wnam,Wave_Nam) || ~strcmp(wfam,Wave_Fam)
            varargout = {1,Wave_Fam,Wave_Nam,prec_val};
        else
            varargout = {0,Wave_Fam,Wave_Nam,prec_val};
            return
        end

        % Setting refinement to 0 (as flag).
        %----------------------------------
        wmemtool('wmb',win_loctool,n_miscella,ind_refinement,0);

        % Cleaning the graphical part.
        %-----------------------------
        dynvtool('stop',win_loctool);
        axe_handles = findobj(get(win_loctool,'Children'),'flat', ...
                              'Type','axes','Visible','on');
        delete(axe_handles);
        wfigtitl('vis',win_loctool,'off');

    case 'demo'
        %*******************************************%
        %** OPTION = 'demo' -  for DEMOS or TESTS **%
        %*******************************************%
        win_loctool = varargin{1};
        Wave_Nam    = varargin{2};

        % Handles of tagged objects.
        %---------------------------
        children     = get(win_loctool,'Children');
        uic_handles  = findobj(children,'flat','Type','uicontrol');
        pop_handles  = findobj(uic_handles,'Style','popupmenu');
        pop_prec_val = findobj(pop_handles,'Tag',tag_prec_val);
        pus_handles  = findobj(uic_handles,'Style','pushbutton');
        pus_inf1     = findobj(pus_handles,'Tag',tag_pus_inf1);

        cbanapar('set',win_loctool,'wav',Wave_Nam);
        [Wave_Fam,tabNums] = wavemngr('fields',Wave_Nam,'fsn','tabNums');

        if nargin==4
            set(pop_prec_val,'Value',varargin{3});
        end
        if size(tabNums,1)>1
            str_inf1 = getWavMSG('Wavelet:divGUIRF:Info_WV_2',Wave_Fam);
        else
            str_inf1 = getWavMSG('Wavelet:divGUIRF:Info_WV_1',Wave_Fam);
        end
        set(pus_inf1,'String',str_inf1);
        wvdtool('draw1d',win_loctool);

    case 'close'

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function axe = plotYval(xVal,yVal,axeProp,color,axeTitle)

xlim  = [min(xVal) , max(xVal)];
mini  = min(yVal);
maxi  = max(yVal);
dyVal = maxi-mini;
if dyVal<sqrt(eps) , dyVal = sqrt(eps);end
ylim = [mini maxi]+0.02*dyVal*[-1 1];
axe  = axes(axeProp{:},'XLim',xlim,'YLim',ylim);
line('XData',xVal,'YData',yVal,'Color',color,'Parent',axe);
wtitle(axeTitle,'Parent',axe);
%-----------------------------------------------------------------------------%
%=============================================================================%

