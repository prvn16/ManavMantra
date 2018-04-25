function [YFIT,R,COEFF,IOPT,qual,X] = wmpalg(AlgNAM,Y,varargin)
%WMPALG Matching Pursuit
%   Matching Pursuit computes the adaptive greedy decomposition
%   of a vector in a dictionary. 
%
%   YFIT = WMPALG(ALGNAM,Y,X) returns an adaptive greedy approximation of Y
%   in the dictionary X.
%   
%   ALGNAM is a string giving the name of the algorithm.
%   Valid values for ALGNAM are:
%     - 'BMP' for (Basic) Matching Pursuit
%     - 'OMP' Orthogonal Matching Pursuit
%     - 'WMP' Weak Matching Pursuit
%   Y is the N-by-1 vector to be modeled.
%   X is a N-by-P dictionary matrix. The columns of X are scaled to have L2 
%   unit norm. You can build X with the WMPDICTIONARY function.
%
%   [YFIT,R,COEFF,IOPT,QUAL,X] = WMPALG(...), returns:
%     - R the residual Y-YFIT
%     - IOPT the vector of indices of the retained 
%       columns of X
%     - COEFF the corresponding vector of coefficients 
%     - QUAL the proportion of retained energy
%
%   By default the algorithm stops after at most 25 iterations. 
%   The stopping rule can be relaxed using the following 
%   syntax:
%     [...] = WMPALG(...,'PropName1',PropValue1,...
%                         'PropName2',PropValue2,...)
%       'itermax': PropValue is a positive integer fixing the maximum 
%                  number of iterations of the decomposition algorithm.      
%       'maxerr' : PropValue is a cell array which contains the name of
%                  the norm used in the error computation and the maximum
%                  percentage of the relative admissible value. The
%                  available error names are 'L1', 'L2' or 'Linf'.
%
%   When ALGNAM is equal to 'WMP', you may specify a real coefficient, CFS,
%   in the interval (0,1] (see the algorithm section in the algorithm
%   section in the documentation). If unspecified, CFS defaults to 0.60.
%     [...] = WMPALG(...,'wmpcfs',CFS)
%
%   To plot the output:
%     [...] = WMPALG(...,'typeplot',TYPE,'stepplot',STEP)
%      'typeplot' : TYPE gives the type of plot. You can enter 0 or 'none',
%      1 or 'one' , 2 or 'movie', 3 or 'stepwise'. The default is 0 or
%      'none'.
%      'stepplot' : When TYPE is equal to 2 or 3 ('movie' or
%                   'stepwise'), STEP specifies the number of
%                   iterations between two successive plots.
%
%   Instead of providing the dictionary X as an input argument, 
%   you can generate the dictionary by using
%     [...] = WMPALG(ALGNAM,Y,'PropName1',PropValue1,...
%                            'PropName2',PropValue2,...)
%   and specifying the parameters corresponding to the property names 
%   'LstCpt', 'addbeg', and 'addend' (see WMPDICTIONARY for more details).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 10-Sep-2010.
%   Last Revision: 19-Sep-2011.
%   Copyright 1995-2011 The MathWorks, Inc.

% Default and initialization for parameters.
%-------------------------------------------
itermax  = [];
namERR   = [];
valERR   = [];
onceFLAG = [];
typePLOT = [];
stepPLOT = [];
itermax_DEF  = 25;
typePLOT_DEF = 0;
onceFLAG_DEF = false;
stepPLOT_DEF = 5;
wmpcfs   = NaN;
OK_Dico  = false;

% Use column vector
Y = Y(:);
N = length(Y);
xval = 1:N;

% Check input arguments.
%----------------------
if isnumeric(varargin{1}) && ismatrix(varargin{1})
    X = varargin{1};
    varargin = varargin(2:end);
    OK_Dico = true;
end
nbIN = length(varargin);
argDICO = [];
k = 1;
while k<=nbIN
    argNAM = lower(varargin{k});
    switch argNAM
        case 'lstcpt'   , argDICO = [argDICO,k,k+1]; k = k+2;  %#ok<*AGROW>
        case 'addbeg'   , argDICO = [argDICO,k,k+1]; k = k+2; 
        case 'addend'   , argDICO = [argDICO,k,k+1]; k = k+2;
        case 'typeplot' , typePLOT = varargin{k+1}; k = k+2;
        case 'stepplot' , stepPLOT = varargin{k+1}; k = k+2;
        case 'itermax'  , itermax  = varargin{k+1}; k = k+2;
        case 'wmpcfs'   , wmpcfs   = varargin{k+1}; k = k+2;
        case 'onceflag' , onceFLAG = varargin{k+1}; k = k+2;
        case 'maxerr'   , TMP = varargin{k+1};      k = k+2;
            if ~isempty(TMP)
                namERR  = upper(TMP{1}); valERR  = TMP{2}; 
            end
        otherwise
            error(message('Wavelet:FunctionInput:ArgumentName'));
    end
end
if isempty(typePLOT) , typePLOT = typePLOT_DEF; end
if isempty(onceFLAG) , onceFLAG = onceFLAG_DEF; end
if isempty(stepPLOT) , stepPLOT = stepPLOT_DEF; end
if isempty(valERR)   , valERR = 0; end

if ~isempty(namERR)
    switch upper(namERR)
        case {'NONE','L1','L2','LINF'} 
        otherwise , 
            error(message('Wavelet:FunctionInput:ArgumentName'));
    end
    if isempty(itermax) , itermax = min([N,500]); end
else
    namERR = 'NONE';
    if isempty(itermax) , itermax = itermax_DEF; end
end

AlgNAM = upper(AlgNAM);
if  ~(strcmp(AlgNAM,'BMP') || strcmp(AlgNAM,'OMP') || strcmp(AlgNAM,'WMP'))
    AlgNAM = 'BMP';
end

% Initialization of the dictionnary.
%-----------------------------------
if OK_Dico && ~isempty(argDICO)
    error(message('Wavelet:wmp1dRF:Invalid_ArgDic'))
end
if ~OK_Dico
    if isempty(argDICO) 
        [X,nbVect] = wmpdictionary(N); 
    else
        [X,nbVect] = wmpdictionary(N,varargin{argDICO});
    end
else
    nbVect = size(X,2);    
end
p = size(X,2);

if ~(isequal(onceFLAG,0) || isequal(onceFLAG,1)) , onceFLAG = 0; end
if ~(isnumeric(itermax) && itermax>0 && isequal(itermax,fix(itermax))) 
    itermax = min([p,itermax_DEF]);
end

J     = 1:p;              % index of remaining vectors in the dictionary
COEFF = zeros(itermax,1); % Coefficients
YFIT  = zeros(N,1) ;
qual  = zeros(1,itermax);
IOPT  = zeros(1,itermax); % Index of the selected vectors

% Normalization of columns of X.
S = sum(X.*X).^0.5;
X = X./repmat(S,N,1);     % the columns norm are set to 1
N2Y = Y'*Y;               % square norm 

% Plot arguments analysis.
%-------------------------
if ispc , FS = 8; else FS = 12; end
if isequal(typePLOT,2) || isequal(typePLOT,3) || ...
        isequal(typePLOT,'stepwise') || isequal(typePLOT,'movie') 
    fig = figure('Position',[240 120 720 640],'DefaultAxesFontSize',FS);
    kPLOT = 0:stepPLOT:itermax;
    if ~ismember(itermax,kPLOT) , kPLOT = [kPLOT,itermax]; end
    nV = length(nbVect);
    if isequal(typePLOT,'movie') , typePLOT = 2;
    elseif isequal(typePLOT,'stepwise') , typePLOT = 3;
    end
    if isequal(typePLOT,3)
        msg = getWavMSG('Wavelet:wmp1dRF:Press_any_key');
        txt_Step = uicontrol('style','text','Position',[0 0 720 18],...
            'String',msg,'Parent',fig);
    end
else
    nV = length(nbVect);
    kPLOT = itermax;
end
%--------------------------------------------------------------------

Add = zeros(N,1);
R = Y;           % initialization of residual
switch AlgNAM
    case 'BMP'   % Basic Matching Pursuit Algorithm.
        k = 1;
        stopALG = false;
        while ~stopALG
            [~,i]	 = max(abs(R' * X));   % choose the max(abs(scalar product)
            kopt     = J(i);               % index of the kept variable
            COEFF(k) = R'*X(:,i);          % coefficient
            Z		 = COEFF(k) * X(:,i);  % projection onto the kept atom
            IOPT(k)	 = kopt;
            if onceFLAG
                J      = setdiff(J,kopt);    %#ok<*UNRCH>
                X(:,i) = [];
            end
            YFIT	= YFIT + Z;             % fit
            R		= R - Z;                % residuals
            qual(k)	= norm(COEFF)^2 / N2Y;  % cumulated quality
            Add     = Add+Z;                % cumulated modifs between 2 plots
            
            ErrL1 = 100*(norm(R,1)/norm(Y,1));
            ErrL2 = 100*(norm(R)/norm(Y));
            ErrMax = 100*(norm(R,Inf)/norm(Y,Inf));
            if ~isempty(namERR)
                switch upper(namERR)
                    case 'NONE' , curERR = Inf;
                    case 'L1'   , curERR = ErrL1;
                    case 'L2'   , curERR = ErrL2;
                    case 'LINF' , curERR = ErrMax;
                end
            end            
            if k>=itermax || curERR<valERR
                stopALG = true;
                kPLOT(kPLOT>=k) = [];
                kPLOT = [kPLOT,k]; %#ok<AGROW>
            end
            
            if (isequal(typePLOT,2) || isequal(typePLOT,3)) && ismember(k,kPLOT)
                plotDEC;
            end
            if ~stopALG , k = k+1; end
        end
        COEFF(k+1:end) = [];
        qual(k+1:end)  = []; 
        IOPT(k+1:end)  = [];
        if isequal(typePLOT,1) || isequal(typePLOT,'one') , onePLOT; end
        if  isequal(typePLOT,3) || isequal(typePLOT,'stepwise')
            set(txt_Step,'String',getWavMSG('Wavelet:wmp1dRF:End_of_ALG'));
        end
        
    case {'OMP','WMP'}
        if isnan(wmpcfs) , wmpcfs = 0.60; end
        XX  = X;
        k = 1;
        stopALG = false;
        while ~stopALG
            scalProd = abs(R' * XX);
            okALG = false;
            if isequal(AlgNAM,'WMP')
                i = find(scalProd>wmpcfs*norm(R),1,'first');
                if ~isempty(i) , okALG = true; end
            end
            if ~okALG , [~,i] = max(scalProd); end  % OMP and ...
            kopt = J(i);           % index of the kept atom.
            J    = setdiff(J,kopt);
            IOPT(k)	= kopt;
            P    = X(:, IOPT(1:k));
            TMP  = ((P'*P)\P')*Y;
            COEFF(k) = TMP(k);
            Z = P*TMP - YFIT;
            Add  = Add + Z;
            YFIT = YFIT + Z;
            R    = R - Z;
            XX = X(:,J);
            qual(k)  = norm(YFIT)^2 / N2Y;
            if isempty(J)
                qual(k+1:end) = []; 
                IOPT(k+1:end) = []; 
                stopALG = true;
            end
            ErrL1 = 100*(norm(R,1)/norm(Y,1));
            ErrL2 = 100*(norm(R)/norm(Y));
            ErrMax = 100*(norm(R,Inf)/norm(Y,Inf));
            if ~isempty(namERR)
                switch upper(namERR)
                    case 'NONE' , curERR = Inf;
                    case 'L1'   , curERR = ErrL1;
                    case 'L2'   , curERR = ErrL2;
                    case 'LINF' , curERR = ErrMax;
                end
            end
            if k>=itermax || curERR<valERR
                stopALG = true;
                kPLOT(kPLOT>=k) = [];
                kPLOT = [kPLOT,k]; %#ok<AGROW>
            end
            if (isequal(typePLOT,2) || isequal(typePLOT,3)) && ismember(k,kPLOT)
                plotDEC;
            end
            if ~stopALG , k = k+1; end
        end
        if ~isempty(namERR)
            qual(k+1:end) = []; IOPT(k+1:end) = [];
        end
        
        if isequal(typePLOT,1) || isequal(typePLOT,'one') , onePLOT; end
        if  isequal(typePLOT,3) || isequal(typePLOT,'stepwise')
            set(txt_Step,'String',getWavMSG('Wavelet:wmp1dRF:End_of_ALG'));
        end
        
        COEFF = (P' * P) \ P' * Y;
        YFIT  = P * COEFF;

end

if isequal(typePLOT,'hor')  % Test horizontal plot
    switch AlgNAM
        case 'BMP' , nameSTR = getWavMSG('Wavelet:wmp1dRF:BMP_ALG');
        case 'OMP' , nameSTR = getWavMSG('Wavelet:wmp1dRF:OMP_ALG');
        case 'WMP' , nameSTR = getWavMSG('Wavelet:wmp1dRF:WMP_ALG');
    end
    if ispc , FS = 8; else FS = 12; end
    figure('Name',nameSTR,'Position',[200 124 880 568],...
        'DefaultAxesFontSize',FS);
    NBcol = 3;
    %---------------------------------------------------------
    ax(1) = subplot(2,NBcol,1);
    plot(1:p,zeros(p,1),IOPT,COEFF, 's',...
        'MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',5);
    title(getWavMSG('Wavelet:wmp1dRF:Sel_Cfs'));
    xlabel(getWavMSG('Wavelet:wmp1dRF:Index'));
    ylabel(getWavMSG('Wavelet:wmp1dRF:Cfs_Val'));
    set(ax(1),'XLim',[min(IOPT),max(IOPT)]); grid
    %---------------------------------------------------------
    if length(unique(IOPT))==length(IOPT)
        ax(2) = subplot(2,NBcol,2);
        plot(IOPT,1:length(IOPT),'r-'); hold on;
        plot(IOPT,1:length(IOPT),'d',...
            'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',7)
        axis tight; grid
        xlabel(getWavMSG('Wavelet:wmp1dRF:Index'));
        ylabel(getWavMSG('Wavelet:wmp1dRF:Rank'));
        title(getWavMSG('Wavelet:wmp1dRF:Rank_of_Sel'));
    else
        ax(2) = subplot(2,NBcol,2); 
        plot(IOPT,1:length(IOPT),'r-'); hold on;
        plot(IOPT,1:length(IOPT),'d',...
            'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',7)
        axis tight; grid;
        xlabel(getWavMSG('Wavelet:wmp1dRF:Index'));
        ylabel(getWavMSG('Wavelet:wmp1dRF:Rank'));
        title(getWavMSG('Wavelet:wmp1dRF:Rank_of_Sel_Rep'));
    end
    %---------------------------------------------------------
    ax(3) = subplot(2,NBcol,3);
    set(ax(3),'Ylim',[min(qual)-0.1 1.02])
    mCOL = [0 0 0.8];
    plot(1:length(qual),qual,'Color',mCOL); hold on;
    plot(1:length(qual),qual,'s',...
            'MarkerEdgeColor',mCOL,'MarkerFaceColor',mCOL,'MarkerSize',5)
    axis tight; grid
    xlabel(getWavMSG('Wavelet:wmp1dRF:Iteration'));
    ylabel(getWavMSG('Wavelet:wmp1dRF:Quality'));
    title(getWavMSG('Wavelet:wmp1dRF:Qual_Iter'));
    %---------------------------------------------------------
    subplot(2,1,2);
    plot(1:N,Y,'.-r',1:N,YFIT,'.-b'); axis tight
    legend(getWavMSG('Wavelet:wmp1dRF:Leg_Data'), ...
        getWavMSG('Wavelet:wmp1dRF:Leg_Fit'),'AutoUpdate','off')
    title(getWavMSG('Wavelet:wmp1dRF:Title_Iter',itermax,p));
    S1 = num2str(ErrL2,'%5.2f %%');
    S2 = num2str(ErrMax,'%5.2f %%');
    S3 = num2str(ErrL1,'%5.2f %%');
    xlabel(getWavMSG('Wavelet:wmp1dRF:Relative_Err',S1,S2,S3));
end

    %------------------------------------------------------------------
    function plotDEC
        idxKplot = find(kPLOT==k);
        newk = (kPLOT(idxKplot-1)+1):kPLOT(idxKplot);
        if length(newk)<15 , 
            newkSTR = int2str(newk);
        else
            newkSTR = ...
                [int2str(newk(1:3)) '  ...  ' int2str(newk(end-2:end))];
        end
        %---------------------------------------------------
        subplot(311)
        hL = plot(xval,Y,'r-',xval,YFIT,'b-');
        set(hL,'Linewidth',1.5)
        axis tight
        legend(getWavMSG('Wavelet:wmp1dRF:Leg_Sig'), ...
            getWavMSG('Wavelet:wmp1dRF:Leg_App'),'AutoUpdate','off');
        S1 =  num2str(qual(k));       
        title({getWavMSG('Wavelet:wmp1dRF:Title_DEC_1',p), ...
            getWavMSG('Wavelet:wmp1dRF:Title_DEC_2',k,S1)});
        S1 = num2str(ErrL2,'%5.2f %%');
        S2 = num2str(ErrMax,'%5.2f %%');
        S3 = num2str(ErrL1,'%5.2f %%');
        xlabel(getWavMSG('Wavelet:wmp1dRF:Relative_Err',S1,S2,S3));
        %---------------------------------------------------
        subplot(312)
        plot(xval,Add,'g-');
        axis tight
        title(getWavMSG('Wavelet:wmp1dRF:Title_Added',newkSTR));
        %---------------------------------------------------
        ax = subplot(325);
        first = 1;
        for jjj = 1:nV
            nbval = nbVect(jjj);
            last = first+nbval-1;
            yy = jjj*ones(1,nbval);
            xx = (1:nbval);
            plot([0 xx],[jjj yy],'-k'); hold on;
            tf = ismember(IOPT,first:last);
            if ~isempty(tf) && any(tf)
                index = IOPT(tf)-first+1;
                yytf = yy(index) + 0.5  ;
                XXX = [repmat(xx(index),2,1) ; NaN(1,size(xx(index),2))]; 
                XXX = XXX(:);
                YYY = [yytf ; yy(index) ; NaN(size(yytf))];
                YYY = YYY(:);
                plot(XXX,YYY,'-r');
                plot(xx(index),yytf,'.r','MarkerSize',8);
            end
            first = last+1;
        end
        axis tight
        set(ax,'Xlim',[1 nbval],'Ylim',[0.5,nV+1]);
        title(getWavMSG('Wavelet:wmp1dRF:Ndx_of_Sel'));
        set(ax,'Ytick',(1:nV),'YTicklabel',int2str((1:nV)'));
        %---------------------------------------------------
        bx = subplot(326);
        mCOL = [0 0 0.8];
        plot(1:length(qual),qual,'Color',mCOL,'Parent',bx); hold on;
        plot(1:length(qual),qual,'s','Parent',bx,...
            'MarkerEdgeColor',mCOL,'MarkerFaceColor',mCOL,'MarkerSize',5)
        hold off;
        axis tight; grid
        xlabel(getWavMSG('Wavelet:wmp1dRF:Iteration'),'Parent',bx)
        ylabel(getWavMSG('Wavelet:wmp1dRF:Quality'),'Parent',bx);
        title(getWavMSG('Wavelet:wmp1dRF:Qual_Iter'),'Parent',bx);
        %---------------------------------------------------
        % abs_CFS = rem(IOPT,1024);
        % set(ax,'Xlim',[0 max(abs_CFS)+1]);
        xlabel(getWavMSG('Wavelet:wmp1dRF:Ind_of_CPT'),'Parent',ax);
        pause(0.20);
        Add = zeros(N,1);
        if typePLOT==3 , pause; end
    end
    %------------------------------------------------------------------
    function onePLOT
        figure('Name',getWavMSG('Wavelet:wmp1dRF:MP_ALG'),...
            'Position',[240 60 698 740],'DefaultAxesFontSize',FS);
        %---------------------------------------------------
        subplot(311)
        hL = plot(xval,Y,'r-',xval,YFIT,'b-');
        set(hL,'Linewidth',1.5)
        axis tight
        legend(getWavMSG('Wavelet:wmp1dRF:Leg_Sig'),...
            getWavMSG('Wavelet:wmp1dRF:Leg_App'),'AutoUpdate','off');
        S1 =  num2str(qual(k));       
        title({getWavMSG('Wavelet:wmp1dRF:Title_DEC_1',p), ...
            getWavMSG('Wavelet:wmp1dRF:Title_DEC_2',k,S1)});
        S1 = num2str(ErrL2,'%5.2f %%');
        S2 = num2str(ErrMax,'%5.2f %%');
        S3 = num2str(ErrL1,'%5.2f %%');
        xlabel(getWavMSG('Wavelet:wmp1dRF:Relative_Err',S1,S2,S3));
        %---------------------------------------------------
        subplot(323)
        plot(1:p,zeros(p,1),IOPT,COEFF(1:length(IOPT)), 's',...
            'MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',5);
        title(getWavMSG('Wavelet:wmp1dRF:Sel_Cfs'));
        xlabel(getWavMSG('Wavelet:wmp1dRF:Index'));
        ylabel(getWavMSG('Wavelet:wmp1dRF:Cfs_Val'));
        set(gca,'XLim',[min(IOPT),max(IOPT)]); grid
        %---------------------------------------------------
        subplot(324)
        plot(IOPT,1:length(IOPT),'r-'); hold on;
        plot(IOPT,1:length(IOPT),'d',...
            'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',7)
        axis tight; grid
        xlabel(getWavMSG('Wavelet:wmp1dRF:Index'));
        ylabel(getWavMSG('Wavelet:wmp1dRF:Rank'));
        title(getWavMSG('Wavelet:wmp1dRF:Rank_of_Sel'));
        %---------------------------------------------------
        ax = subplot(325);
        first = 1;
        for jjj = 1:nV
            nbval = nbVect(jjj);
            last = first+nbval-1;
            yy = jjj*ones(1,nbval);
            xx = (1:nbval);
            plot(xx,yy,'-k'); hold on;
            tf = ismember(IOPT,first:last);
            if ~isempty(tf) && any(tf)
                index = IOPT(tf)-first+1;
                yytf = yy(index) + 0.5  ;
                XXX = [repmat(xx(index),2,1) ; NaN(1,size(xx(index),2))]; 
                XXX = XXX(:);
                YYY = [yytf ; yy(index) ; NaN(size(yytf))];
                YYY = YYY(:);
                plot(XXX,YYY,'-r');
                plot(xx(index),yytf,'.r','MarkerSize',8);
            end
            first = last+1;
        end
        axis tight
        set(ax,'Ylim',[0.5,nV+1]);
        title(getWavMSG('Wavelet:wmp1dRF:Ndx_of_Sel'));
        set(ax,'Ytick',(1:nV),'YTicklabel',int2str((1:nV)'));
        % set(ax,'Ytick',(1:nV),'YTicklabel',LstCPT_LAB);
        %---------------------------------------------------
        bx = subplot(326);
        mCOL = [0 0 0.8];
        plot(1:length(qual),qual,'Color',mCOL,'Parent',bx); hold on;
        plot(1:length(qual),qual,'s','Parent',bx,...
            'MarkerEdgeColor',mCOL,'MarkerFaceColor',mCOL,'MarkerSize',5)
        axis tight; grid
        xlabel(getWavMSG('Wavelet:wmp1dRF:Iteration'),'Parent',bx);
        ylabel(getWavMSG('Wavelet:wmp1dRF:Quality'),'Parent',bx);
        title(getWavMSG('Wavelet:wmp1dRF:Qual_Iter'),'Parent',bx);
        %---------------------------------------------------
        % abs_CFS = rem(IOPT,1024);
        % set(ax,'Xlim',[1 max(abs_CFS)+1]);
        xlabel(getWavMSG('Wavelet:wmp1dRF:Ind_in_Sub'),'Parent',ax);
        pause(0.20);
        Add = zeros(N,1);
    end
    %------------------------------------------------------------------
end

