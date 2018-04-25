%PROD Product of elements.
%   S = PROD(X) is the product of the elements of the vector X. If X is a
%   matrix, S is a row vector with the product over each column. For 
%   N-D arrays, PROD(X) operates on the first non-singleton dimension.
%
%   PROD(X,DIM) works along the dimension DIM. 
%
%   S = PROD(...,TYPE) specifies the type in which the product is 
%   performed, and the type of S. Available options are:
%
%   'double'    -  S has class double for any input X
%   'native'    -  S has the same class as X
%   'default'   -  If X is floating point, that is double or single,
%                  S has the same class as X. If X is not floating point, 
%                  S has class double.
%
%   S = PROD(...,NANFLAG) specifies how NaN (Not-A-Number) values are 
%   treated. The default is 'includenan':
%
%   'includenan' - the product of a vector containing NaN values is also NaN.
%   'omitnan'    - the product of a vector containing NaN values
%                  is the product of all its non-NaN elements. If all 
%                  elements are NaN, the result is 1.
%
%   Examples:
%       X = [0 1 2; 3 4 5]
%       prod(X,1)
%       prod(X,2)
%
%       X = int8([5 5 5 5])
%       prod(X)              % returns double(625), accumulates in double
%       prod(X,'native')     % returns int8(127), because it accumulates in 
%                            % int8, but overflows and saturates.

%   See also SUM, CUMPROD, DIFF.

%   Copyright 1984-2015 The MathWorks, Inc.

%   Built-in function.
