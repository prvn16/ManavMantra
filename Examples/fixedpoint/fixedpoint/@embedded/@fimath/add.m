%ADD    Add two fi objects using fimath object
%   C = F.ADD(A,B) adds objects A and B using fimath object F. 
%
%   This is helpful in cases when you want to override the fimath properties 
%   associated with A and B, or if the fimath properties associated with A 
%   and B are different.
%
%   A and B must be fi objects and must have the same dimensions unless one is a scalar.
%   If either A or B is scalar, then C has the dimensions of the nonscalar
%   object.
%
%   Example: add two fi objects overriding their fimath:
%     a = fi(pi);
%     b = fi(exp(1));
%     F = fimath('SumMode','SpecifyPrecision','SumWordLength', ...
%		   		   32,'SumFractionLength',16);
%     c = F.add(a,b)
%     % returns sum of 'a' and 'b', with real world value 5.8599
%
%   Algorithm:
%     C = F.add(A,B) is equivalent to:
%     A.fimath = F;
%     B.fimath = F;
%     C = A + B;
%     except that the fimath properties of a and b are not modified when  
%     you use the functional form.
%
%   See also EMBEDDED.NUMERICTYPE/DIVIDE, FI, FIMATH, 
%            EMBEDDED.FIMATH/MPY, NUMERICTYPE, EMBEDDED.FIMATH/SUB, 
%            EMBEDDED.FI/SUM

%   Copyright 1999-2010 The MathWorks, Inc.
