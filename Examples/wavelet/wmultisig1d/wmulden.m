function varargout = wmulden(varargin)
%WMULDEN Wavelet multivariate denoising.
%   [X_DEN,NPC,NESTCOV,DEC_DEN,PCA_Params,DEN_Params] = ...
%               WMULDEN(X,LEVEL,WNAME,NPC_APP,NPC_FIN,TPTR,SORH)
%   or  [...] = WMULDEN(X,LEVEL,WNAME,'mode',EXTMODE,NPC_APP,...)
%   returns a denoised version X_DEN of the input matrix X.
%   The strategy combines univariate wavelet denoising in the  
%   basis where the estimated noise covariance matrix is  
%   diagonal with non-centered Principal Component 
%   Analysis (PCA) on approximations in the wavelet domain or
%   with final PCA.
%
%   Input matrix X contains P signals of length N stored
%   columnwise where N > P. 
%
%   Wavelet Decomposition Parameters.
%   ---------------------------------
%   The Wavelet decomposition is performed using the 
%   decomposition level LEVEL and the wavelet WNAME. 
%   EXTMODE is the extended mode for the DWT (default 
%   is returned by DWTMODE).
%
%   If a decomposition DEC obtained using MDWTDEC is available, 
%   then you can use [...] = WMULDEN(DEC,NPC_APP) instead of
%   [...] = WMULDEN(X,LEVEL,WNAME,'mode',EXTMODE,NPC_APP).
%
%   Principal Components Parameters NPC_APP and NPC_FIN.
%   ----------------------------------------------------
%   Input selection methods NPC_APP and NPC_FIN define the way  
%   to select principal components for approximations at level 
%   LEVEL in the wavelet domain and for final PCA after 
%   wavelet reconstruction respectively.
%
%   If NPC_APP (resp. NPC_FIN) is an integer, it contains the number 
%   of retained principal components for approximations at  
%   level LEVEL (resp. for final PCA after wavelet reconstruction).
%   NPC_XXX must be such that:   0 <= NPC_XXX <= P.
%
%   NPC_APP or NPC_FIN = 'kais' (resp. 'heur') selects
%   automatically the number of retained principal components
%   using the Kaiser's rule (resp. the heuristic rule).
%      - Kaiser's rule keeps the components associated with 
%        eigenvalues exceeding the mean of all eigenvalues.
%      - heuristic rule keeps the components associated with 
%        eigenvalues exceeding 0.05 times the sum of all 
%        eigenvalues.
%   NPC_APP or NPC_FIN = 'none' is equivalent to NPC_APP or 
%   NPC_FIN = P.
%
%   De-Noising Parameters TPTR, SORH (See WDEN and WBMPEN).
%   -------------------------------------------------------
%   Default values are: TPTR = 'sqtwolog' and SORH = 's'.
%   Valid values for TPTR are:
%       'rigrsure','heursure','sqtwolog','minimaxi'
%       'penalhi','penalme','penallo'
%   Valid values for SORH are: 's' (soft) or 'h' (hard)
%
%   Outputs.
%   --------
%   X_DEN is a denoised version of the input matrix X.
%   NPC is the vector of selected numbers of retained
%   principal components.
%   NESTCOV is the estimated noise covariance matrix obtained 
%   using the minimum covariance determinant (MCD) estimator.
%   DEC_DEN is the wavelet decomposition of X_DEN. See MDWTDEC
%   for more information on decomposition structure. 
%   PCA_Params is a structure such that:
%       PCA_Params.NEST = {pc_NEST,var_NEST,NESTCOV}
%       PCA_Params.APP  = {pc_APP,var_APP,npc_APP}
%       PCA_Params.FIN  = {pc_FIN,var_FIN,npc_FIN}
%   where: 
%       - pc_XXX is a P-by-P matrix of principal components.
%         The columns are stored according to the descending 
%         order of the variances.
%       - var_XXX is the principal component variances vector. 
%       - NESTCOV is the covariance matrix estimate for detail 
%         at level 1.
%   DEN_Params is a structure such that:
%       DEN_Params.thrVAL is a vector of length LEVEL which 
%       contains the threshold values for each level. 
%       DEN_Params.thrMETH is a string containing the name of 
%       denoising method (TPTR)
%       DEN_Params.thrTYPE  is a char containing the type of 
%       thresholding (SORH)
%
%   Special cases.
%   --------------
%   [DEC,PCA_Params] = WMULDEN('estimate',DEC,NPC_APP,NPC_FIN)
%   returns the wavelet decomposition DEC and the Principal 
%   Components Estimates PCA_Params.
%
%   [X_DEN,NPC,DEC_DEN,PCA_Params] = WMULDEN('execute',DEC,PCA_Params)
%   or  [...] = WMULDEN('execute',DEC,PCA_Params,TPTR,SORH) uses the
%   Principal Components Estimates PCA_Params previously computed.
%   
%   The input value DEC can be replaced by X, LEVEL and WNAME.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Jan-2005.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

% Check input arguments.
nextARG = 1;
if ischar(varargin{1})
    switch lower(varargin{1}(1:3))
        case 'est'  , option = 'estimate'; nextARG = 2;
        case 'exe'  , option = 'execute';  nextARG = 2;
        otherwise   , option = 'compute';
    end
else
    option = 'compute';
end
if isstruct(varargin{nextARG})
    flagDEC = true;
    dec = varargin{nextARG};
    nextARG = nextARG+1;
    n = dec.dataSize(1);
    p = dec.dataSize(2);
    level = dec.level;
else
    flagDEC = false;
    [x,level,wname] = deal(varargin{nextARG:2+nextARG});
    nextARG = nextARG+3;
    [n,p] = size(x);
end
if n<=p, error(message('Wavelet:FunctionArgVal:Invalid_SizMat')), end

if ~flagDEC % Wavelet decomposition.
    if isequal(varargin{nextARG},'mode')
        extMode = varargin{nextARG+1};
        nextARG = nextARG+2;
    else
        extMode = dwtmode('status','nodisp');
    end
    dec = mdwtdec('c',x,level,wname,'mode',extMode);
end

if ~isequal(option,'estimate')
    [npc_APP,npc_FIN] = deal(varargin{nextARG:1+nextARG});
    nextARG = nextARG+2;
    if isequal(npc_APP,Inf) , npc_APP = p; end
    if isequal(npc_FIN,Inf) , npc_FIN = p; end
end

if ~isequal(option,'execute')   % option = 'estimate' or 'compute'
    % Estimated robust covariance (detail 1).
    coefs  = dec.cd{1};
    [pc_NEST,var_NEST,nestcov] = D1_robust_COVAR(coefs);
    PCA_Params.NEST = {pc_NEST,var_NEST,nestcov};
    
    % Approximation components estimation.
    coefs = dec.ca;
    [pc_APP,~,var_APP] = wpca(coefs,false);
    PCA_Params.APP = {pc_APP,var_APP,NaN};
    PCA_Params.FIN = {[],[],NaN};
    if isequal(option,'estimate')
        varargout = {dec,PCA_Params};
        if nargout>2
            npcKAIS = sum(var_APP>mean(var_APP));
            npcHEUR = sum(var_APP>0.05*sum(var_APP));
            varargout = [varargout,npcKAIS,npcHEUR];
        end
        return
    end
else   % option = 'execute'
    PCA_Params = varargin{nextARG};
    nextARG = nextARG+1;
    [pc_NEST,var_NEST,nestcov] = deal(PCA_Params.NEST{:});
    [pc_APP,var_APP] = deal(PCA_Params.APP{1:2});
end

if nargin<nextARG
    % Set default thresholding parameters for denoising.
    tptr = 'sqtwolog';
    sORh = 's';
else
    [tptr,sORh] = deal(varargin{nextARG:nextARG+1});
end

if ischar(npc_APP)
    switch npc_APP
        case 'kais' , npc_APP = sum(var_APP>mean(var_APP));
        case 'heur' , npc_APP = sum(var_APP>0.05*sum(var_APP));
        case 'none' , npc_APP = p;
        otherwise   , error(message('Wavelet:FunctionArgVal:Invalid_SelMeth'))
    end
else
    if (npc_APP>p) || (npc_APP<0)
        error(message('Wavelet:FunctionArgVal:Invalid_SelNum'))
    end
end

if ischar(npc_FIN)
    switch npc_FIN
        case {'kais','heur'}
        case {'none'} ,npc_FIN = p;
        otherwise ,  error(message('Wavelet:FunctionArgVal:Invalid_SelMeth'))
    end
else
    if (npc_FIN>p) || (npc_FIN<0) 
        error(message('Wavelet:FunctionArgVal:Invalid_SelNum'))
    end
end

thrVAL = zeros(1,level);
switch tptr
    case {'rigrsure','heursure','sqtwolog','minimaxi'}
        % Threshold details level by level in the diagonal basis
        % and perform PCA approximations.
        for j = 1:level
            coefs = dec.cd{j};
            newdata = coefs*pc_NEST;

            % detail coefficients thresholding.
            for i=1:p
                std = sqrt(var_NEST(i));
                thrVAL(i) = std*thselect(newdata(:,i),tptr);
                newdata(:,i) = wthresh(newdata(:,i),sORh,thrVAL(i));
            end

            % detail coefficients reconstruction.
            dec.cd{j} = newdata*pc_NEST';
        end
        if npc_APP<p
            coefs = dec.ca;
            % perform PCA.
            newdata = coefs*pc_APP;

            % the last columns of pc_APP are replaced by zeros.
            thrpc = pc_APP;
            thrpc(:,npc_APP+1:p) = 0;

            % reconstruction of new coefficients for approximations
            dec.ca = newdata * thrpc';
        end
        
    case {'penalhi','penalme','penallo'}
        %-----------------
        % BMVal : 1 --> 5
        %-----------------
        BMVal = 10;
        switch tptr
            case 'penalhi' , alpha = 5*(3*BMVal+1)/8; % Min: 2.5 - Max: 10
            case 'penalme' , alpha = (BMVal+5)/4;     % Min: 1.5 - Max: 2.5
            case 'penallo' , alpha = (BMVal+3)/4;     % Min: 1   - Max: 2
        end
        decTMP = dec;
        decTMP.ca = decTMP.ca*pc_NEST;
        for j=1:level , decTMP.cd{j} = decTMP.cd{j}*pc_NEST; end
        [newdata,longs] = wdec2cl(decTMP);
        for i=1:p
            std = sqrt(var_NEST(i));
            thrVAL(i) = wbmpen(newdata(:,i)',longs',std,alpha);
        end
        
        for j = 1:level
            coefs = decTMP.cd{j};
            newdata = coefs*pc_NEST;
            for i=1:p
                newdata(:,i) = wthresh(newdata(:,i),sORh,thrVAL(i));
            end
            dec.cd{j} = newdata*pc_NEST';
        end
        if npc_APP<p
            coefs = dec.ca;
            newdata = coefs*pc_APP;
            thrpc = pc_APP;
            thrpc(:,npc_APP+1:p) = 0;
            dec.ca = newdata * thrpc';
        end
end

% wavelet reconstruction of columns of x_den.
x_den = mdwtrec(dec);

% Final PCA.
[pc_FIN,newdata,var_FIN] = wpca(x_den,true);

% components selection.
switch npc_FIN
    case {'kais'} , npc_FIN = sum(var_FIN>mean(var_FIN));
    case {'heur'} , npc_FIN = sum(var_FIN>0.05*sum(var_FIN));
end

% perform PCA.
if npc_FIN<p 
    % the last columns of are replaced by zeros.
    pc_FIN(:,npc_FIN+1:p) = 0; 
    
    % reconstruction of new coefficients.
    thrcenterd = newdata*pc_FIN';
    
    % center the columns.
    avg = mean(x_den);
    x_den = thrcenterd + avg(ones(size(x_den,1),1),:);

end

% Store DEN_Params
DEN_Params = struct('thrVAL',thrVAL,'thrMETH',tptr,'thrTYPE',sORh);

% Store PCA_Params
PCA_Params.FIN = {pc_FIN,var_FIN,npc_FIN};
PCA_Params.APP{3} = npc_APP;
varargout = {x_den,[npc_APP,npc_FIN],nestcov,dec,PCA_Params,DEN_Params};

%-------------------------------------------------------------------------
function [pc,variances,nestcov] = D1_robust_COVAR(coefs)

% Estimated robust covariance.
% Replace: [pc,newdata,variances] = pca(centerd);
alpha     = 0.75; ntrial = 50;
idxREP    = ones(size(coefs,1),1);
avg       = mean(coefs);
centerd   = (coefs - avg(idxREP,:));
nestcov   = wfastmcd(centerd,alpha,ntrial);
[pc,dia]  = eig(nestcov);
variances = diag(dia);
variances(variances<0) = 0;
%-------------------------------------------------------------------------
