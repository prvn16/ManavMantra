%NARGCHK Validate number of input arguments. 
%   MSGSTRUCT = NARGCHK(LOW,HIGH,N,'struct') returns an appropriate error
%   message structure if N is not between LOW and HIGH. If N is in the
%   specified range, the message structure is empty. The message structure
%   has at a minimum two fields, 'message' and 'identifier'.
%
%   MSG = NARGCHK(LOW,HIGH,N) returns an appropriate error message if
%   N is not between LOW and HIGH. If it is, NARGCHK returns an empty matrix. 
%
%   MSG = NARGCHK(LOW,HIGH,N,'string') is the same as 
%   MSG = NARGCHK(LOW,HIGH,N).
% 
%   NARGCHK is not recommended. Use NARGINCHK instead.
%
%   Example
%      narginchk(1,3)
%
%   See also NARGINCHK, NARGOUTCHK, NARGIN, NARGOUT, INPUTNAME, ERROR.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.
