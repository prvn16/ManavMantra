function varargout = wtc_gbl_mmc(option,typeSAVE,varargin)
%WTC_GBL_MMC Max Module Code (Huffman or fixed encoding).
%   VARARGOUT = WTC_GBL_MMC(OPTION,VARARGIN)
%
%   WTC_GBL_MMC('encode',...)
%   WTC_GBL_MMC('decode',...)
%   WTC_GBL_MMC('save',...)
%   WTC_GBL_MMC('load',...)
%   WTC_GBL_MMC('quantize',...)
%   WTC_GBL_MMC('unquantize',...)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Jun-2004.
%   Last Revision: 06-May-2009.
%   Copyright 1995-2009 The MathWorks, Inc.

nbCHAR = 1;
validOPTION = {'encode','decode','save','load','quantize','unquantize'};
numOPT = find(strncmpi(option,validOPTION,nbCHAR));
nbout = nargout;
switch numOPT
    %----- 'encode' -----%
    case 1 , [varargout{1:nbout}] = gbl_mmc_enc(typeSAVE,varargin{:});
    %----- 'decode' -----%
    case 2 , [varargout{1:nbout}] = gbl_mmc_dec(typeSAVE,varargin{:});
    %------ 'save' ------%
    case 3 , [varargout{1:nbout}] = gbl_mmc_save(typeSAVE,varargin{:});
    %------ 'load' ------%
    case 4 , [varargout{1:nbout}] = gbl_mmc_load(typeSAVE,varargin{:});
    %---- 'quantize' ----%
    case 5 , [varargout{1:nbout}] = gbl_mmc_quantize(varargin{:});
    %--- 'unquantize' ---%
    case 6 , [varargout{1:nbout}] = gbl_mmc_unquantize(varargin{:});
end


%=======================================================================%
function gbl_mmc_Cell = gbl_mmc_enc(typeSAVE,varargin)
%GBL_MMC_ENC Encode Max Module Code (Huffman or fixed encoding).
%   GBL_MMC_ENC(TYPECODE,VARARGIN)

nb_CLASSES_DEF = 75;
typeCODE = varargin{1};
X = varargin{2};
[level,wname,modeDWT]  = deal(varargin{3}{:}); %#ok<NASGU>
modeDWT = 'per';   % Force periodization for the DWT.
methodParams = varargin{4};
ColType = varargin{5};

WT_Settings = struct(...
    'typeWT','dwt','wname',wname,...
    'extMode',modeDWT,'shift',[0,0]);
[X,ColMAT] = wimgcolconv(ColType,X);
T = wdectree(X,2,level,WT_Settings);
[order,tn_of_TREE,WT_Settings] = get(T,'order','tn','WT_Settings');
[size_of_DATA,C] = read(T,'sizes',0,'data');
type_of_DATA = get(T,'typData');
Dat_Par = {order , tn_of_TREE , type_of_DATA , size_of_DATA , WT_Settings};

if iscell(methodParams)
    [threshold,nb_CLASSES] = deal(methodParams{:});
elseif isstruct(methodParams)
    fn = lower(fieldnames(methodParams));
    idx = find(strcmpi(fn,'thr'));
    if ~isempty(idx)
        parType = 'thr';
        parVal  = methodParams.(fn{idx});
    else
        idx = find(strcmpi(fn,'comprat'));
        if ~isempty(idx)
            parType = 'comprat';
            parVal = methodParams.(fn{idx});
        else
            idx = find(strcmpi(fn,'bpp'));
            if ~isempty(idx)
                parType = 'bpp';
                parVal = methodParams.(fn{idx});
            else
                idx = find(strcmpi(fn,'nbcfs'));
                if ~isempty(idx)
                    parType = 'nbcfs';
                    parVal = methodParams.(fn{idx});
                else
                    idx = find(strcmpi(fn,'percfs'));
                    if ~isempty(idx)
                        parType = 'percfs';
                        parVal = methodParams.(fn{idx});
                    end
                end
            end
        end
    end
    nb_Cfs = length(C);
    if size(X,3)>2 , nbPlan = 3; else nbPlan = 1; end
    [OK,nb_Kept_Cfs,Per_Kept_Cfs,bpp,comprat,threshold] = ...
        getcompresspar(typeCODE,nb_Cfs,nbPlan,parType,parVal,C);   
    idx = find(strcmpi(fn,'nbclas'));
    if ~isempty(idx)
        nb_CLASSES = methodParams.(fn{idx});
    else
        nb_CLASSES = nb_CLASSES_DEF;
    end
end

[Cfs_Par,Idx_Par,Cod_Par] = ...
    gbl_mmc_quantize('encode',typeCODE,C,threshold,nb_CLASSES);

switch wtcmngr('meth_ident',typeSAVE,typeCODE)
    case 'h'    % Huffman
        HC_Struct  = whuffencode(Cod_Par{3});
        Cod_Par{3} = HC_Struct.HC_tabENC;
        Cod_Par{5} = HC_Struct.HC_codes;

    case 'f'   % Fixed length coding
end
gbl_mmc_Cell = {typeCODE,ColType,ColMAT,Dat_Par,Cfs_Par,Idx_Par,Cod_Par};
%=======================================================================%
function [Xrec,T] = gbl_mmc_dec(typeSAVE,gbl_mmc_Cell,varargin)
%GBL_MMC_DEC Decode Max Module Code (Huffman or fixed encoding).
%   [Xrec,T] = GBL_MMC_DEC(WTC_Struct)

[typeCODE,ColType,ColMAT,Dat_Par,Cfs_Par,Idx_Par,Cod_Par] = ...
    deal(gbl_mmc_Cell{:});
[order , tn_of_TREE , type_of_DATA , size_of_DATA , WT_Settings] = ...
    deal(Dat_Par{:});
codeID = wtcmngr('meth_ident',typeSAVE,typeCODE);
switch codeID
    case 'h'    % Huffman Coding
        [minE , nb_CODED , TabCODE , signCFS , HCTab] = deal(Cod_Par{:});
        E = whuffdecode(HCTab,TabCODE,nb_CODED);
        Cod_Par = {minE , nb_CODED , E , signCFS};
    case 'f'    % Fixed length coding
end
D = gbl_mmc_unquantize(typeCODE,Cfs_Par,Idx_Par,Cod_Par);
if isequal(type_of_DATA,'2d3') , size_of_DATA(3) = 3; end
[T,Xrec] = cfs2wdt(WT_Settings,size_of_DATA,tn_of_TREE,order,D);
Xrec = wimgcolconv(['inv' ColType],Xrec,ColMAT);
if ndims(Xrec)>2 , Xrec = uint8(Xrec); end
%=======================================================================%
function count = gbl_mmc_save(typeSAVE,filename,gbl_mmc_Cell)
%GBL_MMC_SAVE Save Max Module Code (Huffman or fixed encoding).
%   GBL_MMC_SAVE(FILENAME,WTC_Struct)

% File settings.
%---------------
tmp_filename  = def_tmpfile(filename);
fid = fopen(tmp_filename,'wb');



% Check Inputs.
%---------------
[typeCODE,ColType,ColMAT,Dat_Par,Cfs_Par,Idx_Par,Cod_Par] = ...
    deal(gbl_mmc_Cell{:});
[order , tn_of_TREE , type_of_DATA , size_of_DATA , WT_Settings] = ...
    deal(Dat_Par{:});
[nb_C , Max_C , R0, nb_CLASSES] = deal(Cfs_Par{:});
[len_Idx , First_Idx , idx_NZ]  = deal(Idx_Par{:});
codeID = wtcmngr('meth_ident',typeSAVE,typeCODE);
switch codeID
    case 'h'    % Huffman Coding
        [minE , nb_CODED , TabCODE , signCFS , HCTab] = deal(Cod_Par{:});

    case 'f'    % Fixed length coding
        [minE , nb_CODED , TabCODE , signCFS] = deal(Cod_Par{:});
end

% Begin Saving.
%--------------
fwrite(fid,codeID,'ubit8');
%----------------------------
% switch typeCODE(end)
%     case '2'  , saveCODE = 0;
%     case '1'  , saveCODE = 1;
%     otherwise , saveCODE = 0;
% end
% fwrite(fid,saveCODE,'ubit1');
%------------------------------
codeCOL = wimgcolconv(ColType);
fwrite(fid,codeCOL,'ubit3');
if isequal(codeCOL,2)
    fwrite(fid,ColMAT,'float32');
end
fwrite(fid,order,'ubit3');
%------------------------------------------
nbTN = length(tn_of_TREE);
[dummy,bitLEN] = log2(max(tn_of_TREE)); %#ok<ASGLU>
if bitLEN==0 , bitLEN = 1; end
saveFORMAT = ['ubit' int2str(bitLEN)];
fwrite(fid,nbTN,'uint16');
fwrite(fid,bitLEN,'uint8');
fwrite(fid,tn_of_TREE,saveFORMAT);
%------------------------------------------
type_of_DATA = rwTypeOfData('save',type_of_DATA);
fwrite(fid,type_of_DATA,'uint8');
fwrite(fid,size_of_DATA,'uint16');    
%------------------------------------------ 
nbCHAR = length(WT_Settings.typeWT);
fwrite(fid,nbCHAR,'ubit4');
fwrite(fid,WT_Settings.typeWT,'uint8');
nbCHAR = length(WT_Settings.wname);
fwrite(fid,nbCHAR,'ubit4');
fwrite(fid,WT_Settings.wname,'uint8');
nbCHAR = length(WT_Settings.extMode);
fwrite(fid,nbCHAR,'ubit4');
fwrite(fid,WT_Settings.extMode,'uint8');
fwrite(fid,WT_Settings.shift,'ubit2');
%------------------------------------------
fwrite(fid,nb_C,'uint32');
fwrite(fid,Max_C,'uint16');
fwrite(fid,R0,'uint32');    
fwrite(fid,nb_CLASSES,'uint8');
%------------------------------------------
fwrite(fid,len_Idx,'uint32');
if len_Idx<nb_C
    [dummy,bitLEN] = log2(max(idx_NZ)); %#ok<ASGLU>
    nb_CODED_IDX = length(idx_NZ);
    COUNT_1 = bitLEN*nb_CODED_IDX; %#ok<NASGU> % Under Consideration
    fwrite(fid,bitLEN,'uint8');
    fwrite(fid,First_Idx,'uint32');
    mode_Save_IDX = 2;  % Under Consideration
    if mode_Save_IDX==1
        [TabCODE_IDX,HCTab_IDX] = whuffencode(idx_NZ+1);
        nb_CODED_IDX = length(idx_NZ);
        nb_HC_IDX = length(HCTab_IDX);
        len_TabCODE_IDX = length(TabCODE_IDX);
        fwrite(fid,nb_CODED_IDX,'uint32');
        fwrite(fid,nb_HC_IDX,'uint16');
        fwrite(fid,HCTab_IDX,'ubit2');
        fwrite(fid,len_TabCODE_IDX,'uint32');
        fwrite(fid,TabCODE_IDX,'ubit1');
        COUNT_2 = 32 + 16 + 2*nb_HC_IDX + 32 + len_TabCODE_IDX; %#ok<NASGU>  
        % Under Consideration
    else
        saveFORMAT = ['ubit' int2str(bitLEN)];   
        fwrite(fid,idx_NZ,saveFORMAT);
    end
end
%------------------------------------------
fwrite(fid,minE,'uint16');
%------------------------------------------
switch codeID
    case 'h'    % Huffmann Coding
        nb_HC = length(HCTab);
        len_TabCODE = length(TabCODE);
        try %#ok<TRYNC>
            fwrite(fid,nb_CODED,'uint32');
            fwrite(fid,nb_HC,'uint16');
            fwrite(fid,HCTab,'ubit2');
            fwrite(fid,len_TabCODE,'uint32');
            fwrite(fid,TabCODE,'ubit1');
            fwrite(fid,signCFS,'ubit1');
        end

    case 'f'    % Fixed length coding
        [dummy,bitLEN] = log2(max(TabCODE)); %#ok<ASGLU>
        saveFORMAT = ['ubit' int2str(bitLEN)];
        fwrite(fid,bitLEN,'uint8');                
        fwrite(fid,nb_CODED,'uint32');
        fwrite(fid,TabCODE,saveFORMAT);
        fwrite(fid,signCFS,'ubit1');
end
try fclose(fid); end %#ok<TRYNC>
modify_wtcfile('save',filename,typeSAVE)
if nargout>0
    fid = fopen(filename);
    [dummy,count] = fread(fid); %#ok<ASGLU>
    fclose(fid);
end
%=======================================================================%
function gbl_mmc_Cell = gbl_mmc_load(typeSAVE,filename)
%GBL_MMC_LOAD Load Max Module Code (Huffman or fixed encoding).
%   GBL_MMC_LOAD(FILENAME,TYPECODE,VARARGIN)

% File settings.
%---------------
tmp_filename  = def_tmpfile(filename);
ok_TMP = exist(tmp_filename,'file');
if ok_TMP
    fid = fopen(tmp_filename);
else
    fid = fopen(filename);
end
codeID = fread(fid,1,'*char');
typeCODE = wtcmngr('meth_name',typeSAVE,codeID);
%------------------------------------------    
% saveCODE = fread(fid,1,'ubit1');
% switch saveCODE
%     case 0 , tmp = '2';
%     case 1 , tmp = '1';
% end
% codeMAIN = wtcmngr('meth_name',codeID);
% typeCODE = [codeMAIN];
%------------------------------------------  
codeCOL = fread(fid,1,'ubit3');
ColType = wimgcolconv(codeCOL);
if isequal(codeCOL,2)
    ColMAT = fread(fid,9,'float32');
    ColMAT = reshape(ColMAT,3,3);
else
    ColMAT = [];
end
%------------------------------------------
order = fread(fid,1,'ubit3');
%------------------------------------------
nbTN = fread(fid,1,'uint16');
bitLEN = fread(fid,1,'uint8');
saveFORMAT = ['ubit' int2str(bitLEN)];
tn_of_TREE = fread(fid,nbTN,saveFORMAT);
%------------------------------------------
type_of_DATA = fread(fid,1,'uint8')';
type_of_DATA = rwTypeOfData('load',type_of_DATA);
size_of_DATA = fread(fid,2,'uint16')';
%------------------------------------------
nbCHAR = fread(fid,1,'ubit4');
typeWT = fread(fid,nbCHAR,'*char')';
nbCHAR = fread(fid,1,'ubit4');
wname  = fread(fid,nbCHAR,'*char')';
nbCHAR = fread(fid,1,'ubit4');
extMode = fread(fid,nbCHAR,'*char')';
shift = fread(fid,2,'ubit2');
shift = double(shift)';
WT_Settings = struct(...
    'typeWT',typeWT,'wname',wname,...
    'extMode',extMode,'shift',shift);
%------------------------------------------    
nb_C  = fread(fid,1,'uint32');
Max_C = fread(fid,1,'uint16');
R0 = fread(fid,1,'uint32');    
nb_CLASSES = fread(fid,1,'uint8');
%------------------------------------------
len_Idx = fread(fid,1,'uint32');
if len_Idx<nb_C
    bitLEN = fread(fid,1,'uint8');
    First_Idx = fread(fid,1,'uint32');
    mode_Save_IDX = 2;  % Under Consideration
    if mode_Save_IDX==1
        nb_CODED_IDX = fread(fid,1,'uint32');
        nb_HC_IDX = fread(fid,1,'uint16');
        HCTab_IDX = fread(fid,nb_HC_IDX,'ubit2');
        len_TabCODE_IDX = fread(fid,1,'uint32');
        TabCODE_IDX = fread(fid,len_TabCODE_IDX,'ubit1');
        idx_NZ = whuffdecode(HCTab_IDX,TabCODE_IDX,nb_CODED_IDX) - 1;
    else
        saveFORMAT = ['ubit' int2str(bitLEN)];
        nb_Idx = len_Idx-First_Idx+1;
        idx_NZ = fread(fid,nb_Idx,saveFORMAT);
    end
else
    First_Idx = 1;  idx_NZ = 0;
end
Dat_Par = {order , tn_of_TREE , type_of_DATA , size_of_DATA , WT_Settings};
Cfs_Par = {nb_C , Max_C , R0 , nb_CLASSES};
Idx_Par = {len_Idx , First_Idx , idx_NZ};
%-----------------------------------------------------------
minE = fread(fid,1,'uint16');
switch codeID
    case 'h'    % Huffmann Coding
        nb_CODED = fread(fid,1,'uint32');
        nb_HC    = fread(fid,1,'uint16');
        HCTab    = fread(fid,nb_HC,'ubit2');
        len_TabCODE = fread(fid,1,'uint32');
        TabCODE  = fread(fid,len_TabCODE,'ubit1');
        signCFS  = fread(fid,len_Idx,'ubit1')';
        Cod_Par = {minE , nb_CODED , TabCODE , signCFS , HCTab};

    case 'f'    % Fixed length coding
        bitLEN   = fread(fid,1,'uint8');
        saveFORMAT = ['ubit' int2str(bitLEN)];
        nb_CODED = fread(fid,1,'uint32');
        TabCODE  = fread(fid,nb_CODED,saveFORMAT);
        signCFS  = fread(fid,nb_CODED,'ubit1')';        
        Cod_Par  = {minE , nb_CODED , TabCODE , signCFS};
end
%-----------------------------------------------------------
gbl_mmc_Cell = {typeCODE,ColType,ColMAT,Dat_Par,Cfs_Par,Idx_Par,Cod_Par};
%------------------------------------------------------------
fclose(fid);
if ok_TMP , delete(tmp_filename); end
%=======================================================================%
function varargout = ...
    gbl_mmc_quantize(option,typeCODE,C,threshold,nb_CLASSES)

switch lower(option)
    case 'encode' , flag_Quantize = false; flag_Edges = false;
    case 'edges'  , flag_Quantize = false; flag_Edges = true;
    otherwise     , flag_Quantize = true;  flag_Edges = false;
end

% Coefficients properties.
%-------------------------
precision = 1E-11;
nb_C   = length(C);
Max_C  = max(abs(C))*(1+precision);
R0 = ceil(Max_C/threshold);
typeBOUNDS = typeCODE(end);
if ~isequal(typeBOUNDS,'1') && ~isequal(typeBOUNDS,'2')
    typeBOUNDS = '2';
end
switch typeBOUNDS
    case {'1'}
        delta_C = Max_C/nb_CLASSES;
        delta_0 = delta_C;
    case {'2'}
        delta_0 = Max_C/R0;
        delta_C = (Max_C-delta_0)/nb_CLASSES;
end
EDGES_C = [0,delta_0:delta_C:Max_C];
if flag_Edges 
    varargout{1} = EDGES_C; 
    return; 
end

% Thresholding the coefficients.
%-------------------------------
D = C;
D(abs(D)<=threshold) = 0;

% Compression Computation.
%-------------------------
j = find(abs(D)>0);
len_Idx = length(j);
K = [j(1) , diff(j)]-1;
First_Idx = find(K>0);
alpha = 0.15;  % alpha = 0.5;
if ~isempty(First_Idx)
    First_Idx = First_Idx(1);
    if (len_Idx-First_Idx+1) < alpha*nb_C
        idx_NZ = K(First_Idx:end); E = D(j);
    else
        len_Idx = nb_C; First_Idx = 1; idx_NZ = 0; E = D;
    end
else
    First_Idx = length(K) ; idx_NZ = 0;  E = D(j);
end

% Coding the coefficients.
%-------------------------
Cfs_Par = {nb_C , Max_C , R0 , nb_CLASSES};
Idx_Par = {len_Idx , First_Idx , idx_NZ};
signCFS = (E>0);
E = abs(E);
[E_COUNT,E_BINS] = histc(E,EDGES_C); %#ok<ASGLU>

if flag_Quantize
    Qcent = 0.5*(EDGES_C(1:end-1)+ EDGES_C(2:end));
    Qval = Qcent(E_BINS);
    sgnE = ones(size(signCFS));
    sgnE(signCFS==0) = -1;
    if ~isequal(size(E),size(D))
        D(j) = sgnE.*Qval;
    else
        D = sgnE.*Qval;
    end
    varargout{1} = D;
else
    minE = min(E_BINS);
    to_ENCODE = E_BINS - minE + 1;
    nb_CODED = length(to_ENCODE);
    Cod_Par = {minE , nb_CODED , to_ENCODE , signCFS};
    varargout = {Cfs_Par,Idx_Par,Cod_Par};
end
%=======================================================================%
function D = gbl_mmc_unquantize(typeCODE,Cfs_Par,Idx_Par,Cod_Par)
%GBL_MMC_UNQUANTIZE

[nb_C , Max_C , R0, nb_CLASSES] = deal(Cfs_Par{:});
[len_Idx , First_Idx , idx_NZ]  = deal(Idx_Par{:});
[minE , nb_CODED , E , signCFS] = deal(Cod_Par{:}); %#ok<ASGLU>
E = E + minE - 1;

typeBOUNDS = typeCODE(end);
if ~isequal(typeBOUNDS,'1') && ~isequal(typeBOUNDS,'2')
    typeBOUNDS = '2';
end
switch typeBOUNDS
    case {'1'}
        delta_C = Max_C/nb_CLASSES;
        delta_0 = delta_C;
    case {'2'}
        delta_0 = Max_C/R0;
        delta_C = (Max_C-delta_0)/nb_CLASSES;
end
EDGES_C = [0,delta_0:delta_C:Max_C];
val_C   = 0.5*(EDGES_C(1:end-1) + EDGES_C(2:end));
signCFS(signCFS==0) = -1;
if len_Idx<nb_C
    idx_C = zeros(1,len_Idx);
    idx_C(First_Idx:end) = idx_NZ;
    D = zeros(1,nb_C);
    Ind = cumsum(idx_C+1);
    D(Ind)  = val_C(E).*signCFS;
else
    D = val_C(E).*signCFS;
end
%=======================================================================%
function OUT = rwTypeOfData(option,IN)
switch option
    case 'load' 
        switch IN
            case 1 , OUT = '1d';               
            case 2 , OUT = '2d';         
            case 3 , OUT = '2d3';         
        end
    case 'save'
        switch IN
            case '1d'  , OUT = 1;               
            case '2d'  , OUT = 2;         
            case '2d3' , OUT = 3;         
        end        
end
%=======================================================================%
