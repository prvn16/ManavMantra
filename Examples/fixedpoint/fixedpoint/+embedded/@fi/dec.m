%DEC    Unsigned decimal representation of stored integer of fi object
%   DEC(A) returns unsigned decimal representation of stored integer of fi 
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
%   DEC(A) returns the stored integer of fi object A in unsigned decimal 
%   format as a string.
%
%   Example:
%     a = fi([-1 1],1,8,7);
%     dec(a)
%     % returns '128'   '127'
%
%   See also EMBEDDED.FI/BIN, EMBEDDED.FI/HEX, EMBEDDED.FI/OCT,
%            EMBEDDED.FI/SDEC, EMBEDDED.FI/storedInteger

%   Copyright 1999-2012 The MathWorks, Inc.
