function varargout = wtc_spiht_3d(option,typeSAVE,varargin)
%WTC_SPIHT Main program for WTC_SPIHT encoding.
%
%   VARARGOUT = WTC_SPIHT_3D(OPTION,VARARGIN)
%
%   WTC_SPIHT_3D('encode', ... )
%   WTC_SPIHT_3D('decode', ... )
%   WTC_SPIHT_3D('save', ... )
%   WTC_SPIHT_3D('load', ... )

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Jun-2004.
%   Last Revision: 03-Apr-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

nbC = 1;
numOPT = find(strncmpi(option,{'encode','decode','save','load'},nbC));
nbout = nargout;
switch numOPT
    %-- 'encode' --%
    case 1 , [varargout{1:nbout}] = wtc_spiht_enc(varargin{:});
        %-- 'decode' --%
    case 2 , [varargout{1:nbout}] = wtc_spiht_dec(varargin{:});
        %--- 'save' ---%
    case 3 , [varargout{1:nbout}] = wtc_spiht_save(typeSAVE,varargin{:});
        %--- 'load' ---%
    case 4 , [varargout{1:nbout}] = wtc_spiht_load(varargin{:});
end


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
function WTC_Struct = wtc_spiht_enc(X,wname,level,modeDWT,...
            MaxLoop,ColType,stepFLAG,CurrentAxe) %#ok<*INUSL>
%WTC_SPIHT_ENC Main program - EZW-SPIHT codes matrix X.

nbin = nargin;
if nbin<2 , wname    = 'haar'; end
if nbin<3 , level    = Inf; end
if nbin<4 , modeDWT  = dwtmode('status','nodisp'); end %#ok<*NASGU>
if ~isequal(wname,'none')
    old_modeDWT = dwtmode('status','nodisp');
    modeDWT = 'per';
    dwtmode(modeDWT,'nodisp');
end
if nbin<5 , MaxLoop  = Inf; end
if nbin<6, ColType  = 'rgb'; end
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

nb_PIX  = rY*cY;
idxR = (0:2^(log2(rY)-level+1)-1);
idxC = (0:2^(log2(cY)-level+1)-1);
len_idxR = length(idxR);
len_idxC = length(idxC);
sizLIP = len_idxR*len_idxC;
%------------------------------------
% LSP <== List of Significant Pixels
% LIP <== List of Insignificant Pixels
% LIS <== List of Insignificant Sets
%------------------------------------
% Initialization of LSP: List of Significant Pixels.
LSP = zeros(nb_PIX,3);
idx_LSP = 1;

% Initialization of LIP: List of Insignificant Pixels.
tmpRow = repmat(idxR,len_idxC,1);
tmpRow = tmpRow(:);
tmpCol = repmat(idxC',1,len_idxR);
tmpCol = tmpCol(:);
LIP = zeros(nb_PIX,2);
tmpXY = tmpCol*rY + tmpRow + 1;
tmpXY = repmat(tmpXY,1,BitPlan)';
tmpXY = tmpXY(:);
lenXY = length(tmpXY);
LIP(1:lenXY,1) = tmpXY;
LIP(1:lenXY,2) = repmat((1:BitPlan),1,sizLIP)';
idxEnd_LIP = lenXY;
clear tmpRow tmpCol tmpXY

% Initialization of LIS: List of Insignificant Sets.
LIS = LIP;
LIS(1:BitPlan,:) = [];
LIS(:,3) = 0;

% Initialization of buffers for Tree Crossing.
Crossing_Tree_LIP = false(nb_PIX,BitPlan);
Crossing_Tree_LIS = false(nb_PIX,BitPlan);

%------------------------------------
n = round(log2(max(abs(double(Y(:))))));
if nbin<4 && isempty(MaxLoop) , MaxLoop = n-3; end
%--------------------------------------------------
WTC_Struct.Header.Row     = rY;
WTC_Struct.Header.Col     = cY;
WTC_Struct.Header.BitPlan = BitPlan;
WTC_Struct.Header.ColType = ColType;
WTC_Struct.Header.ColMAT  = ColMAT;
WTC_Struct.Header.Power   = n;
WTC_Struct.Header.Level   = level;
WTC_Struct.Header.MaxLoop = Inf;
WTC_Struct.Header.Methode = wname;
WTC_Struct.BitStream      = [];
WTC_Struct.BitSignes      = [];
WTC_Struct.SigBIT         = [];
%--------------------------------------------------
[TabFATHER,TabFirstCHILD] = wfandfcidx('qtFC',S);
sigMAP = significant_map('spiht_3d',Y,TabFATHER);
sigMAP_3d = zeros(nb_PIX,BitPlan+2);
sigMAP_3d(:,1:BitPlan) = sigMAP(:,1:3:end);
sigMAP_3d(:,BitPlan+1) = max(sigMAP(:,2:3:end),[],2);
sigMAP_3d(:,BitPlan+2) = max(sigMAP(:,3:3:end),[],2);

% Initialization of buffers for BitStream.
TMP_BitStream   = zeros(1,3*nb_PIX);  PtrStream = 0;
TMP_BitSignes   = zeros(1,nb_PIX);    PtrSignes = 0;
TMP_SignificBIT = zeros(1,nb_PIX);    PtrSigBIT = 0;

% For GUI: Step by Step.
test_step_by_step('ini',stepFLAG);

% Initialization of loop parameters.
MoreLoop = true;
numLoop = 0;

while MoreLoop
    % Compute numLoop and Threshold.
    %-------------------------------
    numLoop = numLoop + 1;
    Thres = 2^n;
    
    % Buffers for Tree Crossing.
    %---------------------------
    Crossing_Tree_PIX_A = false(nb_PIX,1);
    Crossing_Tree_PIX_A_VAL = false(nb_PIX,1);
    Crossing_Tree_PIX_B = false(nb_PIX,1);
    Crossing_Tree_PIX_B_VAL = false(nb_PIX,1);
    
    % 2) - Sorting Loop.
    %===================
    % 2.1) - LIP management
    %-----------------------
    % Compute the significant value.
    % Compute the storage location on Stream buffer.
    % Reset the Stream buffer size if necessary.
    % Store the significant value (0 or 1) on Stream buffer.
    %-------------------------------------------------------
    idx_PIX_Plan = LIP(1:idxEnd_LIP,1:2);    
    idxInSigMAP  = idx_PIX_Plan(:,1)+(idx_PIX_Plan(:,2)-1)*nb_PIX;
    Signific = (sigMAP_3d(idxInSigMAP)>=Thres);
    %---
    PtrStream = PtrStream + 1;
    endStream = PtrStream + length(Signific)-1;
    lenStream = length(TMP_BitStream);
    if endStream>lenStream , TMP_BitStream(1,2*lenStream) = 0; end
    %---   
    TMP_BitStream(PtrStream:endStream) = Signific;
    PtrStream = endStream;

    % Compute the significant value equal to 1.
    % Compute the storage location on LSP buffer.
    % Reset the LSP buffer size if necessary.
    % Store the significant pixels on LSP buffer.
    %--------------------------------------------
    len_NewLSP = sum(Signific);
    idx_LSP_end = idx_LSP+len_NewLSP-1;
    len_LSP = size(LSP,1);
    if idx_LSP_end>len_LSP , LSP(2*len_LSP,3) = 0; end
    %---
    LSP(idx_LSP:idx_LSP_end,:) = ...
        [LIP(Signific,1:2),numLoop*ones(len_NewLSP,1)];
    idx_LSP = idx_LSP_end+1;

    % Compute the signs and update the Signific_MAT.
    % Compute the storage location on Sign buffer
    % and Reset the Sign buffer size if necessary.
    % Then store the sign values on BitSign buffer.
    %----------------------------------------------
    idx_PIX_Plan = LIP(Signific,1:2);
    LIPidx_TMP = idx_PIX_Plan(:,1)+(idx_PIX_Plan(:,2)-1)*nb_PIX;
    signLSP = sign(Y(LIPidx_TMP));
    Signes  = signLSP>0;
    Signific_MAT(LIPidx_TMP) = signLSP*Thres;
    %---
    PtrSignes = PtrSignes + 1;
    endSignes = PtrSignes + length(Signes)-1;
    lenSignes = length(TMP_BitSignes);
    if endSignes>lenSignes , TMP_BitSignes(1,2*lenSignes) = 0; end
    %---
    TMP_BitSignes(PtrSignes:endSignes)= Signes;
    PtrSignes = endSignes;

    % Update the List of Insignificant Pixels.
    LIP(Signific,:) = [];
    idxEnd_LIP = idxEnd_LIP - len_NewLSP;

    % 2.2) - LIS management
    %-----------------------
    idx_End_LIS = size(LIS,1);
    idx_LIS = 0;
    continu = idx_LIS<idx_End_LIS;
    
    while continu
        idx_LIS = idx_LIS + 1;
        idx_PIX = LIS(idx_LIS,1);
        if idx_PIX>0
            k = idx_LIS;
            EntryB = (LIS(k,3)==1);
            Ic = TabFirstCHILD(idx_PIX);   % Ic = 2*idx_PIX-1
            
            idx_desc0 = [Ic , Ic+1 , Ic+rY, Ic+1+rY]; 
            C1 = idx_desc0(ones(1,BitPlan),:); C1 = C1(:);            
            C2 = (1:BitPlan)'; C2 = C2(:,ones(1,4)); C2 = C2(:);
            descend = [C1 , C2];
                                    
            if ~EntryB
                if ~Crossing_Tree_PIX_A(idx_PIX)
                    Crossing_Tree_PIX_A(idx_PIX) = true;
                    Signific_LIS_A = sigMAP_3d(idx_PIX,end-1)>=Thres;
                    Crossing_Tree_PIX_A_VAL(idx_PIX) = Signific_LIS_A;
                    %-----
                    PtrStream = PtrStream + 1;
                    lenStream = length(TMP_BitStream);
                    if PtrStream>lenStream
                        TMP_BitStream(1,2*lenStream) = 0;
                    end
                    TMP_BitStream(PtrStream) = Signific_LIS_A;
                    %-----
                else
                    Signific_LIS_A = Crossing_Tree_PIX_A_VAL(idx_PIX);
                end
                if Signific_LIS_A
                    for jj = 1:4
                        idx_CHILD = idx_desc0(jj);
                        for idx_Plan = 1:BitPlan
                            if ~Crossing_Tree_LIP(idx_CHILD,idx_Plan)
                                Crossing_Tree_LIP(idx_CHILD,idx_Plan) = true;
                                d_PIX_Plan = (idx_Plan-1)*nb_PIX;
                                Signific_LIS_desc = ...
                                    sigMAP_3d(idx_CHILD,idx_Plan)>=Thres;
                                PtrStream = PtrStream + 1;
                                TMP_BitStream(PtrStream) = Signific_LIS_desc;
                                if Signific_LIS_desc
                                    LSP(idx_LSP,1) = idx_CHILD;
                                    LSP(idx_LSP,2) = idx_Plan;
                                    LSP(idx_LSP,3) = numLoop;
                                    signLSP = sign(Y(idx_CHILD + d_PIX_Plan));
                                    %---
                                    PtrSignes = PtrSignes + 1;
                                    lenSignes = length(TMP_BitSignes);
                                    if PtrSignes>lenSignes
                                        TMP_BitSignes(1,2*lenSignes) = 0;
                                    end
                                    TMP_BitSignes(PtrSignes)= signLSP>0;
                                    %---
                                    idx_LSP = idx_LSP + 1;
                                    len_LSP = size(LSP,1);
                                    if idx_LSP>len_LSP,
                                        LSP(2*len_LSP,3) = 0;
                                    end
                                    Signific_MAT(idx_CHILD + d_PIX_Plan) = ...
                                        signLSP*Thres;
                                else
                                    idxEnd_LIP = idxEnd_LIP + 1;
                                    LIP(idxEnd_LIP,1) = idx_CHILD;
                                    LIP(idxEnd_LIP,2) = idx_Plan;
                                end
                            end
                        end
                    end

                    if ~isnan(TabFirstCHILD(idx_desc0(1)))
                        idx_End_LIS = idx_End_LIS + 1;
                        len_LIS = size(LIS,1);
                        %---
                        if idx_End_LIS>len_LIS
                            LIS(2*len_LIS,3) = 0;
                        end
                        LIS(idx_End_LIS,1) = LIS(k,1);
                        LIS(idx_End_LIS,2) = LIS(k,2);
                        LIS(idx_End_LIS,3) = 1;
                        LIS(k,:) = 0;
                        %---
                        k = idx_End_LIS;
                        EntryB = true;
                    else
                        LIS(k,:) = 0;
                    end
                end  % End of: if Signific_LIS
            end  % End of: if ~EntryB

            if EntryB
                if ~Crossing_Tree_PIX_B(idx_PIX)
                    Crossing_Tree_PIX_B(idx_PIX) = true;
                    Signific_LIS_B = sigMAP_3d(idx_PIX,end)>=Thres;
                    Crossing_Tree_PIX_B_VAL(idx_PIX) = Signific_LIS_B;
                    %-----
                    PtrStream = PtrStream + 1;
                    lenStream = length(TMP_BitStream);
                    if PtrStream>lenStream
                        TMP_BitStream(1,2*lenStream) = 0;
                    end
                    TMP_BitStream(PtrStream)= Signific_LIS_B;
                    %-----
                else
                    Signific_LIS_B = Crossing_Tree_PIX_B_VAL(idx_PIX);
                end
                
                if Signific_LIS_B                    
                    ttt = false(size(descend,1),1);
                    for kkk = 1:size(descend,1)
                        ttt(kkk) = ...
                            Crossing_Tree_LIS(descend(kkk,1),descend(kkk,2));
                        if ~ttt(kkk)
                            Crossing_Tree_LIS(descend(kkk,1),descend(kkk,2)) = true;
                        end
                    end
                    nbNEW = sum(~ttt);
                    if nbNEW>0
                        iBeg = idx_End_LIS + 1;
                        idx_End_LIS = idx_End_LIS + nbNEW;
                        len_LIS = size(LIS,1);
                        if idx_End_LIS>len_LIS , LIS(2*len_LIS,3) = 0; end
                        LIS(iBeg:idx_End_LIS,:) = [descend(~ttt,:) ,zeros(nbNEW,1)];
                    end
                    LIS(k,:) = 0;
                end
            end            
        end
        continu = idx_LIS<idx_End_LIS;
    end
    LIS(LIS(:,1)==0,:) = [];

    % 3) - Refinement Loop.
    %======================
    idx_LSP_Ref = LSP(1:idx_LSP-1,3)<numLoop;
    LSPidx = LSP(idx_LSP_Ref,1:2);
    if ~isempty(LSPidx)
        idx_PIX_Plan = LSPidx(:,1)+ (LSPidx(:,2)-1)*nb_PIX;
        Signific_Bit = bitget(round(sigMAP_3d(idx_PIX_Plan)),n+1);
        %---
        PtrSigBIT = PtrSigBIT+1;
        lenSigBIT = length(TMP_SignificBIT);
        if PtrSigBIT>lenSigBIT , TMP_SignificBIT(1,2*lenSigBIT) = 0; end
        endSigBIT = PtrSigBIT + length(LSPidx)-1;
        TMP_SignificBIT(PtrSigBIT:endSigBIT)= Signific_Bit;
        PtrSigBIT = endSigBIT;
        %---
        Signific_MAT(idx_PIX_Plan) = Signific_MAT(idx_PIX_Plan) + ...
            sign(Signific_MAT(idx_PIX_Plan)).*Signific_Bit*Thres;
    end
    
    % For GUI: Step by Step.
    [save_stepFLAG,stepFLAG] = test_step_by_step('beg',stepFLAG);

    % "Reconstruction" and Display of "Image"
    plotFLAG = ~isnan(stepFLAG) && ...
            (stepFLAG==1 || (numLoop==MaxLoop && stepFLAG>-1));
    if plotFLAG
        if ~isequal(wname,'none')
            [CFS,sizeCFS] = wmat2cfs(Signific_MAT,level,[rY,cY]);
            Xrec = waverec2(CFS,sizeCFS,wname);
        else
            Xrec = Signific_MAT;
        end
        Xrec = wimgcolconv(['inv' ColType],Xrec,ColMAT);
        if ndims(Xrec)>2 , Xrec = uint8(Xrec); end %#ok<*ISMAT>
        image(Xrec,'Parent',CurrentAxe);   
        title(getWavMSG('Wavelet:divGUIRF:WTC_Loop',numLoop), ...
            'Parent',CurrentAxe);   
        pause(0.01)
        
        % For GUI: Step by Step.
        if iscell(save_stepFLAG)
            [~,stepFLAG] = test_step_by_step('end',save_stepFLAG);
        end
        
    end

    % 4) - Quantization step update
    %------------------------------
    n = n-1;
    MoreLoop = n>=0 && numLoop<MaxLoop;

end
if plotFLAG
    strTitle = getWavMSG('Wavelet:commongui:CompImg');
    title(strTitle,'Parent',CurrentAxe);
    pause(0.01)   
end 
test_step_by_step('close',stepFLAG);
if ~isequal(wname,'none') , dwtmode(old_modeDWT,'nodisp'); end

% Update Compression Structure: WTC_Struct.
TMP_BitStream(PtrStream+1:end) = [];
TMP_BitSignes(PtrSignes+1:end) = [];
TMP_SignificBIT(PtrSigBIT+1:end) = [];
WTC_Struct.BitStream = uint8(TMP_BitStream);
WTC_Struct.BitSignes = uint8(TMP_BitSignes);
WTC_Struct.SigBIT    = uint8(TMP_SignificBIT);
WTC_Struct.Header.MaxLoop = numLoop;
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%



%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
function Xrec = wtc_spiht_dec(WTC_Struct,stepFLAG)

CurrentAxe = [];
nbin = nargin;
if nbin<2 , stepFLAG = 1; end
if ischar(WTC_Struct)
    WTC_Struct = wtc_spiht_load(WTC_Struct);
end
rY      = WTC_Struct.Header.Row;
cY      = WTC_Struct.Header.Col;
BitPlan = WTC_Struct.Header.BitPlan;
ColType = WTC_Struct.Header.ColType;
ColMAT  = WTC_Struct.Header.ColMAT;
n       = WTC_Struct.Header.Power;
wname   = WTC_Struct.Header.Methode;
level   = WTC_Struct.Header.Level;
MaxLoop = WTC_Struct.Header.MaxLoop;

% 1) - Initialization.
%=====================
if ~isequal(wname,'none')
    old_modeDWT = dwtmode('status','nodisp');
    modeDWT = 'per';
    dwtmode(modeDWT,'nodisp');
end
Signific_MAT = zeros(rY,cY,BitPlan);

nb_PIX  = rY*cY;
idxR = (0:2^(log2(rY)-level+1)-1);
idxC = (0:2^(log2(cY)-level+1)-1);
len_idxR = length(idxR);
len_idxC = length(idxC);
sizLIP = len_idxR*len_idxC;
%------------------------------------
% LSP <== List of Significant Pixels
% LIP <== List of Insignificant Pixels
% LIS <== List of Insignificant Sets
%------------------------------------
% Initialization of LSP: List of Significant Pixels.
LSP = zeros(nb_PIX,3);
idx_LSP = 1;

% Initialization of LIP: List of Insignificant Pixels.
tmpRow = repmat(idxR,len_idxC,1);
tmpRow = tmpRow(:);
tmpCol = repmat(idxC',1,len_idxR);
tmpCol = tmpCol(:);
LIP = zeros(nb_PIX,2);
tmpXY = tmpCol*rY + tmpRow + 1;
tmpXY = repmat(tmpXY,1,BitPlan)';
tmpXY = tmpXY(:);
lenXY = length(tmpXY);
LIP(1:lenXY,1) = tmpXY;
LIP(1:lenXY,2) = repmat((1:BitPlan),1,sizLIP)';
idxEnd_LIP = lenXY;
clear tmpRow tmpCol tmpXY

% Initialization of LIS: List of Insignificant Sets.
LIS = LIP;
LIS(1:BitPlan,:) = [];
LIS(:,3) = 0;

% Buffers for Tree Crossing.
Crossing_Tree_LIP = false(nb_PIX,BitPlan);
Crossing_Tree_LIS = false(nb_PIX,BitPlan);

%------------------------------------
PtrStream = 0;
PtrSignes = 0;
PtrSigBIT = 0;
numLoop   = 0;
MoreLoop  = true;
[sizeCFS,sizesUTL] = getsizes(level,[rY cY]); %#ok<NASGU>
S = sizeCFS(1:end,:);
[TabFATHER,TabFirstCHILD] = wfandfcidx('qtFC',S);    %#ok<ASGLU>

while MoreLoop
    
    % Compute numLoop and Threshold.
    %-------------------------------
    numLoop = numLoop + 1;
    Thres = 2^n;
    
    % Buffers for Tree Crossing.
    %---------------------------
    Crossing_Tree_PIX_A = false(nb_PIX,1);
    Crossing_Tree_PIX_A_VAL = false(nb_PIX,1);
    Crossing_Tree_PIX_B = false(nb_PIX,1);
    Crossing_Tree_PIX_B_VAL = false(nb_PIX,1);

    % 2) - Sorting Loop.
    %=====================
    % 2.1) - LIP management
    %-----------------------
    LIPidx    = LIP(1:idxEnd_LIP,1:2);
    PtrStream = PtrStream + 1;
    endStream = PtrStream + size(LIPidx,1)-1;
    Signific  = logical(WTC_Struct.BitStream(PtrStream:endStream));
    PtrStream = endStream;
    %---------------------------------------------------------
    len_NewLSP = sum(Signific);
    LSP(idx_LSP:idx_LSP+len_NewLSP-1,:) = ...
        [LIP(Signific,1:2), numLoop*ones(len_NewLSP,1)];
    idx_LSP = idx_LSP + len_NewLSP;
    idx_PIX_Plan = LIP(Signific,1:2);
    PtrSignes = PtrSignes + 1;
    endSignes = PtrSignes + len_NewLSP-1;
    Signes    = double(WTC_Struct.BitSignes(PtrSignes:endSignes));
    Signes(Signes==0) = -1;
    PtrSignes = endSignes;
    LIPidx_TMP = idx_PIX_Plan(:,1)+(idx_PIX_Plan(:,2)-1)*nb_PIX;
    Signific_MAT(LIPidx_TMP) = Signes*Thres;
    %---------------------------------------------------------
    LIP(Signific,:) = [];
    idxEnd_LIP = idxEnd_LIP - len_NewLSP;
    %---------------------------------------------------------

    % 2.2) - LIS management
    %-----------------------
    idx_LIS = 0;
    idx_End_LIS = size(LIS,1);
    continu = idx_LIS<idx_End_LIS;
    while continu
        idx_LIS = idx_LIS + 1;
        idx_PIX = LIS(idx_LIS,1);
        if idx_PIX>0
            k = idx_LIS;
            EntryB = (LIS(k,3)==1);
            Ic = TabFirstCHILD(idx_PIX); % Ic = 2*idx_PIX-1;
            idx_desc0 = [Ic , Ic+1 ,  Ic+rY , Ic+1+rY];
            C1 = idx_desc0(ones(1,BitPlan),:); C1 = C1(:);            
            C2 = (1:BitPlan)'; C2 = C2(:,ones(1,4)); C2 = C2(:);
            descend = [C1 , C2];
            if ~EntryB
                if ~Crossing_Tree_PIX_A(idx_PIX)
                    Crossing_Tree_PIX_A(idx_PIX) = true;
                    PtrStream = PtrStream + 1;
                    Signific_LIS_A = ...
                        logical(WTC_Struct.BitStream(PtrStream));
                    Crossing_Tree_PIX_A_VAL(idx_PIX) = Signific_LIS_A;
                else
                    Signific_LIS_A = Crossing_Tree_PIX_A_VAL(idx_PIX);
                end
                
                if Signific_LIS_A
                    for jj = 1:4
                        idx_CHILD = idx_desc0(jj);
                        for idx_Plan = 1:BitPlan
                            if ~Crossing_Tree_LIP(idx_CHILD,idx_Plan)
                                Crossing_Tree_LIP(idx_CHILD,idx_Plan) = true;
                                d_PIX_Plan = (idx_Plan-1)*nb_PIX;
                                PtrStream = PtrStream + 1;
                                Signific_LIS_desc = ...
                                    logical(WTC_Struct.BitStream(PtrStream));
                                if Signific_LIS_desc
                                    LSP(idx_LSP,:) = [idx_CHILD , idx_Plan, numLoop];
                                    PtrSignes = PtrSignes + 1;
                                    Signes = double(WTC_Struct.BitSignes(PtrSignes));
                                    Signes(Signes==0) = -1;
                                    idx_LSP = idx_LSP + 1;
                                    len_LSP = size(LSP,1);
                                    if idx_LSP>len_LSP , LSP(2*len_LSP,3) = 0; end
                                    Signific_MAT(idx_CHILD+d_PIX_Plan) = ...
                                        Signes*Thres;
                                else
                                    idxEnd_LIP = idxEnd_LIP + 1;
                                    LIP(idxEnd_LIP,1) = idx_CHILD;
                                    LIP(idxEnd_LIP,2) = idx_Plan;
                                    LSP(idx_LSP,3) = numLoop;
                                end
                            end
                        end
                    end

                    if ~isnan(TabFirstCHILD(idx_desc0(1)))
                        idx_End_LIS = idx_End_LIS + 1;
                        len_LIS = size(LIS,1);
                        if idx_End_LIS>len_LIS , LIS(2*len_LIS,3) = 0; end
                        LIS(idx_End_LIS,1) = LIS(k,1);
                        LIS(idx_End_LIS,2) = LIS(k,2);
                        LIS(idx_End_LIS,3) = 1;
                        LIS(k,:) = 0;
                        k = idx_End_LIS;
                        EntryB = true;
                    else
                        LIS(k,:) = 0;
                    end
                end  % End of: if Signific_LIS
            end % End: of if ~EntryB
            
            if EntryB
                if ~Crossing_Tree_PIX_B(idx_PIX)
                    Crossing_Tree_PIX_B(idx_PIX) = true;
                    PtrStream = PtrStream + 1;
                    Signific_LIS_B = ...
                        logical(WTC_Struct.BitStream(PtrStream));
                    Crossing_Tree_PIX_B_VAL(idx_PIX) = Signific_LIS_B;
                else
                    Signific_LIS_B = Crossing_Tree_PIX_B_VAL(idx_PIX);
                end
                if Signific_LIS_B
                    ttt = false(size(descend,1),1);
                    for kkk = 1:size(descend,1)
                        ttt(kkk) = ...
                            Crossing_Tree_LIS(descend(kkk,1),descend(kkk,2));
                        if ~ttt(kkk)
                            Crossing_Tree_LIS(descend(kkk,1),descend(kkk,2)) = true;
                        end
                    end
                    nbNEW = sum(~ttt);
                    if nbNEW>0
                        iBeg = idx_End_LIS + 1;
                        idx_End_LIS = idx_End_LIS + nbNEW;
                        len_LIS = size(LIS,1);
                        if idx_End_LIS>len_LIS , LIS(2*len_LIS,3) = 0; end
                        LIS(iBeg:idx_End_LIS,:) = [descend(~ttt,:) ,zeros(nbNEW,1)];
                    end
                    LIS(k,:) = 0;
                end
            end
        end
        continu = idx_LIS<idx_End_LIS;
    end
    LIS(LIS(:,1)==0,:) = [];

    % 3) - Refinement Loop.
    %======================
    idx_LSP_Ref = LSP(1:idx_LSP-1,3)<numLoop;
    LSPidx = LSP(idx_LSP_Ref,1:2);
    PtrSigBIT = PtrSigBIT +1;
    endSigBIT  = PtrSigBIT + size(LSPidx,1)-1;
    Signific_Bit = double(WTC_Struct.SigBIT(PtrSigBIT:endSigBIT));
    PtrSigBIT = endSigBIT;
    if ~isempty(LSPidx)
        idx_PIX_Plan = LSPidx(:,1)+ (LSPidx(:,2)-1)*nb_PIX;
        Signific_MAT(idx_PIX_Plan) = Signific_MAT(idx_PIX_Plan) + ...
            sign(Signific_MAT(idx_PIX_Plan)).*(Signific_Bit*Thres)';
    end
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
        if nbin<2 && ~exist('map','var') ,
            maxi = fix(min([max(abs(Xrec(:))),255]));
            if maxi>0 , colormap(pink(maxi)); end
        end
        title(getWavMSG('Wavelet:divGUIRF:WTC_Loop',numLoop), ...
            'Parent',CurrentAxe);
        pause(0.01)
    end

    % 4) - Quantization step update
    %------------------------------
    n = n-1;
    MoreLoop = n>=0 && numLoop<MaxLoop;
end
if convFLAG
    strTitle = getWavMSG('Wavelet:commongui:CompImg');
    title(strTitle,'Parent',CurrentAxe);
    pause(0.01)   
end 
if ~isequal(wname,'none') , dwtmode(old_modeDWT,'nodisp');  end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%



%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
function fileSize = wtc_spiht_save(typeSAVE,filename,WTC_Struct)

% File settings.
%---------------
tmp_filename = def_tmpfile(filename);
fid = fopen(tmp_filename,'wb');


%--------------------------------------------------------
len_BitStream = length(WTC_Struct.BitStream);
len_BitSignes = length(WTC_Struct.BitSignes);
len_SigBIT    = length(WTC_Struct.SigBIT);
WTC_Struct.BitStream = [...
    WTC_Struct.BitStream , WTC_Struct.BitSignes, WTC_Struct.SigBIT ...
    ];
WTC_Struct = rmfield(WTC_Struct,{'BitSignes','SigBIT'});
%--------------------------------------------------------

% Begin Saving.
%--------------
codeID = wtcmngr('meth_ident',typeSAVE,'spiht_3d');
fwrite(fid,codeID,'ubit8');
LenOfBitStream = length(WTC_Struct.BitStream);
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
fwrite(fid,len_BitStream,'uint32');
fwrite(fid,len_BitSignes,'uint32');
fwrite(fid,len_SigBIT,'uint32');
fwrite(fid,LenOfBitStream,'uint32');
WTC_Struct.BitStream = uint8(WTC_Struct.BitStream);
fwrite(fid,WTC_Struct.BitStream,'ubit1');
%--------------------------------------------------------
try fclose(fid); end %#ok<TRYNC>
modify_wtcfile('save',filename,typeSAVE)
fid = fopen(filename);
[~,fileSize] = fread(fid);
fclose(fid);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%



%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
function WTC_Struct = wtc_spiht_load(filename)

% File settings.
%---------------
tmp_filename  = def_tmpfile(filename);
ok_TMP = exist(tmp_filename,'file');
if ok_TMP
    fid = fopen(tmp_filename);
else
    fid = fopen(filename);
end

codeID = fread(fid,1,'*char');  %#ok<NASGU>   % Not used.
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
wname = fread(fid,nbCHAR,'uint8');
WTC_Struct.Header.Methode = char(wname');
WTC_Struct.Header.Level = fread(fid,1,'uint8');
WTC_Struct.Header.MaxLoop = fread(fid,1,'uint8');
len_BitStream = fread(fid,1,'uint32');
len_BitSignes = fread(fid,1,'uint32');
len_SigBIT    = fread(fid,1,'uint32');
LenOfBitStream = fread(fid,1,'uint32');
WTC_Struct.BitStream = fread(fid,LenOfBitStream,'ubit1');
WTC_Struct.BitStream = uint8(WTC_Struct.BitStream);
idxBeg = len_BitStream + 1;
idxEnd = idxBeg + len_BitSignes - 1;
WTC_Struct.BitSignes = WTC_Struct.BitStream(idxBeg:idxEnd)';
idxBeg = idxEnd + 1;
idxEnd = idxBeg + len_SigBIT - 1;
WTC_Struct.SigBIT = WTC_Struct.BitStream(idxBeg:idxEnd)';
WTC_Struct.BitStream(len_BitStream+1:end) = [];
WTC_Struct.BitStream = WTC_Struct.BitStream';
WTC_Struct.BitStream = WTC_Struct.BitStream;
WTC_Struct.BitSignes = WTC_Struct.BitSignes;
WTC_Struct.SigBIT = WTC_Struct.SigBIT;

fclose(fid);
if ok_TMP , delete(tmp_filename); end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
