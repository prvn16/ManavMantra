function varargout = wtc_stw(option,typeSAVE,varargin)
%WTC_STW Main program for WTC_STW encoding.
%
%   VARARGOUT = WTC_STW(OPTION,VARARGIN)
%
%   WTC_STW('encode', ... )
%   WTC_STW('decode', ... )
%   WTC_STW('save', ... )
%   WTC_STW('load', ... )

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 27-Nov-2007.
%   Last Revision: 19-Apr-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

% Constant used in WTC_STW.
%--------------------------
alphabet   = ['P','N','0','1','2','3','4','5'];
bwt_OPTION = 'off';
mtf_OPTION = 2;

% Constant.
%----------
State_IR = 0; % 'IR';
State_IV = 1; % 'IV';
State_SR = 2; % 'SR';
State_SV = 3; % 'SV';

nbCHAR = 1;    % Nb of significant letters for "option"
validOPTION = {'encode','decode','save','load'};

numOPT = find(strncmpi(option,validOPTION,nbCHAR));
nbout  = nargout;
switch numOPT
    %-- 'encode' --%
    case 1 , [varargout{1:nbout}] = wtc_stw_enc(varargin{:});
        %-- 'decode' --%
    case 2 , [varargout{1:nbout}] = wtc_stw_dec(typeSAVE,varargin{:});
        %--- 'save' ---%
    case 3 , [varargout{1:nbout}] = wtc_stw_save(typeSAVE,varargin{:});
        %--- 'load' ---%
    case 4 , [varargout{1:nbout}] = wtc_stw_load(varargin{:});
end


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function WTC_Struct = wtc_stw_enc(X,wname,level,modeDWT,...
            MaxLoop,ColType,stepFLAG,CurrentAxe) %#ok<*INUSL>

        nbin = nargin;
        if nbin<2 , wname = 'haar'; end
        if nbin<3 , level = Inf; end
        if nbin<4 , modeDWT = dwtmode('status','nodisp'); end %#ok<*NASGU>
        if ~isequal(wname,'none')
            old_modeDWT = dwtmode('status','nodisp');
            modeDWT = 'per';
            dwtmode(modeDWT,'nodisp');
        end
        if nbin<5 , MaxLoop  = Inf; end
        if nbin<6, ColType  = 'rgb'; end
        if nbin<7 , stepFLAG = 1; end
        if nbin<8
            if ~isnan(stepFLAG)
                CurrentAxe = gca;
            else
                CurrentAxe = [];
            end
        end

        [X,ColMAT] = wimgcolconv(ColType,X);
        sX = size(X);
        level = min([fix(log2(min(sX(1:2)))),level]);

        % 1) - Initialization.
        %=====================
        if ~isequal(wname,'none')
            [C,S] = wavedec2(X,level,wname);
            Y = wcfs2mat(C,S);
            Y = round(Y);
        else
            Y = X;
            [dummy,S] = wavedec2(X,level,'haar'); %#ok<ASGLU>
        end
        [rY,cY,BitPlan] = size(Y);
        Signific_MAT = zeros(rY,cY,BitPlan);
        nb_PIX  = rY*cY;

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
        [TabFATHER,TabFirstCHILD] = wfandfcidx('qtFC',S);   
        
        % Initialize Dominant List.
        %--------------------------
        TMP = find(isnan(TabFATHER));
        nbRoots = length(TMP);
        rootNode = zeros(nbRoots,BitPlan);
        for bp = 1:BitPlan
            rootNode(:,bp) = TMP+(bp-1)*nb_PIX;
        end
        rootNode = rootNode(:);
        tf = ismember(scan_Plan_INI,rootNode);
        rootNode = scan_Plan_INI(tf);
        Idx_Dom_LST = BitPlan*nbRoots;
        Dominant_LST = zeros(nb_PIX,2);
        Dominant_LST(1:Idx_Dom_LST,1) = rootNode;
        Refinement_LST = zeros(nb_PIX,2);
        idx_Ref_LST = 0;
                
        % Initialization of buffers for Tree Crossing.
        Crossing_Tree_DOM = false(nb_PIX*BitPlan,1);

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
        WTC_Struct.Header.BitPlan_Encode = false;
        WTC_Struct.StateStream    = [];
        WTC_Struct.SignStream     = [];
        WTC_Struct.SignificStream = zeros(1,nb_PIX);
        PtrStateStream    = 0;
        PtrSignStream     = 0;
        PtrSignificStream = 0;
        %--------------------------------------------------
        % Compute quadtree parameters.
        sigMAP = significant_map('stw',Y,TabFATHER);
        nbCOL = size(sigMAP,2);
        sigMAP_3d = sigMAP(:,[1:3:nbCOL , 2:3:nbCOL]);  
        sigMAP_3d(isnan(TabFirstCHILD),BitPlan+1:end) = Inf;
        sigMAP_3d = reshape(sigMAP_3d,nb_PIX*BitPlan,2);

        % For GUI: Step by Step.
        test_step_by_step('ini',stepFLAG);

        % Initialization of loop parameters.
        MoreLoop = true;
        numLoop = 0;
        while MoreLoop
            % 1) Compute numLoop and Threshold.
            %----------------------------------
            numLoop = numLoop + 1;
            Thres = 2^n;

            % 2) Dominant Pass.
            %------------------
            idx_PIX = Dominant_LST(1:Idx_Dom_LST,1);
            continu = true;
            countSubLoop = 0;
            while continu
                countSubLoop = countSubLoop + 1;
                add2DOM = false;
                State_OLD = getState(idx_PIX,2*Thres);
                nbStates = length(State_OLD);
                State_NEW = getState(idx_PIX,Thres);
                changeStateTAB = getState_Transition;
                PtrStateStream = PtrStateStream+1;
                EndStateStream = PtrStateStream+nbStates-1;
                WTC_Struct.StateStream(PtrStateStream:EndStateStream) = ...
                    changeStateTAB;
                PtrStateStream = EndStateStream;
                %--------------------------------------------------
                IdxChange = State_NEW~=State_OLD;
                if any(IdxChange)
                    notSR_notIV = IdxChange & ...
                        State_OLD~=State_SR & State_NEW~=State_IV;
                    nbChange = sum(notSR_notIV);
                    if nbChange>0
                        idx_ACT = idx_PIX(notSR_notIV);
                        Crossing_Tree_DOM(idx_ACT) = true;
                        idx_Ref_LST = idx_Ref_LST + 1;
                        idx_Ref_END = idx_Ref_LST + length(idx_ACT) - 1;
                        Refinement_LST(idx_Ref_LST:idx_Ref_END,1) = idx_ACT;
                        Refinement_LST(idx_Ref_LST:idx_Ref_END,2) = numLoop;
                        idx_Ref_LST = idx_Ref_END;
                        SGN = sign(double(Y(idx_ACT)));
                        Signific_MAT(idx_ACT) = ...
                            Signific_MAT(idx_ACT)+SGN*Thres;
                        PtrSignStream = PtrSignStream + 1;
                        EndSignStream = PtrSignStream + nbChange - 1;
                        WTC_Struct.SignStream(PtrSignStream:EndSignStream) = SGN;
                        PtrSignStream = EndSignStream;
                        if iscell(stepFLAG) || stepFLAG>1
                            plotIMAGE_ENC(countSubLoop);
                        end
                    end
                    notIV_notSR = IdxChange & ...
                        State_OLD~=State_IV & State_NEW~=State_SR;
                    nbChange = sum(notIV_notSR);
                    if nbChange>0
                        idx_ACT = idx_PIX(notIV_notSR);
                        IdxPlan = 1+floor((idx_ACT-0.5)/nb_PIX);
                        delta_Plan = (IdxPlan-1)*nb_PIX;
                        TMP = idx_ACT - delta_Plan;
                        II = TabFirstCHILD(TMP);
                        idx_desc_P1 = [II , II+1 , II+rY, II+1+rY];
                        lst_CHILD = idx_desc_P1 + delta_Plan(:,ones(1,4));
                        lst_CHILD(isnan(II),:) = [];
                        lst_CHILD = lst_CHILD';
                        lst_CHILD = lst_CHILD(:);
                        [nul,id] = setdiff(lst_CHILD,idx_ACT); %#ok<ASGLU>
                        lst_CHILD = lst_CHILD(id);
                        lst_CHILD(Crossing_Tree_DOM(lst_CHILD)==true) = [];
                        if ~isempty(lst_CHILD)
                            tf = ismember(scan_Plan_INI,lst_CHILD);
                            lst_CHILD = scan_Plan_INI(tf);
                            Idx_Dom_LST = Idx_Dom_LST + 1;
                            Idx_Dom_END = Idx_Dom_LST + length(lst_CHILD)-1;
                            END_Dom_LST = size(Dominant_LST,1);
                            if Idx_Dom_END>END_Dom_LST
                                Dominant_LST(2*Idx_Dom_END,2) = 0;
                            end
                            PtrNext_DOM = Idx_Dom_LST;
                            add2DOM = true;
                            Dominant_LST(Idx_Dom_LST:Idx_Dom_END,1) = lst_CHILD;
                            Dominant_LST(Idx_Dom_LST:Idx_Dom_END,2) = numLoop;
                            Idx_Dom_LST = Idx_Dom_END;
                            Crossing_Tree_DOM(lst_CHILD) = true;
                        end
                    end
                    State_NEW_EQ_SV = IdxChange & State_NEW==State_SV;
                    nbChange = sum(State_NEW_EQ_SV);
                    if nbChange>0
                        idx_ACT = idx_PIX(State_NEW_EQ_SV);
                        tf = ismember(Dominant_LST(:,1),idx_ACT);
                        Dominant_LST(tf,1) = 0;
                    end
                end
                continu = add2DOM;
                if add2DOM
                    idx_PIX = Dominant_LST(PtrNext_DOM:end,1);
                    idx_PIX(idx_PIX==0) = [];
                    continu = ~isempty(idx_PIX);
                end
            end
            Dominant_LST(Dominant_LST(:,1)==0,:) = [];
            Idx_Dom_LST = size(Dominant_LST,1);
            
            % 3) Refinement Pass.
            %--------------------
            sub_thres = fix(Thres/2);
            if sub_thres>0
                toRefine = Refinement_LST(1:idx_Ref_LST);
                Signific_Bit = bitget(double(abs(Y(toRefine))),n);
                PtrSignificStream = PtrSignificStream+1;
                lenSignificStream = length(WTC_Struct.SignificStream);
                if PtrSignificStream>lenSignificStream
                    WTC_Struct.SignificStream(1,2*lenSignificStream) = 0;
                end
                EndSignificStream = PtrSignificStream + length(Signific_Bit)-1;
                WTC_Struct.SignificStream(PtrSignificStream:EndSignificStream) = Signific_Bit;
                PtrSignificStream = EndSignificStream;
                Signific_MAT(toRefine) = Signific_MAT(toRefine) + ...
                    sign(double(Y(toRefine))).*Signific_Bit*sub_thres;
                
                % "Reconstruction" (and Display of "Image")
                plotIMAGE_ENC('ref');
            end
            
            % "Reconstruction" (and Display of "Image")
            plotIMAGE_ENC('end');
            
            % 4) Quantization step update.
            %-----------------------------
            n = n-1;
            MoreLoop = n>=0 && numLoop<MaxLoop;

        end
        plotIMAGE_ENC('final');
        test_step_by_step('close',stepFLAG);
        if ~isequal(wname,'none') , dwtmode(old_modeDWT,'nodisp');  end
        WTC_Struct.SignificStream = WTC_Struct.SignificStream(1:PtrSignificStream);
        
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
        function State = getState(idNode,Thr)
            
            State = zeros(length(idNode),1);
            Signific_NOD = (abs(Y(idNode))<Thr);
            Signific_DES = abs(sigMAP_3d(idNode,2))<Thr;
            Idx_IR =  Signific_NOD &  Signific_DES;
            Idx_IV =  Signific_NOD & ~Signific_DES;
            Idx_SR = ~Signific_NOD &  Signific_DES;
            Idx_SV = ~Signific_NOD & ~Signific_DES;
            State(Idx_IR) = State_IR;
            State(Idx_IV) = State_IV;
            State(Idx_SR) = State_SR;
            State(Idx_SV) = State_SV;            
        end
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
        function changeStateTAB = getState_Transition
            
            nbStates = length(State_OLD);
            IRIR = State_OLD==State_IR & State_NEW==State_IR;
            IRIV = State_OLD==State_IR & State_NEW==State_IV;
            IRSR = State_OLD==State_IR & State_NEW==State_SR;
            IRSV = State_OLD==State_IR & State_NEW==State_SV;
            IVIV = State_OLD==State_IV & State_NEW==State_IV;
            IVSV = State_OLD==State_IV & State_NEW==State_SV;
            SRSR = State_OLD==State_SR & State_NEW==State_SR;
            SRSV = State_OLD==State_SR & State_NEW==State_SV;
            SVSV = State_OLD==State_SV & State_NEW==State_SV;
            changeStateTAB = NaN(nbStates,1);
            changeStateTAB(IRIR) =  0;
            changeStateTAB(IRIV) = 1;
            changeStateTAB(IRSR) = 2;
            changeStateTAB(IRSV) =  3;
            changeStateTAB(IVIV) =  0;
            changeStateTAB(IVSV) =  4;
            changeStateTAB(SRSR) =  0;
            changeStateTAB(SRSV) =  5;
            changeStateTAB(SVSV) =  0;
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
                    if isnumeric(ARGIN)
                        strTitle = ...
                            getWavMSG('Wavelet:divGUIRF:WTC_Loop_Sub', ...
                            numLoop,ARGIN);
                    elseif isequal(ARGIN,'ref')
                        strTitle = ...
                            getWavMSG('Wavelet:divGUIRF:WTC_Loop_Ref', ...
                            numLoop);
                    else
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
    function Xrec = wtc_stw_dec(typeSAVE,WTC_Struct,stepFLAG)
        
        %-------------------------------------------------------------
        % changeStateTAB==0
        % changeStateTAB==3 | changeStateTAB==4 | changeStateTAB==2
        % changeStateTAB==3 | changeStateTAB==5 | changeStateTAB==1
        % changeStateTAB==3 | changeStateTAB==4 | changeStateTAB== 5
        %-------------------------------------------------------------
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
        PtrStateStream    = 0;
        PtrSignStream     = 0;
        PtrSignificStream = 0;
        nb_PIX = rY*cY;
        Signific_MAT = zeros(rY,cY,BitPlan);
        if ~isequal(wname,'none')
            old_modeDWT = dwtmode('status','nodisp');
            modeDWT = 'per';
            dwtmode(modeDWT,'nodisp');
        end
        SizeINI = [rY cY];
        [sizeCFS,~] = getsizes(level,SizeINI);
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
        [TabFATHER,TabFirstCHILD] = wfandfcidx('qtFC',S);   
        
        % Initialize Dominant List.
        %--------------------------
        TMP = find(isnan(TabFATHER));
        nbRoots = length(TMP);
        rootNode = zeros(nbRoots,BitPlan);
        for bp = 1:BitPlan
            rootNode(:,bp) = TMP+(bp-1)*nb_PIX;
        end
        rootNode = rootNode(:);
        tf = ismember(scan_Plan_INI,rootNode);
        rootNode = scan_Plan_INI(tf);
        Idx_Dom_LST = BitPlan*nbRoots;
        Dominant_LST = zeros(nb_PIX,2);
        Dominant_LST(1:Idx_Dom_LST,1) = rootNode;
        Refinement_LST = zeros(nb_PIX,2);
        idx_Ref_LST = 0;
                
        % Initialization of buffers for Tree Crossing.
        Crossing_Tree_DOM = false(nb_PIX*BitPlan,1);
                
        % Initialization of loop parameters.
        MoreLoop = true;
        numLoop = 0;
        while MoreLoop
            % 1) Compute numLoop and Threshold.
            %----------------------------------
            numLoop = numLoop + 1;
            Thres = 2^n;
            
            % 2) Dominant Pass.
            %------------------
            idx_PIX = Dominant_LST(1:Idx_Dom_LST,1);
            continu = true;
            while continu
                add2DOM = false;
                nbStates = length(idx_PIX);
                PtrStateStream = PtrStateStream+1;
                EndStateStream = PtrStateStream+nbStates-1;
                if PtrStateStream>length(WTC_Struct.StateStream)
                    break
                end
                changeStateTAB = ...
                    WTC_Struct.StateStream(PtrStateStream:EndStateStream);
                PtrStateStream = EndStateStream;
                IdxChange = changeStateTAB~=0; 
                if any(IdxChange)
                    idx_to_Change = changeStateTAB==3 | ...
                        changeStateTAB==4 | changeStateTAB==2;
                    idx_ACT = idx_PIX(idx_to_Change);
                    nbChange = length(idx_ACT);
                    if nbChange>0
                        Crossing_Tree_DOM(idx_ACT) = true;
                        idx_Ref_LST = idx_Ref_LST + 1;
                        idx_Ref_END = idx_Ref_LST + length(idx_ACT) - 1;
                        Refinement_LST(idx_Ref_LST:idx_Ref_END,1) = idx_ACT;
                        Refinement_LST(idx_Ref_LST:idx_Ref_END,2) = numLoop;
                        idx_Ref_LST = idx_Ref_END;
                        PtrSignStream = PtrSignStream + 1;
                        EndSignStream = PtrSignStream + nbChange - 1;
                        SGN = WTC_Struct.SignStream(PtrSignStream:EndSignStream)';
                        SGN(SGN==0) = -1;
                        PtrSignStream = EndSignStream;
                        Signific_MAT(idx_ACT) = Signific_MAT(idx_ACT)+SGN*Thres;
                        % if stepFLAG>1 , plotIMAGE; end
                        plotIMAGE;
                    end
                    idx_to_Change = changeStateTAB==3 | ...
                        changeStateTAB==5 | changeStateTAB==1;
                    idx_ACT = idx_PIX(idx_to_Change);                    
                    nbChange = length(idx_ACT);
                    if nbChange>0
                        IdxPlan = 1+floor((idx_ACT-0.5)/nb_PIX);
                        delta_Plan = (IdxPlan-1)*nb_PIX;
                        TMP = idx_ACT - delta_Plan;
                        II = TabFirstCHILD(TMP);
                        idx_desc_P1 = [II , II+1 , II+rY, II+1+rY];
                        lst_CHILD = idx_desc_P1 + delta_Plan(:,ones(1,4));
                        lst_CHILD(isnan(II),:) = [];
                        lst_CHILD = lst_CHILD';
                        lst_CHILD = lst_CHILD(:);
                        [nul,id] = setdiff(lst_CHILD,idx_ACT); %#ok<ASGLU>
                        lst_CHILD = lst_CHILD(id);
                        lst_CHILD(Crossing_Tree_DOM(lst_CHILD)==true) = [];
                        if ~isempty(lst_CHILD)
                            tf = ismember(scan_Plan_INI,lst_CHILD);
                            lst_CHILD = scan_Plan_INI(tf);
                            Idx_Dom_LST = Idx_Dom_LST + 1;
                            Idx_Dom_END = Idx_Dom_LST + length(lst_CHILD)-1;
                            END_Dom_LST = size(Dominant_LST,1);
                            if Idx_Dom_END>END_Dom_LST
                                Dominant_LST(2*Idx_Dom_END,2) = 0;
                            end
                            PtrNext_DOM = Idx_Dom_LST;
                            add2DOM = true;
                            Dominant_LST(Idx_Dom_LST:Idx_Dom_END,1) = lst_CHILD;
                            Dominant_LST(Idx_Dom_LST:Idx_Dom_END,2) = numLoop;
                            Idx_Dom_LST = Idx_Dom_END;
                            Crossing_Tree_DOM(lst_CHILD) = true;
                        end
                    end
                    State_NEW_EQ_SV = changeStateTAB==3 | ...
                        changeStateTAB==4 | changeStateTAB== 5;
                    nbChange = sum(State_NEW_EQ_SV);
                    if nbChange>0
                        idx_ACT = idx_PIX(State_NEW_EQ_SV);
                        tf = ismember(Dominant_LST(:,1),idx_ACT);
                        Dominant_LST(tf,1) = 0;
                    end
                end
                continu = add2DOM;
                if add2DOM
                    idx_PIX = Dominant_LST(PtrNext_DOM:end,1);
                    idx_PIX(idx_PIX==0) = [];
                    continu = ~isempty(idx_PIX);
                end
            end
            Dominant_LST(Dominant_LST(:,1)==0,:) = [];
            Idx_Dom_LST = size(Dominant_LST,1);
                        
            % 3) Refinement Pass.
            %--------------------
            sub_thres = fix(Thres/2);
            if sub_thres>0
                toRefine = Refinement_LST(1:idx_Ref_LST);
                PtrSignificStream = PtrSignificStream+1;
                EndSignificStream = PtrSignificStream + length(toRefine)-1;
                if PtrSignificStream>length(WTC_Struct.SignificStream)
                    break
                end
                Signific_Bit = ...
                    WTC_Struct.SignificStream(PtrSignificStream:EndSignificStream);
                PtrSignificStream = EndSignificStream;
                Signific_MAT(toRefine) = Signific_MAT(toRefine) + ...
                    sign(double(Signific_MAT(toRefine))).*Signific_Bit*sub_thres;
                
                % "Reconstruction" (and Display of "Image")
                plotIMAGE;
            end
            
            % "Reconstruction" (and Display of "Image")
            [Xrec,convFLAG] = plotIMAGE;
            
            % 4) Quantization step update.
            %-----------------------------
            n = n-1;
            MoreLoop = n>=0 && numLoop<MaxLoop;
        end
        if isempty(Xrec)
            numLoop = MaxLoop;
            [Xrec,convFLAG] = plotIMAGE;
        end
        if convFLAG
            strTitle = getWavMSG('Wavelet:commongui:CompImg');
            wtitle(strTitle,'Parent',gca); pause(0.01)
        end
        varargout{1} = Xrec;
        if ~isequal(wname,'none') , dwtmode(old_modeDWT,'nodisp');  end
        
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
        function [Xrec,convFLAG] = plotIMAGE
            
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
    function fileSize = wtc_stw_save(typeSAVE,filename,WTC_Struct)
        
        % File settings.
        %---------------
        tmp_filename = def_tmpfile(filename);
        fid = fopen(tmp_filename,'wb');

        % Select type of endcoding.
        %--------------------------                
        BitPlan_Encode = WTC_Struct.Header.BitPlan_Encode;
        if ~BitPlan_Encode
            nb_States = length(WTC_Struct.StateStream);
            nb_SGN = length(WTC_Struct.SignStream);
            nb_RAF = length(WTC_Struct.SignificStream);
            SignStream = blanks(nb_SGN);
            SignStream(:) = 'P';
            SignStream(WTC_Struct.SignStream<0) = 'N';
            WTC_Struct.BitStream = [char(48+WTC_Struct.StateStream) , ...
                SignStream  char(48+WTC_Struct.SignificStream)];
        end
        LenOfBitStream = length(WTC_Struct.BitStream);
        [bwt_IDX,mtf_VAL,HC_Struct] = bwc_algo('e',...
            bwt_OPTION,mtf_OPTION,alphabet,WTC_Struct.BitStream);
        TabCODE = HC_Struct.HC_tabENC;
        HCTab = HC_Struct.HC_codes;        
                        
        % Begin Saving.
        %--------------
        codeID = wtcmngr('meth_ident',typeSAVE,'stw');
        fwrite(fid,codeID,'ubit8');
        fwrite(fid,BitPlan_Encode,'uint8');
        if ~BitPlan_Encode
            fwrite(fid,nb_States,'uint32');
            fwrite(fid,nb_SGN,'uint32');
            fwrite(fid,nb_RAF,'uint32');
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
        nbHC = length(HCTab);
        fwrite(fid,nbHC,'uint8');
        fwrite(fid,HCTab,'ubit2');
        lenCODE  = length(TabCODE);
        fwrite(fid,lenCODE,'uint32');
        fwrite(fid,TabCODE,'ubit1');
        
        try
            fclose(fid);
        catch ME
        end
        modify_wtcfile('save',filename,typeSAVE)
        fid = fopen(filename);
        [~,fileSize] = fread(fid);
        fclose(fid);        
        
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
    function WTC_Struct = wtc_stw_load(filename)
        
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
        WTC_Struct.Header.BitPlan_Encode = fread(fid,1,'uint8');
        if ~WTC_Struct.Header.BitPlan_Encode
            nb_States = fread(fid,1,'int32');
            nb_SGN = fread(fid,1,'int32');
            nb_RAF = fread(fid,1,'int32');
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
        nbHC = fread(fid,1,'uint8');
        HCTab = fread(fid,nbHC,'ubit2');
        lenCODE = fread(fid,1,'uint32');
        TabCODE = fread(fid,lenCODE,'ubit1');
        WTC_Struct.BitStream = bwc_algo('d', ...
            bwt_IDX,mtf_VAL,alphabet,LenOfBitStream,HCTab,TabCODE);
        
        if ~WTC_Struct.Header.BitPlan_Encode
            WTC_Struct.StateStream = WTC_Struct.BitStream(1:nb_States)-48;
            first = nb_States+1;
            last  = first + nb_SGN-1;
            SignStream = WTC_Struct.BitStream(first:last);
            WTC_Struct.SignStream = ones(1,nb_SGN);
            WTC_Struct.SignStream(SignStream=='N') = -1;
            first = last+1;
            last  = first + nb_RAF-1;
            WTC_Struct.SignificStream = WTC_Struct.BitStream(first:last)-48;
            WTC_Struct = rmfield(WTC_Struct,{'BitStream'});
        end
        fclose(fid);
        if ok_TMP
            delete(tmp_filename);
        end
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%


end  % End of WTC_STW.M