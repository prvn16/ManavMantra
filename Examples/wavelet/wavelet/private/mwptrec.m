function X = mwptrec(dec,varargin)
%MWPTREC Multisignal wavelet packet 1-D reconstruction.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Feb-2011
%   Last Revision: 28-Aug-2011.
%   Copyright 1995-2015 The MathWorks, Inc.

% Check arguments.
narginchk(1,4)
nargoutchk(0,1);

% Initialization.
dirDec = dec.dirDec;
% cA = dec.ca;
% cD = dec.cd;
% sx = mswdecfunc('decSizes',dec);
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

% if isequal(dirDec,'c')
%     sx = fliplr(sx);    
%     cA = cA';
%     for j = 1:levMAX , cD{j} = cD{j}'; end
% end
% if flag_idxSIG
%     sx(:,1) = length(idxSIG);
%     cA = cA(idxSIG,:);
%     for j = 1:levMAX , cD{j} = cD{j}(idxSIG,:); end    
% end

levMIN = 1;
% switch type
%     case 'ca'
%         levMIN = lev+1;
%     case 'd'  , 
%         cA(:) = 0; 
%         for k = 1:levMAX
%             if k~=lev , cD{k}(:) = 0; end; 
%         end
%     case 'a'
%         for k = 1:lev , cD{k}(:) = 0; end
% end
% 
% x = cA;
% Iterated reconstruction.

nbC = length(dec.cfs);
p = 2;
while nbC>1
    for j = 1:nbC/2
        a = dec.cfs{j};
        d = dec.cfs{j+1};
        s = dec.sx(p+1,:);
        a = upsconv(a,LoR,s,perFLAG,shift) + upsconv(d,HiR,s,perFLAG,shift);
        dec.cfs{j+1} = a;
        dec.cfs(j) = [];
    end
    p = p+1;
    nbC = length(dec.cfs);
end
X = dec.cfs{1};
if isequal(dirDec,'c') , X = X'; end



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
