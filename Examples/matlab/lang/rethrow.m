%RETHROW  Reissue error.
%   In order to avoid global state, it is better to use the MException 
%   object in order to reissue errors.  See help for MException/rethrow.
%
%   RETHROW(ERR) reissues an error as stored in the structure ERR. The
%   currently running function terminates and control is returned to the
%   keyboard, unless an enclosing CATCH block is present. ERR must be a 
%   structure containing at least the following two fields:
%
%       message    : the text of the error message 
%       identifier : the message identifier of the error message 
%
%   ERR can also contain the field 'stack', identical in format to the
%   output of the DBSTACK command.  If the 'stack' field is present, MATLAB 
%   sets the stack of the rethrown error to that value.  Otherwise, the 
%   stack is set to the line at which the rethrow occurs.
%
%   See help for ERROR for more information about error message
%   identifiers.
%
%   See also MException, MException/rethrow, ERROR, TRY, CATCH.

%   Copyright 1984-2015 The MathWorks, Inc.
%   Built-in function.
