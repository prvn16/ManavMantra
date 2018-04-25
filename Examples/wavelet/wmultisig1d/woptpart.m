function [optPART,Rupt_Weight] = woptpart(handles,X,optMETH,manyOPT,signals)
%WOPTPART Computes one or many optimal partition(s).
%   Starting from a matrix of partitions X (each column of
%   X is a vector of cluster numbers), Y = WOPTPART(X)
%   returns a column vector which represents the optimal
%   partition.
%
%   Y = WOPTPART(X,optMETH) uses the method optMETH to
%   compute the optimal partition. The valid methods are:
%   'sim' and 'jaccard'. The default is 'jaccard'.
%
%   Y = WOPTPART(X,optMETH,manyOPT) returns a matrix
%   of optimal partitions (one by column) when manyOPT is
%   equal to true. The default is manyOPT = false.
%   When manyOPT is an integer, X may contains at most
%   manyOPT columns.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Feb-2006.
%   Last Revision: 25-Jan-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

% Defaults Values.
%-----------------
optRENUM = 'max';
randFLAG  = false;
plotFLAG  = true;
Max_Rupt_Weight = 2;
nbSTEP_ALG_Rupt = 2;
nbOPT = 1;

% Check inputs.
%--------------
switch nargin
    case 0 ,
        Pus_Compute = gcbo;
        usr = get(Pus_Compute,'UserData');
        [X,optMETH,manyOPT] = deal(usr{:});

    case 2 , manyOPT = false; optMETH = 'jaccard';
    case 3 , manyOPT = false;
    case {4,5}
        if isnumeric(manyOPT)
            nbOPT = manyOPT;
            manyOPT = true;
        else
            nbOPT = Inf;
            manyOPT = isequal(manyOPT,true);
        end
    otherwise
        error(message('Wavelet:FunctionInput:Invalid_ArgNum'));
end

% Defaults Values.
%-----------------
[nbSIG,nbPART] = size(X);
if nbPART<=Max_Rupt_Weight , Max_Rupt_Weight = nbPART-1; end

% Initialisation des donn?es.
%----------------------------
nbCLU  = max(X,[],1);
% nbCLU_Max = max(nbCLU);
% nbCLU_Min = min(nbCLU);
% scoreMIN  = sum(nbCLU)-nbPART;
current_ORDER  = (1:nbSIG)';
if nargin>0
    if isempty(handles)
        Axe_CON_INI = subplot(1,2,1);
        Axe_CON_ALG = subplot(1,2,2);
        Pus_Compute = uicontrol(...
            'Style','pushbutton', ...
            'String','Compute', ...
            'Position',[10 2 80 22], ...
            'UserData',[],...
            'Callback',[mfilename ';']);
        set(Pus_Compute,'UserData',{X,optMETH,manyOPT})
    else
        Axe_CON_INI = handles.Axe_CON_INI;
        Axe_CON_ALG = handles.Axe_CON_ALG;
        set([Axe_CON_INI,Axe_CON_ALG],'FontSize',8);
    end
else
    Axe_CON_INI = subplot(1,2,1);
    Axe_CON_ALG = subplot(1,2,2);
    set([Axe_CON_INI,Axe_CON_ALG],'FontSize',8);
end
set([Axe_CON_INI,Axe_CON_ALG],'XTick',(1:nbPART),'XGrid','On');

% Initialisation des "labels" et des scores.
%-------------------------------------------
switch optRENUM
    case 'min' , maxX = max(max(X));
    case 'max' , maxX = sum(max(X));
end
score = getScore(X);
Perfo = score;
Lst_IdxSORT = [];
Lst_Score   = [];

% Randomisation des "couleurs" (pour mieux voir).
%------------------------------------------------
if randFLAG
    rdNum = rand(1,maxX); %#ok<UNRCH>
    [tmp,rdNum] = sort(rdNum);
else
    rdNum = 1:maxX;
end
viewALGO('init');

% GUI Initialization option.
%---------------------------
if isequal(optMETH,'InitVIEW') ,  return; end

% Search optimal partition (step 1).
%===================================
sortPART('normal');
for pas = 1:nbSTEP_ALG_Rupt , sortPART('force'); end
sortPART('normal');
[tmp,original_ORDER] = sort(current_ORDER);

% Amelioration !?
%----------------
[Perfo,idxMinScore] = min(Lst_Score);
X = X(original_ORDER,:);
for jj=1:idxMinScore , X = X(Lst_IdxSORT(:,jj),:); end
if plotFLAG , plotSCORE('alg',Perfo); end

% Search optimal partition (step 2).
%===================================
D = diff(X,1,1);
D = D~=0;
CumDIFF = sum(D~=0,2);
II = find(CumDIFF);
[Rupt_Weight,JJ] = sort(CumDIFF(II),'descend');
Rupt_Val = II(JJ);

% Keep only the mains ruptures.
%------------------------------
idxToDEL = Rupt_Weight<Max_Rupt_Weight;
Rupt_Val(idxToDEL)    = [];
Rupt_Weight(idxToDEL) = [];
nbRuptTOT = length(Rupt_Val);
if plotFLAG , viewALGO('endSort'); end

% Search optimal partition (step 3).
%===================================
switch lower(optMETH)
    case 'sim'  % Compute similarity indices.
        idx_Attrb = tplnksim;
        idx_Names = idx_Attrb(:,1);
        nbIdxSIM  = length(idx_Names);
        LNK_SIM_STRUCT_Cell = cell(1,nbRuptTOT);
        tab_IdxSIM  = zeros(nbRuptTOT,nbPART,nbIdxSIM);
        for nbRupt = 1:nbRuptTOT
            optPART = makeNewPart(Rupt_Val,nbRupt,nbSIG);
            Y = [optPART,X];
            [~,LNK_SIM_STRUCT] = partlnkandsim(Y,'one');
            LNK_SIM_STRUCT_Cell{nbRupt} = LNK_SIM_STRUCT;
            for kk=1:nbIdxSIM
                fn = idx_Names{kk};
                tab_IdxSIM(nbRupt,:,kk) = LNK_SIM_STRUCT.(fn)(2:end);
            end            
        end
        Rupt_IdxSIM = sum(permute(tab_IdxSIM,[1 3 2]),3)/nbPART;
        % Part_IdxSIM = sum(permute(tab_IdxSIM,[3 2 1]),3)/nbRuptTOT;
        [~,idxMaxSIM] = max(Rupt_IdxSIM,[],1);
        nbVAL = hist(idxMaxSIM,(1:nbIdxSIM));
        [dummy,idxBest] = sort(nbVAL,'descend');
        idxBest = idxBest(dummy>0);

    case 'jaccard'  % Compute Jaccard distance.
        Jacc_DIST = zeros(nbRuptTOT,nbPART);
        for nbRupt = 1:nbRuptTOT
            optPART = makeNewPart(Rupt_Val,nbRupt,nbSIG);
            % TMP = X-optPART(:,ones(1,nbPART));
            %------------------------------------------------
            [dummy,IdxCLU] = renumpart('col',[optPART , X]);
            TMP = IdxCLU(:,2:end) - IdxCLU(:,ones(1,nbPART));
            %------------------------------------------------
            TMP = TMP~=0;
            Jacc_DIST(nbRupt,:) = sum(TMP)';
        end
        Jacc_INDEX = sum(Jacc_DIST,2);
        [dummy,idxBest] = sort(Jacc_INDEX);
        idxBest = idxBest(dummy>0);

    case 'interintran'
        IIN_DIST = zeros(nbRuptTOT);
        signals = signals(current_ORDER,:);
        for nbRupt = 1:nbRuptTOT
            optPART = makeNewPart(Rupt_Val,nbRupt,nbSIG);
            [~,inter_SUR_intra_N] = ...
                partbetweenwithin(signals,optPART);
            IIN_DIST(nbRupt) = inter_SUR_intra_N;
        end
        [dummy,idxBest] = sort(IIN_DIST,'descend');
        idxBest = idxBest(dummy>0);

    case 'jacsim'  % Compute Jaccard similarity.
        Jacc_DIST = zeros(nbRuptTOT,nbPART);
        for nbRupt = 1:nbRuptTOT
            optPART = makeNewPart(Rupt_Val,nbRupt,nbSIG);
            [~,LNK_SIM_STRUCT] = partlnkandsim([optPART,X],'one');
            Jacc_DIST(nbRupt,:) = LNK_SIM_STRUCT.Jaccard(1,2:end);
        end
        Jacc_INDEX = sum(Jacc_DIST,2);
        [dummy,idxBest] = sort(Jacc_INDEX,'descend');
        idxBest = idxBest(dummy>0);
end

if ~manyOPT || isequal(nbOPT,1) , idxBest = idxBest(1); end
optPART = makeNewPart(Rupt_Val,idxBest,nbSIG);
if manyOPT && ~isequal(nbOPT,Inf) && size(optPART,2)>nbOPT
    optPART = optPART(:,1:nbOPT);
end
if plotFLAG , viewALGO('best'); end

% Reorder the best partitions.
%-----------------------------
optPART = optPART(original_ORDER,:);


%----------------------------------------------------------
    function sortPART(option)
        switch option
            case 'normal' , renPART = nbCLU;
            case 'force'  , renPART = rand(1,nbPART);
        end
        [tmp,renPART] = sort(renPART); %#ok<SETNU>
        [tmp,oldNUM]  = sort(renPART);
        X = X(:,renPART);
        score = getScore(X);
        if plotFLAG , plotSCORE('alg',score); end
        for k=1:nbPART
            tk = issorted(X(:,k));
            if ~tk
                [dummy,IdxSort] = sortrows(X,k);
                score  = getScore(dummy);
                if score<=Perfo || isequal(option,'force')
                    X = dummy;
                    Lst_IdxSORT = [Lst_IdxSORT,IdxSort];  %#ok<AGROW>
                    Lst_Score   = [Lst_Score , score];    %#ok<AGROW>
                    current_ORDER = current_ORDER(IdxSort);
                end
                if score<=Perfo
                    Perfo = score;
                    if plotFLAG , plotSCORE('alg',Perfo); end
                end
            end
        end
        X = X(:,oldNUM);
        score = getScore(X);
        if plotFLAG , plotSCORE('alg',score); end
    end
%----------------------------------------------------------
    function viewALGO(step)
        ax = Axe_CON_ALG;
        hdl_TXT = findobj(ax,'Type','text');
        delete(hdl_TXT);
        if isequal(step,'init')
            map = getscaledmap(ax,maxX);
            colormap(map)
            plotSCORE('ini',Perfo);
            return
        end

        curUnits = get(ax,'Units');
        set(ax,'Units','pixels')
        pos = get(ax,'Position');
        set(ax,'Units',curUnits);
        Wax = pos(3);
        dx = nbPART/Wax;
        x1 = 0;
        x2 = nbPART+1;
        xT = nbPART + 0.5 + 15*dx;
        xdata = [x1,x2];
        
        hold on
        switch step
            case 'endSort'
                nbPts = length(Rupt_Val);
                for j = 1:nbPts
                    y1 = Rupt_Val(j)+0.5;
                    ydata = [y1,y1];
                    line('YData',ydata,'XData',xdata,...
                        'Color','r','LineWidth',2,'Parent',ax);
                    text(xT,y1,int2str(Rupt_Weight(j)),...
                        'FontSize',8,'HorizontalAlignment','Center',...
                        'BackgroundColor',[1,1,0.8],...
                        'EdgeColor','k','Parent',ax);
                end
                pause(0.5)

            case 'best'
                nbPts = idxBest(1);
                for j = 1:nbPts
                    y1 = Rupt_Val(j)+0.5;
                    ydata = [y1,y1];
                    line('YData',ydata,'XData',xdata,...
                        'Color','k','LineWidth',3,'Parent',ax);
                    text(xT,y1,int2str(Rupt_Weight(j)),...
                        'FontSize',8,'HorizontalAlignment','Center',...
                        'BackgroundColor',[1,1,0.8],...
                        'EdgeColor','k','Parent',ax);
                end
        end
        
    end
%----------------------------------------------------------
    function plotSCORE(option,Sc)
        col_VER = [0 0 0.5];
        Z = getZVal(optRENUM,X,rdNum);
        scoreSTR = getWavMSG('Wavelet:mdw1dRF:Part_Score',Sc);
        if nbSIG>20 ,
            ytick   = (1:nbSIG);
            ylabINI = '';
            ylabCUR = '';
        else
            ytick   = (1:nbSIG);
            ylabINI = int2str(ytick');
            ylabCUR = int2str(current_ORDER);
        end        
        
        xtickLab = [repmat('P',nbPART,1) , int2str((1:nbPART)')];
        if isequal(option,'ini')
            axeCur = Axe_CON_INI;
            set(axeCur,'FontSize',8);
            image(Z,'Parent',axeCur);
            for k = 1.5:1:nbPART
                line('XData',[k k],'YData',[0 nbSIG+1],...
                    'Color',col_VER,'LineWidth',2,'Parent',axeCur);
            end
            title(getWavMSG('Wavelet:mdw1dRF:Init_Data_Ord'),'Parent',axeCur);
            xlabel(scoreSTR,'Parent',axeCur);
            set(axeCur,...
                'XTick',(1:nbPART),'XGrid','On','XTickLabel',xtickLab, ...
                'YTick',ytick,'YTickLabel',ylabINI);
            
        end
        axeCur = Axe_CON_ALG;
        set(axeCur,'FontSize',8);
        image(Z,'Parent',axeCur);
        for k = 1.5:1:nbPART
            line('XData',[k k],'YData',[0 nbSIG+1],...
                'Color',col_VER,'LineWidth',2,'Parent',axeCur);
        end
        xlabel(scoreSTR,'Parent',axeCur);
        title(getWavMSG('Wavelet:mdw1dRF:Reordered_Data'),'Parent',axeCur);
        set(axeCur,...
            'XTick',(1:nbPART),'XGrid','On','XTickLabel',xtickLab, ...
            'YTick',ytick,'YTickLabel',ylabCUR);
        pause(0.05);
    end
%----------------------------------------------------------

end

%===================================================================
%----------------------------------------------------------
function optPART = makeNewPart(Rupt_Val,nbRupt,nbSIG)
    nbNEW = length(nbRupt);
    optPART = zeros(nbSIG,nbNEW);
    for j = 1:nbNEW
        rupts = sort(Rupt_Val(1:nbRupt(j)));
        first   = [1;rupts+1];
        last    = [rupts ; nbSIG];
        for k = 1:nbRupt(j)+1
            optPART(first(k):last(k),j) = k;
        end
    end
end
%----------------------------------------------------------
function [Sc,S,D] = getScore(V)
    D  = diff(V,1,1);
    S  = sum(D~=0,1);
    Sc = sum(S);
end
%----------------------------------------------------------
function Z = getZVal(optRENUM,X,rdNum)
    switch optRENUM
        case 'min'
            Z = rdNum(X);

        case 'max'
            Z = zeros(size(X));
            idx = 1;
            for k=1:size(X,2)
                maxcol = max(X(:,k));
                for j = 1:maxcol
                    II = X(:,k)==j;
                    Z(II,k) = rdNum(idx);
                    idx = idx+1;
                end
            end
    end
end
%----------------------------------------------------------
%===================================================================
