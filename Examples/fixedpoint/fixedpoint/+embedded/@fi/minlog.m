%MINLOG Smallest real-world value of fi object logged
%   MINLOG(A) returns the smallest real-world value of fi object A since 
%   logging was turned on or since the last time the log was reset for
%   the object.
%   
%   Example:
%     p = fipref('LoggingMode','on');
%     % turn LoggingMode on
%     x = fi([-1.5 eps 0.5], true, 16, 13);
%     x(1) = 3.0;
%     minlog(x)
%     % returns -1.5; warns about underflow in assignment 
% 
%   See also FIPREF, EMBEDDED.FI/MAXLOG, EMBEDDED.FI/NOVERFLOWS,
%            EMBEDDED.FI/NUNDERFLOWS, EMBEDDED.FI/RESETLOG

%   Copyright 1999-2012 The MathWorks, Inc.
