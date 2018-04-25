%SDEC   Signed decimal representation of stored integer of fi object
%   SDEC(A) returns signed decimal representation of stored integer of fi 
%   object A. 
%
%   Fixed-point numbers can be represented as:
%
%      real_world_value = 2^(-fraction_length)*(stored_integer)
%
%   or, equivalently,
%
%      real_world_value = (slope * stored_integer) + (bias)
%   
%   The stored integer is the raw binary number, in which the binary point
%   is assumed to be at the far right of the word.
%   SDEC(A) returns the stored integer of fi object A in signed decimal 
%   format as a string.
%
%   Example:
%     a = fi([-1 1],1,8,7);
%     sdec(a)
%     % returns '-128'   '127'
%
%   See also EMBEDDED.FI/BIN, EMBEDDED.FI/DEC, EMBEDDED.FI/HEX, 
%            EMBEDDED.FI/OCT, EMBEDDED.FI/storedInteger

%   Copyright 1999-2012 The MathWorks, Inc.
