function [dec,coefs,sx] = mdwtdec(dirDec,x,lev,varargin)
%MDWTDEC Multisignal 1-D wavelet decomposition.
%   For a matrix X, DEC = MDWTDEC(DIRDEC,X,LEV,WNAME) returns
%   the wavelet decomposition at level LEV of each row 
%   (if DIRDEC = 'r') or of each column (if DIRDEC = 'c')
%   of X, using the wavelet which name is WNAME.
%
%   The output DEC is a structure with the following fields:
%     'dirDec'     : 'r' (row) or 'c' (column).
%     'level'      : level of DWT decomposition.
%     'wname'      : wavelet name.
%     'dwtFilters' : structure with four fields LoD, HiD, 
%                    LoR and HiR.
%     'dwtEXTM'    : DWT extension mode (see DWTMODE).
%     'dwtShift'   : DWT shift parameter (0 or 1).
%     'dataSize'   : size of X.
%     'ca'         : approximation coefficients at level LEV.  
%     'cd'         : cell array of detail coefficients,  
%                    from level 1 to level LEV.
%      Coefficients cA and cD{k} (for k = 1 to LEV) are
%      matrices and are stored rowwise (resp. columnwise)
%      if DIRDEC = 'r' (resp.  DIRDEC = 'c').
%
%   Instead of the wavelet name, you may use four filters:
%   DEC = MDWTDEC(DIR,X,LEV,LoD,HiD,LoR,HiR)
%
%   MDWTDEC(...,'mode',EXTMODE) computes the wavelet
%   decomposition with the EXTMODE extension mode that  
%   you specify (see DWTMODE for the valid extension modes).
%
%   See also MDWTREC.

%   Note:
%   -----
%   In addition, [DEC,C,L] = MDWTDEC(...) returns the matrix
%   C and the vector L. If dirDec = 'r' (resp. 'c'), each row
%   (resp. column) of C contains the concatenation of the 
%   decomposition coefficients of the corresponding row
%   (resp. column) of X. 
%   L is a row (resp. column) vector which contains the lengths  
%   (see WAVEDEC for more information on (C,L) structure).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Nov-2002.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2015 The MathWorks, Inc.

% Check arguments.
narginchk(4,11);
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
    case 'c'  , x = x';       dirCAT = 1;
    otherwise , dirDec = 'r'; dirCAT = 2;
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
cD = cell(1,lev);
for j = lev+1:-1:2
    [x,d] = dwtLOC(x,LoD,HiD,dwtEXTM,perFLAG,first);
    cD{lev+2-j} = d;
    sx(j,:) = size(d);
end
sx(1,:) = size(d);
cA = {x};
if isequal(dirDec,'c')
    sx = fliplr(sx);
    cA{1} = cA{1}';
    for j = 1:lev , cD{j} = cD{j}'; end
end

Filters = struct('LoD',LoD,'HiD',HiD,'LoR',LoR,'HiR',HiR);
dec = struct(...
    'dirDec',dirDec,'level',lev,          ...
    'wname',wname,'dwtFilters',Filters,   ...
    'dwtEXTM',dwtEXTM,'dwtShift',shift,   ...
    'dataSize',dataSize,'ca',cA,'cd',{cD} ...
    );

if nargout>1
    coefs = cat(dirCAT,cA{:},cat(dirCAT,cD{end:-1:1}));
    if nargout>2
        if isequal(dirDec,'c') , sx = sx(:,1); else sx = sx(:,2)'; end        
    end
end

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
