function timercb(varargin)
%TIMERCB Wrapper for timer object callback.
%
%   See also TIMER
%

%    Copyright 2004 The MathWorks, Inc.

%Create a timer object out of the JavaTimer, and then call the object
%timercb.
h = handle(varargin{1});
if strcmp(varargin{2},'DeleteFcn')
    h.dispose();
    h.delete();
else
    obj = mltimerpackage('GetList');
    jobjs = obj.getJobjects;

    idxIntoTimerObject = false(size(jobjs));
    for i = 1:numel(h)
        % equivalent to idxIntoTimerObject = (jobjs == h(i)) | idxIntoTimerObject;
        idxIntoTimerObject(jobjs == h(i)) = true;
    end
    timercb(obj(idxIntoTimerObject), varargin{2:end});
end
