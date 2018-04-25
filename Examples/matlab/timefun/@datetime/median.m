function m = median(a,dim,missing)
%MEDIAN Median of datetimes.
%   M = MEDIAN(T), when T is a vector of datetimes. returns the sample median of
%   T as a scalar datetime M. When T is a matrix, MEDIAN(T) is a row vector
%   containing the median value of each column.  For N-D arrays, MEDIAN(T) is the
%   median value of the elements along the first non-singleton dimension of T.
%   
%   M = MEDIAN(T,DIM) takes the median along the dimension DIM of T.
%
%   M = MEDIAN(..., MISSING) specifies how NaT (Not-A-Time) values are treated.
%
%      'includenat' - the median of a vector containing any NaT values is also
%                     NaT. This is the default. 'includenan' is equivalent to
%                     'includenat'.
%      'omitnat'    - elements of T containing NaT values are ignored. If all
%                     elements are NaT, the result is NaT. 'omitnan' is equivalent
%                     to 'omitnat'.
%
%   Example:
%
%   % Create a vector of datetimes and find the median value.
%   dts = [datetime('1995-10-01 02:45 PM'),...
%          datetime('08/23/10 16:35', 'InputFormat', 'MM/dd/yy HH:mm'),...
%          datetime('August 23, 2010 4:35 PM'),...
%          datetime('-44-03-15 00:00'),...
%          datetime('21-Oct-2015 12:01:00')]
%
%   median(dts)
%
%   See also MEAN, MODE, STD.

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.isScalarInt

needDim = true;
omitNan = false;

if nargin > 1
    % Recognize DIM if present as the 2nd input, and recognize a trailing string
    % option if present.
    if isScalarInt(dim,1)
        needDim = false;
        if nargin == 2 % median(a,dim)
            % OK
        else % median(a,dim,missing)
            omitNan = validateMissingOption(missing);
        end
    elseif isCharString(dim) && (nargin == 2) % median(a,missing)
        omitNan = validateMissingOption(dim); % missing is in dim's position
    else
        error(message('MATLAB:datetime:InvalidDim'));
    end
end

aData = a.data;
szIn = size(aData);
if needDim
    dim = find(szIn~=1,1);
    if isempty(dim), dim = 1; end
end


% Set output size to 1 along the working dimension.
szOut = szIn;
if dim <= length(szIn)
    szOut(dim) = 1;
end

if isempty(aData)
    if needDim && isequal(aData,[])
        % The output size for [] is a special case when DIM is not given.
        mData = NaN;
        szOut = [1 1];
    else
        mData = NaN(szOut);
    end
elseif dim <= ndims(aData)
    aData = sort(aData,dim,'ComparisonMethod','real');
    mData = NaN(szOut); % the low order part will be created if/when needed
    if omitNan
        % NaN sorts to the end, ignore them for 'omitnan' by treating each column's
        % "length" as its number of non-NaN elements. Except: if every element in the
        % column is NaN, set its "length" to 1, so that the last (n-th) element is NaN
        % when we go to check it.
        n = size(aData,dim) - matlab.internal.math.countnan(aData,dim);
        n(n == 0) = 1;
    else % 'includenan'
        % NaN sorts to the end, so if there are any NaNs in a column, the last element
        % of the sorted column will certainly be NaN. For 'includenan', get the column
        % length so that we can check that last (n-th) element.
        n = repmat(size(aData,dim),szOut);
    end
    half = floor(n/2);
    if dim == 2 && ismatrix(aData) % special case for rowwise on a matrix (no trailing dims)
        [nrow,~] = size(aData);
        for i = 1:nrow
            if ~isnan(aData(i,n(i))) % if last element is NaN, leave median as NaN
                mData(i) = aData(i,half(i)+1);
                if 2*half(i) == n(i)
                    mData(i) = datetimeMidpoint(aData(i,half(i)),mData(i));
                end
            end
        end
    else % dim == 1: column-wise or any N-D case
        if dim ~= 1
            % Permute the working dim to the front, and work column-wise.
            perm = [dim 1:(dim-1) (dim+1):ndims(aData)];
            aData = permute(aData,perm);
            mData = permute(mData,perm);
        end
        [~,ncol] = size(aData);
        for j = 1:ncol
            if ~isnan(aData(n(j),j)) % if last element is NaN, leave median as NaN
                mData(j) = aData(half(j)+1,j);
                if 2*half(j) == n(j)
                    mData(j) = datetimeMidpoint(aData(half(j),j),mData(j));
                end
            end
        end
        if dim ~= 1
            % Permute the working dim back to where it was.
            mData = ipermute(mData,perm);
        end
    end
else % dim > ndims(aData)
    mData = aData;
end
m = a;
m.data = reshape(mData,szOut);


function cdata = datetimeMidpoint(adata,bdata)
import matlab.internal.datetime.datetimeAdd
import matlab.internal.datetime.datetimeSubtract
% Find the midpoint between two datetimes.
cdata = datetimeAdd(adata,datetimeSubtract(bdata,adata,true)/2);
k = (sign(adata) ~= sign(bdata)) | isinf(adata) | isinf(bdata);
cdata(k) = datetimeAdd(adata(k),bdata(k))/2;

