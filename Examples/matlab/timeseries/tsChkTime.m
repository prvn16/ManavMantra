function time = tsChkTime(time)
%
% tstool utility function
% Copyright 2004-2011 The MathWorks, Inc.

stime = size(time);
if length(stime)>2 
    error(message('MATLAB:tsChkTime:manytimedim'))
end
if max(stime)<1
    error(message('MATLAB:tsChkTime:shorttime'))
end
if stime(2)>1
    stime = stime(2:-1:1);
    time = reshape(time,stime);
end
if stime(2)~=1
    error(message('MATLAB:tsChkTime:matrixtime'))
end
if any(isinf(time)) || any(isnan(time))
    error(message('MATLAB:tsChkTime:inftime'))
end
if ~all(isreal(time))
    error(message('MATLAB:tsChkTime:realtime'))
end
