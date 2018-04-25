function x = mdwtrec(dec,varargin)
%MDWTREC Multisignal 1-D wavelet reconstruction.
%   X = MDWTREC(DEC) returns the original matrix of signals,
%   starting from the wavelet decomposition structure DEC 
%   (see MDWTDEC). 
%
%   X = MDWTREC(DEC,IDXSIG) reconstructs the signals which  
%   indices are given by the vector IDXSIG.
%
%   Y = MDWTREC(DEC,TYPE,LEV) extracts or reconstructs the 
%   detail or approximation coefficients (depending on 
%   TYPE value) at level LEV. 
%       - For TYPE equal to 'cd' or 'ca', the coefficients  
%         of level LEV are extracted. 
%       - For TYPE equal to 'd' or 'a', the coefficients  
%         of level LEV are reconstructed. 
%   The maximum value for LEV is LEVDEC = DEC.level.
%
%   When TYPE is equal to 'a' or 'ca', LEV must be an 
%   integer such that 0 <= LEV <= LEVDEC.
%   When TYPE is equal to 'd' or 'cd', LEV must be such 
%   that 0 < LEV <= LEVDEC.
%
%   A  = MDWTREC(DEC,'a') is equivalent to  
%   A  = MDWTREC(DEC,'a',LEVDEC)
%
%   D  = MDWTREC(DEC,'d') returns a matrix which contains
%   the sum of all details, so X = A + D.
%
%   CA = MDWTREC(DEC,'ca') is equivalent to 
%   CA = MDWTREC(DEC,'ca',LEVDEC)
%
%   CD = MDWTREC(DEC,'cd',MODE) returns a matrix which  
%   contains all the detail coefficients.
%   CFS = MDWTREC(DEC,'cfs',MODE) returns a matrix which 
%   contains all the coefficients.
%
%   The concatenation is made rowwise (resp. columnwise) if
%   DEC.dirDec is equal to 'r' (resp. 'c').
%   For MODE = 'descend' (resp 'ascend') the coefficients are  
%   "concatened" from level LEVDEC to level 1 (resp. from level 
%   1 to level LEVDEC). When the input MODE is omitted, the  
%   default is MODE = 'descend'.
%
%   Y = MDWTREC(...,IDXSIG) extracts or reconstructs  
%   the detail or the approximation coefficients for the 
%   signals which indices are given by the vector IDXSIG.
%
%   See also MDWTDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Nov-2002.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2015 The MathWorks, Inc.

% Check arguments.
narginchk(1,4);
nargoutchk(0,1);

% Initialization.
dirDec = dec.dirDec;
cA = dec.ca;
cD = dec.cd;
sx = mswdecfunc('decSizes',dec);
levMAX = dec.level;
flag_idxSIG = false;
flag_ORDER  = false;
if nargin==1
    type = 'a'; lev  = 0;
elseif nargin==2 && isnumeric(varargin{1})
    flag_idxSIG = true;
    idxSIG = varargin{1}; 
    type = 'a'; 
    lev  = 0;
else
    type = varargin{1};
    if nargin==2
        if isequal(type,'cd') || isequal(type,'cfs') || isequal(type,'d')
            lev = 'all';
        else
            lev = levMAX;
        end
    else
        [err,lev,flag_ORDER] = ok_INPUT(type,varargin{2},levMAX);
        if err
            error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
        end
        if nargin>3
            flag_idxSIG = true;
            idxSIG = varargin{3};
        end
    end
end

if isequal(type,'cd') || isequal(type,'cfs')
    if ~isnumeric(lev)
        if ~flag_ORDER
            idxCAT = (levMAX:-1:1);
        else
            idxCAT = (1:levMAX);
        end
        switch dirDec
            case 'c' , x = cat(1,cD{idxCAT});
            case 'r' , x = cat(2,cD{idxCAT});
        end
        if isequal(type,'cfs')
            switch dirDec
                case 'c'
                    if ~flag_ORDER , x = [cA ; x]; else x = [x ; cA]; end
                case 'r'
                    if ~flag_ORDER , x = [cA , x]; else x = [x , cA]; end
            end
        end
    else
        x = cD{lev};
    end
    if flag_idxSIG
        switch dirDec
            case 'c' , x = x(:,idxSIG);
            case 'r' , x = x(idxSIG,:);
        end
    end
    return
end

if isequal(type,'d') && isequal(lev,'all')
    x = 0;
    if flag_idxSIG
        for k = 1:levMAX
            x = x +  mdwtrec(dec,'d',k,idxSIG);
        end
    else
        for k = 1:levMAX
            x = x +  mdwtrec(dec,'d',k);
        end        
    end
    return;
end

LoR = dec.dwtFilters.LoR;
HiR = dec.dwtFilters.HiR;
dwtEXTM = dec.dwtEXTM;
perFLAG = isequal(dwtEXTM,'per');
shift   = dec.dwtShift;

if isequal(dirDec,'c')
    sx = fliplr(sx);    
    cA = cA';
    for j = 1:levMAX , cD{j} = cD{j}'; end
end
if flag_idxSIG
    sx(:,1) = length(idxSIG);
    cA = cA(idxSIG,:);
    for j = 1:levMAX , cD{j} = cD{j}(idxSIG,:); end    
end

levMIN = 1;
switch type
    case 'ca'
        levMIN = lev+1;
    case 'd'  , 
        cA(:) = 0; 
        for k = 1:levMAX
            if k~=lev , cD{k}(:) = 0; end; 
        end
    case 'a'
        for k = 1:lev , cD{k}(:) = 0; end
end

x = cA;
% Iterated reconstruction.
for j = levMAX:-1:levMIN
    p = levMAX+2-j;
    d = cD{j};
    s = sx(p+1,:);
    x = upsconv(x,LoR,s,perFLAG,shift) + upsconv(d,HiR,s,perFLAG,shift);
end
if isequal(dirDec,'c') , x = x'; end



%-------------------------------------------------------------------------%
function [err,lev,flag_ORDER] = ok_INPUT(type,ARG,levMAX)

err = false;
flag_ORDER = false;
switch type
    case {'a','d','ca'}
        lev = ARG;
        err = okLEVEL(type,lev,levMAX);
    case 'cd'
        lev = ARG;
        if isnumeric(lev)
            err = okLEVEL(type,lev,levMAX);
        else
            lev = 'all';
            flag_ORDER = isequal(lower(ARG),'ascend');
        end
    case 'cfs'
        lev = 'all';
        flag_ORDER = isequal(lower(ARG),'ascend');
end
%-------------------------------------------------------------------------%
function err = okLEVEL(type,lev,levMAX)

err = ~isequal(size(lev),[1,1]) || lev~=fix(lev);
if ~err
    err = (lev>levMAX) || (lev<0);
    if ~err && (isequal(type,'d') || isequal(type,'cd'))
        err = (lev==0);
    end
end
%-------------------------------------------------------------------------%
function y = upsconv(x,f,s,perFLAG,shift)
%UPSCONV Upsample and convolution.

% Special case.
if isempty(x) , y = 0; return; end

[sx1,sx2] = size(x);
sx2 = 2*sx2;
lenKept = s(2);
if ~perFLAG
    y = zeros(sx1,sx2-1);
    y(:,1:2:end) = x;
    y = conv2(y,f,'full'); 
    sy = size(y,2);
    if lenKept>sy , lenKept = sy; end
    d = (sy-lenKept)/2;
    switch shift
        case 0 , first = 1+floor(d); last = sy-ceil(d);
        case 1 , first = 1+ceil(d);  last = sy-floor(d);
    end
    y = y(:,first:last);

else
    lf = length(f);
    y = zeros(sx1,sx2);
    y(:,1:2:end) = x;
    y = wextend('addcol','per',y,lf/2);
    y = conv2(y,f,'full');         
    y = y(:,lf:lf+sx2-1);
    if shift~=0 , y = y(:,[2:sx2,1]); end
    y = y(:,1:lenKept);
end
%-------------------------------------------------------------------------%
