%MAXLOG Largest real-world value of fi object logged
%   MAXLOG(A) returns the largest real-world value of fi object A since 
%   logging was turned on or since the last time the log was reset for
%   the object.
%   
%   Example:
%     p = fipref('LoggingMode','on');
%     % turn LoggingMode on
%     x = fi([-1.5 eps 0.5], true, 16, 13);
%     x(1) = 3.0;
%     maxlog(x)
%     % returns 3; warns about underflow in assignment 
% 
%   See also FIPREF, EMBEDDED.FI/MINLOG, EMBEDDED.FI/NOVERFLOWS,
%            EMBEDDED.FI/NUNDERFLOWS, EMBEDDED.FI/RESETLOG

%   Copyright 1999-2012 The MathWorks, Inc.
