function y = mean(x, dim)
%MEAN   Average or mean value of fixed-point array
%   Y = MEAN(X) computes the mean value of the fixed-point array X along
%   its first non-singleton dimension.
%
%   Y = MEAN(X, DIM) computes the mean value of the fixed-point array X 
%   along dimension DIM. DIM must be a positive, real-valued integer with a 
%   power-of-two slope and a bias of 0.
%
%   The fixed-point output array Y has the same numerictype properties 
%   as the fixed-point input array X.
%
%   When X is an empty fixed-point array (value = []), the value of the 
%   output array is zero.
%
%   The general equation for computing the MEAN of an array X, across 
%   dimension DIM is SUM(X,DIM)/SIZE(X,DIM). Because SIZE(X,DIM) is 
%   always a positive integer, the algorithm for computing MEAN casts
%   SIZE(X,DIM) to an unsigned 32-bit FI object with a fraction length 
%   of zero (we denote this FI object as 'SizeX'). The MEAN of X is then 
%   computed according to the following equation, where Tx represents the 
%   numerictype properties of the fixed-point input array X:
%   Y = Tx.divide(SUM(X,DIM), SizeX)
%
%   The fixed-point output array Y is always associated with the 
%   global fimath.
%
%   Refer to the MATLAB MEAN reference page for more information.
%
%   The following example computes the mean of a 2-dimensional array.
%   The example first computes the MEAN along the first dimension 
%   of the input (rows), and then across the second dimension of 
%   the input (columns).
%
%   x = fi([0 1 2; 3 4 5], 1, 32);
%   % x is a signed FI object with 32-bit word length, and 28-bit (best
%   % precision) fraction length.
%   mx1 = mean(x,1)
%   % mx1 is a FI object with value [1.5 2.5 3.5], and the same numerictype 
%   % properties as x.
%   mx2 = mean(x,2)
%   % mx2 is a FI object with value [1; 4], and the same numerictype 
%   % properties as x.
%
%   See also EMBEDDED.FI/MEDIAN, MEAN

%   Copyright 2007-2012 The MathWorks, Inc.
%     

narginchk(1,2);
validateInputsToStatFunctions(x,'mean');
if (nargin == 2)
    if ~isnumeric(dim)

        error(message('fixed:fi:InvalidInputNotNumeric'));
    elseif (~isscalar(dim)||(dim <= 0)||~isreal(dim)||~isequal(floor(dim), dim))

        error(message('fixed:fi:DimensionMustBePositiveInteger'));
    end
else
    
    dim = 0;
end
dim = double(dim);

[y, ty, istrivial, dim] = ...
    fi_statop_trivial_cases_handler(x, dim, 'mean');
if ~istrivial
    
    sumx = sum(x,dim);
    tsize = numerictype(false, 32, 0);
    sizexdim = embedded.fi(size(x,dim), tsize); 
    y = ty.divide(sumx, sizexdim);
end
y.fimathislocal = false;

% LocalWords:  Tx
