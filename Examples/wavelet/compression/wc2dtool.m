function varargout = wc2dtool(varargin)
% WC2DTOOL MATLAB file for wc2dtool.fig
% WC2DTOOL ****************  Tool Description for Help ****************
% Edit the above text to modify the response to help wc2dtool

% Last Modified by GUIDE v2.5 22-Jun-2009 16:55:53
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.1.6.16 $  $Date: 2013/07/05 04:29:25 $ 

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wc2dtool_OpeningFcn, ...
                   'gui_OutputFcn',  @wc2dtool_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout>0
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
% --- Executes just before wc2dtool is made visible.                      %
%*************************************************************************%
function wc2dtool_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for wc2dtool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introdruced manualy in the automatic generated code %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles);
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%

%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = wc2dtool_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>

% Get default command line output from handles structure
varargout{1} = handles.output;
%*************************************************************************%
%                END Output Function                                      %
%*************************************************************************%


%=========================================================================%
%                BEGIN Create Functions                                   %
%                ----------------------                                   %
% --- Executes during object creation, after setting all properties.      %
%=========================================================================%
%--------------------------------------------------------------------------
function EdiPop_CreateFcn(hObject,eventdata,handles) %#ok<INUSD,DEFNU>
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'DefaultUicontrolBackgroundColor'));
end
%--------------------------------------------------------------------------
function Sli_CreateFcn(hObject,eventdata,handles) %#ok<INUSD,DEFNU>
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor', ...
        get(0,'DefaultUicontrolBackgroundColor')); %#ok<UNRCH>
end
%--------------------------------------------------------------------------
%=========================================================================%
%                END Create Functions                                     %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function Pus_CloseWin_Callback(hObject, eventdata, handles)

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
if isequal(lower(ena_Save),'on')
    hFig = get(hObject,'Parent');
    status = wwaitans({hFig,getWavMSG('Wavelet:commongui:Save_Image')},...
        getWavMSG('Wavelet:commongui:SaveCI_Quest'),2,'Cancel');
    switch status
        case -1 , return;
        case  1
            wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));
            save_FUN(m_save,eventdata,handles)
            wwaiting('off',hFig);
        otherwise
    end
end
close(gcbf)
%--------------------------------------------------------------------------
function Men_Load_Callback(hObject,eventdata,handles,varargin) %#ok<DEFNU,INUSL>

% Check inputs
%-------------
optIMG = 'TST'; % 'BW';
if nargin>3 && strcmp(varargin{1},'comp')
    WTB_compFORMAT = true;
    wrks_FLAG = true; % Not Used
else
    WTB_compFORMAT = false;
    wrks_FLAG = nargin>3 && isequal(varargin{1},'wrks');
end

% Get figure handle.
%-------------------
Init_LoadImage('load',handles,{WTB_compFORMAT,wrks_FLAG,optIMG});
%--------------------------------------------------------------------------
function Pus_Decompose_Callback(hObject,eventdata,handles) %#ok<INUSL>

hFig = handles.output;
axe_IND = [...
     handles.Axe_Img_Ori_Dec , handles.Axe_Img_Ori_Dec_His , ...
     handles.Axe_Img_Cmp_Dec, ...
     handles.Axe_Img_Ori_His , handles.Axe_Img_Cmp_Dec_His];

axe_CMD = [handles.Axe_Img_Ori,handles.Axe_Img_Cmp];
axe_ACT = [];

% Decomposition.
%---------------
[wname,level] = cbanapar('get',hFig,'wav','lev');
X = get_Original_Image(handles);

% % Check Image size.
% %------------------
% sX = size(X);
% tstSIZE = sX(1:2)/2^level;
% if tstSIZE~=fix(tstSIZE)
%     msg = strvcat(...
%         ['The level of decomposition ' int2str(level)],...
%         'and the size of the image ',...
%         'are not compatible.',...
%         ' ', ...
%         '2^Level has to divide the size of the image.' ...
%         );  %#ok<VCAT>
%     errargt(mfilename,msg,'msg');
%     return
% end

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
CleanTOOL(hFig,eventdata,handles,'Pus_Decompose_Callback','beg');

% Get compression tool parameters.
%---------------------------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');

% Color Conversion of image.
%---------------------------
ColType = get_Color_Type(handles);
[X,ColMAT] = wimgcolconv(ColType,X);
tool_PARAMS.ColType = ColType;
tool_PARAMS.ColMAT = ColMAT;

% Wavelet Transform Decomposition.
%---------------------------------
WT_Settings = struct(...
    'typeWT','dwt','wname',wname,...
    'extMode','per','shift',[0,0]);
tree_Ori = wdectree(X,2,level,WT_Settings);

% Store Decompositions Parameters.
%--------------------------------
tool_PARAMS.DecIMG_Ori = tree_Ori;
dwt_ATTRB = struct('type','dwt','wname',wname,'level',level);
tool_PARAMS.dwt_ATTRB = dwt_ATTRB;
sizeMAT = tool_PARAMS.imgInfos.size;
if length(sizeMAT)<3 , nbPlan = 1; else  nbPlan = sizeMAT(3); end

% Show Decompositions.
%---------------------
DecIMG_Ori = wd2uiorui2d('d2uint',getdec(tree_Ori));
currentAxes = handles.Axe_Img_Ori_Dec;
imagesc(DecIMG_Ori,'Parent',currentAxes);
wguiutils('setAxesTitle',currentAxes, ...
    getWavMSG('Wavelet:divGUIRF:Original_Dec'));

% Get Wavelet Decomposition.
%---------------------------
C = read(tree_Ori,'data');
[CSORT,Idx] = sort(abs(C(:))); %#ok<ASGLU>
tool_PARAMS.('Idx_of_Sorted_Cfs') = Idx;
clear CSORT Idx

% Store compression tool parameters.
%----------------------------------
wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);

% Normalized Histogram of Wavelet Coefficients.
%----------------------------------------------
showHIST(C,handles.Axe_Img_Ori_Dec_His, ...
        'b',0.8,1,{getWavMSG('Wavelet:divGUIRF:WTC_Wav_Cfs'), ...
                   getWavMSG('Wavelet:divGUIRF:WTC_Nor_Hist_Trunc')});

% Set GUI Parameters.
%--------------------
nb_Cfs = length(C);
set(handles.Edi_Nb_Cfs,'String',int2str(nb_Cfs),'UserData',nb_Cfs);
MethodCOMP = get(handles.Pus_Compress,'UserData');
switch MethodCOMP
    case {'gbl_mmc_h','gbl_mmc_f'}
        nbClasses_INI = 75;
        Per_Cfs_INI   = 3;        
        [~,nb_Kept_Cfs,Per_Kept_Cfs,bpp,comprat,threshold] = ...
            getcompresspar(MethodCOMP,nb_Cfs,nbPlan,'percfs',Per_Cfs_INI,C);
        set(handles.Edi_Thr,...
            'String',num2str(threshold),'UserData',threshold);
        set(handles.Edi_Nb_Kept_Cfs,...
            'String',int2str(nb_Kept_Cfs),'UserData',nb_Kept_Cfs);
        set(handles.Edi_Per_Kept_Cfs,...
            'String', sprintf('%2.2f',Per_Kept_Cfs),'UserData',Per_Cfs_INI);        
        set(handles.Edi_Nb_Symb,...
            'String',num2str(nbClasses_INI),'UserData',nbClasses_INI);
        set(handles.Edi_BPP,...
            'String', sprintf('%2.3f',bpp),'UserData',bpp);
        set(handles.Edi_CompRat,...
            'String', sprintf('%2.2f',comprat),'UserData',comprat);        
        
    case {'lvl_mmc'}
        Per_Cfs_INI = 3;
        [~,nb_Kept_Cfs,Per_Kept_Cfs,bpp,comprat] = ...
            getcompresspar(MethodCOMP,nb_Cfs,nbPlan,'percfs',Per_Cfs_INI,C);
        set(handles.Edi_Nb_Kept_Cfs,...
            'String',int2str(nb_Kept_Cfs),'UserData',nb_Kept_Cfs);
        set(handles.Edi_Per_Kept_Cfs,...
            'String', sprintf('%2.2f',Per_Kept_Cfs),'UserData',Per_Kept_Cfs);        
        set(handles.Edi_BPP,...
            'String', sprintf('%2.3f',bpp),'UserData',bpp);
        set(handles.Edi_CompRat,...
            'String', sprintf('%2.2f',comprat),'UserData',comprat);        
        
    case {'ezw','spiht','spiht_3d','stw','wdr','aswdr'}
        maxCFS = max(abs(C(:)));
        level_MAX_Floor = fix(log(maxCFS)/log(2));
        % sizeINI = read(tool_PARAMS.DecIMG_Ori,'sizes',0);
        % nbDefaultLOOP = max(log2(sizeINI))+2;
        % set(handles.Pop_Nb_LOOP,'Value',min([level_MAX_Floor,nbDefaultLOOP]))   
        oldValue = get(handles.Pop_Nb_LOOP,'Value');   
        if oldValue>level_MAX_Floor
            set(handles.Pop_Nb_LOOP,'Value',level_MAX_Floor)
        end
        Comp_Results_Callback(handles.Pop_Nb_LOOP,eventdata,handles,'loop')
end

% Attach DYNVTOOL.
%-----------------
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','real');

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Pus_Decompose_Callback','end');
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pop_METHOD_Callback(hObject,eventdata,handles) 

hFig = handles.output;
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
flagDEC = tool_PARAMS.flagDEC;

% Handles.
%---------
Fra_GBL_Par  = handles.Fra_GBL_Par;
Edi_BPP      = handles.Edi_BPP;
Txt_BPP      = handles.Txt_BPP;
Edi_CompRat  = handles.Edi_CompRat;
Txt_CompRat  = handles.Txt_CompRat;
Txt_PER_CompRat = handles.Txt_PER_CompRat;
Edi_Thr      = handles.Edi_Thr;
Txt_Thr      = handles.Txt_Thr;
Edi_Nb_Kept_Cfs = handles.Edi_Nb_Kept_Cfs;
Edi_Per_Kept_Cfs = handles.Edi_Per_Kept_Cfs;
Txt_Kept_Cfs = handles.Txt_Kept_Cfs;
Txt_EQUI     = handles.Txt_EQUI;
Txt_PER      = handles.Txt_PER;
Txt_Nb_Symb  = handles.Txt_Nb_Symb;
Edi_Nb_Symb  = handles.Edi_Nb_Symb;
Txt_Nb_LOOP  = handles.Txt_Nb_LOOP;
Pop_Nb_LOOP  = handles.Pop_Nb_LOOP;
Tog_Inspect  = handles.Tog_Inspect;
Pus_Compress = handles.Pus_Compress;
Chk_ALG_STP  = handles.Chk_ALG_STP;
%------------------------------------
Txt_psnr     = handles.Txt_psnr;
Txt_mse      = handles.Txt_mse;
Txt_maxerr   = handles.Txt_maxerr;
Txt_Bit_Pix  = handles.Txt_Bit_Pix;
Txt_Fil_Rat  = handles.Txt_Fil_Rat;
Txt_L2_Rat   = handles.Txt_L2_Rat;
Edi_psnr     = handles.Edi_psnr;
Edi_mse      = handles.Edi_mse;
Edi_maxerr   = handles.Edi_maxerr;
Edi_Bit_Pix  = handles.Edi_Bit_Pix;
Edi_Fil_Rat  = handles.Edi_Fil_Rat;
Edi_L2_Rat   = handles.Edi_L2_Rat;
%------------------------------------
hdls_SET_1  = [Txt_Nb_Symb,Edi_Nb_Symb];
hdls_SET_2_P1 = [Txt_psnr,Txt_mse,Txt_maxerr];
hdls_SET_2_P2 = [Txt_BPP,Edi_BPP,Txt_CompRat,Edi_CompRat,Txt_PER_CompRat];
hdls_SET_3  = [Txt_Thr,Edi_Thr,Fra_GBL_Par];
hdls_SET_4  = [Txt_Nb_LOOP,Pop_Nb_LOOP,Chk_ALG_STP];

hdls_SET_5  = [...
    Txt_Kept_Cfs,Edi_Nb_Kept_Cfs,Txt_EQUI,Edi_Per_Kept_Cfs,Txt_PER ...    
    ];
hdls_SET_6 = ...
    [handles.Chk_StepOnOff,handles.Pus_NEXT_STP,handles.Pus_END_STP];
hdl_Edi_PERF = [...
    Edi_psnr , Edi_mse , Edi_maxerr , ...
    Edi_Bit_Pix , Edi_Fil_Rat, Edi_L2_Rat ...
    ];
hdl_Txt_PERF = [...
    Txt_psnr , Txt_mse , Txt_maxerr , ...
    Txt_Bit_Pix , Txt_Fil_Rat , Txt_L2_Rat ...
    ];
%------------------------------------------------------
numCode  = get(hObject,'Value');
tabCode  = get(hObject,'String');
MethodCOMP = lower(tabCode{numCode});
old_METHOD = get(Pus_Compress,'UserData');
old_FAM = wtcmngr('meth_fam',3,old_METHOD);
new_FAM = wtcmngr('meth_fam',3,MethodCOMP);
if ~isempty(old_FAM) && ~isequal(old_FAM,new_FAM)
    sX = read(tool_PARAMS.DecIMG_Ori,'sizes',0);
    level_MAX = wmaxlev(sX,'haar');
    switch lower(new_FAM)
        case 'pscm' , level_DEF =level_MAX;
        case 'ctm'  , level_DEF = round(level_MAX/2);
    end
    cur_LEV = cbanapar('get',hFig,'lev');
    if ~isequal(cur_LEV,level_DEF)
        cbanapar('set',hFig,'lev',level_DEF);
        Pus_Decompose_Callback(hObject,eventdata,handles);
    end
end
set(Pus_Compress,'UserData',MethodCOMP);
%------------------------------------------------------
if flagDEC ,ena_Compress = 'On'; else ena_Compress = 'Off'; end

switch MethodCOMP
    case {'gbl_mmc_h','gbl_mmc_f'} 
        visSet_1  = 'On'; visSet_3  = 'On'; visSet_4  = 'Off';
        visSet_5  = 'On'; visSet_6  = 'Off';
        
    case 'lvl_mmc' 
        visSet_1  = 'Off'; visSet_3  = 'Off'; visSet_4  = 'Off';
        visSet_5  = 'Off'; visSet_6  = 'Off';
            
    case {'ezw','spiht','spiht_3d','stw','wdr','aswdr'}
        visSet_1 = 'Off'; visSet_3 = 'Off'; visSet_4 = 'On';
        visSet_5 = 'Off';
        val_STEP = get(Chk_ALG_STP,'Value');
        if isequal(val_STEP,1) , visSet_6  = 'On'; else visSet_6  = 'Off'; end 
        sizeINI = read(tool_PARAMS.DecIMG_Ori,'sizes',0);
        nbDefaultLOOP = round(max(log2(sizeINI)))+2;
        set(Pop_Nb_LOOP,'Value',nbDefaultLOOP);
end

% Clean Axes.
%------------
axesToClean = [...
    handles.Axe_Img_Cmp,handles.Axe_Img_Cmp_Dec_His, ...
    handles.Axe_Img_Cmp_Dec  ...
    ];
try 
    Child_1 = get(axesToClean(1),'Children');
    Child_2 = allchild(axesToClean(2:3));
    toDel = [Child_1 ; cat(1,Child_2{:})];
    delete(toDel);
catch ME    %#ok<NASGU>
end

% Set uicontrols visibility.
%--------------------------
set(hdls_SET_1,'Visible',visSet_1);
set([hdls_SET_2_P1,hdls_SET_2_P2],'Visible','Off');
set(hdls_SET_3,'Visible',visSet_3);
set(hdls_SET_4,'Visible',visSet_4);
set(hdls_SET_5,'Visible',visSet_5);
set(hdls_SET_6,'Visible',visSet_6);

% Set Decompositions Parameters.
%--------------------------------
switch MethodCOMP
    case {'gbl_mmc_h','gbl_mmc_f'}
        default_PER = 3;
        nbClasses_INI = 75;
        set(Edi_Nb_Symb,'String',int2str(nbClasses_INI));
        Comp_Results_Callback(Edi_Per_Kept_Cfs,eventdata,handles,...
            'percfs',default_PER);
        set([Txt_Nb_Symb,Edi_Nb_Symb],'Enable','On');
        set(hdls_SET_2_P2,'Visible','On');
    
    case 'lvl_mmc'
        default_BPP = 0.1;
        Comp_Results_Callback(Edi_BPP,eventdata,handles,'bpp',default_BPP);       
        set(hdls_SET_2_P2,'Visible','On');

    case {'ezw','spiht','spiht_3d','stw','wdr','aswdr'}
        set(hdls_SET_4,'Enable','On');
        set(hdls_SET_2_P2,'Visible','Off');
        set([handles.Pus_NEXT_STP,handles.Pus_END_STP],'Enable','Off');        
        sizeINI = read(tool_PARAMS.DecIMG_Ori,'sizes',0);
        nbDefaultLOOP = round(max(log2(sizeINI)))+2;
        set(Pop_Nb_LOOP,'Value',nbDefaultLOOP);        
end
set(hdls_SET_2_P1,'Visible','On');
set([hdl_Txt_PERF,hdl_Edi_PERF,Tog_Inspect],'Enable','Off');
set(hdl_Edi_PERF,'String','');
set(Pus_Compress,'Enable',ena_Compress);

hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
m_save = hdl_Menus.m_save;
m_exp_sig = hdl_Menus.m_exp_sig;
m_SAV_EXP = [m_save m_exp_sig];
set(m_SAV_EXP,'Enable','Off')
%--------------------------------------------------------------------------
function Tog_Inspect_Callback(hObject,eventdata,handles) %#ok<DEFNU>

hFig = handles.output;
Val_Inspect = get(hObject,'Value');

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
CleanTOOL(hFig,eventdata,handles,'Tog_Inspect_Callback','beg',Val_Inspect);

axe_INI = ...
    [ handles.Axe_Img_Ori_Dec , handles.Axe_Img_Ori_Dec_His   , ...
      handles.Axe_Img_Cmp_Dec , handles.Axe_Img_Cmp_Dec_His , ...
      handles.Axe_Img_Ori  , handles.Axe_Img_Ori_His ,  ...
      handles.Axe_Img_Cmp , ...
      ];
child = allchild(axe_INI);
child = cat(1,child{:})';
child_INI = findobj(child)';
axe_TREE = [...
        handles.Axe_Tree_Dec , ...
        handles.Axe_Tree_ImgOri  , handles.Axe_Tree_ImgRes ,  ...
        handles.Axe_Tree_ImgCmp ...
    ];
child = allchild(axe_TREE);
child_DEC = cat(1,child{:})';
child_DEC = findobj(child_DEC)';

switch Val_Inspect
    case 0 ,
        set([axe_TREE , child_DEC],'Visible','Off');
        delete(child_DEC);
        set([axe_INI  , child_INI],'Visible','On');
        axe_IND = [...
            handles.Axe_Img_Ori_Dec , handles.Axe_Img_Ori_Dec_His , ...
            handles.Axe_Img_Cmp_Dec, ...
            handles.Axe_Img_Ori_His , handles.Axe_Img_Cmp_Dec_His];

        axe_CMD = [handles.Axe_Img_Ori,handles.Axe_Img_Cmp];
        
        axe_ACT = [];        
        dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','real');
        set(hObject,'String',getWavMSG('Wavelet:divGUIRF:Tog_Inspect'));
       
    case 1 ,
        dynvtool('ini_his',hFig,-1);
        set([axe_INI  , child_INI],'Visible','Off');        
        set([axe_TREE , child_DEC],'Visible','On');
        Tree_MANAGER('create',hFig,eventdata,handles);
        set(hObject,'String',getWavMSG('Wavelet:divGUIRF:ReturnTog_Inspect'));
end

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Tog_Inspect_Callback','end',Val_Inspect);
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pop_Nod_Lab_Callback(hObject,eventdata,handles) %#ok<DEFNU>

hFig = handles.output;
lab_Value  = get(hObject,'Value');
switch lab_Value
    case 1 , NodeLabType = 'Index';
    case 2 , NodeLabType = 'Depth_Pos';
    case 3 , NodeLabType = 'Size';
    case 4 , NodeLabType = 'Type';
    case 5 , NodeLabType = 'per. n2_ori';
    case 6 , NodeLabType = 'per. n2_comp';
    case 7 , NodeLabType = 'per. n2_res';
end
node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
if isequal(NodeLabType,node_PARAMS.nodeLab) , return; end
node_PARAMS.nodeLab = NodeLabType;
wtbxappdata('set',hFig,'node_PARAMS',node_PARAMS);
Tree_MANAGER('setNodeLab',hFig,eventdata,handles,lab_Value)
%--------------------------------------------------------------------------
function Pop_Nod_Act_Callback(hObject,eventdata, handles) %#ok<DEFNU>

hFig = handles.output;
act_Value = get(hObject,'Value');
switch act_Value
    case 1 , NodeActType = 'Visualize';
    case 2 , NodeActType = 'Reconstruct';
end
node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
if isequal(NodeActType,node_PARAMS.nodeAct) , return; end
node_PARAMS.nodeAct = NodeActType;
wtbxappdata('set',hFig,'node_PARAMS',node_PARAMS);
Tree_MANAGER('setNodeAct',hFig,eventdata,handles,act_Value)
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                    TREE MANAGEMENT and CALLBACK FUNCTIONS               %
%-------------------------------------------------------------------------%
function Tree_MANAGER(option,hFig,eventdata,handles,varargin)

% Miscellaneaous Values.
%-----------------------
line_color = [0 0 0];
actColor   = 'b';
inactColor = 'r';

% MemBloc of stored values.
%--------------------------
n_stored_val = 'NTREE_Plot';
ind_tree     = 1;
% ind_Class    = 2;
ind_hdls_txt = 3;
ind_hdls_lin = 4;
ind_menu_NodeLab =  5;
ind_type_NodeLab =  6;
% ind_menu_NodeAct =  7;
ind_type_NodeAct =  8;
% ind_menu_TreeAct =  9;
% ind_type_TreeAct = 10;
% nb1_stored = 10;

% Handles.
%---------
tool_hdl_AXES = wtbxappdata('get',hFig,'tool_hdl_AXES');
axe_TREE = tool_hdl_AXES.axe_TREE;
Axe_Tree_Dec  = axe_TREE(1);
% Axe_Tree_ImgOri = axe_TREE(2);
% Axe_Tree_ImgRes = axe_TREE(3);
% Axe_Tree_ImgCmp = axe_TREE(4);

% tool_PARAMS.
%-------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tree_Ori = tool_PARAMS.DecIMG_Ori;

% Find Compressed_Image.
%----------------------
h_img_COMP = findobj(hFig,'Type','image','Tag','Compressed_Image');
Xcomp = get(h_img_COMP,'CData');
[wname,level] = cbanapar('get',hFig,'wav','lev');

% Wavelet Transform Decomposition.
%---------------------------------
h_img_ORI = findobj(hFig,'Type','image','Tag','Original_Image');
X = get(h_img_ORI,'CData');
WT_Settings = struct(...
    'typeWT','dwt','wname',wname,...
    'extMode','per','shift',[0,0]);
tree_Comp = wdectree(Xcomp,2,level,WT_Settings);
tool_PARAMS.DecIMG_Comp = tree_Comp;
tree_Res = wdectree(abs(double(Xcomp)-double(X)),2,level,WT_Settings);
tool_PARAMS.DecIMG_Res = tree_Res;
wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);

switch option
    case 'create'
        % node_PARAMS.
        %-------------
        node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
        type_NodeLab = node_PARAMS.nodeLab;
        Tree_Colors = struct(...
            'line_color',line_color, ...
            'actColor',actColor,     ...
            'inactColor',inactColor);  
        wtbxappdata('set',hFig,'Tree_Colors',Tree_Colors);
        set(Axe_Tree_Dec,'DefaultTextFontSize',8)
        
        [order,depth] = get(tree_Ori,'order','depth');
        allN  = allnodes(tree_Ori);
        NBnod = (order^(depth+1)-1)/(order-1);
        table_node = -ones(1,NBnod);
        table_node(allN+1) = allN;
        [xnpos,ynpos] = xynodpos(table_node,order,depth);
        
        hdls_lin = zeros(1,NBnod);
        hdls_txt = zeros(1,NBnod);
        i_fath  = 1;
        i_child = i_fath + (1:order);
        dxPOS = 0.1;
        xnpos = xnpos + dxPOS;
        dX = (xnpos(i_child(4))-xnpos(i_child(1)))/4;
        
        for d=1:depth
            ynT = ynpos(d,:);
            ynL = ynT + [0.01 -0.01];
            i_ch1 = i_child(1);
            for p=0:order^(d-1)-1
                if table_node(i_child(1)) ~= -1
                    for k=1:order
                        ic = i_child(k);
                        xLplus = xnpos([i_fath,i_fath,i_ch1,i_ch1]) + ...
                            (k-1)*[0 0 dX dX];
                        yLM  = 0.5*(ynL(1)+ynL(2));
                        yLplus = [ynL(1) yLM yLM ynL(2)];
                        hdls_lin(ic) = line(...
                            'Parent',Axe_Tree_Dec, ...
                            'XData',xLplus,...
                            'YData',yLplus,...
                            'Color',line_color);
                    end
                end
                i_child = i_child+order;
                i_fath  = i_fath+1;
            end
        end
        labels = tlabels(tree_Ori,'i'); % Indices
        textProp = {...
                'Parent',Axe_Tree_Dec,          ...
                'FontWeight','bold',            ...
                'Color',actColor,               ...
                'HorizontalAlignment','center', ...
                'VerticalAlignment','middle',   ...
                'Clipping','on'                 ...
            };    
        
        i_node = 1;   
        hdls_txt(i_node) = ...
            text(textProp{:},...
            'String', labels(i_node,:),   ...
            'Position',[0+dxPOS 0.1 0],         ...
            'UserData',table_node(i_node) ...
            );
        i_node = i_node+1;
        i_fath  = 1;
        i_child = i_fath+(1:order);
        for d=1:depth
            for p=0:order:order^d-1
                if table_node(i_child(1)) ~= -1
                    for k=1:order
                        ic = i_child(k);
                        posX = xnpos(i_child(1))+(k-1)*dX;
                        hdls_txt(ic) = text(...
                            textProp{:},...
                            'String',labels(i_node,:), ...
                            'Position',[posX ynpos(d,2) 0],...
                            'UserData',table_node(ic)...
                            );
                        i_node = i_node+1;
                    end
                end
                i_child = i_child+order;
            end
        end
        nodeAction = ...
            [mfilename '(''nodeAction_CallBack'',gco,[],' num2mstr(hFig) ');'];
        set(hdls_txt(hdls_txt~=0),'ButtonDownFcn',nodeAction);
        [nul,notAct] = findactn(tree_Ori,allN,'na'); %#ok<ASGLU>
        set(hdls_txt(notAct+1),'Color',inactColor);
        %----------------------------------------------
        m_lab = [];
        wmemtool('wmb',hFig,n_stored_val, ...
            ind_tree,tree_Ori,      ...
            ind_hdls_txt,hdls_txt, ...
            ind_hdls_lin,hdls_lin, ...
            ind_menu_NodeLab,m_lab, ...
            ind_type_NodeLab,'Index', ...
            ind_type_NodeAct,'' ...
            );        
        %----------------------------------------------
        switch lower(type_NodeLab)
            case 'index' ,
            case {'depth_pos' ,'size','type'}
                Tree_MANAGER('setNodeLab',hFig,eventdata,handles);
            case {'per. n2_ori','per. n2_comp','per. n2_res'}
                Tree_MANAGER('setNodeLab',hFig,eventdata,handles);
            otherwise
                plot(tree_Ori,'setNodeLabel',hFig,lower(type_NodeLab));
        end        
        %----------------------------------------------
        wguiutils('setAxesTitle',Axe_Tree_Dec, ...
            getWavMSG('Wavelet:divGUIRF:Wav_Dec_Tree'));
        show_Node_IMAGES(hFig,'Visualize',0)
        
    case 'setNodeLab'
        if length(varargin)>1
            labValue = varargin{1};
        else
            handles = guihandles(hFig);
            labValue = get(handles.Pop_Nod_Lab,'Value');
        end
        switch labValue
            case 1 , labels = tlabels(tree_Ori,'i');
            case 2 , labels = tlabels(tree_Ori,'dp');
            case 3 , labels = tlabels(tree_Ori,'s');
            case 4 , labels = tlabels(tree_Ori,'t');
            case 5 , labels = getNormLab(tree_Ori,2);
            case 6 , labels = getNormLab(tree_Comp,2);
            case 7 , labels = getNormLab(tree_Res,2);
        end
        hdls_txt = wmemtool('rmb',hFig,n_stored_val,ind_hdls_txt);
        hdls_txt = hdls_txt(hdls_txt~=0);
        for k=1:length(hdls_txt), set(hdls_txt(k),'String',labels(k,:)); end

    case 'setNodeAct'
        nodeAction = ...
            [mfilename '(''nodeAction_CallBack'',gco,[],' num2mstr(hFig) ');'];
        hdls_txt = wmemtool('rmb',hFig,n_stored_val,ind_hdls_txt);
        set(hdls_txt(hdls_txt~=0),'ButtonDownFcn',nodeAction);        
end
%-------------------------------------------------------------------------%
function nodeAction_CallBack(hObject,eventdata,hFig) %#ok<INUSL,DEFNU>

node = plot(ntree,'getNode',hFig);
if isempty(node) , return; end
node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
nodeAct = node_PARAMS.nodeAct;
if isequal(nodeAct,'Split_Merge') || isequal(nodeAct,'Split / Merge')
    tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
    tree_Ori = tool_PARAMS.DecIMG_Ori;
    tnrank = findactn(tree_Ori,node);
    if isnan(tnrank) , return;  end
    plot(tree_Ori,'Split-Merge',hFig);
    tree_Comp = tool_PARAMS.DecIMG_Comp;
    tree_Res = tool_PARAMS.DecIMG_Res;
    if tnrank>0
        tree_Ori  = nodesplt(tree_Ori,node);
        tree_Comp = nodesplt(tree_Comp,node);
        tree_Res  = nodesplt(tree_Res,node);
    else
        tree_Ori  = nodejoin(tree_Ori,node);
        tree_Comp = nodejoin(tree_Comp,node);
        tree_Res  = nodejoin(tree_Res,node);
    end
    tool_PARAMS.DecIMG_Ori = tree_Ori;
    tool_PARAMS.DecIMG_Res = tree_Res;
    tool_PARAMS.DecIMG_Comp = tree_Comp;
    wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);
    Tree_MANAGER('setNodeLab',hFig,eventdata,guihandles(hFig))
else
    show_Node_IMAGES(hFig,nodeAct,node);
end
%-------------------------------------------------------------------------%
function show_Node_IMAGES(hFig,nodeAct,node)

tool_hdl_AXES = wtbxappdata('get',hFig,'tool_hdl_AXES');
axe_TREE = tool_hdl_AXES.axe_TREE;
Axe_Tree_0ri = axe_TREE(2);
Axe_Tree_Res = axe_TREE(3);
Axe_Tree_Cmp = axe_TREE(4);
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tree_Ori = tool_PARAMS.DecIMG_Ori;
tree_Res = tool_PARAMS.DecIMG_Res;
tree_Cmp = tool_PARAMS.DecIMG_Comp;
ColType  = tool_PARAMS.ColType;
ColMAT   = tool_PARAMS.ColMAT;
mousefrm(hFig,'watch')
NBC = cbcolmap('get',hFig,'nbColors');
flag_INVERSE = false;
showPARAMS = {nodeAct,node,NBC,flag_INVERSE};
show_One_IMAGE(showPARAMS,tree_Ori,Axe_Tree_0ri, ...
    getWavMSG('Wavelet:divGUIRF:Original_image'),ColType,ColMAT);
show_One_IMAGE(showPARAMS,tree_Res,Axe_Tree_Res, ...
    getWavMSG('Wavelet:divGUIRF:Residual_image'));
show_One_IMAGE(showPARAMS,tree_Cmp,Axe_Tree_Cmp, ...
    getWavMSG('Wavelet:divGUIRF:Compressed_image'));

lind = tlabels(tree_Ori,'i',node);
ldep = tlabels(tree_Ori,'p',node);
if ~isequal(nodeAct,'Reconstruct')
    axeTitle = getWavMSG('Wavelet:divGUIRF:Cfs_Node',lind,ldep);
else
    axeTitle = getWavMSG('Wavelet:divGUIRF:Rec_Cfs_Node',lind,ldep);
end

wguiutils('setAxesTitle',Axe_Tree_Cmp,axeTitle);
mousefrm(hFig,'arrow')
dynvtool('init',hFig,axe_TREE(1),axe_TREE(2:4),[],[1 1],'','','','real');
%-------------------------------------------------------------------------%
function show_One_IMAGE(showPARAMS,treeOBJ,axe,xlab,ColType,ColMAT)

[nodeAct,node,NBC,flag_INVERSE] = deal(showPARAMS{:});
switch nodeAct
    case 'Visualize' , [nul,X] = nodejoin(treeOBJ,node); %#ok<ASGLU>
    case 'Reconstruct' , X = rnodcoef(treeOBJ,node);
end
if node>0
    if nargin<5
        X = wcodemat(X,NBC,'mat',1);
    else
        X = wcodemat(X,NBC,'mat',1); % Must be changed if Color Conversion
    end
    if flag_INVERSE && rem(node,4)~=1 , X = max(X(:))-X; end
end

if nargin>4 , X = wimgcolconv(['inv' ColType],X,ColMAT); end
image(wd2uiorui2d('d2uint',X),'Parent',axe);
wguiutils('setAxesXlabel',axe,xlab);
%-------------------------------------------------------------------------%
function labs = getNormLab(t,p)

% p = Inf;
[t_TMP,X] = nodejoin(t,0);
levMAX = treedpth(t);
if ~isequal(p,Inf)
    V = 1;
else
    V = norm(X(:),p);
end
n_ORI = V;
for k = 1:levMAX
    n2dec = [k-1,0];
    t_TMP = nodesplt(t_TMP,[k-1,0]);
    child = nodedesc(t_TMP,n2dec);
    cfs = read(t_TMP,'data',child(2:end));
    nbcfs = length(cfs);
    tmp = zeros(nbcfs,1);
    for j = 1:nbcfs
        tmp(j,1) = norm(cfs{j}(:),p);
    end
    s = sum(tmp);
    V = [V ; tmp/s]; %#ok<AGROW>
    lenV = length(V);
    if lenV<8 || isequal(p,Inf)
        appMul = 1;
    else
        appMul = V(lenV-7);
    end
    V(end-3:end) = appMul*V(end-3:end);
end
V = 100*V/n_ORI;
labs = num2str(V,'%5.2f');
%==========================================================================


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%
function demo_FUN(hObject,eventdata,handles,colorFLAG,numDEM) %#ok<DEFNU,INUSL>

Rad_Show_VAL = 0;
if ~colorFLAG , optIMG = 'BW'; else optIMG = 'COL'; end

switch optIMG
    case 'BW' ,
    case 'COL', numDEM = numDEM + 100;
end

switch numDEM
    case {1,2,3,4,5,6,7,8}
        filename = 'mask'; wname = 'haar'; Rad_Show_VAL = 0;
        if numDEM==1 || numDEM==2 || numDEM==3
            level = 4;
        else
            level = 8;
        end
        switch numDEM
            case 1 , MethodCOMP = 'gbl_mmc_f' ; nbKept_Cfs = 1500;
            case 2 , MethodCOMP = 'gbl_mmc_h' ; nbKept_Cfs = 1500;
            case 3 , MethodCOMP = 'lvl_mmc';    nbKept_Cfs = 1500;
            case 4 , MethodCOMP = 'ezw';   nbPass = 10;
            case 5 , MethodCOMP = 'spiht'; nbPass = 10;
            case 6 , MethodCOMP = 'stw';   nbPass = 10;
            case 7 , MethodCOMP = 'wdr';   nbPass = 10;
            case 8 , MethodCOMP = 'aswdr'; nbPass = 10;
        end
    %-------------------------------------------------------------        
    case 9
        filename = 'mask';    wname = 'bior4.4' ; level = 8;
        MethodCOMP = 'spiht'; nbPass = 11; Rad_Show_VAL = 0;        
        
    case 10
        filename = 'mask';  wname = 'haar' ; level = 8;
        MethodCOMP = 'stw'; nbPass = 11; Rad_Show_VAL = 0;
          
    case 11
        filename = 'laure';       wname = 'bior4.4' ; level = 4;
        MethodCOMP = 'gbl_mmc_h'; nbKept_Cfs = 1500;
        
    case 12
        filename = 'catherine';   wname = 'bior4.4' ; level = 4;
        MethodCOMP = 'gbl_mmc_h'; nbKept_Cfs = 1500;
        
    case 13
        filename = 'catherine'; wname = 'bior4.4' ; level = 8;
        MethodCOMP = 'aswdr';   nbPass = 10;
        
    case 14
        filename = 'crtcol';      wname = 'bior4.4' ; level = 5;
        MethodCOMP = 'gbl_mmc_h'; nbKept_Cfs = 5000;
        
    case 15
        filename = 'crtcol';   wname = 'bior4.4' ; level = 9;
        MethodCOMP = 'stw'; nbPass = 12;      
    %-------------------------------------------------------------
    case 16
        filename = 'woman2'; wname = 'haar' ;  level = 7;
        MethodCOMP = 'ezw'; nbPass = 9;
    case 17
        filename = 'bust'; wname = 'bior4.4' ; level = 8;
        MethodCOMP = 'ezw';  nbPass = 10;
    case 18
        filename = 'facets'; wname = 'haar' ; level = 8;
        MethodCOMP = 'ezw'; nbPass = 10;
    %---------------------------------------------------------- 
    case 19
        filename = 'finger'; wname = 'bior4.4' ; level = 8;
        MethodCOMP = 'spiht'; nbPass = 10;
    
    case 20
        filename = 'porche';  wname = 'bior4.4' ; level = 9;
        MethodCOMP = 'spiht'; nbPass = 11;
    case 21
        filename = 'sculpture'; wname = 'haar' ; level = 9;
        MethodCOMP = 'spiht'; nbPass = 11;
    case 22
        filename = 'woodsculp256.jpg'; wname = 'bior4.4' ; level = 8;
        MethodCOMP = 'spiht'; nbPass = 11;
    %----------------------------------------------------------
    case 23
        filename = 'arms.jpg'; wname = 'bior4.4' ; level = 4;
        MethodCOMP = 'gbl_mmc_f'; nbKept_Cfs = 4000;
    case 24
        filename = 'arms.jpg'; wname = 'bior4.4' ; level = 4;
        MethodCOMP = 'gbl_mmc_h'; nbKept_Cfs = 4000;
    case 25
        filename = 'arms.jpg'; wname = 'bior4.4' ; level = 8;
        MethodCOMP = 'ezw'; nbPass = 11;
        Rad_Show_VAL = 0;
    case 26
        filename = 'arms.jpg'; wname = 'bior4.4' ; level = 8;
        MethodCOMP = 'spiht'; nbPass = 11;
        Rad_Show_VAL = 0;
    case 27
        filename = 'jellyfish256'; wname = 'bior4.4' ; level = 8;
        MethodCOMP = 'ezw'; nbPass = 11;
        Rad_Show_VAL = 0;
        
    case {101,102,103,104,105,106,107,108}
        numDEM = numDEM-100;
        filename = 'woodstatue.jpg'; wname = 'bior4.4'; Rad_Show_VAL = 0;
        if numDEM==1 || numDEM==2 || numDEM==3
            level = 4;
        else
            level = 8;
        end
        switch numDEM
            case 1 , MethodCOMP = 'gbl_mmc_f' ; nbKept_Cfs = 4500;
            case 2 , MethodCOMP = 'gbl_mmc_h' ; nbKept_Cfs = 4500;
            case 3 , MethodCOMP = 'lvl_mmc';    nbKept_Cfs = 4500;
            case 4 , MethodCOMP = 'ezw';   nbPass = 10;
            case 5 , MethodCOMP = 'spiht'; nbPass = 10;
            case 6 , MethodCOMP = 'stw';   nbPass = 10;
            case 7 , MethodCOMP = 'wdr';   nbPass = 10;
            case 8 , MethodCOMP = 'aswdr'; nbPass = 10;
        end
    %-------------------------------------------------------------        
    case 109
        filename = 'mask'; wname = 'haar' ; level = 8;
        MethodCOMP = 'aswdr'; nbPass = 11; Rad_Show_VAL = 0;
        
    case 110
        filename = 'mask'; wname = 'bior4.4' ; level = 8;
        MethodCOMP = 'aswdr'; nbPass = 11; Rad_Show_VAL = 0;
    %-------------------------------------------------------------        
    case 111
        filename = 'crtcol'; wname = 'bior4.4' ; level = 9;
        MethodCOMP = 'stw'; nbPass = 12;

    case 112
        filename = 'facets'; wname = 'haar' ; level = 8;
        MethodCOMP = 'ezw'; nbPass = 10;
        
    case 113
        filename = 'laure.jpg'; wname = 'bior4.4' ; level = 8;
        MethodCOMP = 'spiht'; nbPass = 10;
        
    case 114
        filename = 'catherine.jpg'; wname = 'bior4.4' ; level = 8;
        MethodCOMP = 'spiht'; nbPass = 11;        
        
    case 115
        filename = 'woodsculp256.jpg'; wname = 'haar' ; level = 8;
        MethodCOMP = 'ezw'; nbPass = 11;
        
    case 116
        filename = 'arms.jpg'; wname = 'haar' ; level = 8;
        MethodCOMP = 'ezw'; nbPass = 11;
        
    case 117
        filename = 'arms.jpg'; wname = 'haar' ; level = 8;
        MethodCOMP = 'stw'; nbPass = 11;
        
    case 118
        filename = 'arms.jpg'; wname = 'haar' ; level = 8;
        MethodCOMP = 'spiht'; nbPass = 11;
        
    case 119
        filename = 'arms.jpg'; wname = 'haar' ; level = 8;
        MethodCOMP = 'aswdr'; nbPass = 11;
        
    case {120,121,122,123,124,125}
        filename = 'jellyfish256'; wname = 'bior4.4' ; level = 8;
        nbPass = 10;
        switch numDEM
            case 120 , MethodCOMP = 'ezw';
            case 121 , MethodCOMP = 'spiht';
            case 122 , MethodCOMP = 'stw';
            case 123 , MethodCOMP = 'wdr';
            case 124 , MethodCOMP = 'aswdr';
            case 125 , MethodCOMP = 'spiht_3d';
        end
        
    case 126
        filename = 'wpeppers.jpg'; wname = 'bior4.4' ; level = 9;
        MethodCOMP = 'spiht'; nbPass = 11;
        
    case 127
        filename = 'wflower512.jpg'; wname = 'bior4.4' ; level = 9;
        MethodCOMP = 'stw'; nbPass = 11;
        
    case 128
        filename = 'whorse.jpg'; wname = 'bior4.4' ; level = 9;
        MethodCOMP = 'spiht'; nbPass = 11;
        
    case 129
        filename = 'persan.jpg'; wname = 'bior4.4' ; level = 9;
        MethodCOMP = 'stw'; nbPass = 11;
        
end

% Get figure handle.
%-------------------
OK = Init_LoadImage('demo',handles,{filename,level,wname,optIMG}); 
if ~OK , return; end

% Decomposition, GUI Settings and Compression.
%---------------------------------------------
Lst_methodCOMP = get(handles.Pop_METHOD,'String');
numMETH = find(strcmpi(MethodCOMP,Lst_methodCOMP));
set(handles.Pop_METHOD,'Value',numMETH);
Pus_Decompose_Callback(handles.Pus_Decompose,eventdata,handles);
Pop_METHOD_Callback(handles.Pop_METHOD,eventdata,handles);
switch MethodCOMP
    case {'gbl_mmc_f','gbl_mmc_h'}
        set(handles.Edi_Nb_Kept_Cfs,'String',int2str(nbKept_Cfs));
        Comp_Results_Callback(handles.Edi_Nb_Kept_Cfs,eventdata,handles);
    case 'lvl_mmc'
    otherwise
        if exist('nbPass','var')
            set(handles.Pop_Nb_LOOP,'Value',nbPass);
        end
        set(handles.Chk_ALG_STP,'Value',Rad_Show_VAL);
        Chk_ALG_STP_Callback(handles.Chk_ALG_STP,eventdata,handles)
end
Pus_Compress_Callback(handles.Pus_Compress,eventdata,handles,'demo');
%-------------------------------------------------------------------------%
function save_FUN(hObject,eventdata,handles,typeSAVE) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Begin waiting.
%--------------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitSave'));

if nargin<4 , typeSAVE = 'MSF'; end
switch typeSAVE
    case 'MSF'  % Matlab Supported Formats
        % Getting Compressed Image.
        %--------------------------
        axe = handles.Axe_Img_Cmp;
        img_Comp = findobj(axe,'Type','image');
        X = round(get(img_Comp,'CData'));
        utguidiv('save_img',getWavMSG('Wavelet:commongui:Sav_Comp_Img'),hFig,X)
        
    case 'WTC'   % Wavelet Toolbox Compression
        [filename,pathname] = uiputfile( ...
            {'*.wtc',getWavMSG('Wavelet:moreMSGRF:Save_CMP_DLG_WTC'); ...
            '*.ezw',getWavMSG('Wavelet:moreMSGRF:Save_CMP_DLG_EZW');   ...
            '*.spi',getWavMSG('Wavelet:moreMSGRF:Save_CMP_DLG_SPI'); ...
            '*.wdr',getWavMSG('Wavelet:moreMSGRF:Save_CMP_DLG_WDR'); ...
            '*.stw',getWavMSG('Wavelet:moreMSGRF:Save_CMP_DLG_STW');   ...            
            '*.mat',getWavMSG('Wavelet:moreMSGRF:Save_DLG_MAT'); ...
            '*.*',  getWavMSG('Wavelet:moreMSGRF:Save_DLG_ALL')},  ...
            getWavMSG('Wavelet:commongui:Sav_Comp_Img'), 'Untitled.wtc');
            if isempty(filename) || isequal(filename,0)
                wwaiting('off',hFig); return
            end
        try
            Compressed_DATA = wtbxappdata('get',hFig,'Compressed_DATA');
            fid = fopen([pathname,filename], 'w');
            fwrite(fid,Compressed_DATA,'uint8');
            fclose(fid);
        catch ME    %#ok<NASGU>
            errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end
       
end
 wwaiting('off',hFig); 
%-------------------------------------------------------------------------%
function close_FUN(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

Pus_CloseWin = handles.Pus_CloseWin;
Pus_CloseWin_Callback(Pus_CloseWin,eventdata,handles);
%--------------------------------------------------------------------------
function Export_Callback(hObject,eventdata,handles) %#ok<INUSL,INUSL,DEFNU>

hFig = handles.output;
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitExport'));
axe = handles.Axe_Img_Cmp;
img_CMP = findobj(axe,'Type','image');
Xcmp = round(get(img_CMP,'CData'));
wtbxexport(Xcmp,'name','Xcmp','title',getWavMSG('Wavelet:commongui:CompImg'));
wwaiting('off',hFig);
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%
function CleanTOOL(hFig,eventdata,handles,callName,option,varargin) %#ok<INUSL>

tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
edi_UIC = [...
    handles.Edi_Nb_Cfs,handles.Edi_Thr,handles.Edi_Nb_Kept_Cfs,...
    handles.Edi_BPP, handles.Edi_CompRat,handles.Edi_Nb_Symb, ...
    handles.Edi_Nb_Kept_Cfs,handles.Edi_Per_Kept_Cfs   ...
    ];
hdl_SET_1 = [...
        handles.Txt_METHOD,handles.Pop_METHOD, ...
        handles.Txt_Nb_Cfs,handles.Edi_Nb_Cfs, ...
        handles.Edi_Thr,handles.Txt_Thr, ...
        handles.Txt_BPP,handles.Edi_BPP, ...
        handles.Txt_CompRat,handles.Edi_CompRat,handles.Txt_PER_CompRat,...
        handles.Txt_Kept_Cfs, ...
        handles.Txt_EQUI,handles.Edi_Nb_Kept_Cfs, ...
        handles.Txt_Nb_LOOP, handles.Pop_Nb_LOOP, ... 
        handles.Txt_PER,handles.Edi_Per_Kept_Cfs, ...
        handles.Chk_ALG_STP,...
        handles.Chk_StepOnOff, ...
    ];
hdl_SET_3 = [handles.Txt_Fil_Rat,handles.Txt_Bit_Pix];
hdl_SET_4 = [handles.Txt_Nb_Symb,handles.Edi_Nb_Symb];
hdl_SET_5 = [...
        handles.Pus_Compress,handles.Txt_Nb_Symb,handles.Edi_Nb_Symb ...
    ];
hdl_SET_6 = [handles.Pus_NEXT_STP,handles.Pus_END_STP];
hdl_Edi_PERF = [...
    handles.Edi_psnr , handles.Edi_mse , handles.Edi_maxerr , ...
    handles.Edi_Bit_Pix , handles.Edi_Fil_Rat ,handles.Edi_L2_Rat ...
    ];
hdl_Txt_PERF = [...
    handles.Txt_psnr , handles.Txt_mse , handles.Txt_maxerr ,      ...
    handles.Txt_Bit_Pix , handles.Txt_Fil_Rat , handles.Txt_L2_Rat ...
    ];
hdl_Fra_PERF = [handles.Fra_perf,handles.Fra_save];
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
m_SAV_EXP = [hdl_Menus.m_save , hdl_Menus.m_exp_sig];

ena_LOAD_DEC = 'On';
switch callName
    case 'demo_FUN'
        tool_PARAMS.flagIMG_1 = true;
        tool_PARAMS.flagDEC   = false;
        tool_PARAMS.flagCMP   = false;
        tool_PARAMS.flagINS   = false;
        hAXE = [handles.Axe_Img_Ori_Dec, handles.Axe_Img_Ori_Dec_His,...
                handles.Axe_Img_Cmp, handles.Axe_Img_Cmp_Dec];
        hIMG = findobj(hAXE,'Type','image');
        delete(hIMG);
                
    case 'Men_Load_Callback'
        switch option
            case 'beg'
                tool_PARAMS.flagIMG_1 = true;
                tool_PARAMS.flagDEC   = false;
                tool_PARAMS.flagCMP   = false;
                tool_PARAMS.flagINS   = false;
                axesToClean_1 = [...
                        handles.Axe_Img_Ori_Dec, ...
                        handles.Axe_Img_Cmp,...
                        handles.Axe_Img_Cmp_Dec];
                axesToClean_2 = [...
                        handles.Axe_Img_Ori_Dec_His, ...
                        handles.Axe_Img_Cmp_Dec_His];
                Child_1 = get(axesToClean_1,'Children');
                Child_2 = allchild(axesToClean_2);
                toDel = [cat(1,Child_1{:}) ; cat(1,Child_2{:})];
                delete(toDel);
                set([edi_UIC,hdl_Edi_PERF],'String','');                
                set([hdl_SET_1,hdl_SET_3,hdl_SET_4,hdl_SET_6, ...
                     hdl_Txt_PERF, hdl_Edi_PERF , ...
                     handles.Pus_Compress],'Enable','Off')
                if ~isempty(varargin)
                    switch varargin{1}
                        case 'Pop_CC'
                    end
                else
                    set(handles.Pop_CC,'Value',1);
                end
                
            case 'end'
        end
        
    case 'Pus_Decompose_Callback'
        switch option
            case 'beg' , 
                tool_PARAMS.flagDEC = true;
                tool_PARAMS.flagCMP = false;
                hAXE = [handles.Axe_Img_Cmp,handles.Axe_Img_Cmp_Dec];
                hIMG = findobj(hAXE,'Type','image');
                hCHILD = allchild(handles.Axe_Img_Cmp_Dec_His);
                delete([hIMG;hCHILD]);
                set([hdl_Txt_PERF, hdl_Edi_PERF],'Enable','Off');
                set(hdl_Edi_PERF,'String','');
                set([handles.Pus_NEXT_STP,handles.Pus_END_STP], ...
                    'Enable','Off');

            case 'end'
                first = 1;
                style = get(handles.Edi_Thr,'Style');
                if isequal(lower(style(1:3)),'pop')
                    v = get(handles.Pop_METHOD,'Value');
                    s = get(handles.Pop_METHOD,'String');
                    if ~isequal(s(v),'ezw')
                        set(hdl_SET_1(1),'Enable','Off')
                        first = 2;
                    end
                end
                set(hdl_SET_1(first:end),'Enable','On')
                set(handles.Edi_Nb_Cfs,'Enable','Inactive');
                set([hdl_SET_4,handles.Txt_METHOD,handles.Pop_METHOD,...
                    handles.Pus_Compress],'Enable','On')                
        end
        
    case 'Pus_Compress_Callback'
        switch option
            case 'beg'
                tool_PARAMS.flagCMP = false;
                ena_LOAD_DEC = 'Off';
                enaOBJ = [...
                    allchild(handles.Pan_DAT_WAV);
                    hdl_Menus.m_files; ...
                    handles.Pus_Decompose; ...
                    handles.Pop_CC;handles.Txt_CC; ...
                    handles.Txt_Nb_Cfs;handles.Edi_Nb_Cfs;...
                    handles.Txt_BPP;handles.Edi_BPP; ...
                    handles.Txt_CompRat;handles.Edi_CompRat; ...
                    handles.Txt_PER_CompRat; ...
                    handles.Txt_Kept_Cfs; ...
                    handles.Txt_EQUI;handles.Edi_Nb_Kept_Cfs; ...
                    handles.Txt_PER;handles.Edi_Per_Kept_Cfs; ...
                    handles.Txt_METHOD;handles.Pop_METHOD; ...
                    handles.Txt_Thr;handles.Edi_Thr; ...
                    handles.Txt_Nb_Symb;handles.Edi_Nb_Symb; ...
                    handles.Txt_Nb_LOOP; handles.Pop_Nb_LOOP; ...
                    handles.Pus_Compress; ...
                    handles.Chk_ALG_STP;handles.Chk_StepOnOff; ...
                    handles.Pus_CloseWin ...
                    ];
                wtbxappdata('set',hFig,'ena_Pan_CMP_PAR',enaOBJ);
                set(enaOBJ,'Enable','Off');
                set(handles.Tog_Inspect,'Enable','Off');
                
            case 'end' 
                tool_PARAMS.flagCMP = true;
                set(hdl_SET_5,'Enable','On');
                set([hdl_Txt_PERF(1:3), hdl_Edi_PERF(1:3)],'Enable','Inactive');
                set([hdl_Txt_PERF(4:6), hdl_Edi_PERF(4:6)],'Enable','Off');
                set(hdl_Edi_PERF(4:6),'String','');           
                enaOBJ = wtbxappdata('get',hFig,'ena_Pan_CMP_PAR');
                set(enaOBJ,'Enable','On');

        end
        
    case 'Tog_Inspect_Callback'
        Val_Inspect = varargin{1};
        if Val_Inspect==1 , vis_INFO = 'Off'; else vis_INFO = 'On'; end
        flag_Enable = logical(1-Val_Inspect);
        switch option
            case 'beg' ,
                tool_PARAMS.flagDEC = false;
                ena_LOAD_DEC = 'Off';
                ena_NOD_OPT  = 'Off';
            case 'end' ,
                tool_PARAMS.flagDEC = flag_Enable;
                if flag_Enable
                    ena_LOAD_DEC = 'On';
                    ena_NOD_OPT  = 'Off';
                else
                    ena_LOAD_DEC = 'Off';
                    ena_NOD_OPT  = 'On';
                end
        end
        set([handles.Pus_Decompose],'Enable',ena_LOAD_DEC);
        set([handles.Fra_Inspect_Lab,handles.Fra_Inspect_Act, ...
             handles.Txt_Nod_Lab,handles.Pop_Nod_Lab, ...
             handles.Txt_Nod_Act,handles.Pop_Nod_Act], ...
            'Enable',ena_NOD_OPT,'Visible',ena_NOD_OPT);
        set([hdl_Txt_PERF,hdl_Edi_PERF,hdl_Fra_PERF],'Visible',vis_INFO);
        if Val_Inspect==1
            enaOBJ = [...
                allchild(handles.Pan_DAT_WAV);
                hdl_Menus.m_files; ...
                handles.Pop_CC;handles.Txt_CC; ...
                handles.Txt_Nb_Cfs;handles.Edi_Nb_Cfs;...
                handles.Txt_BPP;handles.Edi_BPP; ...
                handles.Txt_CompRat;handles.Edi_CompRat;handles.Txt_PER_CompRat; ...                
                handles.Txt_Kept_Cfs; ...
                handles.Txt_EQUI;handles.Edi_Nb_Kept_Cfs; ...
                handles.Txt_PER;handles.Edi_Per_Kept_Cfs; ...
                handles.Txt_METHOD;handles.Pop_METHOD; ...
                handles.Txt_Thr;handles.Edi_Thr; ...
                handles.Txt_Nb_Symb;handles.Edi_Nb_Symb; ...
                handles.Txt_Nb_LOOP; handles.Pop_Nb_LOOP; ...
                handles.Pus_Compress; ...
                handles.Chk_ALG_STP;handles.Chk_StepOnOff; ...
                handles.Pus_CloseWin ...
                ];
            wtbxappdata('set',hFig,'ena_Pan_CMP_PAR',enaOBJ);
            set(enaOBJ,'Enable','Off');
        else
            enaOBJ = wtbxappdata('get',hFig,'ena_Pan_CMP_PAR');
            set(enaOBJ,'Enable','On');
        end
end

Ok_DEC = tool_PARAMS.flagIMG_1;
if Ok_DEC && isequal(ena_LOAD_DEC,'On')
    set(handles.Pus_Decompose,'Enable','On');
else
    set(handles.Pus_Decompose,'Enable','Off');
end

if tool_PARAMS.flagCMP
    set(handles.Tog_Inspect,'Enable','On');
    set(m_SAV_EXP,'Enable','On')
else
    set(handles.Tog_Inspect,'Enable','Off');
    set(m_SAV_EXP,'Enable','Off')
end

wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);
%-------------------------------------------------------------------------

%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%



%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles) %#ok<INUSL>

% WTBX -- Install DynVTool
%-------------------------
set(hObject,'Visible','off');
dynvtool('Install_V3',hObject,handles);

% WTBX -- Initialize GUIDE Figure.
%---------------------------------
wfigmngr('beg_GUIDE_FIG',hObject);

% WTBX -- Install ANAPAR FRAME
%-----------------------------
wnameDEF  = 'bior4.4';
maxlevDEF = 10;
levDEF    = 10;
utanapar('Install_V3_CB',hObject,'maxlev',maxlevDEF,'deflev',levDEF);
% utanapar('Install_V3',hObject,'maxlev',maxlevDEF,'deflev',levDEF);
cbanapar('set',hObject,'wav',wnameDEF,'lev',levDEF);
cbanapar('Enable',hObject,'Off')

% WTBX -- Install COLORMAP FRAME
%-------------------------------
utcolmap('Install_V3',hObject,'Enable','On');
default_nbcolors = 128;
cbcolmap('set',hObject,'pal',{'pink',default_nbcolors})
cbcolmap('Enable',hObject,'Off')

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',hObject,mfilename);
set(hObject,'WindowButtonMotionFcn','');

%--------------------
% UIMENU INSTALLATION
%--------------------
hdl_Menus = Install_MENUS(hObject,handles);
set(hObject,'DefaultAxesXTick',[],'DefaultAxesYTick',[],...
    'DefaultAxesXTickMode','manual','DefaultAxesYTickMode','manual')
axe_INI = [...
    handles.Axe_Img_Ori_Dec , ...
    handles.Axe_Img_Ori_Dec_His , handles.Axe_Img_Cmp_Dec ,...
    handles.Axe_Img_Ori , handles.Axe_Img_Ori_His ,  handles.Axe_Img_Cmp...
    ];
axe_TREE = [...
    handles.Axe_Tree_Dec , ...
    handles.Axe_Tree_ImgOri  , handles.Axe_Tree_ImgRes ,  handles.Axe_Tree_ImgCmp...
    ];
tool_hdl_AXES = struct('axe_INI',axe_INI,'axe_TREE',axe_TREE);
wguiutils('setAxesTitle',handles.Axe_Img_Ori_His,' ');
wguiutils('setAxesTitle',handles.Axe_Img_Ori_Dec,' ');
wguiutils('setAxesTitle',handles.Axe_Img_Ori_Dec_His,' ');
wguiutils('setAxesXlabel',handles.Axe_Img_Cmp_Dec,' ');
dwt_ATTRB   = struct('type','lwt','wname','','level',[]);
tool_PARAMS = struct(...
    'infoIMG_1',[],'flagIMG_1',false,...
    'flagDEC',false,'flagCMP',false, 'flagINS',false, ...
    'DecIMG_Ori',[],'DecIMG_Res',[],'DecIMG_Comp',[], ...
    'Idx_of_Sorted_Cfs',[],'dwt_ATTRB',dwt_ATTRB,...
    'imgInfos',[]);
node_PARAMS = struct('nodeLab','Index','nodeAct','Visualize');
wtbxappdata('set',hObject,'hdl_Menus',hdl_Menus);
wtbxappdata('set',hObject,'tool_hdl_AXES',tool_hdl_AXES);
wtbxappdata('set',hObject,'tool_PARAMS',tool_PARAMS);
wtbxappdata('set',hObject,'node_PARAMS',node_PARAMS);

MethodCOMPDEF = 'spiht';
set(handles.Pus_Compress,'UserData',MethodCOMPDEF);
set(handles.Pop_METHOD,'Value',2); % Default is SPIHT method
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function hdl_Menus = Install_MENUS(hFig,handles)

m_files = wfigmngr('getmenus',hFig,'file');
m_close = wfigmngr('getmenus',hFig,'close');
cb_close = [mfilename '(''close_FUN'',gcbo,[],guidata(gcbo));'];
set(m_close,'Callback',cb_close);

m_load  = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Load_Image'),'Position',1,'Enable','On');
m_save  = uimenu(m_files,...
    'Label',getWavMSG('Wavelet:divGUIRF:Lab_Sav_CI'), ...
    'Position',2,'Enable','Off'   ...
    );
m_demo  = uimenu(m_files,'Label', ...
    getWavMSG('Wavelet:commongui:Str_Example'),'Position',3);
m_demo_GSC  = uimenu(m_demo, ...
    'Label',getWavMSG('Wavelet:divGUIRF:Gray_Sc_Img'), ...
    'Tag','Gray_Sc_Img','Position',1);
m_demo_COL  = uimenu(m_demo, ...
    'Label',getWavMSG('Wavelet:divGUIRF:Color_Img'), ...
    'Tag','Color_Img','Position',2);

uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Import_Image'),'Position',4, ...
    'Enable','On','Separator','On','Tag','Import',...
    'Callback',  ...    
    [mfilename '(''Men_Load_Callback'',gcbo,[],guidata(gcbo),''wrks'');'] ...
    );
m_exp_sig = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Str_ExpImg'),'Position',5, ...
    'Enable','Off','Separator','Off','Tag','Export',...
    'Callback',[mfilename '(''Export_Callback'',gcbo,[],guidata(gcbo));'] ...
    );
uimenu(m_load, ...
    'Label',getWavMSG('Wavelet:commongui:Mat_Sup_Formats'),     ...
    'Position',1,'Enable','On', ...
    'Callback',                ...
    [mfilename '(''Men_Load_Callback'',gcbo,[],guidata(gcbo),''full'');']  ...
    );
uimenu(m_load, ...
    'Label',getWavMSG('Wavelet:commongui:WTC_Image'),     ...
    'Position',2,'Enable','On', ...
    'Callback',                ...
    [mfilename '(''Men_Load_Callback'',gcbo,[],guidata(gcbo),''comp'');']  ...
    );
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:commongui:Mat_Sup_Formats'), ...
    'Position',1,'Enable','On','Tag','Mat_Sup_Formats',  ...
    'Callback',      ...
    [mfilename '(''save_FUN'',gcbo,[],guidata(gcbo),''MSF'');'] ...
    );
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:commongui:WTC_Image'), ...
    'Position',2,    ...
    'Enable','On',  ...
    'Callback',      ...
    [mfilename '(''save_FUN'',gcbo,[],guidata(gcbo),''WTC'');'] ...
    );

tab = char(9);
GSC_Ex = {...
        'Mask' , 'haar' , 4 , ' GBL_MMC_F' ; ...
        'Mask' , 'haar' , 4 , ' GBL_MMC_H' ; ...
        'Mask' , 'haar' , 4 , ' LVL_MMC' ; ...
        'Mask' , 'haar' , 8 , ' EZW' ; ...
        'Mask' , 'haar' , 8 , ' SPIHT' ; ...
        'Mask' , 'haar' , 8 , ' STW' ; ...
        'Mask' , 'haar' , 8 , ' WDR' ; ...
        'Mask' , 'haar' , 8 , ' ASWDR' ; ...
        'Mask' , 'bior4.4 ' , 8 , ' SPIHT' ; ...
        'Mask' , 'haar ' , 8 , ' STW' ; ...
        'Laure' , 'bior4.4' , 4 , ' GBL_MMC_H' ; ...
        'Catherine' , 'bior4.4' , 4 , ' GBL_MMC_H' ; ...
        'Catherine' , 'bior4.4' , 8 , ' ASWDR' ; ...
        'Circle' , 'bior4.4' , 5 , ' GBL_MMC_H' ; ...
        'Circle' , 'bior4.4' , 9 , ' STW' ; ...
        'Woman' , 'haar' , 7 , ' EZW ' ; ...
        'Bust' , 'bior4.4' , 8 , ' EZW' ; ...
        'Facets' , 'haar' , 8 , ' EZW' ; ...
        'Finger' , 'bior4.4' , 8 , ' SPIHT' ; ...
        'Porch' ,  'bior4.4' , 9 , ' SPIHT' ; ...
        'Sculpture' , 'haar' , 9 , ' SPIHT' ; ...
        'Wood Sculpture' , 'bior4.4' , 8 , ' SPIHT' ; ...
        'Arms' , 'bior4.4' , 4 , ' GBL_MMC_F' ; ...
        'Arms' , 'bior4.4' , 4 , ' GBL_MMC_H' ; ...
        'Arms' , 'bior4.4' , 8 , ' EZW' ; ...
        'Arms' , 'bior4.4' , 8 , ' SPIHT' ; ...
        'JellyFish' , 'bior4.4' , 8 , ' EZW'   ...
        };
    
COL_Ex = {...
        'Statue' , 'bior4.4' , 4 , ' GBL_MMC_F' ; ...
        'Statue' , 'bior4.4' , 4 , ' GBL_MMC_H' ; ...
        'Statue' , 'bior4.4' , 4 , ' LVL_MMC' ; ...
        'Statue' , 'bior4.4' , 8 , ' EZW' ; ...
        'Statue' , 'bior4.4' , 8 , ' SPIHT' ; ...
        'Statue' , 'bior4.4' , 8 , ' STW' ; ...
        'Statue' , 'bior4.4' , 8 , ' WDR' ; ...
        'Statue' , 'bior4.4' , 8 , ' ASWDR' ; ...
        'Mask'   , 'haar ' ,   8 , ' SPIHT' ; ...
        'Mask' ,  'bior4.4 ' , 8 , ' ASWDR' ; ...
        'Circle - Square - Triangle' , 'bior4.4' , 9 , ' STW' ; ...
        'Facets' , 'haar' , 8 , ' EZW' ; ...
        'Laure' , 'bior4.4' , 8 , ' SPIHT' ; ...
        'Catherine' , 'bior4.4' , 8 , ' SPIHT' ; ...
        'Wood Sculpture' , 'haar' , 8 , ' EZW' ; ...
        'Arms' , 'haar' , 8 , ' EZW' ; ...
        'Arms' , 'haar' , 8 , ' STW' ; ...
        'Arms' , 'haar' , 8 , ' SPIHT' ; ...
        'Arms' , 'haar' , 8 , ' ASWDR' ; ...
        'JellyFish' , 'bior4.4' , 8 , ' EZW' ;  ...
        'JellyFish' , 'bior4.4' , 8 , ' SPIHT' ;  ...
        'JellyFish' , 'bior4.4' , 8 , ' STW' ;  ...
        'JellyFish' , 'bior4.4' , 8 , ' WDR' ;  ...
        'JellyFish' , 'bior4.4' , 8 , ' ASWDR' ;  ...
        'JellyFish' , 'bior4.4' , 8 , ' SPIHT-3D';   ...
        'Peppers'   , 'bior4.4' , 9 , ' SPIHT';   ...
        'Flower'    , 'bior4.4' , 8 , ' STW';     ...
        'Wood Horse' , 'bior4.4' , 9 , ' ASWDR';   ...
        'Persan'    , 'bior4.4' , 9 , ' STW'      ...        
        };
    
nbDEM_GSC = size(GSC_Ex,1);
sepSET = [9,16,19,23,27];
for k = 1:nbDEM_GSC
    strNUM = int2str(k);
    action = [mfilename '(''demo_FUN'',gcbo,[],guidata(gcbo),0,' strNUM ');'];
    if find(k==sepSET) , Sep = 'On'; else Sep = 'Off'; end
    menuLAB = getWavMSG('Wavelet:divGUIRF:WTC_Examples',...
        GSC_Ex{k,1},tab,GSC_Ex{k,2},int2str(GSC_Ex{k,3}),GSC_Ex{k,4});
    uimenu(m_demo_GSC,'Label',menuLAB,'Separator',Sep,'Callback',action);
end
    
nbDEM_COL = size(COL_Ex,1);
sepSET = [9,16,20,26];
for k = 1:nbDEM_COL
    strNUM = int2str(k);
    action = [mfilename '(''demo_FUN'',gcbo,[],guidata(gcbo),1,' strNUM ');'];
    if find(k==sepSET) , Sep = 'On'; else Sep = 'Off'; end
    menuLAB = getWavMSG('Wavelet:divGUIRF:WTC_Examples',...
        COL_Ex{k,1},tab,COL_Ex{k,2},int2str(COL_Ex{k,3}),COL_Ex{k,4});
    uimenu(m_demo_COL,'Label',menuLAB,'Separator',Sep,'Callback',action);
end

hdl_Menus = struct('m_files',m_files,'m_close',m_close, ...
    'm_load',m_load,'m_save',m_save,'m_exp_sig',m_exp_sig);

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig, ...
    getWavMSG('Wavelet:divGUIRF:HLP_TrueCOMP'),'TRUECOMP_GUI');

% Add Help Item.
%----------------
wfighelp('addHelpItem',hFig, ...
    getWavMSG('Wavelet:divGUIRF:HLP_WavWTC'),'TRUECOMP_CMPWAV');
wfighelp('addHelpItem',hFig, ...
    getWavMSG('Wavelet:commongui:HLP_AvailMeth'),'TRUECOMP_METH');
wfighelp('addHelpItem',hFig, ...
    getWavMSG('Wavelet:commongui:HLP_LoadSave'),'TRUECOMP_LOADSAVE');
%------------------------------------
hdl_METH_INFOS = [...
    handles.Pan_CMP_PAR;handles.Fra_GBL_Par; ...
    handles.Edi_BPP;handles.Txt_BPP; ...
    handles.Edi_CompRat;handles.Txt_CompRat;handles.Txt_PER_CompRat; ...
    handles.Edi_Thr;handles.Txt_Thr; ...
    handles.Edi_Nb_Kept_Cfs;handles.Edi_Per_Kept_Cfs; ...
    handles.Txt_Kept_Cfs;handles.Txt_EQUI;handles.Txt_PER; ...
    handles.Txt_Nb_Symb;handles.Edi_Nb_Symb; ...
    handles.Txt_Nb_LOOP;handles.Pop_Nb_LOOP;
    ];
%------------------------------------
hdl_PERFOS    = [...
    handles.Txt_psnr;handles.Txt_mse;handles.Txt_maxerr; ...
    handles.Txt_Bit_Pix;handles.Txt_Fil_Rat;handles.Txt_L2_Rat; ...
    handles.Edi_psnr;handles.Edi_mse;handles.Edi_maxerr; ...
    handles.Edi_Bit_Pix;handles.Edi_Fil_Rat;handles.Edi_L2_Rat ...
    ];
wfighelp('add_ContextMenu',hFig,hdl_METH_INFOS,'TRUECOMP_METH');
wfighelp('add_ContextMenu',hFig,hdl_PERFOS,'TRUECOMP_SCORES')
%-------------------------------------------------------------------------
function setDynVTool(handles)

hFig = handles.output;
axe_IND = [...
        handles.Axe_Img_Ori_Dec, ...
        handles.Axe_Img_Cmp_Dec, ...
        handles.Axe_Img_Ori_Dec_His, ...
        handles.Axe_Img_Cmp_Dec_His, ...
        handles.Axe_Img_Ori_His, ...
    ];
axe_CMD = [...
        handles.Axe_Img_Ori,handles.Axe_Img_Cmp, ...
        ];
axe_ACT = [];

% DYNV, Cleaning and End waiting.
%--------------------------------
% dynvtool('ini_his',hFig);
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','real');
CleanTOOL(hFig,[],handles,'Pus_Compress_Callback','end');
wwaiting('off',hFig);
%-------------------------------------------------------------------------
function show_PSNR_and_MSE(handles,X,Xcomp)

[psnr,mse,maxerr] = measerr(X,Xcomp);
set(handles.Edi_psnr,'String',num2str(psnr,4));
set(handles.Edi_mse,'String',num2str(mse,4));
set(handles.Edi_maxerr,'String',num2str(maxerr,4));
%-------------------------------------------------------------------------
function X = get_Original_Image(handles)

Image_Ori = findobj(handles.Axe_Img_Ori,'Type','image');
X = get(Image_Ori,'CData');
%-------------------------------------------------------------------------
function ColType = get_Color_Type(handles)

v = get(handles.Pop_CC,'Value')-1;
ColType = wimgcolconv(v);
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN General Utilities                                  %
%                -----------------------                                  %
%=========================================================================%
function EDGES = showHIST(X,currentAxes,color,barWidth,ratio,AxeTitle)
% Normalized Histogram of Original Image.

X = double(X);
MAXI = max(X(:));
MINI = min(X(:));
differ = MAXI-MINI;
if differ<1000   % For an image differ < 255. For coefs ...
    EDGES = MINI+0.5:MAXI+0.5;
else
    if MINI<-501
        Ebeg = linspace(MINI+0.5,-501,1000); 
    else
        Ebeg = []; 
    end
    if MAXI>501
        Eend = linspace(501,MAXI+0.5,1000);
    else
        Eend = []; 
    end
    EDGES = [Ebeg , (-500:1:500) , Eend];
end
N = histc(X(:),EDGES);
if ratio<100
    XmaxHist = ratio*max(abs(X(:)))/100;
    maxLIM = min([XmaxHist,abs(EDGES(1)),abs(EDGES(end))]);
    Xlim = [-maxLIM,maxLIM];
else
    Xlim = [EDGES(1),EDGES(end)];
end
if Xlim(1)==Xlim(2)
    Xlim  = Xlim + [-1 1]/100;
end
wplotbar(currentAxes,EDGES,N/max(N),color,barWidth)
set(currentAxes,'XLim',Xlim)
wguiutils('setAxesTitle',currentAxes,AxeTitle);
%=========================================================================%
%                END Tool General Utilities                               %
%=========================================================================%


%-------------------------------------------------------------------------
function Comp_Results_Callback(hObject,eventdata,handles,typeARG,InputVal) %#ok<INUSL>

MethodCOMP = get(handles.Pus_Compress,'UserData');
if nargin<4 , typeARG = 'nbcfs'; end
hFig = handles.output;

% Get number of BitPlan.
%-----------------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
sizeMAT = tool_PARAMS.imgInfos.size;
if length(sizeMAT)<3 , nbPlan = 1; else  nbPlan = sizeMAT(3); end

% Compute ordered coefficients.
%------------------------------
tree_Ori = tool_PARAMS.DecIMG_Ori;
C = read(tree_Ori,'data');
Idx = tool_PARAMS.('Idx_of_Sorted_Cfs');
C = C(Idx);

nb_Cfs = get(handles.Edi_Nb_Cfs,'UserData');        
switch MethodCOMP
    case {'gbl_mmc_h','gbl_mmc_f','lvl_mmc'}
        if nargin<5
            InputVal = str2double(get(hObject,'String'));
        end
        [OK,nb_Kept_Cfs,Per_Kept_Cfs,bpp,comprat,threshold] = ...
            getcompresspar(MethodCOMP,nb_Cfs,nbPlan,typeARG,InputVal,C);

        if OK
            set(handles.Edi_Nb_Kept_Cfs,...
                'String',int2str(nb_Kept_Cfs),'UserData',nb_Kept_Cfs);
            set(handles.Edi_Per_Kept_Cfs,...
                'String', sprintf('%2.2f',Per_Kept_Cfs),...
                'UserData',Per_Kept_Cfs);
            set(handles.Edi_BPP,...
                'String', sprintf('%2.3f',bpp),'UserData',bpp);
            set(handles.Edi_CompRat,...
                'String', sprintf('%2.2f',comprat),'UserData',comprat);
            switch MethodCOMP
                case {'gbl_mmc_h','gbl_mmc_f'}
                    set(handles.Edi_Thr,...
                        'String',num2str(threshold),'UserData',threshold);
                case 'lvl_mmc'
            end
        else
            set(hObject,'String',num2str(get(hObject,'UserData')));
        end

    case {'ezw','spiht','spiht_3d','stw','wdr','aswdr'}
        if nargin<5
            InputVal = str2double(get(hObject,'String'));
            switch typeARG
                case {'thr','nbcfs','percfs','bpp','comprat'}
                    InputVal = str2double(get(hObject,'String'));
                case 'loop'
                    InputVal = get(hObject,'Value');
            end
        end
        [OK,loop,bpp,comprat] = ...
            getcompresspar(MethodCOMP,nb_Cfs,nbPlan,typeARG,InputVal);
        if OK
            set(handles.Pop_Nb_LOOP,'Value',loop,'UserData',loop);
        else
            loop = get(handles.Pop_Nb_LOOP,'UserData');
            set(handles.Pop_Nb_LOOP,'Value',loop); 
            [~,~,bpp,comprat] = ...
                getcompresspar(MethodCOMP,nb_Cfs,nbPlan,'loop',loop);
        end
        set(handles.Edi_BPP,...
            'String', sprintf('%2.3f',bpp),'UserData',bpp);
        set(handles.Edi_CompRat,...
            'String', sprintf('%2.2f',comprat),'UserData',comprat);        
end
%-------------------------------------------------------------------------
function Edi_Nb_Symb_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

nb_Symb = str2double(get(hObject,'String'));
OK = ~isnan(nb_Symb) & (nb_Symb==fix(nb_Symb)) & ...
    (nb_Symb>=2) & (nb_Symb<=256);
if OK
    set(hObject,'UserData',nb_Symb);
else
    set(hObject,'String',num2str(get(hObject,'UserData')));
end
%-------------------------------------------------------------------------
function Pus_Compress_Callback(hObject,eventdata,handles,flagDEMO) %#ok<INUSD,INUSL>

hFig = handles.output;
MethodCOMP = get(handles.Pus_Compress,'UserData');
filename = 'wtbx_save_tmp.mat';
pathname = [cd , filesep];

% Waiting.
%---------
wwaiting('msg',hFig,getWavMSG('Wavelet:divGUIRF:WaitCodeCompute'));

% Get Parameters.
%----------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
imgInfos = tool_PARAMS.('imgInfos');
dwt_ATTRB = tool_PARAMS.dwt_ATTRB;
wname = dwt_ATTRB.wname;
level = dwt_ATTRB.level;
modeDWT = dwtmode('status','nodisp');
ColType = get_Color_Type(handles);
Sav_filename = [pathname,filename];

% Reset Dynvtool.
%----------------
dynvtool('get',hFig,0);

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
CleanTOOL(hFig,eventdata,handles,'Pus_Compress_Callback','beg');

wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));
switch MethodCOMP    
    case {'gbl_mmc_h','gbl_mmc_f'}
        % Get Decompositions Parameters.
        %-------------------------------
        tree_Ori = tool_PARAMS.DecIMG_Ori;

        % Get Original Image.
        %--------------------
        X = get_Original_Image(handles);

        % Get GUI Parameters.
        %--------------------
        nbKeptCFS  = str2double(get(handles.Edi_Nb_Kept_Cfs,'String'));
        threshold  = str2double(get(handles.Edi_Thr,'String'));
        nb_CLASSES = str2double(get(handles.Edi_Nb_Symb,'String'));

        % Normalized Histogram of Wavelet Coefficients.
        %----------------------------------------------
        C = read(tree_Ori,'data');
        showHIST(C,handles.Axe_Img_Ori_Dec_His, ...
            'b',0.8,1,{getWavMSG('Wavelet:divGUIRF:WTC_Wav_Cfs'), ...
                       getWavMSG('Wavelet:divGUIRF:WTC_Nor_Hist_Trunc')});

        % Get Decompositions Parameters.
        %-------------------------------
        tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');

        % Writing and Reading.
        %---------------------
        wtcmngr('write',3,Sav_filename,MethodCOMP,...
            X,{level,wname,modeDWT},{threshold,nb_CLASSES},ColType);        
        X_decoded = wtcmngr('read',3,Sav_filename);        
        X_decoded = wd2uiorui2d('d2uint',X_decoded);

        % Decomposition of Compressed Image.
        %-----------------------------------
        C = read(tree_Ori,'data');
        Idx = tool_PARAMS.('Idx_of_Sorted_Cfs');
        C(Idx(1:end-nbKeptCFS)) = 0; 
        tree_Comp = write(tree_Ori,'data',C);        
        DecIMG_Comp = getdec(tree_Comp);
        DecIMG_Comp = wd2uiorui2d('d2uint',DecIMG_Comp);
        currentAxes = handles.Axe_Img_Cmp_Dec;
        imagesc(DecIMG_Comp,'Parent',currentAxes);
        wguiutils('setAxesXlabel',currentAxes, ...
            getWavMSG('Wavelet:divGUIRF:WTC_Thr_Dec'));

        % Show Compressed Image.
        %-----------------------
        currentAxes = handles.Axe_Img_Cmp;
        image(X_decoded,'Parent',currentAxes,'Tag','Compressed_Image');
        wguiutils('setAxesXlabel',currentAxes, ...
            getWavMSG('Wavelet:commongui:CompImg'));
        show_PSNR_and_MSE(handles,X,X_decoded);

    case {'lvl_mmc'}
        % Get Decompositions Parameters.
        %-------------------------------
        tree_Ori = tool_PARAMS.DecIMG_Ori;

        % Get GUI Parameters.
        %--------------------
        bpp_Required = str2double(get(handles.Edi_BPP,'String'));

        % Get Original Image.
        %--------------------
        X = get_Original_Image(handles);

        % Normalized Histogram of Wavelet Coefficients.
        %----------------------------------------------
        C = read(tree_Ori,'data');
        showHIST(C,handles.Axe_Img_Ori_Dec_His, ...
            'b',0.8,1,{getWavMSG('Wavelet:divGUIRF:WTC_Wav_Cfs'), ...
                       getWavMSG('Wavelet:divGUIRF:WTC_Nor_Hist')});

        % Writing and Reading.
        %---------------------
        lvl_mmc_Cell = wtcmngr('write',3,Sav_filename,'lvl_mmc', ...
            X,{level,wname,modeDWT},bpp_Required,ColType);
        [X_decoded,CfsRec] = wtcmngr('read',3,Sav_filename);
        X_decoded = wd2uiorui2d('d2uint',X_decoded);
        nb_Kept_Cfs = lvl_mmc_Cell{2};
        set(handles.Edi_Nb_Kept_Cfs,...
            'String',int2str(nb_Kept_Cfs),'UserData',nb_Kept_Cfs);

        % Decomposition of Compressed Image.
        %-----------------------------------
        tree_Comp = write(tree_Ori,'data',CfsRec);
        DecIMG_Comp = getdec(tree_Comp);
        DecIMG_Comp = wd2uiorui2d('d2uint',DecIMG_Comp);
        currentAxes = handles.Axe_Img_Cmp_Dec;
        imagesc(DecIMG_Comp,'Parent',currentAxes);
        wguiutils('setAxesXlabel',currentAxes, ...
            getWavMSG('Wavelet:divGUIRF:WTC_Thr_Dec'));

        % Show Compressed Image.
        %-----------------------
        currentAxes = handles.Axe_Img_Cmp;
        image(X_decoded,'Parent',currentAxes,'Tag','Compressed_Image');
        wguiutils('setAxesXlabel',currentAxes, ...
            getWavMSG('Wavelet:commongui:CompImg'));
        show_PSNR_and_MSE(handles,X,X_decoded);

    case {'ezw','spiht','spiht_3d','stw','wdr','aswdr'}
        % Decomposition.
        %---------------
        [wname,level] = cbanapar('get',hFig,'wav','lev');
        X = get_Original_Image(handles);
        MaxLoop = get(handles.Pop_Nb_LOOP,'Value');
        stepFLAG = get(handles.Chk_ALG_STP,'Value');
        currentAxes = handles.Axe_Img_Cmp;
        stepByStep_Flag = get(handles.Chk_StepOnOff,'Value');
        if stepFLAG
            if stepByStep_Flag
                stepFLAG = ...
                    {handles.Pus_NEXT_STP,handles.Pus_END_STP, ...
                     handles.Chk_ALG_STP,handles.Chk_StepOnOff};
                wwaiting('msg',hFig, ...
                    getWavMSG('Wavelet:divGUIRF:WTC_Next_Or_Finish'));
                set(hFig,'Pointer','hand')
            end
        end
        ezw_Encoded = ...
            wtcmngr('enc',3,MethodCOMP,X,wname,level,modeDWT,...
            MaxLoop,ColType,stepFLAG,currentAxes);
        if stepByStep_Flag , set(hFig,'Pointer','arrow'); end
        wtbxappdata('set',hFig,'ezw_Encoded',ezw_Encoded);
        Img_Comp = findobj(currentAxes,'Type','image');
        set(Img_Comp,'Tag','Compressed_Image');
        wguiutils('setAxesTitle',currentAxes,'');
        wguiutils('setAxesXlabel',currentAxes, ...
            getWavMSG('Wavelet:commongui:CompImg'));
        X_decoded = get(Img_Comp,'CData');
        show_PSNR_and_MSE(handles,X,X_decoded);
        
        % Decomposition of Compressed Image.
        %-----------------------------------
        WT_Settings = struct(...
            'typeWT','dwt','wname',wname,...
            'extMode','per','shift',[0,0]);
        tree_Comp = wdectree(X_decoded,2,level,WT_Settings);
        DecIMG_Comp = getdec(tree_Comp);
        DecIMG_Comp = wd2uiorui2d('d2uint',DecIMG_Comp);
        currentAxes = handles.Axe_Img_Cmp_Dec;
        imagesc(DecIMG_Comp,'Parent',currentAxes);
        wguiutils('setAxesXlabel',currentAxes,...
            getWavMSG('Wavelet:divGUIRF:WTC_Dec_CI'));

        % Writing and Reading.
        %---------------------
        wtcmngr('save',3,Sav_filename,MethodCOMP,ezw_Encoded);
end

%----------------------------------------------------------
imgINAxes = findobj(handles.Axe_Img_Cmp,'Type','image');
Cdata = get(imgINAxes,'CData');
showHIST(Cdata,handles.Axe_Img_Cmp_Dec_His, ...
    [1 0 1],1,100,...
    {getWavMSG('Wavelet:commongui:CompImg'), ...
     getWavMSG('Wavelet:divGUIRF:WTC_Nor_Hist')});
%----------------------------------------------------------

% DYNV, Cleaning and End waiting.
%--------------------------------
setDynVTool(handles);


% Compression Computation
%-------------------------
Txt_psnr     = handles.Txt_psnr;
Txt_mse      = handles.Txt_mse;
Txt_maxerr   = handles.Txt_maxerr;
Txt_Bit_Pix  = handles.Txt_Bit_Pix;
Txt_Fil_Rat  = handles.Txt_Fil_Rat;
TxT_L2_Rat   = handles.Txt_L2_Rat;
Edi_psnr     = handles.Edi_psnr;
Edi_mse      = handles.Edi_mse;
Edi_maxerr   = handles.Edi_maxerr;
Edi_Bit_Pix  = handles.Edi_Bit_Pix;
Edi_Fil_Rat  = handles.Edi_Fil_Rat;
Edi_L2_Rat   = handles.Edi_L2_Rat;
%------------------------------------
hdl_Edi_PERF = [...
    Edi_psnr , Edi_mse , Edi_maxerr , Edi_Bit_Pix , Edi_Fil_Rat , Edi_L2_Rat];
hdl_Txt_PERF = [...
    Txt_psnr , Txt_mse , Txt_maxerr , Txt_Bit_Pix , Txt_Fil_Rat , TxT_L2_Rat];
%---------------------------------------
try
    [compRATIO_Str,NbBitByPix_Str] = ...
        wcomp_img_info('str',[pathname,filename],imgInfos.size);
catch ME %#ok<NASGU>
    New_filename = [tempdir , filename];
    [compRATIO_Str,NbBitByPix_Str] = ...
        wcomp_img_info('str',New_filename,imgInfos.size);    
end
X = get_Original_Image(handles);
[psnr,mse,maxerr,L2_Ratio] = measerr(X,X_decoded);
%---------------------------------------
set(Edi_Bit_Pix,'String',NbBitByPix_Str);
set(Edi_Fil_Rat,'String',compRATIO_Str);
set(Edi_psnr,'String',num2str(psnr,4));
set(Edi_mse,'String',num2str(mse,4));
set(Edi_maxerr,'String',num2str(maxerr,4));
L2_Ratio_Str  = [num2str(100*L2_Ratio,'%5.2f') ,' %'];
set(Edi_L2_Rat,'String',L2_Ratio_Str);
%---------------------------------------
set([hdl_Txt_PERF,hdl_Edi_PERF],'Enable','Inactive');

% Store Compressed File Contain.
%-------------------------------
fid = fopen(Sav_filename, 'r');
if fid==-1
    [~,fname,ext] = fileparts(Sav_filename);
    Sav_filename = [tempdir , fname ,ext];
    fid = fopen(Sav_filename, 'r');
end
Compressed_DATA = fread(fid);
wtbxappdata('set',hFig,'Compressed_DATA',Compressed_DATA);
fclose(fid);
delete(Sav_filename);

% End waiting.
%-------------
wwaiting('off',hFig);
%-------------------------------------------------------------------------
function Pus_Quantize_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

% Get Decompositions Parameters.
%-------------------------------
hFig = handles.output;
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tree_Ori = tool_PARAMS.DecIMG_Ori;

% Get GUI Parameters.
%--------------------
threshold  = str2double(get(handles.Edi_Thr,'String'));
nb_CLASSES = fix(str2double(get(handles.Edi_Nb_Symb,'String')));
MethodCOMP = get(handles.Pus_Compress,'UserData');

% Get Wavelet Packet Decomposition.
%----------------------------------
C = read(tree_Ori,'data');
C = wtc_gbl_mmc('quantize','none',MethodCOMP,C,threshold,nb_CLASSES);
T = write(tree_Ori,'data',C);
XRec = wdtrec(T);
% XRec = round(XRec);
% XRec(XRec<1) = 1;
XRec = wd2uiorui2d('d2uint',XRec);
currentAxes = handles.Axe_Img_Cmp_Dec;
image(XRec,'Parent',currentAxes);
wguiutils('setAxesXlabel',currentAxes, ...
    getWavMSG('Wavelet:divGUIRF:Quantized_image'));
%-------------------------------------------------------------------------
function Pop_CC_Callback(hObject,eventdata,handles) %#ok<DEFNU>

val = get(hObject,'Value');
usr = get(hObject,'UserData');
if isequal(val,usr) , return; end

set(hObject,'UserData',val);
hFig = handles.output;
CleanTOOL(hFig,eventdata,handles,'Men_Load_Callback','beg','Pop_CC');
CleanTOOL(hFig,eventdata,handles,'Men_Load_Callback','end','Pop_CC');
%-------------------------------------------------------------------------
function OK = Init_LoadImage(CallingOpt,handles,params)

hFig = handles.output;
def_nbCodeOfColors = 255;
if isequal(CallingOpt,'demo');
    [filename,level,wname,optIMG] = deal(params{:});
    [name,ext] = strtok(filename,'.');
    if isempty(ext) || isequal(ext,'.')
        ext = '.mat'; filename = [name ext];
    end
    pathname = utguidiv('WTB_DemoPath',filename);
    [imgInfos,X,map,OK] = utguidiv('load_dem2D',hFig,...
        pathname,filename,def_nbCodeOfColors,optIMG);
    clean_OPT = {'demo_FUN'};
else
    [WTB_compFORMAT,wrks_FLAG,optIMG] = deal(params{:});
    if ~WTB_compFORMAT
        if ~wrks_FLAG
            imgFileType = getimgfiletype;
            [imgInfos,X,map,OK] = utguidiv('load_img',hFig, ...
                imgFileType, getWavMSG('Wavelet:commongui:Load_Image'), ...
                def_nbCodeOfColors,optIMG);
        else
            [imgInfos,X,OK] = wtbximport('2d');
            map = pink(def_nbCodeOfColors);
        end
    else
        imgFileType = {'*.wtc;*.ezw;*.spi;*.wdr;*.stw',...
            getWavMSG('Wavelet:moreMSGRF:Save_DLG_ALL_WTC'); ...
            '*.mat;', getWavMSG('Wavelet:moreMSGRF:Save_DLG_MAT'); ...
            '*.*', getWavMSG('Wavelet:moreMSGRF:Save_DLG_ALL')};
        [imgInfos,X,map,OK] = ...
            utguidiv('load_comp_img',hFig,imgFileType,...
            getWavMSG('Wavelet:divGUIRF:WTC_Load_WTC_Img'),def_nbCodeOfColors);
    end
    clean_OPT = {'Men_Load_Callback','beg'};
end
if ~OK, return; end

% Check image size.
%-------------------
img_Size = imgInfos.size;
SS = log2(img_Size(1:2));
if any(SS~=fix(SS))
    msg = {getWavMSG('Wavelet:divGUIRF:WTC_Inv_ImgSize'), ...
        getWavMSG('Wavelet:divGUIRF:WTC_Pow2_Size')};
    errargt(mfilename,msg,'msg');
    wwaiting('off',hFig);
    return
end

tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tool_PARAMS.('imgInfos') = imgInfos;
wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
CleanTOOL(hFig,[],handles,clean_OPT{:});

% Setting GUI values and Analysis parameters.
%--------------------------------------------
max_lev_anal = 12;
[curlev,curlevMAX] = cbanapar('get',hFig,'lev','levmax');
levm = wmaxlev(imgInfos.size([1 2]),'haar');
levmax = min([levm,max_lev_anal]);
if isequal(CallingOpt,'demo');
    level = min([levm,level]);
else
    level = levm;
end
if levmax~=curlevMAX || ((level~=curlev) && ~isequal(CallingOpt,'demo'))
    cbanapar('set',hFig, ...
        'lev',{'String',int2str((1:levmax)'),'Value',min(levmax,level)} ...
        );
end
if isequal(CallingOpt,'demo');
    cbanapar('set',hFig,'wav',wname,'lev',level);
end
cbanapar('Enable',hFig,'On');

% Loading Images and Setting GUI.
%-------------------------------
if isequal(imgInfos.true_name,'X')
    img_Name = imgInfos.name;
else
    img_Name = imgInfos.true_name;
end
NB_ColorsInPal = size(map,1);
if imgInfos.self_map , arg = map; else arg = []; end
cbcolmap('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
cbcolmap('Enable',hFig,'On');
n_s = [img_Name '  (' , int2str(img_Size(2)) 'x' int2str(img_Size(1)) ')'];
set(handles.Edi_Data_NS,'String',n_s);

% Original Image and Normalized Histogram of Original Image.
%-----------------------------------------------------------
nbDIM = ndims(X);
switch nbDIM
    case 2 , X = double(X);
    case 3 , X = uint8(X);
end

% To manage colormap tool for truecolor images
TST_vis_UTCOLMAP_FLAG = true;
vis_UTCOLMAP = 'On';
vis_COLCONV = 'Off';
if TST_vis_UTCOLMAP_FLAG
    if nbDIM>2 , vis_UTCOLMAP = 'Off'; vis_COLCONV = 'On'; end
    cbcolmap('Visible',hFig,vis_UTCOLMAP);
    set([handles.Txt_CC,handles.Pop_CC],'Visible',vis_COLCONV);
end
wtbxappdata('set',hFig,'vis_UTCOLMAP',vis_UTCOLMAP);

currentAxes = handles.Axe_Img_Ori;
image(X,'Parent',currentAxes,'Tag','Original_Image'); 
wguiutils('setAxesTitle',currentAxes, ...
    getWavMSG('Wavelet:commongui:OriImg'));
showHIST(X,handles.Axe_Img_Ori_His, ...
    'r',1,100,{getWavMSG('Wavelet:commongui:OriImg'),getWavMSG('Wavelet:divGUIRF:WTC_Nor_Hist')});

% End waiting.
%-------------
wwaiting('off',hFig);
%-------------------------------------------------------------------------
function Chk_ALG_STP_Callback(hObject,eventdata,handles) 

val = get(hObject,'Value');
switch val
    case 0 , vis = 'Off'; valRad = 0;
    case 1 , vis = 'On';  valRad = get(handles.Chk_StepOnOff,'Value');
end
set(handles.Chk_StepOnOff,'Visible',vis,'Value',valRad);
Chk_StepOnOff_Callback(handles.Chk_StepOnOff,eventdata,handles)
%-------------------------------------------------------------------------
function Chk_StepOnOff_Callback(hObject,eventdata,handles) %#ok<INUSL>

Step_HDL = [handles.Pus_NEXT_STP,handles.Pus_END_STP];
val = get(hObject,'Value');
switch val
    case 0 , vis = 'Off';    
    case 1 , vis = 'On';
end
set(Step_HDL,'Visible',vis);
%-------------------------------------------------------------------------
function Pus_NEXT_STP_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

val = get(hObject,'UserData');
set(hObject,'UserData',1-val);
%-------------------------------------------------------------------------
function Pus_END_STP_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

set(hObject,'UserData',1);
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function varargout = wcomp_img_info(option,filename,Size_Img_ORI)
%WCOMP_IMG_INFO Compression information
%   VARARGOUT = WCOMP_IMG_INFO(OPTION,FILENAME,SIZE_IMG_ORI)
%   [compRATIO,NbBitByPix,compRATIO_Str,NbBitByPix_Str] =  ...
%          WCOMP_IMG_INFO('all',FILENAME,SIZE_IMG_ORI)
%
%   [compRATIO_Str,NbBitByPix_Str] = WCOMP_IMG_INFO('str',...)
%   [compRATIO,NbBitByPix]         = WCOMP_IMG_INFO('num',...)
%   [NbBitByPix,NbBitByPix_Str]    = WCOMP_IMG_INFO('bit',...)
%   [compRATIO,compRATIO_Str]      = WCOMP_IMG_INFO('rat',...)
%
%   Default: OPTION = 'num'

fid = fopen(filename);
[~,count] = fread(fid);
fclose(fid);
NbBytes = prod(Size_Img_ORI(1:2));
size_Of_File_THEO = prod(Size_Img_ORI);
%---------------------------------------------------
% The "physical" compression ratio is  obtained by: 
%	compRATIO  = count/size_Of_File;
% with the real size of file
%---------------------------------------------------
compRATIO  = count/size_Of_File_THEO;
NbBitByPix = (8*count)/NbBytes;
compRATIO_Str  = [num2str(100*compRATIO,'%5.2f') ,' %'];
NbBitByPix_Str = num2str(NbBitByPix);

switch option
    case 'all'
        varargout = {compRATIO,NbBitByPix,compRATIO_Str,NbBitByPix_Str};
    case 'str'
        varargout = {compRATIO_Str,NbBitByPix_Str};
    case 'num'
        varargout = {compRATIO,NbBitByPix};
    case 'bit'
        varargout = {NbBitByPix,NbBitByPix_Str};
    case 'rat'
        varargout = {compRATIO,compRATIO_Str};
    otherwise
        varargout = {compRATIO,NbBitByPix};
end
%-------------------------------------------------------------------------
function varargout = wplotbar(Ax,E,N,ColorFill,RatioW)
%WPLOTBAR Bar graph.

N = N(:)'; 
if isnan(N) ; return; end
E = E(:)';
d = diff(E);
if isempty(d)
    d = 0.01;
else
    d = [d d(1)];
end

E = E+d/2;
d = RatioW*d/2;
xs = [E-d;E-d;E+d;E+d];
ns = zeros(size(xs));
ns(2:3,:) = [N(:)' ; N(:)'];
xs = xs(:)';
ns = ns(:)';
XY = [xs;ns];
hdl = wplothis(Ax,XY,ColorFill,ColorFill);
if nargout>0 , varargout{1} = hdl; end
%-------------------------------------------------------------------------
