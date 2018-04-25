function Y = sum(this,dim,doublenativestr)
%SUM    Sum of array elements
%   B = SUM(A) returns the sum along different dimensions of the fi array A.
%   If A is a vector, SUM(A) returns the sum of the elements.
%   If A is a matrix, sum(A) treats the columns of A as vectors, returning 
%   a row vector of the sums of each column.
%   If A is a multidimensional array, SUM(A) treats the values along the 
%   first non-singleton dimension as vectors, returning an array of row vectors.
%   B = SUM(A, DIM) sums along the dimension DIM of A.
%   The fimath object is used in the calculation of the sum. 
%   If SumMode is FullPrecision, KeepLSB, or KeepMSB, then the number of 
%   integer bits of growth for SUM(A) is ceil(log2(length(A))).
%   SUM does not support fi objects of data type Boolean.
%
%   See also EMBEDDED.FIMATH/ADD, EMBEDDED.NUMERICTYPE/DIVIDE, FI,
%            FIMATH, EMBEDDED.FIMATH/MPY, NUMERICTYPE, EMBEDDED.FIMATH/SUB


%   Thomas A. Bryan
%   Copyright 2003-2017 The MathWorks, Inc.
%     

if nargin > 1
    dim = convertStringsToChars(dim);
end

if nargin > 2
    doublenativestr = convertStringsToChars(doublenativestr);
end

if nargin<2
  dim = [];
end

if nargin<3
  doublenativestr = 'native';
end

if nargin==2 && ischar(dim)
    % sum(a,'double')
    % sum(a,'native')
    doublenativestr = dim;
    dim = [];
end

dim = double(dim); % use real-world value (e.g., allow dim to be FI type)

if ~isempty(dim) 
  if ~(length(dim)==1 && floor(dim(1))==dim(1) && dim(1)>0 && dim(1)<2^31)
    error(message('fixed:fi:invalidDimInput'));
  end
end

switch lower(doublenativestr)
  case 'native'
    % Y = sum(A)     Work on first non-singleton dimension
    % Y = sum(A,dim) Work on dimension dim
    % 
    % To avoid unnecessary copies, only shift and unshift if not working
    % on the leading dimension.
    % If dim is greater than ndims(this) then sum is a no-op and Y = this
    if dim > ndims(this)
        Y = this;
    elseif (isempty(dim) && size(this,1)>1) || (~isempty(dim) && dim(1)==1)
        % Working on the leading dimension.
        Y = leadingdimension_sum(this);
    else
        % Not working on the leading dimension
        [A,perm,nshifts] = shiftdata(this,dim);
        Y = leadingdimension_sum(A);
        Y = unshiftdata(Y,perm,nshifts);
    end
  case 'double'
      Y = sum(double(this),dim);
  otherwise 
    error(message('MATLAB:sum:unknownFlag'));
end

