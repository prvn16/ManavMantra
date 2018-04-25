function [THR_VAL,L2_Perf,N0_Perf] = mswcmptp(varargin)
%MSWCMPTP Multisignal 1-D compression thresholds and performances.
%   [THR_VAL,L2_Perf,N0_Perf] = MSWCMPTP(DEC,METH) or 
%   [THR_VAL,L2_Perf,N0_Perf] = MSWCMPTP(DEC,METH,PARAM) 
%   computes the vectors THR_VAL, L2_Perf and N0_Perf
%   obtained after a compression using the METH method  
%   and, if required, the PARAM parameter (see MSWCMP for 
%   more information on METH and PARAM).
%   For the ith signal:
%     - THR_VAL(i) is the threshold applied to the wavelet 
%       coefficients. For a level dependent method, THR_VAL(i,j)
%       is the threshold applied to the detail coefficients 
%       at level j,
%     - L2_Perf(i) is the percentage of energy (L2-norm) 
%       preserved after compression,
%     - N0_Perf(i) is the percentage of zeros obtained 
%       after compression.
%
%   Three more optional inputs may be used:
%       [...] = MSWCMPTP(...,S_OR_H) or
%       [...] = MSWCMPTP(...,S_OR_H,KEEPAPP) or
%       [...] = MSWCMPTP(...,S_OR_H,KEEPAPP,IDXSIG)
%       - S_or_H  ('s' or 'h') stands for soft or hard 
%         thresholding (see WTHRESH for more details).
%       - KEEPAPP (true or false). When KEEPAPP is equal to
%         true, the approximation coefficients are kept.
%       - IDXSIG is a vector which contains the indices of
%         the initial signals, or the character vector 'all'.
%   The defaults are respectively: 'h' , false and 'all'.
%
%   See also mdwtdec, mdwtrec, ddencmp, wdencmp

%   Note:
%   -----
%   The decomposition structure input argument DEC may be 
%   replaced by three arguments: COEFS, LONGS ,DIRDEC.
%       [...] = MSWCMPTP(COEFS,LONGS,DIRDEC,...)
%   where COEFS is a matrix, LONGS is a vector (see WDEC2CL for 
%   more details on COEFS and LONGS) and DIRDEC ('r' or 'c') 
%   gives the direction of the decomposition. See WAVEDEC for
%   more information on (C,L) storage structure.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Apr-2005.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

% Input Default Values.
dim = 2; keepAPP = false; S_or_H = 'h'; idxSIG = 'All';

% Check arguments.
nbIN = length(varargin);
if isstruct(varargin{1})
    dec = varargin{1};
    if isequal(dec.dirDec,'c') , dim = 1; end
    [cfs,longs] = wdec2cl(dec,'all');
    next = 2;
else
    [cfs,longs,dim] = deal(varargin{1:3});
    next = 4;    
end
if dim==1 , dim = 2; cfs = cfs'; longs = longs'; end

meth = varargin{next};
switch meth
    case {'rem_n0','bal_sn','sqrtbal_sn'} ,  next = next+1;
    case {'L2_perf','N0_perf','glb_thr'}
        input_VAL = varargin{next+1};   next = next+2;
    case {'scarcehi','scarceme','scarcelo','scarce'}
        input_VAL = varargin{next+1};   next = next+2;
    otherwise
        error(message('Wavelet:FunctionArgVal:Unknown_Meth'))
end
if nbIN>=next
    if isequal(lower(varargin{next}(1)),'s'); S_or_H = 's'; end
    next = next+1;
    if nbIN>=next
        keepAPP = isequal(varargin{next},true); next = next+1;
        if nbIN>=next , idxSIG = varargin{next}; end 
    end 
end
if ~ischar(idxSIG) , cfs = cfs(idxSIG,:); end

nbSIG = size(cfs,1);
THR_VAL = zeros(nbSIG,1);
L2_Perf = zeros(nbSIG,1);
N0_Perf = zeros(nbSIG,1);

switch meth
    case {'rem_n0','bal_sn','sqrtbal_sn','L2_perf','N0_perf','glb_thr'}
        [THR_Values,L2_Scores,N0_Scores] = ...
            mswcmpscr(cfs,longs,dim,S_or_H,keepAPP);
        idxMIN = zeros(nbSIG,1);
        switch meth
            case {'rem_n0',}
                absCFS = abs(cfs);
                THR_VAL = median(absCFS,2);
                idx = (THR_VAL == 0);
                if any(idx)
                    maxTHR = max(absCFS(idx),2);
                    THR_VAL(idx) = maxTHR;
                end
                for k = 1:nbSIG
                    [~,idxMIN(k)] = ...
                        min(abs(THR_Values(k,:)-THR_VAL(k)),[],dim);
                end
                
            case 'bal_sn'       % Balance Sparsity & Norm.
                [~,idxMIN] = min(abs(L2_Scores-N0_Scores),[],dim);
                
            case 'sqrtbal_sn'   % SQRT Balance Sparsity & Norm.
                [~,idxMIN] = min(abs(L2_Scores-N0_Scores),[],dim);
                for k = 1:nbSIG
                    THR_VAL(k,1) = THR_Values(k,idxMIN(k))^0.5;
                    [~,idxMIN(k)] = ...
                        min(abs(THR_VAL(k)-THR_Values(k,:)),[],dim);
                end

            case 'L2_perf'      % L2 Performance.
                [~,idxMIN] = min(abs(L2_Scores-input_VAL),[],dim);

            case 'N0_perf'      % N0 Performance.
                [~,idxMIN] = min(abs(N0_Scores-input_VAL),[],dim);
 
            case 'glb_thr'      % THR Performance.
                [~,idxMIN] = min(abs(THR_Values-input_VAL),[],dim);
        end
        for k = 1:nbSIG
            L2_Perf(k) = L2_Scores(k,idxMIN(k));
            N0_Perf(k) = N0_Scores(k,idxMIN(k));
            THR_VAL(k,1) = THR_Values(k,idxMIN(k));
        end
        
    case {'scarce','scarcehi','scarceme','scarcelo'}
        nbcfsTOT = size(cfs,2);
        level = length(longs)-2;
        cfs = abs(cfs);
        Energy = sum(cfs.*cfs,2);
        THR_VAL = zeros(nbSIG,level); 
        nbAppCfs = longs(1);
        M = nbAppCfs;
        switch meth
            case 'scarce'   ,
            case 'scarcehi' ,
            case 'scarceme' , M = 1.5*M;
            case 'scarcelo' , M = 2*M;
        end
        if ~isequal(meth,'scarce') , M = max(M,1); end
        nkeep    = zeros(1,level);        
        first    = cumsum(longs)+1;
        first    = first(end-2:-1:1);
        nbcfsLEV = longs(end-1:-1:2);
        last     = first+nbcfsLEV-1;
        for j=1:level
            n = round(M/((level+2-j)^input_VAL));
            n = min([n,nbcfsLEV(j)]);
            cd = cfs(:,first(j):last(j));
            if n<nbcfsLEV(j)
                cd = sort(cd,2,'descend');
                THR_VAL(:,j) = cd(:,n+1)+eps;
                cd(:,n+1:end) = 0;
                cfs(:,first(j):last(j)) = cd;
            end
            nkeep(j) = n;
        end
        nbKeepTOT = sum(nkeep);
        if keepAPP , nbKeepTOT = nbKeepTOT + nbAppCfs; end
        Energy_NEW = sum(cfs.*cfs,2);
        L2_Perf = 100*((Energy_NEW./Energy).^1);
        N0_Perf(:) = 100*((nbcfsTOT-nbKeepTOT)/nbcfsTOT);
end
