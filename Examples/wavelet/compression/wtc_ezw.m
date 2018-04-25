function varargout = wtc_ezw(option,typeSAVE,varargin)
%WTC_EZW Main program for EZW encoding.
%   VARARGOUT = WTC_EZW(OPTION,VARARGIN)
%
%   WTC_EZW('encode', ... )
%   WTC_EZW('decode', ... )
%   WTC_EZW('save', ... )
%   WTC_EZW('load', ... )

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Jun-2004.
%   Last Revision: 03-Apr-2012.
%   Copyright 1995-2012 The MathWorks, Inc.


% Initialization
%------------------

nbCHAR = 1;    % Nb of significant letters for "option"
validOPTION = {'encode','decode','save','load'};
CurrentAxe = [];

numOPT = find(strncmpi(option,validOPTION,nbCHAR));
nbout  = nargout;
switch numOPT
    case {1,2}  %--  'encode' or 'decode'  --%
        %----------------------------------%
        % INITIALIZATIONS of EZW Structure %
        %----------------------------------%
        %------------------------------
        % Coding and Decoding Variable
        %------------------------------
        EZW.Header.baseMain  = 2;
        EZW.Header.baseSub   = 2;
        EZW.Header.Row       = 0;
        EZW.Header.Col       = 0;
        EZW.Header.BitPlan   = 0;
        EZW.Header.ColType   = 'rgb';
        EZW.Header.ColMAT    = [];        
        EZW.Header.Threshold = 0;
        EZW.Header.Methode   = 'none';
        EZW.Header.Level     = 0;
        EZW.Header.MaxLoop   = Inf;
        EZW.BitStream        = [];
        EZW.Matrice          = [];
        EZW_PtrStream        = 0;
        %-------------------------
        P_code = double('P');
        N_code = double('N');
        Z_code = double('Z');
        T_code = double('T');
        %--------------------

    case {3,4}  %--  'save' or 'load'  --%
        EZW_Codes = struct('pos','P','neg','N','iz','Z','ztr','T');
        %-------------------------
        % Alphabet codes not used.
        %   EZW_Codes.s0  = '0';
        %   EZW_Codes.s1  = '1';
        %-------------------------
end

switch numOPT
    %-- 'encode' --%
    case 1 , [varargout{1:nbout}] = wtc_ezw_enc(varargin{:});
    %-- 'decode' --%
    case 2 , [varargout{1:nbout}] = wtc_ezw_dec(varargin{:});
    %--- 'save' ---%
    case 3 , [varargout{1:nbout}] = wtc_ezw_save(typeSAVE,varargin{:});
    %--- 'load' ---%
    case 4 , [varargout{1:nbout}] = wtc_ezw_load(typeSAVE,varargin{:});
end



%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function WTC_Struct = wtc_ezw_enc(varargin)
        %WTC_EZW_ENC Main program - EZW-codes matrix X.

        %-----------------%
        % INITIALIZATIONS %
        %-----------------%
        Idx_Liste = 0;

        %---------------------------------------------------------------%
        % CHECK ARGUMENTS AND and INITIALIZATIONS.                      %
        %---------------------------------------------------------------%
        nbIn = nargin;
        narginchk(1,15);
        
        typeCODE = struct('baseMain',2,'baseSub',2);
        if nbIn>6
            [X,wname,level,modeDWT,MaxLoop,ColType,stepFLAG] = ...
                deal(varargin{1:7}); %#ok<*ASGLU>
            if nbIn<8
                CurrentAxe = [];
            else
                CurrentAxe = varargin{8};
            end
            if nbIn>8 , typeCODE = varargin{9}; end % Not used in the current version 
            if ~iscell(stepFLAG) && isnan(stepFLAG)
                flagPLOT = 0;
            else
                flagPLOT = 1;
                if isequal(stepFLAG,1) || iscell(stepFLAG)
                    flagPLOT = 2;
                end
            end
            old_modeDWT = dwtmode('status','nodisp');
            EZW.Header.baseMain = typeCODE.baseMain;
            EZW.Header.baseSub  = typeCODE.baseSub;
            EZW.Header.Level = level;
            EZW.Header.Methode = 'wavelet';
            EZW.Header.MaxLoop = MaxLoop;
            
        else  % Not used in the current version
            flagPLOT = 1;
            idx = 1;
            while idx<=nbIn
                if isstruct(varargin{idx})
                    typeCODE = varargin{idx};       
                    EZW.Header.baseMain = typeCODE.baseMain; 
                    EZW.Header.baseSub  = typeCODE.baseSub;  
                    idx = idx+1;
                elseif isnumeric(varargin{idx})
                    siz = size(varargin{idx});
                    if min(siz)>2
                        X = varargin{idx};
                        idx = idx+1;
                    else
                        try
                            C = varargin{idx};   %#ok<NASGU>
                            S = varargin{idx+1}; 
                            idx = idx + 2;
                        catch ME    %#ok<NASGU>
                            EZW.Header.MaxLoop = varargin{idx};
                            idx = idx + 1;
                        end
                    end
                elseif ischar(varargin{idx})
                    if isequal(lower(varargin{idx}),'plot')
                        flagPLOT = 2;
                        idx = idx + 1;
                    else
                        EZW.Header.Methode = 'wavelet';
                        wname = varargin{idx};
                        idx   = idx+1;
                        if (idx<=nbIn) && isnumeric(varargin{idx})
                            EZW.Header.Level = varargin{idx};
                            idx = idx + 1;
                            if (idx<=nbIn) && isnumeric(varargin{idx})
                                old_modeDWT = varargin{idx};
                                idx = idx +1;
                                if (idx<=nbIn) && isnumeric(varargin{idx})
                                    EZW.Header.MaxLoop = varargin{idx};
                                    idx = idx + 1;
                                end
                            end
                        else
                            EZW.Header.Level = Inf;
                        end
                    end
                end
            end
        end
        EZW.Header.Level = min(fix(log2(min(size(X(:,:,1))))),EZW.Header.Level);
        EZW.Header.Row = size(X,1);
        EZW.Header.Col = size(X,2);
        EZW.Header.BitPlan = size(X,3);
        EZW.Header.ColType = ColType;
        [X,ColMAT] = wimgcolconv(ColType,X);
        EZW.Header.ColMAT = ColMAT;
        baseMain = EZW.Header.baseMain;
        baseSub  = EZW.Header.baseSub;
        methode  = EZW.Header.Methode;
        nbR = EZW.Header.Row;
        nbBitPlan = EZW.Header.BitPlan;

        if isequal(baseMain,2) && isequal(baseSub,2)
            typeCODE = 'pow2';
        else
            typeCODE = 'prop';
        end
        switch methode
            case 'none'
                EZW.Header.Methode = 'none';
                EZW.Header.Level   = wmaxlev(size(X),'haar');
                if flagPLOT>0 , X_ORI = X; end
                [dummy,S] = wavedec2(X,EZW.Header.Level,'haar'); %#ok<ASGLU>

            case 'wavelet'
                EZW.Header.Methode = wname;
                modeDWT = 'per';
                dwtmode(modeDWT,'nodisp');
                [C,S] = wavedec2(X,EZW.Header.Level,wname);
                dwtmode(old_modeDWT,'nodisp');
                if flagPLOT>0 , X_ORI = X; end
                X = wcfs2mat(C,S);
        end

        %---------------------------------------------------------------%
        % Matrix parameters and Parameters for coding (initialization). %
        %---------------------------------------------------------------%
        maxVAL = max(abs(double(X(:))));
        if ~(isempty(baseMain) || isnan(baseMain))
            tmp = log(maxVAL)/log(baseMain);
            if ceil(tmp)>tmp
                NbMAX_Pass = ceil(tmp);
            else
                NbMAX_Pass = ceil(tmp)+1;
            end
            tab_THRES  = baseMain.^(0:NbMAX_Pass);
        else
            E = sort(abs(X(:)));
            maxTHR = E(end);
            percent = [0:0.1:0.9 , 0.905:0.005:0.950 , 0.9525:0.0025:1];
            idx_THRES = round(percent*length(E));
            tab_THRES = [0, E(idx_THRES(2:end-1))', maxTHR+1];
            NbMAX_Pass = length(tab_THRES);
            EZW.Header.baseMain = tab_THRES;
        end
        diff_THRESH = diff(tab_THRES);
        lenDIFF = length(diff_THRESH);
        threshold_INI = tab_THRES(end-1);

        nbValInMat = numel(X);
        EZW.Header.Threshold = threshold_INI;
        EZW.Matrice   = X;
        EZW.BitStream = char(zeros(1,20*nbValInMat));
        EZW_Liste = zeros(nbValInMat,2);
        LST_idxPlan = zeros(nbValInMat,1);
        EZW_Fifo  = zeros(nbValInMat,2);

        % Compute quadtree parameters.
        [TabFATHER,TabFirstCHILD,idxCFSlevMAX,row_AND_col_IDX] = ...
            wfandfcidx('quadtree',S);

        %=================================================================%
        %               Main loop for EZW-encoding matrix X.              %
        %=================================================================%
        
        % For GUI: Step by Step.
        test_step_by_step('ini',stepFLAG);
        
        threshold = threshold_INI;
        MAX_loop = min([EZW.Header.MaxLoop,NbMAX_Pass]);
        EZW.Header.MaxLoop = MAX_loop;
        nbTHR = length(tab_THRES);
        loop = 0;
        sigMAP = significant_map('ezw',EZW.Matrice,TabFATHER);
        while ~isequal(threshold,0) && loop<MAX_loop
            loop = loop+1;
            numTHR = nbTHR-loop;
            threshold = tab_THRES(numTHR);
            Fifo_Beg_Ptr = 0;
            Fifo_End_Ptr = 0;
            Matrice_TMP = EZW.Matrice;
            % sigMAP = significant_map('ezw',Matrice_TMP,TabFATHER);
            % slower and not more efficient.
            for idxPlan = 1:nbBitPlan
                encode_Main_Pass(threshold,loop);

                % Search the "Pixels" to refine.
                if nbBitPlan>1
                    idx2Change = find(LST_idxPlan(1:Idx_Liste)==idxPlan);
                else
                    idx2Change = (1:Idx_Liste);
                end
                nbVal2Change = length(idx2Change);

                switch typeCODE
                    case 'pow2' , encode_Sub_Pass_V1(threshold,loop);
                    case 'prop' , encode_Sub_Pass_V2(baseSub,threshold,loop);
                end
            end
            EZW.Matrice = Matrice_TMP;
            if flagPLOT>1
                [~,stepFLAG] = ...
                    plotezw('encode',EZW,loop,X_ORI,stepFLAG,CurrentAxe);
            end
        end
        if flagPLOT>=1
            [~,stepFLAG] = ...
                plotezw('encode',EZW,loop,X_ORI,stepFLAG,CurrentAxe);
            pause(0.01);
            strTitle = getWavMSG('Wavelet:commongui:CompImg');
            title(strTitle,'Parent',CurrentAxe); pause(0.01)   
        end
        test_step_by_step('close',stepFLAG);

        EZW.BitStream(EZW_PtrStream+1:end) = [];
        WTC_Struct = rmfield(EZW,{'Matrice'});
        %=================================================================%


        %=================================================================%
        %----------------------------------------------------------------%
        % Performs one complete dominant pass. Dominant-pass-codes are
        % sent to the output stream and the subordinate list is updated.
        %----------------------------------------------------------------%
        function encode_Main_Pass(threshold,loop)

            % Approximation Coefficients of Level MAX
            idx_INIT = idxCFSlevMAX(:,1);
            for k = 1:length(idx_INIT)
                idx_PIX = idx_INIT(k);
                encode_PIXEL(idx_PIX);
            end

            % Detail Coefficients of Level MAX
            idx_INIT = idxCFSlevMAX(:,2:4);
            idx_INIT = idx_INIT(:);
            for k = 1:length(idx_INIT)
                idx_PIX = idx_INIT(k);
                encode_PIXEL(idx_PIX);
            end

            % Other Detail Coefficients.
            while (Fifo_Beg_Ptr<Fifo_End_Ptr)
                Fifo_Beg_Ptr = Fifo_Beg_Ptr + 1;
                idx_PIX  = EZW_Fifo(Fifo_Beg_Ptr,1);
                cod_PIX  = EZW_Fifo(Fifo_Beg_Ptr,2);
                EZW_PtrStream = EZW_PtrStream + 1;
                EZW.BitStream(EZW_PtrStream) = cod_PIX;
                if cod_PIX~=T_code
                    Ic = TabFirstCHILD(idx_PIX);
                    if ~isnan(Ic)
                        Children = [Ic , Ic+1 , Ic+nbR , Ic+1+nbR];
                        for k = 1:4
                            idx_Child = Children(k);

                            %-------------------------------------------
                            % The following lines are equivalent to:
                            %    encode_PIXEL(idx_Child);
                            % but they are fastest!
                            %-------------------------------------------
                            iRow = row_AND_col_IDX(idx_Child,1);
                            iCol = row_AND_col_IDX(idx_Child,2);
                            tmp = Matrice_TMP(iRow,iCol,idxPlan);
                            if abs(tmp)>=threshold
                                if tmp>=0
                                    code = P_code;
                                else
                                    code = N_code;
                                end
                                Idx_Liste = Idx_Liste + 1;
                                EZW_Liste(Idx_Liste,1) = abs(tmp);
                                EZW_Liste(Idx_Liste,2) = loop;
                                LST_idxPlan(Idx_Liste) = idxPlan;
                                Matrice_TMP(iRow,iCol,idxPlan) = 0;
                            else
                                if sigMAP(idx_Child,2*idxPlan)<threshold
                                    code = T_code;
                                else
                                    code = Z_code;
                                end
                            end

                            % Store INDEX and CODE on EZW_Fifo.
                            % Resize EZW_Fifo if necessary.
                            %----------------------------------
                            Fifo_End_Ptr = Fifo_End_Ptr + 1;
                            len_EZW_Fifo = size(EZW_Fifo,1);
                            if Fifo_End_Ptr>len_EZW_Fifo
                                EZW_Fifo(2*len_EZW_Fifo,end) = 0;
                            end
                            EZW_Fifo(Fifo_End_Ptr,1) = idx_Child;
                            EZW_Fifo(Fifo_End_Ptr,2) = code;
                            %------------------------------------

                        end
                    end
                end;
            end
        end

        %---------------------------------------------------------------%
        % Encoding one Pixel.
        %-------------------
        function encode_PIXEL(iP)
            iRow = row_AND_col_IDX(iP,1);
            iCol = row_AND_col_IDX(iP,2);
            tmp = Matrice_TMP(iRow,iCol,idxPlan);
            if abs(tmp)>=threshold
                if tmp>=0 ,
                    code = P_code;
                else
                    code = N_code;
                end
                Idx_Liste = Idx_Liste + 1;
                EZW_Liste(Idx_Liste,1) = abs(tmp);
                EZW_Liste(Idx_Liste,2) = loop;
                LST_idxPlan(Idx_Liste) = idxPlan;
                Matrice_TMP(iRow,iCol,idxPlan) = 0;
            else
                if sigMAP(iP,2*idxPlan)<threshold
                    code = T_code;
                else
                    code = Z_code;
                end
            end

            % Store INDEX and CODE on EZW_Fifo.
            % Resize EZW_Fifo if necessary.
            %----------------------------------
            Fifo_End_Ptr = Fifo_End_Ptr + 1;
            len_EZW_Fifo = size(EZW_Fifo,1);
            if Fifo_End_Ptr>len_EZW_Fifo
                EZW_Fifo(2*len_EZW_Fifo,end) = 0;
            end
            EZW_Fifo(Fifo_End_Ptr,:) = [iP,code];
            %-------------------------------------------
        end
        %----------------------------------------------------------------%
        %=================================================================%

        %----------------------------------------------------------------%
        % Performs one subordinate pass - Version 1 (vectorized).
        %----------------------------------------------------------------%
        function encode_Sub_Pass_V1(threshold,loop) %#ok<INUSD>

            sub_thres = fix(threshold/2);
            if sub_thres>0
                AND_Val  = bitand(round(EZW_Liste(idx2Change,1)),sub_thres);
                idx_ONES = (AND_Val~=0);
                TMP = '0';
                TMP = TMP(ones(1,nbVal2Change));
                TMP(idx_ONES) = '1';
                first = EZW_PtrStream + 1;
                last  = first + nbVal2Change-1;
                EZW.BitStream(first:last) = TMP;
                EZW_PtrStream = last;
            end
        end
        %----------------------------------------------------------------%
        % Performs one subordinate pass - Version 2.
        %----------------------------------------------------------------%
        function encode_Sub_Pass_V2(baseSub,threshold,loop)

            sub_thres = fix(threshold/2);
            if sub_thres>0
                for k=1:nbVal2Change
                    j = idx2Change(k);
                    loop_INI = EZW_Liste(j,2);
                    diff_IDX = loop_INI-1;
                    delta = diff_THRESH(lenDIFF-diff_IDX);
                    teta  = (EZW_Liste(j,1)-tab_THRES(lenDIFF-diff_IDX))/delta;
                    if ~isempty(baseSub)
                        tmpTMP = baseSub^(loop-diff_IDX);
                        code = rem(fix(tmpTMP*teta),baseSub) + 48;
                    else
                        code = double(teta>0.5) + 48;
                    end
                    EZW_PtrStream = EZW_PtrStream + 1;
                    EZW.BitStream(EZW_PtrStream) = char(code);
                end
            end
        end
        %-----------------------------------------------------------------%

    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%



%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function OUT = wtc_ezw_dec(varargin)
        %WTC_EZW_DEC Main program - EZW-decodes BitStream.

        %---------------------------------------------------------------%
        % CHECK ARGUMENTS AND and INITIALIZATIONS.                      %
        %---------------------------------------------------------------%
        pauseFLAG = 0;
        flagPLOT = 1;
        if length(varargin)>1 , flagPLOT = varargin{2}; end
        E = varargin{1};
        EZW.Header = E.Header;
        baseMain = EZW.Header.baseMain;
        baseSub  = EZW.Header.baseSub;
        if isequal(baseMain,2) && isequal(baseSub,2)
            typeCODE = 'pow2';
        else
            typeCODE = 'prop';
        end
        if length(baseMain)==1
            maxVAL     = baseMain * EZW.Header.Threshold;
            NbMAX_Pass = ceil(log(maxVAL)/log(baseMain)-sqrt(eps));
            tab_THRES  = baseMain.^(0:NbMAX_Pass);
        else
            tab_THRES = baseMain;
        end
        diff_THRESH   = diff(tab_THRES);
        SizeINI       = [EZW.Header.Row,EZW.Header.Col];
        level         = EZW.Header.Level;
        [sizeCFS,sizesUTL] = getsizes(level,SizeINI);
        BitPlan       = EZW.Header.BitPlan;
        EZW.Matrice   = zeros([sizesUTL(end,:),BitPlan]);
        EZW_BitStream = double(E.BitStream);
        Len_BitStream = length(EZW_BitStream);
        Ptr_Stream = 0;
        nbR = EZW.Header.Row;
        nbBitPlan = EZW.Header.BitPlan;

        %----------------------------%
        % VARIABLES INITIALIZATIONS. %
        %----------------------------%
        nbValInMat = numel(EZW.Matrice);
        EZW_Fifo   = zeros(nbValInMat,2);
        EZW_Liste  = zeros(nbValInMat,3);
        LST_idxPlan = zeros(nbValInMat,1);
        MAX_loop   = EZW.Header.MaxLoop;
        S = sizeCFS(1:end,:);
        [~,TabFirstCHILD,idxCFSlevMAX,row_AND_col_IDX] = ...
            wfandfcidx('quadtree',S);

        if flagPLOT>0, plotezw('decode',EZW,0); end
        %---------------------------------------------------------------%

        %=================================================================%
        %           Main loop for EZW-decoding matrix BitStream.          %
        %=================================================================%
        Idx_Liste  = 0;
        threshold = EZW.Header.Threshold;
        loop = 0;

        while ~isequal(threshold,0) && loop<MAX_loop
            loop = loop+1;
            threshold = tab_THRES(end-loop);
            Fifo_Beg_Ptr = 0;
            Fifo_End_Ptr = 0;
            Matrice_TMP  = EZW.Matrice;
            for idxPlan = 1:nbBitPlan
                decode_Main_Pass(threshold,loop);

                % Search the "Pixels" to refine.
                if nbBitPlan>1
                    idx2Change = find(LST_idxPlan(1:Idx_Liste)==idxPlan);
                else
                    idx2Change = (1:Idx_Liste);
                end
                nbVal2Change = length(idx2Change);

                switch typeCODE
                    case 'pow2' , decode_Sub_Pass_V1(threshold);
                    case 'prop' , decode_Sub_Pass_V2(baseSub,threshold,loop);
                end
            end
            EZW.Matrice = Matrice_TMP;
            if flagPLOT==1 , plotezw('decode',EZW,loop); end
            if pauseFLAG , 
                disp(['Pause ... loop = ' int2str(loop)]); pause;  %#ok<UNRCH>
            end
        end
        % if flagPLOT==2 ,end
        if flagPLOT>=0
            plotezw('decode',EZW,loop); 
            strTitle = getWavMSG('Wavelet:commongui:CompImg');
            title(strTitle); pause(0.01)   
        end

        
        %--------------------------------------------------------------%
        switch EZW.Header.Methode
            case 'none' ,
                OUT = EZW.Matrice;
            otherwise
                wname = EZW.Header.Methode;
                level = EZW.Header.Level;
                SizeINI = [EZW.Header.Row,EZW.Header.Col];
                [C,S] = wmat2cfs(EZW.Matrice,level,SizeINI);
                old_modeDWT = dwtmode('status','nodisp');
                modeDWT = 'per';
                dwtmode(modeDWT,'nodisp');
                OUT = waverec2(C,S,wname);
                dwtmode(old_modeDWT,'nodisp');
        end
        OUT = ...
            wimgcolconv(['inv' EZW.Header.ColType],OUT,EZW.Header.ColMAT);
        if ndims(OUT)>2 , OUT = uint8(OUT); end %#ok<ISMAT>
        %--------------------------------------------------------------%
    %====================================================================%


    %====================================================================%
    %-----------------------------------------------------------------%
    % Performs one complete dominant pass. Dominant-pass-codes are
    % sent to the output stream and the subordinate list is updated.
    %-----------------------------------------------------------------%
    function decode_Main_Pass(threshold,loop)
                
        idx_INIT = idxCFSlevMAX(:);
        for k = 1:length(idx_INIT)
            idx_PIX = idx_INIT(k);
            iRow = row_AND_col_IDX(idx_PIX,1);
            iCol = row_AND_col_IDX(idx_PIX,2);
         
            if Ptr_Stream<Len_BitStream
                Ptr_Stream = Ptr_Stream + 1;
                code = EZW_BitStream(Ptr_Stream);
            else
                error(message('Wavelet:InOut:Invalid_EndStream'));
            end
            
            if code==P_code || code==N_code
                if code==P_code
                    Matrice_TMP(iRow,iCol,idxPlan) = threshold;
                else
                    Matrice_TMP(iRow,iCol,idxPlan) = -threshold;
                end
                Idx_Liste = Idx_Liste + 1;
                EZW_Liste(Idx_Liste,1) = idx_PIX;
                EZW_Liste(Idx_Liste,2) = loop;
                LST_idxPlan(Idx_Liste) = idxPlan;
            end
            Fifo_End_Ptr = Fifo_End_Ptr + 1;
            EZW_Fifo(Fifo_End_Ptr,:) = [idx_PIX , code];
        end
        
        while Fifo_Beg_Ptr<Fifo_End_Ptr
            Fifo_Beg_Ptr = Fifo_Beg_Ptr + 1;
            idx_PIX = EZW_Fifo(Fifo_Beg_Ptr,1);
            cod_PIX = EZW_Fifo(Fifo_Beg_Ptr,2);
            if cod_PIX ~= T_code
                Ic = TabFirstCHILD(idx_PIX);
                if ~isnan(Ic)
                    Children = [Ic , Ic+1 , Ic+nbR, Ic+1+nbR];
                    for k = 1:4
                        idx_Child = Children(k);
                        if Ptr_Stream<Len_BitStream
                            Ptr_Stream = Ptr_Stream + 1;
                            code = EZW_BitStream(Ptr_Stream);
                        else
                            error(message('Wavelet:InOut:Invalid_EndStream'));
                        end
                        
                        if code==P_code || code==N_code
                            iRow = row_AND_col_IDX(idx_Child,1);
                            iCol = row_AND_col_IDX(idx_Child,2);
                            if code==P_code
                                Matrice_TMP(iRow,iCol,idxPlan) = threshold;
                            else
                                Matrice_TMP(iRow,iCol,idxPlan) = -threshold;
                            end
                            Idx_Liste = Idx_Liste + 1;
                            EZW_Liste(Idx_Liste,1) = idx_Child;
                            EZW_Liste(Idx_Liste,2) = loop;
                            LST_idxPlan(Idx_Liste) = idxPlan;
                        end
                        Fifo_End_Ptr = Fifo_End_Ptr + 1;
                        len_EZW_Fifo = size(EZW_Fifo,1);
                        if Fifo_End_Ptr>len_EZW_Fifo
                            EZW_Fifo(2*len_EZW_Fifo,end) = 0;
                        end
                        EZW_Fifo(Fifo_End_Ptr,1) = idx_Child;
                        EZW_Fifo(Fifo_End_Ptr,2) = code;
                    end
                end
            end
        end        
    end

    %-----------------------------------------------------------------%
    % Performs one subordinate pass.
    %-----------------------------------------------------------------%
    function decode_Sub_Pass_V1(threshold)
        
        sub_thres = fix(threshold/2);
        if sub_thres>0
            for k=1:nbVal2Change
                j = idx2Change(k);
                if Ptr_Stream<Len_BitStream
                    Ptr_Stream = Ptr_Stream + 1;
                    if isequal(EZW_BitStream(Ptr_Stream),'1')
                        idx_Child = EZW_Liste(j,1);
                        iRow = row_AND_col_IDX(idx_Child,1);
                        iCol = row_AND_col_IDX(idx_Child,2);
                        tmp = Matrice_TMP(iRow,iCol,idxPlan);
                        Matrice_TMP(iRow,iCol,idxPlan) = ...
                            tmp + sign(tmp)*sub_thres;
                    end
                end
            end
        end
    end
    
    %-----------------------------------------------------------------%
    % Performs one subordinate pass - Version 2.
    %-----------------------------------------------------------------%
    function decode_Sub_Pass_V2(baseSub,threshold,loop)
        
        sub_thres = fix(threshold/2);
        if sub_thres>0
            for k=1:nbVal2Change
                j = idx2Change(k);
                if Ptr_Stream<Len_BitStream
                    Ptr_Stream = Ptr_Stream + 1;
                    code = EZW_BitStream(Ptr_Stream);
                    idx_Child = EZW_Liste(j,1);
                    loop_INI  = EZW_Liste(j,2);
                    iPlan     = LST_idxPlan(j);
                    if iPlan==idxPlan
                        diff_IDX = loop_INI-1;
                        delta = diff_THRESH(end-diff_IDX);
                        if ~isempty(baseSub)
                            addTHR = ...
                                delta * (abs(code)-48) / baseSub^(loop-diff_IDX);
                        else
                            addTHR = ...
                                delta * (abs(code)-48) / 2^(loop-diff_IDX);
                        end
                        iRow = row_AND_col_IDX(idx_Child,1);
                        iCol = row_AND_col_IDX(idx_Child,2);
                        tmp = Matrice_TMP(iRow,iCol,iPlan);
                        Matrice_TMP(iRow,iCol,iPlan) = ...
                            tmp + sign(tmp)*addTHR;
                    end
                end
            end
        end
    end
    %====================================================================%

end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%



%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function fileSize = wtc_ezw_save(typeSAVE,filename,WTC_Struct)
        %WTC_EZW_SAVE Save original EZW encoding.

        % File settings.
        %---------------
        tmp_filename  = def_tmpfile(filename);
        fid = fopen(tmp_filename,'wb');

        % Code alphabet
        %--------------
        maxSub = WTC_Struct.Header.baseSub;
        tmp = int2str((0:maxSub-1)');
        for k=1:length(tmp) , EZW_Codes.(['s' tmp(k)]) = tmp(k); end
        codes = fieldnames(EZW_Codes);
        nbCodes = length(codes);
        alphabet = [];
        for k = 1:nbCodes
            alphabet = [alphabet , EZW_Codes.(codes{k})]; %#ok<AGROW>
        end
        bwt_OPTION = 'off';
        mtf_OPTION = 2;
        [bwt_IDX,mtf_VAL,HC_Struct] = ...
            bwc_algo('e',bwt_OPTION,mtf_OPTION,alphabet,WTC_Struct.BitStream);
        TabCODE = HC_Struct.HC_tabENC;
        HCTab = HC_Struct.HC_codes;
        %-----------------------------------------------------------------------

        % Begin Saving.
        %--------------
        codeID = wtcmngr('meth_ident',typeSAVE,'ezw');
        fwrite(fid,codeID,'ubit8');
        LenOfBitStream = length(WTC_Struct.BitStream);
        len_baseMain   = length(WTC_Struct.Header.baseMain);
        fwrite(fid,LenOfBitStream,'uint32');
        fwrite(fid,len_baseMain,'uint8');
        fwrite(fid,bwt_IDX,'uint16');
        fwrite(fid,mtf_VAL,'int8');
        fwrite(fid,WTC_Struct.Header.baseMain,'double');
        fwrite(fid,WTC_Struct.Header.baseSub,'ubit4');
        fwrite(fid,WTC_Struct.Header.Row,'uint16');
        fwrite(fid,WTC_Struct.Header.Col,'uint16');
        fwrite(fid,WTC_Struct.Header.BitPlan,'uint8');
        codeCOL = wimgcolconv(WTC_Struct.Header.ColType);
        fwrite(fid,codeCOL,'ubit3');
        if isequal(codeCOL,2)
            fwrite(fid,WTC_Struct.Header.ColMAT,'float32');
        end        
        fwrite(fid,WTC_Struct.Header.Threshold,'uint32');
        nbCHAR = length(WTC_Struct.Header.Methode);
        fwrite(fid,nbCHAR,'ubit4');
        fwrite(fid,WTC_Struct.Header.Methode,'uint8');
        fwrite(fid,WTC_Struct.Header.Level,'uint8');
        fwrite(fid,WTC_Struct.Header.MaxLoop,'uint8');
        nbHC = length(HCTab);
        fwrite(fid,nbHC,'uint8');
        fwrite(fid,HCTab,'ubit2');
        lenCODE  = length(TabCODE);
        fwrite(fid,lenCODE,'uint32');
        fwrite(fid,TabCODE,'ubit1');
        try   fclose(fid);
        catch ME  %#ok<NASGU>
        end
        modify_wtcfile('save',filename,typeSAVE)
        fid = fopen(filename);
        [~,fileSize] = fread(fid);
        fclose(fid);
        
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%



%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function WTC_Struct = wtc_ezw_load(typeSAVE,filename)
        %WTC_EZW_LOAD Load EZW encoded file.
        %   WTC_Struct = WTC_EZW_LOAD(FILENAME)

        % File settings.
        %---------------
        tmp_filename = def_tmpfile(filename);
        ok_TMP = exist(tmp_filename,'file');
        if ok_TMP
            fid = fopen(tmp_filename);
        else
            fid = fopen(filename);
        end
        %---------------------------------------------------------------
        codeID = fread(fid,1,'*char');  %#ok<NASGU> % Not used.
        LenOfBitStream = fread(fid,1,'uint32');
        len_baseMain = fread(fid,1,'uint8');
        bwt_IDX = fread(fid,1,'uint16');
        mtf_VAL = fread(fid,1,'int8');
        WTC_Struct.Header.baseMain = fread(fid,len_baseMain,'double');
        WTC_Struct.Header.baseSub  = fread(fid,1,'ubit4');
        %---------------------------------------------------------------

        % Code alphabet
        %---------------
        maxSub = WTC_Struct.Header.baseSub;
        tmp = int2str((0:maxSub-1)');
        for k=1:length(tmp) , EZW_Codes.(['s' tmp(k)]) = tmp(k); end
        codes = fieldnames(EZW_Codes);
        nbCodes = length(codes);
        alphabet = [];
        for k = 1:nbCodes
            alphabet = [alphabet , EZW_Codes.(codes{k})]; %#ok<AGROW>
        end
        %------------------------------------------------------------
        WTC_Struct.Header.Row = fread(fid,1,'uint16');
        WTC_Struct.Header.Col = fread(fid,1,'uint16');
        WTC_Struct.Header.BitPlan = fread(fid,1,'uint8');
        
        codeCOL = fread(fid,1,'ubit3');
        WTC_Struct.Header.ColType = wimgcolconv(codeCOL);
        if isequal(codeCOL,2)
            ColMAT = fread(fid,9,'float32');
            WTC_Struct.Header.ColMAT = reshape(ColMAT,3,3);
        else
            WTC_Struct.Header.ColMAT = [];
        end

        WTC_Struct.Header.Threshold = fread(fid,1,'uint32');
        nbCHAR = fread(fid,1,'ubit4');
        wname = fread(fid,nbCHAR,'uint8');
        WTC_Struct.Header.Methode = char(wname');
        WTC_Struct.Header.Level = fread(fid,1,'uint8');
        WTC_Struct.Header.MaxLoop = fread(fid,1,'uint8');
        nbHC = fread(fid,1,'uint8');
        HCTab = fread(fid,nbHC,'ubit2');
        lenCODE = fread(fid,1,'uint32');
        TabCODE = fread(fid,lenCODE,'ubit1');
        WTC_Struct.BitStream = ...
            bwc_algo('d',bwt_IDX,mtf_VAL,alphabet,LenOfBitStream,HCTab,TabCODE);
        %------------------------------------------------------------
        fclose(fid);
        if ok_TMP , delete(tmp_filename); end
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function [save_stepFLAG,stepFLAG] = ...
            plotezw(option,EZW,loop,X_ORI,stepFLAG,CurrentAxe) %#ok<INUSL>

        % For GUI: Step by Step.
        if nargin>4 
            [save_stepFLAG,stepFLAG] = ...
            test_step_by_step('beg',stepFLAG);
        else
            CurrentAxe = gca;
        end

        methode = EZW.Header.Methode;
        EZW_Mat = EZW.Matrice;
        switch methode
            case 'none'
            otherwise
                wname = methode;
                level = EZW.Header.Level;
                SizeINI = [EZW.Header.Row,EZW.Header.Col];
                [C,S] = wmat2cfs(EZW_Mat,level,SizeINI);
                old_modeDWT = dwtmode('status','nodisp');
                modeDWT = 'per';
                dwtmode(modeDWT,'nodisp');
                EZW_Mat = waverec2(C,S,wname);
                dwtmode(old_modeDWT,'nodisp');
        end
        if nargin>3 , EZW_Mat = double(X_ORI)-double(EZW_Mat); end
        ColType = EZW.Header.ColType;
        ColMAT  = EZW.Header.ColMAT;
        EZW_Mat = wimgcolconv(['inv' ColType],EZW_Mat,ColMAT);
        EZW_Mat = wd2uiorui2d('d2uint',EZW_Mat);
        image(EZW_Mat,'Parent',CurrentAxe);
        pause(0.01)
        title(getWavMSG('Wavelet:divGUIRF:WTC_Loop',loop),'Parent',CurrentAxe)
        pause(0.01)
        if nargin<5 , save_stepFLAG = 0; stepFLAG = 0; end

        % For GUI: Step by Step.
        if iscell(save_stepFLAG)
            [save_stepFLAG,stepFLAG] = ...
                test_step_by_step('end',save_stepFLAG);
        end
        
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


end  % End of WTC_EZW.M