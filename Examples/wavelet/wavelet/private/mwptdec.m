function [dec,coefs] = mwptdec(dirDec,x,lev,varargin)
%MWPTDEC Multisignal wavelet packet 1-D decomposition.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Feb-2011
%   Last Revision: 28-Aug-2011.
%   Copyright 1995-2015 The MathWorks, Inc.

% Check arguments.
narginchk(4,11)
nargoutchk(0,3);
if errargt(mfilename,lev,'int')
    error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
if ischar(varargin{1})
    wname = varargin{1};
    [LoD,HiD,LoR,HiR] = wfilters(wname);
    varargin(1) = [];
else
    wname = '';
    [LoD,HiD,LoR,HiR] = deal(varargin{1:4});
    varargin(1:4) = [];
end

% Type of decomposition.
if ~isempty(dirDec)
    dirDec = dirDec(1);
    dirDec = lower(dirDec);
else
    dirDec = 'r';
end
dataSize = size(x);
switch dirDec
    case 'c'  , x = x';       dirCAT = 2;
    otherwise , dirDec = 'r'; dirCAT = 1;
end
x = double(x);

% Default: Shift and Extension.
dwtATTR = dwtmode('get');
shift   = dwtATTR.shift1D;
dwtEXTM = dwtATTR.extMode;

% Check arguments for Extension and Shift.
nbin = length(varargin);
for k = 1:2:nbin-1
    switch varargin{k}
      case 'mode'  , dwtEXTM = varargin{k+1};
      case 'shift' , shift   = mod(varargin{k+1},2);
    end
end
perFLAG = isequal(dwtEXTM,'per');

% Initialization.
sx = zeros(lev+2,2);
sx(end,:) = size(x);
first = 2 - rem(shift,2);

% Full decomposition
cfs    = {x};
idxLST = 1;
for j = 1:((2^lev)-1)
    [a,d] = dwtLOC(cfs{idxLST},LoD,HiD,dwtEXTM,perFLAG,first);
    cfs = [cfs,a,d];
    cfs(idxLST) = [];
    k = log2(j+1);
    if isequal(k,fix(k)) , sx(lev+2-k,:) = size(a); end
end
sx(1,:) = sx(2,:);

Filters = struct('LoD',LoD,'HiD',HiD,'LoR',LoR,'HiR',HiR);
dec = struct(...
    'dirDec',dirDec,'level',lev,          ...
    'wname',wname,'dwtFilters',Filters,   ...
    'dwtEXTM',dwtEXTM,'dwtShift',shift,   ...
    'dataSize',dataSize,'sx',sx);

dec.cfs = cfs;
coefs = cat(dirCAT,dec.cfs{:});

%------------------------------------------------------------------------
function [a,d] = dwtLOC(x,LoD,HiD,dwtEXTM,perFLAG,first)

% Compute sizes.
lf = length(LoD);
lx = size(x,2);

% Extend, Decompose &  Extract coefficients.
dCol = lf-1;
if ~perFLAG
    lenEXT = lf-1; lenKEPT = lx+lf-1;      
else
    lenEXT = lf/2; lenKEPT = 2*ceil(lx/2);
end
idxCOL = (first + dCol : 2 : lenKEPT + dCol);
y = wextend('addcol',dwtEXTM,x,lenEXT);
a = conv2(y,LoD,'full'); 
a = a(:,idxCOL);
d = conv2(y,HiD,'full');
d = d(:,idxCOL);
%--------------------------------------------------------------------
