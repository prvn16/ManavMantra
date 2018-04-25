%STRIPSCALING Stored integer of fi object
%   I = stripscaling(A) returns the stored integer of A as a fi object with 
%   zero bias and the same word length and sign as A.
%   Stripscaling is useful for converting the value of a fi object to its 
%   stored integer value without changing any other parameters.
%
%   Example:
%   fipref('NumericTypeDisplay','short','FimathDisplay','none');
%   format long g
%   a = fi(0.1,true,48,47)
%   % real world value of a
%   b = stripscaling(a)
%   % integer value of b and a are identical, not real world values
%   bin(a)
%   bin(b)
%   % stored integer values of a and b are identical, as seen from
%   % a binary display; real world-values are non-identical as the 
%   % scaling of a has been 'stripped off' to create a

%   Copyright 1999-2012 The MathWorks, Inc.
