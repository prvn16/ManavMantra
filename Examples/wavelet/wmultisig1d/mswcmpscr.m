function [thresh,L2SCR,n0SCR,idx_SORT] = mswcmpscr(varargin)
%MSWCMPSCR Multisignal 1-D wavelet compression scores.
%   [THR,L2SCR,N0SCR,IDXSORT] = MSWCMPSCR(DEC) computes four  
%   matrices: thresholds THR, compression scores L2SCR and 
%   N0SCR and indices IDXSORT.
%   The decomposition DEC corresponds to a  matrix of wavelet   
%   coefficients CFS obtained by concatenation of detail
%   and (optionally) approximation coefficients:
%       CFS = [cd{DEC.LEV} , ... , cd{1}] or
%       CFS = [ca , cd{DEC.LEV} , ... , cd{1}]
%   The concatenation is made rowwise (resp. columnwise) if
%   DEC.dirDec is equal to 'r' (resp. 'c').
%
%   Let NbSIG be the number of  original signals and NbCFS
%   the number of coefficients for each signal (all or only 
%   the detail coefficients), then CFS is an NbSIG-by-NbCFS 
%   matrix.
%	So:
%     - THR, L2SCR, N0SCR are NbSIG-by-(NbCFS+1) matrices.
%     - IDXSORT is an NbSIG-by-NbCFS matrix.
%   And:
%     - THR(:,2:end) is equal to CFS sorted by row in ascending
%       order with respect to the absolute value. For each row,  
%       IDXSORT contains the order of coefficients.
%       And THR(:,1) = 0.
%     For the ith signal:
%     - L2SCR(i,j) is the percentage of preserved energy
%       (L2-norm), corresponding to a threshold equal to 
%       CFS(i,j-1) (2 <= j <= NbCFS). And L2SCR(:,1) = 100.
%     - N0SCR(i,j) is the percentage of zeros corresponding 
%       to a threshold equal to CFS(i,j-1) (2 <= j <= NbCFS). 
%       And N0SCR(:,1) = 0.
%
%   Three more optional inputs may be used:
%     [...] = MSWCMPSCR(...,S_or_H,KEEPAPP,IDXSIG)
%       - S_or_H  ('s' or 'h') stands for soft or hard 
%         thresholding (see MSWTHRESH for more details).
%       - KEEPAPP (true or false). When KEEPAPP is equal to
%         true, the approximation coefficients are kept.
%       - IDXSIG is a vector which contains the indices of
%         the initial signals, or the string 'all'.
%   The defaults are respectively: 'h', false and 'all'.
%
%   See also mdwtdec, mdwtrec, ddencmp, wdencmp

%   Note:
%   -----
%   The decomposition structure input argument DEC may be
%   replaced by three arguments: COEFS, LONGS ,DIRDEC.
%       [...] = MSWCMPSCR(COEFS,LONGS,DIRDEC,...)
%   where COEFS is a matrix, LONGS is a vector (see WDEC2CL for
%   more details on COEFS and LONGS) and DIRDEC ('r' or 'c') 
%   gives the direction of the decomposition. See WAVEDEC for
%   more information on (C,L) storage structure.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-Apr-2005.
%   Last Revision: 16-Mar-2008.
%   Copyright 1995-2008 The MathWorks, Inc.

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
    cfs   = varargin{1};
    longs = varargin{2};
    if isequal(varargin{3},'c') , dim = 1; end
    next = 4;    
end
if dim==1 , dim = 2; cfs = cfs'; longs = longs'; end

if nbIN>=next
    if isequal(lower(varargin{next}(1)),'s'); S_or_H = 's'; end
    next = next+1;
    if nbIN>=next
        keepAPP = isequal(varargin{next},true);
        next = next+1;
        if nbIN>=next , idxSIG = varargin{next}; end 
    end 
end

[nb_SIG,nb_CFS_TOT] = size(cfs);
if ~ischar(idxSIG)
    cfs = cfs(idxSIG,:);
    nb_SIG = size(cfs,1);
end
n2_ORI = sum(cfs.*cfs,dim);
if keepAPP
    nb_CFS_InAPP = longs(1); 
    app = cfs(:,1:nb_CFS_InAPP);
    n2_app = sum(app.*app,dim);
    n0app  = sum(app==0,2);
else
    nb_CFS_InAPP = 0;
    n2_app = zeros(nb_SIG,1);
    n0app  = zeros(nb_SIG,1);
end
nb_CFS = nb_CFS_TOT - nb_CFS_InAPP;
first  = nb_CFS_InAPP+1;
[thresh,idx_SORT] = sort(abs(cfs(:,first:end)),dim);
onesIDX = ones(1,nb_CFS);
val_ENER = (thresh.^2);
switch S_or_H
    case 'h',
        percentENER = 100*val_ENER./n2_ORI(:,onesIDX);
        L2SCR = 100 - [zeros(nb_SIG,1) , cumsum(percentENER,2)];

    case 's'
        cum_ENER = fliplr(cumsum(fliplr(val_ENER),2));
        cum_THR  = fliplr(cumsum(fliplr(thresh),2));
        tmp_ENER = val_ENER.*repmat((nb_CFS+1-(1:nb_CFS)),nb_SIG,1);
        soft_ENER = (cum_ENER + tmp_ENER - 2*thresh.*cum_THR);
        if keepAPP , soft_ENER = soft_ENER + n2_app(:,onesIDX); end
        L2SCR = 100*[ones(nb_SIG,1) , soft_ENER./n2_ORI(:,onesIDX)];
end
L2SCR = max(L2SCR,0);

thresh  = [zeros(nb_SIG,1) , thresh];
n0SCR   = zeros(nb_SIG,nb_CFS+1);
idxNZ = find(n2_app>eps | thresh(:,end)>eps);

if ~isempty(idxNZ)
    n0det =  sum((thresh(idxNZ,:)==0),2);
    for k = 1:length(idxNZ)
        j = idxNZ(k);
        nbd = n0det(k);
        plus = n0app(j) + nbd;
        n0SCR(j,1:nbd) = 0; 
        n0SCR(j,nbd+1:end) = 1:(nb_CFS+1-nbd);
        n0SCR(j,:) = n0SCR(j,:) + plus; 
    end
    n0SCR = 100*(n0SCR-1)/nb_CFS_TOT;
end

