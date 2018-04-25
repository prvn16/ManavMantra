function y = mean(x,dim,flag,flag2)
%MEAN   Average or mean value.
%   S = MEAN(X) is the mean value of the elements in X if X is a vector. 
%   For matrices, S is a row vector containing the mean value of each 
%   column. 
%   For N-D arrays, S is the mean value of the elements along the first 
%   array dimension whose size does not equal 1.
%
%   MEAN(X,DIM) takes the mean along the dimension DIM of X.
%
%   S = MEAN(...,TYPE) specifies the type in which the mean is performed, 
%   and the type of S. Available options are:
%
%   'double'    -  S has class double for any input X
%   'native'    -  S has the same class as X
%   'default'   -  If X is floating point, that is double or single,
%                  S has the same class as X. If X is not floating point, 
%                  S has class double.
%
%   S = MEAN(...,NANFLAG) specifies how NaN (Not-A-Number) values are 
%   treated. The default is 'includenan':
%
%   'includenan' - the mean of a vector containing NaN values is also NaN.
%   'omitnan'    - the mean of a vector containing NaN values is the mean 
%                  of all its non-NaN elements. If all elements are NaN,
%                  the result is NaN.
%
%   Example:
%       X = [1 2 3; 3 3 6; 4 6 8; 4 7 7]
%       mean(X,1)
%       mean(X,2)
%
%   Class support for input X:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32,
%               int32, uint64, int64
%
%   See also MEDIAN, STD, MIN, MAX, VAR, COV, MODE.

%   Copyright 1984-2017 The MathWorks, Inc.

isDimSet = nargin > 1 && ~ischar(dim) && ~(isstring(dim) && isscalar(dim));
isFlag2Set = nargin >= 4;

if nargin == 1 || (nargin == 2 && isDimSet)
    
    flag = 'default';
    omitnan = false;
    
else % nargin >= 3 || (nargin == 2 && ~isDimSet)
        
    if nargin == 2
        flag = dim;
    elseif nargin == 3
        if ~isDimSet
            flag2 = dim;
            isFlag2Set = true;
        end
    elseif nargin == 4 && ~isDimSet
        error(message('MATLAB:mean:nonNumericSecondInput'));
    end
    
    if ~isFlag2Set
        flag2 = '';
    end
    
    [flag, omitnan] = parseInputs(flag, flag2, isFlag2Set);
        
end

if ~isDimSet
    % preserve backward compatibility with 0x0 empty
    if isequal(x,[])
        y = sum(x,flag)./0;
        return
    end
    dim = find(size(x)~=1,1);
    if isempty(dim)
        dim = 1;
    end
end

if ~isobject(x) && isinteger(x)
    % accumulation flag may still be partial
    isnative = strncmpi(flag, 'native', max(1, strlength(flag)));
    if intmin(class(x)) == 0  % unsigned integers
        y = sum(x,dim,flag);
        if (isnative && all(y(:) < intmax(class(x)))) || ...
                (~isnative && all(y(:) <= flintmax))
            % no precision lost, can use the sum result
            y = y./size(x,dim);
        else  % throw away and recompute
            y = intmean(x,dim,isnative);
        end
    else  % signed integers
        ypos = sum(max(x,0),dim,flag);
        yneg = sum(min(x,0),dim,flag);
        if (isnative && all(ypos(:) < intmax(class(x))) && ...
                all(yneg(:) > intmin(class(x)))) || ...
                (~isnative && all(ypos(:) <= flintmax) && ...
                all(yneg(:) >= -flintmax))
            % no precision lost, can use the sum result
            y = (ypos+yneg)./size(x,dim);
        else  % throw away and recompute
            y = intmean(x,dim,isnative);
        end
    end
else
    if omitnan     
        % Compute sum and number of NaNs
        m = sum(x, dim, flag, 'omitnan');
        nr_nonnan = size(x, dim) - matlab.internal.math.countnan(x, dim);
        % Divide by the number of non-NaNs.
        y = m ./ nr_nonnan;
    else
        y = sum(x, dim, flag) ./ size(x,dim);
    end
end
    
end


function y = intmean(x, dim, isnative)
% compute the mean of integer vector

dim = min(dim, ndims(x)+1);
shift = [dim:ndims(x),1:dim-1];
x = permute(x,shift);

xclass = class(x);
if ~isnative
    outclass = 'double';
else
    outclass = xclass;
end

if intmin(xclass) == 0
    accumclass = 'uint64';
else
    accumclass = 'int64';
end
xsiz = size(x);
xlen = cast(xsiz(1),accumclass);

y = zeros([1 xsiz(2:end)],outclass);
ncolumns = prod(xsiz(2:end));
int64input = isa(x,'uint64') || isa(x,'int64');

for iter = 1:ncolumns
    xcol = cast(x(:,iter),accumclass);
    if int64input
        xr = rem(xcol,xlen);
        ya = sum((xcol-xr)./xlen,1,'native');
        xcol = xr;
    else
        ya = zeros(accumclass);
    end
    xcs = cumsum(xcol);
    ind = find(xcs == intmax(accumclass) | (xcs == intmin(accumclass) & (xcs < 0)) , 1);
    
    while (~isempty(ind))
        remain = rem(xcs(ind-1),xlen);
        ya = ya + (xcs(ind-1) - remain)./xlen;
        xcol = [remain; xcol(ind:end)];
        xcs = cumsum(xcol);
        ind = find(xcs == intmax(accumclass) | (xcs == intmin(accumclass) & (xcs < 0)), 1);
    end
    
    if ~isnative
        remain = rem(xcs(end),xlen);
        ya = ya + (xcs(end) - remain)./xlen;
        % The latter two conversions to double never lose precision as
        % values are less than FLINTMAX. The first conversion may lose
        % precision.
        y(iter) = double(ya) + double(remain)./double(xlen);
    else
        y(iter) = cast(ya + xcs(end) ./ xlen, outclass);
    end
end
if ~isscalar(y)
    y = ipermute(y,shift);
end

end


function [flag, omitnan] = parseInputs(flag, flag2, isFlag2Set)
% Process flags, return boolean omitnan and string flag

    if isInvalidText(flag)
        error(message('MATLAB:mean:invalidFlags'));
    end
    if isstring(flag)
        flag = char(flag);
    end
    s = strncmpi(flag, {'omitnan', 'includenan'}, max(length(flag), 1));
    
    if ~isFlag2Set
        omitnan = s(1);
        if any(s)
           flag = 'default';
        end
    else
        if isInvalidText(flag2)
            error(message('MATLAB:mean:invalidFlags'));
        end
        if isstring(flag2)
            flag2 = char(flag2);
        end
        s2 = strncmpi(flag2, {'omitnan', 'includenan'}, max(length(flag2), 1));
        
        % Make sure one flag is from the set {'omitnan', 'includenan'},
        % while the other is from {'default', 'double', 'native'}.        
        if ~xor( any(s), any(s2) )
            error(message('MATLAB:mean:invalidFlags'));
        end
        
        if any(s) % flag contains 'includenan' or 'omitnan'
            omitnan = s(1);
            flag = flag2;
        else
            omitnan = s2(1);
        end
    end
end

function tf = isInvalidText(str)
tf = (ischar(str) && ~isrow(str)) || ...
     (isstring(str) && ~(isscalar(str) && (strlength(str) > 0)));
end