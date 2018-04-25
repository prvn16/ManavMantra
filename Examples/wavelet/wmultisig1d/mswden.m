function varargout = mswden(option,varargin)
%MSWDEN Multisignal 1-D denoising using wavelets.
%   MSWDEN computes thresholds and, depending on the selected
%   option, performs denoising of 1-D signals using wavelets.
%   OUTPUTS = MSWDEN(OPTION,INPUTS) is the general syntax and 
%   valid values for OPTION are: 
%           'den' , 'densig' , 'dendec' , 'thr'
%
%   [XD,DECDEN,THRESH] = MSWDEN('den',DEC,METH) or 
%   [XD,DECDEN,THRESH] = MSWDEN('den',DEC,METH,PARAM)  returns
%   a denoised version XD of the original multisignal  
%   matrix X, which wavelet decomposition structure is DEC.
%   XD is obtained by thresholding the wavelet coefficients.
%   DECDEN is the wavelet decomposition associated to XD 
%   (see MDWTDEC), and THRESH  is the vector of  threshold 
%   values.
%
%   METH is the name of the denoising method and PARAM 
%   is the associated parameter if required (see below). 
%   You may use 'densig' or 'dendec' OPTION in order to select
%   output arguments: 
%       [XD,THRESH] = MSWDEN('densig', ...) or
%       [DECDEN,THRESH] = MSWDEN('dendec',...)
%
%   In the same way, you may use 'thr' OPTION in order to 
%   retrieve only the threshold values: 
%   THRESH = MSWDEN('thr',DEC,METH) or
%   THRESH = MSWDEN('thr',DEC,METH,PARAM) returns the computed
%   thresholds, but the denoising is not performed.
%   
%   The decomposition structure input argument DEC may be 
%   replaced by four arguments: DIRDEC, X, WNAME and LEV.
%       [...] = MSWDEN(OPTION,DIRDEC,X,WNAME,LEV,METH,PARAM).
%   Before to perform a denoising or to compute thresholds,
%   the multisignal matrix X is decomposed at level LEV
%   using the wavelet WNAME, in the direction DIRDEC.
%
%   Three more optional inputs may be used:
%       [...] = MSWDEN(...,S_OR_H) or
%       [...] = MSWDEN(...,S_OR_H,KEEPAPP) or
%       [...] = MSWDEN(...,S_OR_H,KEEPAPP,IDXSIG)
%       - S_or_H  ('s' or 'h') stands for soft or hard 
%         thresholding (see MSWTHRESH for more details).
%       - KEEPAPP (true or false). When KEEPAPP is equal to
%         true, the approximation coefficients are kept.
%       - IDXSIG is a vector which contains the indices of
%         the initial signals, or the character vector 'all'.
%   The defaults are respectively: 'h' , false and 'all'.
%
%   Valid denoising methods METH and associated parameters 
%   PARAM are:
%       'rigrsure' principle of Stein's Unbiased Risk.
%       'heursure' heuristic variant of the first option.
%       'sqtwolog' universal threshold sqrt(2*log(.)).
%       'minimaxi' minimax thresholding (see THSELECT).
%       PARAM defines multiplicative threshold rescaling:
%          'one' no rescaling.
%          'sln' rescaling using a single estimation of level
%                noise based on first level coefficients.
%          'mln' rescaling using a level dependent 
%                estimation of level noise.
%
%       'penal'     (Penal)       
%       'penalhi'   (Penal high)   ,  2.5 <= PARAM <= 10
%       'penalme'   (Penal medium) ,  1.5 <= PARAM <= 2.5
%       'penallo'   (Penal low)    ,    1 <= PARAM <= 2
%       PARAM is a sparsity parameter, and it should be such that:
%       1 <= PARAM <= 10. For Penal method no control is done.
%
%       'man_thr'   (Manual method)
%       Parameter PARAM is an NbSIG-by-NbLEV matrix or
%       NbSIG-by-(NbLEV+1) matrix such that:
%         - PARAM(i,j) is the threshold for the detail coefficients
%           of level j for the ith signal (1 <= j <= NbLEV).
%         - PARAM(i,NbLEV+1) is the threshold for the approximation 
%           coefficients for the ith signal (if KEEPAPP is 0).
%
%   See also mdwtdec, mdwtrec, mswthresh, wthresh

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Apr-2005.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

% Check arguments.
option = lower(option);
switch option
    case {'thr','den','densig','dendec'}
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgFirst'));
end
nbVarIN = length(varargin);
if nargin<3
    error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
end
decFLAG = isstruct(varargin{1});
if ~decFLAG
    last = 6;
    [dirDec,x,wname,level,meth,param] = deal(varargin{1:last});
    dec = mdwtdec(dirDec,x,level,wname);
else
    last = 3;
    [dec,meth,param] = deal(varargin{1:last});
    level = dec.level;
end
if errargt(mfilename,meth,'str')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
next = last + 1;

% Defaults.
s_OR_h = 'h';
keepAPP = 1;
idxFLAG  = false;
returALL = false;
if ~isequal(option,'thr')
    if nbVarIN>=next
        s_OR_h = lower(varargin{next}(1));
        if ~isequal(s_OR_h,'h') && ~isequal(s_OR_h,'s')
            error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
        end
        next = next+1;
    end
    if nbVarIN>=next
        keepAPP = varargin{next};
        if ~isequal(keepAPP,0) && ~isequal(keepAPP,1)
            error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
        end
        next = next+1;
    end    
end

if nbVarIN>=next
    idxSIG = varargin{next}; 
    idxFLAG = true;
    if (nbVarIN>next) && isequal(lower(varargin{next+1}),'all')
        returALL = true;
    end
end

switch meth
    case {'sqtwolog','minimaxi','rigrsure','heursure'}
        scal = param;
    case {'penal','penalhi','penalme','penallo'}
        alpha = param;  scal = 'sln';
        switch meth
            case 'penalhi' , errVAL = alpha<2.5 || alpha>10;
            case 'penalme' , errVAL = alpha<1.5 || alpha>2.5;
            case 'penallo' , errVAL = alpha<1   || alpha>2;
            case 'penal'   , errVAL = false;
        end
        if errVAL
            error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
        end
        
    case 'man_thr'
        scal = 'none';
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end
switch scal
    case {'one','sln','mln','none'}
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end

dirDec = dec.dirDec;
if isequal(dirDec,'c') , dec = mswdecfunc('transpose',dec); end
dirCAT = 2;
sx = mswdecfunc('decSizes',dec);
cA = dec.ca;
cD = dec.cd;
dataSize = dec.dataSize;
if idxFLAG
    dataSize(1) = length(idxSIG);
    cA = cA(idxSIG,:);
    for j = 1:level , cD{j} = cD{j}(idxSIG,:); end
end
nbSIG = dataSize(1);

% BEGIN: Compute thresholds.
%===========================
if ~isequal(meth,'man_thr')
    % Compute level noise estimation.
    sigma = ones(nbSIG,level);
    switch scal
        case 'one'
        case 'sln'
            sigmaTMP = median(abs(cD{1}),dirCAT)/0.6745;
            sigma = sigmaTMP(:,ones(1,level));
        case 'mln'
            for k = 1:level
                sigma(:,k) = median(abs(cD{k}),dirCAT)/0.6745;
            end
    end

    % Compute thresholds.
    threshold = zeros(nbSIG,level);
    switch meth
        case {'sqtwolog','minimaxi'}
            TMP    = sx(:,2);
            nbcfs  = TMP(end-1:-1:1);
            nbcfs_TOT = sum(nbcfs);
            switch meth
                case 'sqtwolog' ,
                    thrINI = sqrt(2*log(nbcfs_TOT));
                case 'minimaxi'
                    if nbcfs_TOT <= 32
                        thrINI = 0;
                    else
                        thrINI = 0.3936 + 0.1829*(log(nbcfs_TOT)/log(2));
                    end
            end
            threshold = thrINI*sigma;

        case {'rigrsure','heursure'}
            sqEPS = sqrt(eps);
            for k = 1:level
                matCFS = cD{k};
                nbCFS_LEV = size(matCFS,2);
                idxRows = ~(sigma(:,k) < sqEPS*max(abs(matCFS),[],dirCAT));
                matSIGMA = sigma(idxRows,k);
                matCFS = matCFS(idxRows,:)./matSIGMA(:,ones(1,nbCFS_LEV));
                nbROWS = size(matCFS,1);
                thrLOC = zeros(nbROWS,1);
                continu = true;
                if isequal(meth,'heursure')
                    hTHR = sqrt(2*log(nbCFS_LEV));
                    crit = (log(nbCFS_LEV)/log(2))^(1.5)/sqrt(nbCFS_LEV);
                    eta = (sum(matCFS.*matCFS,2)-nbCFS_LEV)/nbCFS_LEV;
                    idxR1 = eta < crit;
                    thrLOC(idxR1) = hTHR;
                    idxR2 = ~idxR1;
                    continu = any(idxR2);
                end
                if continu
                    repIDX = ones(1,nbROWS);
                    Vn_1 = nbCFS_LEV - (2*(1:nbCFS_LEV));
                    Vn_1 = Vn_1(repIDX,:);
                    Vn_2 = (nbCFS_LEV-1:-1:0);
                    Vn_2 = Vn_2(repIDX,:);
                    sx2 = sort(abs(matCFS),2).^2;
                    risks = (Vn_1 + cumsum(sx2,2) + Vn_2.*sx2)/nbCFS_LEV;
                    [~,best] = min(risks,[],2);
                    rigTHR = sqrt(diag(sx2(1:nbROWS,best)));
                    if isequal(meth,'heursure')
                        thrLOC(idxR2) = min(rigTHR(idxR2),hTHR);
                    else
                        thrLOC = rigTHR;
                    end
                end
                threshold(idxRows,k) = thrLOC.*sigma(idxRows,k);
            end

        case {'penal','penalhi','penalme','penallo'}
            if ~isequal(alpha,0)
                if idxFLAG
                    matCFS = mdwtrec(dec,'cd','all',idxSIG);
                else
                    matCFS = mdwtrec(dec,'cd');
                end
                sigmaTMP = sigma(:,1);
                [nbSIG,nbcfs] = size(matCFS);
                sigmaTMP = sigmaTMP(:,ones(1,nbcfs)).^2;
                thresh = sort(abs(matCFS),2,'descend');
                rl2scr = cumsum(thresh.^2,2);
                xpen   = 1:nbcfs;
                xpen   = xpen(ones(nbSIG,1),:);
                pen    = 2*xpen.*(alpha + log(nbcfs./xpen));
                pen    = pen.*sigmaTMP;
                [~,indmin] = min(pen-rl2scr,[],2);
                
                thrLOC = thresh(indmin);
                for k = 1:length(indmin)
                    thrLOC(k) = thresh(k,indmin(k));
                end
                
                threshold = thrLOC(:,ones(1,level));
            else
                threshold = zeros(nbSIG,level);
            end
    end
else
    threshold = param;
end

if isequal(option,'thr')
    if idxFLAG && returALL
        thrTMP = zeros(dec.dataSize(1),dec.level);
        thrTMP(idxSIG,:) = threshold;
        threshold = thrTMP;
    end
    varargout{1} = threshold; return; 
end
% END: Compute thresholds.
%==========================

% Wavelet coefficients thresholding.
for k = 1:level
    cD{k} = mswthresh(cD{k},s_OR_h,threshold(:,k));
end
if ~keepAPP
    cA = mswthresh(cA,s_OR_h,threshold(:,end));
end

% Wavelet reconstruction of xd.
if returALL
    dec.ca(idxSIG,:) = cA;
    for j = 1:level , dec.cd{j}(idxSIG,:) = cD{j}; end
    thrTMP = zeros(dec.dataSize(1),dec.level);
    thrTMP(idxSIG,:) = threshold;
    threshold = thrTMP;
else
    dec.ca = cA;
    dec.cd = cD;
    if idxFLAG , dec.dataSize(1) = length(idxSIG); end
end

if ~isequal(option,'dendec') , xd = mdwtrec(dec); end
if isequal(dirDec,'c')
    dec = mswdecfunc('transpose',dec);
    if ~isequal(option,'dendec') , xd = xd'; end
end
switch lower(option)
    case 'den' ,    varargout = {xd,dec,threshold};
    case 'densig' , varargout = {xd,threshold};
    case 'dendec' , varargout = {dec,threshold};
end
