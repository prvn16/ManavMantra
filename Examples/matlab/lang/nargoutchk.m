%NARGOUTCHK Validate number of output arguments. 
%   NARGOUTCHK(LOW,HIGH) throws an error if nargout is less than LOW or
%   greater than HIGH.
%   
%   MSGSTRUCT = NARGOUTCHK(LOW,HIGH,N,'struct') returns an error message 
%   structure if N is less than LOW or greater than HIGH. If N is in the
%   specified range, the message structure is empty. The message structure
%   has at a minimum two fields, 'message' and 'identifier'.
%
%   MSG = NARGOUTCHK(LOW,HIGH,N) returns error message text if N is 
%   less than LOW or greater than HIGH. If N is in the specified range, 
%   NARGOUTCHK returns an empty matrix.
%
%   MSG = NARGOUTCHK(LOW,HIGH,N,'string') is the same as 
%   MSG = NARGOUTCHK(LOW,HIGH,N).
% 
%   Example
%      nargoutchk(1, 3)
%
%   See also NARGINCHK, NARGOUT, INPUTNAME, ERROR.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.
