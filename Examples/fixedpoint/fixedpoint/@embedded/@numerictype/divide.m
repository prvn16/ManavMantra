%DIVIDE Divide two fi objects
%   C = DIVIDE(T,A,B) and C = T.DIVIDE(A,B) perform division on the
%   elements of A by the elements of B. The result C is a fi object which
%   has numerictype object T.
%   A and B must have the same dimensions unless one is a scalar. If either
%   A or B is scalar, then C has the dimensions of the nonscalar object.
%   If either A or B is a fi object, and the other is a MATLAB built-in 
%   numeric type, then the built-in object is cast to the word length of 
%   the fi object, preserving best-precision fraction length. If A and B 
%   are both MATLAB built-in doubles or singles, then C is the 
%   floating-point quotient A./B, and numerictype T is ignored. A and B must
%   have the same dimensions unless one is a scalar. If either A or B is 
%   scalar, then C has the dimensions of the nonscalar object.
%
%   If either A or B is a fi object, and the other is a MATLAB built-in 
%   numeric type, then the built-in object is cast to the word length of 
%   the fi object, preserving best-precision fraction length.
%
%   Note: The divide function is not currently supported for Slope-Bias
%   signals
%
%   Example: To illustrate the precision of the fi divide function:
%     P = fipref('NumberDisplay','bin','NumericTypeDisplay','short',...
% 				'FimathDisplay','none');
%     a = fi(0.1, false, 80, 83)
%     % displays a
%     % Notice that the infinite repeating representation is truncated 
%     % after 52 bits, because the mantissa of an IEEE standard  
%     % double-precision floating-point number has 52 bits.
%     % Contrast the above to calculating 1/10 in fixed-point arithmetic 
%     % with the quotient set to the same numeric type as before:
%     T = numerictype('Signed',false,'WordLength',80,...
%					      'FractionLength',83);
%     a = fi(1);
%     b = fi(10);
%     c = T.divide(a,b);
%     c.bin
%     % displays binary value of c
%     % Notice that when you use the divide function, the quotient is 
%     % calculated to the full 80 bits, regardless of the precision of a 
%     % and b. Thus, the fi object c represents 1/10 more precisely than 
%     % IEEE standard double-precision floating-point number can. With 
%     % 1000 bits of precision,
%     T = numerictype('Signed',false,'WordLength',1000,...
%					      'FractionLength',1003);
%     a = fi(1);
%     b = fi(10);
%     c = T.divide(a,b);
%     c.bin
%     % displays binary value of c
%
%   See also EMBEDDED.FIMATH/ADD, FI, FIMATH, EMBEDDED.FIMATH/MPY,
%            NUMERICTYPE, EMBEDDED.FIMATH/SUB, 
%            EMBEDDED.FI/SUM

%   Copyright 1999-2006 The MathWorks, Inc.
