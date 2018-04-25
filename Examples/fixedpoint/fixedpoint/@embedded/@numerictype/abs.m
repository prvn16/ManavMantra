function Y = abs(A, varargin)
%ABS    Absolute value of built-in data-type with numerictype and (possibly) fimath
%
%   ABS(A,T) and ABS(A,T,F) return the absolute value of built-in argument 
%   A; Numerictype T and Fimath F (if specified) are ignored
%
%
%   See also EMBEDDED.FI/ABS, EMBEDDED.FIMATH/ABS, 
%            EMBEDDED.FI/COMPLEXABS, FI, EMBEDDED.FI/REALABS

%   Copyright 1999-2015 The MathWorks, Inc.
%     

narginchk(2,3);
if (nargin == 3)&&(~isfimath(varargin{2}))
    error(message('fixed:fi:invalidSyntax', 'abs')); 
end
if (isnumerictype(A))
    error(message('fixed:fi:invalidSyntax', 'abs')); 
end

Y = abs(A);

