function [flag,varargout] = tsIsSameTime(time1, time2, varargin) 
%
% tstool utility function

%   Copyright 2005-2007 The MathWorks, Inc.

% TSISSAMETIME returns true if the two time vectors are the same

% Check if the threshold is provided by user
if nargin == 3 
    threshold = varargin{1};
else
    threshold = 1e-10;
end
% check if the length of time vector match
if length(time1)~=length(time2)
    flag = false;
    if nargout>1
        varargout{1} = [];
    end
    return
end
% Single time point at 0
if length(time1)==1 && time1 == 0
    v = abs(time1-time2)<=threshold;
    if v
        flag = true;
    else
        flag = false;
    end
% Otherwise
else
    v = abs(time1-time2)/mean(abs(time1))<=threshold;
    if all(v)
        flag = true;
    else
        flag = false;
    end
end

if nargout>1
    varargout{1} = v;
end