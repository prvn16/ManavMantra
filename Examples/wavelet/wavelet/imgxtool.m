function varargout = imgxtool(option,varargin)
%IMGXTOOL Image extension tool.
%   VARARGOUT = IMGXTOOL(OPTION,VARARGIN)
%
%   GUI oriented tool which allows the construction of a new
%   image from an original one by truncation or extension.
%   Extension is done by selecting different possible modes:
%   Symmetric, Periodic, Zero Padding, Continuous or Smooth.
%   A special mode is provided to extend an image in order 
%   to be accepted by the SWT decomposition.
%------------------------------------------------------------
%   Internal options:
%
%   OPTION = 'create'          'load'             'demo'
%            'update_deslen'   'extend_truncate'
%            'draw'            'save'
%            'clear_graphics'  'mode'
%            'close'
%
%   See also WEXTEND.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 30-Nov-98.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.12.4.19 $  $Date: 2013/07/05 04:30:16 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% Default values.
%----------------
default_nbcolors = 255;

% Image Coding Value.
%-------------------
codemat_v = wimgcode('get');

% Initializations for all options excepted 'create'.
%---------------------------------------------------
switch option

  case 'create'
  
  otherwise
    % Get figure handle.
    %-------------------
    win_imgxtool = varargin{1};

    % Get stored structure.
    %----------------------
    Hdls_UIC_C      = wfigmngr('getValue',win_imgxtool,'Hdls_UIC_C');
    Hdls_UIC_H      = wfigmngr('getValue',win_imgxtool,'Hdls_UIC_H');
    Hdls_UIC_V      = wfigmngr('getValue',win_imgxtool,'Hdls_UIC_V');
    Hdls_UIC_Swt    = wfigmngr('getValue',win_imgxtool,'Hdls_UIC_Swt');
    Hdls_Axes       = wfigmngr('getValue',win_imgxtool,'Hdls_Axes');
    Hdls_Colmap     = wfigmngr('getValue',win_imgxtool,'Hdls_Colmap');
    Pos_Axe_Img_Ori = wfigmngr('getValue',win_imgxtool,'Pos_Axe_Img_Ori');
 
    % Get UIC Handles.
    %-----------------
    [m_load,m_save,m_demo,txt_image,edi_image,...
    txt_mode,pop_mode,pus_extend] = deal(Hdls_UIC_C{:}); %#ok<ASGLU>
    m_exp_sig = wtbxappdata('get',win_imgxtool,'m_exp_sig'); 
 
    [frm_fra_H,txt_fra_H,txt_length_H,edi_length_H,txt_nextpow2_H,  ...
     edi_nextpow2_H,txt_prevpow2_H,edi_prevpow2_H,txt_deslen_H,     ...
     edi_deslen_H,txt_direct_H,pop_direct_H] = deal(Hdls_UIC_H{:}); %#ok<ASGLU>
 
    [frm_fra_V,txt_fra_V,txt_length_V,edi_length_V,txt_nextpow2_V,  ...
     edi_nextpow2_V,txt_prevpow2_V,edi_prevpow2_V,txt_deslen_V,     ...
     edi_deslen_V,txt_direct_V,pop_direct_V] = deal(Hdls_UIC_V{:}); %#ok<ASGLU>
 
    [txt_swtdec,pop_swtdec,frm_fra_H_2,txt_fra_H_2,txt_swtlen_H,    ...
     edi_swtlen_H,txt_swtclen_H,edi_swtclen_H,txt_swtdir_H,         ...
     edi_swtdir_H,txt_swtdec,pop_swtdec,frm_fra_V_2,txt_fra_V_2,    ...
     txt_swtlen_V,edi_swtlen_V,txt_swtclen_V,edi_swtclen_V          ...
     ] = deal(Hdls_UIC_Swt{1:end-2}); %#ok<ASGLU>
end

% Process control depending on the calling option.
%-------------------------------------------------
switch option

    case 'create'
    %-------------------------------------------------------%
    % Option: 'CREATE' - Create Figure, Uicontrols and Axes %
    %-------------------------------------------------------%
	
        % Get Globals.
        %-------------
        [btn_Height,Def_Btn_Width, ...
        X_Spacing,Y_Spacing,ediActBkColor,ediInActBkColor,    ...
        Def_FraBkColor,Def_ShadowColor] =                     ...
                mextglob('get',                               ...
                'Def_Btn_Height','Def_Btn_Width',             ...
                'X_Spacing','Y_Spacing',                      ...
                'Def_Edi_ActBkColor','Def_Edi_InActBkColor',  ...
                'Def_FraBkColor','Def_ShadowColor' ...
                );

        % Window initialization.
        %-----------------------
        [win_imgxtool,pos_win,win_units,str_numwin,pos_frame0] = ...
                wfigmngr('create',getWavMSG('Wavelet:divGUIRF:Imgx_Name'),  ...
                         winAttrb,'ExtFig_Tool_3',                 ...
                        {mfilename,'cond'},1,1,0);
        if nargout>0 , varargout{1} = win_imgxtool; end
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_imgxtool, ...
			getWavMSG('Wavelet:divGUIRF:II_D_Ext'),'IMGX_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_imgxtool,...
			getWavMSG('Wavelet:divGUIRF:BordDist'),'BORDER_DIST');

        % Menu construction for current figure.
        %--------------------------------------
        m_files = wfigmngr('getmenus',win_imgxtool,'file');
        m_load  = uimenu(m_files,...
            'Label',getWavMSG('Wavelet:commongui:Load_Image'),'Position',1, ...
            'Callback',[mfilename '(''load'',' str_numwin ');']  ...            
            );
        m_save  = uimenu(m_files,...
            'Label',getWavMSG('Wavelet:divGUIRF:Save_Image'),     ...
            'Position',2,                            ...
            'Enable','Off',                          ...
            'Callback',                              ...
            [mfilename '(''save'',' str_numwin ');'] ...
            );
        m_demo  = uimenu(m_files, ...
           'Label',getWavMSG('Wavelet:commongui:Example_Ext'),'Position',3);
        uimenu(m_files,...
            'Label',getWavMSG('Wavelet:commongui:Import_Image'), ...
            'Position',4,'Separator','On', ...
            'Tag','Import', ...
            'Callback', ...
            [mfilename '(''load'',' str_numwin ',''wrks'');'] ...
            );
        m_exp_sig = uimenu(m_files,...
            'Label',getWavMSG('Wavelet:commongui:Str_ExpImg'),  ...
            'Position',5,'Enable','Off','Separator','Off', ...
            'Tag','Export', ...            
            'Callback',[mfilename '(''exp_wrks'',' str_numwin ');']  ...
            ); 
        
        m_demoIDX = uimenu(m_demo,...
            'Label',getWavMSG('Wavelet:dw2dRF:Lab_IndImg'),...
            'Tag','Lab_IndImg','Position',1);
        m_demoCOL = uimenu(m_demo,...
            'Label',getWavMSG('Wavelet:dw2dRF:Lab_ColImg'),...
            'Tag','Lab_ColImg','Position',2);
        demoSET = {...
         'woman2'  , 'ext'   , '{''zpd'' , [220,200] , ''both'' , ''both''}' , 'BW' ; ...
         'woman2'  , 'trunc' , '{''nul'' , [ 96, 96] , ''both'' , ''both''}' , 'BW' ; ...
         'wbarb'   , 'ext'   , '{''sym'' , [512,200] , ''right'', ''both''}' , 'BW' ; ...
         'noiswom' , 'ext'   , '{''sym'' , [512,512] , ''right'', ''down''}' , 'BW' ; ...
         'noiswom' , 'ext'   , '{''ppd'' , [512,512] , ''right'', ''down''}' , 'BW' ; ...
         'wbarb'   , 'ext'   , '{''sym'' , [512,512] , ''both'' , ''both''}' , 'BW' ; ...
         'facets'  , 'ext'   , '{''ppd'' , [512,512] , ''both'' , ''both''}' , 'COL' ; ...
         'mandel'  , 'ext'   , '{''sym'' , [512,512] , ''left'' , ''both''}' , 'COL'  ...
         };
        nbDEM = size(demoSET,1);
        beg_call_str = [mfilename '(''demo'',' str_numwin ','''];
        for k = 1:nbDEM
            typ = demoSET{k,2};
            fil = demoSET{k,1};
            par = demoSET{k,3};
            optIMG = demoSET{k,4};
            libel = getWavMSG(['Wavelet:divGUIRF:ImgEXT_Ex' int2str(k)]);
            action = [beg_call_str fil  ''',''' typ ''',' par ...
                            ''',''' optIMG ''');'];
            if k<7 , md = m_demoIDX; else md = m_demoCOL; end
            uimenu(md,'Label',libel,'Callback',action);
        end

        % Borders and double borders.
        %----------------------------
        dx = X_Spacing; dx2 = 2*dx;
        dy = Y_Spacing; dy2 = 2*dy;

        % General graphical parameters initialization.
        %--------------------------------------------
        x_frame0  = pos_frame0(1);
        cmd_width = pos_frame0(3);
        pus_width = cmd_width-4*dx2;
        unit_width = cmd_width/20;
        txt_width = 9*unit_width;
        edi_width = 5*unit_width;
        pop_width = 5*unit_width;
        bdx       = 0.08*pos_win(3);
        bdy       = 0.06*pos_win(4);
        x_graph   = bdx;
        y_graph   = 2*btn_Height+dy;
        h_graph   = pos_frame0(4)-y_graph;
        w_graph   = pos_frame0(1);
        

        % Command part of the window.
        %============================

        % Position property of objects.
        %------------------------------
        delta_Xleft        = wtbutils('extension_PREFS');          
        xlocINI            = [x_frame0 cmd_width];
        ybottomINI         = pos_win(4)-dy2;
        x_left_0           = x_frame0 + unit_width;
        x_left_1           = x_left_0 + txt_width/2 + delta_Xleft;
        x_left_2           = x_left_0 + txt_width + 2*unit_width + dx ;
        
        y_low              = ybottomINI-(1/2*btn_Height+1*dy2);
        pos_txt_image      = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_image      = ...
            [x_left_1+unit_width, y_low+dy/2, 2*edi_width, btn_Height];

        y_low              = y_low-1*(btn_Height+3*dy2);  %high DPI 2*dy2
        pos_txt_length_H   = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_length_H   = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+1*dy2);
        pos_txt_nextpow2_H = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_nextpow2_H = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+1*dy2);
        pos_txt_prevpow2_H = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_prevpow2_H = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+1*dy2);
        pos_txt_deslen_H   = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_deslen_H   = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+1*dy2);
        pos_txt_direct_H   = [x_left_0, y_low, txt_width, btn_Height];
        pos_pop_direct_H   = [x_left_2, y_low+dy/2, pop_width , btn_Height];

        fra_left           = x_frame0+unit_width/4;
        fra_low            = y_low-dy;
        fra_width          = cmd_width-unit_width/2;
        fra_height         = 5*(btn_Height+1*dy2)+dy2;
        pos_fra_H          = [fra_left, fra_low, fra_width, fra_height];
        txt_fra_H_height   = 3*btn_Height/4;
        txt_fra_H_width    = Def_Btn_Width;
        txt_fra_H_low      = (fra_low + fra_height) - (txt_fra_H_height / 2);
        txt_fra_H_left     = fra_left + (fra_width - txt_fra_H_width) / 2;
        pos_txt_fra_H      = [txt_fra_H_left, txt_fra_H_low, ...
                               txt_fra_H_width, txt_fra_H_height];
 
        y_low              = fra_low-1.5*(btn_Height+2*dy2); %1.5*btn_Height
        pos_txt_length_V   = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_length_V   = [x_left_2, y_low+dy, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+dy2);
        pos_txt_nextpow2_V = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_nextpow2_V = [x_left_2, y_low+dy/2, edi_width, btn_Height];

        y_low              = y_low-(btn_Height+dy2/2);
        pos_txt_prevpow2_V = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_prevpow2_V = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+dy2/2);
        pos_txt_deslen_V   = [x_left_0, y_low, txt_width btn_Height];
        pos_edi_deslen_V   = [x_left_2, y_low+dy/2, edi_width , btn_Height];

        y_low              = y_low-(btn_Height+1*dy2/2);
        pos_txt_direct_V   = [x_left_0, y_low, txt_width, btn_Height];
        pos_pop_direct_V   = [x_left_2, y_low+dy/2, edi_width , btn_Height];
 
        fra_left           = x_frame0+unit_width/4;
        fra_low            = y_low-dy/2;
        fra_width          = cmd_width-unit_width/2;
        fra_height         = 5*(btn_Height+dy2)+dy2;
        pos_fra_V          = [fra_left, fra_low, fra_width, fra_height];
        txt_fra_V_height   = 3* btn_Height/4;
        txt_fra_V_width    = Def_Btn_Width;
        txt_fra_V_low      = (fra_low + fra_height) - (txt_fra_V_height / 2);
        txt_fra_V_left     = fra_left + (fra_width - txt_fra_V_width) / 2;
        pos_txt_fra_V      = [txt_fra_V_left, txt_fra_V_low, ...
                               txt_fra_V_width, txt_fra_V_height];

        x_left             = x_left_0-dx2+(cmd_width-9*unit_width)/2;
        y_low              = fra_low-(btn_Height/2+1*dy2);  %btn_Height/2
        pos_txt_mode       = [x_left, y_low, 12*unit_width btn_Height];
 
        y_low              = y_low-(btn_Height/2+dy);  %dy/4  btn_Height/2
        pop_mode_width     = cmd_width - 6*dx2;
        xleft_pop          = x_frame0+3*dx2;
        pos_pop_mode       = [xleft_pop, y_low+10, pop_mode_width/2 , btn_Height/1.5];  %pop_mode_width/2

        y_low              = y_low-1.5*btn_Height-dy/4;  %dy/4  2*btn_Height to 1.5*btn_Height
        pos_pus_extend     = [x_left_0+dx2, y_low+10, pus_width-10 , btn_Height/1.5]; %High DPI pus_width-10

        pos_fra_H_2        = pos_fra_H;
        pos_fra_H_2(2)     = pos_fra_H(2)-btn_Height;
        pos_fra_H_2(4)     = 3*(btn_Height+2*dy2)+dy;

        txt_fra_H_height   = 3*btn_Height/4;
        txt_fra_H_width    = Def_Btn_Width;
        txt_fra_H_low      = (pos_fra_H_2(2)+pos_fra_H_2(4))-(txt_fra_H_height/2);
        txt_fra_H_left     = pos_fra_H_2(1)+(pos_fra_H_2(3)-txt_fra_H_width)/ 2;
        pos_txt_fra_H_2    = [txt_fra_H_left, txt_fra_H_low,...
                              txt_fra_H_width, txt_fra_H_height];
 
        x_left             = x_left_0-dx2;
        y_low              = pos_fra_H_2(2)+pos_fra_H_2(4)+3*dy2;
        pos_txt_swtdec     = [x_left, y_low, 9*txt_width/8, btn_Height];
        x_left             = x_left + pos_txt_swtdec(3);
        pos_pop_swtdec     = [x_left, y_low+dy, edi_width, btn_Height];
 
        y_low              = pos_fra_H_2(2)+pos_fra_H_2(4)-(btn_Height+2*dy2);
        pos_txt_swtlen_H   = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtlen_H   = [x_left_2, y_low+dy, edi_width, btn_Height];
 
        y_low              = y_low-(btn_Height+2*dy2);
        pos_txt_swtclen_H  = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtclen_H  = [x_left_2, y_low+dy, edi_width, btn_Height];
 
        y_low              = y_low-(btn_Height+2*dy2);
        pos_txt_swtdir_H   = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtdir_H   = [x_left_2, y_low+dy, edi_width, btn_Height];
 
        pos_fra_V_2        = pos_fra_V;
        pos_fra_V_2(4)     = 3*(btn_Height+2*dy2)+dy;

        txt_fra_V_height   = 3*btn_Height/4;
        txt_fra_V_width    = Def_Btn_Width;
        txt_fra_V_low      = pos_fra_V_2(2)+pos_fra_V_2(4)- txt_fra_V_height/2;
        txt_fra_V_left     = pos_fra_V_2(1)+(pos_fra_V_2(3)-txt_fra_V_width)/2;
        pos_txt_fra_V_2    = [txt_fra_V_left, txt_fra_V_low,...
                              txt_fra_V_width, txt_fra_V_height];
 
        y_low              = pos_fra_V_2(2)+pos_fra_V_2(4)-(btn_Height+2*dy2);
        pos_txt_swtlen_V   = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtlen_V   = [x_left_2, y_low+dy, edi_width, btn_Height];
 
        y_low              = y_low-(btn_Height+2*dy2);
        pos_txt_swtclen_V  = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtclen_V  = [x_left_2, y_low+dy, edi_width, btn_Height];
 
        y_low              = y_low-(btn_Height+2*dy2);
        pos_txt_swtdir_V   = [x_left_0, y_low, txt_width, btn_Height];
        pos_edi_swtdir_V   = [x_left_2, y_low+dy, edi_width, btn_Height];

        % String property of objects.
        %----------------------------
        str_txt_image    = getWavMSG('Wavelet:commongui:Str_Image');
        str_edi_image    = '';
        str_txt_length   = getWavMSG('Wavelet:commongui:Str_Length');
        str_edi_length   = '';
        str_txt_nextpow2 = getWavMSG('Wavelet:divGUIRF:Str_Nextpow2');
        str_edi_nextpow2 = '';
        str_txt_prevpow2 = getWavMSG('Wavelet:divGUIRF:Str_Prevpow2');
        str_edi_prevpow2 = '';
        str_txt_deslen   = getWavMSG('Wavelet:divGUIRF:Str_DesLength');
        str_edi_deslen   = '';
        str_txt_direct   = getWavMSG('Wavelet:divGUIRF:Str_Dir2Ext');
        str_pop_direct_H = { ...
            getWavMSG('Wavelet:divGUIRF:Str_dir_Both') ; ...
            getWavMSG('Wavelet:divGUIRF:Str_dir_Left') ; ...
            getWavMSG('Wavelet:divGUIRF:Str_dir_Right')  ...
            };
        str_pop_direct_V = {...
            getWavMSG('Wavelet:divGUIRF:Str_dir_Both') ; ...
            getWavMSG('Wavelet:divGUIRF:Str_dir_Up') ; ...
            getWavMSG('Wavelet:divGUIRF:Str_dir_Down')  ...
            };
        str_txt_fra_H    = getWavMSG('Wavelet:divGUIRF:Str_HOR');
        str_txt_fra_H_2  = getWavMSG('Wavelet:divGUIRF:Str_HOR');
        str_txt_fra_V    = getWavMSG('Wavelet:divGUIRF:Str_VER');
        str_txt_fra_V_2  = getWavMSG('Wavelet:divGUIRF:Str_VER');
        str_txt_mode     = getWavMSG('Wavelet:divGUIRF:Str_ExtM');
        str_pop_mode     = {...
            getWavMSG('Wavelet:divGUIRF:ExtM_Symmetric_H'), ...
            getWavMSG('Wavelet:divGUIRF:ExtM_Symmetric_W'), ...
            getWavMSG('Wavelet:divGUIRF:ExtM_Antisymmetric_H'), ...
            getWavMSG('Wavelet:divGUIRF:ExtM_Antisymmetric_W'), ...
            getWavMSG('Wavelet:divGUIRF:ExtM_Periodic'), ...
            getWavMSG('Wavelet:divGUIRF:ExtM_ZPD'), ...
            getWavMSG('Wavelet:divGUIRF:ExtM_Continuous'), ...
            getWavMSG('Wavelet:divGUIRF:ExtM_Smooth'), ...
            getWavMSG('Wavelet:divGUIRF:ExtM_For_SWT')  ...            
             };        
        str_pus_extend    = getWavMSG('Wavelet:divGUIRF:Str_Extend');
        str_txt_swtdec    = getWavMSG('Wavelet:divGUIRF:SWT_DecLev');
        str_pop_swtdec    = num2str((1:10)');
        str_txt_swtlen_H  = getWavMSG('Wavelet:commongui:Str_Length');
        str_edi_swtlen_H  = '';
        str_txt_swtclen_H = getWavMSG('Wavelet:divGUIRF:Computed_Length');
        str_edi_swtclen_H = '';
        str_txt_swtdir_H  = getWavMSG('Wavelet:divGUIRF:Str_Dir2Ext');
        str_edi_swtdir_H  = getWavMSG('Wavelet:divGUIRF:Str_dir_Right');
        str_tip_swtclen_H = getWavMSG('Wavelet:divGUIRF:Computed_Length');
        str_tip_swtclen_V = str_tip_swtclen_H;
        str_txt_swtlen_V  = getWavMSG('Wavelet:commongui:Str_Length');
        str_edi_swtlen_V  = '';
        str_txt_swtclen_V = getWavMSG('Wavelet:divGUIRF:Computed_Length');
        str_edi_swtclen_V = '';
        str_txt_swtdir_V  = getWavMSG('Wavelet:divGUIRF:Str_Dir2Ext');
        str_edi_swtdir_V  = getWavMSG('Wavelet:divGUIRF:Str_dir_Down');
 
        % Construction of uicontrols.
        %----------------------------
        commonProp = {...
            'Parent',win_imgxtool, ...
            'Units',win_units,      ...
            'Visible','off'        ...
            };
        comFraProp = [commonProp, ...
            'BackgroundColor',Def_FraBkColor, ...
            'ForegroundColor',Def_ShadowColor,  ...
            'Style','frame'                   ...
            ];
        comPusProp = [commonProp,'Style','pushbutton'];
        comPopProp = [commonProp,'Style','Popupmenu'];
        comTxtProp = [commonProp, ...
            'ForegroundColor','k',            ...
            'BackgroundColor',Def_FraBkColor, ...
            'HorizontalAlignment','left',     ...
            'Style','Text'                    ...
            ];
        comEdiProp = [commonProp, ...
            'ForegroundColor','k',          ...
            'HorizontalAlignment','center', ...
            'Style','Edit'                  ...
            ];

        txt_image = uicontrol( ...
            comTxtProp{:},                     ...
            'Position',pos_txt_image,          ...
            'String',str_txt_image             ...
            );
        edi_image = uicontrol( ...
            comEdiProp{:},                     ...
            'Position',pos_edi_image,          ...
            'String',str_edi_image,            ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );

        frm_fra_H = uicontrol(  ...
            comFraProp{:},                     ...
            'Position',pos_fra_H               ...
            );
        txt_fra_H = uicontrol(  ...
            comTxtProp{:},                     ...
            'HorizontalAlignment','center',    ...
            'Position',pos_txt_fra_H,          ...
            'String',str_txt_fra_H             ...
            );
        txt_length_H   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_length_H,       ...
            'String',str_txt_length            ...
            );
        edi_length_H   = uicontrol( ...
            comEdiProp{:},                     ...
            'Position',pos_edi_length_H,       ...
            'String',str_edi_length,           ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_nextpow2_H = uicontrol( ...
            comTxtProp{:},                     ...
            'Position',pos_txt_nextpow2_H,     ...
            'String',str_txt_nextpow2          ...
            );
        edi_nextpow2_H = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_nextpow2_H,     ...
            'String',str_edi_nextpow2,         ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_prevpow2_H = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_prevpow2_H,     ...
            'String',str_txt_prevpow2          ...
            );
        edi_prevpow2_H = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_prevpow2_H,     ...
            'String',str_edi_prevpow2,         ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_deslen_H   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_deslen_H,       ...
            'String',str_txt_deslen            ...
            );
        edi_deslen_H   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_deslen_H,       ...
            'String',str_edi_deslen,           ...
            'BackgroundColor',ediActBkColor   ...
            );
        txt_direct_H   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_direct_H,       ...
            'String',str_txt_direct            ...
            );
        pop_direct_H   = uicontrol(  ...
            comPopProp{:},                     ...
            'Position',pos_pop_direct_H,       ...
            'String',str_pop_direct_H          ...
            );

        frm_fra_V      = uicontrol(  ...
            comFraProp{:},                     ...
            'Position',pos_fra_V               ...
            );
        txt_fra_V      = uicontrol(  ...
            comTxtProp{:},                     ...
            'HorizontalAlignment','center',    ...
            'Position',pos_txt_fra_V,          ...
            'String',str_txt_fra_V             ...
            );
        txt_length_V   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_length_V,       ...
            'String',str_txt_length            ...
            );
        edi_length_V   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_length_V,       ...
            'String',str_edi_length,           ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );

        txt_nextpow2_V = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_nextpow2_V,     ...
            'String',str_txt_nextpow2          ...
            );
        edi_nextpow2_V = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_nextpow2_V,     ...
            'String',str_edi_nextpow2,         ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_prevpow2_V = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_prevpow2_V,     ...
            'String',str_txt_prevpow2          ...
            );
        edi_prevpow2_V = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_prevpow2_V,     ...
            'String',str_edi_prevpow2,         ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_deslen_V   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_deslen_V,       ...
            'String',str_txt_deslen            ...
            );
        edi_deslen_V   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_deslen_V,       ...
            'String',str_edi_deslen,           ...
            'BackgroundColor',ediActBkColor   ...
            );
        txt_direct_V   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_direct_V,       ...
            'String',str_txt_direct            ...
            );
        pop_direct_V   = uicontrol(  ...
            comPopProp{:},                     ...
            'Position',pos_pop_direct_V,       ...
            'String',str_pop_direct_V          ...
            );

        txt_mode       = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_mode,           ...
            'String',str_txt_mode              ...
            );
        pop_mode       = uicontrol(  ...
            comPopProp{:},                     ...
            'Position',pos_pop_mode,           ...
            'String',str_pop_mode              ...
            );
        pus_extend     = uicontrol(  ...
            comPusProp{:},              ...
            'Position',pos_pus_extend,  ...
            'String',str_pus_extend,    ...
            'Tag','Extend',             ...             
            'Interruptible','On'        ...
            );

        txt_swtdec     = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtdec,         ...
            'String',str_txt_swtdec            ...
            );
        pop_swtdec     = uicontrol(  ...
            comPopProp{:},                     ...
            'Position',pos_pop_swtdec,         ...
            'String',str_pop_swtdec            ...
            );
        frm_fra_H_2    = uicontrol(  ...
            comFraProp{:},                     ...
            'Position',pos_fra_H_2             ...
            );
        txt_fra_H_2    = uicontrol(  ...
            comTxtProp{:},                     ...
            'HorizontalAlignment','center',    ...
            'Position',pos_txt_fra_H_2,        ...
            'String',str_txt_fra_H_2           ...
            );
        txt_swtlen_H   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtlen_H,       ...
            'String',str_txt_swtlen_H          ...
            );
        edi_swtlen_H   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtlen_H,       ...
            'String',str_edi_swtlen_H,         ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_swtclen_H  = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtclen_H,      ...
            'TooltipString',str_tip_swtclen_H, ...
            'String',str_txt_swtclen_H         ...
            );
        edi_swtclen_H  = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtclen_H,      ...
            'String',str_edi_swtclen_H,        ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_swtdir_H   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtdir_H,       ...
            'String',str_txt_swtdir_H          ...
            );
        edi_swtdir_H   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtdir_H,       ...
            'String',str_edi_swtdir_H,         ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        frm_fra_V_2    = uicontrol(  ...
            comFraProp{:},                     ...
            'Position',pos_fra_V_2             ...
            );
        txt_fra_V_2    = uicontrol(  ...
            comTxtProp{:},                     ...
            'HorizontalAlignment','center',    ...
            'Position',pos_txt_fra_V_2,        ...
            'String',str_txt_fra_V_2           ...
            );
        txt_swtlen_V   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtlen_V,       ...
            'String',str_txt_swtlen_V          ...
            );
        edi_swtlen_V   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtlen_V,       ...
            'String',str_edi_swtlen_V,         ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_swtclen_V  = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtclen_V,      ...
            'TooltipString',str_tip_swtclen_V, ...
            'String',str_txt_swtclen_V         ...
            );
        edi_swtclen_V  = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtclen_V,      ...
            'String',str_edi_swtclen_V,        ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
        txt_swtdir_V   = uicontrol(  ...
            comTxtProp{:},                     ...
            'Position',pos_txt_swtdir_V,       ...
            'String',str_txt_swtdir_V          ...
            );
        edi_swtdir_V   = uicontrol(  ...
            comEdiProp{:},                     ...
            'Position',pos_edi_swtdir_V,       ...
            'String',str_edi_swtdir_V,         ...
            'BackgroundColor',ediInActBkColor,  ...
            'Enable','Inactive'                ...
            );
                             
        % Callback property of objects.
        %------------------------------
        str_win_imgxtool = num2mstr(win_imgxtool);
        cba_edi_deslen_H = [mfilename '(''update_deslen'','   ...
                                 str_win_imgxtool             ...
                                 ',''H'');'];
        cba_edi_deslen_V = [mfilename '(''update_deslen'','   ...
                                 str_win_imgxtool             ...
                                 ',''V'');'];
        cba_pop_direct_H = [mfilename '(''clear_GRAPHICS'','  ...
                                 str_win_imgxtool             ...
                                 ');'];
        cba_pop_direct_V = [mfilename '(''clear_GRAPHICS'','  ...
                                 str_win_imgxtool             ...
                                 ');'];
        cba_pop_mode 	 = [mfilename '(''mode'','            ...
                                 str_win_imgxtool             ...
                                 ');'];
        cba_pus_extend 	 = [mfilename '(''extend_truncate'',' ...
                                 str_win_imgxtool             ...
                                 ');'];
        cba_pop_swtdec 	 = [mfilename '(''update_swtdec'','   ...
                                 str_win_imgxtool             ...
                                 ');'];
        set(edi_deslen_H,'Callback',cba_edi_deslen_H);
        set(pop_direct_H,'Callback',cba_pop_direct_H);
        set(edi_deslen_V,'Callback',cba_edi_deslen_V);
        set(pop_direct_V,'Callback',cba_pop_direct_V);
        set(pop_mode,'Callback',cba_pop_mode);
        set(pus_extend,'Callback',cba_pus_extend);
        set(pop_swtdec,'Callback',cba_pop_swtdec);
        
        % Graphic part of the window.
        %============================

        % Axes Construction.
        %-------------------
        commonProp  = {...
            'Parent',win_imgxtool,           ...
            'Visible','off',                 ...
            'Units','pixels',                ...
            'XTickLabelMode','manual',       ...
            'YTickLabelMode','manual',       ...
            'XTicklabel',[],'YTickLabel',[], ...
            'XTick',[],'YTick',[],           ...
            'Box','On'                       ...
            };

        % Image Axes construction.
        %--------------------------
        x_left      = x_graph;
        x_wide      = w_graph-2*x_left;
        y_low       = y_graph+2*bdy;
        y_height    = h_graph-y_low-2*bdy;
        Pos_Axe_Img = [x_left, y_low, x_wide, y_height];
        Axe_Img     = axes( commonProp{:},         ...
                            'YDir','Reverse',      ...
                            'Position',Pos_Axe_Img ...
                            );

        % Legend Axes construction.
        %--------------------------
        X_Leg = Pos_Axe_Img(1);
        Y_Leg = Pos_Axe_Img(2) + 43*Pos_Axe_Img(4)/40;
        W_Leg = (Pos_Axe_Img(3) - Pos_Axe_Img(1)) / 2.5;
        H_Leg = (Pos_Axe_Img(4) - Pos_Axe_Img(2)) / 5;
        
        Pos_Axe_Leg = [X_Leg Y_Leg W_Leg H_Leg];
        ud.dynvzaxe.enable = 'Off';
        Axe_Leg = axes(commonProp{:},          ...
            'Position',Pos_Axe_Leg, ...
            'XLim',[0 180],         ...
            'YLim',[0 20],          ...
            'UserData',ud           ...
            );
        line(                           ...
            'Parent',Axe_Leg,          ...
            'XData',11:30,             ...
            'YData',ones(1,20)*14,     ...
            'LineWidth',3,             ...
            'Visible','off',           ...
            'Color',[0.95 0.95 0]      ...
            );
        line(                          ...
            'Parent',Axe_Leg,          ...
            'XData',11:30,             ...
            'YData',ones(1,20)*7,      ...
            'LineWidth',3,             ...
            'Visible','off',           ...
            'Color','red'              ...
            );
        text(40,14,getWavMSG('Wavelet:divGUIRF:Trans_Image'), ...
            'Parent',Axe_Leg,          ...
            'FontWeight','normal',     ...
            'Visible','off'            ...
            );
        text(40,7,getWavMSG('Wavelet:commongui:OriImg'),  ...
            'Parent',Axe_Leg,          ...
            'FontWeight','normal',     ...
            'Visible','off'            ...
            );

        % Adding colormap GUI.
        %---------------------
        [Hdls_Colmap1,Hdls_Colmap2] = utcolmap('create',win_imgxtool, ...
                 'xloc',xlocINI,'bkcolor',Def_FraBkColor);
        Hdls_Colmap = [Hdls_Colmap1 Hdls_Colmap2];
        if iscell(Hdls_Colmap) , Hdls_Colmap = cat(1,Hdls_Colmap{:}); end 
        set(Hdls_Colmap,'Visible','off');

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_imgxtool);

        % Store values.
        %--------------
        Hdls_UIC_C  = {...
            m_load,m_save,m_demo,...
            txt_image,edi_image,  ...
            txt_mode,pop_mode,pus_extend ...
            };
        Hdls_UIC_H  = {...
            frm_fra_H,txt_fra_H,           ...
            txt_length_H,edi_length_H,     ...
            txt_nextpow2_H,edi_nextpow2_H, ...
            txt_prevpow2_H,edi_prevpow2_H, ...
            txt_deslen_H,edi_deslen_H,     ...
            txt_direct_H,pop_direct_H      ...
            };
        Hdls_UIC_V  = {...
            frm_fra_V,txt_fra_V,           ...
            txt_length_V,edi_length_V,     ...
            txt_nextpow2_V,edi_nextpow2_V, ...
            txt_prevpow2_V,edi_prevpow2_V, ...
            txt_deslen_V,edi_deslen_V,     ...
            txt_direct_V,pop_direct_V      ...
            };

        Hdls_UIC_Swt = {...
            txt_swtdec,pop_swtdec,       ...
            frm_fra_H_2,txt_fra_H_2,     ...
            txt_swtlen_H,edi_swtlen_H,   ...
            txt_swtclen_H,edi_swtclen_H, ...
            txt_swtdir_H,edi_swtdir_H,   ...
            txt_swtdec,pop_swtdec,       ...
            frm_fra_V_2,txt_fra_V_2,     ...
            txt_swtlen_V,edi_swtlen_V,   ...
            txt_swtclen_V,edi_swtclen_V, ...
            txt_swtdir_V,edi_swtdir_V    ...
            };
 
        Hdls_Axes    = struct('Axe_Img',Axe_Img,'Axe_Leg',Axe_Leg);

        Pos_Axe_Img_Ori = get(Axe_Img,'Position');

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_BORDER_DIST = [txt_mode,pop_mode];
		wfighelp('add_ContextMenu',win_imgxtool,...
			hdl_BORDER_DIST,'BORDER_DIST');
		%-------------------------------------
        
		% Store handles and values.
        %--------------------------		
        wfigmngr('storeValue',win_imgxtool,'Hdls_UIC_C',Hdls_UIC_C);
        wfigmngr('storeValue',win_imgxtool,'Hdls_UIC_H',Hdls_UIC_H);
        wfigmngr('storeValue',win_imgxtool,'Hdls_UIC_V',Hdls_UIC_V);
        wfigmngr('storeValue',win_imgxtool,'Hdls_UIC_Swt',Hdls_UIC_Swt);
        wfigmngr('storeValue',win_imgxtool,'Hdls_Axes',Hdls_Axes);
        wfigmngr('storeValue',win_imgxtool,'Hdls_Colmap',Hdls_Colmap);
        wfigmngr('storeValue',win_imgxtool,'Pos_Axe_Img_Ori',Pos_Axe_Img_Ori);
        wtbxappdata('set',win_imgxtool,'m_exp_sig',m_exp_sig);

        % Set Figure Visible 'On'
        %------------------------
        set(win_imgxtool,'Visible','On');

    case 'load'
    %------------------------------------------%
    % Option: 'LOAD' - Load the original image %
    %------------------------------------------%
        if length(varargin)<2  % LOAD IMAGE
            imgFileType = getimgfiletype;
            [imgInfos,Anal_Image,map,ok] = ...
                utguidiv('load_img',win_imgxtool,imgFileType, ...
                getWavMSG('Wavelet:commongui:Load_Image'),default_nbcolors); %#ok<ASGLU>
        
        elseif isequal(varargin{2},'wrks')  % LOAD from WORKSPACE
            [imgInfos,Anal_Image,ok] = wtbximport('2d');
            % map = pink(default_nbcolors);
            
        else
            img_Name = deblank(varargin{2});
            filename = [img_Name '.mat'];
            pathname = utguidiv('WTB_DemoPath',filename);
            if length(varargin)<5 , optIMG = ''; else  optIMG = varargin{5}; end
            [imgInfos,Anal_Image,map,ok] = utguidiv('load_dem2D',...
                win_imgxtool,pathname,filename,default_nbcolors,optIMG); %#ok<ASGLU>
        end
        if ~ok, return; end
        flagIDX = length(size(Anal_Image))<3;
        setfigNAME(win_imgxtool,flagIDX)
        

        % Begin waiting.
        %---------------
        wwaiting('msg',win_imgxtool,getWavMSG('Wavelet:commongui:WaitLoad'));

        % Cleaning.
        %----------
        imgxtool('clear_GRAPHICS',win_imgxtool,'load');

        % Disable save menu.
        %-------------------
        set([m_save,m_exp_sig],'Enable','off');

        % Compute UIC values.
        %--------------------
        H           = imgInfos.size(1);
        V           = imgInfos.size(2);
        pow_H       = fix(log(H)/log(2));
        Next_Pow2_H = 2^(pow_H+1);
        if isequal(2^pow_H,H)
            Prev_Pow2_H = 2^(pow_H-1);
            swtpow_H    = pow_H;
        else
            Prev_Pow2_H = 2^pow_H;
            swtpow_H    = pow_H+1;
        end
        pow_V       = fix(log(V)/log(2));
        Next_Pow2_V = 2^(pow_V+1);
        if isequal(2^pow_V,V)
            Prev_Pow2_V   = 2^(pow_V-1);
            swtpow_V    = pow_V;
        else
            Prev_Pow2_V   = 2^pow_V;
            swtpow_V    = pow_V+1;
        end
        
        % Compute the max level value for SWT.
        %-------------------------------------
        Max_Lev = min(swtpow_H,swtpow_V);
                
        % Compute the default level for SWT .
        %-----------------------------------
        def_pow = 1;
        if ~rem(H,2)
            while ~rem(H,2^def_pow), def_pow = def_pow + 1; end
            def_level_H = def_pow-1;
        else
            def_level_H = def_pow;
        end
        
        def_pow = 1;
        if ~rem(V,2)
            while ~rem(V,2^def_pow), def_pow = def_pow + 1; end
            def_level_V = def_pow-1;
        else
            def_level_V = def_pow;
        end
        Def_Lev = min(max(def_level_H,def_level_V),Max_Lev);
        
        % Compute the extended lengths for SWT.
        %--------------------------------------
        C_Length_H = H;
        while rem(C_Length_H,2^def_level_H), C_Length_H = C_Length_H + 1; end
        C_Length_V = V;
        while rem(C_Length_V,2^def_level_V), C_Length_V = C_Length_V + 1; end
        
        % Set UIC values.
        %----------------
        set(edi_image,'String',imgInfos.name);
        set(edi_length_H,'String',sprintf('%.0f',H));
        set(edi_nextpow2_H,'String',sprintf('%.0f',Next_Pow2_H));
        set(edi_prevpow2_H,'String',sprintf('%.0f',Prev_Pow2_H));
        set(edi_deslen_H,'String',sprintf('%.0f',Next_Pow2_H));
        set(pop_direct_H,'Value',1);
        set(edi_length_V,'String',sprintf('%.0f',V));
        set(edi_nextpow2_V,'String',sprintf('%.0f',Next_Pow2_V));
        set(edi_prevpow2_V,'String',sprintf('%.0f',Prev_Pow2_V));
        set(edi_deslen_V,'String',sprintf('%.0f',Next_Pow2_V));
        set(pop_direct_V,'Value',1);
        set(pop_mode,'Value',1);
        set(pus_extend, ...
            'String',getWavMSG('Wavelet:divGUIRF:Str_Extend'), ...
            'Enable','on','UserData','extend');
        set(pop_swtdec,'String',num2str((1:Max_Lev)'));
        set(pop_swtdec,'Value',Def_Lev);
        set(edi_swtlen_H,'String',sprintf('%.0f',H));
        set(edi_swtlen_V,'String',sprintf('%.0f',V));        
        set(edi_swtclen_H,'String',sprintf('%.0f',C_Length_H));
        set(edi_swtclen_V,'String',sprintf('%.0f',C_Length_V));        
                
        % Set UIC visible on.
        %--------------------
        set(cat(1,Hdls_UIC_H{:}),'Visible','on')
        set(cat(1,Hdls_UIC_V{:}),'Visible','on')
        set(cat(1,Hdls_UIC_Swt{:}),'Visible','off')
        set(cat(1,Hdls_UIC_C{4:end}),'Visible','on')

        % Setting Colormap.
        %------------------
        maxVal   = double(max(Anal_Image(:)));
        nbcolors = round(max([2,min([maxVal,default_nbcolors])]));
        cbcolmap('set',win_imgxtool,'pal',{'pink',nbcolors});
        if ~flagIDX ,
            set(Hdls_Colmap,'Visible','off');
        else
            set(Hdls_Colmap,'Visible','on');
            set(Hdls_Colmap,'Enable','on');
        end

        % Get Axes Handles.
        %------------------
        Axe_Img =  Hdls_Axes.Axe_Img ;

        % Drawing.
        %---------
        NB_ColorsInPal = default_nbcolors;
        Anal_Image     = wimgcode('cod',0,Anal_Image,NB_ColorsInPal,codemat_v);
        image(                ...
            'Parent',Axe_Img,   ...
            'XData',[1,H],      ...
            'YData',[1,V],      ...
            'CData',wd2uiorui2d('d2uint',Anal_Image), ...
            'Visible','on'      ...
            );
        [w,h]          = wpropimg([H V],Pos_Axe_Img_Ori(3),Pos_Axe_Img_Ori(4));
        Pos_Axe_Img    = Pos_Axe_Img_Ori;
        Pos_Axe_Img(1) = Pos_Axe_Img(1)+abs(Pos_Axe_Img(3)-w)/2;
        Pos_Axe_Img(2) = Pos_Axe_Img(2)+abs(Pos_Axe_Img(4)-h)/2;
        Pos_Axe_Img(3) = w;
        Pos_Axe_Img(4) = h;
        set(Axe_Img,                ...
            'XLim',[1,H],           ...
            'YLim',[1,V],           ...
            'Position',Pos_Axe_Img, ...
            'Visible','on');
        set(get(Axe_Img,'title'),'String',getWavMSG('Wavelet:commongui:OriImg'));

        % Store values.
        %--------------
        wfigmngr('storeValue',win_imgxtool,'Anal_Image',Anal_Image);
        wfigmngr('storeValue',win_imgxtool,'Pos_Axe_Img_Bas',Pos_Axe_Img);

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 0;
        wfigmngr('storeValue',win_imgxtool,'File_Save_Flag',File_Save_Flag);
        
        % Dynvtool Attachment.
        %----------------------
        dynvtool('init',win_imgxtool,[],Axe_Img,[],[1 1],'','','');

        % End waiting.
        %-------------
        wwaiting('off',win_imgxtool);
        
    case 'demo'
        imgxtool('load',varargin{:});
        ext_OR_trunc = varargin{3};
        if ~isempty(varargin{4})
            par_Demo = varargin{4};
        else
            return;
        end
        extMode  = par_Demo{1};
        lenSIG   = par_Demo{2};
        direct_H = lower(par_Demo{3});
        direct_V = lower(par_Demo{4});
        if ~isequal(extMode,'swt')
            set(edi_deslen_H,'String',sprintf('%.0f',lenSIG(1)));
            imgxtool('update_deslen',win_imgxtool,'H','noClear');
            set(edi_deslen_V,'String',sprintf('%.0f',lenSIG(2)));
            imgxtool('update_deslen',win_imgxtool,'V','noClear');
        else
            set(pop_swtdec,'Value',lenSIG)
            imgxtool('update_swtdec',win_imgxtool)
        end
        switch direct_H
          case 'both'  , direct = 1;
          case 'left'  , direct = 2;
          case 'right' , direct = 3;
        end
        set(pop_direct_H,'Value',direct);
        switch direct_V
          case 'both' , direct = 1;
          case 'up'   , direct = 2;
          case 'down' , direct = 3;
        end
        set(pop_direct_V,'Value',direct);
        switch ext_OR_trunc
          case 'ext'
            switch extMode
              case 'sym' ,         extVal = 1;
              case 'ppd' ,         extVal = 5;
              case 'zpd' ,         extVal = 6;
              case 'sp0' ,         extVal = 7;
              case {'sp1','spd'} , extVal = 8;
              case 'swt' ,         extVal = 9;
            end
            set(pop_mode,'Value',extVal);
            imgxtool('mode',win_imgxtool,'noClear')

          case 'trunc'
        end
        imgxtool('extend_truncate',win_imgxtool);

    case 'update_swtdec'
    %----------------------------------------------------------------------%
    % Option: 'UPDATE_SWTDEC' - Update values when using popup in SWT case %
    %----------------------------------------------------------------------%        
        % Update the computed length.
        %----------------------------
        Image_Length_H = wstr2num(get(edi_swtlen_H,'String'));
        Image_Length_V = wstr2num(get(edi_swtlen_V,'String'));
        Level          = get(pop_swtdec,'Value');
        remLen_H       = rem(Image_Length_H,2^Level);
        remLen_V       = rem(Image_Length_V,2^Level);
        if remLen_H>0
            C_Length_H = Image_Length_H + 2^Level-remLen_H;
        else
            C_Length_H = Image_Length_H;
        end
        if remLen_V>0
            C_Length_V = Image_Length_V + 2^Level-remLen_V;
        else
            C_Length_V = Image_Length_V;
        end
        set(edi_swtclen_H,'String',sprintf('%.0f',C_Length_H));
        set(edi_swtclen_V,'String',sprintf('%.0f',C_Length_V));
        
        % Enabling Extend button.
        %------------------------        
        set(pus_extend,'String',getWavMSG('Wavelet:divGUIRF:Str_Extend'), ...
            'UserData','extend','Enable','on');

    case 'update_deslen'
    %--------------------------------------------------------------------------%
    % Option: 'UPDATE_DESLEN' - Update values when changing the Desired Length %
    %--------------------------------------------------------------------------%
		
        % Get arguments.
        %---------------
        Direction = varargin{2};

        % Cleaning.
        %----------
        if nargin<4 , imgxtool('clear_GRAPHICS',win_imgxtool); end

        % Get Common UIC Handles.
        %------------------------	
        Image_length_H   = wstr2num(get(edi_length_H,'String'));
        Desired_length_H = wstr2num(get(edi_deslen_H,'String'));
        Image_length_V   = wstr2num(get(edi_length_V,'String'));
        Desired_length_V = wstr2num(get(edi_deslen_V,'String'));
        uic_mode         = [txt_mode;pop_mode];
        switch Direction
          case 'H'
            % Update UIC values.
            %-------------------
            if      isempty(Desired_length_H) || Desired_length_H < 2
                    set(edi_deslen_H,'String',get(edi_nextpow2_H,'String'));
                    set(txt_direct_H, ...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Dir2Ext'));
                    set(pus_extend,...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Extend'), ...
                        'UserData','extend','Enable','on');
            elseif  Image_length_H <= Desired_length_H
                    set(txt_direct_H, ...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Dir2Ext'));
                    set(pus_extend, ...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Extend'), ...
                        'UserData','extend');
            elseif  Image_length_H > Desired_length_H
                    set(txt_direct_H, ...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Dir2Trunc'));
                    set(pus_extend, ...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Truncate'),'UserData','truncate');
            end

          case 'V'
            % Update UIC values.
            %-------------------
            if      isempty(Desired_length_V) || Desired_length_V < 2
                    set(edi_deslen_V,'String',get(edi_nextpow2_V,'String'));
                    set(txt_direct_V, ...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Dir2Ext'));
                    set(pus_extend, ...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Extend'), ...
                        'UserData','extend');
            elseif  Image_length_V <= Desired_length_V
                    set(txt_direct_V, ...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Dir2Ext'));
                    set(pus_extend, ...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Extend'), ...
                        'UserData','extend');
            elseif  Image_length_V > Desired_length_V
                    set(txt_direct_V, ...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Dir2Trunc'));
                    set(pus_extend, ...
                        'String',getWavMSG('Wavelet:divGUIRF:Str_Truncate'),'UserData','truncate');
            end

          otherwise
              errargt(mfilename, ...
                  getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
              error(message('Wavelet:FunctionArgVal:Invalid_Input'));
        end
        set(uic_mode,'Enable','on');
        set(pus_extend,'Enable','on');                                
        if     	isequal(Image_length_H,Desired_length_H) && ...
                isequal(Image_length_V,Desired_length_V)
                set(txt_direct_V, ...
                    'String',getWavMSG('Wavelet:divGUIRF:Str_Dir2Ext'));
                set(txt_direct_H, ...
                    'String',getWavMSG('Wavelet:divGUIRF:Str_Dir2Ext'));
                set(uic_mode,'Enable','off');
                set(pus_extend,'Enable','off');                        
        elseif  ((Image_length_H <= Desired_length_H)  && ...
                 (Image_length_V <  Desired_length_V)) || ...
                ((Image_length_H <  Desired_length_H)  && ...
                 (Image_length_V <= Desired_length_V))                
                set(uic_mode,'Visible','on');
                set(pus_extend, ...
                    'String',getWavMSG('Wavelet:divGUIRF:Str_Extend'), ...
                    'UserData','extend');
        elseif  (Image_length_H <= Desired_length_H) && ...
                (Image_length_V > Desired_length_V)
                set(uic_mode,'Visible','on');
                set(pus_extend,'String',getWavMSG('Wavelet:divGUIRF:Str_Ext_Trunc'),'UserData','ext_trunc');
        elseif  (Image_length_H > Desired_length_H) && ...
                (Image_length_V <= Desired_length_V)
                set(uic_mode,'Visible','on');
                set(pus_extend,'String',getWavMSG('Wavelet:divGUIRF:Str_Trunc_Ext'),'UserData','trunc_ext');
        elseif  (Image_length_H > Desired_length_H) && ...
                (Image_length_V > Desired_length_V)
                set(uic_mode,'Visible','off');
                set(pus_extend,'String',getWavMSG('Wavelet:divGUIRF:Str_Truncate'),'UserData','truncate');
        end
        set(pus_extend,'Visible','on');
	
    case 'mode'
    %------------------------------------------------------------------------%
    % Option: 'MODE' -  Update the command part when changing Extension Mode %
    %------------------------------------------------------------------------%

        % Cleaning.
        %----------
        if nargin<3 , imgxtool('clear_GRAPHICS',win_imgxtool); end

        % Checking the SWT case for visibility settings.
        %-----------------------------------------------
        Mode_str = get(pop_mode,'String');
        Mode_val = get(pop_mode,'Value');
        if  strcmp(deblank(Mode_str(Mode_val,:)), ...
                getWavMSG('Wavelet:divGUIRF:ExtM_For_SWT'))
            set(cat(1,Hdls_UIC_H{:}),'Visible','off')
            set(cat(1,Hdls_UIC_V{:}),'Visible','off')
            set(cat(1,Hdls_UIC_Swt{:}),'Visible','on')

            Image_Length_H    = wstr2num(get(edi_swtlen_H,'String'));
            Computed_Length_H = wstr2num(get(edi_swtclen_H,'String'));
            Image_Length_V    = wstr2num(get(edi_swtlen_V,'String'));
            Computed_Length_V = wstr2num(get(edi_swtclen_V,'String'));
            set(pus_extend, ...
                'String',getWavMSG('Wavelet:divGUIRF:Str_Extend'), ...
                'UserData','extend');
            if isequal(Image_Length_H,nextpow2(Image_Length_H)) && ...
                isequal(Image_Length_V,nextpow2(Image_Length_V))
                set(pus_extend,'Enable','off');
                strSize = ['(' int2str(Image_Length_V), 'x', ...
                               int2str(Image_Length_H) ')'];
                msg = getWavMSG('Wavelet:divGUIRF:Warn_SWTSiz',strSize);
                wwarndlg(msg,getWavMSG('Wavelet:divGUIRF:SWT_ExtMode'),'block');

            elseif Image_Length_H < Computed_Length_H || ...
                Image_Length_V < Computed_Length_V
                set(pus_extend,'Enable','on');
            end
        else
            set(pus_extend,'Enable','on');
            set(cat(1,Hdls_UIC_H{:}),'Visible','on')
            set(cat(1,Hdls_UIC_V{:}),'Visible','on')
            set(cat(1,Hdls_UIC_Swt{:}),'Visible','off')
        end
        set(cat(1,Hdls_UIC_C{4:end}),'Visible','on');
            
    case 'extend_truncate'
    %-------------------------------------------------------------------------%
    % Option: 'EXTEND_TRUNCATE' - Compute the new Extended or Truncated image %
    %-------------------------------------------------------------------------%
        
        % Begin waiting.
        %---------------
        wwaiting('msg',win_imgxtool,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Get stored structure.
        %----------------------        
        Anal_Image = wfigmngr('getValue',win_imgxtool,'Anal_Image');

        % Get UIC values.
        %----------------
        Image_length_H   = wstr2num(get(edi_length_H,'String'));
        Val_pop_direct_H = get(pop_direct_H,'Value');
        Image_length_V   = wstr2num(get(edi_length_V,'String'));
        Val_pop_direct_V = get(pop_direct_V,'Value');
        Str_pop_mode     = get(pop_mode,'String');
        last_Mode        = length(Str_pop_mode);
        Val_pop_mode     = get(pop_mode,'Value');

        % Directions mode conversion and desired lengths.
        %------------------------------------------------
        if isequal(Val_pop_mode,last_Mode)
            Dir_H = 'r';
            Dir_V = 'b';
            Desired_length_H = wstr2num(get(edi_swtclen_H,'String'));
            Desired_length_V = wstr2num(get(edi_swtclen_V,'String'));
        else
            Dir_H_Values     = ['b';'l';'r'];
            Dir_V_Values     = ['b';'u';'d'];
            Dir_H            = Dir_H_Values(Val_pop_direct_H);
            Dir_V            = Dir_V_Values(Val_pop_direct_V);
            Desired_length_H = wstr2num(get(edi_deslen_H,'String'));
            Desired_length_V = wstr2num(get(edi_deslen_V,'String'));
        end
        Desired_Size = [Desired_length_V Desired_length_H];

        % Extension mode conversion.
        %---------------------------
        Mode_Values = {'sym';'symw';'asym';'asymw';'ppd';'zpd';'sp0';'spd';'ppd'};
        Mode        = Mode_Values{Val_pop_mode};

        % Get action to do.
        %------------------
        action = get(pus_extend,'UserData');
        switch action
          case 'truncate'
              Deb_O_H = 1;
              Deb_O_V = 1;
              delta_H = Image_length_H - Desired_length_H;
              delta_V = Image_length_V - Desired_length_V;
              switch Val_pop_direct_H
                case 2 ,  Deb_N_H = 1 + delta_H;        % 'Left'
                case 3  , Deb_N_H = 1;                  % 'Right'
                case 1  , Deb_N_H = 1 + fix(delta_H/2); % 'Both'
              end
              switch Val_pop_direct_V
                case 2 , Deb_N_V = 1 + delta_V;        % 'Up'  
                case 3 , Deb_N_V = 1;                  % 'Down' 
                case 1 , Deb_N_V = 1 + fix(delta_V/2); % 'Both'
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              First_Point  = [Deb_N_V Deb_N_H ];
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              New_Image    = wkeep2(Anal_Image,Desired_Size,First_Point);
              imgxtool('draw',win_imgxtool,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

          case 'ext_trunc'
              Deb_O_V = 1;
              Deb_N_H = 1;
              delta_H = Desired_length_H - Image_length_H;
              delta_V = Image_length_V - Desired_length_V;
              switch Val_pop_direct_H
                case 2 , Deb_O_H = 1 + delta_H;       % 'Left'
                case 3 , Deb_O_H = 1;                 % 'Right'
                case 1 , Deb_O_H = 1 + fix(delta_H/2);% 'Both'  
              end
              switch Val_pop_direct_V
                case 2 , Deb_N_V = 1 + delta_V;        % 'Up'  
                case 3 , Deb_N_V = 1;                  % 'Down' 
                case 1 , Deb_N_V = 1 + fix(delta_V/2); % 'Both'
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              First_Point  = [Deb_N_V Deb_N_H ];
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              New_Image    = wkeep2(Anal_Image,Desired_Size,First_Point);
              switch Dir_H
                case {'l','r'}
                  New_Image = wextend('ac',Mode,New_Image,delta_H,Dir_H);

                case 'b'
                  Ext_Size  = ceil(delta_H/2);
                  New_Image = wextend('ac',Mode,New_Image,Ext_Size,Dir_H);
                  if rem(delta_H,2)
                      New_Image = wkeep2(New_Image,Desired_Size,'c','dr');
                  end
              end

              imgxtool('draw',win_imgxtool,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

          case 'trunc_ext'
              Deb_O_H = 1;
              Deb_N_V = 1;
              delta_H = Image_length_H - Desired_length_H;
              delta_V = Desired_length_V - Image_length_V ;
              switch Val_pop_direct_H
                case 2 ,  Deb_N_H = 1 + delta_H;        % 'Left'
                case 3  , Deb_N_H = 1;                  % 'Right'
                case 1  , Deb_N_H = 1 + fix(delta_H/2); % 'Both'
              end
              switch Val_pop_direct_V
                case 1 , Deb_O_V = 1 + fix(delta_V/2); % 'Both'                   
                case 2 , Deb_O_V = 1 + delta_V;        % 'Up'   
                case 3 , Deb_O_V = 1;                  % 'Down'
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              First_Point  = [Deb_N_V Deb_N_H ];
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              New_Image    = wkeep2(Anal_Image,Desired_Size,First_Point);
              switch Dir_V
                case {'u','d'}
                  New_Image = wextend('ar',Mode,New_Image,delta_V,Dir_V);

                case 'b'
                  Ext_Size  = ceil(delta_V/2);
                  New_Image = wextend('ar',Mode,Anal_Image,Ext_Size,Dir_V);
                  if rem(delta_V,2)
                      New_Image = wkeep2(New_Image,Desired_Size,'c','dr');
                  end
              end

              imgxtool('draw',win_imgxtool,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

          case 'extend'
              Deb_N_H = 1;
              Deb_N_V = 1;
              delta_H = Desired_length_H - Image_length_H;
              delta_V = Desired_length_V - Image_length_V ;
              switch Val_pop_direct_H
                case 1 , Deb_O_H = 1 + fix(delta_H/2); % 'Both'
                case 2 , Deb_O_H = 1 + delta_H;        % 'Left'
                case 3 , Deb_O_H = 1;                  % 'Right' 
              end
              switch Val_pop_direct_V
                case 1 , Deb_O_V = 1 + fix(delta_V/2); % 'Both'                   
                case 2 , Deb_O_V = 1 + delta_V;        % 'Up'   
                case 3 , Deb_O_V = 1;                  % 'Down'
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              switch Dir_H
                case {'l','r'}
                  New_Image = wextend('ac',Mode,Anal_Image,delta_H,Dir_H);

                case 'b'
                  Ext_Size  = ceil(delta_H/2);
                  New_Image = wextend('ac',Mode,Anal_Image,Ext_Size,Dir_H);
              end

              switch Dir_V
                case {'u','d'}
                  New_Image  = wextend('ar',Mode,New_Image,delta_V,Dir_V);

                case 'b'
                  Ext_Size  = ceil(delta_V/2);
                  New_Image = wextend('ar',Mode,New_Image,Ext_Size,Dir_V);
              end
              if rem(delta_H,2) || rem(delta_V,2)
                  New_Image = wkeep2(New_Image,Desired_Size,'c','dr');
              end

              imgxtool('draw',win_imgxtool,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

        end
		
        % Saving the new image.
        %-----------------------		
        wfigmngr('storeValue',win_imgxtool,'New_Image',New_Image);

        % End waiting.
        %-------------
        wwaiting('off',win_imgxtool);
        
    case 'draw'
    %-----------------------------------------------------%
    % Option: 'DRAW' - Plot both new and original signals %
    %-----------------------------------------------------%
						
        % Get arguments.
        %---------------
        Anal_Image = varargin{2};
        New_Image  = varargin{3};
        Image_Lims = varargin{4};
        Deb_O_H    = Image_Lims(1,1);
        Fin_O_H    = Image_Lims(1,2);
        Deb_O_V    = Image_Lims(1,3);
        Fin_O_V    = Image_Lims(1,4);
        Deb_N_H    = Image_Lims(2,1);
        Fin_N_H    = Image_Lims(2,2);
        Deb_N_V    = Image_Lims(2,3);
        Fin_N_V    = Image_Lims(2,4);
        
        % Begin waiting.
        %---------------
        wwaiting('msg',win_imgxtool,getWavMSG('Wavelet:commongui:WaitDraw'));
        
        % Get Axes Handles.
        %------------------
        Axe_Img = Hdls_Axes.Axe_Img;
        Axe_Leg = Hdls_Axes.Axe_Leg;
		
        % Clean images axes.
        %--------------------
        delete(findobj(Axe_Img,'Type','image'));
        delete(findobj(Axe_Img,'Type','line'));

        % Compute axes limits.
        %---------------------
        Xmin = min(Deb_O_H,Deb_N_H)-1;
        Xmax = max(Fin_O_H,Fin_N_H)+1;
        Ymin = min(Deb_O_V,Deb_N_V)-1;
        Ymax = max(Fin_O_V,Fin_N_V)+1;

        % Compute image ratio.
        %---------------------
        Len_X = Xmax - Xmin;
        Len_Y = Ymax - Ymin;
        
        % Compute new Axes position to respect a good ratio.
        %---------------------------------------------------
        [w,h]          = wpropimg([Len_X Len_Y],Pos_Axe_Img_Ori(3), ...
                                   Pos_Axe_Img_Ori(4));
        Pos_Axe_Img    = Pos_Axe_Img_Ori;
        Pos_Axe_Img(1) = Pos_Axe_Img(1)+abs(Pos_Axe_Img(3)-w)/2;
        Pos_Axe_Img(2) = Pos_Axe_Img(2)+abs(Pos_Axe_Img(4)-h)/2;
        Pos_Axe_Img(3) = w;
        Pos_Axe_Img(4) = h;
            
        % Update axes properties.
        %------------------------
        set(Axe_Img,                         ...
            'XTickLabelMode','manual',       ...
            'YTickLabelMode','manual',       ...
            'XTicklabel',[],'YTickLabel',[], ...
            'XTick',[],'YTick',[],           ...
            'YDir','reverse',                ...
            'Box','Off',                     ...
            'NextPlot','add',                ...
            'Position',Pos_Axe_Img,          ...
            'XLim',[Xmin,Xmax],              ...
            'YLim',[Ymin,Ymax],              ...
            'XColor','k',                    ...
            'YColor','k',                    ...
            'Visible','on'                   ...
            );
        set(get(Axe_Img,'title'),'String','');
            
        % Draw old image.
        %----------------
        image(wd2uiorui2d('d2uint',Anal_Image), ... 
            'Parent',Axe_Img,          ...
            'XData',[Deb_O_H Fin_O_H], ...
            'YData',[Deb_O_V Fin_O_V]  ...
            );

        % Draw new image.
        %----------------
        image(wd2uiorui2d('d2uint',New_Image), ...
            'Parent',Axe_Img,          ...
            'XData',[Deb_N_H Fin_N_H], ...
            'YData',[Deb_N_V Fin_N_V]  ...
            );

        % Constant coefs. for box design.
        %--------------------------------
        S1 = 4;
        S2 = 4;

        % Draw Box around old image.
        %---------------------------
        X = [Deb_O_H Fin_O_H Fin_O_H Deb_O_H Deb_O_H];
        Y = [Deb_O_V Deb_O_V Fin_O_V Fin_O_V Deb_O_V];
        line(X,Y,'Parent',Axe_Img,'Color','red','LineWidth',S1);

        % Draw Box around new image.
        %----------------------------
        X = [Deb_N_H Fin_N_H Fin_N_H Deb_N_H Deb_N_H];
        Y = [Deb_N_V Deb_N_V Fin_N_V Fin_N_V Deb_N_V];
        line(X,Y,'Parent',Axe_Img,'Color',[0.95 0.95 0],'LineWidth',S2);

        % Display Legend.
        %----------------
        set(Axe_Leg,'Visible','on');
        set(get(Axe_Leg,'Children'),'Visible','on');
				
        % Dynvtool Attachment.
        %----------------------
        dynvtool('init',win_imgxtool,[],Axe_Img,[],[1 1],'','','');

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 0;
        wfigmngr('storeValue',win_imgxtool,'File_Save_Flag',File_Save_Flag);
        				
        % Enable save menu.
        %------------------
        set([m_save,m_exp_sig],'Enable','on');

        % End waiting.
        %-------------
        wwaiting('off',win_imgxtool);
                		
    case 'save'
    %-----------------------------------------%
    % Option: 'SAVE' - Save transformed image %
    %-----------------------------------------%				

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_imgxtool, ...
                         '*.mat',getWavMSG('Wavelet:divGUIRF:Save_Image'));
        if ~ok, return; end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_imgxtool,getWavMSG('Wavelet:commongui:WaitSave'));
				
        % Restore the new image.
        %-----------------------		
        X = wfigmngr('getValue',win_imgxtool,'New_Image');

        % Setting Colormap.
        %------------------
        map = cbcolmap('get',win_imgxtool,'self_pal');
        if isempty(map)
            maxVal   = double(max(X(:)));
            nbcolors = round(max([2,min([maxVal,default_nbcolors])]));
            map = pink(nbcolors); %#ok<NASGU>
        end
	
        % Saving transformed Image.
        %--------------------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        try
          save([pathname filename],'X','map');
        catch %#ok<CTCH>
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 1;
        wfigmngr('storeValue',win_imgxtool,'File_Save_Flag',File_Save_Flag);
        				
        % Enable save menu.
        %------------------
        set([m_save,m_exp_sig],'Enable','off');
        
        % End waiting.
        %-------------
        wwaiting('off',win_imgxtool);

    case 'exp_wrks'
        wwaiting('msg',win_imgxtool,getWavMSG('Wavelet:commongui:WaitExport'));
        X = wfigmngr('getValue',win_imgxtool,'New_Image');
        wtbxexport(X,'name','sig_2D', ...
            'title',getWavMSG('Wavelet:divGUIRF:Extended_Image'));
        wwaiting('off',win_imgxtool);                
        
    case 'clear_GRAPHICS'
    %---------------------------------------------------------------------%
    % Option: 'CLEAR_GRAPHICS' - Clear graphics and redraw original image %
    %---------------------------------------------------------------------%
					
        % Get arguments.
        %---------------
        if length(varargin) > 1, Draw_flag = 0; else Draw_flag = 1; end

        % Get Axes Handles.
        %------------------
        Axe_Img = Hdls_Axes.Axe_Img;
        Axe_Leg = Hdls_Axes.Axe_Leg;

        % Set graphics part visible off and redraw original image if needed.
        %-------------------------------------------------------------------
        set(Axe_Leg,'Visible','off');
        set(get(Axe_Leg,'Children'),'Visible','off');
        
        if Draw_flag
            Anal_Image      = wfigmngr('getValue',win_imgxtool,'Anal_Image');
            Pos_Axe_Img_Bas = wfigmngr('getValue',win_imgxtool, ...
                                       'Pos_Axe_Img_Bas');
            set(findobj(Axe_Img,'Type','line'),'Visible','Off');
            [H,V] = size(Anal_Image);
            set(get(Axe_Img,'title'), ...
                'String',getWavMSG('Wavelet:commongui:OriImg'));
            set(Axe_Img,                         ...
                'XLim',[1,H],                    ...
                'YLim',[1,V],                    ...
                'Position',Pos_Axe_Img_Bas,      ...
                'Visible','on');
            set(findobj(Axe_Img,'Type','image'), ...
                'Parent',Axe_Img,                ...
                'XData',[1,H],                   ...
                'YData',[1,V],                   ...
                'CData',wd2uiorui2d('d2uint',Anal_Image), ... 
                'Visible','on'                   ...
                );
            dynvtool('init',win_imgxtool,[],Axe_Img,[],[1 1],'','','');
        else
            set(Axe_Img,'Visible','off');
            set(get(Axe_Img,'Children'),'Visible','off');
        end
				
        % Disable save menu.
        %-------------------
        set([m_save,m_exp_sig],'Enable','off');
		
        % Reset the new image.
        %---------------------		
        wfigmngr('storeValue',win_imgxtool,'New_Image',[]);
        
    case 'close'
    %---------------------------------------%
    % Option: 'CLOSE' - Close current figure%
    %---------------------------------------%

        % Retrieve File_Save_Flag.
        %-------------------------
        File_Save_Flag = wfigmngr('getValue',win_imgxtool,'File_Save_Flag');
        		
        % Retrieve images values.
        %------------------------		
        New_Image  = wfigmngr('getValue',win_imgxtool,'New_Image');
        Anal_Image = wfigmngr('getValue',win_imgxtool,'Anal_Image');
        
        % Test for saving the new image.
        %-------------------------------
        status = 0;
        if ~isempty(New_Image) && any(size(New_Image)~=size(Anal_Image)) &&...
            ~File_Save_Flag
            status = wwaitans(win_imgxtool,...
                     getWavMSG('Wavelet:divGUIRF:Save_ImgQuest'),2,'cond');
        end
        switch status
          case 1 , imgxtool('save',win_imgxtool)
          case 0 ,
        end
        varargout{1} = status;
        				
    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end

%--------------------------------------------------------------------------
function setfigNAME(fig,flagIDX)

if flagIDX
    figNAME = getWavMSG('Wavelet:divGUIRF:IMGX_Nam_Ind');
else
    figNAME = getWavMSG('Wavelet:divGUIRF:IMGX_Nam_TC');
end
set(fig,'Name',figNAME);
%---------------------------------------------------------------------------

