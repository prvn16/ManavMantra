function varargout = wtc_lvl_mmc(option,typeSAVE,varargin)
%WTC_LVL_MMC Max Module Code (Huffman or fixed encoding).
%   VARARGOUT = WTC_LVL_MMC(OPTION,VARARGIN)
%
%   WTC_LVL_MMC('encode',CFS,sizeCFS,level,wname,modeDWT,Per_Kept_Cfs)
%     or
%   WTC_LVL_MMC('encode',X,level,wname,modeDWT,Per_Kept_Cfs)
%
%   WTC_LVL_MMC('decode',...)
%   WTC_LVL_MMC('save',...)
%   WTC_LVL_MMC('load',...)
%   WTC_LVL_MMC('quantize',...)
%   WTC_LVL_MMC('unquantize',...)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Jun-2004.
%   Last Revision 06-May-2009.
%   Copyright 1995-2009 The MathWorks, Inc.


% Initialization of constants.
%----------------------------
newCFS_ORDER   = false; % Reorder Cfs. Flag.
prop_Store_Idx = 1.25;  
nbCHAR = 1;             % Nb of significant letters for "option"
validOPTION = {'encode','decode','save','load','quantize','unquantize'};

numOPT = find(strncmpi(option,validOPTION,nbCHAR));
nbout = nargout;
switch numOPT
    %----- 'encode' -----%
    case 1 , [varargout{1:nbout}] = lvl_mmc_enc(varargin{:});
        %----- 'decode' -----%
    case 2 , [varargout{1:nbout}] = lvl_mmc_dec(varargin{:});
        %------ 'save' ------%
    case 3 , [varargout{1:nbout}] = lvl_mmc_save(typeSAVE,varargin{:});
        %------ 'load' ------%
    case 4 , [varargout{1:nbout}] = lvl_mmc_load(typeSAVE,varargin{:});
        %---- 'quantize' ----%
    case 5 , [varargout{1:nbout}] = lvl_mmc_quantize(varargin{:});
        %--- 'unquantize' ---%
    case 6 , [varargout{1:nbout}] = lvl_mmc_unquantize(varargin{:});
end


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function lvl_mmc_Cell = lvl_mmc_enc(varargin)
        %LVL_MMC_ENC
        %   LVL_MMC('encode',CFS,sizeCFS,level,wname,modeDWT,...
        %                    Per_Kept_Cfs,ColType)
        %     or
        %   LVL_MMC('encode',X,level,wname,modeDWT,Per_Kept_Cfs,ColType)

        % Check inputs.
        %--------------
        if length(varargin)==1 ,  varargin = varargin{1}; end
        nbin = length(varargin);
        switch nbin
            case 4
                X = varargin{1};
                [level,wname,modeDWT]  = deal(varargin{2}{:});  %#ok<NASGU>
                methodParams = varargin{3};
                ColType      = varargin{4};
                bpp          = methodParams;
                modeDWT      = 'per';   % Force periodization for the DWT.
                
            case 7
                [CFS,sizeCFS,level,wname,modeDWT,bpp,ColType] = ...
                    deal(varargin{:});
        end

        % Compute 'Local_BPP_Rate'
        %-------------------------
        flagEXP_Curve = false;
        if ~flagEXP_Curve
            if isnumeric(methodParams)
                comprat = 100*bpp/(8*size(X,3));
            elseif isstruct(methodParams)
                fn = fieldnames(methodParams);
                idx = find(strcmp(fn,'comprat'));
                if ~isempty(idx)
                    comprat = methodParams.(fn{idx});
                else
                    idx = find(strcmp(fn,'bpp'));
                    if ~isempty(idx)
                        bpp = methodParams.(fn{idx});
                        comprat = 100*bpp/(8*size(X,3));
                    end
                end
            end
            [xval,yval] = getcompresspar('lvl_mmc' );
            [mini,idx] = min(abs(yval-comprat));
            bpp_Rate = xval(idx);
        else
            bpp_Rate = methodParams;
        end

        if nbin==4  % 
            old_modeDWT = dwtmode('status','nodisp');
            dwtmode(modeDWT,'nodisp');
            [X,ColMAT]    = wimgcolconv(ColType,X);
            [CFS,sizeCFS] = wavedec2(X,level,wname);
            dwtmode(old_modeDWT,'nodisp');
        end
               
        Header.Size = sizeCFS(end,:);
        Header.ColType = ColType;
        Header.ColMAT = ColMAT;
        WT_Settings = struct(...
            'typeWT','dwt', ...
            'wname',wname,'level',level, ...
            'extMode',modeDWT,'shift',0);
        
        % [X,ColMAT] = wimgcolconv(ColType,X);
        % T = wdectree(X,2,level,WT_Settings);
        % [order,tn_of_TREE,WT_Settings] = get(T,'order','tn','WT_Settings');
        % [size_of_DATA,C] = read(T,'sizes',0,'data');

        %-------------------------------------------------------------
        % Info_cod_SubBand{1,:}  <== siz_SubBand
        % Info_cod_SubBand{2,:}  <== len_SubBand
        % Info_cod_SubBand{3,:}  <== stp_Qtz_SubBand
        % Info_cod_SubBand{4,:}  <== mul_Qtz_SubBand
        % Info_cod_SubBand{5,:}  <== min_SubBand
        % Info_cod_SubBand{6,:}  <== nb_CODED ( <==> len_Idx)
        % info_cod_SubBand{7,:}  <== First_Idx
        % Info_cod_SubBand{8,:}  <== idx_NZ
        % Info_cod_SubBand{9,:}  <== to_ENCODE or TabCODE
        % Info_cod_SubBand{10,:} <== signCFS
        % Info_cod_SubBand{11,:} <== HCTab
        %-------------------------------------------------------------

        % %################################
        % % MatCFS = wcfs2mat(CFS,sizeCFS);
        % CFS = reshape(1:16,4,4);
        % CFS = CFS(:)';
        % %################################

        % Compute Quantization Parameters.
        %---------------------------------
        Nb_SubBand = 3*level + 1;
        Info_cod_SubBand = cell(11,Nb_SubBand);
        [stp_Qtz_SubBand,siz_SubBand,len_SubBand] = ...
            quantize_params(CFS,bpp_Rate,sizeCFS);
        % Info_cod_SubBand(1,:) = mat2cell(siz_SubBand,ones(1,Nb_SubBand),2);
        Info_cod_SubBand(1,:) = ...
            mat2cell(siz_SubBand,ones(1,Nb_SubBand),size(siz_SubBand,2));
        Info_cod_SubBand(2,:) = num2cell(len_SubBand);
        Info_cod_SubBand(3,:) = num2cell(stp_Qtz_SubBand);

        % Quantization.
        %--------------
        [Info_cod_SubBand,Nb_Kept_Cfs] = ...
            lvl_mmc_quantize(CFS,Info_cod_SubBand);

        % Encoding.
        %----------
        for idx_Sub = 2:Nb_SubBand
            to_ENCODE = Info_cod_SubBand{9,idx_Sub};
            if ~isempty(to_ENCODE)
                HC_Struct = whuffencode(to_ENCODE);
                Info_cod_SubBand([9,11],idx_Sub) = ...
                    {HC_Struct.HC_tabENC;HC_Struct.HC_codes};
            end
        end
        lvl_mmc_Cell = {Info_cod_SubBand,Nb_Kept_Cfs,WT_Settings,Header};
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function [Xrec,CFS_QUA] = lvl_mmc_dec(lvl_mmc_Cell,varargin)
        %LVL_MMC_DEC Decode Max Module Code (Huffman or fixed encoding).
        %   LVL_MMC_DEC(FILENAME,TYPECODE,VARARGIN)

        % Check inputs.
        %--------------
        [Info_cod_SubBand,Nb_Kept_Cfs,WT_Settings,Header] = ...
            deal(lvl_mmc_Cell{:}); %#ok<ASGLU>

        Nb_SubBand = size(Info_cod_SubBand,2);
        for idx_Sub = 1:Nb_SubBand
            to_DECODE = Info_cod_SubBand{9,idx_Sub};
            if ~isempty(to_DECODE)
                HCTab    = Info_cod_SubBand{11,idx_Sub};
                nb_CODED = Info_cod_SubBand{6,idx_Sub};
                minE     = Info_cod_SubBand{5,idx_Sub};
                if idx_Sub>1
                    to_DECODE = whuffdecode(HCTab,to_DECODE,nb_CODED);
                end
                to_DECODE = to_DECODE + minE - 1;
                Info_cod_SubBand{9,idx_Sub} = to_DECODE;
            end
        end
        CFS_QUA = lvl_mmc_unquantize(Info_cod_SubBand);
        sizeMAT = Header.Size;
        ColType = Header.ColType;
        ColMAT  = Header.ColMAT;
        wname = WT_Settings.wname;
        level = WT_Settings.level;
        modeDWT = WT_Settings.extMode;
        sizeCFS = get_size2d(sizeMAT,wname,level,modeDWT);
        old_modeDWT = dwtmode('status','nodisp');
        dwtmode(modeDWT,'nodisp');
        Xrec = waverec2(CFS_QUA,sizeCFS,wname);
        Xrec = wimgcolconv(['inv' ColType],Xrec,ColMAT);
        if ndims(Xrec)>2 , Xrec = uint8(Xrec); end        
        dwtmode(old_modeDWT,'nodisp');
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function count = lvl_mmc_save(typeSAVE,filename,lvl_mmc_Cell)
        %LVL_MMC_SAVE Save Max Module Code (Huffman or fixed encoding).
        %   COUNT = LVL_MMC_SAVE(FILENAME,LVL_MMC_CELL)

        % File settings.
        %---------------
        tmp_filename  = def_tmpfile(filename);
        fid = fopen(tmp_filename,'wb');

        % Check inputs.
        %--------------
        [Info_cod_SubBand,Nb_Kept_Cfs,WT_Settings,Header] = ...
            deal(lvl_mmc_Cell{:}); %#ok<ASGLU>

        % Begin Saving.
        %--------------
        codeID = wtcmngr('meth_ident',typeSAVE,'lvl_mmc');
        fwrite(fid,codeID,'ubit8');
        if length(Header.Size)<3 , Header.Size(3) = 1; end
        fwrite(fid,Header.Size,'uint16');
        codeCOL = wimgcolconv(Header.ColType);
        fwrite(fid,codeCOL,'ubit3');
        if isequal(codeCOL,2)
            fwrite(fid,Header.ColMAT,'float32');
        end
        nbCHAR = length(WT_Settings.typeWT);
        fwrite(fid,nbCHAR,'ubit4');
        fwrite(fid,WT_Settings.typeWT,'uint8');
        nbCHAR = length(WT_Settings.wname);
        fwrite(fid,nbCHAR,'ubit4');
        fwrite(fid,WT_Settings.wname,'uint8');
        fwrite(fid,WT_Settings.level,'uint8');
        nbCHAR = length(WT_Settings.extMode);
        fwrite(fid,nbCHAR,'ubit4');
        fwrite(fid,WT_Settings.extMode,'uint8');
        fwrite(fid,WT_Settings.shift,'ubit2');
        %---------------------------------------
        %---------------------------------------------------------
        % max_stp_Qtz   = max(cat(1,Info_cod_SubBand{3,:}));
        
        % the_Max = cat(1,Info_cod_SubBand{4,:});
        % the_Max = the_Max(isfinite(the_Max));
        % max_mul_Qtz   = max(the_Max);
        
        max_mul_Qtz   = max(cat(1,Info_cod_SubBand{4,:}));        
        max_minE      = max(cat(1,Info_cod_SubBand{5,:}));
        max_len_Idx   = max(cat(1,Info_cod_SubBand{6,:}));
        max_First_Idx = max(cat(1,Info_cod_SubBand{7,:}));
        % max_idx_NZ    = max(cat(2,Info_cod_SubBand{8,:}));
        max_VAL = max([max_mul_Qtz , max_minE , max_len_Idx ,max_First_Idx]);
        [dummy,max_BITLEN] = log2(max_VAL); %#ok<ASGLU>
        save_MAX_FORMAT = ['ubit' int2str(max_BITLEN)];
        fwrite(fid,max_BITLEN,'uint8');
        %---------------------------------------------------------
        Nb_SubBand = size(Info_cod_SubBand,2);
        for idx_Sub = 1:Nb_SubBand
            len_Idx = Info_cod_SubBand{6,idx_Sub};
            %-----------------------------------
            fwrite(fid,len_Idx,'uint32');
            if len_Idx>0
                stp_Qtz   = Info_cod_SubBand{3,idx_Sub};
                mul_Qtz   = Info_cod_SubBand{4,idx_Sub};
                minE      = Info_cod_SubBand{5,idx_Sub};
                First_Idx = Info_cod_SubBand{7,idx_Sub};
                idx_NZ    = Info_cod_SubBand{8,idx_Sub};
                TabCODE   = Info_cod_SubBand{9,idx_Sub};
                signCFS   = Info_cod_SubBand{10,idx_Sub};
                HCTab     = Info_cod_SubBand{11,idx_Sub};
                len_TabCODE = length(TabCODE);
                nb_HC     = length(HCTab);
                fwrite(fid,mul_Qtz,save_MAX_FORMAT);
                fwrite(fid,stp_Qtz,'float32');
                if ~isempty(idx_NZ)
                    [dummy,bitLEN] = log2(max(idx_NZ)); %#ok<ASGLU>
                    fwrite(fid,bitLEN,'uint8');
                    saveFORMAT = ['ubit' int2str(bitLEN)];
                    nb_idx_NZ  = length(idx_NZ);
                    fwrite(fid,First_Idx,save_MAX_FORMAT);
                    fwrite(fid,nb_idx_NZ,save_MAX_FORMAT);
                    fwrite(fid,idx_NZ,saveFORMAT);
                else
                    bitLEN = 0;
                    fwrite(fid,bitLEN,'uint8');
                end
                fwrite(fid,minE,save_MAX_FORMAT);
                if idx_Sub>1
                    fwrite(fid,nb_HC,'uint16');
                    fwrite(fid,HCTab,'ubit2');
                    fwrite(fid,len_TabCODE,'uint32');
                    fwrite(fid,TabCODE,'ubit1');
                else
                    max_VAL = max(TabCODE);
                    [dummy,bitLEN] = log2(max_VAL); %#ok<ASGLU>
                    save_FORMAT = ['ubit' int2str(bitLEN)];
                    fwrite(fid,bitLEN,'uint8');
                    fwrite(fid,TabCODE,save_FORMAT);
                end
                fwrite(fid,signCFS,'ubit1');
            end
            %-----------------------------------
        end
        fclose(fid);
        modify_wtcfile('save',filename,typeSAVE)
        if nargout>0
            fid = fopen(filename);
            [dummy,count] = fread(fid); %#ok<ASGLU>
            fclose(fid);
        end
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function lvl_mmc_Cell = lvl_mmc_load(typeSAVE,filename)
        %LVL_MMC_LOAD Load Max Module Code (Huffman or fixed encoding).
        %   LVL_MMC_LOAD(FILENAME)

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
        typeCODE = wtcmngr('meth_name',typeSAVE,codeID); %#ok<NASGU>  % Not used
        Header.Size = fread(fid,3,'uint16')';
        codeCOL = fread(fid,1,'ubit3');
        Header.ColType = wimgcolconv(codeCOL);
        if isequal(codeCOL,2)
            ColMAT = fread(fid,9,'float32');
            Header.ColMAT = reshape(ColMAT,3,3);
        else
            Header.ColMAT = [];
        end
        nbCHAR  = fread(fid,1,'ubit4');
        typeWT  = fread(fid,nbCHAR,'uint8=>char')';
        nbCHAR  = fread(fid,1,'ubit4');
        wname   = fread(fid,nbCHAR,'uint8=>char')';
        level   = fread(fid,1,'uint8');
        nbCHAR  = fread(fid,1,'ubit4');
        extMode = fread(fid,nbCHAR,'uint8=>char')';
        shift   = fread(fid,1,'ubit2'); %#ok<NASGU>
        WT_Settings = struct(...
            'typeWT',typeWT, ...
            'wname',wname,'level',level, ...
            'extMode',extMode,'shift',0);

        Nb_SubBand  = 3*level+1;
        sizeCFS = get_size2d(Header.Size,wname,level,extMode);
        len_SubBand = zeros(1,Nb_SubBand);
        siz_SubBand = prod(sizeCFS,2);
        idx_IDX = zeros(1,Nb_SubBand);
        idx_IDX(1) = 1;
        idx_Var = 2;
        for lev = 2:level+1
            idx_IDX(idx_Var:idx_Var+2) = lev;
            idx_Var = idx_Var + 3;
        end
        len_SubBand(:) = siz_SubBand(idx_IDX);
        nb_COL_SIZE = size(sizeCFS,2);
        Info_cod_SubBand(1,:) = ...
            mat2cell(sizeCFS(idx_IDX,:),ones(1,Nb_SubBand),nb_COL_SIZE);
        Info_cod_SubBand(2,:) = num2cell(len_SubBand);

        max_BITLEN = fread(fid,1,'uint8');
        load_MAX_FORMAT = ['ubit' int2str(max_BITLEN)];
        for idx_Sub = 1:Nb_SubBand
            nb_CODED = fread(fid,1,'uint32');
            Info_cod_SubBand{6,idx_Sub} = nb_CODED;
            if nb_CODED>0
                Info_cod_SubBand{4,idx_Sub} = fread(fid,1,load_MAX_FORMAT);
                Info_cod_SubBand{3,idx_Sub} = fread(fid,1,'float32');
                bitLEN  = fread(fid,1,'uint8');
                if bitLEN>0
                    saveFORMAT = ['ubit' int2str(bitLEN)];
                    Info_cod_SubBand{7,idx_Sub} = fread(fid,1,load_MAX_FORMAT);
                    nb_idx_NZ = fread(fid,1,load_MAX_FORMAT);
                    Info_cod_SubBand{8,idx_Sub} = fread(fid,nb_idx_NZ,saveFORMAT)';
                end
                Info_cod_SubBand{5,idx_Sub} = fread(fid,1,load_MAX_FORMAT);

                if idx_Sub>1
                    nb_HC = fread(fid,1,'uint16');
                    Info_cod_SubBand{11,idx_Sub} = fread(fid,nb_HC,'ubit2')';
                    len_TabCODE = fread(fid,1,'uint32');
                    Info_cod_SubBand{9,idx_Sub} = fread(fid,len_TabCODE,'ubit1');
                else
                    bitLEN  = fread(fid,1,'uint8');
                    load_FORMAT = ['ubit' int2str(bitLEN)];
                    Info_cod_SubBand{9,idx_Sub} = fread(fid,nb_CODED,load_FORMAT);
                end
                Info_cod_SubBand{10,idx_Sub} = fread(fid,nb_CODED,'ubit1')';
            end
        end
        fclose(fid);
        if ok_TMP , delete(tmp_filename); end
        Nb_Kept_Cfs = sum(cat(1,Info_cod_SubBand{6,:}));
        lvl_mmc_Cell = {Info_cod_SubBand,Nb_Kept_Cfs,WT_Settings,Header};
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


%=======================================================================%
    function [Info_cod_SubBand,Nb_Kept_Cfs] = ...
       lvl_mmc_quantize(CFS,Info_cod_SubBand)
        %LVL_MMC_QUANTIZE

        % Check inputs.
        %--------------
        Nb_SubBand = size(Info_cod_SubBand,2);
        idx_end_CFS = 0;
        for idx_Sub = 1:Nb_SubBand
            len_Sub = Info_cod_SubBand{2,idx_Sub};
            idx_beg_CFS = idx_end_CFS + 1;
            idx_end_CFS = idx_beg_CFS + len_Sub - 1;
            C = CFS(idx_beg_CFS:idx_end_CFS);
            if (idx_Sub>1) && newCFS_ORDER
                remVAL = rem(idx_Sub,3);
                if remVAL==2;
                    siz_Sub = Info_cod_SubBand{1,idx_Sub};
                    [H_Ord,D_Ord] = dwt2_cfs_order('dir',siz_Sub);
                end
                switch remVAL
                    case 2 , C = C(H_Ord);
                    case 1 , C = C(D_Ord);
                end
            elseif (idx_Sub==1) && newCFS_ORDER
                siz_Sub = Info_cod_SubBand{1,idx_Sub};
                [H_Ord,D_Ord] = dwt2_cfs_order('dir',siz_Sub);
                C = C(D_Ord);
            end
            [to_ENCODE,signCFS,mul_Qtz,minE,Idx_Info] = ...
                quantize_OneSubBand(C,Info_cod_SubBand{3,idx_Sub});
            if ~isempty(to_ENCODE)
                Info_cod_SubBand(9:10,idx_Sub) = {to_ENCODE;signCFS};
            end
            Info_cod_SubBand{4,idx_Sub} = mul_Qtz;
            Info_cod_SubBand{5,idx_Sub} = minE;
            Info_cod_SubBand(6:8,idx_Sub) = Idx_Info;
        end
        Nb_Kept_Cfs = sum(cat(1,Info_cod_SubBand{6,:}));
    end
%=======================================================================%


%=======================================================================%
    function [to_ENCODE,signCFS,mul_Qtz,minE,Idx_Info] = ...
            quantize_OneSubBand(C,stp_Qtz)

        % Coefficients properties.
        %-------------------------
        precision = 0.1;
        mul_THRES = 1;
        Max_C = max(abs(C)) + precision;
        nb_C  = length(C);
        threshold = mul_THRES*stp_Qtz;
        mul_Qtz = ceil(Max_C/stp_Qtz);
        EDGES_C = [0,threshold:stp_Qtz:mul_Qtz*stp_Qtz];

        % Thresholding the coefficients.
        %-------------------------------
        D = C;
        D(abs(D)<=threshold) = 0;

        % Compression Computation.
        %-------------------------
        j = find(abs(D)>0);
        len_Idx = length(j);
        if len_Idx==0
            to_ENCODE = [];
            signCFS   = [];
            minE      = 0;
            Idx_Info  = {len_Idx;0;[]};
            return;
        end

        K = [j(1) , diff(j)]-1;
        First_Idx = find(K>0);
        if ~isempty(First_Idx)
            First_Idx = First_Idx(1);
            if (len_Idx-First_Idx+1) < prop_Store_Idx*nb_C
                idx_NZ = K(First_Idx:end); E = D(j);
            else
                len_Idx = nb_C; First_Idx = 1; idx_NZ = []; E = D;
            end
        else
            First_Idx = 1 ; idx_NZ = [];  E = D(j);
        end
        Idx_Info = {len_Idx;First_Idx;idx_NZ};

        % Coding the coefficients.
        %-------------------------
        signCFS = (E>0);
        E = abs(E);
        [E_COUNT,E_BINS] = histc(E,EDGES_C); %#ok<ASGLU>
        minE = min(E_BINS);
        to_ENCODE = E_BINS - minE + 1;
    end
%=======================================================================%


%=======================================================================%
    function CFS_QUA = lvl_mmc_unquantize(Info_cod_SubBand)
        %LVL_MMC_UNQUANTIZE

        mul_THRES = 1;
        Nb_SubBand = size(Info_cod_SubBand,2);
        idx_end_CFS = 0;
        len_Of_Cfs = sum(cat(1,Info_cod_SubBand{2,:}));
        CFS_QUA = zeros(1,len_Of_Cfs);
        for idx_Sub = 1:Nb_SubBand
            len_Sub   = Info_cod_SubBand{2,idx_Sub};
            idx_beg_CFS = idx_end_CFS + 1;
            idx_end_CFS = idx_beg_CFS + len_Sub - 1;
            TabCODE   = Info_cod_SubBand{9,idx_Sub};
            if ~isempty(TabCODE)
                stp_Qtz   = Info_cod_SubBand{3,idx_Sub};
                mul_Qtz   = Info_cod_SubBand{4,idx_Sub};
                % minE      = Info_cod_SubBand{5,idx_Sub};
                len_Idx   = Info_cod_SubBand{6,idx_Sub};
                First_Idx = Info_cod_SubBand{7,idx_Sub};
                idx_NZ    = Info_cod_SubBand{8,idx_Sub};
                
                signCFS = Info_cod_SubBand{10,idx_Sub};
                signCFS = double(signCFS);
                signCFS(signCFS==0) = -1;
                threshold = mul_THRES*stp_Qtz;
                EDGES_C = [0,threshold:stp_Qtz:mul_Qtz*stp_Qtz];
                val_C   = 0.5*(EDGES_C(1:end-1) + EDGES_C(2:end));
                if len_Idx<len_Sub  
                    
                    if ~isempty(idx_NZ) %#######
                        idx_C = zeros(1,len_Idx);
                        idx_C(First_Idx:end) = idx_NZ;
                        Ind = cumsum(idx_C+1);
                    else
                        Ind = First_Idx:First_Idx+len_Idx-1;
                    end
                    C = zeros(1,len_Sub); 
                    if ~isempty(Ind)
                        C(Ind) = val_C(TabCODE).*signCFS;
                    end
                else
                    % C = val_C(TabCODE).*signCFS;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if TabCODE>0
                        C  = val_C(TabCODE).*signCFS;
                    else
                        C = 0;
                    end
                end

                if (idx_Sub>1) && newCFS_ORDER
                    remVAL = rem(idx_Sub,3);
                    if remVAL==2;
                        siz_Sub = Info_cod_SubBand{1,idx_Sub};
                        [RH_Ord,RD_Ord] = dwt2_cfs_order('rev',siz_Sub);
                    end
                    switch remVAL
                        case 2 , C = C(RH_Ord);
                        case 1 , C = C(RD_Ord);
                    end
                elseif (idx_Sub==1) && newCFS_ORDER
                    siz_Sub = Info_cod_SubBand{1,idx_Sub};
                    [RH_Ord,RD_Ord] = dwt2_cfs_order('rev',siz_Sub);
                    C = C(RD_Ord);
                end
                CFS_QUA(idx_beg_CFS:idx_end_CFS) = C;
            end
        end
        %=============================================================%
    end
%=======================================================================%


%=======================================================================%
    function sizeCFS = get_size2d(sizeMAT,wav_or_lenFILT,level,ModeDWT)
        %GET_SIZE2D Get sizes of wavelet coefficients.
        %   SIZECFS = GET_SIZE2D(SIZEMAT,WAV_OR_LENFILT,LEVEL,ModeDWT)

        if ischar(wav_or_lenFILT)
            F = wfilters(wav_or_lenFILT);
            lenFILT = length(F);
        else
            lenFILT = wav_or_lenFILT;
        end
        flagPer = isequal(ModeDWT,'per');
        colorFLAG = sizeMAT(3)>1;
        if colorFLAG
            nb_COL_SIZE = sizeMAT(3);
        else
            nb_COL_SIZE = 2;
        end
        sizeCFS = zeros(level+2,nb_COL_SIZE);
        sizeCFS(end,:) = sizeMAT(1:nb_COL_SIZE);
        if flagPer
            for k=1:level
                sizeCFS(end-k,1:2) = ceil(sizeCFS(end-k+1,1:2)/2);
            end
        else
            for k=1:level
                sizeCFS(end-k,1:2) = floor((sizeCFS(end-k+1,1:2)+lenFILT-1)/2);
            end
        end
        sizeCFS(1,1:2) = sizeCFS(2,1:2);
        if nb_COL_SIZE>2 , sizeCFS(:,3) = nb_COL_SIZE; end
    end
%=======================================================================%


end % END of LVL_MMC


%-----------------------------------------------------------------------%
function varargout = dwt2_cfs_order(option,siz_Sub,first_DIAG)
%DWT2_CFS_ORDER

    if nargin<3, first_DIAG = 'col'; end

    rMAX = siz_Sub(1);
    cMAX = siz_Sub(2);
    NB_V = rMAX*cMAX;
    nums = (1:NB_V);
    M    = reshape(nums,rMAX,cMAX);

    V_Ord = nums;
    %------------------------------
    % Reverse of V_Ord:
    %------------------
    %   nums = V_Ord;  % identity
    %------------------------------

    Mh    = M';
    H_Ord = Mh(:)';
    %------------------------------
    % Reverse of H_Ord:
    %------------------
    %   Mh = reshape(H_Ord,cMAX,rMAX);
    %   M = Mh';
    %   nums = M(:)';
    %------------------------------

    indexD = zeros(NB_V,2);
    indexD(1,:) = [1 1];
    idx_End = 1;
    val_MAX = 2;
    while idx_End<NB_V
        idx_Beg = idx_End + 1;
        v = (1:val_MAX)';
        w = flipud(v);
        if isequal(first_DIAG,'col')
            add = [w,v];
        else
            add = [v,w];
        end
        add(add(:,1)>rMAX,:) = [];
        add(add(:,2)>cMAX,:) = [];
        len = size(add,1);
        idx_End = idx_Beg + len-1;
        if isequal(first_DIAG,'col')
            indexD(idx_Beg:idx_End,:) = add;
            first_DIAG = 'row';
        else
            indexD(idx_Beg:idx_End,:) = add;
            first_DIAG = 'col';
        end
        val_MAX = val_MAX + 1;
    end
    D_Ord = rMAX*(indexD(:,2)-1)' + indexD(:,1)';

    %----------------------------------
    % Reverse of D_Ord:
    %------------------
    %   [tmp,INV_D_ORD] = sort(D_Ord);
    %   Md = M(D_Ord);
    %   nums = Md(INV_D_ORD);
    %----------------------------------
    if isequal(option,'dir')
        varargout = {H_Ord , D_Ord , V_Ord};
        return
    end

    [tmp,R_H_Ord] = sort(H_Ord);
    [tmp,R_D_Ord] = sort(D_Ord);
    R_V_Ord       = V_Ord;
    if isequal(option,'rev')
        varargout = {R_H_Ord , R_D_Ord , R_V_Ord};
    else
        varargout = {H_Ord , D_Ord , V_Ord , R_H_Ord , R_D_Ord , R_V_Ord};
    end
    
end     % END of DWT2_CFS_ORDER
%-----------------------------------------------------------------------%


%-----------------------------------------------------------------------%
function varargout = quantize_params(CFS,bpp_Rate,sizeCFS)
%QUANTIZE_PARAMS
%   varargout = QUANTIZE_PARAMS(CFS,bpp_Rate,sizeCFS)
%   varargout = {stp_Qtz_SubBand,sizeCFS(idx_IDX,:),len_SubBand};

    if nargin<3 , sizeCFS = 0; end   % All coefficients
    %------------------ WEIGHT for CODING ------------------
    % Under Consideration: see the book of STRANG et NGUYEN
    %-------------------------------------------------------
    % a = sym('a');
    % V = [];
    % for k = level:-1:0 ,
    %     V = [V , a^k];
    % end
    % W = V.'*V;
    % W  = diag(diag(W,0),0) + ...
    %      diag(diag(W,1),1) + diag(diag(W,-1),-1);
    % a = 1; % or a = 2 or ...
    % W_val = eval(W);
    % weight_SubBand(1) =
    % for k = 1:size(W_val,1)
    %
    % end
    %----------------------------------------------------------

    LN22 = 2*log(2);
    lowPASS_Mul = 1.5;
    ByCfs_BitAlloc = bpp_Rate*8;
    %----------------------------------------
    siz_SubBand = prod(sizeCFS,2);
    level = length(siz_SubBand)-2;
    if level<0
        D = abs(CFS);
        [dummy,nb_BITS_NEC] = log2(D); %#ok<ASGLU>
        % nb_BITS_OK = ByCfs_BitAlloc*length(D);
        nb_BITS_OK = ByCfs_BitAlloc*length(D);
        [nb_BITS_Sorted,Idx] = sort(nb_BITS_NEC,'descend');
        cum_nb_BITS = cumsum(nb_BITS_Sorted);
        last = find(cum_nb_BITS>nb_BITS_OK);
        if ~isempty(last)
            first = last(1)+ 1;
        else
            NEG = find(nb_BITS_Sorted<=0);
            first = NEG(1);
            first = min([first,4000]);
        end
        Idx_ZER = Idx(first:end);
        stp_Qtz_SubBand = max(D(Idx_ZER));
        varargout = {stp_Qtz_SubBand};
        return
    end
    Nb_Bits     = siz_SubBand(end);
    Nb_SubBand  = 3*level+1;
    % alf_SubBand = zeros(1,Nb_SubBand);
    var_SubBand = zeros(1,Nb_SubBand);
    bit_SubBand = zeros(1,Nb_SubBand);
    stp_Qtz_SubBand = zeros(1,Nb_SubBand);
    max_SubBand = zeros(1,Nb_SubBand);
    cfs_SubBand = 8*ones(1,Nb_SubBand);
    len_SubBand = zeros(1,Nb_SubBand);
    idx_IDX = zeros(1,Nb_SubBand);
    idx_IDX(1) = 1;
    idx_Var = 2;
    for lev = 2:level+1
        idx_IDX(idx_Var:idx_Var+2) = lev;
        idx_Var = idx_Var + 3;
    end
    len_SubBand(:) = siz_SubBand(idx_IDX);
    alf_SubBand = len_SubBand/Nb_Bits;
    idx_end_CFS = 0;
    for idx_Sub = 1:Nb_SubBand
        len_Sub = len_SubBand(idx_Sub);
        idx_beg_CFS = idx_end_CFS + 1;
        idx_end_CFS = idx_beg_CFS + len_Sub - 1;
        C = CFS(idx_beg_CFS:idx_end_CFS);
        var_SubBand(idx_Sub) = var(C);
        max_SubBand(idx_Sub) = max(abs(C));
    end
    var_SubBand(1) = lowPASS_Mul * var_SubBand(1);
    weight_SubBand = LN22*ones(1,Nb_SubBand);

    indic = true(1,Nb_SubBand);
    continu = true;
    while continu
        ALF_S = alf_SubBand(indic);
        WEI_S = weight_SubBand(indic);
        VAR_S = var_SubBand(indic);
        lambda = 2^(sum(ALF_S.*log2(WEI_S.*VAR_S)) - 2*ByCfs_BitAlloc);
        for k=1:Nb_SubBand
            if indic(k)
                bit_SubBand(k) = ...
                    0.5*log2((weight_SubBand(k)*var_SubBand(k))/lambda);
            end
        end
        idx_NEG = find(bit_SubBand<0);
        continu = ~isempty(idx_NEG);
        if continu
            indic(idx_NEG) = false;
            bit_SubBand(idx_NEG) = 0;
        end
    end

    idx_POS = find(bit_SubBand>0);
    for k=1:length(idx_POS)
        idx = idx_POS(k);
        T = cfs_SubBand(idx)*sqrt(var_SubBand(idx))/2^bit_SubBand(idx);
        C_max    = max_SubBand(idx);
        [dummy,nb_bit] = log2(C_max); %#ok<ASGLU>
        stp_QtzMIN = C_max/(2^nb_bit-1);
        stp_Qtz_SubBand(idx) = max([2*T,stp_QtzMIN]);
    end
    idx_ZER = find(bit_SubBand==0);
    for k=1:length(idx_ZER)
        idx = idx_ZER(k);
        stp_Qtz_SubBand(idx) = 2*max_SubBand(idx) + sqrt(eps);
    end
    varargout = {stp_Qtz_SubBand,sizeCFS(idx_IDX,:),len_SubBand};
end     % END of QUANTIZE_PARAMS
%-----------------------------------------------------------------------%


