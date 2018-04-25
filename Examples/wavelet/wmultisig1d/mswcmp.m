function varargout = mswcmp(option,varargin)
%MSWCMP Multisignal 1-D compression using wavelets.
%   MSWCMP computes thresholds and, depending on the selected
%   option, performs compression of 1-D signals using wavelets.
%   OUTPUTS = MSWCMP(OPTION,INPUTS) is the general syntax and 
%   valid values for OPTION are: 
%           'cmp' , 'cmpsig' , 'cmpdec' , 'thr'
%
%   [XC,DECCMP,THRESH] = MSWCMP('cmp',DEC,METH) or 
%   [XC,DECCMP,THRESH] = MSWCMP('cmp',DEC,METH,PARAM) returns
%   a compressed version XC of the original multisignal   
%   matrix X, which wavelet decomposition structure is DEC.
%   XC is obtained by thresholding the wavelet coefficients.
%   DECCMP is the wavelet decomposition associated to XC
%   (see MDWTDEC), and THRESH is the vector of threshold
%   values.
%
%   METH is the name of the compression method and PARAM 
%   is the associated parameter if required (see below).
%   You may use 'cmpsig', 'cmpdec' or 'thr' OPTION in order 
%   to select output arguments: 
%       [XC,THRESH] = MSWCMP('cmpsig', ...) or
%       [DECCMP,THRESH] = MSWCMP('cmpdec',...)
%       THRESH = MSWCMP('thr',...) returns the computed
%       thresholds, but the compression is not performed.
%   
%   The decomposition structure input argument DEC may be 
%   replaced by four arguments: DIRDEC, X, WNAME and LEV.
%       [...] = MSWCMP(OPTION,DIRDEC,X,WNAME,LEV,METH) or
%       [...] = MSWCMP(OPTION,DIRDEC,X,WNAME,LEV,METH,PARAM)
%   Before to perform a compression or to compute thresholds,
%   the multisignal matrix X is decomposed at level LEV
%   using the wavelet WNAME, in the direction DIRDEC.
%
%   Three more optional inputs may be used:
%       [...] = MSWCMP(...,S_OR_H) or
%       [...] = MSWCMP(...,S_OR_H,KEEPAPP) or
%       [...] = MSWCMP(...,S_OR_H,KEEPAPP,IDXSIG)
%       - S_or_H  ('s' or 'h') stands for soft or hard 
%         thresholding (see MSWTHRESH for more details).
%       - KEEPAPP (true or false). When KEEPAPP is equal to
%         true, the approximation coefficients are kept.
%       - IDXSIG is a vector which contains the indices of
%         the initial signals, or the string 'all'.
%   The defaults are respectively: 'h' , true and 'all'.
%
%   Valid compression methods METH and associated parameters 
%   PARAM are:
%       'rem_n0'     (Remove near 0)        
%       'bal_sn'     (Balance sparsity-norm)
%       'sqrtbal_sn' (Balance sparsity-norm (sqrt))
%   
%       'scarce'     (Scarce)        ,  PARAM (any number)
%       'scarcehi'   (Scarce high)   ,  2.5 <= PARAM <= 10
%       'scarceme'   (Scarce medium) ,  1.5 <= PARAM <= 2.5
%       'scarcelo'   (Scarce low)    ,    1 <= PARAM <= 2
%       PARAM is a sparsity parameter, and it should be such that:
%       1 <= PARAM <= 10. For Scarce method no control is done.
%    
%       'L2_perf'    (Energy ratio)
%       'N0_perf'    (Zero coefficients ratio)
%       Parameter PARAM is a real number which represents 
%       the required performance (0 <= PARAM <= 100).
%    
%       'glb_thr'    (Global threshold)
%       Parameter PARAM is a real positive number.
%   
%       'man_thr'     (Manual method)
%       Parameter PARAM is an NbSIG-by-NbLEV matrix or
%       NbSIG-by-(NbLEV+1) matrix such that:
%        - PARAM(i,j) is the threshold for the detail coefficients
%          of level j for the ith signal (1 <= j <= NbLEV).
%        - PARAM(i,NbLEV+1) is the threshold for the approximation 
%          coefficients for the ith signal (if KEEPAPP is 0).
%       Where NbSIG is the number of signals and NbLEV the number
%       of levels of decomposition.
%
%   See also mdwtdec, mdwtrec, mswthresh, wthresh

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Apr-2005.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

% Check arguments.
option = lower(option);
switch option
    case 'thr',     nbOUT = 1;
    case 'cmp' ,    nbOUT = 3;
    case 'cmpsig' , nbOUT = 2;
    case 'cmpdec' , nbOUT = 2;
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgFirst'));
end
nbVarIN = length(varargin);
if nargin<3
    error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
end
decFLAG = isstruct(varargin{1});
if ~decFLAG
    [dirDec,x,wname,level] = deal(varargin{1:4});
    dec = mdwtdec(dirDec,x,level,wname);
    next = 5;
else
    dec = varargin{1};
    level = dec.level;
    next  = 2;
end
meth = varargin{next};
if errargt(mfilename,meth,'str')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
next = next+1;
errARG = 0;
switch meth
    case {'rem_n0','bal_sn','sqrtbal_sn'}
        
    case {'scarcehi','scarceme','scarcelo','scarce'}
        if nbVarIN>=next
            alpha = varargin{next};     next = next+1;
            switch meth
                case 'scarcehi' , errVAL = alpha<2.5 || alpha>10;
                case 'scarceme' , errVAL = alpha<1.5 || alpha>2.5;
                case 'scarcelo' , errVAL = alpha<1   || alpha>2;
                case 'scarce'   , errVAL = false;
            end
            if errVAL
                error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
            end
        else
            errARG = 1;
        end

    case 'glb_thr'
        if nbVarIN>=next , thrGLB = varargin{next};    next = next+1;
        else errARG = 1; end

    case {'L2_perf','N0_perf'};
        if nbVarIN>=next , perPERFO = varargin{next};  next = next+1;
        else errARG = 1; end

    case 'man_thr'
        if nbVarIN>=next , threshold = varargin{next}; next = next+1;
        else errARG = 1; end
        
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end
if errARG
    error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
end

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

% Get coefficients.
dirDec = dec.dirDec;
if isequal(dirDec,'c') , dec = mswdecfunc('transpose',dec); end
sx = mswdecfunc('decSizes',dec);
cA = dec.ca;
cD = dec.cd;
dataSize = dec.dataSize;
nbSIG = dataSize(1);
if idxFLAG
    sx(:,1) = length(idxSIG);
    cA = cA(idxSIG,:);
    for j = 1:level , cD{j} = cD{j}(idxSIG,:); end
end

% BEGIN: Compute thresholds.
%===========================
if ~isequal(meth,'man_thr')    
    threshold = zeros(nbSIG,level);
    switch meth
        case 'rem_n0'
            % rescaled threshold.
            if keepAPP      % only detail coeffs can be thresholded.
                c = wdec2cl(dec,'cd');
            else            % all coeffs can be thresholded.
                c = wdec2cl(dec);
            end
            valTHR = median(abs(c),2);
            idx = (valTHR == 0);
            if any(idx)
                maxTHR = max(abs(c),2);
                valTHR(idx) = maxTHR(idx);
            end
            threshold = valTHR(:,ones(1,level));

        case {'bal_sn','sqrtbal_sn','L2_perf','N0_perf'}
            % Set possible thresholds.
            if keepAPP      % only detail coeffs can be thresholded.
                app = dec.ca;
                dimapp = size(app,2);
                nl2app = sum(app.^2,2);
                n0app  = sum(app==0,2);
                c = wdec2cl(dec,'cd');
            else            % all coeffs can be thresholded.
                c = wdec2cl(dec);
                dimapp = 0; nl2app = zeros(nbSIG,1); n0app = zeros(nbSIG,1);
            end

            % Compute compression scores.
            thresh  = sort(abs(c),2);
            Nb_Thr  = size(thresh,2);
            rl2SCR  = 100*ones(nbSIG,Nb_Thr);
            n0SCR   = 100*ones(nbSIG,Nb_Thr+1);
            imin    = ones(nbSIG,1);
            idxNZ   = find(nl2app>eps | thresh(:,end)>eps);
            if ~isempty(idxNZ)
                thrTMP = thresh(idxNZ,:).^2;
                divTMP = (sum(thrTMP,2)+ nl2app(idxNZ));
                rl2TMP = cumsum(thrTMP,2);
                for k = 1:Nb_Thr
                    rl2TMP(:,k) = rl2TMP(:,k)./divTMP;
                end
                rl2SCR(idxNZ,:) = 1-rl2TMP;
                % rl2SCR(idxNZ,end) = (1 - rl2SCR(idxNZ,end));
                
                n0det =  sum((c(idxNZ,:)==0),2);
                for k = 1:length(idxNZ)
                    j = idxNZ(k);
                    nbd = n0det(k);
                    n0SCR(j,:) = (n0app(j) + nbd + ...
                        [zeros(1,nbd+1) , 1:(Nb_Thr-nbd)]);
                end
                n0SCR = n0SCR/(Nb_Thr+dimapp);
                n0SCR = 100 * n0SCR;
                % rl2SCR(idxNZ,end) = (1 - rl2SCR(idxNZ,end));
                thresh = [zeros(nbSIG,1)    thresh];
                rl2SCR = 100*[ones(nbSIG,1) rl2SCR];
                switch meth
                    case {'bal_sn','sqrtbal_sn'} , toMINI = rl2SCR - n0SCR;
                    case 'L2_perf' , toMINI = rl2SCR - perPERFO;
                    case 'N0_perf' , toMINI = n0SCR - perPERFO;
                end
                [~,imin] = min(abs(toMINI),[],2);
            end
            idx_valTHR = (1:nbSIG)'+(imin-1)*nbSIG;
            valTHR = thresh(idx_valTHR);
            if isequal(meth,'sqrtbal_sn')
                maxTHR = thresh(:,end);
                valTHR = min(sqrt(valTHR),maxTHR);
            end
            threshold = valTHR(:,ones(1,level));

        case {'scarce','scarcehi','scarceme','scarcelo'}
            M = sx(1,2);
            switch meth
                case 'scarce'   , 
                case 'scarcehi' ,
                case 'scarceme' , M = 1.5*M;
                case 'scarcelo' , M = 2*M; 
            end
            if ~isequal(meth,'scarce') , M = max(M,1); end
            nkeep = zeros(1,level);

            % Wavelet coefficients selection.
            for j=1:level
                % number of coefs to be kept.
                idxLEV = level+2-j;
                n = M/(idxLEV^alpha);
                nbcfsLEV = sx(idxLEV,2);
                n = min([round(n),nbcfsLEV]);
                % threshold.
                if n<nbcfsLEV
                    cd_J = wdec2cl(dec,'cd',j);
                    cd_J = sort(abs(cd_J),2);
                    threshold(:,j) = cd_J(:,end-n);
                else
                    threshold(:,j) = 0;
                end
                nkeep(j) = n;
            end

        case 'glb_thr'
            threshold = thrGLB*ones(nbSIG,level);
    end
end
if idxFLAG && ~returALL
    threshold = threshold(idxSIG,:);
end
if isequal(option,'thr')
    varargout{1} = threshold; 
    return;
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

% Get original signal and/or original decomposition
% to compute performances.
%-----------------------------------------------------------------
% Computation of "compressed" decomposition and compressed signal.
if nargout>nbOUT
    if idxFLAG && ~returALL
        cfs_ORI = wdec2cl(dec,'all',idxSIG);
    else
        cfs_ORI = wdec2cl(dec,'all');
    end
end
if returALL
    dec.ca(idxSIG,:) = cA;
    for j = 1:level , dec.cd{j}(idxSIG,:) = cD{j}; end
else
    dec.ca = cA;
    dec.cd = cD;
    if idxFLAG , dec.dataSize(1) = length(idxSIG); end
end
if ~isequal(option,'cmpdec') , xc = mdwtrec(dec); end

if nargout>nbOUT
    % Compute DEC L^2 recovery score.
    cfs_CMP = wdec2cl(dec);
    n2_CMP = sum(cfs_CMP.*cfs_CMP,2);
    n2_ORI = sum(cfs_ORI.*cfs_ORI,2);
    energyDEC_PERF = 100*ones(size(n2_ORI));
    idxNZ  = n2_ORI>eps;
    energyDEC_PERF(idxNZ) = 100*n2_CMP(idxNZ)./n2_ORI(idxNZ);

    % Compute ZERO score.
    nbCFS = size(cfs_ORI,2);
    nbZER = nbCFS-sum(abs(cfs_CMP)>0,2);
    nb0_PERF = 100*nbZER/nbCFS;
end

if isequal(dirDec,'c')
    dec = mswdecfunc('transpose',dec);
    if ~isequal(option,'cmpdec') , xc = xc'; end
    if nargout>nbOUT
        energyDEC_PERF = energyDEC_PERF';
        nb0_PERF       = nb0_PERF';
    end
end
switch lower(option)
    case 'cmp' ,    varargout = {xc,dec,threshold};
    case 'cmpsig' , varargout = {xc,threshold};
    case 'cmpdec' , varargout = {dec,threshold};
end
if nargout>nbOUT
    varargout = [varargout , energyDEC_PERF , nb0_PERF];
end
%--------------------------------------------------------------------------
