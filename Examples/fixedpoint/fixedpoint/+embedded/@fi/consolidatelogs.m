function c = consolidatelogs(varargin)
%CONSOLIDATELOGS Consolidate fi logs
%   L = CONSOLIDATELOGS(A, B, ...) consolidates the logs of A, B, ... into the
%   global fi log map and reset the logs of A, B, ..., where the input variables
%   are all fi objects.  A cell array containing the contents of the global fi
%   log is returned in L.
%
%   Logs are written to the global fi log whenever an object is cleared, or when
%   this function is called.
%
%   Example:
%     fipref('LoggingMode','on');
%     fipref('LogType','Tag');
%     a = fi(magic(3));
%     b = a*a;
%     L = consolidatelogs(a,b)
%
%   See also FI, FIPREF
    
%   Tag logging was featured off in R2006b.  To turn it on, do
%     feature FiTagLogging on

%   Thomas A. Bryan, 5 April 2006
%   Copyright 2003-2012 The MathWorks, Inc.

for k=1:length(varargin);
    consolidatelocalfilogs(varargin{k});
end

c = embedded.filog.getlogs;
