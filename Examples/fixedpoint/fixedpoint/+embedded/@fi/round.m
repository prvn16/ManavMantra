function Y = round(A)
%ROUND  Round towards nearest integer - ties round away from zero
%   Y = ROUND(A) rounds fi object A to the nearest integer or, in case of a
%   tie, to the nearest integer with absolute value greater than that of A,
%   then returns the result in fi object Y.
%
%   Y and A have the same fimath object and DataType property.
%
%   When the DataType property of A is 'Single', 'Double' or 'Boolean', the
%   numerictype of Y is the same as that of A. 
%
%   When the fraction length of A is zero or negative, A is already an 
%   integer, and the numerictype of Y is the same as that of A.
%
%   When the fraction length of A is positive, the fraction length of Y is
%   0, its signedness is the same as that of A, and its word length is
%   the difference between the word length and fraction length of A, plus
%   one bit. If A is signed, then the minimum word length of Y is 2. If A is
%   unsigned, then the minimum word length of Y is 1.
%
%   For complex fi objects, the imaginary and real parts are rounded 
%   independently.
%
%   ROUND does not support fi objects with nontrivial slope and bias 
%   scaling. Slope and bias scaling is trivial when the slope is an integer
%   power of 2 and the bias is zero.
%
%   See also EMBEDDED.FI/CEIL, EMBEDDED.FI/CONVERGENT, EMBEDDED.FI/FIX, 
%            EMBEDDED.FI/FLOOR, EMBEDDED.FI/NEAREST

%   Copyright 2007-2012 The MathWorks, Inc.

Y = fi_matlab_style_round_helper(A, mfilename, 1);
