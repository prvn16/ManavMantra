function varargout = wtc_wdr(option,typeSAVE,varargin)
%WTC_WDR Main program for WTC_WDR encoding.
%
%   VARARGOUT = WTC_WDR(OPTION,VARARGIN)
%
%   WTC_WDR('encode', ... )
%   WTC_WDR('decode', ... )
%   WTC_WDR('save', ... )
%   WTC_WDR('load', ... )

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 27-Nov-2007.
%   Last Revision: 03-Apr-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

% Constant used in WTC_WDR.
%--------------------------
alphabet   = ['P','N','0','1'];
bwt_OPTION = 'off';
mtf_OPTION = 2;

% Check inputs.
%--------------
nbCHAR = 1;    % Nb of significant letters for "option"
validOPTION = {'encode','decode','save','load'};

numOPT = find(strncmpi(option,validOPTION,nbCHAR));
nbout  = nargout;
switch numOPT
    %-- 'encode' --%
    case 1 , [varargout{1:nbout}] = wtc_wdr_enc(varargin{:});
        %-- 'decode' --%
    case 2 , [varargout{1:nbout}] = wtc_wdr_dec(varargin{:});
        %--- 'save' ---%
    case 3 , [varargout{1:nbout}] = wtc_wdr_save(typeSAVE,varargin{:});
        %--- 'load' ---%
    case 4 , [varargout{1:nbout}] = wtc_wdr_load(varargin{:});
end


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function WTC_Struct = wtc_wdr_enc(X,wname,level,modeDWT,...
            MaxLoop,ColType,stepFLAG,CurrentAxe) %#ok<INUSL>
        % WTC_WDR_ENC Main program - EZW-WDRcodes matrix X.

        nbin = nargin;
        if nbin<2 , wname = 'haar'; end
        if nbin<3 , level = Inf; end
        if nbin<4 , modeDWT  = dwtmode('status','nodisp'); end  %#ok<*NASGU>        
        if ~isequal(wname,'none')
            old_modeDWT = dwtmode('status','nodisp');
            modeDWT = 'per';
            dwtmode(modeDWT,'nodisp');
        end
        if nbin<5 , MaxLoop  = Inf; end
        if nbin<6 , ColType  = 'rgb'; end
        if nbin<7 , stepFLAG = 1; end
        if nbin<8 
            if ~isnan(stepFLAG) , CurrentAxe = gca; else CurrentAxe = []; end 
        end

        [X,ColMAT] = wimgcolconv(ColType,X);
        sX = size(X);
        level = min([fix(log2(min(sX(1:2)))),level]);

        % 1) - Initialization.
        %=====================
        if ~isequal(wname,'none')
            [C,S] = wavedec2(X,level,wname);
            Y = wcfs2mat(C,S);
        else
            Y = X;
            [dummy,S] = wavedec2(X,level,'haar'); %#ok<ASGLU>
        end
        [rY,cY,BitPlan] = size(Y);
        Signific_MAT = zeros(rY,cY,BitPlan);
        nb_PIX = rY*cY;

        %------------------------------------
        maxiY = max(abs(double(Y(:))));
        n = round(log2(maxiY));
        if maxiY<2^n , n = n-1; end
        if nbin<4 && isempty(MaxLoop) , MaxLoop = n-3; end
        %--------------------------------------------------
        WTC_Struct.Header.Row     = rY;
        WTC_Struct.Header.Col     = cY;
        WTC_Struct.Header.BitPlan = BitPlan;
        WTC_Struct.Header.ColType = ColType;
        WTC_Struct.Header.ColMAT  = ColMAT;
        WTC_Struct.Header.Power   = n;
        WTC_Struct.Header.Level   = level;
        WTC_Struct.Header.MaxLoop = MaxLoop;
        WTC_Struct.Header.Methode = wname;
        WTC_Struct.Header.BitPlan_Encode = false;
        WTC_Struct.LoopMarker     = [];
        %-------------------------------
        % IF NOT BitPlaneEncoding:
        %     WTC_Struct.Refine_Stream = [];
        %     WTC_Struct.Indices   = [];
        %     WTC_Struct.Signs     = [];
        % ELSE
        %     WTC_Struct.BitStream = [];
        % END
        %-------------------------------        
        Refine_Stream  = [];        
        PtrRefine   = 0;
        PtrSignific = 0;
        nbValInMat  = numel(X);
        LST_Val_Signif = zeros(nbValInMat,4);
        Matrice_TMP = Y;
        
        % Scanning order.
        %---------------
        scan_IDX = wfandfcidx('scan_1',S);
        scan_Plan_INI = zeros(nb_PIX,BitPlan);        
        for bp = 1:BitPlan
            scan_Plan_INI(:,bp) = scan_IDX+(bp-1)*nb_PIX;
        end
        scan_Plan_INI = scan_Plan_INI(:);
        % scan_Plan_INI = scan_Plan_INI';
        % scan_Plan_INI = scan_Plan_INI(:);
        
        % For GUI: Step by Step.
        test_step_by_step('ini',stepFLAG);        

        % Initialization of loop parameters.
        MoreLoop = true;
        numLoop = 0;
        MarkerEndLoop = zeros(1,20);
        while MoreLoop
            % 1) Compute numLoop and Threshold.
            %----------------------------------
            numLoop = numLoop + 1;
            Thres = 2^n;
            
            % 2) Significance Pass.
            %----------------------
            SigniFicant = abs(Matrice_TMP(scan_Plan_INI))>=Thres;            
            idx_in_MAT  = scan_Plan_INI(SigniFicant);
            val_SIGNIF  = Matrice_TMP(idx_in_MAT);
            SGN_SIGNIF  = double(sign(val_SIGNIF));
            nb_SIGNIF   = length(idx_in_MAT);            
            index_SIGNIF = (1:nbValInMat);
            index_SIGNIF = index_SIGNIF(SigniFicant);
            Matrice_TMP(idx_in_MAT) = 0;
            
            PtrSignific = PtrSignific + 1;
            EndSignific = PtrSignific + nb_SIGNIF-1;
            LST_Val_Signif(PtrSignific:EndSignific,1) = idx_in_MAT;
            LST_Val_Signif(PtrSignific:EndSignific,3) = SGN_SIGNIF(:);
            LST_Val_Signif(PtrSignific:EndSignific,4) = index_SIGNIF;
            LST_Val_Signif(PtrSignific:EndSignific,2) = abs(val_SIGNIF(:));
            PtrSignific = EndSignific;                       
            Signific_MAT(idx_in_MAT) = ...
                Signific_MAT(idx_in_MAT) + SGN_SIGNIF*Thres;
            if iscell(stepFLAG) || stepFLAG>1
                plotIMAGE_ENC('sig'); 
            end

            % 3) Refinement Pass.
            %--------------------
            % Search the "Pixels" to refine.
            idx2Change = (1:PtrSignific);
            nbVal2Change = PtrSignific;
            sub_thres = fix(Thres/2);
            MarkerEndLoop(numLoop) = PtrSignific;
            if sub_thres>0
                AND_Val  = ...
                    bitand(round(LST_Val_Signif(idx2Change,2)),sub_thres);
                idx_ONES = (AND_Val~=0);
                TMP = '0';
                TMP = TMP(ones(1,nbVal2Change));
                TMP(idx_ONES) = '1';
                
                first = PtrRefine + 1;
                last  = first + nbVal2Change-1;
                Refine_Stream(first:last) = TMP;
                PtrRefine = last;
                
                idx_IN_LST = idx2Change(idx_ONES);
                idx2MODIFY = LST_Val_Signif(idx_IN_LST,1);
                SGN  = LST_Val_Signif(idx_IN_LST,3);
                Plus = zeros(size(Y));
                Plus(idx2MODIFY) = SGN*sub_thres;
                Signific_MAT(idx2MODIFY) = ...
                    Signific_MAT(idx2MODIFY) + Plus(idx2MODIFY);                
                
                % "Reconstruction" (and Display of "Image")
                plotIMAGE_ENC('ref');
                
            end
            
            % "Reconstruction" (and Display of "Image")
            plotIMAGE_ENC('end');

            % 4) Quantization step update.
            %-----------------------------
            n = n-1;
            MoreLoop = n>=0 && numLoop<MaxLoop;

        end  % END of: while MoreLoop
        plotIMAGE_ENC('final');
        test_step_by_step('close',stepFLAG);

        LST_Val_Signif = LST_Val_Signif(1:PtrSignific,:);
        if ~isequal(wname,'none') , dwtmode(old_modeDWT,'nodisp');  end

        MarkerEndLoop(numLoop+1:end) = [];     
        if any(MarkerEndLoop>=PtrSignific)
            nbLoopSignif = find(MarkerEndLoop>=PtrSignific,1,'first');
        else
            nbLoopSignif = find(MarkerEndLoop==0,1,'first')-1;
        end
        diffMarkerEndLoop = [MarkerEndLoop(1) , diff(MarkerEndLoop)];       
        MarkerBegLoop = [1 MarkerEndLoop+1];        
        Signs = LST_Val_Signif(:,3);
        Indices = [LST_Val_Signif(1,4) ; diff(LST_Val_Signif(:,4))];
        Idx_toChange  = MarkerBegLoop(MarkerBegLoop<PtrSignific);
        Indices(Idx_toChange) = LST_Val_Signif(Idx_toChange,4);
        if WTC_Struct.Header.BitPlan_Encode
            BitPlane_Encoding;
        else
            WTC_Struct.LoopMarker = diffMarkerEndLoop;
            WTC_Struct.Signs   = Signs;
            WTC_Struct.Indices = Indices;
            WTC_Struct.Refine_Stream = Refine_Stream;
        end

        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
        function BitPlane_Encoding

            BitStream  = blanks(100);
            SignStream = blanks(length(Signs));
            SignStream(Signs>=0) = 'P';
            SignStream(Signs<0)  = 'N';
            clear Signs
            PtrBitStream = 0;
            firstRaf = 1;
            for k = 1:length(diffMarkerEndLoop)
                if k<=nbLoopSignif
                    first = MarkerBegLoop(k);
                    last  = MarkerEndLoop(k);
                    for j = first:last
                        % tmp = dec2bin(Indices(j));
                        % tmp = tmp(2:end);
                        dd = Indices(j);
                        [ff,ee] = log2(dd); %#ok<ASGLU>
                        tmp = char(rem(floor(dd*pow2(2-ee:0)),2)+'0');
                        nbVal = length(tmp);
                        PtrBitStream = PtrBitStream + 1;
                        endBitStream = PtrBitStream + nbVal;
                        lenStream    = length(BitStream);
                        if endBitStream>endBitStream
                            BitStream(2*lenStream) = 0;
                        end
                        BitStream(PtrBitStream:endBitStream) = ...
                            [SignStream(j), tmp];
                        PtrBitStream = endBitStream;
                    end

                    % End Marker.
                    %------------
                    % tmp = dec2bin(MarkerEndLoop(k));
                    % tmp = tmp(2:end);
                    dd = MarkerEndLoop(k);
                    [ff,ee] = log2(dd); %#ok<ASGLU>
                    tmp = char(rem(floor(dd*pow2(2-ee:0)),2)+'0');
                    nbVal = length(tmp) + 2;
                    PtrBitStream = PtrBitStream + 1;
                    endBitStream = PtrBitStream + nbVal-1;
                    BitStream(PtrBitStream:endBitStream) = ['P' , tmp , 'P'];
                    PtrBitStream = endBitStream;
                end

                % Refinement.
                %------------
                if MarkerEndLoop(k)>0
                    nbVal   = last;
                    lastRaf = firstRaf + nbVal-1;
                    if lastRaf<=length(Refine_Stream)
                        PtrBitStream = PtrBitStream + 1;
                        endBitStream = PtrBitStream + nbVal - 1;
                        lenStream = length(BitStream);
                        if endBitStream>endBitStream
                            BitStream(2*lenStream) = 0;
                        end
                        BitStream(PtrBitStream:endBitStream) = ...
                            Refine_Stream(firstRaf:lastRaf);
                        PtrBitStream = endBitStream;
                        firstRaf = lastRaf+1;
                    end
                end
            end
            BitStream(PtrBitStream+1:end) = [];
            WTC_Struct.BitStream  = BitStream;
            WTC_Struct.LoopMarker = diffMarkerEndLoop;
        end
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
        function Xrec = plotIMAGE_ENC(ARGIN)
            
            % For GUI: Step by Step.
            [save_stepFLAG,stepFLAG] = test_step_by_step('beg',stepFLAG);
                        
            Xrec = [];
            convFLAG = ~isnan(stepFLAG) && ...
                (stepFLAG==1 || (numLoop==MaxLoop));
            if convFLAG || (numLoop==MaxLoop)
                if ~isequal(wname,'none')
                    [CFS,sizeCFS] = wmat2cfs(Signific_MAT,level,[rY,cY]);
                    Xrec = waverec2(CFS,sizeCFS,wname);
                else
                    Xrec = Signific_MAT;
                end
                Xrec = wimgcolconv(['inv' ColType],Xrec,ColMAT);
                if ndims(Xrec)>2 , Xrec = uint8(Xrec); end %#ok<*ISMAT>
            end            
            
            if convFLAG
                if ~isequal(ARGIN,'final')
                    switch ARGIN
                        case 'sig'
                            strTitle = ...
                                getWavMSG('Wavelet:divGUIRF:WTC_Loop_Sig', ...
                                    numLoop);
                        case 'ref'
                            strTitle = ...
                                getWavMSG('Wavelet:divGUIRF:WTC_Loop_Ref', ...
                                    numLoop);
                        case 'end'
                            strTitle = ...
                                getWavMSG('Wavelet:divGUIRF:WTC_Loop_End', ...
                                    numLoop);
                    end
                else
                    strTitle = getWavMSG('Wavelet:commongui:CompImg');
                end
                image(Xrec,'Parent',CurrentAxe);   
                wtitle(strTitle,'Parent',CurrentAxe);   
                pause(0.01)
                
                % For GUI: Step by Step.
                if iscell(save_stepFLAG)
                    [save_stepFLAG,stepFLAG] = ...
                        test_step_by_step('end',save_stepFLAG); %#ok<ASGLU>
                end
                
            end
        end
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%

    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function Xrec = wtc_wdr_dec(WTC_Struct,stepFLAG)

        CurrentAxe = [];
        nbin = nargin;
        if nbin<2 , stepFLAG = 3; end
        if ischar(WTC_Struct)
            WTC_Struct = wtcmngr('load',typeSAVE,WTC_Struct);
        end

        % 1) - Initialization.
        %=====================
        rY      = WTC_Struct.Header.Row;
        cY      = WTC_Struct.Header.Col;
        BitPlan = WTC_Struct.Header.BitPlan;
        ColType = WTC_Struct.Header.ColType;
        ColMAT  = WTC_Struct.Header.ColMAT;
        n       = WTC_Struct.Header.Power;
        wname   = WTC_Struct.Header.Methode;
        level   = WTC_Struct.Header.Level;
        MaxLoop = WTC_Struct.Header.MaxLoop;       
        BitPlan_Encode = WTC_Struct.Header.BitPlan_Encode;
        diffMarkerEndLoop = WTC_Struct.LoopMarker;
        
        nb_PIX = rY*cY;
        nb_VAL = rY*cY*BitPlan;
        Signific_MAT = zeros(rY,cY,BitPlan);
        
        MarkerEndLoop = cumsum(diffMarkerEndLoop);
        MarkerBegLoop = [1 MarkerEndLoop+1];
        nbLoopSignif = length(diffMarkerEndLoop);
        if ~BitPlan_Encode
            Refine_Stream = WTC_Struct.Refine_Stream;
            SignStream = WTC_Struct.Signs;
            Indices = WTC_Struct.Indices;
        else
            BitPlan_Decoding;
        end
        
        % For decoding.
        %--------------
        Refine_Stream = Refine_Stream-48; % To obtain 0 or 1
        Refine_Stream = Refine_Stream(:);
        Signs = ones(size(SignStream))';       
        Signs(SignStream=='N') = -1;
        Signs = Signs(:);
        for kk = 1:nbLoopSignif
            first = MarkerBegLoop(kk);
            last  = MarkerEndLoop(kk);
            Indices(first:last) = cumsum(Indices(first:last));
        end
        
        if ~isequal(wname,'none')
            old_modeDWT = dwtmode('status','nodisp');
            modeDWT = 'per';
            dwtmode(modeDWT,'nodisp');
        end
        SizeINI = [rY cY];
        [sizeCFS,sizesUTL] = getsizes(level,SizeINI); %#ok<NASGU>
        S = sizeCFS(1:end,:);
       
        % Scanning order.
        %---------------
        scan_IDX = wfandfcidx('scan_1',S);
        scan_Plan_INI = zeros(nb_PIX,BitPlan);        
        for bp = 1:BitPlan
            scan_Plan_INI(:,bp) = scan_IDX+(bp-1)*nb_PIX;
        end
        scan_Plan_INI = scan_Plan_INI(:);
        % scan_Plan_INI = scan_Plan_INI';
        % scan_Plan_INI = scan_Plan_INI(:);        
        
        Indices2RAF = zeros(nb_VAL,1);
        iBegRAF  = 1;
        numLoop  = 0;
        MoreLoop = true;
        firstRaf = 1;
        while MoreLoop
            % Compute numLoop and Threshold.
            %-------------------------------
            numLoop = numLoop + 1;
            Thres = 2^n;
            
            % 2) Significance Pass.
            %----------------------
            if numLoop<=nbLoopSignif
                first = MarkerBegLoop(numLoop);
                last  = MarkerEndLoop(numLoop);
                idx_in_MAT = scan_Plan_INI(Indices(first:last));
                iEndRAF = iBegRAF + length(idx_in_MAT)-1;
                Indices2RAF(iBegRAF:iEndRAF) = idx_in_MAT;
                iBegRAF = iEndRAF+1;
                Signific_MAT(idx_in_MAT) = ...
                    Signific_MAT(idx_in_MAT) + Signs(first:last)*Thres;
                if stepFLAG>1 , plotIMAGE; end
            end
                      
            % 3) Refinement Pass.
            %--------------------            
            nb2change  = last;
            lastRaf = firstRaf + nb2change-1;
            if lastRaf<=length(Refine_Stream)
                RAF = Refine_Stream(firstRaf:lastRaf);
                firstRaf = lastRaf+1;
                
                Idx2RAF = Indices2RAF(1:iEndRAF);
                Signific_MAT(Idx2RAF) = ...
                    Signific_MAT(Idx2RAF) + RAF.*Signs(1:last)*Thres/2;
                plotIMAGE;
            end
            [Xrec,convFLAG] = plotIMAGE;
                                   
            % 4) Quantization step update.
            %-----------------------------
            n = n-1;
            MoreLoop = n>=0 && numLoop<MaxLoop;

        end  % END of: while MoreLoop
        if convFLAG
             strTitle = getWavMSG('Wavelet:commongui:CompImg');
             wtitle(strTitle,'Parent',gca); pause(0.01)
        end
        if ~isequal(wname,'none') , dwtmode(old_modeDWT,'nodisp');  end
 
        
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
        function BitPlan_Decoding
            
            BitStream = WTC_Struct.BitStream;
            PtrBitStream = 0;
            Refine_Stream  = zeros(nb_PIX,1);
            firstRaf = 1;
            Pos = find(BitStream=='P');
            Neg = find(BitStream=='N');
            for k = 1:length(diffMarkerEndLoop)
                first = MarkerBegLoop(k);
                last  = MarkerEndLoop(k);
                if k<=nbLoopSignif
                    for j = first:last
                        PtrBitStream  = PtrBitStream + 1;
                        SignStream(j) = BitStream(PtrBitStream);
                        I1 = find((Pos>PtrBitStream),1,'first');
                        I2 = find((Neg>PtrBitStream),1,'first');
                        P_or_N = min([Pos(I1) Neg(I2)]);
                        endBitStream = P_or_N-1;
                        PtrBitStream  = PtrBitStream + 1;
                        tmp = BitStream(PtrBitStream:endBitStream);
                        % Indices(j) = bin2dec(['1' tmp]);
                        v = ['1' tmp] - '0';
                        len = length(v);
                        Indices(j) = sum(v .*pow2(len-1:-1:0),2);
                        PtrBitStream = endBitStream;
                    end

                    % End Marker.
                    %------------
                    I1 = find((Pos>PtrBitStream),2,'first');
                    I1 = Pos(I1);
                    if ~isempty(I1)
                        % tmp = BitStream(I1(1)+1:I1(2)-1);
                        % New_MarkerEndLoop(k) = bin2dec(['1' tmp]);
                        % v = ['1' tmp] - '0';
                        % len = length(v);
                        % New_MarkerEndLoop(k) = sum(v .*pow2(len-1:-1:0),2);                        
                        PtrBitStream = I1(2);
                    end
                end

                % Refinement.
                %------------
                if MarkerEndLoop(k)>0
                    nbVal   = last;
                    lastRaf = firstRaf + nbVal-1;
                    PtrBitStream = PtrBitStream + 1;
                    endBitStream = PtrBitStream + nbVal - 1;
                    if endBitStream<=length(BitStream)
                        Refine_Stream(firstRaf:lastRaf) = ...
                            BitStream(PtrBitStream:endBitStream);
                        PtrBitStream = endBitStream;
                        firstRaf = lastRaf+1;
                    end
                end
            end

        end
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
        function [Xrec,convFLAG] = plotIMAGE
            Xrec = [];
            convFLAG = ~isnan(stepFLAG) && (stepFLAG==1 || (numLoop==MaxLoop));
            if convFLAG || (numLoop==MaxLoop)
                if ~isequal(wname,'none')
                    [CFS,sizeCFS] = wmat2cfs(Signific_MAT,level,[rY,cY]);
                    Xrec = waverec2(CFS,sizeCFS,wname);
                else
                    Xrec = Signific_MAT;
                end
                Xrec = wimgcolconv(['inv' ColType],Xrec,ColMAT);
                if ndims(Xrec)>2 , Xrec = uint8(Xrec); end
            end
            if convFLAG
                if isempty(CurrentAxe) , CurrentAxe = gca; end
                image(Xrec,'Parent',CurrentAxe);
                wtitle(getWavMSG('Wavelet:divGUIRF:WTC_Loop',numLoop), ...
                    'Parent',CurrentAxe);
                pause(0.01)
            end
        end
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function fileSize = wtc_wdr_save(typeSAVE,filename,WTC_Struct)   

        % File settings.
        %---------------
        tmp_filename = def_tmpfile(filename);
        fid = fopen(tmp_filename,'wb');

        % Select type of endcoding.
        %--------------------------
        BitPlan_Encode = WTC_Struct.Header.BitPlan_Encode;
        if ~BitPlan_Encode
            nb_IDX = length(WTC_Struct.Indices);
            nb_SGN = length(WTC_Struct.Signs);
            nb_RAF = length(WTC_Struct.Refine_Stream);
            SignsStream = blanks(nb_SGN);
            SignsStream(:) = 'P';
            SignsStream(WTC_Struct.Signs<0) = 'N';
            WTC_Struct.BitStream = [...
               SignsStream  char(WTC_Struct.Refine_Stream)];
            WTC_Struct = rmfield(WTC_Struct,{'Signs','Refine_Stream'});
        end
        LenOfBitStream = length(WTC_Struct.BitStream);
        [bwt_IDX,mtf_VAL,HC_Struct] = bwc_algo('e',...
            bwt_OPTION,mtf_OPTION,alphabet,WTC_Struct.BitStream);
        TabCODE = HC_Struct.HC_tabENC;
        HCTab = HC_Struct.HC_codes;        
                        
        % Begin Saving.
        %--------------
        codeID = wtcmngr('meth_ident',typeSAVE,'wdr');
        fwrite(fid,codeID,'ubit8');
        fwrite(fid,BitPlan_Encode,'uint8');
        if ~BitPlan_Encode
            fwrite(fid,nb_IDX,'uint32');
            fwrite(fid,nb_SGN,'uint32');
            fwrite(fid,nb_RAF,'uint32');
            fwrite(fid,WTC_Struct.Indices,'uint32');
        end
        fwrite(fid,LenOfBitStream,'uint32');
        fwrite(fid,bwt_IDX,'uint16');
        fwrite(fid,mtf_VAL,'int8');
        fwrite(fid,WTC_Struct.Header.Row,'uint16');
        fwrite(fid,WTC_Struct.Header.Col,'uint16');
        fwrite(fid,WTC_Struct.Header.BitPlan,'uint8');
        codeCOL = wimgcolconv(WTC_Struct.Header.ColType);
        fwrite(fid,codeCOL,'ubit3');
        if isequal(codeCOL,2)
            fwrite(fid,WTC_Struct.Header.ColMAT,'float32');
        end
        fwrite(fid,WTC_Struct.Header.Power,'uint8');
        nbCHAR = length(WTC_Struct.Header.Methode);
        fwrite(fid,nbCHAR,'ubit4');
        fwrite(fid,WTC_Struct.Header.Methode,'uint8');
        fwrite(fid,WTC_Struct.Header.Level,'uint8');
        fwrite(fid,WTC_Struct.Header.MaxLoop,'uint8');
        LenOfLoopMarker = length(WTC_Struct.LoopMarker);
        fwrite(fid,LenOfLoopMarker,'uint32');
        fwrite(fid,WTC_Struct.LoopMarker,'uint32');
        
        nbHC = length(HCTab);
        fwrite(fid,nbHC,'uint8');
        fwrite(fid,HCTab,'ubit2');
        lenCODE  = length(TabCODE);
        fwrite(fid,lenCODE,'uint32');
        fwrite(fid,TabCODE,'ubit1');
        
        try
            fclose(fid); 
        catch ME	%#ok<NASGU>
        end
        modify_wtcfile('save',filename,typeSAVE)
        fid = fopen(filename);
        [~,fileSize] = fread(fid);
        fclose(fid);
        
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function WTC_Struct = wtc_wdr_load(filename) 
        % File settings.
        %---------------
        tmp_filename  = def_tmpfile(filename);
        ok_TMP = exist(tmp_filename,'file');
        if ok_TMP
            fid = fopen(tmp_filename);
        else
            fid = fopen(filename);
        end

        codeID = fread(fid,1,'*char');  %#ok<NASGU> % Not used.
        WTC_Struct.Header.BitPlan_Encode = fread(fid,1,'uint8');
        if ~WTC_Struct.Header.BitPlan_Encode
            nb_IDX = fread(fid,1,'int32');
            nb_SGN = fread(fid,1,'int32');
            nb_RAF = fread(fid,1,'int32');
            WTC_Struct.Indices = fread(fid,nb_IDX,'uint32');
        end        
        LenOfBitStream = fread(fid,1,'uint32');
        bwt_IDX = fread(fid,1,'uint16');
        mtf_VAL = fread(fid,1,'int8');
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
        WTC_Struct.Header.Power = fread(fid,1,'uint8');
        nbCHAR = fread(fid,1,'ubit4');
        wname  = fread(fid,nbCHAR,'uint8');
        WTC_Struct.Header.Methode = char(wname');
        WTC_Struct.Header.Level = fread(fid,1,'uint8');
        WTC_Struct.Header.MaxLoop = fread(fid,1,'uint8');
        
        LenOfLoopMarker = fread(fid,1,'uint32');
        WTC_Struct.LoopMarker = fread(fid,LenOfLoopMarker,'uint32')';
        
        nbHC = fread(fid,1,'uint8');
        HCTab = fread(fid,nbHC,'ubit2');
        lenCODE = fread(fid,1,'uint32');
        TabCODE = fread(fid,lenCODE,'ubit1');
        WTC_Struct.BitStream = bwc_algo('d', ...
            bwt_IDX,mtf_VAL,alphabet,LenOfBitStream,HCTab,TabCODE);
        
        if ~WTC_Struct.Header.BitPlan_Encode
            WTC_Struct.Signs = WTC_Struct.BitStream(1:nb_SGN);
            first = nb_SGN+1;
            last = first + nb_RAF-1;
            WTC_Struct.Refine_Stream = WTC_Struct.BitStream(first:last);
            WTC_Struct = rmfield(WTC_Struct,{'BitStream'});
        end
        
        fclose(fid);
        if ok_TMP , delete(tmp_filename); end

    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function fileSize = wtc_wdr_save_NEW(typeSAVE,filename,WTC_Struct)   %#ok<DEFNU>

        % File settings.
        %---------------
        tmp_filename = def_tmpfile(filename);
        fid = fopen(tmp_filename,'wb');

        % Select type of endcoding.
        %--------------------------
        BitPlan_Encode = WTC_Struct.Header.BitPlan_Encode;
        if ~BitPlan_Encode
            nb_IDX = length(WTC_Struct.Indices);
            nb_SGN = length(WTC_Struct.Signs);
            nb_RAF = length(WTC_Struct.Refine_Stream);
            WTC_Struct.Signs(WTC_Struct.Signs<0) = 0;
        else
            LenOfBitStream = length(WTC_Struct.BitStream);
            [bwt_IDX,mtf_VAL,TabCODE,HCTab] = bwc_algo('e',...
                bwt_OPTION,mtf_OPTION,alphabet,WTC_Struct.BitStream);
        end
                        
        % Begin Saving.
        %--------------
        codeID = wtcmngr('meth_ident',typeSAVE,'wdr');
        fwrite(fid,codeID,'ubit8');
        fwrite(fid,BitPlan_Encode,'uint8');
        fwrite(fid,WTC_Struct.Header.Row,'uint16');
        fwrite(fid,WTC_Struct.Header.Col,'uint16');
        fwrite(fid,WTC_Struct.Header.BitPlan,'uint8');
        codeCOL = wimgcolconv(WTC_Struct.Header.ColType);
        fwrite(fid,codeCOL,'ubit3');
        if isequal(codeCOL,2)
            fwrite(fid,WTC_Struct.Header.ColMAT,'float32');
        end
        fwrite(fid,WTC_Struct.Header.Power,'uint8');
        nbCHAR = length(WTC_Struct.Header.Methode);
        fwrite(fid,nbCHAR,'ubit4');
        fwrite(fid,WTC_Struct.Header.Methode,'uint8');
        fwrite(fid,WTC_Struct.Header.Level,'uint8');
        fwrite(fid,WTC_Struct.Header.MaxLoop,'uint8');
        LenOfLoopMarker = length(WTC_Struct.LoopMarker);
        fwrite(fid,LenOfLoopMarker,'uint32');
        fwrite(fid,WTC_Struct.LoopMarker,'uint32');
        if ~BitPlan_Encode
            fwrite(fid,nb_IDX,'uint32');
            fwrite(fid,WTC_Struct.Indices,'uint32');
            fwrite(fid,nb_SGN,'uint32');
            fwrite(fid,WTC_Struct.Signs,'ubit1');
            fwrite(fid,nb_RAF,'uint32');
            WTC_Struct.Refine_Stream = WTC_Struct.Refine_Stream-48;
            fwrite(fid,WTC_Struct.Refine_Stream,'ubit1');
        else
            fwrite(fid,LenOfBitStream,'uint32');
            fwrite(fid,mtf_VAL,'int8');
            fwrite(fid,bwt_IDX,'uint16');
            nbHC = length(HCTab);
            fwrite(fid,nbHC,'uint8');
            fwrite(fid,HCTab,'ubit2');
            lenCODE  = length(TabCODE);
            fwrite(fid,lenCODE,'uint32');
            fwrite(fid,TabCODE,'ubit1');
        end
        
        try   fclose(fid); 
        catch ME    %#ok<NASGU>
        end
        modify_wtcfile('save',filename,typeSAVE)
        fid = fopen(filename);
        [~,fileSize] = fread(fid);
        flcose(fid)
        
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function WTC_Struct = wtc_wdr_load_NEW(filename)   %#ok<DEFNU>
        % File settings.
        %---------------
        tmp_filename  = def_tmpfile(filename);
        ok_TMP = exist(tmp_filename,'file');
        if ok_TMP
            fid = fopen(tmp_filename);
        else
            fid = fopen(filename);
        end

        codeID = fread(fid,1,'*char');  %#ok<NASGU> % Not used.
        WTC_Struct.Header.BitPlan_Encode = fread(fid,1,'uint8');
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
        WTC_Struct.Header.Power = fread(fid,1,'uint8');
        nbCHAR = fread(fid,1,'ubit4');
        wname  = fread(fid,nbCHAR,'uint8');
        WTC_Struct.Header.Methode = char(wname');
        WTC_Struct.Header.Level = fread(fid,1,'uint8');
        WTC_Struct.Header.MaxLoop = fread(fid,1,'uint8');
        LenOfLoopMarker = fread(fid,1,'uint32');
        WTC_Struct.LoopMarker = fread(fid,LenOfLoopMarker,'uint32')';
        if ~WTC_Struct.Header.BitPlan_Encode
            nb_IDX = fread(fid,1,'int32');
            WTC_Struct.Indices = fread(fid,nb_IDX,'uint32');
            nb_SGN = fread(fid,1,'int32');
            WTC_Struct.Signs = fread(fid,nb_SGN,'ubit1');
            WTC_Struct.Signs(WTC_Struct.Signs==0) = -1;
            nb_RAF = fread(fid,1,'int32');
            WTC_Struct.Refine_Stream = fread(fid,nb_RAF,'ubit1');
            WTC_Struct.Refine_Stream = char((WTC_Struct.Refine_Stream + 48)');
        else
            LenOfBitStream = fread(fid,1,'uint32');
            mtf_VAL = fread(fid,1,'int8');
            bwt_IDX = fread(fid,1,'uint16');            
            nbHC = fread(fid,1,'uint8');
            HCTab = fread(fid,nbHC,'ubit2');
            lenCODE = fread(fid,1,'uint32');
            TabCODE = fread(fid,lenCODE,'ubit1');
            WTC_Struct.BitStream = bwc_algo('d', ...
                bwt_IDX,mtf_VAL,alphabet,LenOfBitStream,HCTab,TabCODE);
         end        
        
        fclose(fid);
        if ok_TMP , delete(tmp_filename); end
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%

end  % End of WTC_WDR.M