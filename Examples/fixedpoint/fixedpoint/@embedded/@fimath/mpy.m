%MPY    Multiply two fi objects using fimath object
%   C = F.MPY(A,B) performs element-wise multiplication on A and B using 
%   fimath object F. 
%
%   This is helpful in cases when you want to override the fimath properties 
%   associated with A and B, or if the fimath properties associated with A 
%   and B are different.
%
%   A and B must be fi objects and must have the same dimensions unless one is a scalar.
%   If either A or B is scalar, then C has the dimensions of the nonscalar
%   object.
%
%   Example: 
%   % In this example, c is the 40-bit product of a and b with fraction 
%   % length 30.
%   a = fi(pi);
%   b = fi(exp(1));
%   F = fimath('ProductMode','SpecifyPrecision',...
%		'ProductWordLength',40,'ProductFractionLength',30);
%   c = F.mpy(a, b)
%   % returns pi*exp(1) = 8.5397
%
%   Algorithm:
%     C = F.MPY(A,B) is equivalent to:
%     A.fimath = F;
%     B.fimath = F;
%     C = A .* B;
%     except that the fimath properties of a and b are not modified when  
%     you use the functional form.
%
%   See also EMBEDDED.FIMATH/ADD, EMBEDDED.NUMERICTYPE/DIVIDE, FI, 
%            FIMATH, NUMERICTYPE, EMBEDDED.FIMATH/SUB, 
%            EMBEDDED.FI/SUM

%   Copyright 1999-2010 The MathWorks, Inc.
