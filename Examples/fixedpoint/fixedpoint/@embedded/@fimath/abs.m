function Y = abs(A, varargin)
%ABS    Absolute value of built-in data-type with fimath and (possibly) numerictype 
%
%   ABS(A,F) and ABS(A,F,T) return the absolute value of built-in argument
%   A; Fimath F and Numerictype T (if specified) are ignored
%
%
%   See also EMBEDDED.FI/ABS, EMBEDDED.NUMERICTYPE/ABS,
%            EMBEDDED.FI/COMPLEXABS, FI, EMBEDDED.FI/REALABS

%   Copyright 1999-2015 The MathWorks, Inc.
%     

narginchk(2,3);
if (nargin == 3)&&(~isnumerictype(varargin{2}))
    error(message('fixed:fi:invalidSyntax', 'abs')); 
end
if (isfimath(A))
    error(message('fixed:fi:invalidSyntax', 'abs')); 
end

Y = abs(A);

