function varargout = wdecenergy(varargin)
%WDECENERGY Multisignal 1-D decomposition energy distribution.
%   [E,PEC,PECFS] = WDECENERGY(DEC) computes the vector E which 
%   contains the energy (L2-Norm) of each decomposed signal, the
%   matrix PEC which contains the percentage of energy for each
%   wavelet component (approximation and details) of each signal,
%   and the matrix PECFS which contains the percentage of energy
%   for each coefficient. So:
%       - E(i) is the energy (L2-norm) of the ith signal.
%       - PEC(i,1) is the percentage of energy for the 
%         approximation of level DEC.level (MAXLEV) of the
%         ith signal.
%       - PEC(i,j), j = 2,...,MAXLEV+1 is the percentage of 
%         energy for the detail of level (MAXLEV+1-j) of the 
%         ith signal.
%       - PECFS(i,j), is the percentage of energy for jth
%         coefficients of the ith signal.
%
%   [E,PEC,PECFS,IDXSORT,LONGS] = WDECENERGY(DEC,'sort') returns
%   PECFS sorted (by row) in ascending order and an index 
%   vector IDXSORT. 
%   Replacing 'sort' by 'ascend' you obtain the same result.
%   Replacing 'sort' by 'descend' you obtain PECFS sorted in 
%   descending order. 
%   LONGS is a vector which contains the lengths of each family 
%   of coefficients. 
%
%   [...] = WDECENERGY(DEC,OPTSORT,IDXSIG) returns the values  
%   for the signals which indices are given by the IDXSIG vector.
%   The valid values for OPTSORT are: 
%        'none' , 'sort', 'ascend' , 'descend'.
%
%   See also MDWTDEC, MDWTREC.

%   Nota:
%   -----
%   The decomposition structure input argument DEC may be 
%   replaced by three arguments: COEFS, LONGS ,DIRDEC.
%       [...] = WDECENERGY(COEFS,LONGS,DIRDEC,...)
%   where COEFS is a matrix, LONGS is a vector (see WDEC2CL for 
%   more details on COEFS and LONGS) and DIRDEC ('r' or 'c') 
%   gives the direction of decomposition. See WAVEDEC for more
%   information on (C,L) storage structure.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-May-2005.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.

% Input Default Values.
dim = 2;

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
    dim   = varargin{3};
    next = 4;    
end
if dim==1 ,cfs = cfs'; longs = longs'; end
level = length(longs)-2;

if nbIN>=next
    option = varargin{next};
    switch option
        case 'none'
        case {'cfs','ca','cd','sort','ascend','descend'}
        otherwise
            error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
    end
    next = next+1;
else
    option = 'none';
end
flagSIG = nbIN>=next;
if flagSIG
    idxSIG = varargin{next};
    nbSIG  = length(idxSIG);
else
    nbSIG  = size(cfs,1);
    idxSIG = (1:nbSIG);
end

cfs = cfs(idxSIG,:);
nb_CFS_TOT = size(cfs,2);
absCFS   = abs(cfs);
cfs_POW2 = absCFS.^2;
Energy  = sum(cfs_POW2,2);
percentENER = 0*ones(size(cfs_POW2));
notZER = (Energy>0);
percentENER(notZER,:) = ...
    100*cfs_POW2(notZER,:)./Energy(notZER,ones(1,nb_CFS_TOT));
tab_ENER = zeros(nbSIG,level+1);
first = 1;
for k=1:level+1
    nbCFS = longs(k);
    last  = first+nbCFS-1;
    tab_ENER(:,k) = sum(percentENER(:,first:last),2);
    first = last + 1;
end
if ~isequal(option,'sort') && ...
        ~isequal(option,'ascend')   && ~isequal(option,'descend')  
    varargout = {Energy,tab_ENER,percentENER,longs};
else
    if isequal(option,'sort') , option = 'ascend'; end
    [percentENER,idx_SORTED] = sort(percentENER,2,option);
    varargout = {Energy,tab_ENER,percentENER,idx_SORTED,longs};
end
