%SINGLE Single-precision  floating-point real-world value of fi object
%   SINGLE(A) returns the real-world value of fi object A in 
%   single-precision floating point. 
%
%   Fixed-point numbers can be represented as:
%
%      real_world_value = 2^(-fraction_length)*(stored_integer)
%
%   or, equivalently,
%
%      real_world_value = (slope * stored_integer) + (bias)
%   
%   SINGLE(A) returns the real_world_value corresponding to A.
%
%   See also EMBEDDED.FI/DOUBLE

%   Copyright 1999-2012 The MathWorks, Inc.
